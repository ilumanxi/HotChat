//
//  TUIChatController.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIChatController.h"
#import "ChatController.h"
#import "THeader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIGroupPendencyViewModel.h"
#import "TUIMessageController.h"
#import "TUISelectMemberViewController.h"
#import "TUITextMessageCellData.h"
#import "TUIImageMessageCellData.h"
#import "TUIVideoMessageCellData.h"
#import "TUIFileMessageCellData.h"
#import "TUIGroupPendencyController.h"
#import "TUIFriendProfileControllerServiceProtocol.h"
#import "TUIUserProfileControllerServiceProtocol.h"
#import "TCServiceManager.h"
#import "Toast/Toast.h"
#import "THelper.h"
#import "UIColor+TUIDarkMode.h"
#import "TUICallManager.h"
#import "TUIKit.h"
#import "TUIGroupLiveMessageCell.h"
#import "GiftCellData.h"
#import "GiftManager.h"
#import "GiveGift.h"
#import <MJExtension/MJExtension.h>
#import "HotChat-Swift.h"
#import "JPGiftModel.h"
#import "JPGiftShowManager.h"
#import <SPAlertController/SPAlertController.h>

@interface ChatController () <TMessageControllerDelegate, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) TUIConversationCellData *conversationData;
@property (nonatomic, strong) UIView *tipsView;
@property (nonatomic, strong) UILabel *pendencyLabel;
@property (nonatomic, strong) UIButton *pendencyBtn;
@property (nonatomic, strong) UIButton *atBtn;
@property (nonatomic, strong) TUIGroupPendencyViewModel *pendencyViewModel;
@property (nonatomic, strong) NSMutableArray<UserModel *> *atUserList;
@property (nonatomic, assign) BOOL responseKeyboard;

@property (nonatomic, strong) JPGiftShowManager * giftShowManager;

@property (nonatomic, strong) GiftEffectsController * giftEffectsController;

@end

@implementation ChatController

- (instancetype)initWithConversation:(TUIConversationCellData *)conversationData;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _conversationData = conversationData;

        NSMutableArray *moreMenus = [NSMutableArray array];
        [moreMenus addObject:[TUIInputMoreCellData photoData]];
        [moreMenus addObject:[TUIInputMoreCellData pictureData]];
        [moreMenus addObject:[TUIInputMoreCellData videoData]];
        [moreMenus addObject:[TUIInputMoreCellData fileData]];
        [moreMenus addObject:[TUIInputMoreCellData videoCallData]];
        [moreMenus addObject:[TUIInputMoreCellData audioCallData]];
        if ([TUIKit sharedInstance].config.enableGroupLiveEntry && conversationData.groupID.length > 0) {
            [moreMenus addObject:[TUIInputMoreCellData groupLivePalyData]];
        }
        _moreMenus = moreMenus;

        if (self.conversationData.groupID.length > 0) {
            _pendencyViewModel = [TUIGroupPendencyViewModel new];
            _pendencyViewModel.groupId = _conversationData.groupID;
        }
        
        self.atUserList = [NSMutableArray array];
    }
    return self;
}

- (JPGiftShowManager *)giftShowManager {
    
    if (!_giftShowManager) {
        _giftShowManager = [[JPGiftShowManager alloc] init];
    }
    
    return _giftShowManager;
}

- (GiftEffectsController *)giftEffectsController {
    if (!_giftEffectsController) {
        _giftEffectsController = [[GiftEffectsController alloc] initWithOwner: self];
    }
    return _giftEffectsController;
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
    
    if (msg.userID != self.conversationData.userID) {
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
    self.giftShowManager.topPadding = self.view.safeAreaInsets.top;
    [self.giftShowManager showGiftViewWithBackView:self.view info:giftModel completeBlock:^(BOOL finished) {
        //结束
        }
    ];
    
    [self.giftEffectsController addQueue: gift];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
//    [[V2TIMManager sharedInstance]  addAdvancedMsgListener:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageNotification:) name:TUIKitNotification_TIMMessageListener object:nil];
}

-(void)messageNotification:(NSNotification *)notification {
    V2TIMMessage *msg = (V2TIMMessage *) notification.object;
    
    [self onRecvNewMessage:msg];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.responseKeyboard = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.responseKeyboard = NO;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        [self saveDraft];
    }
}

