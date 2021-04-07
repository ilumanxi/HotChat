//
//  PhotoViewCell.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/2.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import FSPagerView

class PhotoViewCell: FSPagerViewCell {
    
    
    var visualEffectView: UIVisualEffectView!
    
    var lockButton: UIButton!
    
    let onLockButtonTapped = Delegate<Void, Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let _  = imageView
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.contentView.layer.shadowColor = UIColor.clear.cgColor
        self.contentView.layer.shadowRadius = 5
        self.contentView.layer.shadowOpacity = 0.75
        self.contentView.layer.shadowOffset = .zero
        visualEffectView = UIVisualEffectView(effect:  UIBlurEffect(style: .dark))
        contentView.addSubview(visualEffectView)
        
        visualEffectView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        lockButton = UIButton(type: .custom)
        lockButton.setImage(UIImage(named: "lock-photo"), for: .normal)
        lockButton.addTarget(self, action: #selector(lockButtonTapped), for: .touchUpInside)
        contentView.addSubview(lockButton)
        lockButton.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        
    }
    
    @objc func lockButtonTapped() {
        
        onLockButtonTapped.call()
    }

}
