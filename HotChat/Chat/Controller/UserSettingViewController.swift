//
//  UserSettingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/21.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import SPAlertController

class UserFormEntry: NSObject,FormEntry {
    
    let user: User
    
    let onTapped = Delegate<Void, Void>()
    
    init(user: User) {
        self.user = user
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserViewCell.self)
        render(cell)
        return cell
    }
    @objc func tapped()  {
        onTapped.call()
    }
    
    private func render(_ cell: UserViewCell) {
        cell.avatarImageView.kf.setImage(with: URL(string: user.headPic))
        cell.nicknameLabel.text = user.friendNick.isEmpty ? user.nick : user.friendNick
        cell.userView.setUser(user)
        cell.followView.text = user.userFollowNum.description
        cell.locationLabel.text = user.region
        cell.statusLabel.text = user.onlineStatus.text
        cell.statusLabel.textColor = user.onlineStatus.color
        
        if !(cell.contentView.gestureRecognizers?.contains{ $0 is UITapGestureRecognizer } ?? false) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            cell.contentView.addGestureRecognizer(tap)
        }
    }
    
}

class BasicFormEntry: NSObject, FormEntry {

    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    let onTapped = Delegate<Void, Void>()
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UITableViewCell.self)
        cell.textLabel?.text = text
        
        if !(cell.contentView.gestureRecognizers?.contains{ $0 is UITapGestureRecognizer } ?? false) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            cell.contentView.addGestureRecognizer(tap)
        }
        return cell
    }
    
    @objc func tapped()  {
        onTapped.call()
    }
}

class SwitchFormEntry: NSObject, FormEntry {
    
    let text: String
    let isOn: Bool
    init(text: String, isOn: Bool) {
        self.text = text
        self.isOn = isOn
    }
    
    let onSwitchTrigger = Delegate<Bool, Void>()
    

    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SwitchViewCell.self)
        render(cell)
        return cell
    }
    
//    var disposeBag: DisposeBag?
    
    private func render(_ cell: SwitchViewCell) {
        cell.titleLabel.text = text
        cell.switch.isOn = isOn
       
        
        for target in cell.switch.allTargets {
            cell.switch.removeTarget(target, action: #selector(switchTrigger), for: .valueChanged)
        }
        
        cell.switch.addTarget(self, action: #selector(switchTrigger), for: .valueChanged)
    }
    
    @objc func switchTrigger(_ sender: UISwitch) {
        onSwitchTrigger.call(sender.isOn)
    }
}

class DestructiveFormEntry: NSObject, FormEntry {
    
    let text: String
    let onTapped = Delegate<Void, Void>()
    init(text: String) {
        self.text = text
    }
    
    func cell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: DestructiveViewCell.self)
        if !(cell.contentView.gestureRecognizers?.contains{ $0 is UITapGestureRecognizer } ?? false) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
            cell.contentView.addGestureRecognizer(tap)
        }
        return cell
    }
    
    @objc func tapped()  {
        onTapped.call()
    }
}


class UserSettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoadingStateType, IndicatorDisplay , StoryboardCreate {
    
    
    static var storyboardNamed: String { return "Chat" }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    
    var user: User! {
        didSet {
            if isViewLoaded {
                setupSections()
                tableView.reloadData()
            }
        }
    }
    
    
    var userForm: FormEntry {
        let entry = UserFormEntry(user: user)
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushUser()
        }
        return entry
    }
    
    var remarksForm: FormEntry {
        
        let entry = BasicFormEntry(text: "备注名")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushRemark()
            self.tableView.reloadData()
        }
        
        return entry
    }
    
    var topForm: FormEntry {
        
        let userId = "c2c_\(user.userId)"
        
        let topConversationList = TUILocalStorage.sharedInstance().topConversationList().compactMap{ $0 as? String }
        
        let isTop = topConversationList.contains(userId)
        
        let entry = SwitchFormEntry(text: "置顶聊天", isOn: isTop)
        entry.onSwitchTrigger.delegate(on: self) { (self, isOn) in
            if isOn {
                TUILocalStorage.sharedInstance().addTopConversation(userId)
            }
            else {
                TUILocalStorage.sharedInstance().removeTopConversation(userId)
            }
        }
        return entry
    }
    
    var followForm: FormEntry {
        let entry = SwitchFormEntry(text: "关注", isOn: user.isFollow)
        
        entry.onSwitchTrigger.delegate(on: self) { (self, isOn) in
            self.user.isFollow = isOn
            self.dynamicAPI.request(.follow(self.user.userId), type: ResponseEmpty.self)
                .subscribe(onSuccess: nil, onError: nil)
                .disposed(by: self.rx.disposeBag)
        }
        
        return entry
    }
    
    var defriendForm: FormEntry {
        let entry = SwitchFormEntry(text: "拉黑", isOn: user.isDefriend)
        
        entry.onSwitchTrigger.delegate(on: self) { (self, isOn) in
            self.user.isDefriend = isOn
            self.userAPI.request(.editDefriend(userId: self.user.userId), type: ResponseEmpty.self)
                .subscribe(onSuccess: nil, onError: nil)
                .disposed(by: self.rx.disposeBag)
        }
        
        return entry
    }
    
    
    
    var reportForm: FormEntry {
        let entry = BasicFormEntry(text: "举报")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushReport()
        }
        return entry
    }
    
    var destructiveForm: FormEntry {
        let entry = DestructiveFormEntry(text: "清空聊天记录")
        entry.onTapped.delegate(on: self) { (self, _) in
            
            let alert =  SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(SPAlertAction(title: "清空聊天记录", style: .destructive, handler: { [weak self] _ in
                self?.clearChatRecords()
            }))
            alert.addAction(SPAlertAction(title: "取消", style: .cancel, handler: { _ in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        return entry
        
    }
    
    
    private var sections: [FormSection] = []
    
    let userAPI = Request<UserAPI>()
    
    let dynamicAPI = Request<DynamicAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .groupTableViewBackground
        tableView.hiddenHeader()
        // Do any additional setup after loading the view.
        setupSections()
        refreshData()
    }
    
    func pushRemark() {
        let vc = RemarkViewController.loadFromStoryboard()
        vc.text = user.friendNick.isEmpty ? user.nick : user.friendNick
        vc.onSaved.delegate(on: self) { (self, text) in
            self.remark(text)
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushUser() {
        let vc  = UserInfoViewController()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushReport()  {
        let vc = ReportUserViewController.loadFromStoryboard()
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func clearChatRecords() {
        let conversationID = "c2c_\(user.userId)"
        V2TIMManager.sharedInstance()?.deleteConversation(conversationID, succ: nil, fail: nil)
    }
    
    func remark(_ text: String) {
        user.friendNick = text
        userAPI.request(.remark(friendNick: text, userId: user.userId), type: ResponseEmpty.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] _ in
                let friend = V2TIMFriendInfo()
                friend.userID = self?.user.userId
                friend.friendRemark = text
                
                V2TIMManager.sharedInstance()?.setFriendInfo(friend, succ: {
                    
                }, fail: { (_, _) in
                    
                })
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func setupSections() {
        
        sections = [
            FormSection(entries: [userForm], headerText: nil),
            FormSection(entries: [remarksForm], headerText: nil),
            FormSection(entries: [topForm], headerText: nil),
            FormSection(entries: [followForm, defriendForm, reportForm], headerText: nil),
//            FormSection(entries: [destructiveForm], headerText: nil)
        ]
        
    }
    
    func refreshData() {
        state = (state == .initial) ? .loadingContent : .refreshingContent
        userAPI.request(.userinfo(userId: user.userId), type: Response<User>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.user = response.data
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].formEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }

}