- (CGFloat)inputBarHeight {
    return InputBar_Height;
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    @weakify(self)
    //message
    _messageController = [[TUIMessageController alloc] init];
    _messageController.delegate = self;
    [self addChildViewController:_messageController];
    if (self.inputBarHeight > 0) {
        _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.inputBarHeight - Bottom_SafeHeight);
    }
    else {
        _messageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.inputBarHeight);
    }
    [self.view addSubview:_messageController.view];
    [_messageController setConversation:self.conversationData];
    
    if (self.inputBarHeight > 0) {
        //input
        _inputController = [[InputController alloc] init];
        [self addChildViewController:_inputController];
        [self.view addSubview:_inputController.view];
        _inputController.view.frame = CGRectMake(0, self.view.frame.size.height - self.inputBarHeight - Bottom_SafeHeight, self.view.frame.size.width, self.inputBarHeight + Bottom_SafeHeight);
        _inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _inputController.delegate = self;
        [RACObserve(self, moreMenus) subscribeNext:^(NSArray *x) {
            @strongify(self)
            [self.inputController.moreView setData:x];
        }];
        
        [_inputController didMoveToParentViewController:self];
        _inputController.inputBar.inputTextView.text = self.conversationData.draftText;
    }

    self.tipsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tipsView.backgroundColor = RGB(246, 234, 190);
    [self.view addSubview:self.tipsView];
    self.tipsView.mm_height(24).mm_width(self.view.mm_w);

    self.pendencyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.tipsView addSubview:self.pendencyLabel];
    self.pendencyLabel.font = [UIFont systemFontOfSize:12];


    self.pendencyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tipsView addSubview:self.pendencyBtn];
    [self.pendencyBtn setTitle:@"点击处理" forState:UIControlStateNormal];
    [self.pendencyBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pendencyBtn addTarget:self action:@selector(openPendency:) forControlEvents:UIControlEventTouchUpInside];
    [self.pendencyBtn sizeToFit];
    self.tipsView.hidden = YES;


    [RACObserve(self.pendencyViewModel, unReadCnt) subscribeNext:^(NSNumber *unReadCnt) {
        @strongify(self)
        if ([unReadCnt intValue]) {
            self.pendencyLabel.text = [NSString stringWithFormat:@"%@条入群请求", unReadCnt];
            [self.pendencyLabel sizeToFit];
            CGFloat gap = (self.tipsView.mm_w - self.pendencyLabel.mm_w - self.pendencyBtn.mm_w-8)/2;
            self.pendencyLabel.mm_left(gap).mm__centerY(self.tipsView.mm_h/2);
            self.pendencyBtn.mm_hstack(8);

            [UIView animateWithDuration:1.f animations:^{
                self.tipsView.hidden = NO;
                self.tipsView.mm_top(self.navigationController.navigationBar.mm_maxY);
            }];
        } else {
            self.tipsView.hidden = YES;
        }
    }];
    [self getPendencyList];
    
    //监听入群请求通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPendencyList) name:TUIKitNotification_onReceiveJoinApplication object:nil];
    
    //群 @ ,UI 细节比较多，放在二期实现
//    if (self.conversationData.groupID.length > 0 && self.conversationData.atMsgSeqList.count > 0) {
//        self.atBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.mm_w - 100, 100, 100, 40)];
//        [self.atBtn setTitle:@"有人@我" forState:UIControlStateNormal];
//        [self.atBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [self.atBtn setBackgroundColor:[UIColor whiteColor]];
//        [self.atBtn addTarget:self action:@selector(loadMessageToAT) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:_atBtn];
//    }
}

- (void)getPendencyList
{
    if (self.conversationData.groupID.length > 0)
        [self.pendencyViewModel loadData];
}

- (void)openPendency:(id)sender
{
    TUIGroupPendencyController *vc = [[TUIGroupPendencyController alloc] init];
    vc.viewModel = self.pendencyViewModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputController:(InputController *)inputController didChangeHeight:(CGFloat)height
{
    if (!self.responseKeyboard) {
        return;
    }
    __weak typeof(self) ws = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = ws.messageController.view.frame;
        msgFrame.size.height = ws.view.frame.size.height - height;
        ws.messageController.view.frame = msgFrame;

        CGRect inputFrame = ws.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        ws.inputController.view.frame = inputFrame;
        [ws.messageController scrollToBottom:NO];
    } completion:nil];
}

