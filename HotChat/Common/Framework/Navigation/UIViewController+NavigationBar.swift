//
//  UIViewController+NavigationBar.swift
//  NavigationController
//
//  Created by 谭帆帆 on 2019/5/17.
//  Copyright © 2019 谭帆帆. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// keys
    private struct NavigationBarKey {
        static var barStyle = "NavigationBarKey.barStyle"
        static var backgroundColor = "NavigationBarKey.backgroundColor"
        static var backgroundImage = "NavigationBarKey.backgroundImage"
        static var tintColor = "NavigationBarKey.tintColor"
        static var barAlpha = "NavigationBarKey.barAlpha"
        static var titleColor = "NavigationBarKey.titleColor"
        static var titleFont = "NavigationBarKey.titleFont"
        static var shadowHidden = "NavigationBarKey.shadowHidden"
        static var shadowColor = "NavigationBarKey.shadowColor"
        static var enableInteractivePopGestureRecognizer = "NavigationBarKey.enableInteractivePopGestureRecognizer"
    }
    
    var navigationBarStyle: UIBarStyle {
        get {
            return objc_getAssociatedObject(self, &NavigationBarKey.barStyle) as? UIBarStyle ?? UINavigationBar.appearance().barStyle
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.barStyle, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            setNeedsNavigationBarTintUpdate()
        }
    }
    
    var navigationBarTintColor: UIColor {
        get {
            if let tintColor = objc_getAssociatedObject(self, &NavigationBarKey.tintColor) as? UIColor {
                return tintColor
            }
            if let tintColor = UINavigationBar.appearance().tintColor {
                return tintColor
            }
            return .black
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.tintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsNavigationBarTintUpdate()
        }
    }
    
    
    var navigationBarTitleColor: UIColor {
        get {
            if let titleColor = objc_getAssociatedObject(self, &NavigationBarKey.titleColor) as? UIColor {
                return titleColor
            }
            if let titleColor = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor {
                return titleColor
            }
            return .black
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.titleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsNavigationBarTintUpdate()
        }
    }
    
    var navigationBarTitleFont: UIFont {
        get {
            if let titleFont = objc_getAssociatedObject(self, &NavigationBarKey.titleFont) as? UIFont {
                return titleFont
            }
            if let titleFont = UINavigationBar.appearance().titleTextAttributes?[NSAttributedString.Key.font] as? UIFont {
                return titleFont
            }
            return UIFont.boldSystemFont(ofSize: 17)
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.titleFont, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsNavigationBarTintUpdate()
        }
    }
    
    
    var navigationBarBackgroundColor: UIColor {
        get {
            if let backgroundColor = objc_getAssociatedObject(self, &NavigationBarKey.backgroundColor) as? UIColor {
                return backgroundColor
            }
            if let backgroundColor = UINavigationBar.appearance().barTintColor {
                return backgroundColor
            }
            return .white
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.backgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsNavigationBarBackgroundUpdate()
        }
    }
    
    var navigationBarBackgroundImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &NavigationBarKey.backgroundImage) as? UIImage ?? UINavigationBar.appearance().backgroundImage(for: .default)
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.backgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsNavigationBarBackgroundUpdate()
        }
    }
    
    @objc
    var navigationBarAlpha: CGFloat {
        get {
            return objc_getAssociatedObject(self, &NavigationBarKey.barAlpha) as? CGFloat ?? 1
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.barAlpha, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            setNeedsNavigationBarBackgroundUpdate()
        }
    }
    
    var navigationBarShadowHidden: Bool {
        get {
            return objc_getAssociatedObject(self, &NavigationBarKey.shadowHidden) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.shadowHidden, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            setNeedsNavigationBarShadowUpdate()
        }
    }
    
    var navigationBarShadowColor: UIColor {
        get {
            
            if let color = objc_getAssociatedObject(self, &NavigationBarKey.shadowColor) as? UIColor {
                return color
            }
            
            guard let image =  navigationController?.navigationBar.shadowImage  else {
                return  UIColor(white: 0, alpha: 0.3)
            }
            
            return UIColor(patternImage: image)
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.shadowColor, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            setNeedsNavigationBarShadowUpdate()
        }
    }
    
    var enableInteractivePopGestureRecognizer: Bool {
        get {
            return objc_getAssociatedObject(self, &NavigationBarKey.enableInteractivePopGestureRecognizer) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, &NavigationBarKey.enableInteractivePopGestureRecognizer, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    
    func setNeedsNavigationBarUpdate() {
        guard let naviController = navigationController as? NavigationController else { return }
        naviController.updateNavigationBar(for: self)
    }
    
    func setNeedsNavigationBarTintUpdate() {
        guard let naviController = navigationController as? NavigationController else { return }
        naviController.updateNavigationBarTint(for: self)
    }
    
    func setNeedsNavigationBarBackgroundUpdate() {
        guard let naviController = navigationController as? NavigationController else { return }
        naviController.updateNavigationBarBackground(for: self)
    }
    
    func setNeedsNavigationBarShadowUpdate() {
        guard let naviController = navigationController as? NavigationController else { return }
        naviController.updateNavigationBarShadow(for: self)
    }
    
}

