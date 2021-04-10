//
//  AddressBook.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/10.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON

struct AddressBookInfo: HandyJSON {
    
    var qq: AddressBookStatus?
    var weixin: AddressBookStatus?
    var contactPhone: AddressBookStatus?
}


struct AddressBookStatus: HandyJSON {
    var energy: Int = 0
    var status:  Bool = false
    var title: String = ""
    var value: String = ""
}