- (void)inputController:(InputController *)inputController didSendMessage:(TUIMessageCellData *)msg
{
    if ([msg isKindOfClass:[TUITextMessageCellData class]]) {
        NSMutableArray *userIDList = [NSMutableArray array];
        for (UserModel *model in self.atUserList) {
            [userIDList addObject:model.userId];
        }
        if (userIDList.count > 0) {
            [msg setAtUserList:userIDList];
        }
        //消息发送完后 atUserList 要重置
        [self.atUserList removeAllObjects];
    }
    
    if ([msg isKindOfClass:[TextMessageCellData class]]) {
        NSMutableArray *userIDList = [NSMutableArray array];
        for (UserModel *model in self.atUserList) {
            [userIDList addObject:model.userId];
        }
        if (userIDList.count > 0) {
            [msg setAtUserList:userIDList];
        }
        //消息发送完后 atUserList 要重置
        [self.atUserList removeAllObjects];
    }
    
    
    [_messageController sendMessage:msg];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:msg];
    }
}


- (void)inputControllerDidSayHello:(InputController *)inputController {
    
}

- (void)inputControllerDidAudio:(InputController *)inputController {
    
}

- (void)inputControllerDidVideo:(InputController *)inputController {
    
}

- (void)inputControllerDidPhoto:(InputController *)inputController {
    
}

- (void)inputControllerDidInputAt:(InputController *)inputController
{
    // 检测到 @ 字符的输入
    if (_conversationData.groupID.length > 0) {
        TUISelectMemberViewController *vc = [[TUISelectMemberViewController alloc] init];
        vc.groupId = _conversationData.groupID;
        vc.name = @"选择群成员";
        vc.selectedFinished = ^(NSMutableArray<UserModel *> * _Nonnull modelList) {
            NSMutableString *atText = [[NSMutableString alloc] init];
            for (int i = 0; i < modelList.count; i++) {
                UserModel *model = modelList[i];
                [self.atUserList addObject:model];
                if (i == 0) {
                    [atText appendString:[NSString stringWithFormat:@"%@ ",model.name]];
                } else {
                    [atText appendString:[NSString stringWithFormat:@"@%@ ",model.name]];
                }
            }
            NSString *inputText = self.inputController.inputBar.inputTextView.text;
            self.inputController.inputBar.inputTextView.text = [NSString stringWithFormat:@"%@%@ ",inputText,atText];
            [self.inputController.inputBar updateTextViewFrame];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)inputController:(InputController *)inputController didDeleteAt:(NSString *)atText
{
    // 删除了 @ 信息，atText 格式为：@xxx空格
    for (UserModel *user in self.atUserList) {
        if ([atText rangeOfString:user.name].location != NSNotFound) {
            [self.atUserList removeObject:user];
            break;
        }
    }
}

- (void)sendMessage:(TUIMessageCellData *)message
{
    [_messageController sendMessage:message];
}

- (void)sendMessageDict:(NSDictionary *)msgDict {
    NSString *className = msgDict[@"className"];
    Class cellDataClass = NSClassFromString(className);
    SEL selector = @selector(initWithDict:);
    if (cellDataClass && [cellDataClass instancesRespondToSelector:selector]) {
        TUIMessageCellData *msgData = [[cellDataClass alloc] initWithDict:msgDict];
        msgData.direction = MsgDirectionOutgoing;
        [self sendMessage:msgData];
    }
}

- (void)saveDraft
{
    NSString *draft = self.inputController.inputBar.inputTextView.text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[V2TIMManager sharedInstance] setConversationDraft:self.conversationData.conversationID draftText:draft succ:nil fail:nil];
}

- (void)inputController:(InputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    cell.disableDefaultSelectAction = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]){
        [_delegate chatController:self onSelectMoreCell:cell];
    }
    if (cell.disableDefaultSelectAction) {
        return;
    }
    if (cell.data == [TUIInputMoreCellData photoData]) {
        [self selectPhotoForSend];
    }
    if (cell.data == [TUIInputMoreCellData videoData]) {
        [self takeVideoForSend];
    }
    if (cell.data == [TUIInputMoreCellData fileData]) {
        [self selectFileForSend];
    }
    if (cell.data == [TUIInputMoreCellData pictureData]) {
        [self takePictureForSend];
    }
    if (cell.data == [TUIInputMoreCellData videoCallData]) {
        [self videoCall];
    }
    if (cell.data == [TUIInputMoreCellData audioCallData]) {
        [self audioCall];
    }
    if (cell.data == [TUIInputMoreCellData groupLivePalyData]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyGroupLiveOnSelectMoreCell" object:nil userInfo:@{
            @"groupID":_conversationData.groupID?:@"",
            @"msgSender": self,
        }];
    }
}

