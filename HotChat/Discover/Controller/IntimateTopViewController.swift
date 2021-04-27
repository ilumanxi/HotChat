//
//  IntimateTopViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import MJRefresh

class IntimateTopViewController: UIViewController {
    
    
    lazy var headerView: IntimateTopHeaderView  = {
        let view = IntimateTopHeaderView.loadFromNib()
        view.onNavigation.delegate(on: self) { (self, _) in
            return self.navigationController!
        }
        return view
    }()
    
    let API = Request<TopAPI>()
    
    fileprivate var data: IntimacyList? {
        didSet{
            headerView.set(data?.topList ?? [])
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        // Do any additional setup after loading the view.
        data = nil
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    func setupUI() {
        tableView.rowHeight = 75
        tableView.estimatedRowHeight = 0
        tableView.tableHeaderView = headerView
        tableView.register(UINib(nibName: "IntimateTopCell", bundle: nil), forCellReuseIdentifier: "IntimateTopCell")
    }
    
    func refreshData() {
        
        API.request(.intimacyTopList, type: Response<IntimacyList>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.data = response.data
            }, onError: { error in
                
            })
            .disposed(by: rx.disposeBag)
    }

}

extension IntimateTopViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: IntimateTopCell.self)
        cell.set(data!.list[indexPath.row])
        cell.onNavigation.delegate(on: self) { (self, _) in
            return self.navigationController!
        }
        
        return cell
    }
    
    
}
