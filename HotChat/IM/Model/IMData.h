//
//  IMData.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;


NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IMDataTypeGift = 100,
    IMDataTypeImage = 101,
    IMDataTypeText = 102,
    IMDataTypeMarqueeGift = 10000,
    IMDataTypeMarqueeHeadline = 10001,
    IMDataTypeDynamic = 10002,
    IMDataTypePresent = 10003,
    IMDataTypeOnline = 10004
    
} IMDataType;

@interface IMData : NSObject

@property(nonatomic, assign) IMDataType type;

@property(nonatomic, copy) NSString *appVersion;

@property(nonatomic, assign) NSInteger imVersion;

@property(nonatomic, copy) NSString *giftRequestId;

@property(nonatomic, strong) User *user;

@property(nonatomic, copy) NSString *data; //json


+ (IMData *)defaultData;

@end

NS_ASSUME_NONNULL_END
