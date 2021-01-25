//
//  MeHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/26.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setGrade(_ user: User) {
        if user.girlStatus {
            kf.setImage(with: URL(string: user.girlRankIcon))
        }
        else {
            kf.setImage(with: URL(string: user.userRankIcon))
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 28).isActive = true
        heightAnchor.constraint(equalToConstant: 12).isActive = true
    }
}

class MeHeaderView: UIView {
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var sexView: LabelView!
    
    @IBOutlet weak var gradeView: UIImageView!
    
    @IBOutlet weak var vipButton: UIButton!
    
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var fansButton: UIButton!
    
    @IBOutlet weak var taskView: UIStackView!
    
    @IBOutlet weak var walletView: UIStackView!
    
    @IBOutlet weak var earningsView: UIStackView!
    
    @IBOutlet weak var vipView: UIStackView!
    
    @IBOutlet weak var inviteView: UIStackView!
    
    
    @IBOutlet var backgroundViewHeightConstraint: NSLayoutConstraint!
    


    override func awakeFromNib() {
                
        if let superview = superview {
            widthAnchor.constraint(equalTo: superview.widthAnchor).isActive = true
        }
        
        layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        
        // 可以根据 srollview offset 改变高度
        backgroundViewHeightConstraint.constant = UIScreen.main.bounds.height
        
        super.awakeFromNib()
    }
    
}
