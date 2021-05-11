//
//  UserInfoEditingHeaderView.swift
//  HotChat
//
//  Created by 风起兮 on 2020/8/31.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import SnapKit



class UserInfoEditingHeaderView: UITableViewHeaderFooterView {

    var titleLabel: UILabel

    override init(reuseIdentifier: String?) {
        titleLabel = UILabel()
        titleLabel.font = .textTitle
        titleLabel.textColor = .titleBlack
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { [unowned self] maker in
            maker.leading.equalTo(self.contentView.snp.leadingMargin)
            maker.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
