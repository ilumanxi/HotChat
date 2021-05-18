//
//  AuthenticationViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit


extension ValidationStatus: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .empty:
            return "未认证"
        case .validating:
            return "审核中"
        case .ok:
            return "已审核"
        case .failed:
            return "未通过"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .ok:
            return UIColor(hexString: "#17A463")
        default:
            return UIColor(hexString: "#999999")
        }
    }
    
    
    var isPush: Bool {
        switch self {
        case .empty, .failed:
            return true
        default:
            return false
        }
    }
    
}


class AuthenticationViewController: UIViewController, IndicatorDisplay, LoadingStateType {
    
    
    var state: LoadingState = .initial {
        didSet {
            if isViewLoaded {
                showOrHideIndicator(loadingState: state)
            }
        }
    }
    
    let API = Request<AuthenticationAPI>()
    
    var authentication: Authentication! {
        didSet {
            setupSections()
        }
    }
    
    var tableView: UITableView!
    
    private var sections: [FormSection] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的认证"
        setupUI()
    }
    
    func setupUI() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "RightDetailViewCell", bundle: nil), forCellReuseIdentifier: "UITableViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
    }
    
    func setupSections()  {

        
        var entries =  [
            RightDetailFormEntry(image: nil, text: "实名认证", detailText: authentication.realNameStatus.description, onTapped: { [weak self] in self?.pushRealName()}),
            RightDetailFormEntry(image: nil, text: "头像认证", detailText: authentication.headStatus.description, onTapped: {[weak self] in self?.pushFace()})
        ]
        
        if LoginManager.shared.user!.girlStatus {
            entries.append( RightDetailFormEntry(image: nil, text: "联系方式", detailText: authentication.contactStatus.description, onTapped: {[weak self] in self?.pushAddressBook()}))
        }
        
        let section = FormSection(
            entries: entries,
            headerText: nil
        )
        
        self.sections = [section]
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func refreshData() {
        state = .refreshingContent
        API.request(.checkUserAttestation, type: Response<Authentication>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.authentication = response.data
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }


    
    func pushRealName() {
        
        if !authentication.realNameStatus.isPush {
            return
        }
        
        if LoginManager.shared.user!.sex == .female  {
            let vc = AnchorAuthenticationViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = RealNameAuthenticationViewController.loadFromStoryboard()
            navigationController?.pushViewController(vc, animated: true)
        }

        
    }
    
    func pushAddressBook() {
        let vc = AddressBookAuthenticationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushFace() {
        if !authentication.headStatus.isPush {
            return
        }
        

       let vc = HeadViewController()
        
       navigationController?.pushViewController(vc, animated: true)
    }

}

extension AuthenticationViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if let rightDetail =  sections[indexPath.section].formEntries[indexPath.row] as? RightDetailFormEntry {
            rightDetail.onTapped?()
        }
    }
    
    
}


extension AuthenticationViewController: UITableViewDataSource {
    
    
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
