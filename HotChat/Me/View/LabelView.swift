//
//  LabelView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


//@IBDesignable
@objc
open class LabelView: UIView {
    
    
    open override class var layerClass: AnyClass {
        return CAGradientLayer.self
        
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupData()
        setupUI()
    }
    
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupData()
        setupUI()
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
    
    
    var imageView: UIImageView!
    
    var textLabel: UILabel!
    
    
    @IBInspectable var size: CGSize = CGSize(width: 28, height: 12) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var image: UIImage? {
        didSet {
            imageView.image = image
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    @IBInspectable var text: String?  {
        didSet {
            textLabel.text = text
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    
    @IBInspectable var textColor: UIColor = .white {
        didSet {
            textLabel.textColor = textColor
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var textFont: UIFont = .systemFont(ofSize: 9) {
        didSet {
            textLabel.font = textFont
            invalidateIntrinsicContentSize()
        }
    }
    
     var textAlignment: NSTextAlignment = .center {
        didSet {
            textLabel.textAlignment = textAlignment
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var contentInsert: UIEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    

    
    
    func setupUI() {
        
        imageView = UIImageView(frame: .zero)
        addSubview(imageView)
        
        textLabel = UILabel(frame: .zero)
        textLabel.font = textFont
        textLabel.textColor = textColor
        textLabel.textAlignment = textAlignment
        addSubview(textLabel)
        
    }
    
    open override func layoutSubviews() {
        
        let imageSize = image?.size ?? .zero
        imageView.frame = CGRect(
            x: contentInsert.left,
            y: (frame.height - imageSize.height) / 2 ,
            width: imageSize.width, height: imageSize.height
        )
        
        let maximumLabelWidth = frame.width - imageView.frame.maxX - 2 - contentInsert.right
        
        let labelSize = textLabel.sizeThatFits(CGSize(width: maximumLabelWidth, height: 0))
        
        
        textLabel.frame = CGRect(
            x: imageView.frame.maxX + 2 + (maximumLabelWidth - labelSize.width) / 2,
            y: (frame.height - labelSize.height) / 2,
            width: labelSize.width, height: labelSize.height
        )
        
        layer.cornerRadius = frame.height / 2
        
        super.layoutSubviews()
    }
    
    
    open override var intrinsicContentSize: CGSize {
        return size
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
}
