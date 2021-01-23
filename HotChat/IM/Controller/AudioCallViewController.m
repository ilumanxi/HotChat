//
//  AudioCallViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/19.
//  Copyright © 2020 风起兮. All rights reserved.
//


#import <AudioToolbox/AudioToolbox.h>
#import "TUIAudioCallViewController.h"
#import "AudioCallViewController.h"
#import "TUIAudioCallUserCell.h"
#import "TUIAudioCalledView.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import <Masonry/Masonry.h>
#import "UIView+Additions.h"
#import "CallMenuViewController.h"
#import "HotChat-Swift.h"
#import "PIPWindow.h"

#define kUserCalledView_Width  200
#define kUserCalledView_Top  200

@interface AudioCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, CallMenuViewControllerDelegate>
@property(nonatomic,assign) AudioCallState curState;
@property(nonatomic,strong) NSMutableArray<CallUserModel *> *userList;
@property(nonatomic,strong) CallUserModel *curSponsor;
@property(nonatomic,strong) CallUserModel *curInvite;
@property(nonatomic,strong) UIView *sponsorPanel;
@property(nonatomic,strong) UILabel *invite;
@property(nonatomic,strong) CallMenuViewController *callMenu;

@property(nonatomic,strong) UICollectionView *userCollectionView;
@property(nonatomic,assign) NSInteger collectionCount;
@property(nonatomic,strong) UIButton *hangup;
@property(nonatomic,strong) UIButton *accept;
@property(nonatomic,strong) UIButton *mute;
@property(nonatomic,strong) UIButton *handsfree;
@property(nonatomic,strong) UILabel *callTimeLabel;
@property(nonatomic,strong) UILabel *chargeReminderLabel;
@property(nonatomic,strong) dispatch_source_t timer;
@property(nonatomic,assign) UInt32 callingTime;
@property(nonatomic,assign) BOOL playingAlerm; // 播放响铃

@property(nonatomic,assign) SystemSoundID systemSoundID;
@end

@implementation AudioCallViewController
{
    AudioCallState _curState;
    UIView *_onInviteePanel;
    UICollectionView *_userCollectionView;
    NSInteger _collectionCount;
    UIButton *_hangup;
    UIButton *_accept;
    UIButton *_mute;
    UIButton *_handsfree;
}

- (instancetype)initWithSponsor:(CallUserModel *)sponsor userList:(NSMutableArray<CallUserModel *> *)userList {
    self = [super init];
    if (self) {
        self.curSponsor = sponsor;
        if (sponsor) {
            self.curState = AudioCallState_OnInvitee;
        } else {
            self.curState = AudioCallState_Dailing;
            self.curInvite = userList.firstObject;
        }
        
        [self resetUserList:^{
            for (CallUserModel *model in userList) {
                if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
                    if (self.curState == AudioCallState_Dailing) {
                        [self.userList addObject:model];
                    }
                }
            }
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&setCategoryError]) {
            NSLog(@"开启扬声器发生错误:%@",setCategoryError.localizedDescription);
        }
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"bell" withExtension:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &_systemSoundID);
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

#pragma mark logic

- (void)resetUserList:(void(^)(void))finished {
    self.userList = [NSMutableArray array];
    if (self.curSponsor) {
        [self.userList addObject:self.curSponsor];
        finished();
    } else {
        @weakify(self)
        [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
            @strongify(self)
            model.isEnter = YES;
            [self.userList addObject:model];
            finished();
        }];
    }
}

- (void)enterUser:(CallUserModel *)user {
    self.curState = AudioCallState_Calling;
    [self updateUser:user animate:YES];
    if (![user.userId isEqualToString:[TUICallUtils loginUser]]) {
        [self stopAlerm];
    }
    
    if (self.manager.isCharge) {
        [self.manager startCallChat];
    }
}

