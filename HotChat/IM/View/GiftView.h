//
//  GiftView.h
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gift.h"
@class GiftView;

#define GiftView_Height ([UIScreen mainScreen].bounds.size.width / 2 + 40 + 28)

NS_ASSUME_NONNULL_BEGIN

@protocol GiftViewDelegate <NSObject>


- (void)giftView:(GiftView *)giftView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GiftView : UIView

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, weak) id<GiftViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *energyButton;

@property(strong , nonatomic) NSArray<Gift *> *gifts;

@end

NS_ASSUME_NONNULL_END
