//
//  CallManager.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/19.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "CallManager.h"

#import "TUICallManager.h"
#import "TUICallUtils.h"
#import "TUISelectMemberViewController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "VideoCallViewController.h"
#import "AudioCallViewController.h"
#import "THelper.h"
#import "PIPWindow.h"

typedef NS_ENUM(NSInteger,VideoUserRemoveReason){
    VideoUserRemoveReason_Leave = 0,
    VideoUserRemoveReason_Reject,
    VideoUserRemoveReason_Noresp,
    VideoUserRemoveReason_Busy,
};

@interface CallManager()<TUICallDelegate>
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,strong)UIViewController *callVC;
@property(nonatomic,assign)CallType type;
@end

@implementation CallManager
+(CallManager *)shareInstance {
    static dispatch_once_t onceToken;
    static CallManager * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[CallManager alloc] init];
    });
    return g_sharedInstance;
}

- (void)initCall {
    [[TUICall shareInstance] setDelegate:self];
}

- (void)unInitCall {
    [[TUICall shareInstance] setDelegate:nil];
}

- (void)call:(NSString *)groupID userID:(NSString *)userID callType:(CallType)callType {
    self.groupId = groupID;
    self.userId = userID;
    self.type = callType;
    [self setupUI];
}

- (void)onReceiveGroupCallAPNs:(V2TIMSignalingInfo *)signalingInfo {
    [[TUICall shareInstance] onReceiveGroupCallAPNs:signalingInfo];
}

-(void)setupUI {
    if (self.groupId.length > 0) {
        TUISelectMemberViewController *selectVC = [[TUISelectMemberViewController alloc] init];
        selectVC.groupId = self.groupId;
        UITabBarController *tab = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *nav = tab.selectedViewController;
        [nav pushViewController:selectVC animated:YES];
        @weakify(self)
        selectVC.selectedFinished = ^(NSMutableArray<UserModel *> * _Nonnull modelList) {
            @strongify(self)
            NSMutableArray *userIds = [NSMutableArray array];
            NSMutableArray *inviteeList = [NSMutableArray array];
            for (UserModel *model in modelList) {
                [userIds addObject:model.userId];
                [inviteeList addObject:[self covertUser:model isEnter:NO]];
            }
            [self showCallVC:inviteeList sponsor:nil];
            [[TUICall shareInstance] call:userIds groupID:self.groupId type:self.type];
        };
    } else {
        [TUICallUtils getCallUserModel:self.userId finished:^(CallUserModel * _Nonnull model) {
            NSMutableArray *inviteeList = [NSMutableArray array];
            model.userId = self.userId;
            [inviteeList addObject:model];
            [self showCallVC:inviteeList sponsor:nil];
            [[TUICall shareInstance] call:@[self.userId] groupID:nil type:self.type];
        }];
    }
}

- (void)showCallVC:(NSMutableArray<CallUserModel *> *)invitedList sponsor:(CallUserModel *)sponsor {
    if (self.type == CallType_Video) {
        self.callVC = [[VideoCallViewController alloc] initWithSponsor:sponsor userList:invitedList];
        VideoCallViewController *videoVC = (VideoCallViewController *)self.callVC;
        videoVC.dismissBlock = ^{
            self.callVC = nil;
        };
        [videoVC setModalPresentationStyle:UIModalPresentationFullScreen];
        [PIPWindow presentViewController:self.callVC animated:YES completion:nil];
    } else {
        self.callVC = [[AudioCallViewController alloc] initWithSponsor:sponsor userList:invitedList];
        AudioCallViewController *audioVC = (AudioCallViewController *)self.callVC;
        audioVC.dismissBlock = ^{
            self.callVC = nil;
        };
        [PIPWindow presentViewController:self.callVC animated:YES completion:nil];
    }
}

- (CallUserModel *)covertUser:(UserModel *)user isEnter:(BOOL)isEnter {
    CallUserModel *callModel = [[CallUserModel alloc] init];
    callModel.name = user.name;
    callModel.avatar = user.avatar;
    callModel.userId = user.userId;
    callModel.isEnter = isEnter;
    if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
        VideoCallViewController *videoVC = (VideoCallViewController *)self.callVC;
        CallUserModel *oldUser = [videoVC getUserById:user.userId];
        callModel.isVideoAvaliable = oldUser.isVideoAvaliable;
    }
    return callModel;
}

#pragma mark TUICallDelegate
-(void)onError:(int)code msg:(NSString *)msg {
    NSLog(@"📳 onError: code:%d msg:%@",code,msg);
}
   
-(void)onInvited:(NSString *)sponsor userIds:(NSArray *)userIds isFromGroup:(BOOL)isFromGroup callType:(CallType)callType {
    NSLog(@"📳 onError: sponsor:%@ userIds:%@",sponsor,userIds);
    NSMutableArray *userIdList = [NSMutableArray array];
    [userIdList addObject:sponsor];
    [userIdList addObjectsFromArray:userIds];
    self.type = callType;
    @weakify(self)
    [[V2TIMManager sharedInstance] getUsersInfo:userIdList succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        @strongify(self)
        CallUserModel *sponsorModel = [[CallUserModel alloc] init];
        NSMutableArray *inviteeList = [NSMutableArray array];
        for (V2TIMUserFullInfo *info in infoList) {
            CallUserModel *model = [[CallUserModel alloc] init];
            model.name = info.nickName;
            model.avatar = info.faceURL;
            model.userId = info.userID;
            if ([model.userId isEqualToString:sponsor]) {
                sponsorModel = model;
            } else {
                [inviteeList addObject:model];
            }
            if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
                CallUserModel *oldModel = [(VideoCallViewController *)self.callVC getUserById:model.userId];
                model.isVideoAvaliable = oldModel.isVideoAvaliable;
            }
            if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
                CallUserModel *oldModel = [(AudioCallViewController *)self.callVC getUserById:model.userId];
                model.isVideoAvaliable = oldModel.isVideoAvaliable;
            }
        }
        [self showCallVC:inviteeList sponsor:sponsorModel];
    } fail:nil];
}
   
