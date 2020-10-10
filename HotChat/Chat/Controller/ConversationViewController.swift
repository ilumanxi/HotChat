//
//  ConversationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


class ConversationViewController: UIViewController {
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建会话列表
        let conversationListController = TUIConversationListController()
        conversationListController.delegate = self
        addChild(conversationListController)
        
        view.addSubview(conversationListController.view)
        
        conversationListController.didMove(toParent: self)
        
        
        let chatActionViewController = ConversationActionViewController.loadFromStoryboard()
        conversationListController.addChild(chatActionViewController)
        chatActionViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: chatActionViewController.contentHeight)
        chatActionViewController.tableView.isScrollEnabled = false
        conversationListController.tableView.tableHeaderView = chatActionViewController.view
        chatActionViewController.didMove(toParent: conversationListController)
        
        
       
    }
    
    @IBAction func moreAction(_ sender: Any) {
        
//        let vc =  TUIConversationListController()
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
    }
    

}

extension ConversationViewController: TUIConversationListControllerDelegate {
    
    func conversationListController(_ conversationController: TUIConversationListController, didSelectConversation conversation: TUIConversationCell) {
        
        let convData = conversation.convData
        
//        data.groupID = @"groupID";  // 如果是群会话，传入对应的群 ID
//        data.userID = @"userID";    // 如果是单聊会话，传入对方用户 ID
        
        let data = TUIConversationCellData()
        data.userID = convData.userID
        
        let vc  = ChatViewController(conversation: data)!
        vc.title = convData.userID.description
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
