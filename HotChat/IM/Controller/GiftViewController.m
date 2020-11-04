//
//  GiftViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/29.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftViewController.h"
#import "Gift.h"
#import "GiftViewCell.h"
#import <SDWebImage/SDWebImage.h>
#import "GiftManager.h"
#import "HotChat-Swift.h"

@interface GiftViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property(nonatomic, assign) NSInteger perRowCount;

@property(nonatomic, assign) NSInteger perPageCount;

@property (weak, nonatomic) IBOutlet UIButton *energyButton;


@end

@implementation GiftViewController


+ (CGFloat)contentHeight { 
    if (@available(iOS 11.0, *)) {
        return [UIScreen mainScreen].bounds.size.width / 2 + 41 + 28 +  UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    } else {
        return [UIScreen mainScreen].bounds.size.width / 2 + 41 + 28;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gifts = [GiftManager shared].cahcheGiftList;
    
    [[GiftManager shared] getGiftList:^(NSArray<Gift *> * _Nonnull giftList) {
        self.gifts = giftList;
        self.pageControl.numberOfPages = self.numberOfPages;
        [self.collectionView reloadData];
    }];
    
    [self setupViews];

}

- (void)setupViews {
    
    _perRowCount = 4;
    _perPageCount = 8;
    
    _pageControl.numberOfPages = self.numberOfPages;
    
    [_energyButton setTitle:[NSString stringWithFormat:@"%ld",(long)[LoginManager shared].user.userEnergy]  forState:UIControlStateNormal];
    
    CGFloat size = UIScreen.mainScreen.bounds.size.width / _perRowCount;
    
    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsZero;
    _collectionViewFlowLayout.minimumLineSpacing = 0;
    _collectionViewFlowLayout.minimumInteritemSpacing = 0;
    _collectionViewFlowLayout.itemSize = CGSizeMake(size, size);
    [_collectionView registerNib:[UINib nibWithNibName:@"GiftViewCell" bundle:nil] forCellWithReuseIdentifier:@"GiftViewCell"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
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
    cell.energyLabel.text = [NSString stringWithFormat:@"%ld能量",gift.energy];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(_delegate && [_delegate respondsToSelector:@selector(giftViewController:didSelectItemAtIndexPath:)]){
        [_delegate giftViewController:self didSelectItemAtIndexPath:indexPath];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger curSection = round(scrollView.contentOffset.x / scrollView.frame.size.width);

    _pageControl.currentPage = curSection;
}

- (IBAction)recharge:(id)sender {
    
    WalletViewController *vc = [[WalletViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:true];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (touches.anyObject.view == self.view) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


@end
