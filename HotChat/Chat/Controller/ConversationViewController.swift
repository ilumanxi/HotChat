//
//  ConversationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SPAlertController


class ConversationViewController: UIViewController {
    
    lazy var conversationListController: TUIConversationListController = {
        let conversationListController = TUIConversationListController()
        conversationListController.delegate = self
        return conversationListController
    }()
    
    lazy var chatActionViewController: ConversationActionViewController = {
        let chatActionViewController = ConversationActionViewController.loadFromStoryboard()
        chatActionViewController.onContentHeightUpaded.delegate(on: self) { (self, sender) in
            sender.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: chatActionViewController.contentHeight)
            self.conversationListController.tableView.tableHeaderView = sender.view
        }
        return chatActionViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建会话列表
        addChild(conversationListController)
        
        view.addSubview(conversationListController.view)
        
        conversationListController.didMove(toParent: self)
        
        conversationListController.addChild(chatActionViewController)
        chatActionViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: chatActionViewController.contentHeight)
        chatActionViewController.tableView.isScrollEnabled = false
        conversationListController.tableView.tableHeaderView = chatActionViewController.view
        chatActionViewController.didMove(toParent: conversationListController)
        
        
       
    }
    
    @IBAction func contactItemTapped(_ sender: Any) {
        let meContact = MeContactViewController(show: .follow)
        navigationController?.pushViewController(meContact, animated: true)
    }
    
    
    
    @IBAction func moreAction(_ sender: Any) {
        
        let vc = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        vc.addAction(SPAlertAction(title: "消息设为已读", style: .default, handler: { _ in
            
            V2TIMManager.sharedInstance()?.getConversationList(0, count: .max, succ: { (conversationList, last, isFinished) in
                
                conversationList?.forEach{ conversation in
                    V2TIMManager.sharedInstance()?.markC2CMessage(asRead: conversation.userID, succ: {
                        
                    }, fail: { (code, msg) in
                        
                    })
                }
            }, fail: { (code, msg) in
                    
            })
            
        }))
        
        vc.addAction(SPAlertAction(title: "清空聊天列表", style: .default, handler: { [weak self] _ in
            self?.confirmClearanceRecord()
        }))
        
        vc.addAction(SPAlertAction(title: "取消", style: .cancel, handler: { _ in
            
        }))
        
        present(vc, animated: true, completion: nil)
    }
    

    
    func confirmClearanceRecord() {
        
        let message = "确定清空聊天纪律列表吗？清空后，你与好友的聊天纪律将不可恢复"
        let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.conversationListController.viewModel.dataList.forEach {
                self.conversationListController.viewModel.remove($0)
            }
        }))
        
        vc.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    func clearanceRecord() {
        
        V2TIMManager.sharedInstance()?.getConversationList(0, count: .max, succ: { (conversationList, last, isFinished) in
            
            conversationList?.forEach{ conversation in
                
                V2TIMManager.sharedInstance()?.deleteConversation(conversation.conversationID, succ: {
                    
                }, fail: { (code, msg) in
                    
                })
            }
        }, fail: { (code, msg) in
                
        })
        
    }
}

extension ConversationViewController: TUIConversationListControllerDelegate {
    
    func conversationListController(_ conversationController: TUIConversationListController, didSelectConversation conversation: TUIConversationCell) {
        
        let convData = conversation.convData
        
        let data = TUIConversationCellData()
        data.userID = convData.userID
        
        let vc  = ChatViewController(conversation: data)!
        vc.title = convData.title
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
