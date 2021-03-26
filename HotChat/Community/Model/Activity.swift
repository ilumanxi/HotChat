//
//  Activity.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

import HandyJSON
import RxSwift
import RxCocoa

class Activity: NSObject, HandyJSON {
    
    
    required override init() {
        
    }
    
    var countdown: UInt = 0
    var energy: Int = 0
    var tanbi: Int = 0
    var isNext: Bool = false
    
    /// 1110抱歉，活动已结束 1111领取完了 1112有新奖励
    var resultCode: Int = 0
    var resultMsg: String?
    
    
    var isSuccessd: Bool {
        return resultCode == 1112
    }
    
    var error: Error? {
        if isSuccessd {
            return nil
        }
        return NSError(domain: "HotChatError", code: resultCode, userInfo: [NSLocalizedDescriptionKey: resultMsg ?? "未知错误"])
    }
    
    
   var timerCountdown: Observable<Int>!
    
   private(set) var canReceive: Bool = false
    
    func startCountdown() {
        if canReceive {
            return
        }
        
        if countdown <= 0 {
            canReceive = true
            timerCountdown = .empty()
        }
        else { // 倒计时
            timerCountdown = Observable<Int>.countdown(Int(countdown)).share(replay: 1, scope: .forever)
            timerCountdown?
                .subscribe(onCompleted: { [weak self]  in
                    self?.canReceive = true
                })
                .disposed(by: rx.disposeBag)
        }
    }
}
