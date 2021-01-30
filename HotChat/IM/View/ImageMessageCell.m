//
//  ImageMessageCell.m
//  HotChat
//
//  Created by 风起兮 on 2021/1/30.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "ImageMessageCell.h"
#import "THeader.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"
#import <SDWebImage/SDWebImage.h>

@implementation ImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFit;
        _thumb.backgroundColor = [UIColor whiteColor];
        [self.container addSubview:_thumb];
        _thumb.mm_fill();
        _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)fillWithData:(ImageMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.imageData = data;
    _thumb.image = nil;
    
    [_thumb sd_setImageWithURL:[NSURL URLWithString:data.url]];
}


@end
