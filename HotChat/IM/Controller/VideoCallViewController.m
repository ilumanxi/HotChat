//
//  VideoCallViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/19.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "VideoCallViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TUIVideoCallViewController.h"
#import "TUIVideoCallUserCell.h"
#import "TUIVideoRenderView.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import <Masonry/Masonry.h>
#import "UIView+Additions.h"
#import "CallMenuViewController.h"
#import "QMUIButton.h"
#import "HotChat-Swift.h"
#import "PIPWindow.h"


#define kSmallVideoWidth 100.0

@interface VideoCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, CallMenuViewControllerDelegate>
@property(nonatomic,assign) VideoCallState curState;
@property(nonatomic,assign) CGFloat topPadding;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *avaliableList;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *userList;
@property(nonatomic,strong) CallUserModel *curSponsor;
@property(nonatomic,strong) CallUserModel *curInvite;

@property(nonatomic,strong) CallMenuViewController *callMenu;

@property(nonatomic,strong) UICollectionView *userCollectionView;
@property(nonatomic,assign) BOOL refreshCollectionView;
@property(nonatomic,assign) NSInteger collectionCount;
@property(nonatomic,strong) QMUIButton *hangup;
@property(nonatomic,strong) QMUIButton *accept;
@property(nonatomic,strong) UIButton *mute;
@property(nonatomic,strong) UIButton *handsfree;
@property(nonatomic,strong) UILabel *callTimeLabel;
@property(nonatomic,strong) UILabel *chargeReminderLabel;


@property(nonatomic,strong) UIView *localPreView;
@property(nonatomic,strong) UIView *sponsorPanel;
@property(nonatomic,strong) NSMutableArray<TUIVideoRenderView *> *renderViews;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) UInt32 callingTime;
@property(nonatomic,assign) BOOL playingAlerm; // 播放响铃

@property(nonatomic,assign) SystemSoundID systemSoundID;

@property(nonatomic,assign) CallSubType callSubType;

@property(nonatomic,strong) BaseNavigationController *pairController;

@end

@implementation VideoCallViewController
{
    VideoCallState _curState;
    UILabel *_callTimeLabel;
    UIView *_localPreview;
    UIView *_sponsorPanel;
    UICollectionView *_userCollectionView;
    NSInteger _collectionCount;
    NSMutableArray *_userList;
}

- (instancetype)initWithSponsor:(CallUserModel *)sponsor userList:(NSMutableArray<CallUserModel *> *)userList callSubType: (CallSubType) callSubType {
    self = [super init];
    if (self) {
        self.callSubType = callSubType;
        self.curSponsor = sponsor;
        if (sponsor) {
            self.curState = VideoCallState_OnInvitee;
        } else {
            self.curState = VideoCallState_Dailing;
        }
        
        if (userList) {
            self.curInvite = userList.firstObject;
        }
        
        self.renderViews = [NSMutableArray array];
        self.userList = [NSMutableArray array];
        [self resetUserList:^{
            for (CallUserModel *model in userList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    [self.userList addObject:model];
                }
            }
        }];
    }
    return self;
}

- (void)resetUserList:(void(^)(void))finished {
    if (self.curSponsor) {
        self.curSponsor.isVideoAvaliable = NO;
        [self.userList addObject:self.curSponsor];
        finished();
    } else {
        @weakify(self)
        [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
            @strongify(self)
            model.isEnter = YES;
            model.isVideoAvaliable = YES;
            [self.userList addObject:model];
            finished();
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"bell" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &_systemSoundID);
    AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&setCategoryError]) {
            NSLog(@"开启扬声器发生错误:%@",setCategoryError.localizedDescription);
        }
    [self setupUI];
    
    if (self.callSubType == CallSubType_Pair) {
        PairCallViewController *vc = [[PairCallViewController alloc] init];
        self.pairController = [[BaseNavigationController alloc] initWithRootViewController:vc];
        [self addChildViewController:self.pairController];
        self.pairController.view.frame = self.view.bounds;
        [self.view addSubview:self.pairController.view];
        [self.pairController didMoveToParentViewController:self];
    }
    
    [IMHelper getUser:self.manager.chargeUserID success:^(User * _Nonnull user) {
        self.chargeReminderLabel.text = [NSString stringWithFormat:@"%ld能量/分钟", (long)user.videoCharge];
    } failed:^(NSError * _Nonnull error) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateCallView:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.curSponsor  == nil  && self.callSubType == CallSubType_Pair) { //缘分配对拨打方不响铃
        return;
    }
    [self playAlerm];
}

