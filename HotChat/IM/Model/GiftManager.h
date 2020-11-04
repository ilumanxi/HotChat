//
//  GiftManager.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/4.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gift.h"

NS_ASSUME_NONNULL_BEGIN

@interface GiftManager : NSObject

@property(nonatomic, copy) NSArray<Gift *> *cahcheGiftList;

+ (instancetype)shared;

- (void)getGiftList:(void (^)(NSArray<Gift *> *giftList))block;

@end

NS_ASSUME_NONNULL_END
