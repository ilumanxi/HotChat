//
//  DiscoverViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide
import RxSwift
import RxCocoa
import SnapKit
import Aquaman
import Trident
import FSPagerView
import URLNavigator

extension TridentMenuView {
    public override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
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


class DiscoverViewController: AquamanPageViewController, LoadingStateType, IndicatorDisplay {
    
    lazy var bannerView: FSPagerView = {
        let headerViewHeight =  (view.bounds.width / (2 / 0.75)).rounded(.down)
        let bannerView =  FSPagerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: headerViewHeight))
        bannerView.bounces = false
        bannerView.delegate = self
        bannerView.dataSource = self
//        bannerView.itemSize = FSPagerViewAutomaticSize // Fill parent
        bannerView.itemSize = bannerView.frame.insetBy(dx: 24, dy: 20).size
        bannerView.interitemSpacing = 24
        bannerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "FSPagerViewCell")
        return bannerView
    }()
    
    
    lazy var menuView: TridentMenuView = {
        let view = TridentMenuView(parts:
            .normalTextColor(UIColor(hexString: "#666666")),
            .selectedTextColor(UIColor(hexString: "#1B1B1B")),
            .normalTextFont(UIFont.systemFont(ofSize: 14.0, weight: .medium)),
            .selectedTextFont(UIFont.systemFont(ofSize: 19.0, weight: .bold)),
            .switchStyle(.line),
            .sliderStyle(
                SliderViewStyle(parts:
                    .backgroundColor(.theme),
                    .height(2.5),
                    .cornerRadius(1.5),
                    .position(.bottom),
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
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    
    var headerViewHeight: CGFloat {
        if banners.isEmpty {
            return 1
        }
        return (view.bounds.width / (2 / 0.75)).rounded(.down)
    }
    private var menuViewHeight: CGFloat = 44.0
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    let discoverAPI = Request<DiscoverAPI>()
    let chatGreetAPI = Request<ChatGreetAPI>()
    let bannerAPI = Request<BannerAPI>()
    
    var channels: [Channel] = [] {
        didSet {
            menuView.titles = channels.compactMap{ $0.tagName }
            reloadData()
        }
    }
    
    var banners: [Banner] = [] {
        didSet {
            bannerView.reloadData()
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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = menuView
        
        state = .loadingContent
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAccost()
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
        
        bannerAPI.request(.bannerList(type: 1), type: Response<[Banner]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.banners = response.data ?? []
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func loadData() -> Single<Response<[Channel]>> {
        return discoverAPI.request(.labelList).verifyResponse()
    }
    
    
    func refreshData() {
        requestData()
    }

    let cache = NSCache<NSString, UIViewController>()
    
    func viewController(at index: Int) -> UIViewController {
        
        let channel  = channels[index]
        
        guard let controller = cache.object(forKey: channel.labelId.description as NSString)  else {
            let vc = ChannelViewController.loadFromStoryboard()
            vc.channel = channel
            cache.setObject(vc, forKey: channel.labelId.description as NSString)
            return vc
        }
        
        return controller
    }
    
    override func headerViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return bannerView
    }
    
    override func headerViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: AquamanPageViewController) -> Int {
        return channels.count
    }
    
    override func pageController(_ pageController: AquamanPageViewController, viewControllerAt index: Int) -> (UIViewController & AquamanChildViewController) {
        
        return viewController(at: index) as! AquamanChildViewController
    }
    
    // 默认显示的 ViewController 的 index
    override func originIndexFor(_ pageController: AquamanPageViewController) -> Int {
       return 0
    }
    
    override func menuViewFor(_ pageController: AquamanPageViewController) -> UIView {
        return UIView()
    }
    
    override func menuViewHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return 0
    }
    
    override func menuViewPinHeightFor(_ pageController: AquamanPageViewController) -> CGFloat {
        return 0.0
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

    }
    
    
    override func pageController(_ pageController: AquamanPageViewController, willDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
    }
    
    override func pageController(_ pageController: AquamanPageViewController, didDisplay viewController: (UIViewController & AquamanChildViewController), forItemAt index: Int) {
        menuView.checkState(animation: true)
    }
    
    override func contentInsetFor(_ pageController: AquamanPageViewController) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: safeAreaInsets.bottom, right: 0)
    }
        
}

extension DiscoverViewController: TridentMenuViewDelegate {
    func menuView(_ menuView: TridentMenuView, didSelectedItemAt index: Int) {
        guard index < channels.count else {
            return
        }
        setSelect(index: index, animation: false)
    }
}


extension FSPagerViewCell {
    
    open override var isHighlighted: Bool {
        didSet {
            
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            
        }
    }
}

extension DiscoverViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return banners.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let model = banners[index]
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "FSPagerViewCell", at: index)
        cell.contentView.layer.shadowColor = UIColor.clear.cgColor
        cell.imageView?.kf.setImage(with: URL(string: model.img))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        let model = banners[index]
        guard let url = URL(string: model.url) else { return }
        
        Navigator.share.push(url)
        

    }
    
}
