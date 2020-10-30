//
//  LiveGiftShowNumberView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowNumberView.h"
#import "Masonry.h"

@interface LiveGiftShowNumberView ()

@property (nonatomic ,assign) NSInteger lastNumber;/**< 最后显示的数字 */

@property(nonatomic, strong) UILabel *numberLabel;

@end

@implementation LiveGiftShowNumberView

@synthesize number = _number;

- (void)setNumber:(NSInteger)number{
    self.lastNumber = number;
}

- (NSInteger)number{
    _number = self.lastNumber ;
    self.lastNumber += 1;
    return _number;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [UILabel new];
        _numberLabel.textColor = [UIColor yellowColor];
        [self addSubview:_numberLabel];
        [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _numberLabel;
}

/**
 获取显示的数字
 
 @return 显示的数字
 */
- (NSInteger)getLastNumber{
    return self.lastNumber - 1;
}

/**
 改变数字显示
 
 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger)numberStr{
    if (numberStr <= 0) {
        return;
    }
    
    
    self.numberLabel.text = [NSString stringWithFormat:@"x%ld",(long)numberStr];
    
    [self layoutIfNeeded];
    
}




@end
