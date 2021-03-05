//
//  CommentViewCell.swift
//  Comments
//
//  Created by 风起兮 on 2021/3/3.
//

import UIKit

class CommentViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var vipButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    

    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var sexView: LabelView!
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    @IBOutlet weak var gradeView: UIImageView!
    
    let onLikeTapped = Delegate<CommentViewCell, Void>()
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        onLikeTapped.call(self)
    }

}


extension CommentViewCell {
    
    func setComment(_ comment: Comment) {
         avatarImageView.kf.setImage(with: URL(string: comment.userInfo.headPic))
         nicknameLabel.text = comment.userInfo.nick
         nicknameLabel.textColor = comment.userInfo.vipType.textColor
         sexView.setSex(comment.userInfo)
         likeButton.setTitle(comment.zanNum.description, for: .normal)
         likeButton.isSelected = comment.isSelfZan
        
         vipButton.setVIP(comment.userInfo.vipType)
         if comment.userInfo.girlStatus {
             vipButton.isHidden = true
         }
        gradeView.setGrade(comment.userInfo)
        authenticationButton.isHidden = !comment.userInfo.girlStatus
        
        let attributedString =  NSMutableAttributedString()
        if let toUser = comment.toUserInfo {
            attributedString.append(NSAttributedString(string: "回复 "))
            attributedString.append(NSAttributedString(string: toUser.nick, attributes: [NSAttributedString.Key.foregroundColor : toUser.vipType.nameTextColor]))
            attributedString.append(NSAttributedString(string: "："))
           
        }
        attributedString.append(NSAttributedString(string: comment.content))
        content.attributedText = attributedString
        dateLabel.text = comment.timeFormat
    }
}

