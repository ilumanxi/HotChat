//
//  BaseNavigationController.swift
//  TodayNews
//
//  Created by 风起兮 on 2019/5/15.
//  Copyright © 2019 hrscy. All rights reserved.
//

import UIKit
import HBDNavigationBar


var hidesTabBarWhenPushedKey = "hidesTabBarWhenPushedKey"

extension UIViewController {
    
    var hidesTabBarWhenPushed: Bool {
        get {
            guard let hides = objc_getAssociatedObject(self, &hidesTabBarWhenPushedKey) as? Bool else {
                return true
            }
            return hides
        }
        set {
            objc_setAssociatedObject(self, &hidesTabBarWhenPushedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc var backBarButtonImage: UIImage? {
         return UIImage(named: "navigation-bar-back")
    }
    
}

class BaseNavigationController: HBDNavigationController {

    /// Custom back buttons disable the interactive pop animation
    /// To enable it back we set the recognizer to `self`

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers.forEach {
            let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            $0.navigationItem.backBarButtonItem = backBarButtton
        }
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        
        viewController.hidesBottomBarWhenPushed =  viewControllers.count > 0 ? viewController.hidesTabBarWhenPushed : false
        
        // Provide an empty backBarButton to hide the 'Back' text present by default in the back button.
        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = backBarButtton
        
        /// hidden NavigationBar back text
        //        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //        viewController.navigationItem.backBarButtonItem = backBarButtton
        
//        if viewControllers.count > 0 && viewController.navigationItem.leftBarButtonItems == nil {
//
//            let backButton = BackButton(type: .custom)
//            backButton.addTarget(self, action:  #selector(pop), for: .touchUpInside)
//            backButton.setImage(viewController.backBarButtonImage, for: .normal)
//            let backBarButtton = UIBarButtonItem(customView: backButton)
//            viewController.navigationItem.leftBarButtonItem = backBarButtton
//        }
        
        if let tableViewController = viewController as? UITableViewController, tableViewController.tableView.style == .grouped {
            tableViewController.tableView.hiddenHeader()
        }

        super.pushViewController(viewController, animated: true)
    }

   @objc fileprivate func pop() {
        _ = popViewController(animated: true)
    }
}
