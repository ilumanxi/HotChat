//
//  TalkViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/23.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Aquaman
import Trident
import MJRefresh
import MJExtension
import RxSwift
import RxCocoa
import SVGAPlayer


class TalkViewController: AquamanPageViewController, LoadingStateType, IndicatorDisplay {
    
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
        view.backgroundColor = UIColor(hexString: "#F6F7F9")
        view.delegate = self
        return view
    }()
    
    
    var headerViewHeight: CGFloat {
        return 185
    }
    private var menuViewHeight: CGFloat = 44.0
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    private lazy var headerView: TalkHeaderView = {
        let headerView = TalkHeaderView.loadFromNib()
        headerView.onMatch.delegate(on: self) { (self, _) in
            let vc = WebViewController.H5(path: "h5/mate")
            self.navigationController?.pushViewController(vc, animated: true)
        }

        headerView.onTop.delegate(on: self) { (self, _) in
            let vc = TopController(start: .estate)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        headerView.onTask.delegate(on: self) { (self, _) in
            let vc = WebViewController.H5(path: "h5/sign")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        headerView.onVIP.delegate(on: self) { (self, _) in
            let vc = WebViewController.H5(path: "h5/vip")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        headerView.onHeadline.delegate(on: self) { (self, _) in
            let vc = HeadlineViewController()
            self.present(vc, animated: true, completion: nil)
            
        }

        headerView.onUser.delegate(on: self) { (self, userID) in
            let user = User()
            user.userId = userID
            let vc = UserInfoViewController()
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return headerView
    }()
    
    
    lazy var activityView: ActivityView = {
        
        let view = ActivityView.loadFromNib()
        view.onReceive.delegate(on: self) { (self, activity) in
            
            let vc = ActivityViewController(activity: activity)
            vc.onDone.delegate(on: self) { (self, _) in
                self.refreshActivity()
            }
            self.present(vc, animated: true, completion: nil)
        }
        return view
    }()
    
    
    var avgaAPlayer: SVGAPlayer!
    var rewardButton: UIButton!
    
    let upgradeAPI = Request<UpgradeAPI>()
    
    let userAPI = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    let matchAPI = Request<FateMatchAPI>()
    
    let discoverAPI = Request<DiscoverAPI>()
    
    let activityAPI = Request<UserActivityAPI>()
    
    let userSettingsAPI = Request<UserSettingsAPI>()
    
    let checkInAPI = Request<CheckInAPI>()
    
    var checkInResult: CheckInResult?
    
    fileprivate var channels: [Channel] = [] {
        didSet {
            newReloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserConfig.share.defaultRequest()
        
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes, for: .normal)
        
        mainScrollView.backgroundColor = UIColor(hexString: "#F6F7F9")
        
        mainScrollView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.childViewConttrollerRefreshData()
            
        }
        
        NotificationCenter.default.rx.notification(.init(TUIKitNotification_TIMMessageListener))
            .subscribe(onNext: { [weak self] notification in
                self?.handle(notification: notification)
            })
            .disposed(by: rx.disposeBag)

        refreshData()
        
        onCallEnd()
        
        let selectedIndex = tabBarController?.rx.didSelect
            .compactMap{ viewController in
                viewController.parent?.children.firstIndex(of: viewController)
            }
            .share(replay: 1)
        

        selectedIndex?
            .filter{ $0 == 0 }
            .subscribe(onNext: { [weak self] index in
                
                guard let self = self else { return }
                
                if !self.channels.isEmpty {
                    self.setSelect(index: 0, animation: false)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToTop()
                    self.scrollToTop()
                    if !(self.mainScrollView.mj_header?.isRefreshing ?? false) {
                        self.mainScrollView.mj_header?.beginRefreshing()
                    }
                   
                }
               
            })
            .disposed(by: rx.disposeBag)
        
        upgradeAPI.request(.updateChannel, type: Response<Upgrade>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                let vc = UpgrateViewController(upgrade: response.data!)
                self?.presentTopMost(vc)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func scrollToTop()  {
        mainScrollView.setContentOffset(.zero, animated: false)
        channels.forEach {channel in
            if viewController(for: channel).isViewLoaded {
                viewController(for: channel).aquamanChildScrollView().setContentOffset(.zero, animated: false)
            }
        }
    }
    
    func checkInState() {
        
        if LoginManager.shared.user!.girlStatus || AppAudit.share.signinStatus {
            self.checkInResult = nil
            return
        }
        
        checkInAPI.request(.checkUserSignInfo, type: Response<CheckInResult>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.checkInResult = response.data
                self?.presentCheckIn()
                
            }, onError: { [weak self] error in
                self?.checkInResult = nil
            })
            .disposed(by: rx.disposeBag)
    }
    
    func presentCheckIn() {
       
        let vc = CheckInViewController(day: checkInResult!.day)
        vc.onCheckInSucceed.delegate(on: self) { (self, _) in
            self.checkInState()
        }
        
        UIApplication.shared.keyWindow?.present(vc)
       
    }
    
    func onCallEnd()  {
        NotificationCenter.default.addObserver(self, selector: #selector(presentAnchorTip), name: .init("onCallEnd"), object: nil)
        
    }
    
   @objc func presentAnchorTip() {
    
        let user = LoginManager.shared.user!
    
        let isPresent = !AnchorTipViewController.notRemind() && user.sex == .female && !user.girlStatus
    
        if !isPresent {
            return
        }
    
        let vc = AnchorTipViewController()
        vc.onAnthor.delegate(on: self) { (self, _) in
            
            guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
                  let navigationController = tabBarController.selectedViewController as? UINavigationController
            else {
                return
            }
            
            let vc = AuthenticationViewController()
            navigationController.pushViewController(vc, animated: true)
            
        }
        UIApplication.shared.keyWindow?.present(vc)
    }
    
    func addActivityView(_ activity: Activity) {
        activityView.activity = activity
        view.addSubview(activityView)
        activityView.snp.makeConstraints { maker in
            maker.trailing.equalToSuperview().offset(-15)
            maker.bottom.equalTo(safeBottom).offset(-20)
            
        }
    }
    
    func removeActivityView() {
        
        if let _ = activityView.superview {
            activityView.removeFromSuperview()
        }
    }
    
    private func handle(notification: Notification) {
        
        guard let msg = notification.object as?  V2TIMMessage else { return }
        
        guard msg.elemType == .ELEM_TYPE_CUSTOM,
              let param = TUICallUtils.jsonData2Dictionary(msg.customElem.data) as? [String : Any],
              let imData = IMData.fixData(param),
              let content = imData.data.mj_JSONObject() as? [String : Any]  else {
            
            return
        }
        
        if imData.type != IMDataTypeMarqueeGift && imData.type != IMDataTypeMarqueeHeadline {
            return
        }
        
        let marquee = Marquee.mj_object(withKeyValues: content)!
        headerView.addMarquee(marquee)
    
    }
    
    func childViewConttrollerRefreshData() {
        
        guard let viewController = currentViewController as? TalkChannelViewController else { return  }
        
        viewController.onFinished.delegate(on: self) { (self, _) in
            self.mainScrollView.mj_header?.endRefreshing()
        }
        
        viewController.refreshData()
    }
    
    func newReloadData() {
        menuView.titles = channels.compactMap{ $0.tagName }
        reloadData()
    }

    func refreshData() {
        
        
        state = .loadingContent
        
        discoverAPI.request(.labelList, type: Response<[Channel]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.channels = response.data ?? []
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
        
        headlineConfig()
        
        refreshActivity()
        
        checkInState()
        
        if LoginManager.shared.user?.sex == Sex.male ||  (LoginManager.shared.user?.sex == Sex.female && !LoginManager.shared.user!.girlStatus) {
            userAPI.request(.checkUserHeadPic, type: Response<[String : Any]>.self)
                .verifyResponse()
                .subscribe(onSuccess: { [unowned self] response in
                    guard let resultCode = response.data?["resultCode"] as? Int, resultCode == 1120 else { return }
                    
                    if !AvatarTipViewController.isPresent() {
                        return
                    }
                    self.avatarTask()
                    
                   
                }, onError: nil)
                .disposed(by: rx.disposeBag)
        }
       
    }
    
    let headlineAPI = Request<HeadlineAPI>()
    func headlineConfig()  {
        
        let headlineAPI = Request<HeadlineAPI>()
        headlineAPI.request(.headlinesConfig, type: Response<[String : Any]>.self)
            .subscribe(onSuccess: { response in
                guard let energy  = response.data?["energy"] as? Int else {
                    return
                }
                HeadlineViewController.energy = energy
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func avatarTask() {
        
        userSettingsAPI.request(.taskConfig(type: 2), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                guard let energy = response.data?["energy"] as? String else { return }
                
                let vc = AvatarTipViewController(text: energy)
                vc.onAvatar.delegate(on: self) { (self, _) in
                    self.pushUser(LoginManager.shared.user!)
                }
                UIApplication.shared.keyWindow?.present(vc)
                AvatarTipViewController.cachePresent()
                
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func pushUser(_ user: User) {
        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
              let navigationController = tabBarController.selectedViewController as? UINavigationController
        else { return  }
        
        let vc = UserInfoEditingViewController.loadFromStoryboard()
        vc.user = LoginManager.shared.user
        navigationController.pushViewController(vc, animated: true)
    }
    
    func refreshActivity() {
        activityAPI.request(.checkActivityInfo, type: Response<Activity>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                if response.data!.isSuccessd {
                    self.addActivityView(response.data!)
                }
                else {
                    self.removeActivityView()
                }
               
                
            }, onError: nil)
            .disposed(by: rx.disposeBag)
        
        activityAPI.request(.receiveKeepReward, type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: {  response in
                //resultCode: 1114领取成功 1115全部领取完了 1116 注册第一天，无奖励 1117 今天领取过奖励l
                guard let resultCode = response.data?["resultCode"] as? Int,
                      let list =  response.data?["list"] as? [String],
                      resultCode == 1114 ,
                      !list.isEmpty else {
                    return
                }
                
                let vc = NewcomerAwardViewController(list: list)
                UIApplication.shared.keyWindow?.present(vc)
                
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
   private func pair(callType: CallType) {
        
        showIndicator()
        matchAPI.request(.matchGirl(callType), type: Response<[String :Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                guard let self = self else { return }
                self.hideIndicator()
                if let userId = response.data?["userId"] as? String {
                    CallHelper.share.call(userID: userId, callType:callType, callSubType: .pair)
                }
                else {
                    let vc = PairCallViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        if let _ = vc.navigationController {
                            vc.navigationController?.popViewController(animated: true)
                            self.showMessageOnWindow("亲，当前没有匹配到合适的人选，请稍后再试！")
                        }
                    }
                }
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
   @IBAction func pushSearch() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pushWallet() {
         let vc = WalletViewController()
         navigationController?.pushViewController(vc, animated: true)
     }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    let cacheviewControllers = NSCache<NSString, UIViewController>()
    
    func viewController(for channel: Channel) -> UIViewController & AquamanChildViewController {
        
        let key = channel.type.description as NSString
        
        guard let cacheViewController  = cacheviewControllers.object(forKey: key) as? UIViewController & AquamanChildViewController else  {
            
            let viewController = TalkChannelViewController(channel: channel)
            cacheviewControllers.setObject(viewController, forKey: key)
            return viewController
        }
        return cacheViewController
    }
    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return headerView
    }
    
    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        return channels.count
    }
    
    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        return viewController(for: channels[index])
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
        return 0
    }

    
    override func pageController(_ pageController: AquamanPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        
    }
    
    override func pageController(_ pageController: AquamanPageViewController, contentScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }
    
    override func pageController(_ pageController: AquamanPageViewController,
                                 contentScrollViewDidEndScroll scrollView: UIScrollView) {
        
    }
    
    override func pageController(_ pageController: AquamanPageViewController, menuView isAdsorption: Bool) {
        
        menuView.backgroundColor = isAdsorption ? .white :  UIColor(hexString: "#F6F7F9")

    }
    
    
    override func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
    }
    
    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
    }
    
    override func contentInsetFor(_ pageController: AquamanPageViewController) -> UIEdgeInsets {
        return .zero
    }
    
}

extension TalkViewController: TridentMenuViewDelegate {
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < channels.count else {
            return
        }
        setSelect(index: index, animation: false)
    }
}

