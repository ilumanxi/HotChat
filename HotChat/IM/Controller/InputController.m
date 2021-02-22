//
//  TInputController.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "InputController.h"
#import "TUIMenuCell.h"
#import "TUIInputMoreCell.h"
#import "TUIFaceCell.h"
#import "TUIFaceMessageCell.h"
#import "TUITextMessageCell.h"
#import "TUIVoiceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "UIColor+TUIDarkMode.h"
#import <AVFoundation/AVFoundation.h>
#import "GiftCellData.h"
#import <MJExtension/MJExtension.h>
#import "IMData.h"
#import "TUICallUtils.h"
#import "GiftReminderViewController.h"
#import "GiftManager.h"
#import "HotChat-Swift.h"


typedef NS_ENUM(NSUInteger, InputStatus) {
    Input_Status_Input,
    Input_Status_Input_Face,
    Input_Status_Input_More,
    Input_Status_Input_Keyboard,
    Input_Status_Input_Talk,
    Input_Status_Input_Gift
};

@interface InputController () <TextViewDelegate, TMenuViewDelegate, TFaceViewDelegate, TMoreViewDelegate, VoiceViewDelegate, GiftViewControllerDelegate, GreetingViewControllerDelegate>
@property (nonatomic, assign) InputStatus status;
@property (nonatomic, strong) GreetingViewController *greetingViewController;
@end

@implementation InputController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (UIGestureRecognizer *gesture in self.view.window.gestureRecognizers) {
        NSLog(@"gesture = %@",gesture);
        gesture.delaysTouchesBegan = NO;
        NSLog(@"delaysTouchesBegan = %@",gesture.delaysTouchesBegan?@"YES":@"NO");
        NSLog(@"delaysTouchesEnded = %@",gesture.delaysTouchesEnded?@"YES":@"NO");
    }
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];
    _status = Input_Status_Input;

    _inputBar = [[InputBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, InputBar_Height)];
    _inputBar.delegate = self;
    [self.view addSubview:_inputBar];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // http://tapd.oa.com/20398462/bugtrace/bugs/view?bug_id=1020398462072883317&url_cache_key=b8dc0f6bee40dbfe0e702ef8cebd5d81
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    else if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    
    else if(_status == Input_Status_Input_Gift){
        [self hideGiftAnimation];
    }
    else{
        //[self hideFaceAnimation:NO];
        //[self hideMoreAnimation:NO];
    }
    
    [self hideGreetingAnimation];
    _status = Input_Status_Input_Keyboard;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:keyboardFrame.size.height + _inputBar.frame.size.height];
    }
}

- (void)hideFaceAnimation
{
    self.faceView.hidden = NO;
    self.faceView.alpha = 1.0;
    self.menuView.hidden = NO;
    self.menuView.alpha = 1.0;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.faceView.alpha = 0.0;
        ws.menuView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.faceView.hidden = YES;
        ws.faceView.alpha = 1.0;
        ws.menuView.hidden = YES;
        ws.menuView.alpha = 1.0;
        [ws.menuView removeFromSuperview];
        [ws.faceView removeFromSuperview];
    }];
}

- (void)hideGiftAnimation
{
    self.giftViewController.view.hidden = NO;
    self.giftViewController.view.alpha = 1.0;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.giftViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.giftViewController.view.hidden = YES;
        ws.giftViewController.view.alpha = 1.0;
        [ws.giftViewController.view removeFromSuperview];
        [ws.giftViewController didMoveToParentViewController:nil];
        [ws.giftViewController removeFromParentViewController];
    }];
}

- (void)hideGreetingAnimation
{
    self.greetingViewController.view.hidden = NO;
    self.greetingViewController.view.alpha = 1.0;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.greetingViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.greetingViewController.view.hidden = YES;
        ws.greetingViewController.view.alpha = 1.0;
        [ws.greetingViewController.view removeFromSuperview];
        [ws.greetingViewController didMoveToParentViewController:nil];
        [ws.greetingViewController removeFromParentViewController];
    }];
}


- (void)hideVoiceAnimation
{
    self.voiceView.hidden = NO;
    self.voiceView.alpha = 1.0;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.voiceView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.voiceView.hidden = YES;
        ws.voiceView.alpha = 1.0;
        [ws.voiceView removeFromSuperview];
    }];
}

