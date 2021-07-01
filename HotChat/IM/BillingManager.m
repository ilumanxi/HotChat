//
//  BillingManager.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/3.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "BillingManager.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import "BillingStatus.h"
#import "HotChat-Swift.h"
#import <MJExtension/MJExtension.h>

@interface BillingManager ()

@property(strong, nonatomic) AFHTTPSessionManager *manager;

@property(strong, nonatomic) BillingStatus *billingStatus;

@property(nonatomic,assign) NSTimeInterval callingTime;

@property(nonatomic,strong) dispatch_source_t secondTimer;

@property(nonatomic,strong) dispatch_source_t minuteTimer;

@property(assign, nonatomic, getter=isStartBilling) BOOL startBilling;


@end

@implementation BillingManager

- (instancetype)initWithUserId:(NSString *)userId type:(NSInteger)type {
    if (self =[super init]) {
        _userId = userId;
        _type = type;
        _roomId = [TUICall shareInstance].curRoomID;
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

- (NSString *)chargeUserID {
    
    if ([self isCharge]) {
        
        return self.userId;
        
    }
    return LoginManager.shared.user.userId;
}

- (BOOL)isCharge {
    return LoginManager.shared.user.ocSex == 1;
}

- (void)accept:(void (^)(void))block {
    NSDictionary *headers = @{
        @"token" : LoginManager.shared.user.token
    };

    NSDictionary *parameters = @{
        @"type" : @(self.type),
        @"toUserId": self.userId
    };
    @weakify(self)
    [self.manager
        POST:@"Im/call"
        parameters:parameters
        headers:headers
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
            NSString *callCode = [responseObject[@"data"][@"callCode"] stringValue];
         
             if (callCode != nil && [callCode intValue] != 1 ) {
                 NSString *msg = responseObject[@"data"][@"msg"];
                 self.errorCall([callCode intValue], msg, self.roomId );
             }
             else if ([responseObject[@"code"] intValue] != 1 ) {
                 NSString *msg = responseObject[@"msg"];
                 self.errorCall([responseObject[@"code"] intValue], msg, self.roomId );
             }
             else {
                 block();
             }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self)
            self.errorCall(error.code, error.localizedDescription, self.roomId);
//            self.errorCall(10000, error.localizedDescription);
        }
     ];
    
}

-(void)startCallChat {
    
    if (self.isStartBilling) {
        return;
    }
    
    self.startBilling = YES;
    
    NSDictionary *headers = @{
        @"token" : LoginManager.shared.user.token
    };
    
   

    NSDictionary *parameters = @{
        @"type" : @(self.type),
        @"toUserId": self.userId,
        @"roomId": @(self.roomId)
    };
    
    NSLog(@"********roomId: %@", parameters);
    @weakify(self)
   [self.manager
        POST:@"Im/startCallChat"
        parameters:parameters      
        headers:headers
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary  * _Nullable responseObject) {
            @strongify(self)
           if ([responseObject[@"code"] intValue] == 1 ) {
               self.billingStatus = [BillingStatus mj_objectWithKeyValues:responseObject[@"data"]];
               [self startCallingTime];
           }
           else {
               NSString *msg = responseObject[@"msg"];
               self.errorCall([responseObject[@"code"] intValue], msg, self.roomId );
           }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            @strongify(self)
            self.errorCall(error.code, error.localizedDescription, self.roomId);
        }
     ];
    
    
}

- (void)startCallingTime {
    
    self.callingTime = 0;
    self.secondTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.secondTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.secondTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callingTime += 1;
        });
    });
    dispatch_resume(self.secondTimer);
    
    self.minuteTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.minuteTimer, DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.minuteTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callContinued];
        });
    });
    dispatch_resume(self.minuteTimer);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEnd) name:@"onCallEnd" object:nil];
}

- (void)onCallEnd {
    [self endCallingTime];
}

- (void)endCallingTime {
    
    if (self.secondTimer) {
        dispatch_cancel(self.secondTimer);
        self.secondTimer = nil;
    }
    
    if (self.minuteTimer) {
        dispatch_cancel(self.minuteTimer);
        self.minuteTimer = nil;
    }
}

- (void)callContinued {
    
    if (!self.startBilling) {
        [self endCallingTime];
        return;
    }
    
    if (self.billingStatus == nil) {
        return;
    }
    
    NSDictionary *headers = @{
        @"token" : LoginManager.shared.user.token
    };

    NSTimeInterval nowTime = self.billingStatus.callStartTime + self.callingTime;
    
    NSDictionary *parameters = @{
        @"callId" : self.billingStatus.callId,
        @"nowTime": @(nowTime)
    };
    
    NSLog(@"callContinued: %@", parameters);
    @weakify(self)
   [self.manager
        POST:@"Im/callContinued"
        parameters:parameters
        headers:headers
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary  * _Nullable responseObject) {
       @strongify(self)
          NSString *callCode = [responseObject[@"data"][@"callCode"] stringValue];
       
           if (callCode != nil && [callCode intValue] != 1 ) {
               NSString *msg = responseObject[@"data"][@"msg"];
               self.errorCall([callCode intValue], msg, self.roomId);
           }
           else if ([responseObject[@"code"] intValue] != 1 ) {
               NSString *msg = responseObject[@"msg"];
               [self endCallingTime];
               self.errorCall(1000, msg, self.roomId);
               
           }
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            @strongify(self)
           if (error.code != -1005) {
               self.errorCall(error.code, error.localizedDescription, self.roomId);
               [self endCallingTime];
           }
           else {
               NSLog(@"网络问题");
           }
       }
           
     ];
    
}

- (void)dealloc
{
    [self endCallingTime];
}


- (void)endCallChat {
    
    if (self.billingStatus == nil) {
        return;
    }

    [self endCallingTime];
    NSDictionary *headers = @{
        @"token" : LoginManager.shared.user.token
    };
    NSTimeInterval nowTime = self.billingStatus.callStartTime + self.callingTime;
    
    NSDictionary *parameters = @{
        @"callId" : self.billingStatus.callId,
        @"endTime": @(nowTime)
    };
    NSLog(@"endCallChat: %@", parameters);
    @weakify(self)
   [self.manager
        POST:@"Im/endCallChat"
        parameters:parameters
        headers:headers
        progress:nil
        success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary  * _Nullable responseObject) {
          @strongify(self)
       
           if (self) {
               NSString *callCode = [responseObject[@"data"][@"callCode"] stringValue];
            
                if (callCode != nil && [callCode intValue] != 1 ) {
                    NSString *msg = responseObject[@"data"][@"msg"];
                    self.errorCall([callCode intValue], msg, self.roomId);
                }
                else if ([responseObject[@"code"] intValue] != 1 ) {
                    NSString *msg = responseObject[@"msg"];
                    self.errorCall([responseObject[@"code"] intValue], msg, self.roomId);
                }
           }
          
        }
        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            @strongify(self)
           if (self) {
               self.errorCall(error.code, error.localizedDescription, self.roomId);
           }
        }
     ];
}


@end
