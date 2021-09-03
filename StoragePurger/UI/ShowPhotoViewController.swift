//
//  ShowPhotoViewController.swift
//  ClearAlgorithms
//
//  Created by priders on 2021/8/31.
//

import UIKit
import Photos

class ShowPhotoViewController: UIViewController {
    
    let dateMatter = DateFormatter.init()

    
    static let imageManager: PHCachingImageManager = {
        return PHCachingImageManager() // 使用的时候才加载，否则会再一开始就请求权限
    }()

    static let imgOpt: PHImageRequestOptions = {
        let imgOpt = PHImageRequestOptions()
        imgOpt.deliveryMode = .highQualityFormat // 保证质量
        imgOpt.resizeMode = .exact // 保证大小是 256 * 256
        imgOpt.isSynchronous = true // 同步
        return imgOpt
    }()

    var sameDate:[SimilarlyPhotoModel]  {
        return SimilarDataHelper.shared.similarlyData
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionV.frame = CGRect(x: 0, y: 44 + 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        leftBtn.frame = CGRect(x: 100, y: 44, width: 50, height: 50)
        self.view.addSubview(leftBtn)
        self.view.addSubview(collectionV)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    private var leftBtn:UIButton = {
        let btn = UIButton.init(frame: CGRect(x: 100, y: 44, width: 50, height: 50))
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(leftBtnTouchInsideEvent), for: .touchUpInside)
        return btn
    }()
    
    private var collectionV:UICollectionView {
        
        let viewLayout = UICollectionViewFlowLayout.init()
        viewLayout.itemSize = CGSize.init(width: 80, height: 80)
        viewLayout.scrollDirection = .vertical
        viewLayout.minimumLineSpacing = 10
        viewLayout.minimumInteritemSpacing = 10
        viewLayout.headerReferenceSize = CGSize(width: 376, height:50)

        let collectionV = UICollectionView.init(frame: CGRect(x: 0, y: 44 + 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: viewLayout)
//        collectionV.backgroundColor = .orange
        
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionV.register(SortHeadCell.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "cellh")
    
        return collectionV
        
    }
    
    @objc func leftBtnTouchInsideEvent(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
extension ShowPhotoViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sameDate.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sameDate[section].modelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell {
            cell.imageAsset = sameDate[indexPath.section].modelList[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "UICollectionElementKindSectionHeader" {
            if let cellHead = collectionView.dequeueReusableSupplementaryView(ofKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: "cellh", for: indexPath) as? SortHeadCell {
                dateMatter.dateFormat = "yyyy_MM.dd"
                cellHead.title = dateMatter.string(from: Date.init(timeIntervalSince1970: sameDate[indexPath.section].time))
                return cellHead
            }
        }
        return UICollectionReusableView()

    }
    
    
}

class PhotoCell: UICollectionViewCell {
    
    var imageAsset:PHAsset? {
        
        didSet {
            ShowPhotoViewController.imageManager.requestImage(for: imageAsset!, targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: ShowPhotoViewController.imgOpt) { (image, info) in
                self.imageV.image = image
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageV.frame = bounds
        self.contentView.addSubview(imageV)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    private lazy var imageV = UIImageView()
}

class SortHeadCell: UICollectionReusableView {
    var title:String? {
        didSet {
            label.text = title
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.gray
        self.backgroundColor = .white
        self.addSubview(label)
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var label = UILabel()
}
