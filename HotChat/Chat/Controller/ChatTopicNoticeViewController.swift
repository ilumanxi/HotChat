//
//  ChatTopicNoticeViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class ChatTopicNoticeViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    let noticeTitle: String
    let noticeContent: String
    
    init(noticeTitle: String, noticeContent: String) {
        self.noticeTitle = noticeTitle
        self.noticeContent = noticeContent
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = noticeTitle
        contentLabel.text = noticeContent
        

        // Do any additional setup after loading the view.
    }


    @IBAction func doneButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    

}
