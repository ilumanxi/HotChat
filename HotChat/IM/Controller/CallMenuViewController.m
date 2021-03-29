//
//  CallMenuViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "CallMenuViewController.h"
#import "QMUIButton.h"
#import "UIView+Additions.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import "BeautyViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "GiftViewController.h"
#import "ChatController.h"
#import "Gift.h"
#import "IMData.h"
#import "GiftCellData.h"
#import <MJExtension/MJExtension.h>
#import "IMData.h"
#import "JPGiftModel.h"
#import "JPGiftShowManager.h"
#import <ImSDK/V2TIMManager.h>
#import <ImSDK/V2TIMManager+Message.h>
#import "GiftReminderViewController.h"
#import "HotChat-Swift.h"
#import "GiftManager.h"
#import <ReplayKit/ReplayKit.h>
#import "HotChat-Swift.h"
#import <Toast/Toast.h>


@interface CallMenuViewController ()<GiftViewControllerDelegate, V2TIMAdvancedMsgListener>

///  摄像头 📷
@property(strong, nonatomic) QMUIButton *cameraButton;

/// 美颜 👀
@property(strong, nonatomic) QMUIButton *beautyButton;

/// 礼物 🎁
@property(strong, nonatomic) QMUIButton *giftButton;

/// 免提
@property(nonatomic,strong) QMUIButton *handsfreeButton;

/// 静音 🔇
@property(nonatomic,strong) QMUIButton *muteButton;

/// 挂断
@property(nonatomic,strong) QMUIButton *hangupButton;

@property(nonatomic, strong) UIStackView *containerStackView;

@property(nonatomic, strong) BeautyViewController *beautyController;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIButton *followButton;


@property (nonatomic, strong) JPGiftShowManager * giftShowManager;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
 
@property (strong, nonatomic) ReportHelper *reportHelper;



@end

@implementation CallMenuViewController


- (instancetype)initWithStyle:(CallMenuStyle)style user:(UserModel *)user {
    if (self = [super init]) {
        _frontCamera = YES;
        _style = style;
        _user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupViews];
    
    self.nameLabel.text = self.user.name ? : self.user.userId;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar]];
    
    [[V2TIMManager sharedInstance]  addAdvancedMsgListener:self];
    
    if (self.style == CallMenuStyleVideo) {
        [BeautyViewController setDefaultBeauty];
    }
    
}

-(void)dealloc {
    if ([self isViewLoaded]) {
//        [[V2TIMManager sharedInstance]  removeAdvancedMsgListener:self];
    }
}


- (IBAction)followButtonTapped {
    
}
- (IBAction)reportButtonTapped {
    
    if (self.style == CallMenuStyleAudio) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Chat" bundle:nil];
        
        ReportUserViewController *vc = (ReportUserViewController *) [storyboard instantiateViewControllerWithIdentifier:@"ReportUserViewController"];
        User * user = [[User alloc] init];
        user.userId = self.user.userId;
        vc.user = user;
    
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [self snapshotImage];
    }
}

- (void)snapshotImage {
    
    [[TRTCCloud sharedInstance] snapshotVideo:self.user.userId type:TRTCVideoStreamTypeBig completionBlock:^(UIImage *image) {
        
        [self.reportHelper oneKeyReportWithReportUserId:self.user.userId img:image success:^(NSDictionary<NSString *,id> * _Nonnull result) {
            [self.view makeToast:result[@"resultMsg"] duration:[CSToastManager defaultDuration] position:CSToastPositionCenter];
        } failed:^(NSError * _Nonnull error) {
            [self.view makeToast:error.localizedDescription duration:[CSToastManager defaultDuration] position:CSToastPositionCenter];
        }];
    }];
    
}


- (void)setupViews {
    
    if (self.style == CallMenuStyleVideo) {
        [self.containerStackView addArrangedSubview:self.cameraButton];
        [self.containerStackView addArrangedSubview:self.beautyButton];
        [self.containerStackView addArrangedSubview:self.giftButton];
        self.visualEffectView.hidden = YES;
    }
    else {
        self.backgroundImageView.backgroundColor = [UIColor blackColor];
        [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar]];
        [self.containerStackView addArrangedSubview:self.muteButton];
        [self.containerStackView addArrangedSubview:self.handsfreeButton];
        [self.containerStackView addArrangedSubview:self.giftButton];
    }
    
    self.handsfreeButton.selected = [TUICall shareInstance].handsFreeOn;
    self.muteButton.selected = [TUICall shareInstance].micMute;
    
    [self.view addSubview:self.containerStackView];
    [self.containerStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(20);
        make.bottom.equalTo(self.view).offset(-55);
    }];
    
    [self.view addSubview:self.hangupButton];
    [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-55);
    }];
    
}