- (void)showFaceAnimation
{
    [self.view addSubview:self.faceView];
    [self.view addSubview:self.menuView];

    self.faceView.hidden = NO;
    CGRect frame = self.faceView.frame;
    frame.origin.y = Screen_Height;
    self.faceView.frame = frame;

    self.menuView.hidden = NO;
    frame = self.menuView.frame;
    frame.origin.y = self.faceView.frame.origin.y + self.faceView.frame.size.height;
    self.menuView.frame = frame;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.faceView.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.faceView.frame = newFrame;

        newFrame = ws.menuView.frame;
        newFrame.origin.y = ws.faceView.frame.origin.y + ws.faceView.frame.size.height;
        ws.menuView.frame = newFrame;
    } completion:nil];
}

- (void)showGiftAnimation {
    
    [self addChildViewController:self.giftViewController];
    self.giftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.giftViewController.view.frame = CGRectMake(0, Screen_Height, Screen_Width, GiftViewController.contentHeight);
    [self.view addSubview:self.giftViewController.view];
    
    [self.giftViewController didMoveToParentViewController:self];

    self.giftViewController.view.hidden = NO;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.giftViewController.view.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.giftViewController.view.frame = newFrame;
    } completion:nil];
}


- (void)showGreetingAnimation {
    [self addChildViewController:self.greetingViewController];
    self.greetingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.greetingViewController.view.frame = CGRectMake(0, Screen_Height, Screen_Width, GreetingViewController.contentHeight);
    [self.view addSubview:self.greetingViewController.view];
    
    [self.greetingViewController didMoveToParentViewController:self];
    self.greetingViewController.view.hidden = NO;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.greetingViewController.view.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.greetingViewController.view.frame = newFrame;
    } completion:nil];
}



- (void)showVoiceAnimation {
    self.voiceView.frame = CGRectMake(0, Screen_Height, Screen_Width, VoiceView.contentHeight);
    [self.view addSubview:self.voiceView];

    self.voiceView.hidden = NO;

    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.voiceView.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.voiceView.frame = newFrame;
    } completion:nil];
}

- (void)hideMoreAnimation
{
    self.moreView.hidden = NO;
    self.moreView.alpha = 1.0;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.moreView.alpha = 0.0;
    } completion:^(BOOL finished) {
        ws.moreView.hidden = YES;
        ws.moreView.alpha = 1.0;
        [ws.moreView removeFromSuperview];
    }];
}

- (void)showMoreAnimation
{
    [self.view addSubview:self.moreView];

    self.moreView.hidden = NO;
    CGRect frame = self.moreView.frame;
    frame.origin.y = Screen_Height;
    self.moreView.frame = frame;
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect newFrame = ws.moreView.frame;
        newFrame.origin.y = ws.inputBar.frame.origin.y + ws.inputBar.frame.size.height;
        ws.moreView.frame = newFrame;
    } completion:nil];
}

- (void)inputBarDidTouchVoice:(InputBar *)textView
{
    if(_status == Input_Status_Input_Talk){
        return;
    }
    [_inputBar.inputTextView resignFirstResponder];
    [self hideFaceAnimation];
    [self hideMoreAnimation];
    [self hideGiftAnimation];
    
    [self showVoiceAnimation];
    _status = Input_Status_Input_Talk;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + VoiceView.contentHeight];
    }
}

- (void)inputBarDidTouchMore:(InputBar *)textView
{
    if(_status == Input_Status_Input_More){
        return;
    }
   
    [self hideFaceAnimation];
    [self hideGiftAnimation];
    [self hideVoiceAnimation];
    
    
    [_inputBar.inputTextView resignFirstResponder];
    [self showMoreAnimation];
    _status = Input_Status_Input_More;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + self.moreView.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)inputBarDidTouchFace:(InputBar *)textView
{
    if([TUIKit sharedInstance].config.faceGroups.count == 0){
        return;
    }
    [self hideMoreAnimation];
    [self hideGiftAnimation];
    [self hideVoiceAnimation];
    [_inputBar.inputTextView resignFirstResponder];
    [self showFaceAnimation];
    _status = Input_Status_Input_Face;
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + self.faceView.frame.size.height + self.menuView.frame.size.height + Bottom_SafeHeight];
    }
}


- (void)inputBarDidTouchGift:(InputBar *)inputBar {
    
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    if (_status == Input_Status_Input_Face) {
        [self hideFaceAnimation];
    }
    
    [_inputBar.inputTextView resignFirstResponder];
    [self showGiftAnimation];
    _status = Input_Status_Input_Gift;
    

    
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + GiftViewController.contentHeight];
    }
    
}

