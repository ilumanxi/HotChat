//
//  LegalLiabilityViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class LegalLiabilityViewController: UITableViewController {
    
    private lazy var toolBar: LegalLiabilityToolBar =  {
        let toolBar = LegalLiabilityToolBar()
        toolBar.onPushing.delegate(on: self) { (self, _) -> UINavigationController in
            return self.navigationController!
        }
        return toolBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        tableView.separatorColor = .clear
        tableView.backgroundColor = .white
//        tableView.bounces = false
//        tableView.isScrollEnabled = false
        tableView.tableFooterView = toolBar
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustFooterViewHeightToFillTableView()
    }
    
    private func adjustFooterViewHeightToFillTableView() {
        
         guard let tableFooterView = tableView.tableFooterView  else {
             return
         }
         
        let usableHeight = tableView.frame.height - tableView.contentSize.height + tableFooterView.frame.height - safeAreaTop
         
         if usableHeight != tableFooterView.frame.height {
             toolBar.frame.size.height  = max(usableHeight, LegalLiabilityToolBar.defaultHeight)
             tableView.tableFooterView = toolBar
         }
    }
}
