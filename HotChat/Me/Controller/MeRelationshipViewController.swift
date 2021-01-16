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

class MeRelationshipViewController: UITableViewController, SegementSlideContentScrollViewDelegate, IndicatorDisplay, LoadingStateType {
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
        
    @objc
    var scrollView: UIScrollView {
        return tableView
    }
    
    var relationship: Relationship!
    
    let API = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()
    
    
    var users: [User] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 70
        tableView.register(cellType: RelationshipViewCell.self)
        refreshData()
    }
    
    
    func refreshData() {
        state = (state == .initial) ? .loadingContent : .refreshingContent
        API.request(.followList(type: relationship.rawValue), type: Response<[User]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.users = response.data ?? []
                self.state = self.users.isEmpty ? .noContent : .contentLoaded
                
            }, onError: { [weak self] error in
                self?.state = .error
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
        cell.sexView.setSex(user)
        cell.introduceLabel.text = user.introduce
        cell.followButton.isHidden = user.isFollow
        
        cell.onFollowButtonTapped.delegate(on: self) { (self, _) in
            self.follow(user: user)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let user = users[indexPath.row]
        
        let vc = UserInfoViewController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func follow(user: User) {
        
        if let index = users.firstIndex(where: { $0.userId == user.userId }) {
            users.modifyElement(at: index) { user in
                user.isFollow = !user.isFollow
            }
            tableView.reloadData()
        }
        
        dynamicAPI.request(.follow(user.userId), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }

}
