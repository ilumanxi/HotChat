//
//  UIView+Additions.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (MASViewAttribute *)safeAreaLayoutGuideTop {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
    } else {
        return [[MASViewAttribute alloc] initWithView:self item:self.topAnchor layoutAttribute:NSLayoutAttributeTop];
    }
}
- (MASViewAttribute *)safeAreaLayoutGuideBottom {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
    } else {
        return [[MASViewAttribute alloc] initWithView:self item:self.bottomAnchor layoutAttribute:NSLayoutAttributeBottom];
    }
}

@end
