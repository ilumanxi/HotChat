//
//  ChatViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SPAlertController
import MJExtension
import AVFoundation
import RxCocoa
import RxSwift
import GKPhotoBrowser
import HandyJSON

extension IMData: HandyJSON {
    
    @objc
    class func fixData(_ json: [String : Any]) -> IMData? {
        
        guard let model = IMData.mj_object(withKeyValues: json) else { return nil }
        
        guard let userValue = json["user"] as? [String : Any], let user = User.deserialize(from: userValue) else { return model }
        
        model.user = user
        
        return model
    }
    
    @objc func fixJson() -> NSDictionary {
        let dict = self.mj_keyValues()!
        
        if dict["user"] != nil {
            dict["user"] =  self.user.toJSON()
        }
        return dict
    }
    
}

class ChatViewController: ChatController, IndicatorDisplay {
    
    let imAPI = Request<IMAPI>()
    
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
    
    
    lazy var sayhHellow: TUIInputMoreCellData = {
        let data = TUIInputMoreCellData()
        data.title = "常用语"
        data.image = UIImage(named: "sayhellow")
        return data
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()
        
        self.delegate = self
        

        self.moreMenus = [video, audio, camera, photos, sayhHellow]
        
        observerUserWallet()
    }
    
    
    func setupNavigationItem() {
        
        let setting = UIBarButtonItem(image: UIImage(named: "chat-setting"), style: .plain, target: self, action: #selector(pushUserSetting))
        var items = [setting]
        
        if !AppAudit.share.imcallStatus {
            let call = UIBarButtonItem(image: UIImage(named: "chat-call"), style: .plain, target: self, action: #selector(chatCall))
            items.append(call)
        }
        
        navigationItem.rightBarButtonItems = items
    }
        
    func observerUserWallet() {
        
        updateUserWallet
            .flatMapLatest{[unowned self] in self.userWallet() }
            .subscribe(onNext: { response in
                let user = LoginManager.shared.user!
                user.userTanbi = response.data!.userTanbi
                user.userEnergy = response.data!.userEnergy
                LoginManager.shared.update(user: user)
            })
            .disposed(by: rx.disposeBag)
    }
    @objc func pushUserSetting() {
        userSetting(userId: conversationData.userID)
    }
    
    @objc func userSetting(userId: String) {
        let user = User()
        user.userId = userId
        
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
            CallHelper.share.call(userID: self.conversationData.userID, callType: .video)
        }
        video.attributedTitle = attributedText(text: "视频聊", detailText: "(2500能量/分钟)")
        alertController.addAction(video)
        
        let audio = SPAlertAction(title: nil, style: .default) { _ in
            CallHelper.share.call(userID: self.conversationData.userID, callType: .audio)
        }
        audio.attributedTitle = attributedText(text: "语音聊", detailText: "(1000能量/分钟)")
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
    
    
    let userAPI = Request<UserAPI>()
    
    let updateUserWallet = PublishSubject<Void>()

}

extension ChatViewController: ChatControllerDelegate {
    
    
    func chatController(_ controller: ChatController!, didSendMessage msgCellData: TUIMessageCellData!) {

        updateUserWallet.onNext(())
    }
    
    
    func userWallet() -> Single<Response<Wallet>>  {
       return userAPI.request(.userWallet, type: Response<Wallet>.self)
            .verifyResponse()
           
    }
    
    func chatController(_ controller: ChatController!, onNewMessage msg: V2TIMMessage!) -> TUIMessageCellData! {
        
        
        
        if msg.elemType == .ELEM_TYPE_CUSTOM , let param = TUICallUtils.jsonData2Dictionary(msg.customElem.data) as? [String : Any], let imData = IMData.fixData(param) {
            
            if imData.type == IMDataTypeGift { // 礼物

                let cellData = GiftCellData(direction: msg.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming)
                cellData.innerMessage = msg;
                cellData.name = msg.nickName
                cellData.msgID = msg.msgID
                cellData.avatarUrl = URL(string: msg.faceURL ?? "")
                cellData.identifier = msg.sender
                cellData.gift = Gift.mj_object(withKeyValues: imData.data)
                cellData.showName = true
                return cellData
            }
            else if imData.type == IMDataTypeImage { // 图片
                //ImageMessageCellData
                let cellData = ImageMessageCellData(direction: msg.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming)
                cellData.innerMessage = msg
                cellData.msgID = msg.msgID
                cellData.name = msg.nickName
                cellData.avatarUrl = URL(string: msg.faceURL ?? "")
                cellData.showName = true
                cellData.mj_setKeyValues(imData.data)
                cellData.identifier = msg.sender
                return cellData
                
            }
            else if imData.type == IMDataTypeText, let content = imData.data.mj_JSONObject() as? [String : Any]  { // 自定义文本消息

                let cellData = TextMessageCellData(direction: msg.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming)
                cellData.user = imData.user;
                cellData.content = (content["text"] as? String) ?? ""
                cellData.innerMessage = msg
                cellData.msgID = msg.msgID
                cellData.name = msg.nickName
                cellData.showName = !msg.isSelf
                cellData.avatarUrl = URL(string: msg.faceURL ?? "")
                cellData.mj_setKeyValues(imData.data)
                cellData.identifier = msg.sender

                return cellData
            }
        }
        
        
        return nil
    }
    
    func chatController(_ controller: ChatController!, onShowMessageData cellData: TUIMessageCellData!) -> TUIMessageCell! {
        
        if cellData.isKind(of: GiftCellData.self) {
            
            let cell = GiftCell(style: .default, reuseIdentifier: "GiftCell")
            cell.fill(with: cellData)
            return cell
        }
        
       else if cellData.isKind(of: ImageMessageCellData.self) {
            let cell = ImageMessageCell(style: .default, reuseIdentifier: "ImageMessageCell")
            cell.fill(with: cellData as! ImageMessageCellData)
            return cell
        }
        
       else if let data = cellData as? TextMessageCellData {
            let cell = TextMessageCell(style: .default, reuseIdentifier: "TextMessageCell")
            cell.fill(with: data)
            return cell
        }
        
        
        return nil
    }
    
    func chatController(_ chatController: ChatController!, onSelect cell: TUIInputMoreCell!) {
        if cell.data.title == video.title {
            CallHelper.share.call(userID: conversationData.userID, callType: .video)
        }
        else if cell.data.title == audio.title {
            CallHelper.share.call(userID: conversationData.userID, callType: .audio)
        }
    }
    
    func chatController(_ controller: ChatController!, onSelectMessageAvatar cell: TUIMessageCell!) {
        userSetting(userId: cell.messageData.identifier)
    }
    
    func chatController(_ controller: ChatController!, onSelectMessageContent cell: TUIMessageCell!) {
        
        if let imageMessageCell = cell as? ImageMessageCell  {
           
            let photo = GKPhoto()
            photo.url = URL(string: imageMessageCell.imageData.url)!
            photo.sourceImageView = imageMessageCell.thumb
            
            let browser = GKPhotoBrowser(photos: [photo], currentIndex: 0)
            browser.showStyle = .zoom
            browser.hideStyle = .zoomScale
            browser.loadStyle = .indeterminateMask
            browser.maxZoomScale = 20
            browser.doubleZoomScale = 2
            browser.isFollowSystemRotation = true
            browser.show(fromVC: self)
        }

    }
    
}
