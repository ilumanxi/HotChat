//
//  NavigationController.swift
//  NavigationController
//
//  Created by 谭帆帆 on 2019/5/17.
//  Copyright © 2019 谭帆帆. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    
    private lazy var fakeBar: FakeNavigationBar = {
        let fakeBar = FakeNavigationBar()
        return fakeBar
    }()
    
    private lazy var fromFakeBar: FakeNavigationBar = {
        let fakeBar = FakeNavigationBar()
        return fakeBar
    }()
    
    private lazy var toFakeBar: FakeNavigationBar = {
        let fakeBar = FakeNavigationBar()
        return fakeBar
    }()
    
    private var fakeSuperView: UIView? {
        get {
            return navigationBar.subviews.first
        }
    }
    
    private weak var popingController: UIViewController?
    private var fakeFrameObserver: NSKeyValueObservation?
    
    // MARK: -  override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handleInteractivePopGesture))
        setupNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let coordinator = transitionCoordinator {
            guard let fromVC = coordinator.viewController(forKey: .from) else { return }
            if fromVC == popingController {
                updateNavigationBar(for: fromVC)
            }
        } else {
            guard let topViewController = topViewController else { return }
            updateNavigationBar(for: topViewController)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutFakeSubviews()
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        popingController = topViewController
        let viewController = super.popViewController(animated: animated)
        if let topViewController = topViewController {
            updateNavigationBarTint(for: topViewController, ignoreTintColor: true)
        }
        return viewController
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        popingController = topViewController
        let vcArray = super.popToRootViewController(animated: animated)
        if let topViewController = topViewController {
            updateNavigationBarTint(for: topViewController, ignoreTintColor: true)
            updateNavigationBar(for: topViewController)
        }
        return vcArray
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        popingController = topViewController
        let vcArray = super.popToViewController(viewController, animated: animated)
        if let topViewController = topViewController {
            updateNavigationBarTint(for: topViewController, ignoreTintColor: true)
        }
        return vcArray
    }
    
}

// MARK: -  Private Methods
extension NavigationController {
    
    private func setupNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        setupFakeSubviews()
    }
    
    private func setupFakeSubviews() {
        guard let fakeSuperView = fakeSuperView else { return }
        if fakeBar.superview == nil {
            fakeFrameObserver = fakeSuperView.observe(\.frame, changeHandler: { [weak self] (obj, changed) in
                guard let `self` = self else { return }
                self.layoutFakeSubviews()
            })
            fakeSuperView.insertSubview(fakeBar, at: 0)
        }
    }
    
    private func layoutFakeSubviews() {
        guard let fakeSuperView = fakeSuperView else { return }
        fakeBar.frame = fakeSuperView.bounds
        fakeBar.setNeedsLayout()
    }
    
    @objc private func handleInteractivePopGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let coordinator = transitionCoordinator,
            let fromVC = coordinator.viewController(forKey: .from),
            let toVC = coordinator.viewController(forKey: .to) else {
                return
        }
        if gesture.state == .changed {
            navigationBar.tintColor = average(fromColor: fromVC.navigationBarTintColor, toColor: toVC.navigationBarTintColor, percent: coordinator.percentComplete)
        }
    }
    
    private func average(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        let red = fromRed + (toRed - fromRed) * percent
        let green = fromGreen + (toGreen - fromGreen) * percent
        let blue = fromBlue + (toBlue - fromBlue) * percent
        let alpha = fromAlpha + (toAlpha - fromAlpha) * percent
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func showViewController(_ viewController: UIViewController, coordinator: UIViewControllerTransitionCoordinator) {
        guard let fromVC = coordinator.viewController(forKey: .from),
            let toVC = coordinator.viewController(forKey: .to) else {
                return
        }
        resetButtonLabels(in: navigationBar)
        coordinator.animate(alongsideTransition: { (context) in
            self.updateNavigationBarTint(for: viewController, ignoreTintColor: context.isInteractive)
            if viewController == toVC {
                self.showTempFakeBar(fromVC: fromVC, toVC: toVC)
            } else {
                self.updateNavigationBarBackground(for: viewController)
                self.updateNavigationBarShadow(for: viewController)
            }
        }) { (context) in
            if context.isCancelled {
                self.updateNavigationBar(for: fromVC)
            } else {
                self.updateNavigationBar(for: viewController)
            }
            if viewController == toVC {
                self.clearTempFakeBar()
            }
        }
    }
    
    private func showTempFakeBar(fromVC: UIViewController, toVC: UIViewController) {
        UIView.setAnimationsEnabled(false)
        fakeBar.alpha = 0
        // from
        fromVC.view.addSubview(fromFakeBar)
        fromFakeBar.frame = fakerBarFrame(for: fromVC)
        fromFakeBar.setNeedsLayout()
        fromFakeBar.setBarBackground(for: fromVC)
        fromFakeBar.barShadow(for: fromVC)
        // to
        toVC.view.addSubview(toFakeBar)
        toFakeBar.frame = fakerBarFrame(for: toVC)
        toFakeBar.setNeedsLayout()
        toFakeBar.setBarBackground(for: toVC)
        toFakeBar.barShadow(for: toVC)
        UIView.setAnimationsEnabled(true)
    }
    
    private func clearTempFakeBar() {
        fakeBar.alpha = 1
        fromFakeBar.removeFromSuperview()
        toFakeBar.removeFromSuperview()
    }
    
    private func fakerBarFrame(for viewController: UIViewController) -> CGRect {
        guard let fakeSuperView = fakeSuperView else {
            return navigationBar.frame
        }
        var frame = navigationBar.convert(fakeSuperView.frame, to: viewController.view)
        frame.origin.x = viewController.view.frame.origin.x
        return frame
    }
    
    private func resetButtonLabels(in view: UIView) {
        let viewClassName = view.classForCoder.description().replacingOccurrences(of: "_", with: "")
        if viewClassName == "UIButtonLabel" {
            view.alpha = 1
        } else {
            if view.subviews.count > 0 {
                for subview in view.subviews {
                    resetButtonLabels(in: subview)
                }
            }
        }
    }
    
}