- (void)disMiss {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }

    if (self.dismissBlock) {
        self.dismissBlock();
    }
    
    if (self.manager.isCharge) {
        [self.manager endCallChat];
    }
    [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    
    [self stopAlerm];
}

- (void)dealloc {
    [[TUICall shareInstance] closeCamara];
}

- (void)enterUser:(CallUserModel *)user {
    if (![user.userId isEqualToString:[TUICallUtils loginUser]]) {
        TUIVideoRenderView *renderView = [[TUIVideoRenderView alloc] init];
        renderView.userModel = user;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [renderView addGestureRecognizer:tap];
        [pan requireGestureRecognizerToFail:tap];
        [renderView addGestureRecognizer:pan];
        [self.renderViews addObject:renderView];
        [[TUICall shareInstance] startRemoteView:user.userId view:renderView];
        [self stopAlerm];
        
        if (self.pairController != nil ) {
            [self.pairController.view removeFromSuperview];
            [self.pairController didMoveToParentViewController:nil];
            self.pairController = nil;
        }
    }
    self.curState = VideoCallState_Calling;
    [self updateUser:user animate:YES];
    
    if (self.manager.isCharge) {
        [self.manager startCallChat];
    }
}

- (void)leaveUser:(NSString *)userId {
    [[TUICall shareInstance] stopRemoteView:userId];
    for (TUIVideoRenderView *renderView in self.renderViews) {
        if ([renderView.userModel.userId isEqualToString:userId]) {
            [self.renderViews removeObject:renderView];
            break;
        }
    }
    for (CallUserModel *model in self.userList) {
        if ([model.userId isEqualToString:userId]) {
            BOOL isVideoAvaliable = model.isVideoAvaliable;
            [self.userList removeObject:model];
            [self updateCallView:isVideoAvaliable];
            break;
        }
    }
}

- (void)updateUser:(CallUserModel *)user animate:(BOOL)animate {
    BOOL findUser = NO;
    for (int i = 0; i < self.userList.count; i ++) {
        CallUserModel *model = self.userList[i];
        if ([model.userId isEqualToString:user.userId]) {
            model = user;
            findUser = YES;
            break;
        }
    }
    if (!findUser) {
        [self.userList addObject:user];
    }
    [self updateCallView:animate];
}

- (void)updateCallView:(BOOL)animate {
    if (self.collectionCount <= 2) {
        // 展示 1v1 视频通话
        [self show1to1CallView];
    } else {
        // 展示多人视频通话
        [self showMultiCallView:animate];
    }
}

- (void)show1to1CallView {
    self.refreshCollectionView = NO;
    if (self.collectionCount == 2) {
        [self setLocalViewInVCView:CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0) shouldTap:YES];
        CallUserModel *userFirst;
        for (CallUserModel *model in self.avaliableList) {
            if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                userFirst = model;
                break;
            }
        }
        if (userFirst) {
            TUIVideoRenderView *firstRender = [self getRenderView:userFirst.userId];
            if (firstRender) {
                firstRender.userModel = userFirst;
                if (![firstRender.superview isEqual:self.view]) {
                    [firstRender removeFromSuperview];
                    [self.view insertSubview:firstRender belowSubview:self.localPreView];
                    [self.view insertSubview:_callMenu.view aboveSubview:firstRender];
                    [UIView animateWithDuration:0.1 animations:^{
                        firstRender.frame = self.view.bounds;
                    }];
                } else {
                    firstRender.frame = self.view.bounds;
                }
            } else {
                NSLog(@"getRenderView error");
            }
        }
    } else { //用户退出只剩下自己（userleave引起的）
        if (self.collectionCount == 1) {
            [self setLocalViewInVCView:[UIApplication sharedApplication].keyWindow.bounds shouldTap:NO];
        }
    }
    [self bringControlBtnToFront];
}

