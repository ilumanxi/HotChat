//
//  ChatViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SPAlertController

class ChatViewController: TUIChatController {
    
    var conversationData: TUIConversationCellData!
    override init!(conversation conversationData: TUIConversationCellData!) {
        self.conversationData = conversationData
        super.init(conversation: conversationData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var video: TUIInputMoreCellData = {
        let data = TUIInputMoreCellData()
        data.image = UIImage(named: "video")
        data.title = "视频聊天"
        
        return data
    }()
    
    lazy var audio: TUIInputMoreCellData = {
        let data = TUIInputMoreCellData()
        data.image = UIImage(named: "audio")
        data.title = "语音聊天"
        
        return data
    }()
    
    lazy var camera: TUIInputMoreCellData = {
        let data = TUIInputMoreCellData.photo!
        data.image = UIImage(named: "camera")
        return data
    }()
    
    lazy var photos: TUIInputMoreCellData = {
        let data = TUIInputMoreCellData.picture!
        data.image = UIImage(named: "photos")
        return data
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        self.delegate = self
        

        self.moreMenus = [video, audio, camera, photos]
    }
    
    
    func setupNavigationItem() {
        
        let setting = UIBarButtonItem(image: UIImage(named: "chat-setting"), style: .plain, target: self, action: #selector(userSetting))
        
        let call = UIBarButtonItem(image: UIImage(named: "chat-call"), style: .plain, target: self, action: #selector(chatCall))
        
        navigationItem.rightBarButtonItems = [setting, call]
        
    }
    
    
    @objc func userSetting() {
        var user = User()
        user.userId = conversationData.userID
        
        let vc = UserSettingViewController.loadFromStoryboard()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func chatCall() {
        chatCallAlert()
    }
    
    private func chatCallAlert() {
        
        let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
 
        
        let video = SPAlertAction(title: nil, style: .default) { _ in
            CallManager.shareInstance()?.call(nil, userID: self.conversationData.userID, callType: .video)
        }
        video.attributedTitle = attributedText(text: "视频聊", detailText: "(2500能量/分钟)")
        alertController.addAction(video)
        
        let audio = SPAlertAction(title: nil, style: .default) { _ in
            CallManager.shareInstance()?.call(nil, userID: self.conversationData.userID, callType: .audio)
        }
        audio.attributedTitle = attributedText(text: "语音聊", detailText: "(2500能量/分钟)")
        alertController.addAction(audio)
        
        alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
 
    }
    
    func attributedText(text: String, detailText: String) -> NSAttributedString {
        
        let string = "\(text)\(detailText)" as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes([.foregroundColor: UIColor.textBlack, .font : UIFont.systemFont(ofSize: 14)], range: string.range(of: text))
        attributedString.addAttributes([.foregroundColor: UIColor.textBlack, .font : UIFont.systemFont(ofSize: 12)], range: string.range(of: detailText))
        return attributedString
    }
    

}

extension ChatViewController: TUIChatControllerDelegate {
    
    
    func chatController(_ controller: TUIChatController!, didSendMessage msgCellData: TUIMessageCellData!) {

    }
    
    func chatController(_ controller: TUIChatController!, onNewMessage msg: V2TIMMessage!) -> TUIMessageCellData! {
        return nil
    }
    
    func chatController(_ controller: TUIChatController!, onShowMessageData cellData: TUIMessageCellData!) -> TUIMessageCell! {
        return nil
    }
    
    func chatController(_ chatController: TUIChatController!, onSelect cell: TUIInputMoreCell!) {
        if cell.data.title == video.title {
            CallManager.shareInstance()?.call(self.conversationData.groupID, userID: self.conversationData.userID, callType: .video)
        }
        else if cell.data.title == audio.title {
            CallManager.shareInstance()?.call(self.conversationData.groupID, userID: self.conversationData.userID, callType: .audio)
        }
    }
    
    func chatController(_ controller: TUIChatController!, onSelectMessageAvatar cell: TUIMessageCell!) {
        
    }
    
    func chatController(_ controller: TUIChatController!, onSelectMessageContent cell: TUIMessageCell!) {
        

    }
    
    
    
}
