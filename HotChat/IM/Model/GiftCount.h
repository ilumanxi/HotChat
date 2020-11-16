//
//  GiftCount.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiftCount : NSObject

@property(nonatomic, assign) NSInteger count;

@property(nonatomic, copy) NSString *text;

- (instancetype)initWithCount: (NSInteger)count text: (NSString *)text;

@end

NS_ASSUME_NONNULL_END
