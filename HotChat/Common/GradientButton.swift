//
//  GradientButton.swift
//  HotChat
//
//  Created by 风起兮 on 2021/1/16.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class GradientButton: UIButton {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
        
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupData()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupData()
    }
    
    
    private func setupData() {
        self.startPoint = CGPoint(x: 0, y: 0.5)
        self.endPoint = CGPoint(x: 1, y: 0.5)
        
    }
    
    @IBInspectable
    var colorsString: String? {
        didSet {
            let colors = colorsString?
                .split(separator: ",")
                .compactMap{
                    UIColor(hexString: String($0))
                }
            self.colors = colors
        }
    }
    
    
    var colors: [UIColor]? {
        didSet {
            gradientLayer.colors = colors?.compactMap{ $0.cgColor }
        }
    }
    
    @IBInspectable
    var locationsString: String? {
        didSet {
            let locations = locationsString?
                .split(separator: ",")
                .compactMap {
                    Double($0)
                }
            self.locations = locations
        }
    }
    

    open var locations: [Double]? {
        didSet {
            gradientLayer.locations = locations?.compactMap(NSNumber.init(value:))
        }
    }

    @IBInspectable
    open var startPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    
    @IBInspectable
    open var endPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    

}
