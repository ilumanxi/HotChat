//
//  InterfaceOrientation.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/30.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit

/*


func isPad() ->Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}


func isPhone() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}



public protocol Orientation: class {
    var openAutorotate: Bool { get set }
}

fileprivate var _openAutorotate: String = "InterfaceOrientation._openAutorotate"

extension UIViewController {
    
    public var openAutorotate: Bool {
        get {
            guard let autorotate = objc_getAssociatedObject(self, &_openAutorotate) as? Bool else {
                return false
            }
            return autorotate
        }
        set {
            objc_setAssociatedObject(self, &_openAutorotate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


extension UIDevice {
    
    
    class var shouldAutorotate: Bool {
        return isPad()
    }
    
    class var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isPhone() ? .portrait : .all
    }
    
    class var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return isPhone() ? .portrait : .unknown
    }
     
 
}

public extension UIDeviceOrientation {
    
    var interfaceOrientation: UIInterfaceOrientation {
        
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .unknown
        }
    }
    
}

public extension UIViewController {
    
    class var interfaceOrientation: UIInterfaceOrientation {
        return UIDevice.current.orientation.interfaceOrientation
    }
    
    class func setOrientation(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

public extension UIDevice {
    
    class func setOrientation(_ orientation: UIDeviceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    class func defautlInterfaceOrientation() -> UIInterfaceOrientation {
        return isPhone() ? .portrait : .unknown
    }
}



extension UIViewController { //Need override UIViewController.shouldAutorotate
    
     open var shouldAutorotate: Bool {
        return openAutorotate
    }
    
}

extension UITableViewController {
    
    @objc open override var shouldAutorotate: Bool {
        return openAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.preferredInterfaceOrientationForPresentation
    }
}

extension UITabBarController {
    
    @objc open override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? openAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? UIDevice.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? UIDevice.preferredInterfaceOrientationForPresentation
    }

}



extension UINavigationController {
    
    @objc open override var shouldAutorotate: Bool {
        

        if let _ = topViewController as? MeViewController {
            return true
        }
        
        return false
        
//        return topViewController?.shouldAutorotate ?? openAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? UIDevice.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? UIDevice.preferredInterfaceOrientationForPresentation
    }
    
}

 
 */


public extension UIDeviceOrientation {
    
    var interfaceOrientation: UIInterfaceOrientation {
        
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .unknown
        }
    }
    
}


public extension UIViewController {
    
    class var interfaceOrientation: UIInterfaceOrientation {
        return UIDevice.current.orientation.interfaceOrientation
    }
    
    class func setOrientation(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

public extension UIDevice {
    
    class func setOrientation(_ orientation: UIDeviceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
}


//  标志支持旋转
@objc protocol Autorotate {
    
}


extension UIWindow {
    
    var visibleViewController: UIViewController? {
        
        var viewController = rootViewController
        
        let runLoopFind = true
        
        while runLoopFind {
            if let presentedViewController  = viewController?.presentedViewController,
                !presentedViewController.isKind(of: UIAlertController.self) {
                viewController = presentedViewController
            }
            else if let tabBarController = viewController as? UITabBarController {
                viewController = tabBarController.selectedViewController
            }
            else if let navigationController = viewController  as? UINavigationController {
                viewController = navigationController.visibleViewController
            }
            else if  let children = viewController?.children, !children.isEmpty {
                viewController = children.last
                return viewController
            }
            else {
                return viewController
            }
        }
        
        return viewController
    }
}

