//
//  DynamicDetailViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class DynamicDetailViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var likeButton: HotChatButton!
    
    @IBOutlet weak var giveButton: HotChatButton!
    
    @IBOutlet weak var vipButton: UIButton!
    
    @IBOutlet weak var commentButton: HotChatButton!
    
    
    @IBOutlet weak var moreButton: MinimumHitButton!
    
    
    let onAvatarTapped = Delegate<DynamicDetailViewCell, Void>()
    
    let onLikeTapped = Delegate<DynamicDetailViewCell, Void>()
    
    let onGiveTapped = Delegate<DynamicDetailViewCell, Void>()
    
    let onCommentTapped = Delegate<DynamicDetailViewCell, Void>()
    
    let onImageTapped = Delegate<(DynamicDetailViewCell, Int, [UIImageView]), Void>()
    
    let onMoreButtonTapped = Delegate<DynamicDetailViewCell, Void>()
    
    @IBAction func avatarButtonTapped(_ sender: Any) {
        onAvatarTapped.call(self)
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        onLikeTapped.call(self)
    }
    
    @IBAction func giveButtonTapped(_ sender: Any) {
        onGiveTapped.call(self)
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        onCommentTapped.call(self)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        onMoreButtonTapped.call(self)
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
        vipButton.setVIP(dynamic.userInfo.vipType)        
        likeButton.setTitle(dynamic.zanNum.description, for: .normal)
        likeButton.isSelected = dynamic.isSelfZan
        if dynamic.commentCount > 0 {
            commentButton.setTitle(dynamic.commentCount.description, for: .normal)
        }
        else {
            commentButton.setTitle("评论", for: .normal)
        }
        
        giveButton.setTitle(dynamic.giftNum.description, for: .normal)
        dateLabel.text = dynamic.timeFormat
        
        collectionViewHeightConstraint.constant = collectionViewHeight()
        
        
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    let sectionInset = UIEdgeInsets(top: 15, left: 16, bottom: 1, right: 16)
    
    let horizontalSpacing: CGFloat = 10
    
    let verticalSpacing: CGFloat = 10
    
    let itemsPerRow: CGFloat = 3
    

    func collectionViewHeight() -> CGFloat {
        
        let itemsCount = max(dynamic.photoList.count, 1)
                
        let rows = (CGFloat(itemsCount) / itemsPerRow).rounded(.up)
        let size = itemSize()
        let height = sectionInset.top + sectionInset.bottom +  size.height * rows + (rows - 1) * verticalSpacing
        return height
    }
    
    func itemSize() -> CGSize {
        
        let count = max(dynamic.photoList.count, 1)
        
        if count == 1 {
            if dynamic.type == .video, let video = dynamic?.video, video.size != .zero {
                return adjustSize(with: video.size)
            }
            else if let photo = dynamic.photoList.first, photo.size != .zero {
                return adjustSize(with: photo.size)
            }
        }
        
        let itemSize = (UIScreen.main.bounds.width - (sectionInset.left + sectionInset.right) - (itemsPerRow - 1) * horizontalSpacing) / itemsPerRow
        return CGSize(width: itemSize, height: itemSize)
    }
    
    func adjustSize(with size: CGSize) -> CGSize {
        
        let maxSize = UIScreen.main.bounds.width * 0.4
        let adjustSize: CGSize

        if(size.height > size.width){
            adjustSize = CGSize(width: size.width / size.height * maxSize, height: maxSize)
        } else {
            adjustSize = CGSize(width: maxSize, height: size.height / size.width * maxSize)
        }
        
        return adjustSize
    }
}

extension DynamicDetailViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageViews = collectionView.visibleCells
            .sorted {
                collectionView.indexPath(for: $0)!.item < collectionView.indexPath(for: $1)!.item
            }
            .compactMap {
                ($0 as? MediaViewCell)?.imageView
            }
        
        
        onImageTapped.call((self, indexPath.item, imageViews))
    }
    
}

extension DynamicDetailViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let dynamic = dynamic else { return 0 }
        
        if dynamic.type == .video {
            return 1
        }
        
        return dynamic.photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaViewCell.self)
        cell.layer.cornerRadius = 8
        
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

extension DynamicDetailViewCell: UICollectionViewDelegateFlowLayout {

    
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
        if dynamic.photoList.count == 4 {
            var adjustSectionInset =  sectionInset
            adjustSectionInset.right += itemSize().width + horizontalSpacing - 0.1
            return adjustSectionInset
        }
        return sectionInset
    }

}

