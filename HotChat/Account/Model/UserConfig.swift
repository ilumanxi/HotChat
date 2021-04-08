//
//  UserConfig.swift
//  HotChat
//
//  Created by 风起兮 on 2021/4/8.
//  Copyright © 2021 风起兮. All rights reserved.
//

import Foundation
import RxSwift


class UserConfig: NSObject {
    
    static let share = UserConfig()
    
    let API = Request<UserAPI>()
    
    /// 行业
    private(set) var industry: [LikeTag] = []
    
    func defaultRequest() {
        requestIndustryData()
    }
    
    func requestIndustryData() {
        requestData(type: 9) { [unowned self] in
            self.industry = $0
        }
    }
    
    func requestData(type: Int, block: @escaping ([LikeTag]) -> Void) {
        API.request(.userConfig(type: type), type: Response<[LikeTag]>.self)
            .verifyResponse()
            .subscribe(onSuccess: {  response in
                block(response.data ?? [])
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
}
