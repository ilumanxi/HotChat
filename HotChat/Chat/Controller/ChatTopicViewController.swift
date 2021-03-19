//
//  ChatTopicViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ChatTopicViewController: ChatViewController, UIPopoverPresentationControllerDelegate {
    
    override var inputBarHeight: CGFloat {
        return 49
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupNavigationItem() {

        let memberItem = UIBarButtonItem(image: UIImage(named: "chat-member"), style: .plain, target: self, action: #selector(pushMember))
        navigationItem.rightBarButtonItems = [memberItem]
    }
    
    
    @objc
    func pushMember()  {
        
        let vc = ChatMemberContainerViewController(groupId: self.conversationData.groupID)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    let dynamicAPI = Request<DynamicAPI>()
    
    var disposeObject = DisposeBag()
    
    override func chatController(_ controller: ChatController!, onSelectMessageAvatar cell: TUIMessageCell!) {
        
        disposeObject = DisposeBag()
        
        let messageData = cell.messageData!
        
        userAPI.request(.checkFollow(userId: messageData.identifier), type: Response<[String : Any]>.self)
            .timeout(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                guard let isFollow = response.data?["isFollow"] as? Int else { return }
                
                var menus = ["@Ta", "资料", "关注", "举报"]
                
                if isFollow == 1 {
                    menus.remove(at: 2)
                }
                self?.presentChatTopicMenu(cell: cell, menus: menus, messageData: messageData)
                
            }, onError: { _ in
                
            })
            .disposed(by: disposeObject)
        
    }

    func follow(_ userId: String) {
        
        dynamicAPI.request(.follow(userId), type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func presentChatTopicMenu(cell: TUIMessageCell, menus: [String], messageData: TUIMessageCellData){
        
       
        let sourceView = cell.avatarView!
        
        let vc = ChatTopicMenuViewController(menus: menus)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = CGRect(x: 4, y: 0, width: sourceView.bounds.width, height: sourceView.bounds.height)
        vc.popoverPresentationController?.backgroundColor = .white
        vc.popoverPresentationController?.canOverlapSourceViewRect = false
        
        vc.ondSelected.delegate(on: self) { (self, index) in
            self.action(for: menus[index], messageData: cell.messageData)
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    
    func action(for title: String, messageData: TUIMessageCellData)  {
        switch title {
        case "@Ta":
            at(messageData)
        case "资料":
            let userID = messageData.identifier
            let user = User()
            user.userId = userID
            
            let vc  = UserInfoViewController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        case "关注":
            follow(messageData.identifier)
        case "举报":
            let vc = ChatTopicReportViewController()
            present(vc, animated: true, completion: nil)
        default:  break
        }
        
    }
    
    func at(_ messageData: TUIMessageCellData) {
        
        inputController.inputBar.inputTextView.insertText("@\( messageData.name) ")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


