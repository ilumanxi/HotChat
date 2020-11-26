//
//  UserInfoChatView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class UserInfoChatView: UIView {

    let onPushing = Delegate<(), (User, UINavigationController)>()
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var sayHellowButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()

    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if LoginManager.shared.user!.girlStatus {
            stackView.isHidden = true
            sayHellowButton.isHidden = false
        }
        else {
            stackView.isHidden = false
            sayHellowButton.isHidden = true
        }
        
        isHidden = !LoginManager.shared.currentVersionApproved
    }
    
    var user: User!
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, navigationController) = data
        
        let info = TUIConversationCellData()
        info.userID = user.userId
        let vc  = ChatViewController(conversation: info)!
        vc.title = user.nick
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, _) = data
        
        CallHelper.share.call(userID: user.userId, callType: .video)
    }
    
    @IBAction func audioButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, _) = data
        
        CallHelper.share.call(userID: user.userId, callType: .audio)
    }
    
    
    @IBAction func sayHelloButtonTapped(_ sender: Any) {
        guard let data = onPushing.call() else { return }
        
        let (user, navigationController) = data
        
        let info = TUIConversationCellData()
        info.userID = user.userId
        let vc  = ChatViewController(conversation: info)!
        vc.title = user.nick
        navigationController.pushViewController(vc, animated: true)
    }
    
}
