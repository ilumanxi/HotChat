//
//  UserDataView.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/2.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit

class UserDataView: UIView {

    @IBOutlet weak var userIDLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var realNameButton: UIButton!
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    @IBOutlet weak var ageLabel: UILabel!
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var regionLabel: UILabel!
    
    @IBOutlet weak var homeLabel: UILabel!
    
    @IBOutlet weak var educationLabel: UILabel!
    
    @IBOutlet weak var industryLabel: UILabel!
    
    @IBOutlet weak var incomeLabel: UILabel!
    
    @IBOutlet weak var constellationLabel: UILabel!
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    @IBOutlet weak var priceView: UIStackView!
    
    
    @IBOutlet weak var voiceLabel: UILabel!
    
    @IBOutlet weak var videoLabel: UILabel!
    
    
    func set(_ model: User)  {
        
        
        let placeholder = model.userId == LoginManager.shared.user!.userId ? "未设置"  : "保密"
        
        userIDLabel.text = model.userId
        sexLabel.text = model.sex.description
        realNameButton.isSelected = model.realNameStatus == .ok
        authenticationButton.isSelected = model.authenticationStatus == .ok
        ageLabel.text = "\(model.age)岁"
        heightLabel.text = model.height.isEmpty ? placeholder: model.height
        regionLabel.text = model.region
        let home = "\(model.homeProvince)\(model.homeCity)"
        homeLabel.text = home.isEmpty ? placeholder : home
        educationLabel.text = model.education.isEmpty ? placeholder : model.education
        let industry =  model.industryList.first?.label ?? ""
        industryLabel.text = industry.isEmpty  ? placeholder : industry
        incomeLabel.text = model.income.isEmpty  ? placeholder : model.income
        constellationLabel.text = model.constellation
        introduceLabel.text =  model.introduce.isEmpty ? "未设置" : model.introduce
        
        priceView.isHidden = !model.girlStatus ||  AppAudit.share.energyStatus
        
        voiceLabel.text = "语音聊天：\(model.voiceCharge)能量/分钟"
        videoLabel.text = "视频聊天：\(model.videoCharge)能量/分钟"
    }
    
    
    func fittingSize()  {
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority(900), verticalFittingPriority: .fittingSizeLevel)
        frame = CGRect(origin: .zero, size: size)
    }

}
