//
//  PushSettingsViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PushSettingsViewController: UITableViewController, LoadingStateType, IndicatorDisplay, StoryboardCreate {
    
    
    static var storyboardNamed: String { return "Me" }
    
    
    enum Section: Int {
        case invitation
        case notDisturb
        
        var title: String? {
            switch self {
            case .notDisturb:
                return "开启后，每天23:00~8:00，收到语音/视频邀请，都不会响铃提醒。"
            default:
                return nil
            }
        }
    }
    
    
    @IBOutlet weak var videoSwitch: UISwitch!
    
    @IBOutlet weak var voiceSwitch: UISwitch!
    
    
    
    @IBOutlet weak var disturbSwitch: UISwitch!
    
    var setting: InfoSettings! {
        didSet {
            reloadData()
        }
    }
    
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    let settingsAPI = Request<UserSettingsAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshData()

    }
    
    
    func reloadData() {
        
        videoSwitch.isOn = setting.isLive
        voiceSwitch.isOn = setting.isVoice
        disturbSwitch.isOn = setting.isDisturb
        tableView.reloadData()
        
    }
    
    
    @IBAction func videoSwitchChanged(_ sender: UISwitch) {
        editSettings(type: 1, isOn: sender.isOn)
    }
    
    @IBAction func voiceSwitchChanged(_ sender: UISwitch) {
        editSettings(type: 2, isOn: sender.isOn)
    }
    
    
    @IBAction func disturbSwitchChanged(_ sender: UISwitch) {
        editSettings(type: 3, isOn: sender.isOn)
    }
    
    
    func editSettings(type: Int, isOn: Bool) {
        
        settingsAPI.request(.editSettings(type: type, value: isOn ? 1 : 0), type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ =  setting {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
     
        return 0
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if  setting == nil {
            return nil
        }
        
        let title = Section(rawValue: section)?.title
        return title
    }
    
}
