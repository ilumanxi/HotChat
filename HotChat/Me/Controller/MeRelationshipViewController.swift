//
//  MeRelationshipViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SegementSlide
import Kingfisher

class MeRelationshipViewController: UITableViewController, SegementSlideContentScrollViewDelegate, Wireframe {
        
    @objc
    var scrollView: UIScrollView {
        return tableView
    }
    
    var relationship: Relationship!
    
    let API = RequestAPI<UserAPI>()
    
    
    var users: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 70
        tableView.register(cellType: RelationshipViewCell.self)
        
        API.request(.followList(type: relationship.rawValue), type: HotChatResponse<[User]>.self)
            .subscribe(onSuccess: { [weak self] response in
                if response.isSuccessd {
                    self?.users = response.data ?? []
                }
                
            }, onError: { [weak self] error in
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = users[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: RelationshipViewCell.self)
        cell.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        cell.nicknameLabel.text = user.nick
        cell.sexView.setUser(user)
        cell.introduceLabel.text = user.introduce
        
        return cell
    }

}
