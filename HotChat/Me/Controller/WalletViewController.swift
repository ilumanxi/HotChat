//
//  WalletViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit
import SwiftyStoreKit

// MARK: - SKProduct
extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}


class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorDisplay, LoadingStateType {
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    
    
    // com.friday.Chat.energy.6

    enum SectionType {
        
        case energy
        case product
    }
    
    struct Section {
        
        var type: SectionType
        /// List of products/purchases.
        var elements: [Any]
    }

    init(style: UITableView.Style) {
        super.init(nibName: nil, bundle: nil)
        self.tableView = UITableView(frame: .zero, style: style)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    convenience init() {
        self.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    var tableView: UITableView!
    

    var data: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let payAPI = Request<PayAPI>()
    
    
    
    var user: User = LoginManager.shared.user!
    
    var products: [(Product, SKProduct)] = []
    
    override func loadView() {
        super.loadView()
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    let API = Request<UserAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        requestUserInfo()
        requestProductInfo()
    }
    
    func setupViews()  {
        title = "我的钱包"
        
        tableView.register(UINib(nibName: "WalletEnergyViewCell", bundle: nil), forCellReuseIdentifier: "WalletEnergyViewCell")
        tableView.register(UINib(nibName: "WalletProductViewCell", bundle: nil), forCellReuseIdentifier: "WalletProductViewCell")
    }
    
    func requestUserInfo()  {
        API.request(.userinfo(userId: nil), type: Response<User>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data!
                self?.setupSections()
                
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func refreshData() {
        requestProductInfo()
    }
    
    func requestProductInfo()  {
        if self.products.isEmpty {
            state = .refreshingContent
        }
        
        productInfo()
            .subscribe(onSuccess: { [weak self] products in
                self?.products = products
                self?.setupSections()
                self?.state = .contentLoaded
                
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func setupSections() {
        let energySection = Section(type: .energy, elements: [user])
        let productSection = Section(type: .product, elements: products)
        
        self.data = [energySection, productSection]
        self.tableView.reloadData()
        
    }
    
    func productInfo() -> Single<[(Product, SKProduct)]> {
        
        return API.request(.amountList(type: 2), type: Response<[Product]>.self)
            .flatMap{ response -> Single<([Product], [SKProduct])> in

                guard let data = response.data else {
                    throw HotChatError.generalError(reason: HotChatError.GeneralErrorReason.conversionError(string: response.msg, encoding: .utf8))
                }

                let productIds = data.compactMap{ "com.friday.Chat.energy.\($0.money.intValue)" }
               
                return Single.create { single in
                    
                    SwiftyStoreKit.retrieveProductsInfo(Set(productIds)) { result in
                        
                        if let error = result.error {
                            single(.error(error))
                        }
                        else {
                            single(.success((data, Array(result.retrievedProducts))))
                        }
                    }

                   return Disposables.create()
                }

            }
            .map(productSorted)
        
    }
    
    
    func productSorted(_ product: ([Product], [SKProduct])) -> [(Product, SKProduct)] {
        let sourceProduct = product.0
        let appleProduct = product.1
        
        func findProduct(_ product: SKProduct) -> Product {
            return sourceProduct.first {
                "com.friday.Chat.energy.\($0.money.intValue)" == product.productIdentifier
            }!
        }
        return appleProduct
            .compactMap{ (findProduct($0), $0) }
            .sorted { (l, r) -> Bool in
                l.1.price.intValue < r.1.price.intValue
            }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let type = data[indexPath.section].type
        
        switch type {
        case .energy:
            return 95
        default:
            return 50
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = data[indexPath.section]
        
        if section.type == .energy {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletEnergyViewCell.self)
            cell.titleLabel.text = "能量：\(user.userEnergy.description)"
            return cell
        }
        else {
            let content = section.elements as! [(Product, SKProduct)]
            
            let product = content[indexPath.row]
           
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletProductViewCell.self)
            cell.titleLabel.text = product.1.localizedTitle
            cell.priceButton.setTitle( product.1.regularPrice?.replacingOccurrences(of: ".00", with: ""), for: .normal)
            return cell
        }
    }
    
    /// Starts a purchase when the user taps an available product row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = data[indexPath.section]
        
        // Only available products can be bought.
        if section.type == .product, let content = section.elements as? [(Product, SKProduct)] {
            let product = content[indexPath.row]
            showIndicator()
            createOrder(product)
                .flatMap(payOrder)
                .subscribe(onSuccess: { [weak self] response in
                    self?.requestUserInfo()
                    self?.hideIndicator()
                }, onError: { [weak self] error in
                    self?.hideIndicator()
                    self?.show(error.localizedDescription)
                    
                })
                .disposed(by: rx.disposeBag)
            
        }
    }
    
    func payOrder(_ order: (Ordrer, Product, SKProduct)) -> Single<ResponseEmpty> {
        return Single.create { single in
            
            // Attempt to purchase the tapped product.
            SwiftyStoreKit.purchaseProduct(order.2, atomically: true, applicationUsername: order.0.outTradeNo) { result in
                switch result {
                case .success(let purchase):
                    
                    let receipt =  try! Data(contentsOf: Bundle.main.appStoreReceiptURL!)
                    
                    var orderId: String =  order.0.outTradeNo
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
        return payAPI.request(.notify(parameters), type: ResponseEmpty.self)
    }
    
    func createOrder(_ product: (Product, SKProduct)) -> Single<(Ordrer, Product, SKProduct)> {
        
        let parameters: [String : Any] =  [
            "subject" : product.1.localizedTitle,
            "body": product.1.localizedDescription,
            "amount" : product.1.price.doubleValue,
            "moneyId" : product.0.moneyId,
            "energy" : product.0.energy
        ]
        
        return payAPI.request(.ceateOrder(parameters), type: Response<[String : Any]>.self)
            .map { response in
                if response.isSuccessd {
                    let order =  Ordrer.deserialize(from: response.data, designatedPath: "params")!
                    return (order, product.0, product.1)
                }
                else {
                    throw HotChatError.generalError(reason: HotChatError.GeneralErrorReason.conversionError(string: response.msg, encoding: .utf8))
                }
               
            }
    }

}



