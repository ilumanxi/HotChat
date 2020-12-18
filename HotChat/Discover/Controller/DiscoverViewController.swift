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


class DiscoverViewController: SegementSlideDefaultViewController, LoadingStateType, IndicatorDisplay {
    
    
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
            defaultSelectedIndex = 0
            reloadData()
            selectItem(at: 0, animated: false)
        }
    }
    
    let cache = NSCache<NSString, UIViewController>()
    
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
        self.edgesForExtendedLayout = .all
        state = .loadingContent
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    func setupViews() {
        
        if LoginManager.shared.user!.girlStatus && LoginManager.shared.currentVersionApproved {

            checkUserCallChat()
        }
        else {
            sayHellowButton.removeFromSuperview()
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
       
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] _ in
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
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
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
