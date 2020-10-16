//
//  VideoCallViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/10/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class VideoCallViewController: UIViewController {
    
    typealias DismissAction = () -> Void
    
    let sponsor: CallUserModel?
    
    let invited: CallUserModel
    
    let dismissAction:  DismissAction
    
    required init(sponsor: CallUserModel?, invited: CallUserModel, dismissAction: @escaping DismissAction) {
        self.sponsor = sponsor
        self.invited = invited
        self.dismissAction = dismissAction
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///  有用户进入
    func enter(_ user: CallUserModel) {
        
    }
    
    ///  通话用户状态更新
    func update(_ user: CallUserModel, animate: Bool){
        
    }
    
    ///  有用户离开通话
    func leave(_ user: CallUserModel) {
        
    }
    
    func getUser(_ userId: String) -> CallUserModel? {
        
        return invited.userId == userId ? invited : nil
    }
    
    func dismiss() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    



}
