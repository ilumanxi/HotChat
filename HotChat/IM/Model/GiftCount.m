//
//  GiftCount.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftCount.h"

@implementation GiftCount

- (instancetype)initWithCount:(NSInteger)count text:(NSString *)text {
    
    if (self = [super init]) {
        _count = count;
        _text = text;
    }
    return self;
}

@end
