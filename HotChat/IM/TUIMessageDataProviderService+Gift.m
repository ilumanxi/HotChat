//
//  TUIMessageDataProviderService+Gift.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "TUIMessageDataProviderService+Gift.h"
#import <objc/runtime.h>


@implementation TUIMessageDataProviderService (Gift)

+ (void)load
{
    swizzleMethod([self class], NSSelectorFromString(@"getCustomElemContent:"), @selector(swizzledGetCustomElemContent:));
}

- (void)swizzled_viewDidAppear:(BOOL)animated
{
    // call original implementation
    [self swizzled_viewDidAppear:animated];
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
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

- (NSString *)swizzledGetCustomElemContent:(V2TIMMessage *)message {
    
    if (message.customElem == nil || message.customElem.data == nil) {
        return nil;
    }
    // 先判断下是不是信令消息
    V2TIMSignalingInfo *info = [[V2TIMManager sharedInstance] getSignallingInfo:message];

    NSError *err = nil;
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingMutableContainers error:&err];
    if (info == nil && param != nil && [param[@"type"] intValue] == 100) {
        return  @"[礼物]";
    }
    if (info == nil && param != nil && [param[@"type"] intValue] == 101) {
        return  @"[图片]";
    }
    return [self swizzledGetCustomElemContent:message];
}
   

@end