- (void)inputBarDidTouchKeyboard:(InputBar *)textView
{
    if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    if (_status == Input_Status_Input_Face) {
        [self hideFaceAnimation];
    }
    if (_status == Input_Status_Input_Gift) {
        [self hideGiftAnimation];
    }
    _status = Input_Status_Input_Keyboard;
    [_inputBar.inputTextView becomeFirstResponder];
}

- (void)inputBar:(InputBar *)textView didChangeInputHeight:(CGFloat)offset
{
    if(_status == Input_Status_Input_Face){
        [self showFaceAnimation];
    }
    else if(_status == Input_Status_Input_More){
        [self showMoreAnimation];
    }
    
    else if(_status == Input_Status_Input_Gift){
        [self showGiftAnimation];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:self.view.frame.size.height + offset];
    }
}

- (void)inputBar:(InputBar *)textView didSendText:(NSString *)text
{
    TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    data.content = text;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:data];
    }
}

- (void)inputBar:(InputBar *)textView didSendVoice:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    int length = (int)[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];

    TUIVoiceMessageCellData *voice = [[TUIVoiceMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    voice.path = path;
    voice.duration = duration;
    voice.length = length;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:voice];
    }
}

- (void)voiceView:(VoiceView *)voiceView didSendVoice:(NSString *)path {
    
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    int duration = (int)CMTimeGetSeconds(audioAsset.duration);
    int length = (int)[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];

    TUIVoiceMessageCellData *voice = [[TUIVoiceMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    voice.path = path;
    voice.duration = duration;
    voice.length = length;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:voice];
    }
}

- (void)inputBarDidInputAt:(InputBar *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputControllerDidInputAt:)]) {
        [_delegate inputControllerDidInputAt:self];
    }
}

- (void)inputBar:(InputBar *)textView didDeleteAt:(NSString *)atText
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didDeleteAt:)]) {
        [_delegate inputController:self didDeleteAt:atText];
    }
}

- (void)reset
{
    if(_status == Input_Status_Input){
        return;
    }
    else if(_status == Input_Status_Input_More){
        [self hideMoreAnimation];
    }
    else if(_status == Input_Status_Input_Face){
        [self hideFaceAnimation];
    }
    else if(_status == Input_Status_Input_Gift){
        [self hideGiftAnimation];
    }
    [self hideVoiceAnimation];
    [self hideGreetingAnimation];
    _status = Input_Status_Input;
    [_inputBar.inputTextView resignFirstResponder];
    [_inputBar resetToolButtonSelected];
    if (_delegate && [_delegate respondsToSelector:@selector(inputController:didChangeHeight:)]){
        [_delegate inputController:self didChangeHeight:_inputBar.frame.size.height + Bottom_SafeHeight];
    }
}

- (void)menuView:(TUIMenuView *)menuView didSelectItemAtIndex:(NSInteger)index
{
    [self.faceView scrollToFaceGroupIndex:index];
}

- (void)menuViewDidSendMessage:(TUIMenuView *)menuView
{
    NSString *text = [_inputBar getInput];
    if([text isEqualToString:@""]){
        return;
    }
    [_inputBar clearInput];
    TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    data.content = text;
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
        [_delegate inputController:self didSendMessage:data];
    }
}

