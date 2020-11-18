//
//  AuthenticationGuideViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/18.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class AuthenticationGuideViewController: UIViewController {
    
    let onPushing = Delegate<Void,  UINavigationController?>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func authenticationButtonTapped(_ sender: Any) {
        
        dismiss(animated: true) { [weak self] in
            self?.pushRealName()
        }
    }
    
    func pushRealName() {
        
        guard let navigationController = onPushing.call() else {
            return
        }
        
        if LoginManager.shared.user!.sex == .female  {
            let vc = AnchorAuthenticationViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = RealNameAuthenticationViewController.loadFromStoryboard()
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
}
