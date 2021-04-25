//
//  IntimateTopViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class IntimateTopViewController: UIViewController {
    
    
    var headerView: IntimateTopHeaderView = IntimateTopHeaderView.loadFromNib()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 0
        
        tableView.tableHeaderView = headerView
        
        tableView.register(UINib(nibName: "IntimateTopCell", bundle: nil), forCellReuseIdentifier: "IntimateTopCell")

        // Do any additional setup after loading the view.
    }


}

extension IntimateTopViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: IntimateTopCell.self)
        
        return cell
    }
    
    
}
