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
import ActiveLabel

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
        self.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    var tableView: UITableView!
    
    lazy fileprivate var textLabel: ActiveLabel = {
       let label = ActiveLabel()
       label.numberOfLines = 0
       label.font = .systemFont(ofSize: 12)
       label.textAlignment = .center
       label.textColor = .textGray
       let agreementType = ActiveType.custom(pattern: "《用户充值协议》")
       let privacyType = ActiveType.custom(pattern: "联系客服>")
       let normalColor = UIColor(hexString: "#525AF8")
       let selectedColor = normalColor.withAlphaComponent(0.7)
       label.customColor[agreementType] = normalColor
       label.customColor[privacyType] = normalColor
       label.customSelectedColor[agreementType] = selectedColor
       label.customSelectedColor[privacyType] = selectedColor
       label.enabledTypes = [agreementType, privacyType]

       label.handleCustomTap(for: agreementType) { [weak self] element in
            let vc = WebViewController.H5(path: "h5/payAgreement")
            self?.navigationController?.pushViewController(vc, animated: true)
       }
       label.handleCustomTap(for: privacyType) { [weak self] element in
            let vc = WebViewController.H5(path: "h5/customer")
            self?.navigationController?.pushViewController(vc, animated: true)
       }
        
        label.lineSpacing = 9
        
        let text = """
        充值即代表你已成年，并同意《用户充值协议》
        充值遇到问题，请及时 联系客服>
        """
        label.text = text
        label.sizeToFit()
       return label
   }()
    

    var data: [Section] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let payAPI = Request<PayAPI>()
    
    
    var user: User = LoginManager.shared.user!
    
    var products: [ItemProduct] = []
    
    override func loadView() {
        super.loadView()
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.frame = view.bounds
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
        
    
        let recordItem = UIBarButtonItem(title: "明细", style: .plain, target: self, action: #selector(pushExpensesRecord))
        navigationItem.rightBarButtonItem = recordItem
        
        tableView.register(UINib(nibName: "WalletEnergyViewCell", bundle: nil), forCellReuseIdentifier: "WalletEnergyViewCell")
        tableView.register(UINib(nibName: "WalletProductViewCell", bundle: nil), forCellReuseIdentifier: "WalletProductViewCell")
        
        tableView.tableFooterView = textLabel
    }
    
    @objc private func pushExpensesRecord() {
        let vc = ConsumptionListController(type: .wallet)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func requestUserInfo()  {
        API.request(.userinfo(userId: nil), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data!
                let user = LoginManager.shared.user!
                user.userEnergy = response.data!.userEnergy
                LoginManager.shared.update(user: user)
                
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
        let productSection = Section(type: .product, elements: [products])
        
        self.data = [energySection, productSection]
        self.tableView.reloadData()
        
    }
    
    func productInfo() -> Single<[ItemProduct]> {
        
        return API.request(.amountList(type: 2), type: Response<[Product]>.self)
            .flatMap{ response -> Single<[ItemProduct]> in

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
                            
                            let retrievedProducts = Array(result.retrievedProducts)
                            var items: [ItemProduct] = []
                            
                            retrievedProducts.forEach { appleProduct in
                                
                                if let product = data.first(where: { appleProduct.productIdentifier == "com.friday.Chat.energy.\($0.money.intValue)" }) {
                                    items.append(ItemProduct(product: product, appleProduct: appleProduct))
                                    
                                }
                            }
                            single(.success(items))
                        }
                    }

                   return Disposables.create()
                }

            }
            .map(productSorted)
        
    }
    
    
    func productSorted(_ products: [ItemProduct]) -> [ItemProduct] {

        return products
            .sorted { (l, r) -> Bool in
                l.appleProduct.price.intValue < r.appleProduct.price.intValue
            }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let type = data[indexPath.section].type
        
        switch type {
        case .energy:
            return 126
        default:
            return 190
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = data[indexPath.section]
        
        if section.type == .energy {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletEnergyViewCell.self)
            cell.energyLabel.text = user.userEnergy.description
            cell.coinLabel.text = user.userTanbi.description
            return cell
        }
        else {           
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletProductViewCell.self)
            cell.products = products
            cell.onSelectedIndexPath.delegate(on: self) { (self, indexPath) in
                self.payProduct(self.products[indexPath.item])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let inserCell = cell  as? InsetGroupedCell else { return  }
        
        if self.tableView(tableView, numberOfRowsInSection: indexPath.section) == 1 {
            
            inserCell.rectCorner = .allCorners
        }
        else if indexPath.row == 0 {
            inserCell.rectCorner = [.topLeft, .topRight]
        }
        else if indexPath.row == (self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
            inserCell.rectCorner = [.bottomLeft, .bottomRight]
        }
        else {
            inserCell.rectCorner = []
        }
    }
    
    func payProduct(_ product: ItemProduct) {
        showIndicatorOnWindow()
        createOrder(product)
            .flatMap(payOrder)
            .subscribe(onSuccess: { [weak self] response in
                self?.requestUserInfo()
                self?.hideIndicatorFromWindow()
            }, onError: { [weak self] error in
                self?.hideIndicatorFromWindow()
                self?.show(error)
                
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    func payOrder(_ order: Ordrer) -> Single<ResponseEmpty> {
        return Single.create { single in
            
            // Attempt to purchase the tapped product.
            SwiftyStoreKit.purchaseProduct(order.itemProduct.appleProduct, atomically: true, applicationUsername: order.outTradeNo) { result in
                switch result {
                case .success(let purchase):
                    
                    let receipt =  try! Data(contentsOf: Bundle.main.appStoreReceiptURL!)
                    
                    var orderId: String =  order.outTradeNo
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
    
    func createOrder(_ itemProduct: ItemProduct) -> Single<Ordrer> {
        
        let parameters: [String : Any] =  [
            "subject" : itemProduct.appleProduct.localizedTitle,
            "body": itemProduct.appleProduct.localizedDescription,
            "amount" : itemProduct.appleProduct.price.doubleValue,
            "moneyId" : itemProduct.product.moneyId,
            "energy" : itemProduct.product.energy
        ]
        
        return payAPI.request(.ceateOrder(parameters), type: Response<[String : Any]>.self)
            .verifyResponse()
            .map { response in
                var order =  Ordrer.deserialize(from: response.data, designatedPath: "params")!
                order.itemProduct = itemProduct
                return order
            }
    }

}



