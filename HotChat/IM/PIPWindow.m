//
//  PIPWindow.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/5.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "PIPWindow.h"
#import <HBDNavigationBar/HBDNavigationController.h>
#import <HBDNavigationBar/UIViewController+HBD.h>
#import "HotChat-Swift.h"

static PIPWindow *_share = nil;



@implementation PIPWindow

+ (PIPWindow *)share {
    
    return  _share;
    
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    if (_share != nil) {
        return;
    }
    
//    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    
    viewControllerToPresent.hbd_barHidden = YES;
    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:viewControllerToPresent];
    
//    UIWindowLevel PIPWindowLevelNormal = UIWindowLevelNormal + 1;
    
    _share = [[PIPWindow alloc] initWithFrame: CGRectMake(UIScreen.mainScreen.bounds.size.width, 0, UIScreen.mainScreen.bounds.size.width,  UIScreen.mainScreen.bounds.size.height)];
//    _share.windowLevel =  PIPWindowLevelNormal;
    _share.rootViewController = navigationController;

    _share.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        _share.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width,  UIScreen.mainScreen.bounds.size.height);
    }];
    
}

+ (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    if (_share == nil) {
        return;
    }
    
    _share.hidden = YES;
    [_share.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    _share.rootViewController = nil;
    _share = nil;
}

@end
