//
//  TConversationListViewModel+Single.h
//  HotChat
//
//  Created by 风起兮 on 2021/3/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TConversationListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TConversationListViewModel (Single)

@property (nonatomic, strong) NSMutableArray *localConvList;

- (void)updateConversation:(NSArray *)conversationList;

- (BOOL)filteConversation:(V2TIMConversation *)conv;

- (NSMutableArray<NSNumber *> *)getGroupAtMsgSeqList:(V2TIMConversation *)conv;

- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conv;

- (NSDate *)getLastDisplayDate:(V2TIMConversation *)conv;

- (void)sortDataList:(NSMutableArray<TUIConversationCellData *> *)dataList;

@end

NS_ASSUME_NONNULL_END
