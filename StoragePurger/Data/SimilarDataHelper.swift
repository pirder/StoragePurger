//
//  SimilarDataHelper.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/9/3.
//

import UIKit
import Photos

class SimilarDataHelper: NSObject {
    static let shared = SimilarDataHelper()
    var count = 0

    lazy var similarlyData: [SimilarlyPhotoModel] = {
        
        let sameData = SimilarPhotoHelper.shared.similarlyAllImages
        
        var newData: Array<SimilarlyPhotoModel> = [SimilarlyPhotoModel]()
        for key in orderSameKey(By: sameData) {
            var i = 0
            let contentList :Array = sameData[key] ?? Array()
            for modelList in contentList {
                let photoModel = SimilarlyPhotoModel()
                photoModel.modelList = modelList
                photoModel.time = Double(key)
                photoModel.groud = i
                newData.append(photoModel)
                count+=modelList.count
                i += 1
            }
        }
        return newData
    }()
    
    func orderSameKey(By dict:Dictionary<Int, Any>) -> Array<Int> {
        return dict.keys.sorted { (str1, str2) -> Bool in
            return str1 > str2
        }
    }
    

    private override init() {
        super.init()
    }
    
    
}

class SimilarlyPhotoModel: NSObject {
    var modelList: [PHAsset] = [PHAsset]()
    var time: TimeInterval = Double(0)
    var groud = 0
}
