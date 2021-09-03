//
//  ViewController.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/6/20.
//

import UIKit
import Photos
import MetalKit

class ViewController: UIViewController {
    
    let loadAllSimilarDataDispatchQueue = DispatchQueue.init(label: "LoadAllSimilarDataDispatchQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        button.frame = CGRect.init(x: UIScreen.main.bounds.width/2 - 100, y: UIScreen.main.bounds.height/2 - 100 , width: 200, height: 200)
        loadingView.frame = CGRect.init(x: UIScreen.main.bounds.width/2 - 100 / 2, y:  UIScreen.main.bounds.height/2 - 100 / 2, width: 100, height: 100)
        label.frame = CGRect.init(x: UIScreen.main.bounds.width/2 - 300 / 2 , y:  UIScreen.main.bounds.height/2 , width: 300, height: 100)
        self.view.addSubview(button)
        self.view.addSubview(loadingView)
        self.view.addSubview(label)

        loadingView.isHidden = true
        loadingView.color = .cyan
        if #available(iOS 13.0, *) {
            loadingView.style = .large
        } else {
            loadingView.style = .whiteLarge
        }
        
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
        loadingView.isHidden = false
        loadingView.startAnimating()
        label.isHidden = false
        button.isHidden = true

        loadAllSimilarData {
            print("扫描完成")
            let time = Date().timeIntervalSince1970 - fetchTime
            let _ = SimilarDataHelper.shared.similarlyData
            print("相似照片有\(SimilarDataHelper.shared.count)张")
            print("用时\(time)")
            
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
            let vc = ShowPhotoViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: {
                self.button.isHidden = false
                self.label.isHidden = true

            })
            
        }
    }
    
    func loadAllSimilarData(finishCallback:(()->())?) {
        loadAllSimilarDataDispatchQueue.async {
            
            SimilarPhotoHelper.shared.reloadPhoto {
                DispatchQueue.main.async {
                    if let handle = finishCallback {
                        handle()
                    }
                }
            }
            
        }
    }
    
    lazy var button:UIButton = {
        var btn = UIButton()
        btn.setTitle("点击开始扫描", for: .normal)
        btn.isEnabled = false
        btn.backgroundColor = .darkGray
        btn.addTarget(self, action: #selector(touchBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var loadingView :UIActivityIndicatorView = UIActivityIndicatorView()
    
    lazy var label:UILabel = {
        let label  = UILabel()
        label.text = "正在扫描 请稍等"
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
}

