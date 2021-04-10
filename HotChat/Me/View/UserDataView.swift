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
    
    func set(_ model: User)  {
        userIDLabel.text = model.userId
        sexLabel.text = model.sex.description
        realNameButton.isSelected = model.realNameStatus == .ok
        authenticationButton.isSelected = model.authenticationStatus == .ok
        ageLabel.text = "\(model.age)岁"
        heightLabel.text = model.height.isEmpty ? "保密" : model.height
        regionLabel.text = model.region
        let home = "\(model.homeProvince)\(model.homeCity)"
        homeLabel.text = home.isEmpty ? "保密" : home
        educationLabel.text = model.education.isEmpty ? "保密" : model.education
        let industry =  model.industryList.first?.label ?? ""
        industryLabel.text = industry.isEmpty  ? "保密" : industry
        incomeLabel.text = model.income.isEmpty  ? "保密" : model.income
        constellationLabel.text = model.constellation
        introduceLabel.text = model.introduce.isEmpty  ? "保密" : model.introduce
    }
    

}
