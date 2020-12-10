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


class DiscoverViewController: SegementSlideDefaultViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    let discoverAPI = Request<DiscoverAPI>()
    
    var channels: [Channel] = [] {
        didSet {
            defaultSelectedIndex = 0
            reloadData()
            selectItem(at: 0, animated: false)
        }
    }
    
    let cache = NSCache<NSString, UIViewController>()
    
    let sayHellowButton: UIButton = {
        let button = UIButton(type: .custom)
        let text = "一键打招呼"
        button.setTitle(text, for: .normal)
        button.setImage(#imageLiteral(resourceName: "say-hello"), for: .normal)
        button.setImage(UIImage(named: "say-hello-gray"), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(hexString: "#333333"), for: .disabled)
        button.backgroundColor = UIColor(hexString: "#FF608F")
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.layer.cornerRadius = 17
        button.contentHorizontalAlignment = .leading
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
//        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = .all
        state = .loadingContent
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    func setupViews() {
        
        if LoginManager.shared.user!.girlStatus {
            view.addSubview(sayHellowButton)
            sayHellowButton.snp.makeConstraints { maker in
                maker.size.equalTo(CGSize(width: 110, height: 34))
                maker.trailingMargin.equalToSuperview()
                maker.bottom.equalTo(view.safeBottom).offset(-34)
            }
        }
        else {
            
        }
    }
    
    func requestData() {
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
        return .child
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
