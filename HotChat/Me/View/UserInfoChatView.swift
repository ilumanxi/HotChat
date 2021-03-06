//
//  UserInfoChatView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

enum CheckCallType {
    case text
    case video
    case audio
    case image
    
    var string: String {
        switch self {
        case .text:
            return "留言"
        case .video:
            return "视频"
        case .audio:
            return "语聊"
        case .image:
            return "图片留言"
        }
    }
}



class UserInfoChatView: UIView {
    
    enum State {
        case `default`
        case sayHellow
        case notSayHellow
    }
    
    let onPushing = Delegate<(), (User, UINavigationController)>()
    let onSayHellowed = Delegate<Void, Void>()
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var sayHellowButton: UIButton!
    
    var state: State = .default {
        didSet{
            changeState()
        }
    }
    
    func changeState()  {
        
        switch state {
        case .default:
            stackView.isHidden = false
            sayHellowButton.isHidden = true
            
        case .sayHellow:
            stackView.isHidden = true
            sayHellowButton.isHidden = false
            sayHellowButton.isEnabled = true
            sayHellowButton.setImage(UIImage(named: "say-hello"), for: .normal)
            sayHellowButton.setTitle("和ta打招呼", for: .normal)
            sayHellowButton.backgroundColor = UIColor(hexString: "#FF608F")
        case .notSayHellow:
            stackView.isHidden = true
            sayHellowButton.isHidden = false
            sayHellowButton.isEnabled = false
            sayHellowButton.setImage(nil, for: .normal)
            sayHellowButton.setTitle("已打过招呼，TA回复后即可畅聊", for: .normal)
            sayHellowButton.setTitleColor(.white, for: .normal)
            sayHellowButton.backgroundColor = UIColor(hexString: "#C7C7C7")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeState()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        isHidden = AppAudit.share.imcallStatus
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, navigationController) = data
        
        guard let indicatorDisplay = navigationController.topViewController as? IndicatorDisplay & UIViewController else {
            return
        }
        
        if CallHelper.share.checkCall(user, type: .text, indicatorDisplay: indicatorDisplay) {
            let info = TUIConversationCellData()
            info.userID = user.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = user.nick
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, navigationController) = data
        
        guard let indicatorDisplay = navigationController.topViewController as? IndicatorDisplay & UIViewController else {
            return
        }
        
        if CallHelper.share.checkCall(user, type: .video, indicatorDisplay: indicatorDisplay) {
            CallHelper.share.call(userID: user.userId, callType: .video)
        }
        
    }
    
    @IBAction func audioButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, navigationController) = data
        
        guard let indicatorDisplay = navigationController.topViewController as? IndicatorDisplay & UIViewController else {
            return
        }
        
        if CallHelper.share.checkCall(user, type: .audio, indicatorDisplay: indicatorDisplay) {
            CallHelper.share.call(userID: user.userId, callType: .audio)
        }
        
        
    }
    
    
    @IBAction func sayHelloButtonTapped(_ sender: Any) {
        guard let data = onPushing.call() else { return }
        
        let (user, navigationController) = data
        
        let vc = SayHellowViewController()
        vc.onAddButtonDidTapped.delegate(on: self) { (self, _) in
            let settingVC = SayHellowSettingViewController()
            navigationController.pushViewController(settingVC, animated: true)
        }
        vc.onSayHellowButtonDidTapped.delegate(on: self) { (self, message) in
            let data = TUITextMessageCellData(direction: .MsgDirectionOutgoing)
            data.content = message
            GiftManager.shared().sendGiftMessage(data, userID: user.userId)
            self.onSayHellowed.call()
        }
        navigationController.present(vc, animated: true, completion: nil)
        
    }
    
}