- (void)leaveUser:(NSString *)userId {
    for (CallUserModel *model in self.userList) {
        if ([model.userId isEqualToString:userId]) {
            [self.userList removeObject:model];
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
    [self reloadData:animate];
}

- (void)reloadData:(BOOL)animate {
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *)) {
        topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    @weakify(self)
    [UIView performWithoutAnimation:^{
        @strongify(self)
        self.userCollectionView.mm_top(self.collectionCount == 1 ? (topPadding + 62) : topPadding).mm_flexToBottom(132);
        [self.userCollectionView reloadData];
    }];
}

#pragma mark UI
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *) ){
        topPadding = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
    }
    self.userCollectionView.mm_height(self.view.mm_w).mm_top(topPadding + 62);
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
        make.centerX.equalTo(self.sponsorPanel.mas_centerX);
        make.height.width.equalTo(@130);
        make.top.equalTo(self.sponsorPanel.safeAreaLayoutGuideTop).offset(105);
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
        make.centerX.equalTo(self.sponsorPanel.mas_centerX);
        make.top.equalTo(userImage.mas_bottom).offset(16);
    }];
    
    //提醒文字
    UILabel *invite = [[UILabel alloc] init];
    invite.textAlignment = NSTextAlignmentRight;
    invite.font = [UIFont systemFontOfSize:14];
    invite.textColor = [UIColor whiteColor];
    invite.text = (self.curState == AudioCallState_OnInvitee) ? @"邀请你语音通话"  : @"等待对方接听" ;
    [self.sponsorPanel addSubview:invite];
    self.invite = invite;
    [invite mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.sponsorPanel.mas_centerX);
        make.top.equalTo(userName.mas_bottom).offset(12);
    }];
}


- (void)autoSetUIByState {
    switch (self.curState) {
        case AudioCallState_Dailing:
        {
//            self.hangup.mm_width(50).mm_height(50).mm__centerX(self.view.mm_centerX).mm_bottom(32);
            [self.hangup mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
                make.centerX.equalTo(self.view.mas_centerX);
            }];
            if (self.manager.isCharge) {
                [self.chargeReminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.hangup);
                    make.bottom.equalTo(self.hangup.mas_top).offset(-10);
                }];
            }

            self.userCollectionView.hidden = NO;
        }
            break;
        case AudioCallState_OnInvitee:
        {
            
            [self.hangup mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self.view.mas_centerX).offset(-60);
                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
            }];
            
            [self.accept mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.view.mas_centerX).offset(60);
                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
            }];
            
            if (self.manager.isCharge) {
                [self.chargeReminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.accept);
                    make.bottom.equalTo(self.accept.mas_top).offset(-10);
                }];
            }
            
            self.sponsorPanel.hidden = NO;
            self.userCollectionView.hidden = YES;
//            [self.calledView fillWithData:self.curSponsor];
        }
            break;
        case AudioCallState_Calling:
        {
            
            [self.callMenu.view mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            
            self.hangup.hidden = YES;
               
//            [self.hangup mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self.view.mas_centerX);
//                make.bottom.equalTo(self.view.safeAreaLayoutGuideBottom).offset(-49);
//            }];
//
//            [self.mute mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.trailing.equalTo(self.hangup.mas_leading).offset(-60);
//                make.bottom.equalTo(self.hangup);
//            }];
//
//
//            [self.handsfree mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.leading.equalTo(self.hangup.mas_trailing).offset(60);
//                make.bottom.equalTo(self.hangup);
//            }];
//
//            [self.callTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self.hangup.mas_top).offset(-20);
//                make.centerX.equalTo(self.hangup);
//            }];
//
//            self.invite.text = @"正在通话中...";
//
//            self.mute.hidden = NO;
//            self.handsfree.hidden = NO;
//            self.callTimeLabel.hidden = NO;
////            self.sponsorPanel.hidden = YES;
//            self.userCollectionView.hidden = NO;
//            self.mute.alpha = 0.0;
//            self.handsfree.alpha = 0.0;
            [self startCallTiming];
        }
            break;
        default:
            break;
    }
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//        if (self.curState == AudioCallState_Calling) {
//            self.mute.alpha = 1.0;
//            self.handsfree.alpha = 1.0;
//        }
//    }];
    
    [self.view layoutIfNeeded];
    if (self.curState == AudioCallState_Calling) {
        self.mute.alpha = 1.0;
        self.handsfree.alpha = 1.0;
    }
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

