//
//  PassthroughViewController.swift
//  PassthroughView
//
//  Created by 风起兮 on 2021/4/20.
//

import UIKit
import RxSwift
import RxCocoa
import HandyJSON

class PassthroughView: UIView {
    
    var shouldPassthrough = true
    
    var passthroughViews: [UIView] = []
    
    
     override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
         for subview in subviews {
             if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                 return true
             }
         }
         return false
     }
    
     override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
         let view = super.hitTest(point, with: event)
         if view == self {
             return nil //avoid delivering touch events to the container view (self)
         } else {
             return view //the subviews will still receive touch events
         }
     }
 }

//{type:"10003",data:"{userId:234,sex:1，nick:2,headPic:"",content:"123",region:"广州"}"}

struct GiftNotification: HandyJSON {
    
    var userId: String = ""
    var sex: Sex = .empty
    var nick: String = ""
    var headPic: String = ""
    var region: String = ""
    var content: String = ""
}



struct OnlineNotification: HandyJSON {
    
    var userId: String = ""
    var nick: String = ""
    var headPic: String = ""
    var content: String = ""
}


class NoticeViewController: UIViewController {
    
    
    var passthroughView = PassthroughView()
    
    
    var giftTipContainerView = UIView()
    
    var onlineStatusTipContainerView = UIView()
    
    /// vertical
    fileprivate var giftNotifications: [GiftNotification] = []
    
    
    /// horizontal
    fileprivate var onlineNotifications: [OnlineNotification] = []
    
    /// 普通
    
    
    fileprivate var isGiftFinished = true
    
    fileprivate var isOnlineFinished = true
    
    
    override func loadView() {
        view = passthroughView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.rx.notification(.init(TUIKitNotification_TIMMessageListener))
            .subscribe(onNext: { [weak self] notification in
                self?.handle(notification: notification)
            })
            .disposed(by: rx.disposeBag)
        
        addSubviewEvent(giftTipContainerView)
        addSubviewEvent(onlineStatusTipContainerView)
        
    }
    
    private func handle(notification: Notification) {
        
        guard let msg = notification.object as?  V2TIMMessage else { return }
        
        guard msg.elemType == .ELEM_TYPE_CUSTOM,
              let param = TUICallUtils.jsonData2Dictionary(msg.customElem.data) as? [String : Any],
              let imData = IMData.fixData(param),
              let json = imData.data.mj_JSONObject() as? [String : Any]  else {
            
            return
        }
        
        if imData.type != IMDataTypePresent && imData.type != IMDataTypeOnline {
            return
        }
        
        if imData.type == IMDataTypePresent, let gift = GiftNotification.deserialize(from: json)  {
            add(gift: gift)
        }
   
        if imData.type == IMDataTypeOnline, let online = OnlineNotification.deserialize(from: json)  {
            add(online: online)
        }
    }
    
    func add(online notification: OnlineNotification) {
        onlineNotifications.append(notification)
        addNextOnlineView()
    }
    
    func add(gift notification: GiftNotification) {
        giftNotifications.append(notification)
        addNextGiftView()
    }
    
