//
//  VisitorsVipController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/2/1.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import Kingfisher

class VisitorsVipController: UIViewController {
    
    
    @IBOutlet var userButtons: [UIButton]!
    
    
    @IBOutlet weak var tipLabel: UILabel!
    
    
    @IBOutlet weak var tipButton: GradientButton!
    
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "我的访客"
        
        userButtons.forEach { $0.isHidden = true }
        
        let visitorList = user.visitorList.compactMap{ $0["headPic"] as? String }
        
        for (index, string) in visitorList.enumerated() {
            let button = userButtons[index]
            button.kf.setImage(with: URL(string: string), for: .normal)
            button.isHidden = false
        }
        
        tipButton.setTitle("+\(user.visitorNum)", for: .normal)
        
        let string = NSMutableAttributedString()
        
        string.append(NSAttributedString(string: "哇，有"))
        string.append(NSAttributedString(string: "\(user.visitorNum)", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hexString: "#FF403E")]))
        string.append(NSAttributedString(string: "人默默关注我，对我感兴趣"))
        tipLabel.attributedText = string
        
        NotificationCenter.default.rx.notification(.userDidChange)
            .subscribe(onNext: { [weak self] notification in
                self?.handle(notification)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func handle(_ notification: Notification) {
        
        let user = LoginManager.shared.user!
        
        if user.vipType != .empty {
            
            var viewControllers = navigationController?.viewControllers ?? []
            
            let index = viewControllers.firstIndex(of: self)!
            
            let vc = VisitorsController()
            vc.hidesTabBarWhenPushed = true
            
            viewControllers[index] = vc
            
            navigationController?.setViewControllers(viewControllers, animated: false)
        }
        
    }
    
    @IBAction func vipButonTapped(_ sender: Any) {
        
        let vc = WebViewController.H5(path: "h5/vip")
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
}
