//
//  RealNameAuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class RealNameAuthenticationViewController: UITableViewController {
    

    fileprivate var isShowUploadCard: Bool = false {
        didSet {
            handleUploadCardDisplayStatus()
        }
    }
    
    fileprivate let cardCellIndexPath: IndexPath = IndexPath(row: 5, section: .zero)
    
    @IBOutlet var cardHiddenShowViews: [UIView]!
    
    @IBOutlet var cardShowHiddenViews: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isShowUploadCard = false
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !isShowUploadCard  && indexPath == cardCellIndexPath {
            return .zero
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    @IBAction func showUploadCardView(_ sender: Any) {
        isShowUploadCard = true
    }
    
    fileprivate func handleUploadCardDisplayStatus() {
                
        cardHiddenShowViews.forEach {
            $0.isHidden = !isShowUploadCard
        }
        
        cardShowHiddenViews.forEach {
            $0.isHidden = isShowUploadCard
        }
        
        tableView.reloadData()
    }

}
