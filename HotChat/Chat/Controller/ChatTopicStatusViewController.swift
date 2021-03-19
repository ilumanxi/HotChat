//
//  ChatTopicStatusViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/19.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit



extension ChatTopicStatusViewController.Status {
    
    var backgroundImage: UIImage? {
        switch self {
        case .crowd:
            return UIImage(named: "chat-crowd")
        case .full:
            return UIImage(named: "chat-full")
        default:
            return nil
        }
    }
    
    var text: String? {
        switch self {
        case .crowd:
            return "当前房间拥挤，开通会员特权\n立即进入"
        case .full:
            return "很遗憾，房间人数已满!"
        default:
            return nil
        }
    }
    
    var cancelButtonHidden: Bool {
        return self != .crowd
    }
    
    var doneButtonTitle: String? {
        switch self {
        case .crowd:
            return "开通"
        case .full:
            return "好的"
        default:
            return nil
        }
    }
}

class ChatTopicStatusViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    let buyVip = Delegate<Void, Void>()
    
    
    enum Status: Int {
        /// 正常
        case normal
        /// 拥挤
        case crowd = 1101
        /// 爆满
        case full = 1100
    }
    
    let status: Status
    init(status: Status) {
        self.status = status
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    
    func setupViews()  {
        
        imageView.image = status.backgroundImage
        contentLabel.text = status.text
        cancelButton.isHidden = status.cancelButtonHidden
        doneButton.setTitle(status.doneButtonTitle, for: .normal)
        
    }

    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTApped(_ sender: Any) {
        
        dismiss(animated: true) {
            if self.status == .crowd {
                self.buyVip.call()
            }
        }
    }
}