    func addSubviewEvent(_ view: UIView)  {
        let add =  view.rx.methodInvoked(#selector(UIView.didAddSubview)).map { _ in view.subviews }
        let remove = view.rx.methodInvoked(#selector(UIView.willRemoveSubview))
            .delay(.milliseconds(100), scheduler: MainScheduler.instance)
            .map { _ in view.subviews }
        
        Observable<[UIView]>.merge(add, remove)
            .startWith(view.subviews)
            .map{ !$0.isEmpty}
            .bind(to: view.rx.isUserInteractionEnabled)
            .disposed(by: rx.disposeBag)
    }
    
    
    func setupUI()  {
        giftTipContainerView.clipsToBounds = true
        giftTipContainerView.layer.cornerRadius = 10
        view.addSubview(giftTipContainerView)
        
        giftTipContainerView.snp.makeConstraints { [unowned self] maker in
            maker.top.equalToSuperview()
            maker.leading.equalTo(self.view.snp.leading).offset(20)
            maker.trailing.equalTo(self.view.snp.trailing).offset(-20)
            maker.height.equalTo(190)
        }
        
        onlineStatusTipContainerView.clipsToBounds = true
        onlineStatusTipContainerView.layer.cornerRadius = 22
        view.addSubview(onlineStatusTipContainerView)
        onlineStatusTipContainerView.snp.makeConstraints { [unowned self] maker in
            maker.bottom.equalToSuperview()
            maker.leading.equalTo(self.view.snp.leading).offset(20)
            maker.size.equalTo(CGSize(width: 165, height: 44))
        }
    }
    
    
    func addNextOnlineView() {
        if !isOnlineFinished || onlineNotifications.isEmpty {
            return
        }
        
        let online = onlineNotifications.removeFirst()
        addOnlineView(online: online)
        addOnlineAnimation()
    }
    
    func addOnlineView(online: OnlineNotification) {
        
        isOnlineFinished = false
        
        let frame = self.onlineStatusTipContainerView.bounds
        
        let onlineFrame: CGRect
        
        if self.onlineStatusTipContainerView.subviews.isEmpty {
            onlineFrame = frame.offsetBy(dx:-frame.width, dy: 0)
        }
        else {
            onlineFrame = frame.offsetBy(dx:0, dy: frame.height)
        }
        
        
        let onlineView = OnlineTipView.loadFromNib()
        onlineView.frame = onlineFrame
        onlineView.onContentTapped.delegate(on: self) { (self, _) in
            let vc = OnlineStatusViewController()
            self.presentPanModal(vc)
        }
        
        
        onlineStatusTipContainerView.addSubview(onlineView)
        
        Observable<Int>.countdown(5)
            .subscribe(onCompleted: { [weak self] in
                
                self?.isOnlineFinished = true
                self?.onlineCompleted()
            })
            .disposed(by: onlineView.rx.disposeBag)
        
    }
    

    
    func addOnlineAnimation() {
        
        if self.onlineStatusTipContainerView.subviews.isEmpty || self.onlineStatusTipContainerView.subviews.count == 1 {
            UIView.animate(withDuration: 0.25) { // 左到右
                for view in self.onlineStatusTipContainerView.subviews {
                    view.frame =  self.onlineStatusTipContainerView.bounds
                }
                
            } completion: { _ in
                for view in self.onlineStatusTipContainerView.subviews {
                    if view.frame.minY < 0 {
                        view.removeFromSuperview()
                    }
                }
            }
            
        }
        else { //下到上
            UIView.animate(withDuration: 0.25) {
                for view in self.onlineStatusTipContainerView.subviews {
                    var frame = view.frame
                    frame = CGRect(x: 0, y: frame.minY - self.onlineStatusTipContainerView.frame.height , width: frame.width, height: frame.height)
                    view.frame = frame
                }
                
            } completion: { _ in
                for view in self.onlineStatusTipContainerView.subviews {
                    if view.frame.minY < 0 {
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    func onlineCompleted() {
        if isOnlineFinished  && !self.onlineNotifications.isEmpty {
            addNextOnlineView()
        }
        else {
            self.onlineStatusTipContainerView.subviews.forEach {
                $0.removeFromSuperview()
            }
        }
    }
    
    
    func addNextGiftView() {
        
        if !isGiftFinished || giftNotifications.isEmpty {
            return
        }
        
        let gift = giftNotifications.removeFirst()
        addGiftView(gift: gift)
        addGiftAnimation()
        
    }
    
    
    
    @objc func giftCompleted() {
       
        if isGiftFinished {
            addNextGiftView()
        }
    }
    
    func addGiftView(gift: GiftNotification) {
        
        isGiftFinished = false
        
        let frame = self.giftTipContainerView.bounds
        
        let giftView = GiftTipView.loadFromNib()
        giftView.frame = frame.offsetBy(dx: 0, dy: -frame.height)
        
        giftView.onChatTapped.delegate(on: self) {(self, _) in
            let info = TUIConversationCellData()
            info.userID = gift.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = gift.nick
            guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
                  let navigationController = tabBarController.selectedViewController as? UINavigationController
            else {
                return
            }
            navigationController.pushViewController(vc, animated: true)
        }
        giftView.onCloseTapped.delegate(on: self) { (self, _) in
            self.giftTipContainerView.subviews.forEach { $0.removeFromSuperview() }
            self.isGiftFinished = true
            self.giftCompleted()
        }
        
        giftTipContainerView.addSubview(giftView)
        
        Observable<Int>.countdown(7)
            .subscribe(onCompleted: { [weak self] in
                giftView.removeFromSuperview()
                self?.isGiftFinished = true
                self?.giftCompleted()
            })
            .disposed(by: giftView.rx.disposeBag)
    }
    
    func addGiftAnimation() {
        
        UIView.animate(withDuration: 0.25) {
            for view in self.giftTipContainerView.subviews {
                var frame = view.frame
                frame.origin.y += self.giftTipContainerView.bounds.height
                view.frame = frame
            }
            
        } completion: { _ in
            for view in self.giftTipContainerView.subviews {
                
                if view.frame.maxY > self.giftTipContainerView.frame.height {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
}
