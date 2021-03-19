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
#import "HotChat-Swift.h"
#import <Masonry/Masonry.h>

@interface TextMessageCell ()

@property (nonatomic, strong) LabelView *sex;

@property (nonatomic, strong) UIButton *vip;

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation TextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
         
        _sex = [LabelView new];
        _vip = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _stackView = [[UIStackView alloc] initWithArrangedSubviews:@[_sex, _vip]];
        _stackView.alignment = UIStackViewAlignmentCenter;
        _stackView.axis = UILayoutConstraintAxisHorizontal;
        _stackView.spacing = 9;
        
        [self.contentView addSubview:_stackView];
        
        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel.mas_centerY);
            make.leading.equalTo(self.nameLabel.mas_trailing).offset(13);
        }];
        
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
    [_sex setSex: data.user];
    [_vip setVIP: data.user.ocVipType];
    
    _stackView.hidden = !data.showName;
    
//  font set in attributedString
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
}

@end
