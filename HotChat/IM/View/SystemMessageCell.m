//
//  SystemMessageCell.m
//  HotChat
//
//  Created by 风起兮 on 2021/3/20.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "SystemMessageCell.h"
#import "THeader.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import <Masonry/Masonry.h>

@interface SystemMessageCell ()
@property (nonatomic, strong) UILabel *messageLabel;
@property SystemMessageCellData *systemData;
@end

@implementation SystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.textColor = [UIColor d_systemGrayColor];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.numberOfLines = 0;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.layer.cornerRadius = 3;
        [_messageLabel.layer setMasksToBounds:YES];
        [self.container addSubview:_messageLabel];
        self.container.backgroundColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1.0];
        self.container.layer.cornerRadius = 5;
        
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.container).offset(20);
            make.trailing.equalTo(self.container).offset(-20);
            make.top.bottom.equalTo(self.container);
        }];
    }
    return self;
}

- (void)fillWithData:(SystemMessageCellData *)data;
{
    [super fillWithData:data];
    self.systemData = data;
    //set data
    self.messageLabel.text = data.content;
    self.messageLabel.textColor = data.contentColor;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.container.mm_center();
    
    
    
    
//    self.messageLabel.mm_fill();
}

@end
