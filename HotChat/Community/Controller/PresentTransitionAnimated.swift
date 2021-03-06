//
//  PresentTransitionAnimated.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/6.
//  Copyright © 2021 风起兮. All rights reserved.
//  https://www.jianshu.com/p/daa45775684b

import UIKit

class PresentTransitionAnimated: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let from = transitionContext.viewController(forKey: .from)!
        let to = transitionContext.viewController(forKey: .to)!
        
        let containerView = transitionContext.containerView
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        let isPresent = to.presentingViewController == from
        
        let fromFrame = transitionContext.initialFrame(for: from)
        let toFrame = transitionContext.finalFrame(for: to)
        
        if isPresent {
            fromView.frame = fromFrame
            toView.frame = toFrame.offsetBy(dx: toFrame.width, dy: 0)
            containerView.addSubview(toView)
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            animations: {
                if isPresent {
                    toView.frame = toFrame
                    fromView.frame = fromFrame.offsetBy(dx: fromFrame.width * 0.3 * -1, dy: 0)
                }
            
            }, completion: { _ in
            
                let isCancelled = transitionContext.transitionWasCancelled
                if isCancelled {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(!isCancelled)
            })
    }
    

}

/*

/** 定义动画效果 */
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //转场的容器图，动画完成之后会消失
    UIView *containerView =  [transitionContext containerView];
    UIView *fromView = nil;
    UIView *toView = nil;
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)]) {
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }else{
        fromView = fromViewController.view;
        toView = toViewController.view;
    }
    
    //对应关系
    BOOL isPresent = (toViewController.presentingViewController == fromViewController);
    
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect toFrame = [transitionContext finalFrameForViewController:toViewController];
    
    if (isPresent) {
        fromView.frame = fromFrame;
        toView.frame = CGRectOffset(toFrame, toFrame.size.width, 0);
        [containerView addSubview:toView];
    }
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        if (isPresent) {
            toView.frame = toFrame;
            fromView.frame = CGRectOffset(fromFrame, fromFrame.size.width*0.3*-1, 0);
        }
    } completion:^(BOOL finished) {
        BOOL isCancelled = [transitionContext transitionWasCancelled];
        
        if (isCancelled)
            [toView removeFromSuperview];
        
        [transitionContext completeTransition:!isCancelled];
    }];
}

 */
