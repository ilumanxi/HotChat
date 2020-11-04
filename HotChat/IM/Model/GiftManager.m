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

@interface GiftManager ()

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

@end
