//
//  ImageMessageCell.h
//  HotChat
//
//  Created by 风起兮 on 2021/1/30.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUIMessageCell.h"
#import "ImageMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageMessageCell : TUIMessageCell

/**
 *  缩略图
 *  用于在消息单元内展示的小图，默认优先展示缩略图，省流量。
 */
@property (nonatomic, strong) UIImageView *thumb;

/**
 *  图像消息单元消息源
 *  imageData 中存放了图像路径，图像原图、大图、缩略图，以及三种图像对应的下载进度、上传进度等各种图像消息单元所需信息。
 *  详细信息请参考 Section\Chat\CellData\TUIIamgeMessageCellData.h
 */
@property ImageMessageCellData *imageData;

@end

NS_ASSUME_NONNULL_END
