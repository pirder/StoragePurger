//
//  SimilarPhotoHelper.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/9/3.
//

import UIKit
import Photos

class SimilarPhotoHelper: NSObject {
    
    static let shared = SimilarPhotoHelper()
    
    private lazy var imageManager: PHCachingImageManager = {
        return PHCachingImageManager() // 使用的时候才加载，否则会再一开始就请求权限
    }()
    
    private lazy var imgOpt:PHImageRequestOptions = {
        let imgOpt = PHImageRequestOptions()
        imgOpt.deliveryMode = .highQualityFormat // 保证质量
        imgOpt.resizeMode = .exact // 保证大小是 256 * 256
        imgOpt.isSynchronous = true // 同步
        return imgOpt
    }()
    
    /// 计算dhash 和 sortPhoto 最大并发数
    let concureentQueue = YHDispatchQueue.init(maxConcurrentC: 5)
    
    
    var tempAllImages: [Int : [PHAsset]]  = [Int : [PHAsset]]()
    var resultDhashImages: [Int :[InterimPhoto]] = [Int : [InterimPhoto]]()
    var similarlyAllImages: [Int : [[PHAsset]] ] = [Int : [[PHAsset]] ]()
    
    func reloadPhoto() {
        // 1. 获取 所有的照片, 根据创建时间降序排序
        let optscols = PHFetchOptions()
        // 按照创建时间倒序排列
        optscols.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                     ascending: false)]
        
        let cols = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                       options: optscols)
        
        // 2. 遍历所有 assets，整合成 [图片] 数组
        let timeTagCol = Date.init().timeIntervalSince1970
        cols.enumerateObjects { (asset, index, isOrNot) in
            if let date = asset.creationDate {
                let key = self.getZeroTimestamp(ofDate: date)
                if self.tempAllImages.keys.contains(key) {
                    self.tempAllImages[key]?.append(asset)
                }else{
                    self.tempAllImages[key] = [asset]
                }
            }
        }
        print("获取所有的相册 时间\(Date().timeIntervalSince1970 - timeTagCol)")
        
        let dhashAllPhotoTag = Date.init().timeIntervalSince1970
        let group = DispatchGroup.init()
        //防止多线程数据写入问题
        let semaphore = DispatchSemaphore.init(value: 1)
        group.enter()
        for assetArray in self.tempAllImages {
            autoreleasepool {
                concureentQueue.asyncBlock { [weak self] in
                    guard let `self` = self else {return}
                    if assetArray.value.count >= 2 {
                        var interimPhotos = [InterimPhoto]()
                        for photo in assetArray.value {
                            autoreleasepool {
                                self.getInterimPhoto(with: photo) { (resultPhoto) in
                                    interimPhotos.append(resultPhoto)
                                }
                            }
                        }
                        if interimPhotos.count > 0 {
                            semaphore.wait()
                            self.resultDhashImages[assetArray.key] = interimPhotos
                            semaphore.signal()
                        }
                    }
                }
            }
        }
        concureentQueue.notify {
            group.leave()
        }
        group.wait()
        print("获取所有的相片 dhash 时间 \(Date().timeIntervalSince1970 - dhashAllPhotoTag)")
        
        let sortPhoto = Date.init().timeIntervalSince1970
        
        group.enter()
        for (key,photos) in self.resultDhashImages {
            
            //            let sortPhotoOne = Date.init().timeIntervalSince1970
            concureentQueue.asyncBlock { [weak self] in
                guard let `self` = self else {return}
                if let asset = InterimPhoto.sortPhoto(willSortPhoto: photos) {
                    if self.similarlyAllImages.keys.contains(key) {
                        if let old = self.similarlyAllImages[key] {
                            self.similarlyAllImages[key] = old + asset
                        }
                    }else{
                        self.similarlyAllImages[key] = asset
                    }
                }
            }
            //            print("对比一组费时\( Date.init().timeIntervalSince1970 - sortPhotoOne) 总数\(cols.count)")
            
        }
        concureentQueue.notify {
            group.leave()
        }
        group.wait()

        print("对比费时\( Date.init().timeIntervalSince1970 - sortPhoto) 总数\(cols.count)")
        
        resultDhashImages.forEach { (item) in
            item.value.forEach {
                $0.dhashValue?.deallocate()
            }
        }
        tempAllImages.removeAll()
        resultDhashImages.removeAll()
        
    }
    
    private override init() {
        super.init()
    }
    
    
    func getZeroTimestamp(ofDate date: Date) -> Int {
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        if let zeroDate = calendar.date(from: components) {
            
            return Int(zeroDate.timeIntervalSince1970)
        }
        
        return 0
    }
    
    func getInterimPhoto(with asset: PHAsset,finishBlock: @escaping (InterimPhoto)->Void) {
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 256, height: 256),
                                  contentMode: .aspectFill, options: imgOpt)
        { (image, info) in
            if let img = image{
                let interimPhoto = InterimPhoto()
                let intPointer = PhotoHashHelper.ImageDhash(img)
                interimPhoto.dhashValue = intPointer
                interimPhoto.asset = asset
                finishBlock(interimPhoto)
            }
        }
    }
    
}
