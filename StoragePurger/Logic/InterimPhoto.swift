//
//  InterimPhoto.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/9/2.
//

import UIKit
import Photos

class InterimPhoto: NSObject {
    
    var asset:PHAsset?
    var id:String?
    var tagHit:Bool = false
    var dhashValue:UnsafeMutablePointer<Int32>?
    
    class func sortPhoto(willSortPhoto:[InterimPhoto]) -> [[PHAsset]]?{
        var resultArr:[[PHAsset]] = [[PHAsset]]()
        if willSortPhoto.count < 2 {
            return nil
        }
        
        for i in 0..<willSortPhoto.count { // n
            
            let referencePhoto = willSortPhoto[i]
            var subArray = [PHAsset]()
            subArray.append(referencePhoto.asset!)
            
            if referencePhoto.tagHit {
                continue
            }

            for j in i+1..<willSortPhoto.count { // n-1
                
                let contrastPhoto = willSortPhoto[j]

                //本来是按照时间排序第一 第二张超过了1小时 不认为为相似图片 //速度影响比较多
                if !allowWithin(time: 1, reference: referencePhoto.asset, contrast: contrastPhoto.asset) {
                    //break 在1小时以外的一组直接忽略 时间优化 节省 遍历 和 hanmingDistance处理
                    continue // continue 相当于 无时间间隔图片优化 一张张跳过节省hanmingDistance处理
                }
                if contrastPhoto.tagHit  {
                    continue
                }
                
                let hanmingDistance = referencePhoto.hanmingDistance(contrastPhoto) // 64 * 64
                if hanmingDistance < 10 {
                    subArray.append(contrastPhoto.asset!)
                    referencePhoto.tagHit = true
                    contrastPhoto.tagHit = true
                }
                
            }
            if subArray.count > 1{
                resultArr.append(subArray)
            }
        }
        
        return resultArr.isEmpty ? nil : resultArr
    }
    
    class private func allowWithin(time:Int,reference:PHAsset?,contrast:PHAsset?) -> Bool{
        guard let refDate = reference?.creationDate,let conDate = contrast?.creationDate else {
            return true
        }
        let referenceTime = Calendar.current.component(.hour, from: refDate)
        let contrastTime = Calendar.current.component(.hour, from: conDate)
        return abs(referenceTime - contrastTime) < 1
    }
    
    func hanmingDistance(_ contrast:InterimPhoto) -> Int {
        guard self.dhashValue != nil && contrast.dhashValue != nil else {
            return 11
        }
        let maxHanmingDistance = 10 //小于这个距离才算相似
        let maxPixelNumber = 64 //8*8 最大64个点
        var differentNumber = 0
        for i in 0..<maxPixelNumber {
            //大于10 可以不做比较了 不相似（不做处理）
            if differentNumber > maxHanmingDistance {
                break
            }
            if (maxPixelNumber - i + differentNumber ) < 10 {
                //假设 剩下的全部不相似 那么就是 例子：64-62 + 7 < 10 那么就是相似图片
                differentNumber = maxPixelNumber - i + differentNumber
                break
            }
            if self.dhashValue![i] != contrast.dhashValue![i] {
                differentNumber+=1
            }
        }
        return differentNumber
    }
}