-(void)onGroupCallInviteeListUpdate:(NSArray *)userIds {
    NSLog(@"📳 onGroupCallInviteeListUpdate userIds:%@",userIds);
}
   
-(void)onUserEnter:(NSString *)uid {
    NSLog(@"📳 onUserEnter uid:%@",uid);
    @weakify(self)
    [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
        @strongify(self)
        if (model) {
            model.isEnter = YES;
        }
        if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
            
            VideoCallViewController *videoVC = (VideoCallViewController *)self.callVC;
            
            CallUserModel *oldModel = [videoVC getUserById:model.userId];
            model.isVideoAvaliable = oldModel.isVideoAvaliable;
            [videoVC enterUser:model];
        }
        if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
            AudioCallViewController *audioVC = (AudioCallViewController *) self.callVC;
            
            CallUserModel *oldModel = [audioVC getUserById:model.userId];
            model.isVideoAvaliable = oldModel.isVideoAvaliable;
            [audioVC enterUser:model];

        }
    }];
}
   
-(void)onUserLeave:(NSString *)uid {
    NSLog(@"📳 onUserLeave uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Leave];
}

-(void)onReject:(NSString *)uid {
    NSLog(@"📳 onReject uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Reject];
}

-(void)onNoResp:(NSString *)uid {
    NSLog(@"📳 onNoResp uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Noresp];
}

-(void)onLineBusy:(NSString *)uid {
    NSLog(@"📳 onLineBusy uid:%@",uid);
    [self removeUserFromCallVC:uid reason:VideoUserRemoveReason_Busy];
}

-(void)onCallingCancel:(NSString *)uid {
    NSLog(@"📳 onCallingCancel");
    if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
        [(VideoCallViewController *)self.callVC disMiss];
        [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    }
    if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
        [(AudioCallViewController *)self.callVC disMiss];
        [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    }
    [THelper makeToast:[NSString stringWithFormat:@"%@ 取消了通话",uid]];
}
   
-(void)onCallingTimeOut {
    NSLog(@"📳 onCallingTimeOut");
    if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
        [(VideoCallViewController *)self.callVC disMiss];
        [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    }
    if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
        [(AudioCallViewController *)self.callVC disMiss];
        [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)onCallEnd {
    NSLog(@"📳 onCallEnd");
    if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
        [(VideoCallViewController *)self.callVC disMiss];
        [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    }
    if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
        [(AudioCallViewController *)self.callVC disMiss];
        [PIPWindow dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)onUserVideoAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"📳 onUserVideoAvailable:%@ available:%d",uid,available);
    if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
        VideoCallViewController *videoVC = (VideoCallViewController *)self.callVC;
        CallUserModel *model = [videoVC getUserById:uid];
        if (model) {
            model.isEnter = YES;
            model.isVideoAvaliable = available;
            [videoVC updateUser:model animate:NO];
        } else {
            [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
                model.isEnter = YES;
                model.isVideoAvaliable = available;
                [videoVC enterUser:model];
            }];
        }
    }
}
   
-(void)onUserAudioAvailable:(NSString *)uid available:(BOOL)available {
    NSLog(@"📳 onUserAudioAvailable:%@ available:%d",uid,available);
    if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
        AudioCallViewController *videoVC = (AudioCallViewController *)self.callVC;
        CallUserModel *model = [videoVC getUserById:uid];
        if (model) {
            model.isEnter = YES;
            [videoVC updateUser:model animate:NO];
        } else {
            [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
                model.isEnter = YES;
                [videoVC enterUser:model];
            }];
        }
    }
}
   
-(void)onUserVoiceVolume:(NSString *)uid volume:(UInt32)volume {
    if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
        AudioCallViewController *videoVC = (AudioCallViewController *)self.callVC;
        CallUserModel *model = [videoVC getUserById:uid];
        if (model) {
            model.volume = (CGFloat)volume / 100;
            [videoVC updateUser:model animate:NO];
        } else {
            [TUICallUtils getCallUserModel:uid finished:^(CallUserModel * _Nonnull model) {
                model.isEnter = YES;
                model.volume = (CGFloat)volume / 100;
                [videoVC enterUser:model];
            }];
        }
    }
}
   
- (void)removeUserFromCallVC:(NSString *)uid reason:(VideoUserRemoveReason)reason {
    if ([self.callVC isKindOfClass:[VideoCallViewController class]]) {
        VideoCallViewController *videoVC = (VideoCallViewController *)self.callVC;
        [videoVC leaveUser:uid];
    }
    if ([self.callVC isKindOfClass:[AudioCallViewController class]]) {
        AudioCallViewController *audioVC = (AudioCallViewController *)self.callVC;
        [audioVC leaveUser:uid];
    }
}
@end