- (CallMenuViewController *)callMenu {
    
    if (!_callMenu) {
        _callMenu = [[CallMenuViewController alloc] initWithStyle:CallMenuStyleAudio user:self.curSponsor ? : self.curInvite];
        _callMenu.delegate = self;
        [self addChildViewController:_callMenu];
        [self.view addSubview:_callMenu.view];
        [_callMenu didMoveToParentViewController:self];
    }
    
    return _callMenu;
}

- (void)callMenuViewControllerDidHangup:(CallMenuViewController *)menu {
    
    [self disMiss];
}

- (UIButton *)hangup {
    if (!_hangup.superview) {
        _hangup = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangup setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
        [_hangup addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hangup];
    }
    return _hangup;
}

- (UIButton *)accept {
    if (!_accept.superview) {
        _accept = [UIButton buttonWithType:UIButtonTypeCustom];
        [_accept setImage:[UIImage imageNamed:@"dialing"] forState:UIControlStateNormal];
        [_accept addTarget:self action:@selector(acceptClick) forControlEvents:UIControlEventTouchUpInside];
        _accept.hidden = (self.curSponsor == nil);
        [self.view addSubview:_accept];
    }
    return _accept;
}

- (BillingManager *)manager {
    if (!_manager) {
        
        NSString *userId = (self.curSponsor ? : self.curInvite).userId;
        _manager = [[BillingManager alloc] initWithUserId:userId type:2];
        @weakify(self)
        _manager.errorCall = ^(NSInteger callCode, NSString * _Nonnull msg) {
            @strongify(self)
            if (callCode == 2 || callCode== -1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message: @"你的余额不满三分钟!" preferredStyle:UIAlertControllerStyleAlert];
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
        _chargeReminderLabel.text = @"1000能量/分钟";
        _chargeReminderLabel.hidden = AppAudit.share.imcallStatus;
        [self.view addSubview:_chargeReminderLabel];
    }
    return _chargeReminderLabel;
}

- (UIView *)sponsorPanel {
    if (!_sponsorPanel.superview) {
        _sponsorPanel = [[UIView alloc] init];
        _sponsorPanel.backgroundColor = [UIColor redColor];
        [self.view addSubview:_sponsorPanel];
    }
    return _sponsorPanel;
}

- (UICollectionView *)userCollectionView {
    if (!_userCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
        [_userCollectionView registerClass:[TUIAudioCallUserCell class] forCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId];
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

#pragma mark Event
- (void)hangupClick {
    [[TUICall shareInstance] hangup];
    [self disMiss];
}

- (void)acceptClick {
    
    if (self.manager.isCharge) {
        @weakify(self)
        [self.manager accept:^{
            [[TUICall shareInstance] accept];
            [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
                @strongify(self)
                model.isEnter = YES;
                [self enterUser:model];
                self.curState = AudioCallState_Calling;
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
            [self enterUser:model];
            self.curState = AudioCallState_Calling;
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

#pragma mark UICollectionViewDelegate

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self collectionCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIAudioCallUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TUIAudioCallUserCell_ReuseId forIndexPath:indexPath];
    if (indexPath.row < self.userList.count) {
        [cell fillWithData:self.userList[indexPath.row]];
    } else {
        [cell fillWithData:[[CallUserModel alloc] init]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat collectWidth = collectionView.frame.size.width;
    if (self.collectionCount <= 4) {
        CGFloat border = collectWidth / 2;
        if (self.collectionCount % 2 == 1 && indexPath.row == self.collectionCount - 1) {
            return CGSizeMake(collectWidth, border);
        } else {
            return CGSizeMake(border, border);
        }
    } else {
        CGFloat border = collectWidth / 3;
        return CGSizeMake(border, border);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark data

- (void)setCurState:(AudioCallState)curState {
    if (_curState != curState) {
        _curState = curState;
        [self autoSetUIByState];
    }
}

- (AudioCallState)curState {
    return _curState;
}

- (NSInteger)collectionCount {
    _collectionCount = (self.userList.count <= 4 ? self.userList.count : 9);
    if (self.curState == AudioCallState_OnInvitee) {
        _collectionCount = 1;
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

@end

