//
//  Gift.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Gift : NSObject

@property(nonatomic, copy) NSString *id;

@property(nonatomic, copy) NSString *name;

@property(nonatomic, copy) NSString *img;

/// 0:免费,1能量,2t币

@property(nonatomic, assign) NSInteger type;

/// 标签图片地址
@property(nonatomic, copy) NSString *tag;

/// 亲密
@property(nonatomic, assign) NSInteger intimacy;

/// 富豪
@property(nonatomic, assign) NSInteger rich;

/// 魅力
@property(nonatomic, assign) NSInteger charm;

/// 0底部,1居中,2顶部'
@property(nonatomic, assign) NSInteger position;

@property(nonatomic, assign) NSInteger energy;

@property(nonatomic, assign) NSInteger count;

@property(nonatomic, assign) BOOL isAnim;
@property(nonatomic, assign) BOOL isVip;

@property(nonatomic, assign, getter=isSelected) BOOL selected;

@end

NS_ASSUME_NONNULL_END
