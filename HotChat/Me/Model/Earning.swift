//
//  Earning.swift
//  HotChat
//
//  Created by 风起兮 on 2020/11/10.
//  Copyright © 2020 风起兮. All rights reserved.
//

import HandyJSON

struct Wallet: HandyJSON {
    var userEnergy: Int = 0
    var userTanbi: Int = 0
}


struct Earning: HandyJSON {
    var title: String = ""
    var energy: String = ""
    var desc: String = ""
    var type: Int = 0
}


struct EarningMonthPreview: HandyJSON {
    
    var currentEnergyMonth: Earning = Earning()
    var currentTanbiMonth: Earning = Earning()

}



struct EarningPreview: HandyJSON {
    
    var currentMonth: EarningMonth = EarningMonth()
    var lastMonth: EarningMonth = EarningMonth()
    var balanceEnergy:  EarningMonth = EarningMonth()
    
    var weekList: [EarningWeek] = []
}


struct EarningMonth: HandyJSON {
    var title: String = ""
    var energy: String = ""
    var energyDesc: String = ""
    var tanbi: String = ""
    var tanbiDesc: String = ""
}

struct EarningWeek: HandyJSON {
    
    var title: String = ""
    var list: [EarningWeekConent] = []
}


struct EarningWeekConent: HandyJSON {
    
    var energy: String = ""
    var title: String = ""

}
