//
//  ImageMessageCellData.h
//  HotChat
//
//  Created by 风起兮 on 2021/1/30.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN


//  {type:101,imVersion:0,data:{imgHeight:200,imgWidth:200,url:"http//:img",uuid:asdasd}

@interface ImageMessageCellData : TUIMessageCellData


@property(nonatomic, assign) CGFloat imgHeight;

@property(nonatomic, assign) CGFloat imgWidth;

@property(nonatomic, copy) NSString *url;

@property(nonatomic, copy) NSString *uuid;

@property(nonatomic, assign, readonly) CGSize size;

@end

NS_ASSUME_NONNULL_END
