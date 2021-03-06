//
//  VipBuyViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/6.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class VipBuyViewController: UIViewController {
    
    let onBuy = Delegate<Void, Void>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func buyButtonTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.onBuy.call()
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
