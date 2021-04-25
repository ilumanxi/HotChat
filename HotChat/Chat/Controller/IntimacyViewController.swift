//
//  IntimacyViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/23.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit


class IntimacyViewController: UIViewController {
    
    let tableHeaderView = IntimacyHeaderView.loadFromNib()
    
    @IBOutlet weak var tableView: UITableView!
    
    let onStorage = Delegate<Void, Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
  
    }
    
    
    @IBAction func storageButtonTapped(_ sender: Any) {
        onStorage.call()
    }
    
    func setupUI() {
        tableView.tableHeaderView = tableHeaderView
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "IntimacyCell", bundle: nil), forCellReuseIdentifier: "IntimacyCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let targetSize = CGSize(width: tableView.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let size = tableHeaderView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority(900), verticalFittingPriority: .fittingSizeLevel)
        tableHeaderView.frame = CGRect(origin: .zero, size: size)
        tableView.tableHeaderView = tableHeaderView
    }
}


extension IntimacyViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: IntimacyCell.self)
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        return cell
    }
}
