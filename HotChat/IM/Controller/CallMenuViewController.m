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
#import "LiveGiftShowCustom.h"
#import "LiveUserModel.h"
#import "LiveGiftListModel.h"

#import <ImSDK/V2TIMManager.h>
#import <ImSDK/V2TIMManager+Message.h>


@interface CallMenuViewController ()<GiftViewControllerDelegate, V2TIMAdvancedMsgListener, LiveGiftShowCustomDelegate>

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

@property (weak, nonatomic) IBOutlet UIView *showGiftContainerView;


@property (nonatomic ,weak) LiveGiftShowCustom * customGiftShow;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


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
    
}

-(void)dealloc {
    if ([self isViewLoaded]) {
        [[V2TIMManager sharedInstance]  removeAdvancedMsgListener:self];
    }
}


- (IBAction)followButtonTapped {
    
}
- (IBAction)reportButtonTapped {
}


- (void)setupViews {
    
    if (self.style == CallMenuStyleVideo) {
        [self.containerStackView addArrangedSubview:self.cameraButton];
        [self.containerStackView addArrangedSubview:self.beautyButton];
        [self.containerStackView addArrangedSubview:self.giftButton];
    }
    else {
        self.backgroundImageView.backgroundColor = [UIColor blackColor];
        [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatar]];
        [self.containerStackView addArrangedSubview:self.muteButton];
        [self.containerStackView addArrangedSubview:self.handsfreeButton];
        [self.containerStackView addArrangedSubview:self.giftButton];
    }
    
    
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

- (void)giftButtonTapped {
    GiftViewController *vc = [[GiftViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)giftViewController:(GiftViewController *)gift didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Gift *giftData = gift.gifts[indexPath.item];
    giftData.count = 1;
    GiftCellData *cellData = [[GiftCellData alloc] initWithDirection:MsgDirectionOutgoing];
    cellData.gift = giftData;
    
    IMData *imData = [IMData defaultData];
    imData.data = [giftData mj_JSONString];
    
    NSData *data = [TUICallUtils dictionary2JsonData:[imData mj_keyValues]];
    
    cellData.innerMessage = [[V2TIMManager sharedInstance] createCustomMessage:data];
    [self sendMessage:cellData];
    
    
    [TUICallUtils getCallUserModel:[TUICallUtils loginUser] finished:^(CallUserModel * _Nonnull model) {
        [self user:model giveGift:giftData];
    }];
    
}


- (void)sendMessage:(TUIMessageCellData *)msg
{
    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
        return;
    }
    
    UITabBarController *tabBarController = (UITabBarController *) UIApplication.sharedApplication.keyWindow.rootViewController;
    
    if (![tabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;
    
    for (UIViewController *viewController in navigationController.viewControllers) { // 没有找到IM发消息
        
        if ([viewController isKindOfClass:[ChatController class]]) {
            ChatController *chatControler = (ChatController *) viewController;
            [chatControler sendMessage:msg];
            return;
        }
    }
    
    TUIConversationCellData *conversationCellData = [[TUIConversationCellData alloc] init];
    conversationCellData.userID = self.user.userId;
    
    TUIMessageController *messageController =  [[TUIMessageController alloc] init];
    [messageController setConversation:conversationCellData];
    
    //IM发消息
    [messageController sendMessage:msg];
}

- (void)beautyButtonTapped {
    
    [self presentViewController:self.beautyController animated:YES completion:nil];
}


- (void)hangupButtonTapped {
    [[TUICall shareInstance] hangup];
    if (_delegate && [_delegate respondsToSelector:@selector(callMenuViewControllerDidHangup:)]) {
        [_delegate callMenuViewControllerDidHangup:self];
    }
}

- (void)cameraButtonTapped {
    
    self.frontCamera = !self.isFrontCamera;
    
    [[TUICall shareInstance] switchCamera:self.isFrontCamera];
}

- (LiveGiftShowCustom *)customGiftShow{
    if (!_customGiftShow) {
        _customGiftShow = [LiveGiftShowCustom addToView:self.showGiftContainerView];
        _customGiftShow.addMode = LiveGiftAddModeAdd;
        [_customGiftShow setMaxGiftCount:3];
        [_customGiftShow setShowMode:LiveGiftShowModeFromTopToBottom];
        [_customGiftShow setAppearModel:LiveGiftAppearModeLeft];
        [_customGiftShow setHiddenModel:LiveGiftHiddenModeLeft];
        [_customGiftShow enableInterfaceDebug:YES];
        _customGiftShow.delegate = self;
    }
    return _customGiftShow;
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
    
    
    LiveGiftListModel *giftModel = [[LiveGiftListModel alloc] init];
    giftModel.type = [NSString stringWithFormat:@"%ld",gift.id];
    giftModel.picUrl = gift.img;
    giftModel.name = gift.name;
    giftModel.rewardMsg = [NSString stringWithFormat:@"%@送出%@",user.name, gift.name];
    
    LiveUserModel *userModel =  [[LiveUserModel alloc] init];
    userModel.iconUrl = user.avatar;
    userModel.name = user.name;
    userModel.userId = user.userId;
    
    LiveGiftShowModel *liveGift = [LiveGiftShowModel giftModel:giftModel userModel:userModel];
    
    [self.customGiftShow addLiveGiftShowModel:liveGift];
}


@end


