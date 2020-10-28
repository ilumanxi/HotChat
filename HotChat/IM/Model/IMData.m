//
//  IMData.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "IMData.h"

@implementation IMData

- (instancetype)init {
    if (self = [super init]) {
        self.appVersion = @"1.0";
        self.imVersion = 12;
        self.type = 100;
    }
    return  self;
}

@end
