//
//  ViewController.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/6/20.
//

import UIKit
import Photos
import MetalKit
let kDocumentsPath = NSHomeDirectory() + "/Documents"


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        button.frame = CGRect.init(x: UIScreen.main.bounds.width/2 - 100, y: UIScreen.main.bounds.height/2 , width: 200, height: 200)
        self.view.addSubview(button)
        PHPhotoLibrary.requestAuthorization { (grand) in
            if grand == .authorized {
                print("同意")
                DispatchQueue.main.async {
                    self.button.isEnabled = true
                }
            }else {
                print("处理好权限再使用")
            }
        }
        
    }
    
    @objc func touchBtn()  {
        
        print("开始扫描 ")
        let fetchTime = Date().timeIntervalSince1970
        print("开始时间\(Date().timeIntervalSince1970)")
        
        loadAllSimilarData {
            print("扫描完成")
            let time = Date().timeIntervalSince1970 - fetchTime
            let _ = SimilarDataHelper.shared.similarlyData
            print("相似照片有\(SimilarDataHelper.shared.count)张")
            print("用时\(time)")
            let vc = ShowPhotoViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func loadAllSimilarData(finishCallback:(()->())?) {
        SimilarPhotoHelper.shared.reloadPhoto()
        if let handle = finishCallback {
            handle()
        }
    }
    
    lazy var button:UIButton = {
        var btn = UIButton()
        btn.setTitle("点击开始扫描", for: .normal)
        btn.isEnabled = false
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(touchBtn), for: .touchUpInside)
        return btn
    }()
    
}

