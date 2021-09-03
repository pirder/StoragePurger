//
//  GCDConcurrentDemoHelper.swift
//  GCDConcurrentTest
//
//  Created by priders on 2021/6/29.
//

import UIKit

class YHDispatchQueue: NSObject {
    
    let serialQueuueStart = DispatchQueue.init(label: "YHDispatch_serialQueuueStart")
    let concurrentQueue = DispatchQueue.init(label: "YHDispatch_concurrentQueue",attributes: .concurrent)
    var maxConcurrentCount:Int = 5
    let semaphore:DispatchSemaphore!
    let group = DispatchGroup.init()
    

    init(maxConcurrentC:Int) {
        maxConcurrentCount = maxConcurrentC
        self.semaphore = DispatchSemaphore.init(value: maxConcurrentCount)
        super.init()
    }
    
    override init() {
        self.semaphore = DispatchSemaphore.init(value: 5)
        super.init()
    }
    
    
    func asyncBlock(asyncBlock: @escaping ()->Void){
        serialQueuueStart.async (group: self.group) { [weak self] in
            guard let self = self else{return}
            self.semaphore.wait()
            self.concurrentQueue.async{
                asyncBlock()
                self.semaphore.signal()
            }
        }
    }
    
    func notify(finish: @escaping ()->Void){
        group.notify(queue: serialQueuueStart) {
            self.checkAllSemaphoreFinish()
//            YHLog("结束所有")
            finish()
            self.restoreAllSemaphoreFinish()
        }
    }
    
    func checkAllSemaphoreFinish(){
        for _ in 0..<maxConcurrentCount {
            self.semaphore.wait()
        }
    }
    
    func restoreAllSemaphoreFinish(){
        for _ in 0..<maxConcurrentCount {
            self.semaphore.signal()
        }
    }
    
    
    deinit{
//        YHLog("销毁YHDispatchQueue")
    }
    
    
}
