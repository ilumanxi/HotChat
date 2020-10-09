//
//  ChatActionViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class ChatActionViewController: UITableViewController {
    
    static func loadFromStoryboard() -> Self {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        
        let identifier = String(describing: Self.self)
        
        return  storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
    
    var contentHeight: CGFloat {
        return 192
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

   

}
