//
//  GuidedRechargeViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class GuidedRechargeViewController: UIViewController {
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        super.modalTransitionStyle = .crossDissolve
        super.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func vipButtonTapped(_ sender: Any) {
        dismiss(animated: false) {
            self.pushVip()
        }
    }
    
    
    func showNavigationController() -> UINavigationController? {
        
        guard let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController, let navigationController = tabBarController.selectedViewController as? UINavigationController else {
            return nil
        }
        
        return navigationController
    }
    
    @IBAction func rechargeButtonTapped(_ sender: Any) {
        dismiss(animated: false) {
            self.pushWallet()
        }
    }
    
    func pushVip() {
        
        let vc = WebViewController.H5(path: "h5/vip")
        showNavigationController()?.pushViewController(vc, animated: true)
    }
    
    
    func pushWallet()  {
        let vc = WalletViewController()
        showNavigationController()?.pushViewController(vc, animated: true)
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if touches.first?.view == view {
            dismiss(animated: true, completion: nil)
        }
        
    }

}
