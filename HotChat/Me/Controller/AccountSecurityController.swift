//
//  AccountSecurityController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/6.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class AccountSecurityController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [FormSection] = []
    
    
    lazy var phoneBinding: RightDetailFormEntry = {
        let entry = RightDetailFormEntry(image: nil, text: "手机号绑定", detailText: "未绑定", onTapped: pushPhoneBinding)
        return entry
    }()
    
    
    lazy var unsubscribe: RightDetailFormEntry = {
        let entry = RightDetailFormEntry(image: nil, text: "账号注销", detailText: nil, onTapped: nil)
        return entry
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "账号安全"
        
        setupViews()
        setupSections()
    }

    
    func setupViews() {
        tableView.register(UINib(nibName: "RightDetailViewCell", bundle: nil), forCellReuseIdentifier: "UITableViewCell")
    }

    func setupSections() {
        sections = [
            FormSection(entries: [phoneBinding, unsubscribe], headerText: nil)
        ]
    }
    
    func pushPhoneBinding() {
        let vc = PhoneBindingController()
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension AccountSecurityController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if let rightDetail =  sections[indexPath.section].formEntries[indexPath.row] as? RightDetailFormEntry {
            rightDetail.onTapped?()
        }
    }
    
}

extension AccountSecurityController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return  50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].formEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
        
        return cell
    }
    
}
