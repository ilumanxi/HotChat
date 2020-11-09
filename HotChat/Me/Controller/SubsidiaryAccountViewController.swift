//
//  SubsidiaryAccountViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide

class SubsidiaryAccountViewController: UIViewController, SegementSlideContentScrollViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let type: Checklist
    
    @objc
    var scrollView: UIScrollView {
        return tableView
    }
    
    init(type: Checklist) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 0
        tableView.register(UINib(nibName: "SubsidiaryAccountCell", bundle: nil), forCellReuseIdentifier: "SubsidiaryAccountCell")
    }

}


extension SubsidiaryAccountViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SubsidiaryAccountCell.self)
        
        return cell
    }
}
