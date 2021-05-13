//
//  IntimateTopCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class IntimateTopCell: UITableViewCell {

    
    @IBOutlet weak var rankLabel: UILabel!
    
    @IBOutlet weak var leftAvatarView: UIButton!
    @IBOutlet weak var rightAvatarView: UIButton!
    
    @IBOutlet weak var topNameLabel: UILabel!
    
    @IBOutlet weak var bottomNameLabel: UILabel!
    
    @IBOutlet weak var intimateButton: UIButton!
    
    let onNavigation = Delegate<Void, UINavigationController>()
    
    fileprivate var model: IntimacyTop!
    
    func set(_ model: IntimacyTop) {
        self.model = model
        
        rankLabel.text = model.rankId.description
        
        leftAvatarView.kf.setImage(with: URL(string: model.userInfo.headPic), for: .normal)
        rightAvatarView.kf.setImage(with: URL(string: model.girlInfo.headPic), for: .normal)
        topNameLabel.text = model.userInfo.nick
        bottomNameLabel.text = model.girlInfo.nick
        
        let formatter = NumberFormatter()
        let string = formatter.string(from: NSNumber(value: model.userIntimacy))!
        let text = "亲密度\(string)℃"
        intimateButton.setTitle(text, for: .normal)
        intimateButton.isHidden = AppAudit.share.rankingListStatus
    }
    
    @IBAction func leftAvatarTapped(_ sender: Any) {
        pushUser(model.userInfo)
    }
    
    @IBAction func rightAvatarTapped(_ sender: Any) {
        pushUser(model.girlInfo)
    }
    
    func pushUser(_ user: User) {
        
        if AppAudit.share.rankingListStatus {
            return
        }
        
        guard let navigationController = onNavigation.call() else { return }
        let vc = UserInfoViewController()
        vc.user = user
        navigationController.pushViewController(vc, animated: true)
    }
}
