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

static PIPWindow *_share = nil;



@implementation PIPWindow

+ (PIPWindow *)share {
    
    return  _share;
    
}

+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    if (_share != nil) {
        return;
    }
    viewControllerToPresent.hbd_barHidden= YES;
    HBDNavigationController *navigationController = [[HBDNavigationController alloc] initWithRootViewController:viewControllerToPresent];
    
    UIWindowLevel PIPWindowLevelNormal = UIWindowLevelNormal + 1;
    
    _share = [[PIPWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _share.windowLevel =  PIPWindowLevelNormal;
    _share.rootViewController = navigationController;
    _share.hidden = NO;
    [UIApplication.sharedApplication.keyWindow endEditing:YES];
    
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
