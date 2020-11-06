//
//  PIPWindow.h
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PIPWindow : UIWindow


+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion API_AVAILABLE(ios(5.0));
// The completion handler, if provided, will be invoked after the dismissed controller's viewDidDisappear: callback is invoked.
+ (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion API_AVAILABLE(ios(5.0));

@end

NS_ASSUME_NONNULL_END