- (void)showMultiCallView:(BOOL)animate {
    self.refreshCollectionView = YES;
    [self.view bringSubviewToFront:self.userCollectionView];
    [UIView performWithoutAnimation:^{
        self.userCollectionView.mm_top(self.collectionCount == 1 ? (self.topPadding + 62) : self.topPadding).mm_flexToBottom(132);
        [self.userCollectionView reloadData];
    }];
    [self bringControlBtnToFront];
}

- (void)bringControlBtnToFront {
    [self.view bringSubviewToFront:self.accept];
    [self.view bringSubviewToFront:self.hangup];
    [self.view bringSubviewToFront:self.mute];
    [self.view bringSubviewToFront:self.handsfree];
    
    if (self.manager.isCharge) {
        [self.view bringSubviewToFront:self.chargeReminderLabel];
    }
    if (self.callSubType == CallSubType_Pair &&  self.pairController != nil) {
        [self.view bringSubviewToFront:self.pairController.view];
    }
}

#pragma mark UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    if (@available(iOS 11.0, *) ){
        self.topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    [[TUICall shareInstance] openCamera:YES view:self.localPreView];
    [self setupSponsorPanel];
    [self autoSetUIByState];
}

- (void)setupSponsorPanel {
    [self.view addSubview:self.sponsorPanel];
    
    [self.sponsorPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    if (self.curSponsor) {
        [self setupUserView:self.curSponsor];
    } else {
                
        [self setupUserView:self.curInvite];
    }
}


- (void)setupUserView:(CallUserModel *) user {
    
    //发起者背景头像
    UIImageView *userBackgroundImage = [[UIImageView alloc] init];
    [self.sponsorPanel addSubview:userBackgroundImage];
    [userBackgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sponsorPanel);
    }];
    
    [userBackgroundImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
    
    UIBlurEffect *visualEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
    [self.sponsorPanel addSubview:visualEffectView];
    
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sponsorPanel);
    }];
    
    //发起者头像
    UIImageView *userImage = [[UIImageView alloc] init];
    [self.sponsorPanel addSubview:userImage];
    
    [userImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(18);
        make.height.width.equalTo(@68);
        make.top.equalTo(self.sponsorPanel.safeAreaLayoutGuideTop).offset(32);
    }];
    
    [userImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")] options:SDWebImageHighPriority];
    //发起者名字
    UILabel *userName = [[UILabel alloc] init];
    userName.textAlignment = NSTextAlignmentRight;
    userName.font = [UIFont systemFontOfSize:19];
    userName.textColor = [UIColor whiteColor];
    userName.text = user.name ? : user.userId;
    [self.sponsorPanel addSubview:userName];
    
    [userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(userImage.mas_trailing).offset(13);
        make.top.equalTo(userImage).offset(10);
    }];
    
    //提醒文字
    UILabel *invite = [[UILabel alloc] init];
    invite.textAlignment = NSTextAlignmentRight;
    invite.font = [UIFont systemFontOfSize:14];
    invite.textColor = [UIColor whiteColor];
    invite.text = (self.curState == VideoCallState_OnInvitee) ? @"邀请你视频通话"  : @"等待对方接听" ;
    [self.sponsorPanel addSubview:invite];
    [invite mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(userName);
        make.top.equalTo(userName.mas_bottom).offset(12);
    }];
}



