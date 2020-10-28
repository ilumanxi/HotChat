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

@interface InputBar() <UITextViewDelegate>
@end

@implementation InputBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    
    if (CGRectGetHeight(frame) <= 49) {
        NSLog(@"%@",NSStringFromCGRect(frame));
    }
    else {
        NSLog(@"%@",NSStringFromCGRect(frame));
    }
    
    [super setFrame:frame];
    
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark];
    [self addSubview:_lineView];

    _micButton = [[UIButton alloc] init];
    [_micButton addTarget:self action:@selector(clickVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_micButton setImage:[UIImage imageNamed:@"IMToolVoice"] forState:UIControlStateNormal];
    [_micButton setImage:[UIImage imageNamed:@"IMToolVoiceHL"] forState:UIControlStateSelected];
    [self addSubview:_micButton];

    _faceButton = [[UIButton alloc] init];
    [_faceButton addTarget:self action:@selector(clickFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_faceButton setImage:[UIImage imageNamed:@"IMToolEmotion"] forState:UIControlStateNormal];
    [_faceButton setImage:[UIImage imageNamed:@"IMToolEmotionHL"] forState:UIControlStateSelected];
    [self addSubview:_faceButton];

    _keyboardButton = [[UIButton alloc] init];
    [_keyboardButton addTarget:self action:@selector(clickKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardButton setImage:[UIImage tk_imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
    [_keyboardButton setImage:[UIImage tk_imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateSelected];
    _keyboardButton.hidden = YES;
    [self addSubview:_keyboardButton];
    
    _giftButton = [[UIButton alloc] init];
    [_giftButton setImage:[UIImage imageNamed:@"ToolViewGift"] forState:UIControlStateNormal];
    [_giftButton setImage:[UIImage imageNamed:@"ToolViewGiftHL"] forState:UIControlStateSelected];
    [_giftButton addTarget:self action:@selector(clickGiftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_giftButton];
    

    _moreButton = [[UIButton alloc] init];
    [_moreButton addTarget:self action:@selector(clickMoreBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton setImage:[UIImage imageNamed:@"IMToolMore"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"IMToolMoreHL"] forState:UIControlStateSelected];
    [self addSubview:_moreButton];

    _inputTextView = [[TResponderTextView alloc] init];
    _inputTextView.delegate = self;
    [_inputTextView setFont:[UIFont systemFontOfSize:16]];
    [_inputTextView.layer setMasksToBounds:YES];
    [_inputTextView.layer setCornerRadius:4.0f];
    [_inputTextView.layer setBorderWidth:0.5f];
    [_inputTextView.layer setBorderColor:[UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark].CGColor];
    [_inputTextView setReturnKeyType:UIReturnKeySend];
    [self addSubview:_inputTextView];
}

- (void)defaultLayout
{
    _lineView.frame = CGRectMake(0, 0, Screen_Width, TLine_Heigh);
    
    _inputTextView.frame = CGRectMake(TTextView_Margin, TTextView_Margin, Screen_Width - (TTextView_Margin * 2), TTextView_TextView_Height_Min);
    
    
    CGSize buttonSize = TTextView_Button_Size;
    
    
    CGFloat buttonOriginY = (self.frame.size.height - buttonSize.height) - 16;
    
    
    NSArray<UIButton *> *buttons = @[_faceButton, _micButton, _giftButton, _moreButton];
    
    CGFloat spacing = (Screen_Width - (buttonSize.width * buttons.count) - (InputBar_ButtonMargin * 2)) / (buttons.count - 1);
    
    [buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger index, BOOL * _Nonnull stop) {
        
        CGFloat buttonX = InputBar_ButtonMargin + (spacing + buttonSize.width) * index;
        button.frame = CGRectMake(buttonX  , buttonOriginY, buttonSize.width, buttonSize.height);
    }];
    
}


- (void)layoutButton:(CGFloat)height
{
    CGRect frame = self.frame;
    CGFloat offset = height - frame.size.height;
    frame.size.height = height;
    self.frame = frame;

    CGSize buttonSize = TTextView_Button_Size;
    
    
    CGFloat buttonOriginY = (height - buttonSize.height) - 16;
    
    
    NSArray<UIButton *> *buttons = @[_faceButton, _micButton, _giftButton, _moreButton];
    
    CGFloat spacing = (Screen_Width - (buttonSize.width * buttons.count) - (InputBar_ButtonMargin * 2)) / (buttons.count - 1);
    
    [buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger index, BOOL * _Nonnull stop) {
        
        CGFloat buttonX = InputBar_ButtonMargin + (spacing + buttonSize.width) * index;
        button.frame = CGRectMake(buttonX  , buttonOriginY, buttonSize.width, buttonSize.height);
    }];


    if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didChangeInputHeight:)]){
        [_delegate inputBar:self didChangeInputHeight:offset];
    }
}

- (void)clickVoiceBtn:(UIButton *)sender
{
    [self layoutButton:TTextView_Height + InputBar_ToolHeight];
    
    sender.selected = !sender.isSelected;
    
    [self resetToolButtonSelectedNotIn:sender];
    
    if (sender.isSelected) {
        [_inputTextView resignFirstResponder];
        if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchMore:)]){
            [_delegate inputBarDidTouchVoice:self];
        }
    }
    else {
        [self clickKeyboardBtn:self.keyboardButton];
    }
    _keyboardButton.frame = _micButton.frame;
}

- (void)clickKeyboardBtn:(UIButton *)sender
{
    [self layoutButton:_inputTextView.frame.size.height + 2 * TTextView_Margin + InputBar_ToolHeight];
    if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchKeyboard:)]){
        [_delegate inputBarDidTouchKeyboard:self];
    }
}

- (void)clickFaceBtn:(UIButton *)sender
{
    
    sender.selected = !sender.isSelected;
    
    [self resetToolButtonSelectedNotIn:sender];
    
    if (sender.isSelected) {
        if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchFace:)]){
            [_delegate inputBarDidTouchFace:self];
        }
    }
    else {
        [self clickKeyboardBtn:self.keyboardButton];
    }
    
    _keyboardButton.frame = _faceButton.frame;
}

- (void)resetToolButtonSelectedNotIn:(UIButton *) btn {
    
    NSMutableArray *buttons = @[_faceButton, _micButton, _giftButton, _moreButton].mutableCopy;
    
    [buttons removeObject:btn];
    [buttons enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        button.selected = false;
    }];
}
    
- (void)clickGiftBtn:(UIButton *)sender
{
    
    sender.selected = !sender.isSelected;
    
    [self resetToolButtonSelectedNotIn:sender];
    
    if (sender.isSelected) {
        
        if(_delegate && [_delegate respondsToSelector:@selector(inputBarDidTouchGift:)]){
            [_delegate inputBarDidTouchGift:self];
        }
    }
    else {
        [self clickKeyboardBtn:self.keyboardButton];
    }
    
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

    [self resetToolButtonSelectedNotIn:[UIButton new]];
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

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect textFrame = ws.inputTextView.frame;
        textFrame.size.height += newHeight - oldHeight;
        ws.inputTextView.frame = textFrame;
        [ws layoutButton:newHeight + 2 * TTextView_Margin + InputBar_ToolHeight];
    }];
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

