//
//  VisitorsVipController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/2/1.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class VisitorsVipController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        super.modalPresentationStyle = .overFullScreen
        super.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    let onVIPTapped = Delegate<Void, Void>()
    
    
    @IBAction func vipButonTapped(_ sender: Any) {
        
        onVIPTapped.call()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
