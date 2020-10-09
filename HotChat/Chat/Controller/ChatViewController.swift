//
//  ChatViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import TXIMSDK_TUIKit_iOS
import SPAlertController

class ChatViewController: TUIChatController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem()

    }
    
    
    func setupNavigationItem() {
        
        let setting = UIBarButtonItem(image: UIImage(named: "chat-setting"), style: .plain, target: self, action: #selector(userSetting))
        
        let call = UIBarButtonItem(image: UIImage(named: "chat-call"), style: .plain, target: self, action: #selector(chatCall))
        
        navigationItem.rightBarButtonItems = [setting, call]
        
    }
    
    
    @objc func userSetting() {
        
    }
    
    @objc func chatCall() {
        chatCallAlert()
    }
    
    private func chatCallAlert() {
        
        let alertController = SPAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
 
        
        let video = SPAlertAction(title: nil, style: .default) { _ in
            
        }
        video.attributedTitle = attributedText(text: "视频聊", detailText: "(2500能量/分钟)")
        alertController.addAction(video)
        
        let audio = SPAlertAction(title: nil, style: .default) { _ in
            
        }
        audio.attributedTitle = attributedText(text: "语音聊", detailText: "(2500能量/分钟)")
        alertController.addAction(audio)
        
        alertController.addAction(SPAlertAction(title: "取消", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
 
    }
    
    func attributedText(text: String, detailText: String) -> NSAttributedString {
        
        let string = "\(text)\(detailText)" as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttributes([.foregroundColor: UIColor.textBlack, .font : UIFont.systemFont(ofSize: 14)], range: string.range(of: text))
        attributedString.addAttributes([.foregroundColor: UIColor.textBlack, .font : UIFont.systemFont(ofSize: 12)], range: string.range(of: detailText))
        return attributedString
    }
    

}
