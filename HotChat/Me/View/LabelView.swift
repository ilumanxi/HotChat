//
//  LabelView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


//@IBDesignable
class LabelView: UIView {
    
    
    var imageView: UIImageView!
    
    var textLabel: UILabel!
    
    
    @IBInspectable var size: CGSize = CGSize(width: 32, height: 16) {
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
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
    
    override func layoutSubviews() {
        
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
    
    
    override var intrinsicContentSize: CGSize {
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
}
