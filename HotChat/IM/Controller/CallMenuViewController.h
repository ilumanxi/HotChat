//
//  CallMenuViewController.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICallModel.h"
@class CallMenuViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol CallMenuViewControllerDelegate <NSObject>

- (void)callMenuViewControllerDidHangup:(CallMenuViewController *)menu;

@end

typedef NS_ENUM(NSInteger, CallMenuStyle) {
    CallMenuStyleVideo,
    CallMenuStyleAudio
};


@interface CallMenuViewController : UIViewController

@property(assign, nonatomic) CallMenuStyle style;
@property(assign, nonatomic) UserModel *user;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@property(assign, nonatomic, getter=isFrontCamera) BOOL frontCamera;

@property(nullable,nonatomic,weak) id <CallMenuViewControllerDelegate> delegate;


- (instancetype)initWithStyle:(CallMenuStyle) style user:(UserModel *)user;

@end

NS_ASSUME_NONNULL_END