- (void)faceView:(TUIFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index
{
    [self.menuView scrollToMenuIndex:index];
}

- (void)faceViewDidBackDelete:(TUIFaceView *)faceView
{
    [_inputBar backDelete];
}

- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TFaceGroup *group = [TUIKit sharedInstance].config.faceGroups[indexPath.section];
    TFaceCellData *face = group.faces[indexPath.row];
    if(indexPath.section == 0){
        [_inputBar addEmoji:face.name];
    }
    else{
        TUIFaceMessageCellData *data = [[TUIFaceMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
        data.groupIndex = group.groupIndex;
        data.path = face.path;
        data.faceName = face.name;
        if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
            [_delegate inputController:self didSendMessage:data];
        }
    }
}


- (void)giftViewController:(GiftViewController *)giftController didSelectGift:(Gift *)gift {
    [self giveGifts:gift];
}

- (void)giveGifts:(Gift *)giftData {
    
    GiftCellData *cellData = [[GiftCellData alloc] initWithDirection:MsgDirectionOutgoing];
    cellData.gift = giftData;
    
    IMData *imData = [IMData defaultData];
    imData.data = [giftData mj_JSONString];
    

    ChatViewController *chatController = (ChatViewController *) self.parentViewController;
    TUIConversationCellData *conversationData = [chatController valueForKey:@"conversationData"];
    
    [[GiftManager shared] giveGift:conversationData.userID type:2 dynamicId: nil gift:giftData block:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {

        if (error) {
            [THelper makeToast:error.localizedDescription];
            return;
        }
        GiveGift *giveGift = [GiveGift mj_objectWithKeyValues:responseObject[@"data"]];
        if (giveGift.resultCode == 1) {
            imData.giftRequestId = giveGift.giftRequestId;
            NSData *data = [TUICallUtils dictionary2JsonData:[imData mj_keyValues]];
            cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:data];
            
            [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
                [chatController user:model giveGift:giftData];
            }];
            User *user  = LoginManager.shared.user;
            user.userEnergy = giveGift.userEnergy;
            [LoginManager.shared updateWithUser:user];

            
            if(self->_delegate && [self->_delegate respondsToSelector:@selector(inputController:didSendMessage:)]){
                [self->_delegate inputController:self didSendMessage:cellData];
            }

        }
        else if (giveGift.resultCode == 3) { //能量不足，需要充值

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"您的能量不足、请充值！" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"立即充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                WalletViewController *walletController = [[WalletViewController alloc] init];
                [self.navigationController pushViewController:walletController animated:YES];

            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            [THelper makeToast:giveGift.msg];
        }
    }];

}


- (void)greetingViewController:(GreetingViewController *)greetingViewController didSelect:(NSString *)content {
    
    [self inputBar:self.inputBar didSendText:content];
}

#pragma mark - more view delegate
- (void)moreView:(TUIMoreView *)moreView didSelectMoreCell:(TUIInputMoreCell *)cell
{
    
    if ([cell.data.title isEqualToString:@"常用语"]) {
        [self showGreetingAnimation];
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(inputController:didSelectMoreCell:)]){
        [_delegate inputController:self didSelectMoreCell:cell];
    }
}

#pragma mark - lazy load
- (TUIFaceView *)faceView
{
    if(!_faceView){
        _faceView = [[TUIFaceView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.view.frame.size.width, TFaceView_Height)];
        _faceView.delegate = self;
        [_faceView setData:[TUIKit sharedInstance].config.faceGroups];
    }
    return _faceView;
}


- (GiftViewController *)giftViewController{
    if (!_giftViewController) {
        _giftViewController = [[GiftViewController alloc] init];
        _giftViewController.delegate = self;
    }
    return _giftViewController;
}


- (GreetingViewController *)greetingViewController {
    
    if (!_greetingViewController) {
        _greetingViewController = [[GreetingViewController alloc] init];
        _greetingViewController.delegate = self;
    }
    return  _greetingViewController;
}

- (VoiceView *)voiceView {
    
    if (!_voiceView) {
        _voiceView =  (VoiceView *)[[UINib nibWithNibName:@"VoiceView" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
        _voiceView.delegate = self;
    }
    return  _voiceView;
}

- (TUIMoreView *)moreView
{
    if(!_moreView){
        _moreView = [[TUIMoreView alloc] initWithFrame:CGRectMake(0, _inputBar.frame.origin.y + _inputBar.frame.size.height, self.faceView.frame.size.width, 0)];
        _moreView.delegate = self;
    }
    return _moreView;
}

- (TUIMenuView *)menuView
{
    if(!_menuView){
        _menuView = [[TUIMenuView alloc] initWithFrame:CGRectMake(0, self.faceView.frame.origin.y + self.faceView.frame.size.height, self.view.frame.size.width, TMenuView_Menu_Height)];
        _menuView.delegate = self;

        TUIKitConfig *config = [TUIKit sharedInstance].config;
        NSMutableArray *menus = [NSMutableArray array];
        for (NSInteger i = 0; i < config.faceGroups.count; ++i) {
            TFaceGroup *group = config.faceGroups[i];
            TMenuCellData *data = [[TMenuCellData alloc] init];
            data.path = group.menuPath;
            data.isSelected = NO;
            if(i == 0){
                data.isSelected = YES;
            }
            [menus addObject:data];
        }
        [_menuView setData:menus];
    }
    return _menuView;
}
@end