// MARK: -  UINavigationControllerDelegate
extension NavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = transitionCoordinator {
            showViewController(viewController, coordinator: coordinator)
        } else {
            if !animated && viewControllers.count > 1 {
                let lastButOneVC = viewControllers[viewControllers.count - 2]
                showTempFakeBar(fromVC: lastButOneVC, toVC: viewController)
                return
            }
            updateNavigationBar(for: viewController)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if !animated {
            updateNavigationBar(for: viewController)
            clearTempFakeBar()
        }
        popingController = nil
    }
    
}

//// MARK: -  UIGestureRecognizerDelegate
//extension NavigationController: UIGestureRecognizerDelegate {
//
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if viewControllers.count <= 1 {
//            return false
//        }
//        if let topViewController = topViewController {
//            return topViewController.enableInteractivePopGestureRecognizer
//        }
//        return true
//    }
//
//}

// MARK: -  Public
extension NavigationController {
    
    func updateNavigationBar(for viewController: UIViewController) {
        setupFakeSubviews()
        updateNavigationBarTint(for: viewController)
        updateNavigationBarBackground(for: viewController)
        updateNavigationBarShadow(for: viewController)
    }
    
    func updateNavigationBarTint(for viewController: UIViewController, ignoreTintColor: Bool = false) {
        if viewController != topViewController {
            return
        }
        UIView.setAnimationsEnabled(false)
        navigationBar.barStyle = viewController.navigationBarStyle
        let titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: viewController.navigationBarTitleColor,
            NSAttributedString.Key.font: viewController.navigationBarTitleFont
        ]
        navigationBar.titleTextAttributes = titleTextAttributes
        if !ignoreTintColor {
            navigationBar.tintColor = viewController.navigationBarTintColor
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func updateNavigationBarBackground(for viewController: UIViewController) {
        if viewController != topViewController {
            return
        }
        fakeBar.setBarBackground(for: viewController)
    }
    
    func updateNavigationBarShadow(for viewController: UIViewController) {
        if viewController != topViewController {
            return
        }
        fakeBar.barShadow(for: viewController)
    }
    
}