- (QMUIButton *)handsfreeButton {
    
    if (!_handsfreeButton) {
        _handsfreeButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_handsfreeButton setTitle:@"免提" forState:UIControlStateNormal];
        [_handsfreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_handsfreeButton setImage:[UIImage imageNamed:@"CallMenuHandsfree"] forState:UIControlStateNormal];
        [_handsfreeButton setImage:[UIImage imageNamed:@"CallMenuHandsfreeOn"] forState:UIControlStateSelected];
        _handsfreeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _handsfreeButton.imagePosition = QMUIButtonImagePositionTop;
        _handsfreeButton.spacingBetweenImageAndTitle = 3;
        [_handsfreeButton addTarget:self action:@selector(handsfreeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _handsfreeButton;
    
}

- (QMUIButton *)muteButton {
    
    if (!_muteButton) {
        _muteButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_muteButton setTitle:@"静音" forState:UIControlStateNormal];
        [_muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"CallMenuMute"] forState:UIControlStateNormal];
        [_muteButton setImage:[UIImage imageNamed:@"CallMenuMuteOn"] forState:UIControlStateSelected];
        _muteButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _muteButton.imagePosition = QMUIButtonImagePositionTop;
        _muteButton.spacingBetweenImageAndTitle = 3;
        [_muteButton addTarget:self action:@selector(muteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _muteButton;
}

- (QMUIButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
        [_hangupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_hangupButton setImage:[UIImage imageNamed:@"CallMenuHangup"] forState:UIControlStateNormal];
        _hangupButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _hangupButton.imagePosition = QMUIButtonImagePositionTop;
        _hangupButton.spacingBetweenImageAndTitle = 3;
        [_hangupButton addTarget:self action:@selector(hangupButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _hangupButton;
    
}

- (QMUIButton *)giftButton {
    
    if (!_giftButton) {
        _giftButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_giftButton setTitle:@"礼物" forState:UIControlStateNormal];
        [_giftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_giftButton setImage:[UIImage imageNamed:@"CallMenuGift"] forState:UIControlStateNormal];
        _giftButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _giftButton.imagePosition = QMUIButtonImagePositionTop;
        _giftButton.spacingBetweenImageAndTitle = 3;
        [_giftButton addTarget:self action:@selector(giftButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _giftButton;
}

- (QMUIButton *)beautyButton {
    
    if (!_beautyButton) {
        _beautyButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_beautyButton setTitle:@"美颜" forState:UIControlStateNormal];
        [_beautyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"CallMenuBeauty"] forState:UIControlStateNormal];
        _beautyButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _beautyButton.imagePosition = QMUIButtonImagePositionTop;
        _beautyButton.spacingBetweenImageAndTitle = 3;
        [_beautyButton addTarget:self action:@selector(beautyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _beautyButton;
}


- (QMUIButton *)cameraButton {
    
    if (!_cameraButton) {
        _cameraButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setTitle:@"摄像头" forState:UIControlStateNormal];
        [_cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"CallMenuCamera"] forState:UIControlStateNormal];
        _cameraButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _cameraButton.imagePosition = QMUIButtonImagePositionTop;
        _cameraButton.spacingBetweenImageAndTitle = 3;
        [_cameraButton addTarget:self action:@selector(cameraButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cameraButton;
}

- (UIStackView *)containerStackView {
    
    if (!_containerStackView) {
        _containerStackView = [[UIStackView alloc] initWithArrangedSubviews:@[]];
        _containerStackView.spacing = 20;
        _containerStackView.axis = UILayoutConstraintAxisHorizontal;
        _containerStackView.alignment = UIStackViewAlignmentCenter;
        _containerStackView.distribution = UIStackViewDistributionFill;
    }
    return  _containerStackView;
}

- (BeautyViewController *)beautyController {
    
    if (!_beautyController) {
        _beautyController = [[BeautyViewController alloc] init];
        _beautyController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return  _beautyController;
}

- (void)handsfreeButtonTapped {
    BOOL handsFreeOn = ![TUICall shareInstance].handsFreeOn;
    [[TUICall shareInstance] handsFree:handsFreeOn];
    self.handsfreeButton.selected = handsFreeOn;
    if (handsFreeOn) {
        [THelper makeToast:@"使用扬声器" duration:1 position:CGPointMake(self.handsfreeButton.mm_centerX, self.handsfreeButton.mm_minY - 60)];
    } else {
        [THelper makeToast:@"使用听筒" duration:1 position:CGPointMake(self.handsfreeButton.mm_centerX, self.handsfreeButton.mm_minY - 60)];
    }
}

- (void)muteButtonTapped {
    BOOL micMute = ![TUICall shareInstance].micMute;
    [[TUICall shareInstance] mute:micMute];
    self.muteButton.selected = micMute;
    if (micMute) {
        [THelper makeToast:@"开启静音" duration:1 position:CGPointMake(self.muteButton.mm_centerX, self.muteButton.mm_minY - 60)];
    } else {
        [THelper makeToast:@"关闭静音" duration:1 position:CGPointMake(self.muteButton.mm_centerX, self.muteButton.mm_minY - 60)];
    }
}

- (void)giftButtonTapped {
    
    GiftViewController *vc = [[GiftViewController alloc] init];
    vc.delegate = self;
    vc.hbd_barAlpha = 0;
    vc.hbd_barHidden = true;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.hidden = YES;
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:nav animated:YES completion:^{
        nav.navigationBar.hidden = NO;
    }];
}

- (void)giftViewController:(GiftViewController *)giftController didSelectGift:(Gift *)gift {
    [self giveGifts:gift];
}

- (void)giveGifts:(Gift *)giftData {
    
    [[GiftManager shared] giveGift:self.user.userId type:2 dynamicId: nil gift:giftData block:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
            
        if (error) {
            [THelper makeToast:error.localizedDescription];
            return;
        }
        GiveGift *giveGift = [GiveGift mj_objectWithKeyValues:responseObject[@"data"]];
        if (giveGift.resultCode == 1) {
            GiftCellData *cellData = [[GiftCellData alloc] initWithDirection:MsgDirectionOutgoing];
            cellData.gift = giftData;
            
            IMData *imData = [IMData defaultData];
            imData.data = [giftData mj_JSONString];
            imData.giftRequestId = giveGift.giftRequestId;
            NSData *data = [TUICallUtils dictionary2JsonData:[imData mj_keyValues]];
            
            cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:data];
            
            User *user  = LoginManager.shared.user;
            user.userEnergy = giveGift.userEnergy;
            [LoginManager.shared updateWithUser:user];
            
            [[GiftManager shared] sendGiftMessage:cellData userID:self.user.userId];
            
            [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
                [self user:model giveGift:giftData];
            }];
        }
        else if (giveGift.resultCode == 3) { //能量不足，需要充值
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
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

- (void)beautyButtonTapped {
    
    [self presentViewController:self.beautyController animated:YES completion:nil];
}


- (void)hangupButtonTapped {
    [[TUICall shareInstance] hangup];
    if (_delegate && [_delegate respondsToSelector:@selector(callMenuViewControllerDidHangup:)]) {
        [_delegate callMenuViewControllerDidHangup:self];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:@"onCallEnd" object:nil];
}

- (void)cameraButtonTapped {
    
    self.frontCamera = !self.isFrontCamera;
    
    [[TUICall shareInstance] switchCamera:self.isFrontCamera];
}

- (JPGiftShowManager *)giftShowManager {
    
    if (!_giftShowManager) {
        _giftShowManager = [[JPGiftShowManager alloc] init];
    }
    
    return _giftShowManager;
}

- (ReportHelper *)reportHelper {
    
    if (!_reportHelper) {
        _reportHelper = [[ReportHelper alloc] init];
    }
    return _reportHelper;
}

- (void)onRecvNewMessage:(V2TIMMessage *)msg {
    
    if (msg.elemType != V2TIM_ELEM_TYPE_CUSTOM) {
        return;
    }
    
    NSDictionary *param = [TUICallUtils jsonData2Dictionary:msg.customElem.data];
    IMData *imData = [IMData mj_objectWithKeyValues:param];
    
    if (imData.type != 100) {
        return;
    }
    
    if (msg.userID != self.user.userId) {
        return;
    }

    Gift *gift = [Gift mj_objectWithKeyValues:imData.data];
    UserModel *user = [[UserModel alloc] init];
    user.avatar = msg.faceURL;
    user.name = msg.nickName;
    user.userId = msg.userID;
    [self user:user giveGift:gift];
}

- (void)user:(UserModel *)user giveGift:(Gift *)gift {
    
    JPGiftModel *giftModel = [[JPGiftModel alloc] init];
    giftModel.userId = user.userId;
    giftModel.userIcon = user.avatar;
    giftModel.userName = user.name;
    giftModel.giftName = gift.name;
    giftModel.giftImage = gift.img;
    giftModel.giftId = gift.id;
    giftModel.defaultCount = 0;
    giftModel.sendCount = gift.count;
    self.giftShowManager.topPadding = self.view.safeAreaInsets.top + 120;
    [self.giftShowManager showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
        //结束
        }
    ];
}

@end


