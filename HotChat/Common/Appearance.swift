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
        let navigationBarBackgroundImage =  UIImage(color: .white, size: CGSize(width: 1, height: 1))
        
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.backIndicatorImage = backButtonBackgroundImage
        navigationBarAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        navigationBarAppearance.setBackgroundImage(navigationBarBackgroundImage, for: .default)
        navigationBarAppearance.titleTextAttributes = [
            .font : UIFont.navigationBarTitle,
            .foregroundColor : UIColor.titleBlack]
        
        let barButtonAppearance = UIBarButtonItem.appearance()
        
//        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -5), for: .default)
        
        barButtonAppearance.tintColor = UIColor(hexString: "#333333")
        
        
        barButtonAppearance.setTitleTextAttributes(
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
