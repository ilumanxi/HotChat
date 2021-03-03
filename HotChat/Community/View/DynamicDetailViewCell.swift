//
//  DynamicDetailViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import MagazineLayout
import Kingfisher

class DynamicDetailViewCell: UITableViewCell {
    

    
    let layout = MagazineLayout()
    
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
        giveButton.setTitle(dynamic.giftNum.description, for: .normal)
        dateLabel.text = dynamic.timeFormat
        
        let isSelf = LoginManager.shared.user!.userId == dynamic.userInfo.userId
        
        commentButton.alpha = isSelf ? 0 : 1
        
        collectionViewHeightConstraint.constant = collectionViewHeight()
        
        
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    
    let sectionInset = UIEdgeInsets(top: 15, left: 16, bottom: 1, right: 16)
    
    let horizontalSpacing: CGFloat = 10
    
    let verticalSpacing: CGFloat = 10
    
    let itemsPerRow: CGFloat = 3
    
//    private var itemSize: CGSize {
//        let itemSize = (UIScreen.main.bounds.width - (sectionInset.left + sectionInset.right) - (itemsPerRow - 1) * horizontalSpacing) / itemsPerRow
//        return CGSize(width: itemSize, height: itemSize)
//    }

    func collectionViewHeight() -> CGFloat {
        
        let itemsCount = max(dynamic.photoList.count, 1)
                
        if itemsCount == 1 { // 缩放
            
        }
        else if itemsCount == 4 { // 两列
            
        }
        else {
            
        }
        
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

 
// MARK: UICollectionViewDelegateMagazineLayout

extension DynamicDetailViewCell: UICollectionViewDelegateMagazineLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeModeForItemAt indexPath: IndexPath)
    -> MagazineLayoutItemSizeMode
  {
    
    let count = max(dynamic.photoList.count, 1)
    
    if count == 1 {
        let size = itemSize()
        let percentage =  (UIScreen.main.bounds.width - sectionInset.left - sectionInset.right) / size.width 
        return MagazineLayoutItemSizeMode(widthMode: .fractionalWidth(divisor: UInt(percentage)), heightMode: .static(height: size.height))
    }
    else if count == 4 {
        
        return MagazineLayoutItemSizeMode(widthMode: .halfWidth, heightMode: .static(height: itemSize().height))
    }
    
    return MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .static(height: itemSize().height))
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForHeaderInSectionAtIndex index: Int)
    -> MagazineLayoutHeaderVisibilityMode
  {
    return .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForFooterInSectionAtIndex index: Int)
    -> MagazineLayoutFooterVisibilityMode
  {
    return .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    visibilityModeForBackgroundInSectionAtIndex index: Int)
    -> MagazineLayoutBackgroundVisibilityMode
  {
    return .hidden
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    horizontalSpacingForItemsInSectionAtIndex index: Int)
    -> CGFloat
  {
    return horizontalSpacing
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    verticalSpacingForElementsInSectionAtIndex index: Int)
    -> CGFloat
  {
    return verticalSpacing
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    
    if dynamic.photoList.count == 4 {
        var adjustSectionInset =  sectionInset
        adjustSectionInset.right += itemSize().width + horizontalSpacing
        return adjustSectionInset
    }
    
    return sectionInset
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetsForItemsInSectionAtIndex index: Int)
    -> UIEdgeInsets
  {
    return .zero
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    finalLayoutAttributesForRemovedItemAt indexPath: IndexPath,
    byModifying finalLayoutAttributes: UICollectionViewLayoutAttributes)
  {
    // Fade and drop out
    finalLayoutAttributes.alpha = 0
    finalLayoutAttributes.transform = .init(scaleX: 0.2, y: 0.2)
  }

}