- (void)didTapInMessageController:(TUIMessageController *)controller
{
    [_inputController reset];
}

- (BOOL)messageController:(TUIMessageController *)controller willShowMenuInCell:(TUIMessageCell *)cell
{
    if([_inputController.inputBar.inputTextView isFirstResponder]){
        _inputController.inputBar.inputTextView.overrideNextResponder = cell;
        return YES;
    }
    return NO;
}

- (TUIMessageCellData *)messageController:(TUIMessageController *)controller onNewMessage:(V2TIMMessage *)data
{
    if ([self.delegate respondsToSelector:@selector(chatController:onNewMessage:)]) {
        return [self.delegate chatController:self onNewMessage:data];
    }
    return nil;
}

- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    if ([self.delegate respondsToSelector:@selector(chatController:onShowMessageData:)]) {
        return [self.delegate chatController:self onShowMessageData:data];
    }
    return nil;
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageAvatar:(TUIMessageCell *)cell
{
    if (cell.messageData.identifier == nil)
        return;

    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageAvatar:)]) {
        [self.delegate chatController:self onSelectMessageAvatar:cell];
        return;
    }

    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendsInfo:@[cell.messageData.identifier] succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        V2TIMFriendInfoResult *result = resultList.firstObject;
        if (result.relation == V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST || result.relation == V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY) {
            @strongify(self)
            id<TUIFriendProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIFriendProfileControllerServiceProtocol)];
            if ([vc isKindOfClass:[UIViewController class]]) {
                vc.friendProfile = result.friendInfo;
                [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
            }
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:@[cell.messageData.identifier] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                @strongify(self)
                id<TUIUserProfileControllerServiceProtocol> vc = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileControllerServiceProtocol)];
                if ([vc isKindOfClass:[UIViewController class]]) {
                    vc.userFullInfo = infoList.firstObject;
                    if ([vc.userFullInfo.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                        vc.actionType = PCA_NONE;
                    } else {
                        vc.actionType = PCA_ADD_FRIEND;
                    }
                    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
                }
            } fail:^(int code, NSString *msg) {
                [THelper makeToastError:code msg:msg];
            }];
        }
    } fail:^(int code, NSString *msg) {
        [THelper makeToastError:code msg:msg];
    }];
}

- (void)messageController:(TUIMessageController *)controller onSelectMessageContent:(TUIMessageCell *)cell
{
    cell.disableDefaultSelectAction = NO;
    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageContent:)]) {
        [self.delegate chatController:self onSelectMessageContent:cell];
    }
    if (cell.disableDefaultSelectAction) {
        return;
    }
    if ([cell isKindOfClass:[TUIGroupLiveMessageCell class]]) {
        TUIGroupLiveMessageCellData *celldata = [(TUIGroupLiveMessageCell *)cell customData];
        NSDictionary *roomInfo = celldata.roomInfo;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUINotifyGroupLiveOnSelectMessage" object:nil userInfo:@{
            @"roomInfo": roomInfo,
            @"groupID": _conversationData.groupID?:@"",
            @"msgSender": self,
        }];
    }
}

- (void)didHideMenuInMessageController:(TUIMessageController *)controller
{
    _inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

// ----------------------------------
- (void)selectPhotoForSend
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takePictureForSend
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.cameraCaptureMode =UIImagePickerControllerCameraCaptureModePhoto;
    picker.delegate = self;

    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takeVideoForSend
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    [picker setVideoMaximumDuration:15];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)selectFileForSend
{
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)videoCall
{
    [[TUICallManager shareInstance] call:self.conversationData.groupID userID:self.conversationData.userID callType:CallType_Video];
}

