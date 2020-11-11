//
//  PrivacyViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var locationForm : SwitchFormEntry {
        let entry = SwitchFormEntry(text: "隐藏我的地理位置", isOn: setting.isLocation)
        entry.onSwitchTrigger.delegate(on: self) { (self, isOn) in
            self.editSettings(type: 4, isOn: isOn)
        }
        return entry
    }
    
    
    lazy var blacklistForm: BasicFormEntry = {
        let entry = BasicFormEntry(text: "黑名单管理")
        entry.onTapped.delegate(on: self) { (self, _) in
            self.pushBlacklist()
        }
        return entry
    }()
    
    
    private var sections: [FormSection] = []
    
    let settingsAPI = Request<UserSettingsAPI>()
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    var setting: InfoSettings! {
        didSet {
            setupSections()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        refreshData()
    }
    
    
    func refreshData() {
        
        state = .refreshingContent
        settingsAPI.request(.infoSettings, type: Response<InfoSettings>.self)
            .checkResponse()
            .subscribe(onSuccess: { [weak self] response in
                self?.setting = response.data!
                self?.state = .contentLoaded
            }, onError: { [weak self] _ in
                self?.state = .error
            })
            .disposed(by: rx.disposeBag)
    }
    
    func pushBlacklist()  {
        let vc = BlacklistController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func editSettings(type: Int, isOn: Bool) {
        
        settingsAPI.request(.editSettings(type: type, value: isOn ? 1 : 0), type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }

    
    func setupViews() {
        
        title = "隐私"
        
        tableView.hiddenHeader()
        tableView.rowHeight = 50
        tableView.estimatedRowHeight = 0
        tableView.register(UINib(nibName: "BasicCell", bundle: nil), forCellReuseIdentifier: "UITableViewCell")
        tableView.register(UINib(nibName: "SwitchViewCell", bundle: nil), forCellReuseIdentifier: "SwitchViewCell")
    }
    
    func setupSections() {
        sections = [
            FormSection(entries: [locationForm], footerText: "隐藏位置后，你将错失与附近异性互动的机会！"),
            FormSection(entries: [blacklistForm]),
        ]
    }

}


extension PrivacyViewController: UITableViewDelegate {
    
    
}

extension PrivacyViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        return sections[section].footerText
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
