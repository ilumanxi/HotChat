//
//  ResetPasswordViewController.swift
//  HotChat
//
//  Created by 谭帆帆 on 2020/9/24.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

extension Notification.Name {
    
    static let userDidResetPassword = NSNotification.Name("com.friday.Chat.userDidResetPassword")
    
    
}

class ResetPasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems = nil

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        NotificationCenter.default.post(name: .userDidResetPassword, object: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
