//
//  GiftManager.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/4.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gift.h"
#import "GiveGift.h"
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface GiftManager : NSObject

@property(nonatomic, copy) NSArray<Gift *> *cahcheGiftList;

+ (instancetype)shared;

- (void)getGiftList:(void (^)(NSArray<Gift *> *giftList))block;

/// resultCode 1送礼成功 2送礼失败，3能量不足，送礼失败
/// 送礼物类型 1动态 2 IM聊天
- (void)giveGift:(NSString *)userId type:(NSInteger) type dynamicId:(NSString * _Nullable) dynamicId gift:(Gift *)gift block: (void (^)(NSDictionary * _Nullable responseObject, NSError * _Nullable error))block;

- (void)sendGiftMessage:(TUIMessageCellData *)msg userID: (NSString *)userID;

@end

NS_ASSUME_NONNULL_END
