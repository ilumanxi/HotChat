//
//  GiftViewCell.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GiftViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *energyLabel;


@end

NS_ASSUME_NONNULL_END
