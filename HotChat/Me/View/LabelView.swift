//
//  LabelView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit


@IBDesignable
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
        }
    }
    
    @IBInspectable var text: String?  {
        didSet {
            textLabel.text = text
            invalidateIntrinsicContentSize()
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
    
    @IBInspectable var textAlignment: NSTextAlignment = .center {
        didSet {
            textLabel.textAlignment = textAlignment
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
        
        self.imageView = UIImageView(frame: .zero)
        
        textLabel = UILabel(frame: .zero)
        textLabel.font = textFont
        textLabel.textColor = textColor
        textLabel.textAlignment = textAlignment
        
    }
    
    override func layoutSubviews() {
        
        
        super.layoutSubviews()
    }
    
    
    override var intrinsicContentSize: CGSize {
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }
}
