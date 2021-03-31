//
//  TUIMessageController+Group.m
//  HotChat
//
//  Created by 风起兮 on 2021/3/31.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUIMessageController+Group.h"
#import <objc/runtime.h>
#import <ImSDK/ImSDK.h>

@implementation TUIMessageController (Group)

+ (void)load
{
    
    [self swizzleMethod:[self class] originalSelector:NSSelectorFromString(@"getMessages:msgCount:") swizzledSelector:@selector(swizzledGetMessages:msgCount:)];
    [self swizzleMethod:[self class] originalSelector:NSSelectorFromString(@"onNewMessage:") swizzledSelector:@selector(swizzledOnNewMessage:)];
}




+ (void)swizzleMethod:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}



- (void)swizzledGetMessages:(NSArray<V2TIMMessage *> *)msgs msgCount:(int)msgCount {
    
    NSMutableArray *temp = @[].mutableCopy;
    
    for (V2TIMMessage *msg in msgs) {
        
        if (msg.elemType != V2TIM_ELEM_TYPE_GROUP_TIPS) {
            [temp addObject:msg];
        }
    }
    
    [self swizzledGetMessages:temp msgCount:msgCount];
   
}


- (void)swizzledOnNewMessage:(NSNotification *)notification
{
    V2TIMMessage *msg = notification.object;
    
    if (msg.elemType == V2TIM_ELEM_TYPE_GROUP_TIPS) {
        return;
    }
    
    [self swizzledOnNewMessage:notification];
}


@end
