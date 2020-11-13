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
            return "审核通过"
        case .failed:
            return "审核失败"
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
    
    let API = Request<UserAPI>()
    
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
        
        let section = FormSection(
            entries: [
                RightDetailFormEntry(image: nil, text: "实名认证", detailText: authentication.certificationStatus.description, onTapped: pushRealName),
                RightDetailFormEntry(image: nil, text: "头像认证", detailText: authentication.certificationStatus.description, onTapped: pushFace)
            ],
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
        API.request(.userAttestationInfo, type: Response<Authentication>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.authentication = response.data
                self?.state = .contentLoaded
            }, onError: { [weak self] error in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }


    
    func pushRealName() {
        
        if !authentication.certificationStatus.isPush {
            return
        }
        
        if LoginManager.shared.user!.sex! == .female  {
            let vc = AnchorAuthenticationViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = RealNameAuthenticationViewController.loadFromStoryboard()
            vc.authentication = authentication
            
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
    func pushFace() {
        if !authentication.certificationStatus.isPush {
            return
        }
       let vc = BDFaceDetectionViewController()
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
