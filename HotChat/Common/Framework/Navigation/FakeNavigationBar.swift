//
//  FakeNavigationBar.swift
//  NavigationController
//
//  Created by 谭帆帆 on 2019/5/17.
//  Copyright © 2019 谭帆帆. All rights reserved.
//

import UIKit

class FakeNavigationBar: UIView {
    
    // MARK: -  lazy load
    
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.isUserInteractionEnabled = false
        backgroundImageView.contentScaleFactor = 1
//        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.backgroundColor = .clear
        return backgroundImageView
    }()
    
    private lazy var backgroundEffectView: UIVisualEffectView = {
        let backgroundEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        backgroundEffectView.isUserInteractionEnabled = false
        return backgroundEffectView
    }()
    
    private lazy var shadowImageView: UIImageView = {
        let fakeShadowImageView = UIImageView()
        fakeShadowImageView.isUserInteractionEnabled = false
        fakeShadowImageView.contentScaleFactor = 1
        fakeShadowImageView.isHidden = true
        return fakeShadowImageView
    }()
    
    // MARK: -  init
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(backgroundEffectView)
        addSubview(backgroundImageView)
        addSubview(shadowImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundEffectView.frame = bounds
        backgroundImageView.frame = bounds
        let height = 1.0 / UIScreen.main.scale
        shadowImageView.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    }
    
    // MARK: -  public
    
    func setBarBackground(for viewController: UIViewController) {
        backgroundEffectView.subviews.last?.backgroundColor = viewController.navigationBarBackgroundColor
        backgroundImageView.image = viewController.navigationBarBackgroundImage
        if viewController.navigationBarBackgroundImage != nil {
            // 直接使用fakeBackgroundEffectView.alpha控制台会有提示
            // 这样使用避免警告
            backgroundEffectView.subviews.forEach { (subview) in
                subview.alpha = 0
            }
        } else {
            backgroundEffectView.subviews.forEach { (subview) in
                subview.alpha = viewController.navigationBarAlpha
            }
        }
        backgroundImageView.alpha = viewController.navigationBarAlpha
        shadowImageView.alpha = viewController.navigationBarAlpha
    }
    
    func barShadow(for viewController: UIViewController) {
        shadowImageView.isHidden = viewController.navigationBarShadowHidden
        shadowImageView.backgroundColor = viewController.navigationBarShadowColor
    }
    
}
