//
//  PushSettingsDetailViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class PushSettingsDetailViewController: UITableViewController {

       enum Section: Int {
        case setting
        case detail
        case notDisturb
        
        var title: String? {
            switch self {
            case .setting:
                return "关闭后，将只有密友和你关注的人，能向你发消息，同时系统将不再向女生推荐你"
            default:
                return nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        let title = Section(rawValue: section)?.title
        return title
    }
}
