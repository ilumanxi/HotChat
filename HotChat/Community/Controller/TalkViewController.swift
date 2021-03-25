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
        
        return 231
    }
    private var menuViewHeight: CGFloat = 44.0
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    var talkTop: TalkTop? {
        didSet {
            headerView.talkTop = talkTop
        }
    }
    
    private lazy var headerView: TalkHeaderView = {
        let headerView = TalkHeaderView.loadFromNib()
        headerView.onVideo.delegate(on: self) { (self, _) in
            self.pair(callType: .video)
        }
        headerView.onVoice.delegate(on: self) { (self, _) in
            self.pair(callType: .audio)
        }
        headerView.onHeadline.delegate(on: self) { (self, _) in
            
        }
        headerView.onTop.delegate(on: self) { (self, top) in
            let vc = TopController(start: top.type)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return headerView
    }()
    
    let userAPI = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    let matchAPI = Request<FateMatchAPI>()
    
    let discoverAPI = Request<DiscoverAPI>()
    
    let topAPI = Request<TopAPI>()
    
    fileprivate var channels: [Channel] = [] {
        didSet {
            newReloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(UINavigationBar.appearance().titleTextAttributes, for: .normal)
        
        mainScrollView.backgroundColor = UIColor(hexString: "#F6F7F9")
        
        mainScrollView.mj_header = MJRefreshNormalHeader { [weak self] in
            self?.childViewConttrollerRefreshData()
            
        }
                
        refreshData()
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
        
        topAPI.request(.vitalityList(type: 0), type: Response<TalkTop>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.talkTop = response.data
                
            }, onError: { [weak self] error in
                
            })
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if let _ = vc.navigationController {
                            vc.navigationController?.popViewController(animated: true)
                            self.showMessageOnWindow("你与她擦肩而过...")
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

