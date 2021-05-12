//
//  GiftViewCell.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftViewCell.h"

@implementation GiftViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView.layer removeAllAnimations];
}

- (void)setSelected:(BOOL)selected {
    
    [super setSelected:selected];
    
    
    if (selected) {
        CAKeyframeAnimation *impliesAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        
        impliesAnimation.values = @[@(1.0), @(1.2), @(0.8)];
        impliesAnimation.duration = 1;
        impliesAnimation.calculationMode = kCAAnimationCubic;
        impliesAnimation.repeatCount = MAXFLOAT;
        impliesAnimation.autoreverses = YES;
        impliesAnimation.removedOnCompletion = NO;
        [self.imageView.layer addAnimation: impliesAnimation forKey:@"impliesAnimation"];
        
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:108/255.0 alpha:1].CGColor;
    }
    
    else {
        
        [self.imageView.layer removeAllAnimations];
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }
    
    
}



@end
