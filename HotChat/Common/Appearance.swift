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
        
        let backImage = UIImage(named: "navigation-bar-back")
        let navigationBarBackgroundImage =  UIImage(color: .white, size: CGSize(width: 1, height: 1))
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.backIndicatorImage = backImage
        navigationBar.setBackgroundImage(navigationBarBackgroundImage, for: .default)
        navigationBar.titleTextAttributes = [
            .font : UIFont.navigationBarTitle,
            .foregroundColor : UIColor.titleBlack]
        
        let barButtonItem = UIBarButtonItem.appearance()
        
        barButtonItem.tintColor = UIColor(hexString: "#333333")
        
        
        barButtonItem.setTitleTextAttributes(
            [
                .font : UIFont.title,
                .foregroundColor : UIColor.titleBlack],
            for: .normal)
        
        let tableView = UITableView.appearance()
        tableView.separatorColor = .separator
        tableView.backgroundColor = .separator
        
        let tabBar = UITabBar.appearance()
        tabBar.tintColor = .theme
        tabBar.unselectedItemTintColor = UIColor(hexString: "#333333")
        
    }

}
