//
//  TUICall+ExitRoom.m
//  HotChat
//
//  Created by 风起兮 on 2021/2/24.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUICall+ExitRoom.h"

@implementation TUICall (ExitRoom)

- (void)onExitRoom:(NSInteger)reason {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCallEnd:)]) {
        [self.delegate performSelector:@selector(onCallEnd:) withObject:@(reason)];
    }
}

@end
