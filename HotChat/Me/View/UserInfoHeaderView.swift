//
//  UserInfoHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import FSPagerView
import Kingfisher
import SnapKit
import AlignedCollectionViewFlowLayout

extension ValidationStatus {
    
    var alpha: CGFloat {
        switch self {
        case .ok:
            return 1
        default:
            return 0
        }
    }
    
}

class UserInfoHeaderView: UIView {
    
    private let reuseIdentifier = "PhotoViewCell"
    
    @IBOutlet weak var contentView: UIView!
    
    lazy var pagerView: FSPagerView = {
        let view = FSPagerView()
        view.bounces = false
        view.delegate = self
        view.dataSource = self
        return view
    }()
    

    
    @IBOutlet weak var pagerContainerView: UIView!
    
    @IBOutlet weak var indicatorLabel: UILabel!
    
    let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .right, verticalAlignment: .top)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    @IBOutlet weak var vipButton: UIButton!
    
    
    @IBOutlet weak var sexView: LabelView!
    

    @IBOutlet weak var gradeView: UIImageView!
    
    
    let onFollowButtonTapped = Delegate<UserInfoHeaderView, Void>()
    
    var user: User! {
        didSet {
            selectIndex = 0
            reloadData()
        }
    }
    
    

    
    var count: Int {
        guard let user = user else {
            return 0
        }
        return user.photoList.count  + 1
    }
    
    fileprivate var selectIndex: Int = 0 {
        didSet {
            indicatorLabel.text = "\(selectIndex + 1)/\(count)"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pagerContainerView.addSubview(pagerView)
        pagerView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        layoutIfNeeded()
        
        pagerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        pagerView.register(PhotoViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        alignedFlowLayout.itemSize = CGSize(width: 30, height: 30)
        alignedFlowLayout.minimumInteritemSpacing = 4
        
        collectionView.collectionViewLayout = alignedFlowLayout
        collectionView.register(UINib(nibName: "PhotoViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoViewCell")
        
    }
    
    
    func reloadData() {
        
        
        collectionView.reloadData()
        pagerView.reloadData()
        nicknameLabel.text = user.nick
        sexView.setSex(user)
        gradeView.setGrade(user)
        vipButton.setVIP(user.vipType)
        authenticationButton.alpha = user.headStatus.alpha
        locationLabel.text = user.region
        statusLabel.text = user.onlineStatus.text
        statusLabel.textColor = user.onlineStatus.color
        
    }
    
    @IBAction func followAction(_ sender: Any) {
        onFollowButtonTapped.call(self)
    }
    
}


extension UserInfoHeaderView: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return count
    }
    
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, at: index) as! PhotoViewCell
        
        configureCell(cell, for: index)
        
        return cell
    }
    
    func configureCell(_ cell: PhotoViewCell, for index: Int) {
        
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.backgroundColor = UIColor(hexString: "DDDDDD")
        
        if index == 0 {
            cell.imageView?.kf.setImage(with: URL(string: user.headPic))
        }
        else {
            
            let urlString = user.photoList[index - 1].picUrl
            cell.imageView?.kf.setImage(with: URL(string: urlString))
        }
        
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        selectIndex = targetIndex
        collectionView.reloadData()
    }
}


extension UserInfoHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PhotoViewCell.self)
        configureCell(cell, for: indexPath.item)
        cell.layer.cornerRadius = 2
        
        if indexPath.item == selectIndex {
            cell.imageView?.isOpaque = true
            cell.imageView?.alpha  = 1
            cell.imageView?.layer.borderWidth = 1
            cell.imageView?.layer.borderColor = UIColor.white.cgColor
        }
        else {
            cell.imageView?.isOpaque = false
            cell.imageView?.alpha   = 0.4
            cell.imageView?.layer.borderWidth = 0
            cell.imageView?.layer.borderColor = nil
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectIndex = indexPath.item
        pagerView.scrollToItem(at: selectIndex, animated: false)
        collectionView.reloadData()
    }
    
    
}
