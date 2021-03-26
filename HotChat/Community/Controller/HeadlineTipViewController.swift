//
//  HeadlineTipViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class HeadlineTipViewController: UIViewController {
    
    enum Status {
        case recharge
        case violation
    }
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
    
    @IBOutlet weak var leftButton: UIButton!
    
    
    @IBOutlet weak var rightButton: GradientButton!
    
    let onRecharge = Delegate<Void, Void>()
    
    let text: String
    let status: Status
    
    init(text: String, status: Status) {
        self.text = text
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
        
        self.infoLabel.text = text
        
        self.leftButton.isHidden = status == .violation
        let title  = status == .violation ? "知道了" : "去充值"
        
        self.rightButton.setTitle(title, for: .normal)
    }


    @IBAction func leftButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        
        dismiss(animated: true) { [unowned self] in
            
            if status == .recharge {
                self.onRecharge.call()
            }
        }
    }
    
}
