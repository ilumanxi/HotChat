//
//  ImageMessageCellData.m
//  HotChat
//
//  Created by 风起兮 on 2021/1/30.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "ImageMessageCellData.h"

#import "THelper.h"
#import "THeader.h"




@interface ImageMessageCellData ()
@end

@implementation ImageMessageCellData


- (CGSize)size {
    return CGSizeMake(_imgWidth, _imgHeight);
}
 

- (CGSize)contentSize
{

    CGSize size = self.size;

    if(size.height > size.width){
        size.width = size.width / size.height * TImageMessageCell_Image_Height_Max;
        size.height = TImageMessageCell_Image_Height_Max;
    } else {
        size.height = size.height / size.width * TImageMessageCell_Image_Width_Max;
        size.width = TImageMessageCell_Image_Width_Max;
    }
    return size;
}
@end