- (void)autoSetUIByState {
//    if (self.curSponsor) {
//        self.sponsorPanel.hidden = (self.curState == VideoCallState_Calling);
//    }
    
    self.sponsorPanel.hidden = (self.curState == VideoCallState_Calling);
    
    switch (self.curState) {
        case VideoCallState_Dailing:
        {
            [self.hangup mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
            }];
            
            if (self.manager.isCharge) {
                [self.chargeReminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.hangup);
                    make.bottom.equalTo(self.hangup.mas_top).offset(-10);
                }];
            }
        }
            break;
        case VideoCallState_OnInvitee:
        {
            
            [self.hangup mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.view).offset(55);
                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
            }];
            
            [self.accept mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self.view).offset(-55);
                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
            }];
            
            if (self.manager.isCharge) {
                [self.chargeReminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.accept);
                    make.bottom.equalTo(self.accept.mas_top).offset(-10);
                }];
            }
                        
        }
            break;
        case VideoCallState_Calling:
        {
            self.hangup.hidden = YES;
            
            if (self.manager.isCharge) {
                self.chargeReminderLabel.hidden = YES;
            }
            
            [self.callMenu.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            [self startCallTiming];
        }
            break;
        default:
            break;
    }
    
    [self.view layoutIfNeeded];
    if (self.curState == VideoCallState_Calling) {
        self.mute.alpha = 1.0;
        self.handsfree.alpha = 1.0;
    }
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//        if (self.curState == VideoCallState_Calling) {
//            self.mute.alpha = 1.0;
//            self.handsfree.alpha = 1.0;
//        }
//    }];
}

- (void)startCallTiming {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    self.callingTime = 0;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.callingTime / 60, (int)self.callingTime % 60];
            self.callMenu.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)self.callingTime / 60, (int)self.callingTime % 60];
            self.callingTime += 1;
        });
    });
    dispatch_resume(self.timer);
}

- (void)setLocalViewInVCView:(CGRect)frame shouldTap:(BOOL)shouldTap {
    if (CGRectEqualToRect(self.localPreView.frame, frame)) {
        return;
    }
    [self.localPreView setUserInteractionEnabled:shouldTap];
    [self.localPreView.subviews.firstObject setUserInteractionEnabled:!shouldTap];
    if (![self.localPreView.superview isEqual:self.view]) {
        [self.localPreView removeFromSuperview];
        [self.view insertSubview:self.localPreView aboveSubview:self.userCollectionView];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.localPreView.frame = frame;
    }];
}

- (CallMenuViewController *)callMenu {
    
    if (!_callMenu) {
        _callMenu = [[CallMenuViewController alloc] initWithStyle:CallMenuStyleVideo user:self.curSponsor ? : self.curInvite];
        _callMenu.delegate = self;
        [self addChildViewController:_callMenu];
        [self.view insertSubview:_callMenu.view aboveSubview:self.localPreView];
        [_callMenu didMoveToParentViewController:self];
    }
    
    return _callMenu;
}


