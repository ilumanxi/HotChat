//
//  IMData.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "IMData.h"
#import "HotChat-Swift.h"

@implementation IMData


+ (IMData *)defaultData {
    IMData *data = [[IMData alloc] init];
    data.appVersion = @"1.0";
    data.imVersion = 12;
    data.type = IMDataTypeGift;
    return  data;
}

@end
