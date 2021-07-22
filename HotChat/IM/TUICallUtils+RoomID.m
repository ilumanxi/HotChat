//
//  TUICallUtils+RoomID.m
//  HotChat
//
//  Created by 风起兮 on 2021/7/19.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUICallUtils+RoomID.h"

static UInt32 _TUICallUtilsRoomID = 0;

@implementation TUICallUtils (RoomID)

//+ setGenerateRoomID:

+ (UInt32)generateRoomID {
    return  _TUICallUtilsRoomID;
}

+ (void)setGenerateRoomID: (UInt32) roomID {
    _TUICallUtilsRoomID = roomID;
}

@end
