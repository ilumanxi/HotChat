//
//  UserInfoEditingHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/31.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit
import IBAnimatable


class UserInfoEditingHeaderView: UITableViewHeaderFooterView {

    
    var titleBoxView: UIView
    var titleLabel: UILabel

    fileprivate static let titleBoxSize = CGSize(width: 3, height: 15)

    override init(reuseIdentifier: String?) {
        
        titleBoxView = UIView()
        titleBoxView.ib.cornerRadius = Self.titleBoxSize.width * 0.5
        titleBoxView.backgroundColor = .theme
        
        titleLabel = UILabel()
        titleLabel.font = .textTitle
        titleLabel.textColor = .titleBlack
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
        
        contentView.addSubview(titleBoxView)
        contentView.addSubview(titleLabel)
        
        titleBoxView.snp.makeConstraints { maker in
            maker.leading.equalTo(self.contentView.snp.leadingMargin)
            maker.centerY.equalToSuperview()
            maker.size.equalTo(Self.titleBoxSize)
        }
        
        titleLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(titleBoxView.snp.leadingMargin)
            maker.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
