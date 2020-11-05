//
//  GiftEarningsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class GiftEarningsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "礼物"
        
        setupTableView()
    }

    
    func setupTableView() {
        tableView.rowHeight = 70
        tableView.estimatedRowHeight = 0
        tableView.register(UINib(nibName: "GiftEarningsCell", bundle: nil), forCellReuseIdentifier: "GiftEarningsCell")
        
    }

}

extension GiftEarningsViewController: UITableViewDelegate {
    
}



extension GiftEarningsViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 21
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: GiftEarningsCell.self)
        
        return cell
    }
}
