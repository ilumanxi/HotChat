//
//  DiscoverViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Trident
import Tabman
import Pageboy


extension TridentMenuView {
    
    static var TridentMenuViewLayoutSize = "TridentMenuViewLayoutSize"
    
    var layoutSize: CGSize {
        get {
            guard let size = objc_getAssociatedObject(self, &TridentMenuView.TridentMenuViewLayoutSize) as? CGSize else {
                return  UIView.layoutFittingExpandedSize
            }
            return size
        }
        set {
            objc_setAssociatedObject(self, &TridentMenuView.TridentMenuViewLayoutSize, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    public override var intrinsicContentSize: CGSize {
        return layoutSize
    }
}

extension TimeInterval {
    
    func toDownClock() -> String {
        if isNaN {
            return "00:00:00"
        }
        var Min = Int(self / 60)
        let Sec = Int(self.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min >= 60 {
            Hour = Int(Min / 60)
            Min = Min - Hour*60
            return String(format: "%02d:%02d:%02d", Hour, Min, Sec)
        }
        return String(format: "00:%02d:%02d", Min, Sec)
    }
}


class DiscoverViewController: TabmanViewController, LoadingStateType, IndicatorDisplay {
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    let discoverAPI = Request<DiscoverAPI>()
    let chatGreetAPI = Request<ChatGreetAPI>()
    
    
    var channels: [Channel] = [] {
        didSet {
            reloadData()
        }
    }
    
    private var sayHellowSeconds: TimeInterval = 0
    
    private var countdownTimer: Timer?
    
    let sayHellowButton: UIButton = {
        let button = UIButton(type: .custom)
        let text = "一键打招呼"
        button.setTitle(text, for: .normal)
        button.setImage(#imageLiteral(resourceName: "say-hello"), for: .normal)
        button.setImage(UIImage(named: "say-hello-gray"), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.contentHorizontalAlignment = .leading
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(userCallChat), for: .touchUpInside)
        let image = UIImage.gradientImage(
            bounds: CGRect(x: 0, y: 0, width: 110, height: 34),
            colors: [
                UIColor(hexString: "#FE5788").cgColor,
                UIColor(hexString: "#FB7099").cgColor
            ])
        
        button.setBackgroundImage(image, for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor(hexString: "#DCDCDC"), size: CGSize(width: 110, height: 34)), for: .disabled)
        return button
    }()
    
    fileprivate lazy var badgeView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor(hexString: "#FF413E")
        view.layer.cornerRadius = 5
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        
        // Create a bar
        let bar = TMBarView.ButtonBar()
        
        // Customize bar properties including layout and other styling.
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 12, bottom: 4.0, right: 12)
        bar.layout.interButtonSpacing = 24.0
        bar.indicator.weight = .custom(value: 2.5)
        bar.indicator.cornerStyle = .eliptical
        bar.indicator.overscrollBehavior = .none
        bar.layout.showSeparators = false
        bar.fadesContentEdges = true
        bar.spacing = 30.0
        bar.backgroundView.style = .clear
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor(hexString: "#666666")
            $0.font = .systemFont(ofSize: 17, weight: .medium)
            $0.selectedTintColor = UIColor(hexString: "#333333")
            $0.selectedFont = .systemFont(ofSize: 20, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")
        
        // Add bar to the view - as a .systemBar() to add UIKit style system background views.
//        addBar(bar.systemBar(), dataSource: self, at: .top)
        
        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .navigationItem(item: navigationItem))
        
        
        if let noticeView = notificationItem.value(forKeyPath: "view") as? UIView {
            
            noticeView.addSubview(badgeView)
            badgeView.snp.makeConstraints { maker in
                maker.top.equalToSuperview().offset(5)
                maker.trailing.equalToSuperview().offset(-8)
                maker.size.equalTo(CGSize(width: 10, height: 10))
            }
                        
        }
        
        NotificationCenter.default.rx.notification(.init(TUIKitNotification_TIMMessageListener))
            .subscribe(onNext: { [weak self] notification in
                self?.handle(notification: notification)
            })
            .disposed(by: rx.disposeBag)
        
        
//        requestData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAccost()
    }
    
    @objc private func pushSearch() {
        let vc = SearchViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func pushTop() {
        let vc = TopController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupViews() {
        
        if LoginManager.shared.user!.girlStatus && !AppAudit.share.energyStatus {

            checkUserCallChat()
        }
        else {
            sayHellowButton.removeFromSuperview()
        }
    }
    
    private var isCheckAccost = true
    
    func checkAccost() {
        
        if LoginManager.shared.user!.girlStatus  || !isCheckAccost  || AppAudit.share.accostStatus  {
            return
        }
        
        chatGreetAPI.request(.checkAccost, type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                if let resultCode = response.data?["resultCode"] as? Int, resultCode == 1005 {
                    self.presentAccost()
                }
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func presentAccost()  {
        let vc = AccostViewController()
        present(vc, animated: true) {
            self.isCheckAccost = false
        }
    }
    
    
    func addSayHellowButton() {
        
        if sayHellowSeconds <= 0 {
            sayHellowButton.isEnabled = true
        }
        else {
            sayHellowButton.isEnabled = false
            sayHellowButton.setTitle(sayHellowSeconds.toDownClock(), for: .disabled)
        }
        
        
        view.addSubview(sayHellowButton)
        sayHellowButton.snp.makeConstraints { maker in
            maker.size.equalTo(CGSize(width: 110, height: 34))
            maker.trailingMargin.equalToSuperview()
            maker.bottom.equalTo(view.safeBottom).offset(-34)
        }
    }
    
    func countdown() {
        
        countdownTimer?.invalidate()
        countdownTimer = nil
       
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.sayHellowSeconds -= 1
            
            if self.sayHellowSeconds <= 0 {
                self.sayHellowSeconds = 0
                self.sayHellowButton.isEnabled = true
                self.countdownTimer?.invalidate()
                self.countdownTimer = nil
            }
            else {
                self.sayHellowButton.isEnabled = false
                self.sayHellowButton.setTitle(self.sayHellowSeconds.toDownClock(), for: .disabled)
            }
        }
        countdownTimer?.fire()
    }
    
    func checkUserCallChat() {
        chatGreetAPI.request(.checkUserCallChat, type: Response<ChatGreetResult>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                if response.data!.isSuccessd {
                    self?.sayHellowSeconds = 0
                    self?.sayHellowButton.isEnabled = true
                }
                else {
                    self?.sayHellowSeconds =  response.data!.endTime - Date().timeIntervalSince1970
                    self?.countdown()
                }
                self?.addSayHellowButton()
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
   @objc func userCallChat() {
        sayHellowButton.isUserInteractionEnabled = false
        chatGreetAPI.request(.userCallChat, type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.sayHellowButton.isUserInteractionEnabled = true
                if let endTime = response.data?["endTime"] as? TimeInterval {
                    self?.sayHellowSeconds =  endTime - Date().timeIntervalSince1970
                    self?.countdown()
                }
                self?.show((response.data?["resultMsg"] as? String) ?? "打招呼成功")
            }, onError: { [weak self] error in
                self?.sayHellowButton.isUserInteractionEnabled = true
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func requestData() {
        state = .refreshingContent
        loadData()
            .subscribe(onSuccess: { [unowned self] response in
                self.channels = response.data ?? []
                self.state = self.channels.isEmpty ? .noContent : .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    func loadData() -> Single<Response<[Channel]>> {
        return discoverAPI.request(.labelList).verifyResponse()
    }
    
    
    func refreshData() {
        requestData()
    }

    
    lazy var viewConrollers: [UIViewController] = {
        
        let community = CommunityViewController()
        community.title = "广场"
        
        let follow = RelationViewController()
        follow.title = "关注"
        
        return [community, follow]
    }()
    
    
    private func handle(notification: Notification) {
        
        guard let msg = notification.object as?  V2TIMMessage else { return }
        
        guard msg.elemType == .ELEM_TYPE_CUSTOM,
              let param = TUICallUtils.jsonData2Dictionary(msg.customElem.data) as? [String : Any],
              let imData = IMData.fixData(param) else {
            return
        }
        
        if imData.type != IMDataTypeDynamic{
            return
        }
        
        badgeView.isHidden = false
    }
    

    @IBOutlet weak var notificationItem: UIBarButtonItem!
    
    @IBAction func notificationButtonTapped(_ sender: Any) {
        badgeView.isHidden = true
        let vc = NotificationViewController()
        navigationController?.pushViewController(vc, animated: true)
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
    
//    let cache = NSCache<NSString, UIViewController>()
//
//    func viewController(at index: Int) -> UIViewController {
//
//        let channel  = channels[index]
//
//        guard let controller = cache.object(forKey: channel.labelId.description as NSString)  else {
//            let vc = ChannelViewController()
//            vc.channel = channel
//            cache.setObject(vc, forKey: channel.labelId.description as NSString)
//            return vc
//        }
//
//        return controller
//    }
//
}



extension DiscoverViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewConrollers.count // How many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        // View controller to display at a specific index for the page view controller.
        viewConrollers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        nil // Default page to display in the page view controller (nil equals default/first index).
    }
    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: viewConrollers[index].title!) // Item to display for a specific index in the bar.
    }
}



