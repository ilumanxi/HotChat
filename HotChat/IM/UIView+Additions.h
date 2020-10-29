//
//  UIView+Additions.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Additions)

@property (nonatomic, strong, readonly) MASViewAttribute *safeAreaLayoutGuideTop;

@property (nonatomic, strong, readonly) MASViewAttribute *safeAreaLayoutGuideBottom;

@end

NS_ASSUME_NONNULL_END
