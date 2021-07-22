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

@property(copy, nonatomic, readonly) NSString *chargeUserID;

/// 接收方user ID
@property(copy, nonnull) NSString *userId;


/// 类型 1视频 2语音
@property(assign, nonatomic) NSInteger type;

@property(nonatomic,assign) NSInteger roomId;

@property(nonatomic,assign) NSTimeInterval callingTime;


- (instancetype)initWithUserId:(NSString *)userId type:(NSInteger) type;

///  callCode -1快没钱1正常 2你的余额不满三分钟，请先充值 3对方开启了视频防骚扰4能量不足 5同性不能聊天 10000计费失败
@property(nonnull, nonatomic, copy) void(^errorCall)(NSInteger callCode, NSString *msg, NSInteger roomId);


- (void)accept:(void (^)(void))block;

- (void)startCallChat;


- (void)endCallChat;

@end

NS_ASSUME_NONNULL_END
