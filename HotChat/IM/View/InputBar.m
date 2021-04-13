//
//  InputBar.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "InputBar.h"
#import "TUIRecordView.h"
#import "THeader.h"
#import "THelper.h"
#import "TUIKit.h"
#import <AVFoundation/AVFoundation.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import <Masonry/Masonry.h>
#import <SVGAPlayer/SVGAPlayer.h>
#import <SVGAPlayer/SVGAParser.h>
#import "HotChat-Swift.h"

@interface InputBar() <UITextViewDelegate>
@property BOOL isGroup;
@property SVGAParser *svgaParser;
@property SVGAPlayer *giftView;

@end

@implementation InputBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.isGroup = CGRectGetHeight(frame) <= 49;
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}
- (SVGAParser *)svgaParser {
    
    if (!_svgaParser) {
        _svgaParser = [[SVGAParser alloc] init];
        
    }
    return _svgaParser;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark];
    [self addSubview:_lineView];
    

    _inputTextView = [[TResponderTextView alloc] init];
    _inputTextView.delegate = self;
    [_inputTextView setFont:[UIFont systemFontOfSize:16]];
    [_inputTextView.layer setMasksToBounds:YES];
    [_inputTextView.layer setCornerRadius:4.0f];
    [_inputTextView.layer setBorderWidth:0.5f];
    [_inputTextView.layer setBorderColor:[UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark].CGColor];
    [_inputTextView setReturnKeyType:UIReturnKeySend];
//    [self addSubview:_inputTextView];
        
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[]];
    stackView.spacing = 18;
    stackView.axis = UILayoutConstraintAxisVertical;
    
    [self addSubview:stackView];
    
    
        
    if (!self.isGroup){
        
        _micButton = [[UIButton alloc] init];
        [_micButton addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_micButton setImage:[UIImage tk_imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_micButton setImage:[UIImage tk_imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];


        _faceButton = [[UIButton alloc] init];
        [_faceButton addTarget:self action:@selector(clickFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_faceButton setImage:[UIImage tk_imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage tk_imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];
        
        
        UIButton *sayhellowButton = [HotChatButton buttonWithType:UIButtonTypeCustom];
        [sayhellowButton setImage:[UIImage imageNamed:@"sayhellow"] forState:UIControlStateNormal];
        [sayhellowButton setTitle:@"打招呼" forState:UIControlStateNormal];
        sayhellowButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [sayhellowButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        [sayhellowButton addTarget:self action:@selector(clickSayHelloBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *audioButton = [HotChatButton buttonWithType:UIButtonTypeCustom];
        [audioButton setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
        [audioButton setTitle:@"语音" forState:UIControlStateNormal];
        audioButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [audioButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        [audioButton addTarget:self action:@selector(clickAudioBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *videoButton = [HotChatButton buttonWithType:UIButtonTypeCustom];
        [videoButton setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
        [videoButton setTitle:@"视频" forState:UIControlStateNormal];
        videoButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [videoButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        [videoButton addTarget:self action:@selector(clickVideoBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *photoButton = [HotChatButton buttonWithType:UIButtonTypeCustom];
        [photoButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [photoButton setTitle:@"图片" forState:UIControlStateNormal];
        photoButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [photoButton setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        [photoButton addTarget:self action:@selector(clickPhotoBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *spaceView = [UIView new];
        
        NSArray<UIButton *> *toolButtons = @[sayhellowButton, audioButton, videoButton, photoButton];
        
        
        UIStackView *topStackView = [[UIStackView alloc] initWithArrangedSubviews:toolButtons];
        
        [topStackView addArrangedSubview:spaceView];
        topStackView.spacing = 10;
        
        [stackView addArrangedSubview:topStackView];
        
        for (UIButton *button in toolButtons) {
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
            button.layer.cornerRadius = 14.5;
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = RGBA(213, 213, 213, 1).CGColor;
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@(29));
            }];
        }
    }
    
    
    UIStackView *bottomStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_inputTextView]];
    bottomStackView.alignment = UIStackViewAlignmentBottom;
    bottomStackView.spacing = 18;
    
    if (!self.isGroup) {
        
        [bottomStackView insertArrangedSubview:_micButton atIndex:0];
        [bottomStackView insertArrangedSubview:_faceButton atIndex:2];
        
        _giftButton = [[UIButton alloc] init];
        [_giftButton setImage:[IMHelper imageWithColor:UIColor.clearColor size:CGSizeMake(35, 35)] forState:UIControlStateNormal];
        [_giftButton setImage:[UIImage tk_imageNamed:@"ToolViewKeyboard"] forState:UIControlStateSelected];
        [_giftButton addTarget:self action:@selector(clickGiftBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.giftView = [[SVGAPlayer alloc] init];
        self.giftView.userInteractionEnabled = NO;
        
        [bottomStackView addArrangedSubview:_giftButton];
        
        [_giftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(35, 35)));
        }];
        
        [_giftButton addSubview:_giftView];
        
        [_giftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@(CGSizeMake(48, 48)));
            make.center.equalTo(_giftButton);
        }];
        
        [self.svgaParser parseWithNamed:@"im_gift_btn" inBundle:nil completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
            self.giftView.videoItem = videoItem;
            [self.giftView startAnimation];
        } failureBlock:^(NSError * _Nonnull error) {
            
        }];
    }
    
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(TTextView_Margin);
        make.leading.equalTo(self).offset(TTextView_Margin);
        make.trailing.equalTo(self).offset(-TTextView_Margin);
    }];
    
    
    [stackView addArrangedSubview:bottomStackView];
    
    
    [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(@(TTextView_TextView_Height_Min));
    }];
    
    
}

- (void)defaultLayout
{
    _lineView.frame = CGRectMake(0, 0, Screen_Width, TLine_Heigh);
    
}


- (void)layoutButton:(CGFloat)height
{
    CGRect frame = self.frame;
    CGFloat offset = height - frame.size.height;
    frame.size.height = height;
    self.frame = frame;

    if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didChangeInputHeight:)]){
        [_delegate inputBar:self didChangeInputHeight:offset];
    }
}

- (void)clickSayHelloBtn:(UIButton *)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchSayHello:)]) {
        [_delegate inputBarDidTouchSayHello:self];
    }
}

