//
//  SystemMessageCellData.m
//  HotChat
//
//  Created by 风起兮 on 2021/3/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "SystemMessageCellData.h"
#import "NSString+TUICommon.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

@implementation SystemMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        _contentFont = [UIFont systemFontOfSize:13];
        _contentColor = [UIColor d_systemGrayColor];
        self.cellLayout =  [TUIMessageCellLayout systemMessageLayout];
    }
    return self;
}

- (CGSize)contentSize
{
    CGSize size = [self.content textSizeIn:CGSizeMake(Screen_Width * 0.6, MAXFLOAT) font:self.contentFont];
    size.height += 26;
    size.width += 40;
    return size;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return [self contentSize].height + 26;
}
@end