- (QMUIButton *)hangup {
    if (!_hangup.superview) {
        _hangup = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_hangup setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
        [_hangup setTitle:@"挂断" forState:UIControlStateNormal];
        _hangup.titleLabel.font = [UIFont systemFontOfSize:12];
        [_hangup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _hangup.imagePosition = QMUIButtonImagePositionTop;
        _hangup.spacingBetweenImageAndTitle = 18;
        [_hangup addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hangup];
    }
    return _hangup;
}

- (QMUIButton *)accept {
    if (!_accept.superview) {
        _accept = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_accept setImage:[UIImage imageNamed:@"dialing"] forState:UIControlStateNormal];
        [_accept setTitle:@"接听" forState:UIControlStateNormal];
        _accept.titleLabel.font = [UIFont systemFontOfSize:12];
        [_accept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _accept.imagePosition = QMUIButtonImagePositionTop;
        _accept.spacingBetweenImageAndTitle = 18;
        [_accept addTarget:self action:@selector(acceptClick) forControlEvents:UIControlEventTouchUpInside];
        _accept.hidden = (self.curSponsor == nil);
        [self.view addSubview:_accept];
    }
    return _accept;
}

- (UIButton *)mute {
    if (!_mute.superview) {
        _mute = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mute setImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
        [_mute addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
        _mute.hidden = YES;
        [self.view addSubview:_mute];
    }
    return _mute;
}

- (UIButton *)handsfree {
    if (!_handsfree.superview) {
        _handsfree = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handsfree setImage:[UIImage imageNamed:@"handsfree-on"] forState:UIControlStateNormal];
        [_handsfree addTarget:self action:@selector(handsfreeClick) forControlEvents:UIControlEventTouchUpInside];
        _handsfree.hidden = YES;
        [self.view addSubview:_handsfree];
    }
    return _handsfree;
}

- (UILabel *)callTimeLabel {
    if (!_callTimeLabel.superview) {
        _callTimeLabel = [[UILabel alloc] init];
        _callTimeLabel.backgroundColor = [UIColor clearColor];
        _callTimeLabel.text = @"00:00";
        _callTimeLabel.textColor = [UIColor whiteColor];
        _callTimeLabel.textAlignment = NSTextAlignmentCenter;
        _callTimeLabel.hidden = YES;
        [self.view addSubview:_callTimeLabel];
    }
    return _callTimeLabel;
}

- (UILabel *)chargeReminderLabel {
    
    if (!_chargeReminderLabel.superview) {
        _chargeReminderLabel = [UILabel new];
        _chargeReminderLabel.font = [UIFont systemFontOfSize:12];
        _chargeReminderLabel.textColor = [UIColor colorWithRed:241/255.0 green:238/255.0 blue:11/255.0 alpha:1.0];
//        _chargeReminderLabel.text = @"2500能量/分钟";
        _chargeReminderLabel.hidden = AppAudit.share.imcallStatus;
        [self.view addSubview:_chargeReminderLabel];
    }
    return _chargeReminderLabel;
}

- (UIView *)sponsorPanel {
    if (!_sponsorPanel.superview) {
        _sponsorPanel = [[UIView alloc] init];
        [self.view addSubview:_sponsorPanel];
    }
    return _sponsorPanel;
}

- (UIView *)localPreView {
    if (!_localPreView) {
        _localPreView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_localPreView setUserInteractionEnabled:NO];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_localPreView addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [pan requireGestureRecognizerToFail:tap];
        [_localPreView addGestureRecognizer:pan];
        [self.view addSubview:_localPreView];
    }
    return _localPreView;
}

- (UICollectionView *)userCollectionView {
    if (!_userCollectionView.superview) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_userCollectionView registerClass:[TUIVideoCallUserCell class] forCellWithReuseIdentifier:TUIVideoCallUserCell_ReuseId];
        if (@available(iOS 10.0, *)) {
            [_userCollectionView setPrefetchingEnabled:YES];
        } else {
            // Fallback on earlier versions
        }
        _userCollectionView.showsVerticalScrollIndicator = NO;
        _userCollectionView.showsHorizontalScrollIndicator = NO;
        _userCollectionView.contentMode = UIViewContentModeScaleToFill;
        _userCollectionView.dataSource = self;
        _userCollectionView.delegate = self;
        [self.view addSubview:_userCollectionView];
        _userCollectionView.mm_top(self.topPadding + 62).mm_flexToBottom(132);
    }
    return _userCollectionView;
}

#pragma mark - 响铃🔔
// 播放铃声
- (void)playAlerm {
    self.playingAlerm = YES;
    [self loopPlayAlert];
}

// 结束播放铃声
- (void)stopAlerm {
    self.playingAlerm = NO;
    AudioServicesDisposeSystemSoundID(_systemSoundID);
}

// 循环播放声音
- (void)loopPlayAlert {
    if (!self.playingAlerm) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    AudioServicesPlayAlertSoundWithCompletion(_systemSoundID, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf loopPlayAlert];
        });
    });
}

#pragma mark click

- (void)hangupClick {
    [[TUICall shareInstance] hangup];
    [self disMiss];
}

