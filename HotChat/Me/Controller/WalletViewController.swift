//
//  WalletViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SwiftyStoreKit


class WalletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
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
    
    override func loadView() {
        super.loadView()
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    let API = RequestAPI<UserAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "WalletProductViewCell", bundle: nil), forCellReuseIdentifier: "WalletProductViewCell")

        
        API.request(.amountList(type: 2), type: HotChatResponse<[Product]>.self)
            .subscribe(onSuccess: {[weak self] response in
                if response.isSuccessd {
                    let section = Section(type: .product, elements: response.data!)
                    self?.data.append(section)
                }
                
            }, onError: { error in
                
            })
            .disposed(by: rx.disposeBag)
        
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
            return cell
        }
        else {
            let content = section.elements as! [Product]
            
            let product = content[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WalletProductViewCell.self)
            cell.titleLabel.text = "\(product.energy) 能量"
            cell.priceButton.setTitle("¥ \(Int(product.money))", for: .normal)
            return cell
        }
    }

}
