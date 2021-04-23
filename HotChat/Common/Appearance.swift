//
//  Appearance.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/9.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

class Appearance {
    
    private init() {}
    

    static let `default` = Appearance()
    
    func configure() {
        
        let backButtonBackgroundImage = UIImage(named: "navigation-bar-back")
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.backIndicatorImage = backButtonBackgroundImage
        navigationBarAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        navigationBarAppearance.barTintColor = .white
        navigationBarAppearance.tintColor = UIColor(hexString: "#333333")
        navigationBarAppearance.titleTextAttributes = [
            .font : UIFont.navigationBarTitle,
            .foregroundColor : UIColor.titleBlack]
        
        let barButtonAppearance = UIBarButtonItem.appearance()

//        barButtonAppearance.tintColor = UIColor(hexString: "#333333")
    
        
        
        barButtonAppearance.setTitleTextAttributes(
            [
                .font : UIFont.title,
                .foregroundColor : UIColor.titleBlack],
            for: .normal)
        
        let tableView = UITableView.appearance()
        tableView.separatorColor = .separator
        tableView.backgroundColor = .separator
        
        let tabBar = UITabBar.appearance()
        tabBar.backgroundColor = .white
        tabBar.backgroundImage = UIImage(color: .white, size: CGSize(width: 1, height: 1))
        tabBar.shadowImage = UIImage()
        tabBar.selectionIndicatorImage = UIImage(color: .red, size: CGSize(width: 1, height: 1))
        tabBar.barTintColor = .white
        tabBar.isTranslucent = true
        tabBar.tintColor = UIColor(hexString: "#ff4e39")
        tabBar.unselectedItemTintColor = UIColor(hexString: "#333333")
    }

}
