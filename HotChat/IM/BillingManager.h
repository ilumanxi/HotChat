//
//  BillingManager.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BillingManager : NSObject


@property(assign, nonatomic, getter=isCharge, readonly) BOOL charge;

/// 接收方user ID
@property(copy, nonnull) NSString *userId;


/// 类型 1视频 2语音
@property(assign, nonatomic) NSInteger type;


- (instancetype)initWithUserId:(NSString *)userId type:(NSInteger) type;

///  1正常;0;没钱;-1快没钱
///  1,正常 2你的余额不满三分钟，请先充值 3能量不足

@property(nonnull, nonatomic, copy) void(^errorCall)(NSInteger callCode, NSString *msg);


- (void)accept:(void (^)(void))block;

- (void)startCallChat;


- (void)endCallChat;

@end

NS_ASSUME_NONNULL_END
