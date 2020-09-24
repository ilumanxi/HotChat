//
//  ApplicationSettingsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


class ApplicationSettingsViewController: UITableViewController {
    
    
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    fileprivate func setupUI() {
        appVersionLabel.text = "当前版本\(Bundle.main.appVersion)"
    }

}
