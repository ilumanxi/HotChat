//
//  GiftView.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftView.h"
#import "GiftViewCell.h"
#import <SDWebImage/SDWebImage.h>

@interface GiftView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(nonatomic, assign) NSInteger perRowCount;

@property(nonatomic, assign) NSInteger perPageCount;

@end

@implementation GiftView


- (void)awakeFromNib {
    [super awakeFromNib];
    _perRowCount = 4;
    _perPageCount = 8;
    
    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
    _collectionViewFlowLayout.minimumLineSpacing = 0;
    _collectionViewFlowLayout.minimumInteritemSpacing = 0;
    [_collectionView registerNib:[UINib nibWithNibName:@"GiftViewCell" bundle:nil] forCellWithReuseIdentifier:@"GiftViewCell"];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    self.gifts = @[];
}

- (void)setGifts:(NSArray<Gift *> *)gifts {
    
    _gifts = gifts.copy;
    
    _pageControl.numberOfPages = self.numberOfPages;
    [_collectionView reloadData];
    
}

- (IBAction)rechargeButtonDidTapped:(id)sender {
}


- (NSInteger)numberOfPages {
    
    CGFloat count = _gifts.count;
   
    return ceil(count / _perPageCount);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat size = CGRectGetWidth(collectionView.frame) / _perRowCount;
    return  CGSizeMake(size, size);
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.gifts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Gift *gift = self.gifts[indexPath.item];
    
    GiftViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GiftViewCell" forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:gift.img]];
    cell.nameLabel.text = gift.name;
    cell.energyLabel.text = [NSString stringWithFormat:@"%ld能力",gift.energy];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_delegate && [_delegate respondsToSelector:@selector(giftView:didSelectItemAtIndexPath:)]){
        [_delegate giftView:self didSelectItemAtIndexPath:indexPath];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger curSection = round(scrollView.contentOffset.x / scrollView.frame.size.width);

    _pageControl.currentPage = curSection;
}

@end
