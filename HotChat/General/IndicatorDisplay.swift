//
//  Wireframe.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit
import MBProgressHUD
import Toast_Swift

protocol IndicatorDisplay: NSObject {
    
    func show(_ message: String?, in view: UIView)
    func showIndicator(in view: UIView)
    func showOrHideIndicator(loadingState: LoadingState, in view: UIView, text: String?, image: UIImage?)
    func hideIndicator(from view: UIView)
    
    func refreshData()
}

class IndicatorHolderView: UIView {}


extension IndicatorDisplay where Self: UIViewController {
    
    func show(_ message: String?) {
        show(message, in: view)
    }
    
    func showIndicator() {
       showIndicator(in: view)
    }
    
    func hideIndicator() {
        hideIndicator(from: view)
    }
    
    func showMessageOnWindow(_ message: String?) {
        show(message, in: UIApplication.shared.keyWindow ?? view)
    }
    
    func showIndicatorOnWindow() {
        showIndicator(in: UIApplication.shared.keyWindow ?? view)
    }
    
    func hideIndicatorFromWindow() {
        hideIndicator(from: UIApplication.shared.keyWindow ?? view)
    }
    
    func show(_ message: String?, in view: UIView) {
        view.endEditing(true)
        view.makeToast(message, position: .center)
    }
    
    func showIndicator(in view: UIView) {
        let hub  = MBProgressHUD.showAdded(to: view, animated: true)
        hub.show(animated: true)
    }
    
    func showOrHideIndicator(loadingState: LoadingState, text: String? = nil, image: UIImage? = nil) {
        showOrHideIndicator(loadingState: loadingState, in: view, text: text, image: image)
    }
    
    
    func showOrHideIndicator(loadingState: LoadingState, in view: UIView, text: String? = nil, image: UIImage? = nil) {
        
        func showImageText(text: String, image: UIImage) -> UIStackView {
            let imageView = UIImageView(image: image)
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(hexString: "#999999")
            label.text = text
            
            let stackView =  UIStackView(arrangedSubviews: [imageView, label])
            stackView.spacing = 16
            stackView.alignment  = .center
            stackView.distribution = .fill
            stackView.axis = .vertical
            return stackView
        }
        
        func viewAddRefreshDataTap(_ view: UIView) {
            let refreshDataTap = UITapGestureRecognizer()
            refreshDataTap.rx.event
                .subscribe(onNext: { [weak self] _ in
                    self?.refreshData()
                })
                .disposed(by: rx.disposeBag)
            view.addGestureRecognizer(refreshDataTap)
        }
        
        let findHolderView = view.subviews.first { $0 is IndicatorHolderView }
        findHolderView?.subviews.forEach{ $0.removeFromSuperview() }
        findHolderView?.gestureRecognizers?.forEach{ findHolderView?.removeGestureRecognizer($0) }
        if loadingState == .contentLoaded {
            findHolderView?.removeFromSuperview()
            return
        }
        let holderView = findHolderView ?? IndicatorHolderView()
        holderView.backgroundColor = .groupTableViewBackground
        
        switch loadingState {
        case .initial, .loadingContent, .refreshingContent:
            let indicator = UIActivityIndicatorView(style: .gray)
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(hexString: "#999999")
            label.text = text ?? "加载中"
            
            let stackView =  UIStackView(arrangedSubviews: [indicator, label])
            stackView.spacing = 16
            stackView.alignment  = .center
            stackView.distribution = .fill
            stackView.axis = .vertical
            
            holderView.addSubview(stackView)
            stackView.snp.makeConstraints { maker in
                maker.center.equalToSuperview()
            }
        case .noContent:
            let stackView = showImageText(text: text ?? "暂时没有数据!", image: image ??  UIImage(named: "no-content")!)
            holderView.addSubview(stackView)
            stackView.snp.makeConstraints { maker in
                maker.center.equalToSuperview()
            }
            
            viewAddRefreshDataTap(holderView)
        case .error:
            let stackView = showImageText(text: text ?? "数据加载失败、请刷新!", image: image ??  UIImage(named: "load-error")!)
            holderView.addSubview(stackView)
            stackView.snp.makeConstraints { maker in
                maker.center.equalToSuperview()
            }
            viewAddRefreshDataTap(holderView)
        default:
            break
        }
         
        view.addSubview(holderView)
        holderView.snp.makeConstraints { maker in
            maker.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    func hideIndicator(from view: UIView) {
        let hub = view.subviews.first { $0 is MBProgressHUD } as? MBProgressHUD
        hub?.hide(animated: true)
    }
    
    func refreshData() {
        
    }
}
