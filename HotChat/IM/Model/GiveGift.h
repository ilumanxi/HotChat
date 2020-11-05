//
//  GiveGift.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiveGift : NSObject

@property(assign, nonatomic) NSInteger userEnergy;

/// 1送礼成功 2送礼失败，3能量不足，送礼失败
@property(assign, nonatomic) NSInteger reultCode;

@property(copy, nonatomic) NSString *msg;


@end

NS_ASSUME_NONNULL_END