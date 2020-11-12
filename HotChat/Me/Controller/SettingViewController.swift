//
//  SettingViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController, StoryboardCreate, IndicatorDisplay {
    
    static var storyboardNamed: String { return "Me" }
    
    let API = Request<AccountAPI>()
    
    lazy var accountSecurity: FormEntry = {
        let entry = BasicFormEntry(text: "账户安全")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushAccountSecurity()
        }
        return entry
    }()
    
    lazy var antiHarassment: FormEntry = {
        let entry = BasicFormEntry(text: "防骚扰")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushNotification()
        }
        return entry
    }()
    
    
    
    lazy var privacy: FormEntry = {
        let entry = BasicFormEntry(text: "隐私")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushPrivacy()
        }
        return entry
    }()
    
    lazy var nobleSetting: FormEntry = {
        let entry = BasicFormEntry(text: "会员设置")
        entry.onTapped.delegate(on: self) { (self, _) in
        }
        return entry
    }()
    
    lazy var general: FormEntry = {
        let entry = BasicFormEntry(text: "通用")
        entry.onTapped.delegate(on: self) { (self, _) in
        }
        return entry
    }()
    
    lazy var protection: FormEntry = {
        let entry = BasicFormEntry(text: "未成年人保护工具")
        entry.onTapped.delegate(on: self) { (self, _) in
        }
        return entry
    }()
    
    lazy var invite: FormEntry = {
        let entry = BasicFormEntry(text: "邀请人信息")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushInvite()
        }
        return entry
    }()
    
    lazy var logout: FormEntry = {
        let entry = DestructiveFormEntry(text: "退出登录")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.userLogout()
        }
        return entry
    }()
    
    
    private var sections: [FormSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSections()
        
    }
    
    
    func setupSections() {
        
        sections = [
            FormSection(
                entries: [
                    accountSecurity,
                    antiHarassment,
                    privacy,
//                    nobleSetting,
//                    general,
//                    protection,
                    invite
                ],
                headerText: nil
            ),
            FormSection(entries: [logout], headerText: nil)
        ]
        
    }
    
    func pushPrivacy()  {
        let vc = PrivacyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushAccountSecurity() {
        let vc = AccountSecurityController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushInvite() {
        
        let vc = InviteViewController.loadFromStoryboard()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushNotification () {
        let vc = PushSettingsViewController.loadFromStoryboard()
        navigationController?.pushViewController(vc, animated: true)
    }
    

    func userLogout() {
        showIndicator()
        API.request(.logout, type: ResponseEmpty.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.hideIndicator()
            }, onError: { [weak self] error in
                self?.hideIndicator()
                self?.show(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
  
}


extension SettingViewController {
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].formEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }
}
