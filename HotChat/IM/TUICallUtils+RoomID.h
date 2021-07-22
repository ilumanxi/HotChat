//
//  TUICallUtils+RoomID.h
//  HotChat
//
//  Created by 风起兮 on 2021/7/19.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUICallUtils.h"

NS_ASSUME_NONNULL_BEGIN

// ///生成随机 RoomID
//+ (UInt32)generateRoomID;

@interface TUICallUtils (RoomID)

+ (void)setGenerateRoomID:(UInt32) roomID;

@end

NS_ASSUME_NONNULL_END
