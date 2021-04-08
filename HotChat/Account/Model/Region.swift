//
//  Region.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON
import RxSwift


class Region: NSObject, HandyJSON {
    
    var label: String = ""
    var regionId: String = ""
    var parentRegionId: String = ""
    
    var list: [Region] = []
    
    required override init() {
        
    }
    
    
    private static let API = Request<UserAPI>()
    
    private(set) static var data: [Region] = []
    
    static var disposeBag = DisposeBag()
    
    static func requestData(block: (() -> Void)? = nil) {
        
        API.request(.region, type: Response<[Region]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { response in
                data = response.data ?? []
                block?()
            }, onError: nil)
            .disposed(by: disposeBag)
        
    }

}
