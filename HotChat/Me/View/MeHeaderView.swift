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
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var sexButton: SexButton!
    
    @IBOutlet weak var gradeView: UIImageView!
    
    @IBOutlet weak var vipButton: UIButton!
    
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var fansButton: UIButton!
    
    @IBOutlet weak var userIDLabel: UILabel!
    
    @IBOutlet weak var earningButton: UIButton!
    
    @IBOutlet weak var energyLabel: UILabel!
    
    @IBOutlet weak var coinLabel: UILabel!
    
    override func awakeFromNib() {
                
        if let superview = superview {
            widthAnchor.constraint(equalTo: superview.widthAnchor).isActive = true
        }  
        
        super.awakeFromNib()
    }
    
}
