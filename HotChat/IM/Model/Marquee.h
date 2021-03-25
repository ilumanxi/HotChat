//
//  Marquee.h
//  HotChat
//
//  Created by 风起兮 on 2021/3/25.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Marquee : NSObject

@property(copy) NSString *fromUserId;

@property(copy) NSString *fromUserName;


@property(copy) NSString *toUserId;
@property(copy) NSString *toUserName;

@property(copy) NSString *giftName;
@property(copy) NSString *giftIcon;
@property(assign) NSInteger giftCount;


@property(copy) NSString *noticeText;

/// 1 普通跑马灯, 2 特殊跑马灯

@property(assign) NSInteger type;

@property(assign) NSInteger stayTime;




@end


