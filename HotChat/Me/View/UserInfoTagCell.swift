//
//  UserInfoTagCell.swift
//  HotChat
//
//  Created by 风起兮 on 2020/9/1.
//  Copyright © 2020 风起兮. All rights reserved.
//

import UIKit
import TagListView

class UserInfoTagCell: UITableViewCell {
    
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var placeholderButton: UIButton!
    
    lazy var tagListView: TagListView  =  {
        let view = TagListView()
        view.isUserInteractionEnabled = false
        view.paddingX = 8
        view.paddingY = 8
        view.marginX = 8
        view.marginY = 8
        view.tagBackgroundColor = .white
        view.textFont = .detailTitle
        view.textColor = .textGray
        view.setValue(3, forKey: "cornerRadius")
        view.setValue(1, forKey: "borderWidth")
        view.setValue(UIColor.borderGray, forKey: "borderColor")
        
        return view
    }()
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stackView.addArrangedSubview(tagListView)
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
