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
    
    var string: String {
        switch self {
        case .text:
            return "对方设置隐私保护不接受留言"
        case .video:
            return "对方设置隐私保护不接受视频"
        case .audio:
            return "对方设置隐私保护不接受语聊"
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
        
        if checkCall(user, type: .text) {
            let info = TUIConversationCellData()
            info.userID = user.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = user.nick
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func videoButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, _) = data
        
        if checkCall(user, type: .video) {
            CallHelper.share.call(userID: user.userId, callType: .video)
        }
        
    }
    
    @IBAction func audioButtonTapped(_ sender: Any) {
        
        guard let data = onPushing.call() else { return }
        
        let (user, _) = data
        
        if checkCall(user, type: .audio) {
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
    
    func checkCall(_ toUser: User, type: CheckCallType) -> Bool {
        
        guard let data = onPushing.call() else { return  false }
        
        let (_, navigationController) = data
        
        guard let indicatorDisplay = navigationController.topViewController as? IndicatorDisplay & UIViewController else {
            return false
        }
        
        
        guard let user = LoginManager.shared.user else {
            
            return false
        }
        
        
        if user.sex == toUser.sex {
            indicatorDisplay.show(type.string)
            return false
        }
        
        if  ![user.girlStatus, toUser.girlStatus].contains(true) {
            indicatorDisplay.show(type.string)
            return false
        }
        
        return true
        
    }
    
}
