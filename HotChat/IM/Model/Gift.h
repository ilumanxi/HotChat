//
//  Gift.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Gift : NSObject

@property(class, nonatomic, assign) NSMutableArray<Gift *> *cahche;

@property(nonatomic, assign) NSInteger id;

@property(nonatomic, copy) NSString *name;

@property(nonatomic, copy) NSString *img;

@property(nonatomic, assign) NSInteger energy;

@property(nonatomic, assign) NSInteger count;


@end

NS_ASSUME_NONNULL_END