- (void)clickAudioBtn:(UIButton *)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchAudio:)]) {
        [_delegate inputBarDidTouchAudio:self];
    }
}

- (void)clickVideoBtn:(UIButton *)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchVideo:)]) {
        [_delegate inputBarDidTouchVideo:self];
    }
}

- (void)clickPhotoBtn:(UIButton *)sender {
    
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchPhoto:)]) {
        [_delegate inputBarDidTouchPhoto:self];
    }
}

- (void)clickVoiceBtn:(UIButton *)sender
{
    [self handleKeyboard:sender selector:@selector(inputBarDidTouchVoice:)];
}

- (void)handleKeyboard:(UIButton *)sender selector:(SEL)selector {
    
    sender.selected = !sender.isSelected;
    [self resetToolButtonSelectedNotIn:sender];
    
    if (sender.isSelected) {
        if(_delegate && [_delegate respondsToSelector:selector]) {
            
            [_delegate performSelector:selector withObject:self];
        }
    }
    else {
        
        [self clickKeyboardBtn:nil];
    }
}


- (void)clickKeyboardBtn:(UIButton *)sender
{
    [self layoutButton:_inputTextView.frame.size.height + self.otherHeight];
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchKeyboard:)]){
        [_delegate inputBarDidTouchKeyboard:self];
    }
}

- (void)clickFaceBtn:(UIButton *)sender
{
    
    [self handleKeyboard:sender selector:@selector(inputBarDidTouchFace:)];
}

- (void)resetToolButtonSelected {
    [self resetToolButtonSelectedNotIn:nil];
}

- (void)resetToolButtonSelectedNotIn:(UIButton *) btn {
    
    if (self.isGroup) {
        return;
    }
    
    NSMutableArray *buttons = @[_faceButton, _micButton, _giftButton].mutableCopy;
    
    if (btn != nil) {
        [buttons removeObject:btn];
    }
    [buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.selected = false;
    }];
    
    if (_giftButton && self.giftView != nil) {
        self.giftView.hidden = _giftButton.isSelected;
    }
}
            
- (void)clickGiftBtn:(UIButton *)sender
{
    [self handleKeyboard:sender selector:@selector(inputBarDidTouchGift:)];    
}

