//
//  WebViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/12.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import WKWebViewJavascriptBridge
import StoreKit
import SwiftyStoreKit
import RxSwift
import RxCocoa

extension WebViewController {
    
    class func H5(path: String) -> Self {
        let pathToken = "\(path)?token=\(LoginManager.shared.user?.token ?? "")"
        let url = Constant.H5HostURL.appendingPathComponent(pathToken)
        return WebViewController(url: url) as! Self
    }
}

class WebViewController: UIViewController {
    
    var webViewConfiguration = WKWebViewConfiguration()
    
    lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: webViewConfiguration)
        return view
    }()
    
    
    let url: URL?
    
    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var bridge: WKWebViewJavascriptBridge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBridge()
        loadURL()
    }
    
    
    
    func setupBridge() {
        bridge = WKWebViewJavascriptBridge(webView: webView)
        bridge.isLogEnable = true
        bridge.register(handlerName: "getToken") { (paramters, callback) in
            callback?(LoginManager.shared.user?.token)
        }
        
        bridge.register(handlerName: "getToken") { (paramters, callback) in
            callback?(LoginManager.shared.user?.token)
        }
        
        bridge.register(handlerName: "purchaseVIP") {[weak self] (paramters, callback) in
            self?.purchaseVIP(paramters, callback: callback)
            
        }
        
        bridge.register(handlerName: "share") {[weak self] (paramters, callback) in
            self?.share(paramters, callback: callback)
            
        }
        
        bridge.register(handlerName: "pushInvite") {[weak self] (paramters, callback) in
            self?.pushInvite(paramters, callback: callback)
            
        }
    }
    
    func loadURL() {
        
        guard let url = url else {
            return
        }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
    }

    func setupViews()  {
        view.addSubview(webView)
        webView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        webView.rx.observe(String.self, #keyPath(WKWebView.title))
            .map{ $0 ?? "" }
            .bind(to: rx.title)
            .disposed(by: rx.disposeBag)
            
    }
    
    let payAPI = Request<PayAPI>()
}


extension WebViewController {
    
    public typealias Parameters = [String: Any]
    
    public typealias Callback = (_ responseData: Any?) -> Void
    
    
    func pushInvite(_ parameters: Parameters?, callback: Callback?) {
        let vc = InviteViewController.loadFromStoryboard()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func share(_ parameters: Parameters?, callback: Callback?) {
        
        guard let sceneRawValue = parameters?["scene"] as? Int,
              let scene = WeChat.Scene(rawValue: sceneRawValue),
              let webpage = parameters?["webpageUrl"] as? String,
              let webpageUrl = URL(string: webpage),
              let title = parameters?["title"] as? String,
              let description = parameters?["description"] as? String else {
            self.callback(code: 10001, msg: "参数有误", callback: callback)
            return
        }
        WeChat.default.share(scene: scene, webpageUrl: webpageUrl, title: title, description: description, thumbImage: nil) { error in
            callback?(error?.localizedDescription)
        }
        
    }
    
    func purchaseVIP(_ parameters: Parameters?, callback: Callback?)  {
        
        guard let orderNo = parameters?["orderNo"] as? String,
              let productId = parameters?["vip"] as? String else {
            self.callback(code: 10001, msg: "参数有误", callback: callback)
            return
        }
        
        productInfo(productId: productId)
            .map{ AppleOrder(orderNo: orderNo, product: $0) }
            .flatMap(payOrder)
            .subscribe(onSuccess: { [weak self] response in
                self?.callback(code: 1, msg: response.msg, callback: callback)
                
            }, onError: {[weak self]  error in
                self?.callback(code: 10002, msg: error.localizedDescription, callback: callback)
            })
            .disposed(by: rx.disposeBag)
            
    }
    
    func callback(code: Int, msg: String, callback: Callback?) {
        var response = ResponseEmpty()
        response.code = code
        response.msg = msg
        callback?(response.toJSON())
    }
    
    func productInfo(productId: String) -> Single<SKProduct> {
        
        return Single.create { single in
            SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
                
                if let error = result.error {
                    single(.error(error))
                }
                else {
                    single(.success(result.retrievedProducts.first!))
                }
            }

           return Disposables.create()
        }
        
    }
    
    
    func payOrder(_ order: AppleOrder) -> Single<ResponseEmpty> {
        return Single.create { single in
            
            // Attempt to purchase the tapped product.
            SwiftyStoreKit.purchaseProduct(order.product, atomically: true, applicationUsername: order.orderNo) { result in
                switch result {
                case .success(let purchase):
                    
                    let receipt =  try! Data(contentsOf: Bundle.main.appStoreReceiptURL!)
                    
                    var orderId: String =  order.orderNo
                    if let transaction = purchase.transaction as? SKPaymentTransaction, let applicationUsername =  transaction.payment.applicationUsername {
                        orderId =  applicationUsername
                    }
                    
                    let transactionId = purchase.transaction.transactionIdentifier ?? ""
                    let parameters: [String : Any] = [
                        "tradeNo" : transactionId,
                        "outTradeNo" : orderId,
                        "receiptData" : receipt.base64EncodedString()
                    ]
                    
                    single(.success(parameters))
                    
                case .error(let error):
                    single(.error(error))
                }
            }
           
           return Disposables.create()
        }
        .flatMap(payStatus)
    }
    
    func payStatus(_ parameters: [String : Any]) -> Single<ResponseEmpty> {
        return payAPI.request(.notify(parameters), type: ResponseEmpty.self).checkResponse()
    }
}

struct AppleOrder {
    
    let orderNo: String
    let product: SKProduct
}