- (BillingManager *)manager {
    if (!_manager) {
        
        NSString *userId = (self.curSponsor ? : self.curInvite).userId;
        _manager = [[BillingManager alloc] initWithUserId:userId type:1];
        @weakify(self)
        _manager.errorCall = ^(NSInteger callCode, NSString * _Nonnull msg) {
            @strongify(self)
            
            if (callCode == 2 || callCode== -1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你的余额不满三分钟!" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"立即充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UITabBarController *tabController =  (UITabBarController *) UIApplication.sharedApplication.keyWindow.rootViewController;
                        UINavigationController *navController = (UINavigationController *) tabController.selectedViewController;
                        WalletViewController *walletController = [[WalletViewController alloc] init];
                        [navController pushViewController:walletController animated:YES];
                    }]];
                    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                    [PIPWindow.share.rootViewController presentViewController:alert animated:YES completion:nil];
                    
                });
                
            }
            else if (callCode == 4) {
                [self hangupClick];
            }
            else {
                [THelper makeToast:msg];
            }
        };
    }
    return  _manager;
}

- (void)acceptClick {
    
    if (self.manager.isCharge) {
        @weakify(self)
        [self.manager accept:^{
            @strongify(self)
            [[TUICall shareInstance] accept];
            @weakify(self)
            [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
                @strongify(self)
                model.isEnter = YES;
                model.isVideoAvaliable = YES;
                [self enterUser:model];
                self.curState = VideoCallState_Calling;
                self.accept.hidden = YES;
            }];
        }];
    }
    else {
        
        [[TUICall shareInstance] accept];
        @weakify(self)
        [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
            @strongify(self)
            model.isEnter = YES;
            model.isVideoAvaliable = YES;
            [self enterUser:model];
            self.curState = VideoCallState_Calling;
            self.accept.hidden = YES;
        }];
    }
}

