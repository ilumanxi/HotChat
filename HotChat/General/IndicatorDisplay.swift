//
//  Wireframe.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit
import StoreKit
import MBProgressHUD
import Toast_Swift

protocol IndicatorDisplay: NSObject {
    func show(_ error: Error, in view: UIView)
    func show(_ message: String?, in view: UIView)
    func showIndicator(_ message: String?, in view: UIView)
    func showOrHideIndicator(loadingState: LoadingState, in view: UIView, text: String?, image: UIImage?, actionText: String?, backgroundColor: UIColor?)
    func hideIndicator(from view: UIView)
    
    func refreshData()
    
    func actionTapped()
}

class IndicatorHolderView: UIView {}


extension IndicatorDisplay where Self: UIViewController {
    
    func show(_ error: Error) {
        show(error, in: view)
    }
    
    func show(_ error: Error, in view: UIView) {
        if !shouldHandler(error) {
            return
        }
        
        show(message(error), in: view)
    }
    
    private func shouldHandler(_ error: Error) -> Bool {
        let invalidCodes = [
            HotChatError.Code.accountBanned.rawValue,
            HotChatError.Code.accountDestroy.rawValue
        ]
        return !invalidCodes.contains(error._code)
    }
    
    private func message(_ error: Error) -> String {
        var text = error.localizedDescription
        text = text.replacingOccurrences(of: "URLSessionTask failed with error: ", with: "")
        if text.contains(SKErrorDomain), let index = text.firstIndex(of: "。") {
            text = String(text[text.startIndex...index])
        }
        return text
    }
    
    func show(_ message: String?) {
        show(message, in: view)
    }
    
    func showIndicator(_ message: String? = nil) {
       showIndicator(message, in: view)
    }
    
    func hideIndicator() {
        hideIndicator(from: view)
    }
    
    func showMessageOnWindow(_ error: Error) {
        show(error, in: UIApplication.shared.keyWindow ?? view)
    }
    
    func showMessageOnWindow(_ message: String?) {
        show(message, in: UIApplication.shared.keyWindow ?? view)
    }
    
    func showIndicatorOnWindow(_ message: String? = nil) {
        showIndicator(message, in: UIApplication.shared.keyWindow ?? view)
    }
    
    func hideIndicatorFromWindow() {
        hideIndicator(from: UIApplication.shared.keyWindow ?? view)
    }
    
    func show(_ message: String?, in view: UIView) {
        view.endEditing(true)
        view.makeToast(message, position: .center)
    }
    
    func showIndicator(_ message: String?, in view: UIView) {
        view.endEditing(true)
        let hub  = MBProgressHUD.showAdded(to: view, animated: true)
        if let message = message {
            hub.label.text = message
        }
        hub.show(animated: true)
    }
    
    func showOrHideIndicator(loadingState: LoadingState, text: String? = nil, image: UIImage? = nil, actionText: String? = nil, backgroundColor: UIColor? = nil) {
        showOrHideIndicator(loadingState: loadingState, in: view, text: text, image: image, actionText: actionText, backgroundColor: backgroundColor)
    }
    
    
    func showOrHideIndicator(loadingState: LoadingState, in view: UIView, text: String? = nil, image: UIImage? = nil, actionText: String? = nil, backgroundColor: UIColor? = nil) {
        
        func showImageText(text: String, image: UIImage, actionText: String? = nil) -> UIStackView {
            var arrangedSubviews: [UIView] = []
            
            let imageView = UIImageView(image: image)
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(hexString: "#999999")
            label.text = text
            label.numberOfLines = 0
            label.textAlignment = .center
            
            arrangedSubviews.append(imageView)
            
            arrangedSubviews.append(label)
            
            
            if let actionText = actionText {
                
                let actionButton = GradientButton(type: .custom)
                actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 25, bottom: 10, right: 25)
                actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                actionButton.setTitleColor(.white, for: .normal)
                actionButton.colors = [UIColor(hexString: "#FF3F3F"), UIColor(hexString: "#FF6A2F")]
                actionButton.setTitle(actionText, for: .normal)
                actionButton.sizeToFit()
                actionButton.layer.cornerRadius = actionButton.bounds.height / 2
                
                actionButton.rx.controlEvent(.touchUpInside)
                    .subscribe { [weak self]  _ in
                        self?.actionTapped()
                    }
                    .disposed(by: rx.disposeBag)
                arrangedSubviews.append(actionButton)
            }
            
           
            
            let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
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
        holderView.backgroundColor = backgroundColor ?? (view.backgroundColor ?? UIColor.white)
        
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
            let stackView = showImageText(text: text ?? "暂无数据", image: image ??  UIImage(named: "no-content")!, actionText: actionText)
            holderView.addSubview(stackView)
            stackView.snp.makeConstraints { maker in
                maker.center.equalToSuperview()
            }
            
            viewAddRefreshDataTap(holderView)
        case .error:
            let stackView = showImageText(text: text ?? "网络不给力，请稍后再试!", image: image ??  UIImage(named: "load-error")!, actionText: actionText)
            holderView.addSubview(stackView)
            stackView.snp.makeConstraints { maker in
                maker.center.equalToSuperview()
            }
            viewAddRefreshDataTap(holderView)
        default:
            break
        }
         
        view.addSubview(holderView)
        
        if let scrollView = view as? UIScrollView {
            holderView.snp.makeConstraints { maker in
                maker.leading.equalTo(scrollView.frameLayoutGuide.snp.leading)
                maker.trailing.equalTo(scrollView.frameLayoutGuide.snp.trailing)
                maker.top.equalTo(scrollView.frameLayoutGuide.snp.top)
                maker.bottom.equalTo(scrollView.frameLayoutGuide.snp.bottom)
            }
        }
        else {
            holderView.snp.makeConstraints { maker in
                maker.edges.size.equalToSuperview()
            }
        }
    }
    
    func hideIndicator(from view: UIView) {
        let hub = view.subviews.first { $0 is MBProgressHUD } as? MBProgressHUD
        hub?.hide(animated: true)
    }
    
    func refreshData() {
        
    }
    
    func actionTapped() {
        
    }
}
