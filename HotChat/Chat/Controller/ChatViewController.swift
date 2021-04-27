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
            var userDict = self.user.toJSON()
            userDict?["girlStatus"] = self.user.girlStatus ? 1 : 0
            dict["user"] =  userDict
        }
        return dict
    }
    
}

class ChatViewController: ChatController, IndicatorDisplay, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let imAPI = Request<IMAPI>()
    
    let chatGreetAPI = Request<ChatGreetAPI>()
    
    var conversationData: TUIConversationCellData!
    override init!(conversation conversationData: TUIConversationCellData!) {
        self.conversationData = conversationData
        super.init(conversation: conversationData)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var isAdmin: Bool {
        return conversationData.userID == "10001"
    }
    
    override var inputBarHeight: CGFloat {
        if isAdmin {
            return 0
        }
       
        return super.inputBarHeight
    }
    
    var user: User? {
        didSet {
            userView.set(user!)
            setUserView()
            if !isAdmin && user!.userIntimacy > 4 {
                titleView.set(user!)
                navigationItem.titleView = titleView
            }
        }
    }
    
    lazy var userView: ChatUserView = {
        let view = ChatUserView.loadFromNib()
        view.onFollowTapped.delegate(on: self) { (self, _) in
            self.follow(self.user!)
        }
        view.onAvatarTapped.delegate(on: self) { (self, _) in
            let user = User()
            user.userId = self.conversationData.userID
            let vc = UserInfoViewController()
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return view
    }()
    
    let hiddenIntimacySignal = PublishSubject<Void>()
    
    lazy var intimacyController: IntimacyViewController = {
        let vc = IntimacyViewController(userID: self.conversationData.userID)
        vc.onStorage.delegate(on: self) { (self, _) in
            self.removeIntimacy(animated: true)
        }
        return vc
    }()
    
    lazy var titleView: IntimacyTitleView = {
        let view = IntimacyTitleView.loadFromNib()
        view.addTarget(self, action: #selector(titleViewDidTapped), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupNavigationItem()
        
        self.delegate = self
        
        requestUser()
        
        observerUserWallet()
        
        setUserView()
        
        imChatStatus()
        
        hiddenIntimacy()
    }
    
    func hiddenIntimacy()  {
        if isAdmin {
            return
        }
        let hiddenSignal =  inputController.view.rx.observe(CGRect.self, #keyPath(UIView.frame), options: .new, retainSelf: false)
         .map{ _ in ()}
         
         Observable.merge(hiddenIntimacySignal,  hiddenSignal)
             .debounce(.microseconds(500), scheduler: MainScheduler.instance)
             .subscribe(onNext: {  [unowned self] _ in
                 if self.intimacyController.parent != nil || self.intimacyController.view.superview != nil {
                     removeIntimacy(animated: true)
                 }
             })
             .disposed(by: rx.disposeBag)
    }
    
    @objc func titleViewDidTapped() {
        
        if intimacyController.parent != nil || intimacyController.view.superview != nil {
           return
        }
        else {
            self.inputController.reset()
            addIntimacy(animated: true)
        }
        
    }
    
    func addIntimacy(animated: Bool) {
        addChild(intimacyController)
       
        let safeAreaInsets = view.safeAreaInsets
        let finalFrame =  view.bounds.inset(by: UIEdgeInsets(top: safeAreaInsets.top, left: safeAreaInsets.left, bottom: safeAreaInsets.bottom + inputBarHeight, right: safeAreaInsets.right))
        let initializeFrame = finalFrame.offsetBy(dx: 0, dy: -finalFrame.height)
        
        intimacyController.view.frame = initializeFrame
        view.addSubview(intimacyController.view)
        UIView.animate(withDuration: 0.25) {
            self.intimacyController.view.frame = finalFrame
        }
        intimacyController.didMove(toParent: self)
    }
    
    func removeIntimacy(animated: Bool){
        intimacyController.removeFromParent()
       
        let safeAreaInsets = view.safeAreaInsets
        let finalFrame =  view.bounds.inset(by: UIEdgeInsets(top: safeAreaInsets.top, left: safeAreaInsets.left, bottom: safeAreaInsets.bottom + inputBarHeight, right: safeAreaInsets.right))
        let initializeFrame = finalFrame.offsetBy(dx: 0, dy: -finalFrame.height)
        UIView.animate(withDuration: 0.25) {
            self.intimacyController.view.frame = initializeFrame
        } completion: { _ in
            self.intimacyController.view.removeFromSuperview()
            self.intimacyController.didMove(toParent: nil)
        }

        
    }
    
    private func setUserView() {
        if self.user == nil || isAdmin {
            return
        }
        
        userView.fittingSize()
        if  messageController.tableView.contentSize.height + userView.frame.height <  messageController.tableView.frame.height {
            /// 影响到消息滚动底部
            messageController.tableView.tableHeaderView = userView
        }
    }
    
    func setupNavigationItem() {
        
        if isAdmin {
            return
        }
        
        let setting = UIBarButtonItem(image: UIImage(named: "chat-setting"), style: .plain, target: self, action: #selector(pushUserSetting))
        var items = [setting]
        
        if !AppAudit.share.imcallStatus {
            let call = UIBarButtonItem(image: UIImage(named: "chat-call"), style: .plain, target: self, action: #selector(chatCall))
            items.append(call)
        }
        
        navigationItem.rightBarButtonItems = items
    }
    
    
    func imChatStatus()  {
        if isAdmin {
            return
        }
        
        imAPI.request(.imChatStatus(toUserId: self.conversationData.userID), type: Response<[String : Any]>.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func requestUser()  {
        if self.conversationData.userID.isEmpty || isAdmin {
            return
        }
        userAPI.request(.userinfo(userId: self.conversationData.userID), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data
            }, onError: { error in
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    let dynamicAPI = Request<DynamicAPI>()
    
    func follow(_ user: User) {
        self.dynamicAPI.request(.follow(user.userId), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                let user = self.user
                user?.isFollow = true
                self.user = user
                self.show("关注成功")
            }, onError: { error in
                self.show(error)
            })
            .disposed(by: self.rx.disposeBag)
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
 
        
        let video = SPAlertAction(title: "视频聊", style: .default) { _ in
            CallHelper.share.call(userID: self.conversationData.userID, callType: .video)
        }
        alertController.addAction(video)
        
        let audio = SPAlertAction(title: "语音聊", style: .default) { _ in
            CallHelper.share.call(userID: self.conversationData.userID, callType: .audio)
        }
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
        
    override func inputControllerDidSayHello(_ inputController: InputController!) {
        
        hiddenIntimacySignal.onNext(())
        
        chatGreetAPI.request(.sayHelloInfo, type: Response<[String : Any]>.self)
            .subscribe(onSuccess: { [weak self] response in
                if let content = response.data?["content"] as? String, !content.isEmpty {
                    let textData = TUITextMessageCellData(direction: .MsgDirectionOutgoing)
                    textData.content = content
                    self?.messageController.sendMessage(textData)
                }
                
            }, onError: { [weak self] error in
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func inputControllerDidAudio(_ inputController: InputController!) {
        hiddenIntimacySignal.onNext(())
        self.inputController.reset()
        CallHelper.share.call(userID: self.conversationData.userID, callType: .audio)
    }
    override func inputControllerDidVideo(_ inputController: InputController!) {
        hiddenIntimacySignal.onNext(())
        self.inputController.reset()
        CallHelper.share.call(userID: self.conversationData.userID, callType: .video)
    }
    
    override func inputControllerDidPhoto(_ inputController: InputController!) {
        hiddenIntimacySignal.onNext(())
        if let user = self.user {
            if CallHelper.share.checkCall(user, type: .image, indicatorDisplay: self) {
                let vc = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                vc.addAction(SPAlertAction(title: "拍照", style: .default, handler: { [weak self] _ in
                    self?.takePictureForSend()
                }))
                
                vc.addAction(SPAlertAction(title: "相册选择", style: .default, handler: { [weak self] _ in
                    self?.selectPhotoForSend()
                }))
                
                vc.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
                
                present(vc, animated: true, completion: nil)
            }
            
        }
        else {
            requestUser()
        }
      
    }

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
                cellData.name = msg.nickName ?? msg.sender
                cellData.msgID = msg.msgID
                cellData.avatarUrl = URL(string: msg.faceURL ?? "")
                cellData.identifier = msg.sender
                cellData.gift = Gift.mj_object(withKeyValues: imData.data)
                cellData.showName = false
                return cellData
            }
            else if imData.type == IMDataTypeImage { // 图片
                //ImageMessageCellData
                let cellData = ImageMessageCellData(direction: msg.isSelf ? .MsgDirectionOutgoing : .MsgDirectionIncoming)
                cellData.innerMessage = msg
                cellData.msgID = msg.msgID
                cellData.name = msg.nickName
                cellData.avatarUrl = URL(string: msg.faceURL ?? "")
                cellData.showName = false
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
            else if let content = imData.data.mj_JSONObject() as? [String : Any] {
                
                print("\(imData.type): \(content.debugDescription)")
            }
        }
        
        
        return nil
    }
    
    func chatController(_ controller: ChatController!, onShowMessageData cellData: TUIMessageCellData!) -> TUIMessageCell! {
        
        if let data = cellData as? GiftCellData {
            let cell = GiftCell(style: .default, reuseIdentifier: "GiftCell")
            cell.fill(with: data)
            return cell
        }
        
       else if let data = cellData as? ImageMessageCellData {
            let cell = ImageMessageCell(style: .default, reuseIdentifier: "ImageMessageCell")
            cell.fill(with: data)
            return cell
        }
        
       else if let data = cellData as? TextMessageCellData {
            let cell = TextMessageCell(style: .default, reuseIdentifier: "TextMessageCell")
            cell.fill(with: data)
            return cell
        }
       else if let data = cellData as? SystemMessageCellData {
            let cell = SystemMessageCell(style: .default, reuseIdentifier: "SystemMessageCell")
            cell.fill(with: data)
            return cell
        }
        return nil
    }
    
    func chatController(_ chatController: ChatController!, onSelect cell: TUIInputMoreCell!) {
      
       
    }
    
    func chatController(_ controller: ChatController!, onSelectMessageAvatar cell: TUIMessageCell!) {
        if !isAdmin {
            let user = User()
            user.userId = cell.messageData.identifier
            let vc = UserInfoViewController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
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