- (void)muteClick {
    BOOL micMute = ![TUICall shareInstance].micMute;
    [[TUICall shareInstance] mute:micMute];
    [self.mute setImage:[TUICall shareInstance].isMicMute ? [UIImage imageNamed:@"mute-on"] : [UIImage imageNamed:@"mute"]  forState:UIControlStateNormal];
    if (micMute) {
        [THelper makeToast:@"开启静音" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    } else {
        [THelper makeToast:@"关闭静音" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    }
}

- (void)handsfreeClick {
    BOOL handsFreeOn = ![TUICall shareInstance].handsFreeOn;
    [[TUICall shareInstance] handsFree:handsFreeOn];
    [self.handsfree setImage:[TUICall shareInstance].isHandsFreeOn ? [UIImage imageNamed:@"handsfree-on"] : [UIImage imageNamed:@"handsfree"]  forState:UIControlStateNormal];
    if (handsFreeOn) {
        [THelper makeToast:@"使用扬声器" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    } else {
        [THelper makeToast:@"使用听筒" duration:1 position:CGPointMake(self.hangup.mm_centerX, self.hangup.mm_minY - 60)];
    }
}

- (void)handleTapGesture:(UIPanGestureRecognizer *)tap {
    if (self.collectionCount != 2) {
        return;
    }
    if ([tap.view isEqual:self.localPreView]) {
        if (self.localPreView.frame.size.width == kSmallVideoWidth) {
            CallUserModel *userFirst;
            for (CallUserModel *model in self.avaliableList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    userFirst = model;
                    break;
                }
            }
            if (userFirst) {
                TUIVideoRenderView *firstRender = [self getRenderView:userFirst.userId];
                [firstRender removeFromSuperview];
                [self.view insertSubview:firstRender aboveSubview:self.localPreView];
                [self.view insertSubview:_callMenu.view belowSubview:firstRender];
                [UIView animateWithDuration:0.3 animations:^{
                    self.localPreView.frame = self.view.frame;
                    firstRender.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
                }];
            }
        }
    } else {
        UIView *smallView = tap.view;
        if (smallView.frame.size.width == kSmallVideoWidth) {
            [smallView removeFromSuperview];
            [self.view insertSubview:smallView belowSubview:self.localPreView];
            [self.view insertSubview:_callMenu.view aboveSubview:smallView];
            [UIView animateWithDuration:0.3 animations:^{
                smallView.frame = self.view.frame;
                self.localPreView.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 20, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
            }];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    UIView *smallView = pan.view;
    if (smallView) {
        if (pan.view.frame.size.width == kSmallVideoWidth) {
            if (pan.state == UIGestureRecognizerStateBegan) {
                
            } else if (pan.state == UIGestureRecognizerStateChanged) {
                CGPoint translation = [pan translationInView:self.view];
                CGFloat newCenterX = translation.x + (smallView.center.x);
                CGFloat newCenterY = translation.y + (smallView.center.y);
                if (( newCenterX < (smallView.bounds.size.width) / 2) ||
                    ( newCenterX > self.view.bounds.size.width - (smallView.bounds.size.width) / 2))  {
                    return;
                }
                if (( newCenterY < (smallView.bounds.size.height) / 2) ||
                    (newCenterY > self.view.bounds.size.height - (smallView.bounds.size.height) / 2))  {
                    return;
                }
                [UIView animateWithDuration:0.1 animations:^{
                    smallView.center = CGPointMake(newCenterX, newCenterY);
                }];
                [pan setTranslation:CGPointZero inView:self.view];
            } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
                
            }
        }
    }
}

#pragma mark UICollectionViewDelegate
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIVideoCallUserCell *cell = (TUIVideoCallUserCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TUIVideoCallUserCell_ReuseId forIndexPath:indexPath];
    if (indexPath.row < self.avaliableList.count && self.refreshCollectionView) {
        CallUserModel *model = self.avaliableList[indexPath.row];
        [cell fillWithData:model renderView:[self getRenderView:model.userId]];
        if ([model.userId isEqualToString:[TUICallUtils loginUser]]) {
            [self.localPreView removeFromSuperview];
            [cell addSubview:self.localPreView];
            [cell sendSubviewToBack:self.localPreView];
            self.localPreView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectWidth = collectionView.frame.size.width;
    CGFloat collectHeight = collectionView.frame.size.height;
    if (self.collectionCount <= 4) {
        CGFloat width = collectWidth / 2;
        CGFloat height = collectHeight / 2;
        if (self.collectionCount % 2 == 1 && indexPath.row == self.collectionCount - 1) {
            if (indexPath.row == 0 && self.collectionCount == 1) {
                return CGSizeMake(width, width);
            } else {
                return CGSizeMake(width, height);
            }
        } else {
            return CGSizeMake(width, height);
        }
    } else {
        CGFloat width = collectWidth / 3;
        CGFloat height = collectHeight / 3;
        return CGSizeMake(width, height);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)callMenuViewControllerDidHangup:(CallMenuViewController *)menu {
    
    [self disMiss];
}

#pragma mark data
- (NSMutableArray <CallUserModel *> *)avaliableList {
    NSMutableArray *avaliableList = [NSMutableArray array];
    for (CallUserModel *model in self.userList) {
        if (model.isEnter) {
            [avaliableList addObject:model];
        }
    }
    return avaliableList;
}

- (void)setCurState:(VideoCallState)curState {
    if (_curState != curState) {
        _curState = curState;
        [self autoSetUIByState];
    }
}

- (VideoCallState)curState {
    return _curState;
}

- (NSInteger)collectionCount {
    _collectionCount = (self.avaliableList.count <= 4 ? self.avaliableList.count : 9);
    if (self.curState == VideoCallState_OnInvitee || self.curState == VideoCallState_Dailing) {
        _collectionCount = 0;
    }
    return _collectionCount;
}

- (CallUserModel *)getUserById:(NSString *)userID {
    for (CallUserModel *user in self.userList) {
        if ([user.userId isEqualToString:userID]) {
            return user;
        }
    }
    return nil;
}

- (TUIVideoRenderView *)getRenderView:(NSString *)userID {
    for (TUIVideoRenderView *renderView in self.renderViews) {
        if ([renderView.userModel.userId isEqualToString:userID]) {
            return renderView;
        }
    }
    return nil;
}

@end

