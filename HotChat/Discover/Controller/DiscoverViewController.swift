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


class DiscoverViewController: SegementSlideDefaultViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial
    
    let discoverAPI = Request<DiscoverAPI>()
    
    var channels: [Channel] = [] {
        didSet {
            reloadData()
        }
    }
    
    
    let cache = NSCache<NSString, UIViewController>()

    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSelectedIndex = 0
//        reloadData()

        state = .loadingContent
        requestData()
        
    }
    
    func requestData() {
        loadData()
            .subscribe(onSuccess: { [weak self] response in
                self?.channels = response.data ?? []
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func loadData() -> Single<Response<[Channel]>> {
        return discoverAPI.request(.labelList).checkResponse()
    }
    
    
    func refreshData() {
        requestData()
    }

    
    func viewController(at index: Int) -> SegementSlideContentScrollViewDelegate {
        
        let channel  = channels[index]
        
        guard let controller = cache.object(forKey: channel.labelId.description as NSString) as? SegementSlideContentScrollViewDelegate else {
            let vc = ChannelViewController.loadFromStoryboard()
            vc.channel = channel
            cache.setObject(vc, forKey: channel.labelId.description as NSString)
            return vc
        }
        
        return controller
    }
    
    override var bouncesType: BouncesType {
        return .parent
    }
    
    override func showBadgeInSwitcher(at index: Int) -> BadgeType {
        return .none
    }
    
    
    override func segementSlideHeaderView() -> UIView? {
        return nil
    }
    
    override var titlesInSwitcher: [String] {
        return channels.compactMap{ $0.tagName }
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return viewController(at: index)
    }

    
}
