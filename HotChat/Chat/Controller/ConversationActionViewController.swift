//
//  ChatActionViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import UserNotifications
import PPBadgeViewSwift

class ConversationActionViewController: UITableViewController, StoryboardCreate {
    
    enum Row: Int, CaseIterable  {
        case settings
        case recommend
        case topic
        case interested
    }
    
    static var storyboardNamed: String { return "Chat" }
    
    var contentHeight: CGFloat {
        
        var height =  Row.allCases
            .compactMap{ $0.height }
            .reduce(0, +)
        
        if !isShowSettings {
            height -= Row.settings.height
        }
        
        if !LoginManager.shared.user!.girlStatus {
            height -= Row.recommend.height
        }
        
        if AppAudit.share.groupChatStatus {
            height -= Row.topic.height
        }
        
        height -= Row.interested.height
        
        return height
    }
    
    var isShowSettings: Bool {
        
        return  !(isOperationed || isAuthorization)
    }
    
    
    let onContentHeightUpaded = Delegate<ConversationActionViewController, Void>()
    
    private let key = "isOperationed"
    
    var isOperationed: Bool {
        get {
            return UserDefaults.standard.bool(forKey: key)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    
    private var isAuthorization: Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var authorization: Bool = false
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                authorization = true
            default:
                authorization = false
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return authorization
        
    }

    
    @IBOutlet weak var interestedImageView: UIImageView!
    
    
//    let API = Request<MessageAPI>()

    override func viewDidLoad() {
        super.viewDidLoad()
//        interestedImageView.pp.badgeView.font = .systemFont(ofSize: 12)
//        interestedImageView.pp.setBadge(height: 18.5)
//        interestedImageView.pp.moveBadge(x: -9, y: 9)
//        interestedImageView.pp.hiddenBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        appAudit()
        
//        API.request(.countPeople, type: Response<[String : Any]>.self)
//            .verifyResponse()
//            .subscribe(onSuccess: { [weak self] response in
//
//                if let count = response.data?["count"] as? Int {
//                    if count > 99 {
//                        self?.interestedImageView.pp.addBadge(text: "99+")
//                    }
//                    else {
//                        self?.interestedImageView.pp.addBadge(text: count.description)
//                    }
//                    if count > 0 {
//                        self?.interestedImageView.pp.showBadge()
//                    }
//                    else {
//                        self?.interestedImageView.pp.hiddenBadge()
//                    }
//                }
//
//            }, onError: nil)
//            .disposed(by: rx.disposeBag)
    }
    
    let userSettingsAPI = Request<UserSettingsAPI>()
    func appAudit() {
        userSettingsAPI.request(.appAudit, type: Response<AppAudit>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] respoonse in
                if let data = respoonse.data, let self = self {
                    AppAudit.share = data
                    self.tableView.reloadData()
                    self.onContentHeightUpaded.call(self)
                }
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = Row(rawValue: indexPath.row)!
        
        
        if row == .settings && !isShowSettings {
            return 0
        }
        
        if row == .recommend && !LoginManager.shared.user!.girlStatus {
            return 0
        }
        
        if row == .topic && AppAudit.share.groupChatStatus {
            return 0
        }
        
        if row == .interested {
            return 0
        }
        
        return row.height
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch Row(rawValue: indexPath.row) {
        case .topic:
            let vc = TopicListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .recommend:
            let vc = RecommendContainerController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
        
    }
    
    
    @IBAction func settingButtonTapped(_ sender: Any) {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        isOperationed = true
        tableView.reloadData()
        onContentHeightUpaded.call(self)
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        isOperationed = true
        tableView.reloadData()
        onContentHeightUpaded.call(self)
    }
    
}


extension ConversationActionViewController.Row {
    
    var height: CGFloat {
        switch self {
        case .settings:
            return 112
        case .interested:
            return 80
        case .topic:
            return 80
        case .recommend:
            return 80
        }
    }
}
