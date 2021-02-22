//
//  IMData.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMData : NSObject

@property(nonatomic, assign) NSInteger type;

@property(nonatomic, copy) NSString *appVersion;

@property(nonatomic, assign) NSInteger imVersion;

@property(nonatomic, copy) NSString *giftRequestId;

@property(nonatomic, copy) NSString *data; //json


+ (IMData *)defaultData;

@end

NS_ASSUME_NONNULL_END
