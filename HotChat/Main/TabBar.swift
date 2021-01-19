//
//  TabBar.swift
//  HotChat
//
//  Created by 风起兮 on 2020/12/21.
//

import UIKit

class TabBarShadowView: UIView {
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    var diameter: CGFloat = 46.5
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.lineWidth =  1
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.separator.cgColor
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.height))
        path.addLine(to: CGPoint(x: (bounds.width -  diameter) / 2 , y: bounds.height))
        path.addQuadCurve(
            to: CGPoint(x: (bounds.width -  diameter) / 2 + diameter, y: bounds.height),
            controlPoint: CGPoint(x: bounds.width / 2, y: -bounds.height / 2))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        shapeLayer.path = path.cgPath
        
    }
    
}

class TabBar: UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    let onComposeButtonDidTapped = HotChat.Delegate<Void, Void>()
    
    func setupUI() {
        addSubview(shadowView)
        addSubview(composeButton)
    }
    
    lazy var shadowView: TabBarShadowView = {
        let view = TabBarShadowView()
        return view
    }()
    
    private lazy var composeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentVerticalAlignment = .top
        button.setImage(UIImage(named: "tabbar-add"), for: .normal)
        button.addTarget(self, action: #selector(composeButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func composeButtonDidTapped() {
        onComposeButtonDidTapped.call()
    }
    
    override var isCustomizing: Bool {
        return true
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var views =  self.items?
            .compactMap{
                $0.value(forKey: "view") as? UIView
            } ?? []
        
        let inserIndex = views.count / 2
        views.insert(composeButton, at: inserIndex)
        
        let contentEdgeInsets = UIEdgeInsets(top: 1, left:  max(2, safeAreaInsets.left), bottom: 0, right:  max(2, safeAreaInsets.right))
        let interval: CGFloat = 2
         
        // iOS 11 bounds frame 高度出现不一致， safeAreaInsets 不正确
//        let height: CGFloat = bounds.height - 1 - safeAreaInsets.bottom
        let height: CGFloat = views.first?.bounds.height ?? 48
        
        let spaceWidth: CGFloat = contentEdgeInsets.left + contentEdgeInsets.right + (CGFloat(views.count) - 1) * interval
        let availableWidth = frame.width - spaceWidth
        let itemWidth = availableWidth / CGFloat(views.count)
        
        var frame: CGRect = CGRect(x: 0, y: contentEdgeInsets.top, width: itemWidth, height: height)
        
        for (index, view) in  views.enumerated() {

            let dx: CGFloat = contentEdgeInsets.left + CGFloat(index) * itemWidth + interval * CGFloat(index)
            frame.origin.x = dx
            view.frame = frame
        }
        
        let top: CGFloat = 5.5

        composeButton.frame =  composeButton.frame.offsetBy(dx: 0, dy: -top).insetBy(dx: 0, dy: -top)
        composeButton.contentEdgeInsets = UIEdgeInsets(top:  top, left: 0, bottom: 0, right: 0)
        
        let v: CGFloat = 12
        
        shadowView.frame =  CGRect(x: 0, y: 0, width: self.bounds.width, height: v).offsetBy(dx: 0, dy: -v)
        
    }
    
}
