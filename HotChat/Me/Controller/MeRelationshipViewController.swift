//
//  MeRelationshipViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class MeRelationshipViewController: UITableViewController, IndicatorDisplay, LoadingStateType {
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                if state == .noContent {
                    
                    if relationship == Relationship.follow {
                        showOrHideIndicator(loadingState: state, text: "还没有关注别人，\n你都不主动我们怎么会有故事", image: UIImage(named: "me-relationship"), actionText: "前往发现")
                    }
                    else {
                        showOrHideIndicator(loadingState: state, text: "还没有粉丝，\n也许发条动态就好了", image: UIImage(named: "me-relationship"), actionText: "前往发动态")
                    }
                }
                else {
                    showOrHideIndicator(loadingState: state)
                }
            }
        }
    }
    
    init(relationship: Relationship) {
        self.relationship = relationship
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let relationship: Relationship
    
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
        tableView.register(UINib(nibName: "RelationshipViewCell", bundle: nil), forCellReuseIdentifier: "RelationshipViewCell")
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
        cell.sexView.set(user)
        cell.introduceLabel.text = user.introduce
        cell.followButton.isHidden = user.isFollow
        cell.gradeView.setGrade(user)
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
    
    let authenticationAPI = Request<AuthenticationAPI>()
    
    func checkUserAttestation() {
        showIndicator()
        authenticationAPI.request(.checkUserAttestation, type: Response<Authentication>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.hideIndicator()
                if response.data!.realNameStatus.isPresent {
                    let user = LoginManager.shared.user!
                    user.realNameStatus = response.data!.realNameStatus
                    LoginManager.shared.update(user: user)
                    self.presentDynamic()
                }
                else {
                    let vc = AuthenticationGuideViewController()
                    vc.onPushing.delegate(on: self) { (self, _) -> UINavigationController? in
                        return self.navigationController
                    }
                    self.present(vc, animated: true, completion: nil)
                }
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error)
            })
            .disposed(by: rx.disposeBag)
    }
    
    
    
    func presentDynamic() {
        let vc = DynamicViewController()
        vc.onSened.delegate(on: self) { (self, _) in
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }

    func actionTapped() {
        
        if relationship == Relationship.follow {
            
            self.navigationController?.popToRootViewController(animated: false)
            if let tabBarController =  UIApplication.shared.keyWindow?.rootViewController as? UITabBarController  {
                tabBarController.selectedIndex = 1
            }
        }
        else {
            checkUserAttestation()
        }
    }
}
