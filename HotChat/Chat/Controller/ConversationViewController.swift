//
//  ConversationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/8.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SPAlertController
import Pageboy
import Tabman

// TUIKitNotification_onChangeUnReadCount

extension ConversationListController: IndicatorDisplay {
    
    
}

class ConversationViewController: TabmanViewController {
    
    var titles: [String] = []
    var viewConrollers: [UIViewController] = []
    
    lazy var chatActionViewController: ConversationActionViewController = {
        let chatActionViewController = ConversationActionViewController.loadFromStoryboard()
        chatActionViewController.onContentHeightUpaded.delegate(on: self) { (self, sender) in
            sender.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: chatActionViewController.contentHeight)
            self.messageController.tableView.tableHeaderView = sender.view
        }
        return chatActionViewController
    }()

    
    lazy var messageController: ConversationListController = {
        var controller = ConversationListController()
        controller.view.backgroundColor = .white
        controller.delegate = self
        controller.addChild(chatActionViewController)
        chatActionViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: chatActionViewController.contentHeight)
        chatActionViewController.tableView.isScrollEnabled = false
        controller.tableView.tableHeaderView = chatActionViewController.view
        chatActionViewController.didMove(toParent: controller)
        return controller
    }()
    
    lazy var intimateController: ConversationListController = {
        var controller = ConversationListController(intimacy: true)
        controller.delegate = self
        controller.dataChaned =  { owoner, data in
            if data.isEmpty {
                let text = "亲密度>4℃的亲密关系会在这里展示哦~\n快去和心仪的Ta聊聊吧"
                owoner.showOrHideIndicator(loadingState: .noContent, text: text, image: UIImage(named: "no-content-intimacy"), actionText: nil, backgroundColor: .white)
            }
            else {
                owoner.showOrHideIndicator(loadingState: .contentLoaded)
            }
        }
        return controller
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        viewConrollers = [messageController, intimateController]
        titles = ["消息", "亲密"]

        bounces = false
        isScrollEnabled = false
        
        // Set PageboyViewControllerDataSource dataSource to configure page view controller.
        dataSource = self
        
        // Create a bar
        let bar =  Tabman.TMBarView<Tabman.TMHorizontalBarLayout, Tabman.TMLabelBarButton, Tabman.TMBarIndicator.None>()
                
        // Customize bar properties including layout and other styling.
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 12, bottom: 4.0, right: 12)
        bar.fadesContentEdges = true
        bar.spacing = 20
        bar.backgroundView.style = .clear
        
        // Set tint colors for the bar buttons and indicator.
        bar.buttons.customize {
            $0.tintColor = UIColor(hexString: "#666666")
            $0.font = .systemFont(ofSize: 17, weight: .regular)
            $0.selectedTintColor = UIColor(hexString: "#333333")
            $0.selectedFont = .systemFont(ofSize: 19, weight: .bold)
        }
        bar.indicator.tintColor = UIColor(hexString: "#FF3F3F")
        
        // Add bar to the view - as a .systemBar() to add UIKit style system background views.
        
        addBar(bar.hiding(trigger: .manual), dataSource: self, at: .navigationItem(item: navigationItem))
    }
    
    @IBAction func contactItemTapped(_ sender: Any) {
        let meContact = MeContactViewController()
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
        
        let message = "确定清空聊天记录列表吗？清空后，你与好友的聊天记录将不可恢复"
        let vc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            self.messageController.viewModel.dataList.forEach {
                self.messageController.viewModel.remove($0)
            }
            self.intimateController.viewModel.dataList.forEach {
                self.intimateController.viewModel.remove($0)
            }
            self.parent?.tabBarItem.badgeValue = nil
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

extension ConversationViewController: ConversationListControllerDelegate {
    
    func conversationListController(_ conversationController: ConversationListController, didSelectConversation conversation: ConversationCell) {
        
        let convData = conversation.convData
        
        let vc: ChatViewController
        
        if !convData.groupID.isEmpty {
            vc = ChatTopicViewController(conversation: convData)!
        }
        else {
            vc = ChatViewController(conversation: convData)!
        }
        
        vc.title = convData.title
        navigationController?.pushViewController(vc, animated: true)
        
    }
}


extension ConversationViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    // MARK: PageboyViewControllerDataSource
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        viewConrollers.count // How many view controllers to display in the page view controller.
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        
        // View controller to display at a specific index for the page view controller.
        viewConrollers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        nil // Default page to display in the page view controller (nil equals default/first index).
    }
    
    // MARK: TMBarDataSource
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        
        return TMBarItem(title: titles[index]) // Item to display for a specific index in the bar.
    }
}

