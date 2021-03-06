//
//  GiftManager.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/4.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <MJExtension/MJExtension.h>
#import "HotChat-Swift.h"

@interface GiftManager ()<TMessageControllerDelegate>

@property(strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation GiftManager


+ (instancetype)shared {
    static GiftManager *gm = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (gm == nil) {
            gm = [[GiftManager alloc] init];
        }
    });
  return gm;
    
}

- (instancetype)init {
    
    if (self = [super init]) {
        NSArray *list = [[NSUserDefaults standardUserDefaults] arrayForKey:@"GiftManager.cahcheGiftList"];
        if (list) {
            _cahcheGiftList = [Gift mj_objectArrayWithKeyValuesArray:list];
        }
    }
    return  self;
}

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager =  [[AFHTTPSessionManager alloc] initWithBaseURL:Constant.APIHostURL];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    return  _manager;
}

- (void)getGiftList:(void (^)(NSArray<Gift *> * _Nonnull))block {
    [self.manager
        POST:@"Gift/giftList"
        parameters:@{@"token" : LoginManager.shared.user.token}
        headers:nil
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary   * _Nullable responseObject) {
            if (responseObject[@"data"] != nil) {
                self.cahcheGiftList = [Gift mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
                block(self.cahcheGiftList);
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"data"] forKey:@"GiftManager.cahcheGiftList"];
            }
        }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
       }
    ];
}

- (void)giveGift:(NSString *)userId type:(NSInteger)type dynamicId:(NSString *)dynamicId gift:(Gift *)gift block:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))block {
    NSMutableDictionary *parameters = @{
        @"toUserId" : userId,
        @"giftId" : gift.id,
        @"energy" : @(gift.energy),
        @"num" : @(gift.count),
        @"type" :  @(type)
    }.mutableCopy;
    
    if (dynamicId) {
        parameters[@"dynamicId"] = dynamicId;
    }
    
    [self.manager
        POST:@"Gift/giveGift"
        parameters:parameters
        headers:@{@"token" : LoginManager.shared.user.token}
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary   * _Nullable responseObject) {
            block(responseObject, nil);
        }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            block(nil, error);
       }
    ];
    
}

- (void)sendGiftMessage:(TUIMessageCellData *)msg userID: (NSString *)userID
{
    
    UITabBarController *tabBarController = nil;
    
    
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
           
            tabBarController = (UITabBarController *) window.rootViewController;
            break;
        }
    }
    
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
    conversationCellData.userID = userID;
    
    TUIMessageController *messageController =  [[TUIMessageController alloc] init];
    messageController.delegate = self;
    [messageController setConversation:conversationCellData];
    
    //IM发消息
    [messageController sendMessage:msg];
}

- (TUIMessageCell *)messageController:(TUIMessageController *)controller onShowMessageData:(TUIMessageCellData *)data {
    
    
    if ([data isKindOfClass:[GiftCellData class]]) {
        return [TUIMessageCell new];
    }
    
    return nil;
}

@end

