//
//  GiftCellData.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "TUIMessageCellData.h"
#import "Gift.h"

NS_ASSUME_NONNULL_BEGIN

@interface GiftCellData : TUIMessageCellData

@property(nonatomic, strong) Gift *gift;


@end

NS_ASSUME_NONNULL_END
