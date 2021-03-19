//
//  ChatTopicViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class ChatTopicViewController: ChatViewController {

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

}
