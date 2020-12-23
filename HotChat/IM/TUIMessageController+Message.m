//
//  TUIMessageController+Message.m
//  HotChat
//
//  Created by 风起兮 on 2020/12/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "TUIMessageController+Message.h"
#import "THeader.h"
#import "TUICallUtils.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "HotChat-Swift.h"



@implementation TUIMessageController (Message)


- (void)sendMessage:(TUIMessageCellData *)msg
{
    [self.tableView beginUpdates];
    V2TIMMessage *imMsg = msg.innerMessage;
    TUIMessageCellData *dateMsg = nil;
    if (msg.status == Msg_Status_Init)
    {
        //新消息
        if (!imMsg) {
            imMsg = [self transIMMsgFromUIMsg:msg];
        }
        dateMsg = [self transSystemMsgFromDate:imMsg.timestamp];

    } else if (imMsg) {
        //重发
        dateMsg = [self transSystemMsgFromDate:[NSDate date]];
        NSInteger row = [self.uiMsgs indexOfObject:msg];
        [self.heightCache removeObjectAtIndex:row];
        [self.uiMsgs removeObjectAtIndex:row];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView endUpdates];
        NSLog(@"Unknown message state");
        return;
    }
    // 设置推送
    V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
    int chatType = 0;
    NSString *sender = @"";
    if (self.conversationData.groupID.length > 0) {
        chatType = 2;
        sender = self.conversationData.groupID;
    } else {
        chatType = 1;
        NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
        if (loginUser.length > 0) {
            sender = loginUser;
        }
    }
    NSDictionary *extParam = @{@"entity":@{@"action":@(APNs_Business_NormalMsg),@"chatType":@(chatType),@"sender":sender,@"version":@(APNs_Version)}};
    info.ext = [TUICallUtils dictionary2JsonStr:extParam];
    // 发消息
    @weakify(self)
    [[V2TIMManager sharedInstance] sendMessage:imMsg receiver:self.conversationData.userID groupID:self.conversationData.groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:info progress:^(uint32_t progress) {
        @strongify(self)
        for (TUIMessageCellData *uiMsg in self.uiMsgs) {
            if ([uiMsg.innerMessage.msgID isEqualToString:imMsg.msgID]) {
                if([uiMsg isKindOfClass:[TUIImageMessageCellData class]]){
                    TUIImageMessageCellData *data = (TUIImageMessageCellData *)uiMsg;
                    data.uploadProgress = progress;
                }
                else if([uiMsg isKindOfClass:[TUIVideoMessageCellData class]]){
                    TUIVideoMessageCellData *data = (TUIVideoMessageCellData *)uiMsg;
                    data.uploadProgress = progress;
                }
                else if([uiMsg isKindOfClass:[TUIFileMessageCellData class]]){
                    TUIFileMessageCellData *data = (TUIFileMessageCellData *)uiMsg;
                    data.uploadProgress = progress;
                }
            }
        }
    } succ:^{
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeMsg:msg status:Msg_Status_Succ];
        });
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == 120001) {   // 能量不足
                
                GuidedRechargeViewController *vc = [[GuidedRechargeViewController alloc] init];
                [self presentViewController:vc animated:YES completion:nil];
            }
            else {
                [THelper makeToastError:code msg:desc];
            }
            [self changeMsg:msg status:Msg_Status_Fail];
        });
    }];
    
    // 展示 UI 界面
    msg.status = Msg_Status_Sending;
    msg.name = [msg.innerMessage getShowName];
    msg.avatarUrl = [NSURL URLWithString:[msg.innerMessage faceURL]];
    if(dateMsg){
        self.msgForDate = imMsg;
        [self.uiMsgs addObject:dateMsg];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.uiMsgs.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.uiMsgs addObject:msg];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.uiMsgs.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self scrollToBottom:YES];

    int delay = 1;
    if([msg isKindOfClass:[TUIImageMessageCellData class]]){
        delay = 0;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if(msg.status == Msg_Status_Sending){
            [self changeMsg:msg status:Msg_Status_Sending_2];
        }
    });
}


@end