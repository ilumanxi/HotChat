//
//  DatingDetailViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/15.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class DatingDetailViewController: UIViewController {
    
    
    @IBOutlet weak var backgrounImageView: UIImageView!
    
    @IBOutlet weak var bigAvatarImageView: UIImageView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var priceButton: UIButton!
    
    
    @IBOutlet weak var datingButton: GradientButton!
    
    var dynamic: Dynamic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarAlpha = 0
        
        let backItem = UIBarButtonItem(image: UIImage(named: "circle-back-white"), style: .done, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backItem

        // Do any additional setup after loading the view.
        
        let user = dynamic.userInfo!
        
        backgrounImageView.kf.setImage(with: URL(string: user.headPic))
        bigAvatarImageView.kf.setImage(with: URL(string: user.headPic))
        avatarImageView.kf.setImage(with: URL(string: user.headPic))
        nameLabel.text = user.nick
        infoLabel.text = "\(user.age)岁 \(user.region)"
        priceButton.setTitle("\(user.videoCharge)能量/分钟", for: .normal)
        priceButton.isHidden =  AppAudit.share.energyStatus
        
        if AppAudit.share.energyStatus {
            datingButton.setTitle("开始聊天", for: .normal)
        }
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func datingButtonTapped(_ sender: Any) {
        
        let user = dynamic.userInfo!
        if AppAudit.share.energyStatus {
            let data = TUIConversationCellData()
            data.userID = user.userId

            let vc =  ChatViewController(conversation: data)!
            vc.title = user.nick
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            CallHelper.share.call(userID: user.userId, callType: .video)
        
        }
    }
    

}
