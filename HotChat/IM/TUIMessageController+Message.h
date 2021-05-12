//
//  TUIMessageController+Message.h
//  HotChat
//
//  Created by 风起兮 on 2020/12/22.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "TUIMessageController.h"
#import <TXIMSDK_TUIKit_iOS/TXIMSDK_TUIKit_iOS-umbrella.h>


NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageController (Message)

@property (nonatomic, strong) TUIConversationCellData *conversationData;
@property (nonatomic, strong) NSMutableArray *uiMsgs;
@property (nonatomic, strong) NSMutableArray *heightCache;
@property (nonatomic, strong) V2TIMMessage *msgForDate;
@property (nonatomic, strong) V2TIMMessage *msgForGet;
@property (nonatomic, strong) TUIMessageCellData *menuUIMsg;
@property (nonatomic, strong) TUIMessageCellData *reSendUIMsg;

@property (nonatomic, assign) BOOL isLoadingMsg;
@property (nonatomic, assign) BOOL noMoreMsg;
@property (nonatomic, assign) BOOL firstLoad;
@property (nonatomic, assign) BOOL isInVC;
@property (nonatomic, assign) BOOL isActive;

- (void)readedReport;

- (V2TIMMessage *)transIMMsgFromUIMsg:(TUIMessageCellData *)data;
- (void)changeMsg:(TUIMessageCellData *)msg status:(TMsgStatus)status;
- (TUISystemMessageCellData *)transSystemMsgFromDate:(NSDate *)date;
- (void)getMessages:(NSArray *)msgs msgCount:(int)msgCount;

@end

NS_ASSUME_NONNULL_END
