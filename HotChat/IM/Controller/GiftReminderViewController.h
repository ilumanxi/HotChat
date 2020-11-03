//
//  GiftReminderViewController.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gift.h"
@class GiftReminderViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol GiftReminderViewControllerDelegate <NSObject>

- (void)giftReminderViewController:(GiftReminderViewController *)giftReminder gift:(Gift *)gift;

@end

@interface GiftReminderViewController : UIViewController

@property(nonatomic, class, getter=isReminder) BOOL reminder;

@property (nonatomic, weak) id<GiftReminderViewControllerDelegate> delegate;

@property(strong, nonatomic) Gift *gift;

@end

NS_ASSUME_NONNULL_END
