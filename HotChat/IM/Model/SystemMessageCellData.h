//
//  SystemMessageCellData.h
//  HotChat
//
//  Created by 风起兮 on 2021/3/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface SystemMessageCellData : TUIMessageCellData
/**
 *  系统消息内容，例如“您撤回了一条消息。”
 */
@property (nonatomic, strong) NSString *content;

/**
 *  内容字体
 *  系统消息显示时的 UI 字体。
 */
@property UIFont *contentFont;

/**
 *  内容颜色
 *  系统消息显示时的 UI 颜色。
 */
@property UIColor *contentColor;

@end

NS_ASSUME_NONNULL_END
