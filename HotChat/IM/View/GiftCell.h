//
//  GiftCell.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "TUIMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface GiftCell : TUIMessageCell

@property(strong, nonatomic) UIImageView *giftImageView;

@property(strong, nonatomic) UILabel *giftTextLabel;
@property(strong, nonatomic) UILabel *giftLabel;

@end

NS_ASSUME_NONNULL_END
