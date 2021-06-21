//
//  UIImage+Data.h
//  HotChat
//
//  Created by 风起兮 on 2021/6/21.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Data)

+ (NSData *)zipNSDataWithImage:(UIImage *)sourceImage;

@end

NS_ASSUME_NONNULL_END
