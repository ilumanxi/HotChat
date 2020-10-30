//
//  VoiceView.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VoiceView;

NS_ASSUME_NONNULL_BEGIN

@protocol VoiceViewDelegate <NSObject>

- (void)voiceView:(VoiceView *)voiceView didSendVoice:(NSString *)path;

@end


@interface VoiceView : UIView

@property(nonatomic, assign, class, readonly) CGFloat contentHeight;

@property (nonatomic, weak) id<VoiceViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;


@property (weak, nonatomic) IBOutlet UILabel *recordLabel;


@end

NS_ASSUME_NONNULL_END
