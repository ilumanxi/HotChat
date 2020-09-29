//
//  ChatViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import TXIMSDK_TUIKit_iOS

class ChatViewController: UITableViewController {
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
        let vc =  TUIConversationListController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    

}

extension ChatViewController: TUIConversationListControllerDelegate {
    
    func conversationListController(_ conversationController: TUIConversationListController, didSelectConversation conversation: TUIConversationCell) {
        
        let convData = conversation.convData
        
//        data.groupID = @"groupID";  // 如果是群会话，传入对应的群 ID
//        data.userID = @"userID";    // 如果是单聊会话，传入对方用户 ID
        
        let data = TUIConversationCellData()
        data.userID = convData.userID
        
        let vc  = TUIChatController(conversation: data)!
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
