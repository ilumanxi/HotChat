//
//  TConversationListViewModel+Single.m
//  HotChat
//
//  Created by 风起兮 on 2021/3/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TConversationListViewModel+Single.h"
#import "TUILocalStorage.h"
#import "TUIKit.h"
#import "THeader.h"
#import "THelper.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMMessage+DataProvider.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"

@import ImSDK;

@implementation TConversationListViewModel (Single)



- (void)updateConversation:(NSArray *)conversationList
{
    
    NSMutableArray *convList = @[].mutableCopy;
    for (V2TIMConversation *conversation in conversationList) {
        
        if (conversation.type == V2TIM_C2C && ![conversation.userID isEqualToString:@"admin"]) {
//        if (conversation.type == V2TIM_C2C) {
            [convList addObject:conversation];
        }
    }
    // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
    for (int i = 0 ; i < convList.count ; ++ i) {
        V2TIMConversation *conv = convList[i];
        BOOL isExit = NO;
        for (int j = 0; j < self.localConvList.count; ++ j) {
            V2TIMConversation *localConv = self.localConvList[j];
            if ([localConv.conversationID isEqualToString:conv.conversationID]) {
                [self.localConvList replaceObjectAtIndex:j withObject:conv];
                isExit = YES;
                break;
            }
        }
        if (!isExit) {
            [self.localConvList addObject:conv];
        }
    }
    // 更新 cell data
    NSMutableArray *dataList = [NSMutableArray array];
    for (V2TIMConversation *conv in self.localConvList) {
        // 屏蔽会话
        if ([self filteConversation:conv]) {
            continue;
        }
        
        // 创建cellData
        TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
        data.conversationID = conv.conversationID;
        data.groupID = conv.groupID;
        data.userID = conv.userID;
        data.title = conv.showName;
        data.faceUrl = conv.faceUrl;
        data.subTitle = [self getLastDisplayString:conv];
        data.atMsgSeqList = [self getGroupAtMsgSeqList:conv];
        data.time = [self getLastDisplayDate:conv];
        if (NO == [conv.groupType isEqualToString:@"Meeting"]) {
            data.unreadCount = conv.unreadCount;
        }
        data.draftText = conv.draftText;
        if (conv.type == V2TIM_C2C) {   // 设置会话的默认头像
            data.avatarImage = DefaultAvatarImage;
        } else {
            data.avatarImage = DefaultGroupAvatarImage;
        }
        
        [dataList addObject:data];
    }
    // UI 会话列表根据 lastMessage 时间戳重新排序
    [self sortDataList:dataList];
    self.dataList = dataList;
    // 更新未读数
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onChangeUnReadCount object:self.localConvList];
}

@end