- (void)clickMoreBtn:(UIButton *)sender
{
    
    sender.selected = !sender.isSelected;
    
    [self resetToolButtonSelectedNotIn:sender];
    
    if (sender.isSelected) {
        
        if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchMore:)]){
            [_delegate inputBarDidTouchMore:self];
        }
    }
    else {
        [self clickKeyboardBtn:self.keyboardButton];
    }
}


#pragma mark - talk

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.keyboardButton.hidden = YES;
    [self resetToolButtonSelectedNotIn:nil];
}


- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size = [_inputTextView sizeThatFits:CGSizeMake(_inputTextView.frame.size.width, TTextView_TextView_Height_Max)];
    CGFloat oldHeight = _inputTextView.frame.size.height;
    CGFloat newHeight = size.height;

    if(newHeight > TTextView_TextView_Height_Max){
        newHeight = TTextView_TextView_Height_Max;
    }
    if(newHeight < TTextView_TextView_Height_Min){
        newHeight = TTextView_TextView_Height_Min;
    }
    if(oldHeight == newHeight){
        return;
    }
    
    [textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newHeight));
    }];
    
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect textFrame = ws.inputTextView.frame;
        textFrame.size.height += newHeight - oldHeight;
        ws.inputTextView.frame = textFrame;
        [ws layoutButton:newHeight + self.otherHeight];
    }];
}

- (CGFloat)otherHeight {
    if ( self.isGroup) {
        return  2 * TTextView_Margin;
    }
    return  18 + 29 + 2 * TTextView_Margin;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]){
        if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendText:)]) {
            NSString *sp = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (sp.length == 0) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"不能发送空白消息" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [self.mm_viewController presentViewController:ac animated:YES completion:nil];
            } else {
                [_delegate inputBar:self didSendText:textView.text];
                [self clearInput];
            }
        }
        return NO;
    }
    else if ([text isEqualToString:@""]) {
        if (textView.text.length > range.location) {
            // 一次性删除 [微笑] 这种表情消息
            if ([textView.text characterAtIndex:range.location] == ']') {
                NSUInteger location = range.location;
                NSUInteger length = range.length;
                int left = 91;     // '[' 对应的ascii码
                int right = 93;    // ']' 对应的ascii码
                while (location != 0) {
                    location --;
                    length ++ ;
                    int c = (int)[textView.text characterAtIndex:location];     // 将字符转换成ascii码，复制给int  避免越界
                    if (c == left) {
                        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                        return NO;
                    }
                    else if (c == right) {
                        return YES;
                    }
                }
            }
            // 一次性删除 @xxx 这种 @ 消息
            else if ([textView.text characterAtIndex:range.location] == ' ') {
                NSUInteger location = range.location;
                NSUInteger length = range.length;
                while (location != 0) {
                    location --;
                    length ++ ;
                    char c = [textView.text characterAtIndex:location];
                    if (c == '@') {
                        NSString *atText = [textView.text substringWithRange:NSMakeRange(location, length)];
                        textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBar:didDeleteAt:)]) {
                            [self.delegate inputBar:self didDeleteAt:atText];
                        }
                        return NO;
                    }
                }
            }
        }
    }
    // 监听 @ 字符的输入
    else if ([text isEqualToString:@"@"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(inputBarDidInputAt:)]) {
            [self.delegate inputBarDidInputAt:self];
        }
    }
    return YES;
}

- (void)clearInput
{
    _inputTextView.text = @"";
    [self textViewDidChange:_inputTextView];
}

- (NSString *)getInput
{
    return _inputTextView.text;
}

- (void)addEmoji:(NSString *)emoji
{
    [_inputTextView setText:[_inputTextView.text stringByAppendingString:emoji]];
    if(_inputTextView.contentSize.height > TTextView_TextView_Height_Max){
        float offset = _inputTextView.contentSize.height - _inputTextView.frame.size.height;
        [_inputTextView scrollRectToVisible:CGRectMake(0, offset, _inputTextView.frame.size.width, _inputTextView.frame.size.height) animated:YES];
    }
    [self textViewDidChange:_inputTextView];
}

- (void)backDelete
{
    [self textView:_inputTextView shouldChangeTextInRange:NSMakeRange(_inputTextView.text.length - 1, 1) replacementText:@""];
    [self textViewDidChange:_inputTextView];
}

- (void)updateTextViewFrame
{
    [self textViewDidChange:[UITextView new]];
}

@end

