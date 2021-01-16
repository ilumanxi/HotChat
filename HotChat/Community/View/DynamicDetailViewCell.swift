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
    
    let sectionInset = UIEdgeInsets(top: 15, left: 16, bottom: 1, right: 16)
    
    let horizontalSpacing: CGFloat = 10
    
    let verticalSpacing: CGFloat = 10
    
    let itemsPerRow: CGFloat = 3
    
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
        collectionViewHeightConstraint.constant = collectionViewHeight(for: CGFloat(dynamic.photoList.count))
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private var itemSize: CGSize {
        let itemSize = (UIScreen.main.bounds.width - (sectionInset.left + sectionInset.right) - (itemsPerRow - 1) * horizontalSpacing) / itemsPerRow
        return CGSize(width: itemSize, height: itemSize)
    }

    func collectionViewHeight(for itemsCount: CGFloat) -> CGFloat {
        
        let rows = (itemsCount / itemsPerRow).rounded(.up)
        
        let height = sectionInset.top + sectionInset.bottom +  itemSize.height * rows + (rows - 1) * verticalSpacing
        
        return height
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
        return dynamic?.photoList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = dynamic.photoList[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaViewCell.self)
        cell.layer.cornerRadius = 8
        cell.imageView.kf.setImage(with: URL(string: data.picUrl))
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
    return MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .static(height: itemSize.height))
//    return MagazineLayoutItemSizeMode(widthMode: .thirdWidth, heightMode: .dynamic)
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

