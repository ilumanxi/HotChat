//
//  GiftCell.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "GiftCellData.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "HotChat-Swift.h"

@implementation GiftCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.container.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        
        
        _giftImageView = [UIImageView new];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_giftImageView setClipsToBounds:YES];
        [self.container addSubview:_giftImageView];
        
        _giftTextLabel = [UILabel new];
        _giftTextLabel.font = [UIFont systemFontOfSize:14];
        _giftTextLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        [self.container addSubview:_giftTextLabel];
        
        _giftLabel = [UILabel new];
        _giftLabel.font = [UIFont systemFontOfSize:11];
        _giftLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self.container addSubview:_giftLabel];
        
    }
    
    return  self;
}

- (void)fillWithData:(GiftCellData *)data {
    
    [super fillWithData:data];
    
    [_giftImageView sd_setImageWithURL:[NSURL URLWithString:data.gift.img]];
    _giftTextLabel.text =  data.innerMessage.isSelf ? @"送给TA的礼物" : @"TA送的礼物";
    _giftLabel.text = [NSString stringWithFormat:@"%@x%ld",data.gift.name, data.gift.count];
}

/*
 _name.mm_sizeToFitThan(0, _avatar.mm_h/3).mm_top(_avatar.mm_y).mm_left(_avatar.mm_maxX + TPersonalCommonCell_Margin);
 _identifier.mm_sizeToFitThan(80, _avatar.mm_h/3).mm__centerY(_avatar.mm_centerY).mm_left(_name.mm_x);
 _signature.mm_sizeToFitThan(80, _avatar.mm_h/3).mm_bottom(_avatar.mm_b).mm_left(_name.mm_x);
 */

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.giftImageView.mm_width(52).mm_height(52).mm_top(5).mm_left(8);
    
    self.giftTextLabel.mm_sizeToFit().mm_top(15).mm_left(_giftImageView.mm_maxX + 6);
    self.giftLabel.mm_sizeToFit().mm_bottom(15).mm_left(_giftImageView.mm_maxX + 6 );;
    
}


@end
