//
//  GiftCountViewController.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GiftCountViewController;

NS_ASSUME_NONNULL_BEGIN


@protocol GiftCountViewControllerDelegate <NSObject>

- (void)giftCountViewController:(GiftCountViewController *)giftCountController count:(NSInteger )count;

@end

@interface GiftCountViewController : UITableViewController

@property(nonatomic, assign) NSInteger count;

@property (nonatomic, weak) id<GiftCountViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
