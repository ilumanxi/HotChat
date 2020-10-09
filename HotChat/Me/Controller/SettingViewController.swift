//
//  SettingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    
    let API = RequestAPI<AccountAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 5 {
            
            logout()
        }
    }

    func logout() {
        API.request(.logout, type: ResponseEmpty.self)
            .subscribe(onSuccess: { response in
                Log.print(response)
            }, onError: { error in
                Log.print(error)
            })
            .disposed(by: rx.disposeBag)
    }
  
}
