//
//  ChatActionViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import UserNotifications

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

    
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = Row(rawValue: indexPath.row)!
        
        
        if row == .settings && !isShowSettings {
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
            let vc = RecommendViewController()
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
