//
//  UserViewswift
//  HotChat
//
//  Created by 风起兮 on 2021/4/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class UserInfoViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    
    @IBOutlet weak var sexButton: SexButton!
    
    
    
    @IBOutlet weak var gradeView: UIImageView!
    
    @IBOutlet weak var timeFormaLabel: UILabel!
    
    func set(_ model: DynamicInfo)  {
        let user = model.userInfo!
        
        avatarImageView.kf.setImage(with: URL(string: user.headPic))
        nicknameLabel.text = user.nick
        sexButton.set(user)
        timeFormaLabel.text = model.timeFormat
        gradeView.setGrade(user)
    }
    
}
