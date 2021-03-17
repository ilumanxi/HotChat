//
//  TextMessageCell.m
//  HotChat
//
//  Created by 风起兮 on 2021/3/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TextMessageCell.h"

#import "TUITextMessageCell.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[UILabel alloc] init];
        _content.numberOfLines = 0;
        [self.bubbleView addSubview:_content];
    }
    return self;
}



- (void)fillWithData:(TextMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.content.attributedText = data.attributedString;
    self.content.textColor = data.textColor;
//  font set in attributedString
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
}

@end
