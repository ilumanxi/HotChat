//
//  TUIConversationCellData+Intimacy.m
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import <objc/runtime.h>

const void *TUIConversationCellDataIntimacyKey = "TUIConversationCellData.intimacy";

#import "TUIConversationCellData+Intimacy.h"

@implementation TUIConversationCellData (Intimacy)

-(void)setIntimacy:(float)intimacy {
    objc_setAssociatedObject(self, TUIConversationCellDataIntimacyKey, @(intimacy), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)intimacy {
    return [objc_getAssociatedObject(self, TUIConversationCellDataIntimacyKey) floatValue];
}

@end
