//
//  GiftViewController.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gift.h"
@class GiftViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol GiftViewControllerDelegate <NSObject>

- (void)giftViewController:(GiftViewController *)gift didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GiftViewController : UIViewController

@property(strong , nonatomic) NSArray<Gift *> *gifts;

@property (nonatomic, weak) id<GiftViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END