//
//  UserInfoViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Aquaman
import Trident
import HBDNavigationBar
import RxCocoa
import RxSwift
import NSObject_Rx
import SnapKit

class UserInfoViewController: AquamanPageViewController, LoadingStateType, IndicatorDisplay {
    
    lazy var menuView: TridentMenuView = {
        let view = TridentMenuView(parts:
            .normalTextColor(UIColor(hexString: "#999999")),
            .selectedTextColor(UIColor(hexString: "#333333")),
            .normalTextFont(UIFont.systemFont(ofSize: 16.0, weight: .medium)),
            .selectedTextFont(UIFont.systemFont(ofSize: 17.0, weight: .bold)),
            .switchStyle(.line),
            .sliderStyle(
                SliderViewStyle(parts:
                    .backgroundColor(UIColor(hexString: "#FF3F3F")),
                    .height(3),
                    .cornerRadius(1.5),
                    .position(.bottom),
//                    .extraWidth(24),
                    .shape(.line)
                )
            ),
            .bottomLineStyle(
                BottomLineViewStyle(parts:
                    .hidden(true)
                )
            )
        )
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.backgroundColor = .white
        view.delegate = self
        return view
    }()
    
    
    var headerViewHeight: CGFloat {
        
        return 110.0 + view.bounds.width
    }
    private var menuViewHeight: CGFloat = 44.0
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    var user: User! {
        didSet {
            userInfoHeaderView.user = user
            information.user = user
            dynamic.user = user
        }
    }
    
    override var backBarButtonImage: UIImage? {
        
        return UIImage(named: "circle-back-white")
    }
    
    
    let information = InformationViewController.loadFromStoryboard()
    
    let dynamic = DynamicDetailViewController.loadFromStoryboard()
    
    let addressBook = AddressBookViewController()
    
    lazy var viewControllers: [UIViewController] =  {
        information.title = "资料"
        information.user = user
        dynamic.title = "动态"
        dynamic.user = user
        addressBook.title = "联系方式"
        return [
            information,
            dynamic,
            addressBook
        ]
    }()
    
    private lazy var userInfoHeaderView: UserInfoHeaderView = {
        let headerView = UserInfoHeaderView.loadFromNib()
        headerView.onFollowButtonTapped.delegate(on: self) { (self, sender) in
            
            self.dynamicAPI.request(.follow(self.user.userId), type: ResponseEmpty.self)
                .verifyResponse()
                .subscribe(onSuccess: { response in
                    
                    var user = self.user
                    user?.isFollow = true
                    self.user = user
                    self.show(response.msg)
                }, onError: { error in
                    
                    self.show(error)
                })
                .disposed(by: self.rx.disposeBag)
        }
        
        headerView.onVipAction.delegate(on: self) { (self, _) in
            self.presentVipPhoto()
        }
        return headerView
    }()
    