- (void)audioCall
{
    [[TUICallManager shareInstance] call:self.conversationData.groupID userID:self.conversationData.userID callType:CallType_Audio];
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 快速点的时候会回调多次
    @weakify(self)
    picker.delegate = nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if([mediaType isEqualToString:(NSString *)kUTTypeImage]){
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageOrientation imageOrientation = image.imageOrientation;
            if(imageOrientation != UIImageOrientationUp)
            {
//                CGFloat aspectRatio = MIN ( 1920 / image.size.width, 1920 / image.size.height );
//                CGFloat aspectWidth = image.size.width * aspectRatio;
//                CGFloat aspectHeight = image.size.height * aspectRatio;
//
//                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
//                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
//                image = UIGraphicsGetImageFromCurrentImageContext();
//                UIGraphicsEndImageContext();
            }
//
//            NSData *data = UIImageJPEGRepresentation(image, 0.5);
                
            NSData *data = [UIImage zipNSDataWithImage:image];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [THelper genImageName:nil]];
            NSString *path = [TUIKit_Image_Path stringByAppendingString:fileName];
            [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
            
            TUIImageMessageCellData *uiImage = [[TUIImageMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiImage.path = path;
            uiImage.length = data.length;
            [self sendMessage:uiImage];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:uiImage];
            }
        }
        else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            
            if(![url.pathExtension  isEqual: @"mp4"]) {
                NSString* tempPath = NSTemporaryDirectory();
                NSURL *urlName = [url URLByDeletingPathExtension];
                NSURL *newUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@%@.mp4", tempPath,[urlName.lastPathComponent stringByRemovingPercentEncoding]]];
                // mov to mp4
                AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
                 exportSession.outputURL = newUrl;
                 exportSession.outputFileType = AVFileTypeMPEG4;
                 exportSession.shouldOptimizeForNetworkUse = YES;

                 [exportSession exportAsynchronouslyWithCompletionHandler:^{
                 switch ([exportSession status])
                 {
                      case AVAssetExportSessionStatusFailed:
                           NSLog(@"Export session failed");
                           break;
                      case AVAssetExportSessionStatusCancelled:
                           NSLog(@"Export canceled");
                           break;
                      case AVAssetExportSessionStatusCompleted:
                      {
                           //Video conversion finished
                           NSLog(@"Successful!");
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self sendVideoWithUrl:newUrl];
                          });
                      }
                           break;
                      default:
                           break;
                  }
                 }];
            } else {
                [self sendVideoWithUrl:url];
            }
        }
    }];
}

- (void)sendVideoWithUrl:(NSURL*)url {
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    NSString *videoPath = [NSString stringWithFormat:@"%@%@.mp4", TUIKit_Video_Path, [THelper genVideoName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:videoPath contents:videoData attributes:nil];
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset =  [AVURLAsset URLAssetWithURL:url options:opts];
    NSInteger duration = (NSInteger)urlAsset.duration.value / urlAsset.duration.timescale;
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(192, 192);
    NSError *error = nil;
    CMTime actualTime;
    CMTime time = CMTimeMakeWithSeconds(0.0, 10);
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imagePath = [TUIKit_Video_Path stringByAppendingString:[THelper genSnapshotName:nil]];
    [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    
    TUIVideoMessageCellData *uiVideo = [[TUIVideoMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
    uiVideo.snapshotPath = imagePath;
    uiVideo.snapshotItem = [[TUISnapshotItem alloc] init];
    UIImage *snapshot = [UIImage imageWithContentsOfFile:imagePath];
    uiVideo.snapshotItem.size = snapshot.size;
    uiVideo.snapshotItem.length = imageData.length;
    uiVideo.videoPath = videoPath;
    uiVideo.videoItem = [[TUIVideoItem alloc] init];
    uiVideo.videoItem.duration = duration;
    uiVideo.videoItem.length = videoData.length;
    uiVideo.videoItem.type = url.pathExtension;
    uiVideo.uploadProgress = 0;
    [self sendMessage:uiVideo];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:uiVideo];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    [url startAccessingSecurityScopedResource];
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    @weakify(self)
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        @strongify(self)
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        NSString *fileName = [url lastPathComponent];
        NSString *filePath = [TUIKit_File_Path stringByAppendingString:fileName];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            TUIFileMessageCellData *uiFile = [[TUIFileMessageCellData alloc] initWithDirection:MsgDirectionOutgoing];
            uiFile.path = filePath;
            uiFile.fileName = fileName;
            uiFile.length = (int)fileSize;
            uiFile.uploadProgress = 0;
            [self sendMessage:uiFile];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
                [self.delegate chatController:self didSendMessage:uiFile];
            }
        }
    }];
    [url stopAccessingSecurityScopedResource];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
