//
//  SettingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController, StoryboardCreate, IndicatorDisplay {
    
    
    static var storyboardNamed: String { return "Me" }
    
    
    
    let API = Request<AccountAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            logout()
        }
    }

    func logout() {
        showIndicator()
        API.request(.logout, type: ResponseEmpty.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
  
}
