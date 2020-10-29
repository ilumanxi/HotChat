//
//  CallMenuViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "CallMenuViewController.h"
#import <QMUIKit/QMUIButton.h>
#import "UIView+Additions.h"
#import "TUICallUtils.h"
#import "THeader.h"
#import "THelper.h"
#import "TUICall.h"
#import "TUICall+TRTC.h"
#import "BeautyViewController.h"

@interface CallMenuViewController ()

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



@end

@implementation CallMenuViewController


- (instancetype)initWithStyle:(CallMenuStyle)style {
    if (self = [super init]) {
        _frontCamera = YES;
        _style = style;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupViews];
}


- (void)setupViews {
    
    if (self.style == CallMenuStyleVideo) {
        [self.containerStackView addArrangedSubview:self.cameraButton];
        [self.containerStackView addArrangedSubview:self.beautyButton];
        [self.containerStackView addArrangedSubview:self.giftButton];
    }
    else {
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

@end
