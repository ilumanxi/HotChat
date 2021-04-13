//
//  NoteViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/12.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Kingfisher

class NoteViewCell: UITableViewCell {
    
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var lastTimeLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var likeButton: HotChatButton!
    
    @IBOutlet weak var giveButton: HotChatButton!
    
    
    @IBOutlet weak var commentButton: HotChatButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var accostButton: HotChatButton!
    
    @IBOutlet weak var chatButton: HotChatButton!
    
    
    @IBOutlet weak var timelineView: UIView!
    
    
    let onAvatarTapped = Delegate<NoteViewCell, Void>()
    
    let onLikeTapped = Delegate<NoteViewCell, Void>()
    
    let onGiveTapped = Delegate<NoteViewCell, Void>()
    
    let onCommentTapped = Delegate<NoteViewCell, Void>()
    
    let onImageTapped = Delegate<(NoteViewCell, Int, [UIImageView]), Void>()
    
    let onMoreButtonTapped = Delegate<NoteViewCell, Void>()
    
    let onAccostButtonTapped = Delegate<NoteViewCell, Void>()
    
    let onChatButtonTapped = Delegate<NoteViewCell, Void>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "MediaViewCell", bundle: nil), forCellWithReuseIdentifier: "MediaViewCell")
    }
    
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
    
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        onChatButtonTapped.call(self)
    }
    
    
    @IBAction func accostButtonTapped(_ sender: Any) {
        onAccostButtonTapped.call(self)
    }
    
    var dynamic: Dynamic! {
        didSet {
            reloadData()
        }
    }
    
    func reloadData() {
        
        
        yearLabel.text = dynamic.year
        yearLabel.isHidden = dynamic.year.isEmpty
        
        monthLabel.text = dynamic.date2
        monthLabel.isHidden = dynamic.date2.isEmpty
        
        lastTimeLabel.text = dynamic.date1
        lastTimeLabel.isHidden = dynamic.date1.isEmpty

        contentLabel.text = dynamic.content
        likeButton.setTitle(dynamic.zanNum.description, for: .normal)
        likeButton.isSelected = dynamic.isSelfZan
        if dynamic.commentCount > 0 {
            commentButton.setTitle(dynamic.commentCount.description, for: .normal)
        }
        else {
            commentButton.setTitle("评论", for: .normal)
        }
        
        
//        giveButton.setTitle(dynamic.giftNum.description, for: .normal)
        accostButton.isHidden = dynamic.isGreet
        chatButton.isHidden = !dynamic.isGreet
        
        collectionViewHeightConstraint.constant = collectionViewHeight()
        
        
        setNeedsLayout()
        layoutIfNeeded()
        collectionView.reloadData()
    }
    
    let maxSize: CGFloat = UIScreen.main.bounds.width - 20 * 2 - 46 - 12 - 10 * 2
    
    let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
    
    let horizontalSpacing: CGFloat = 4
    
    let verticalSpacing: CGFloat = 4
    
    var itemsPerRow: CGFloat {
   
        let itemsCount = max(dynamic.photoList.count, 1)
   
        if itemsCount > 2 {
            return 3
        }
        else if itemsCount == 2 {
            return 2
        }
        
        return 1
    }
    

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

extension NoteViewCell: UICollectionViewDelegate {
    
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

extension NoteViewCell: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let dynamic = dynamic else { return 0 }
        
        if dynamic.type == .video {
            return 1
        }
        
        return dynamic.photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: MediaViewCell.self)
        cell.layer.cornerRadius = 5
        
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

extension NoteViewCell: UICollectionViewDelegateFlowLayout {

    
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

