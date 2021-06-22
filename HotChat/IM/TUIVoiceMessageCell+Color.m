//
//  TUIVoiceMessageCell+Color.m
//  HotChat
//
//  Created by 风起兮 on 2021/6/22.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUIVoiceMessageCell+Color.h"
#import "THeader.h"
#import "TUIKit.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIImage+Transform.h"

@implementation TUIVoiceMessageCell (Color)

- (void)fillWithData:(TUIVoiceMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.voiceData = data;
    if (data.duration > 0) {
        self.duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    } else {
        self.duration.text = @"1\"";    // 显示0秒容易产生误解
    }
    if (data.innerMessage.isSelf) {
        self.voice.image = [data.voiceImage sd_tintedImageWithColor:[UIColor whiteColor]];
    }
    else {
        self.voice.image = data.voiceImage;
    }
   
    self.voice.animationImages = data.voiceAnimationImages;
    
    //voiceReadPoint
    //此处0为语音消息未播放，1为语音消息已播放
    //发送出的消息，不展示红点
    if(self.voiceData.innerMessage.localCustomInt == 0 && self.voiceData.direction == MsgDirectionIncoming)
        self.voiceReadPoint.hidden = NO;

    //animate
    @weakify(self)
    [[RACObserve(data, isPlaying) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        if ([x boolValue]) {
            [self.voice startAnimating];
        } else {
            [self.voice stopAnimating];
        }
    }];
    if (data.direction == MsgDirectionIncoming) {
        self.duration.textAlignment = NSTextAlignmentLeft;
    } else {
        self.duration.textAlignment = NSTextAlignmentRight;
    }
}

@end