    let userAPI = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    lazy var textChat: UIButton = {
        let textChat = self.button(text: "聊天", image: UIImage(named: "me-chat-text"))
        textChat.addTarget(self, action: #selector(textChatSignal), for: .touchUpInside)
        return textChat
    }()
    
    lazy var voiceChat: UIButton = {
        let voiceChat = self.button(text: "通话", image: UIImage(named: "me-chat-audio"))
        voiceChat.addTarget(self, action: #selector(voiceChatSignal), for: .touchUpInside)
        return voiceChat
    }()
    
    lazy var videoChat: UIButton = {
        let videoChat = button(text: "视频", image: UIImage(named: "me-chat-video"))
        videoChat.addTarget(self, action: #selector(videoChatSignal), for: .touchUpInside)
        return videoChat
    }()
    
    
    lazy var love: UIButton = {
        let love = button(text: "关注", image: UIImage(named: "me-love"))
        love.addTarget(self, action: #selector(follow), for: .touchUpInside)
        return love
    }()
    
   
    lazy var gift: UIButton = {
        let gift = button(text: "礼物", image: UIImage(named: "me-gift"))
        gift.addTarget(self, action: #selector(giftButtonTapped), for: .touchUpInside)
        return gift
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        mainScrollView.contentInsetAdjustmentBehavior = .never
        updateNavigationBarStyle(mainScrollView)
        navigationItem.title = user.nick
        menuView.titles = viewControllers.compactMap{ $0.title }
        
        reloadData()
        
        NotificationCenter.default.rx.notification(.userDidChange)
            .subscribe(onNext: { [unowned self] _ in
                self.userInfoHeaderView.user = self.user
            })
            .disposed(by: rx.disposeBag)
        
        refreshData()
    }
    
    func button(text: String, image: UIImage?) -> UIButton {
        let button = QMUIButton(type: .custom)
        button.imagePosition = .top
        button.spacingBetweenImageAndTitle = 2
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
        button.setTitle(text, for: .normal)
        button.setImage(image, for: .normal)
        return button
    }
    
    func setupUI() {
        
        if user.userId == LoginManager.shared.user!.userId {
            return
        }
        
        followState()
        
        let stackView = UIStackView(arrangedSubviews: [textChat, voiceChat, videoChat, love, gift])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { [unowned self] maker in
            maker.leading.equalToSuperview().offset(28)
            maker.trailing.equalToSuperview().offset(-28)
            maker.bottom.equalTo(self.safeBottom)
        }
        
        stackView.arrangedSubviews.forEach { subView in
            subView.snp.makeConstraints { maker in
                maker.size.equalTo(CGSize(width: 64, height: 64))
            }
            subView.layer.cornerRadius = 32
            subView.backgroundColor = .white
        }
    }
    
    func followState() {
        love.isHidden = user.isFollow
        gift.isHidden = !user.isFollow
    }
    
    @objc func textChatSignal() {
        
        if CallHelper.share.checkCall(user, type: .text, indicatorDisplay: self) {
            let info = TUIConversationCellData()
            info.userID = user.userId
            let vc  = ChatViewController(conversation: info)!
            vc.title = user.nick
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func voiceChatSignal() {
        CallHelper.share.call(userID: user.userId, callType: .audio)
    }
    
    @objc func videoChatSignal() {
        CallHelper.share.call(userID: user.userId, callType: .video)
    }
    
    func presentVipPhoto() {
        let vc = VipPhotoViewController()
        vc.onVIP.delegate(on: self) { (self, _) in
            self.pushVip()
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func follow(_ sender: UIButton) {
        
        self.dynamicAPI.request(.follow(self.user.userId), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                let user = self.user
                user?.isFollow = true
                self.user = user
                self.followState()
                self.show(response.msg)
            }, onError: { error in
                
                self.show(error)
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    @objc func giftButtonTapped(_ sender: UIButton) {
        let vc = GiftViewController()
        vc.hbd_barHidden = true
        vc.hbd_barAlpha = 0
        vc.delegate = self
        
        let navController = BaseNavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .coverVertical
        navController.navigationBar.isHidden = true
        self.present(navController, animated: true) {
            navController.navigationBar.isHidden = false
        }
    }
    
    func pushVip() {
        let vc = WebViewController.H5(path: "h5/vip")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupNavigationItem() {
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: backBarButtonImage, style: .plain, target: self, action: #selector(pop)), animated: true)
        
        if user.userId == LoginManager.shared.user!.userId {
            let more = UIBarButtonItem(image: UIImage(named: "circle-edit-white"), style: .plain, target: self, action: #selector(editItemTapped))
            self.navigationItem.rightBarButtonItems = [more]
        }
        else {
            let more = UIBarButtonItem(image: UIImage(named: "circle-more-white"), style: .plain, target: self, action: #selector(moreItemTapped))
            self.navigationItem.rightBarButtonItems = [more]
        }
    }
    
    @objc func editItemTapped() {
        let vc  = UserInfoEditingViewController.loadFromStoryboard()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func moreItemTapped() {
        let vc  = UserSettingViewController.loadFromStoryboard()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshData() {
        state = .refreshingContent
        userAPI.request(.userinfo(userId: user.userId),type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data
                self?.setupNavigationItem()
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewState()
    }
    
    private let chatViewHeight: CGFloat = 48
    
    private var chatView: UserInfoChatView!
    
    private var sendButton: GradientButton!
    
    let API = Request<ChatGreetAPI>()
    
    func chatViewState() {
        if LoginManager.shared.user!.girlStatus {
            API.request(.checkGreet(toUserId: user.userId), type: Response<[String : Any]>.self)
                .verifyResponse()
                .subscribe(onSuccess: { [weak self] response in

                    guard let resultCode = response.data?["resultCode"] as? Int else { return }
                    
                    if resultCode == 1005 {
                        self?.chatView?.state = .sayHellow
                    }
                    else if resultCode == 1006 {
                        self?.chatView?.state = .default
                    }
                    else if resultCode == 1007 {
                        self?.chatView?.state = .notSayHellow
                    }
                    
                }, onError: nil)
                .disposed(by: rx.disposeBag)
        }
    }
    
    

    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        if LoginManager.shared.user!.realNameStatus.isPresent {
            self.presentDynamic()
        }
        else {
            self.checkUserAttestation()
        }
    }
    
    func presentDynamic() {
        let vc = DynamicViewController()
        vc.onSened.delegate(on: self) { (self, _) in
            
            if let navigationController =  self.children.first as? UINavigationController,
               let controller = navigationController.viewControllers.first as? IndicatorDisplay {
                controller.refreshData()
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    let authenticationAPI = Request<AuthenticationAPI>()
    
    func checkUserAttestation() {
        showIndicator()
        authenticationAPI.request(.checkUserAttestation, type: Response<Authentication>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.hideIndicator()
                if response.data!.realNameStatus.isPresent {
                    let user = LoginManager.shared.user!
                    user.realNameStatus = response.data!.realNameStatus
                    LoginManager.shared.update(user: user)
                    self.presentDynamic()
                }
                else {
                    let vc = AuthenticationGuideViewController()
                    vc.onPushing.delegate(on: self) { (self, _) -> UINavigationController? in
                        return self.navigationController
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    private func updateNavigationBarStyle(_ scrollView: UIScrollView) {
       
        var alpha = max(min(scrollView.contentOffset.y / headerViewHeight, 1), 0)
        
        if alpha.isNaN {
            alpha = 0
        }
        
        if alpha < 0.5 {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "circle-back-white")
            if user.userId == LoginManager.shared.user!.userId {
                navigationItem.rightBarButtonItem?.image = UIImage(named: "circle-edit-white")
            }
            else {
                navigationItem.rightBarButtonItem?.image = UIImage(named: "circle-more-white")
            }
        }
        else {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "navigation-bar-back")
            
            if user.userId == LoginManager.shared.user!.userId {
                navigationItem.rightBarButtonItem?.image = UIImage(named: "edit-gray")
            }
            else {
                navigationItem.rightBarButtonItem?.image =  UIImage(named: "more-gray")
            }
        }
        
        let color = UIColor.textBlack.withAlphaComponent(alpha)

        hbd_barAlpha = Float(alpha)
//        hbd_barTintColor = UIColor.white.withAlphaComponent(alpha)
        hbd_titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : color]
        hbd_setNeedsUpdateNavigationBar()
    }
    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return userInfoHeaderView
    }
    
    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        return viewControllers.count
    }
    
    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        let viewController = viewControllers[index] as! AquamanChildViewController
       
        if user.userId != LoginManager.shared.user!.userId {
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
        }
        else {
            viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: UIApplication.shared.keyWindow!.safeAreaInsets.bottom, right: 0)
        }
        
        return viewController
    }
    
    // 默认显示的 ViewController 的 index
    override func originIndexFor(_ pageController: AquamanPageViewController) -> Int {
       return 0
    }
    
    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return menuView
    }
    
    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return menuViewHeight
    }
    
    override func menuViewPinHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return (UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0))
    }

    
    override func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        updateNavigationBarStyle(scrollView)
    }
    
    override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }
    
    override func pageController(_ pageController: AquamanPageViewController,
                                 contentScrollViewDidEndScroll scrollView: UIScrollView) {
        
    }
    
    override func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {

    }
    
    
    override func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
    }
    
    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
    }
    
    override func contentInsetFor(_ pageController: AquamanPageViewController) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: -(UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0)),
            left: 0,
            bottom: 0,
            right: 0
        )
    }
    
}

extension UserInfoViewController: TridentMenuViewDelegate {
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < viewControllers.count else {
            return
        }
        setSelect(index: index, animation: false)
    }
}



extension UserInfoViewController: GiftViewControllerDelegate {
    
    func giftViewController(_ giftController: GiftViewController, didSelect gift: Gift) {
        
        GiftManager.shared().giveGift(user.userId, type: 2, dynamicId: nil, gift: gift) { (responseObject, error) in
            if let error = error {
                self.show(error)
                return
            }
            let giveGift = GiveGift.mj_object(withKeyValues: responseObject?["data"])!
            
            if giveGift.resultCode == 1 {
                
                let  user  = LoginManager.shared.user!
                user.userEnergy = giveGift.userEnergy
                LoginManager.shared.update(user: user)
                
                let cellData = GiftCellData(direction: .MsgDirectionOutgoing)
                cellData.gift = gift
                let imData = IMData.default()
                imData.data = gift.mj_JSONString()
                imData.giftRequestId = giveGift.giftRequestId
                let data = TUICallUtils.dictionary2JsonData(imData.mj_keyValues() as! [AnyHashable : Any])
                cellData.innerMessage = V2TIMManager.sharedInstance()!.createCustomMessage(data)
                GiftManager.shared().sendGiftMessage(cellData, userID: user.userId)
                giftController.dismiss(animated: true, completion: nil)
                
                self.show("送礼成功")
            }
            else if (giveGift.resultCode == 3) { //能量不足，需要充值
                giftController.dismiss(animated: true) {
                    
                    let alertController = UIAlertController(title: nil, message: "您的能量不足、请充值！", preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "立即充值", style: .default, handler: { _ in
                        let vc = WalletViewController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                  
                }
                
            }
            else {
                
                self.show(giveGift.msg)
            }
            
        }
    }

    
}

