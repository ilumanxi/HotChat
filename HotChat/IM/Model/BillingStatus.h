//
//  BillingStatus.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BillingStatus : NSObject

@property(assign, nonatomic) NSTimeInterval callStartTime;

@property(copy, nonatomic) NSString *userId;

@property(copy, nonatomic) NSString *toUserId;

@property(assign, nonatomic) NSInteger userEnergy;

@property(copy, nonatomic) NSString *callId;

/// 1正常;0;没钱;-1快没钱
@property(assign, nonatomic) NSInteger callCode;


@property(copy, nonatomic) NSString *msg;

@end

NS_ASSUME_NONNULL_END
