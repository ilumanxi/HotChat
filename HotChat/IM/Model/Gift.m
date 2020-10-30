//
//  Gift.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "Gift.h"

@implementation Gift

+ (NSMutableArray<Gift *> *)cahche  {
    
    NSMutableArray<Gift *> *gifts = @[].mutableCopy;
    
    for (int i = 0; i< 13; i++) {
        Gift *gift = [Gift new];
        gift.id = i;
        gift.img = @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=4108597118,3045519513&fm=11&gp=0.jpg";
        gift.name = [NSString stringWithFormat:@"小皮鞭%d",i];
        gift.energy = i;
        [gifts addObject:gift];
    }
    return gifts;
}

+ (void)setCahche:(NSMutableArray<Gift *> *)cahche {
    
    
}

@end
