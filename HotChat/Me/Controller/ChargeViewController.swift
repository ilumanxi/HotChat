//
//  ChargeViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/14.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct ChargeInfo {
    var setting: InfoSettings
    var config: ChargeConfig
}

class ChargeViewController: UIViewController, LoadingStateType, IndicatorDisplay {
    
    
    var state: LoadingState = .initial {
        didSet {
            showOrHideIndicator(loadingState: state)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [FormSection] = []
    
    let settingsAPI = Request<UserSettingsAPI>()

    let userSettingsAPI = Request<UserSettingsAPI>()
    
    let authenticationAPI = Request<AuthenticationAPI>()
    
    var chargeInfo: ChargeInfo!{
        didSet {
            setupSections()
        }
    }
    
    let tableFooterView = ChargeFooterView.loadFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "价格设置"

        // Do any additional setup after loading the view.
        
        setupViews()
        refreshData()
        
        tableFooterView.onTapped.delegate(on: self) { (self, _) in
            self.pushLevel()
        }
    }
    
    @IBAction func pushLevel() {
        let vc = WebViewController.H5(path: "index/index/level")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func refreshData() {
        
        let infoSetting = requestSetting()
        let chargeConfig = requestChargeConfig()
        
        state = .refreshingContent
        Single.zip(infoSetting, chargeConfig) { (setting, config) -> ChargeInfo in
            return ChargeInfo(setting: setting.data!, config: config.data!)
        }
        .subscribe(onSuccess: { [weak self] response in
            self?.chargeInfo = response
            self?.state = .contentLoaded
            
        }, onError: { [weak self]  error in
            self?.state = .error
        })
        .disposed(by: rx.disposeBag)
        
    }
    
    func requestSetting() -> Single<Response<InfoSettings>> {
        return settingsAPI.request(.infoSettings).verifyResponse()
    }
    
    func requestChargeConfig() -> Single<Response<ChargeConfig>>{
        return userSettingsAPI.request(.chargeConfig).verifyResponse()
    }
    
    func setupViews() {
//        tableView.hiddenHeader()
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = UIColor(hexString: "#F6F7F9")
        tableView.register(UINib(nibName: "RightDetailViewCell", bundle: nil), forCellReuseIdentifier: "UITableViewCell")
        tableView.register(UINib(nibName: "SwitchViewCell", bundle: nil), forCellReuseIdentifier: "SwitchViewCell")
        
        tableFooterView.fittingSize()
        tableView.tableFooterView = tableFooterView
    }
    
    func editCharge(type: Int, item: ChargeConfigItem) {
        self.showIndicator()
        authenticationAPI.request(.editCharge(type: type, chargeId: item.chargeId), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [unowned self] response in
                self.hideIndicator()
                self .handle(response: response, type: type, item: item)
            }, onError: { [unowned self] error in
                self.hideIndicator()
                self.show(error)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    
    func handle(response: Response<[String : Any]>, type: Int, item: ChargeConfigItem)  {
        
        // resultCode：： 1320 等级不够 1321失败 1322成功
        
        guard let data = response.data,
              let resultCode = data["resultCode"] as? Int,
              let resultMsg = data["resultMsg"] as? String
        else {
            return
        }
        
        if resultCode ==  1322 { // 成功
            
            refreshData()
        }
        else if resultCode == 1320 {
            let vc = TipAlertController(title: "提示", message: resultMsg, leftButtonTitle: "", rightButtonTitle: "知道了")
            present(vc, animated: true, completion: nil)
            refreshData()
        }
        else {
            self.show(resultMsg)
        }
        
    }
    
    func setupSections()  {
        
        if chargeInfo == nil {
            return
        }
        
        let voiceSwitch = SwitchFormEntry(text: "语音接听开关", isOn: chargeInfo.setting.isVoice)
        voiceSwitch.onSwitchTrigger.delegate(on: self) { (self, isOn) in
            self.editSettings(type: 2, isOn: isOn)
        }
        let voicePriceText =  chargeInfo.config.voiceList
            .first { $0.isCheck }
            .map { "\($0.charge)能量/分钟"}
        
        let voicePrice =  RightDetailFormEntry(image: nil, text: "语音价格设置", detailText: voicePriceText ?? "1000能量/分钟", onTapped: { [unowned self] in
            self.picker(items: chargeInfo.config.voiceList, type: 2)
            
        })
        let voice = FormSection(
            entries: [voiceSwitch, voicePrice],
            headerText: nil
        )
        
        
        let videoSwitch = SwitchFormEntry(text: "视频接听开关", isOn: chargeInfo.setting.isLive)
        videoSwitch.onSwitchTrigger.delegate(on: self) { (self, isOn) in
            self.editSettings(type: 1, isOn: isOn)
        }
        
        let videoPriceText =  chargeInfo.config.videoList
            .first { $0.isCheck }
            .map { "\($0.charge)能量/分钟" }
        
        let videoPrice =  RightDetailFormEntry(image: nil, text: "视频价格设置", detailText: videoPriceText ?? "2500能量/分钟", onTapped: { [unowned self] in
            self.picker(items: chargeInfo.config.videoList, type: 1)
        })
        let video = FormSection(
            entries: [videoSwitch, videoPrice],
            headerText: nil
        )
        
        self.sections = [voice, video]
        
        tableView.reloadData()
    }
    
    /// 类型 1视频 2语音
    func editSettings(type: Int, isOn: Bool) {
       
        settingsAPI.request(.editSettings(type: type, value: isOn ? 1 : 0), type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func picker(items: [ChargeConfigItem], type: Int)  {
        
        let contents  = items.map { price($0)}
            
        let row = items.firstIndex { $0.isCheck } ?? 0
       
        
        let vc = PickerViewController(conents: contents, selectRow: row)
        
        vc.onPickered.delegate(on: self) { (self, content) in
             let item = items.first { self.price($0) == content  }!
             self.editCharge(type: type, item: item)
        }
        present(vc, animated: true, completion: nil)
    }
    
    func price(_ item: ChargeConfigItem) -> String {
        
        var string = "\(item.charge)能量/分钟"
        
        if LoginManager.shared.user!.girlRank < item.level {
            string.append("(魅力值达到\(item.level)级可选)")
        }
        return string
    }

}

extension ChargeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if let entity = self.sections[indexPath.section].formEntries[indexPath.row] as? RightDetailFormEntry {
            entity.onTapped?()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
}

extension ChargeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].formEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.sections[indexPath.section].formEntries[indexPath.row].cell(tableView, indexPath: indexPath)
    }
    
}
