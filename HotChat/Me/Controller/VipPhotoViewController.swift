//
//  VipPhotoViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/7.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class VipPhotoViewController: UIViewController {
    
    let onVIP = Delegate<Void, Void>()
    
    
    init() {
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
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func vipButtonTapped(_ sender: Any) {
        
        dismiss(animated: false) {
            self.onVIP.call()
        }
    }
}
