//
//  DynamicView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class DynamicView: UIView {
    
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    @IBOutlet weak var sexButton: SexButton!
    
    let onAvatarTapped = Delegate<DynamicView, Void>()

    let onImageTapped = Delegate<(DynamicView, IndexPath), Void>()
    
    let onDeleteTapped = Delegate<DynamicView, Void>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "MediaViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaViewCell")
    }
    
    @IBAction func avatarButtonTapped(_ sender: Any) {
        onAvatarTapped.call(self)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        onDeleteTapped.call(self)
    }
    
    
    var dynamic: Dynamic! {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        
        avatarButton.kf.setImage(with: URL(string: dynamic.userInfo.headPic), for: .normal)
        nicknameLabel.text = dynamic.userInfo.nick
        nicknameLabel.textColor = dynamic.userInfo.vipType.textColor
        contentLabel.text = dynamic.content
        
        sexButton.set(dynamic.userInfo)
        
        dateLabel.text = dynamic.timeFormat
        
        collectionViewHeightConstraint.constant = collectionViewHeight()
        
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadData()
    }
    
    let maxSize: CGFloat = UIScreen.main.bounds.width - 20 * 2 - 46 - 12
    
    let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
    
    let horizontalSpacing: CGFloat = 4
    
    let verticalSpacing: CGFloat = 4
    
    var itemsPerRow: CGFloat = 3
    
    

    func collectionViewHeight() -> CGFloat {
        let rows: CGFloat = 1
        let size = itemSize()
        let height = sectionInset.top + sectionInset.bottom +  size.height * rows + (rows - 1) * verticalSpacing
        return height
    }
    
    func itemSize() -> CGSize {

        let itemSize = (maxSize - (sectionInset.left + sectionInset.right) - (itemsPerRow - 1) * horizontalSpacing) / itemsPerRow
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func adjustSize(with size: CGSize) -> CGSize {
        
        let adjustSize: CGSize

        if(size.height > size.width){
            adjustSize = CGSize(width: size.width / size.height * maxSize, height: maxSize)
        } else {
            adjustSize = CGSize(width: maxSize, height: size.height / size.width * maxSize)
        }
        
        return adjustSize
    }
}

extension DynamicView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        onImageTapped.call((self, indexPath))
    }
    
}

extension DynamicView: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let dynamic = dynamic else { return 0 }
        
        if dynamic.type == .video {
            return 1
        }
        
        return dynamic.photoList.count > 3 ? 3 :  dynamic.photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaViewCell.self)
        cell.layer.cornerRadius = 5
        
        cell.moreButton.isHidden = !(indexPath.item == 2 && dynamic.photoList.count > 3)
        
        if dynamic.type == .video {
            cell.imageView.kf.setImage(with: URL(string: dynamic.video!.coverUrl))
            cell.playImageView.isHidden = false
        }
        else {
            let data = dynamic.photoList[indexPath.item]
            cell.imageView.kf.setImage(with: URL(string: data.picUrl))
            cell.playImageView.isHidden = true
        }
        return cell
    }
    
}

 
// MARK: UICollectionViewDelegateFlowLayout

extension DynamicView: UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return itemSize()
        
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return horizontalSpacing
    }


    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return verticalSpacing
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }

}

