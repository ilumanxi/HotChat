//
//  RemarkViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class RemarkViewController: UITableViewController, StoryboardCreate {
    
    
    static var storyboardNamed: String { return "Chat" }
    
    
    @IBOutlet weak var textField: UITextField!
    
    let onSaved = Delegate<String, Void>()
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.hiddenHeader()
        
        let save = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveItemTapped))
        navigationItem.rightBarButtonItems = [save]
        
        textField.text = text
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @objc func saveItemTapped() {
        
        onSaved.call(textField.text ?? "")
    }
   
}
