//
//  TUIConversationCellData+Intimacy.m
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import <objc/runtime.h>

const void *TUIConversationCellDataIntimacyKey = "TUIConversationCellData.userIntimacy";

#import "TUIConversationCellData+Intimacy.h"

@implementation TUIConversationCellData (Intimacy)

- (void)setUserIntimacy:(float)userIntimacy {
    objc_setAssociatedObject(self, TUIConversationCellDataIntimacyKey, @(userIntimacy), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)userIntimacy {
    return [objc_getAssociatedObject(self, TUIConversationCellDataIntimacyKey) floatValue];
}

@end
