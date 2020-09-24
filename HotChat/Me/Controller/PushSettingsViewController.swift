//
//  PushSettingsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class PushSettingsViewController: UITableViewController {
    
    enum Section: Int {
        case setting
        case invitation
        case notDisturb
        
        var title: String? {
            switch self {
            case .setting:
                return "支持通过性别、等级、距离等，过滤掉你不愿意接收的陌生人消息消除骚扰。"
            case .notDisturb:
                return "开启后，每天23:00~8:00，收到女生语音/视频邀请，都不会响铃提醒。"
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
        return 44
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        let title = Section(rawValue: section)?.title
        return title
    }
    
}
