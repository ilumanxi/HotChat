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
#import "GiftReminderViewController.h"
#import "GiftCountViewController.h"

@interface GiftViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GiftReminderViewControllerDelegate, UIPopoverPresentationControllerDelegate, GiftCountViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property(nonatomic, assign) NSInteger perRowCount;

@property(nonatomic, assign) NSInteger perPageCount;

@property (weak, nonatomic) IBOutlet UIButton *energyButton;

@property (weak, nonatomic) IBOutlet UIButton *tCoinButton;


@property (weak, nonatomic) IBOutlet UIButton *countButton;

@property(nonatomic, assign) NSInteger count;

@property(nonatomic, assign) NSInteger columnCountOfPerRow;




@end

@implementation GiftViewController


+ (CGFloat)contentHeight { 
    return 409  +  UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    self.columnCountOfPerRow = 4;
    self.gifts = [GiftManager shared].cahcheGiftList;
    
    
    [[GiftManager shared] getGiftList:^(NSArray<Gift *> * _Nonnull giftList) {
        self.gifts = giftList;
        self.pageControl.numberOfPages = self.numberOfPages;
        [self.collectionView reloadData];
    }];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:@"com.friday.Chat.userDidChange" object:nil];
}

- (void)setGifts:(NSArray<Gift *> *)gifts {
    _gifts = gifts;
    _pageControl.numberOfPages = self.numberOfPages;
    [self.collectionView reloadData];
}

- (void)dealloc {
    
    if ([self isViewLoaded]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)setupViews {
    
    _perRowCount = 4;
    _perPageCount = 8;
    _count = 1;
    _pageControl.numberOfPages = self.numberOfPages;
    
    [_energyButton setTitle:[NSString stringWithFormat:@"%ld",(long)[LoginManager shared].user.userEnergy]  forState:UIControlStateNormal];
    [_tCoinButton setTitle:[NSString stringWithFormat:@"%ld",(long)[LoginManager shared].user.userTanbi]  forState:UIControlStateNormal];
    

    _collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    _collectionViewFlowLayout.minimumLineSpacing = 10;
    _collectionViewFlowLayout.minimumInteritemSpacing = 5;

//    CGFloat itemWidth= (CGRectGetWidth(self.view.bounds) -  30 - 5 * (_perRowCount - 1)) / _perRowCount;
//
//    _collectionViewFlowLayout.itemSize = CGSizeMake(itemWidth, 112);
    [_collectionView registerNib:[UINib nibWithNibName:@"GiftViewCell" bundle:nil] forCellWithReuseIdentifier:@"GiftViewCell"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
}

- (void)updateUserInfo {
    [_energyButton setTitle:[NSString stringWithFormat:@"%ld",(long)[LoginManager shared].user.userEnergy]  forState:UIControlStateNormal];
    [_tCoinButton setTitle:[NSString stringWithFormat:@"%ld",(long)[LoginManager shared].user.userTanbi]  forState:UIControlStateNormal];
}


- (NSInteger)numberOfPages {
    
    CGFloat count = _gifts.count;
   
    return ceil(count / _perPageCount);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return  UIEdgeInsetsMake(0, 15, 0, 15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth= (CGRectGetWidth(collectionView.frame) -  30 - 5 * (_perRowCount - 1)) / _perRowCount;
    return  CGSizeMake(itemWidth, 112);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gifts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GiftViewCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 10;
    cell.layer.borderWidth = 1.5;
    cell.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:108/255.0 alpha:1].CGColor;
    cell.clipsToBounds = YES;
    Gift *gift = self.gifts[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:gift.img]];
    cell.nameLabel.text = gift.name;
    cell.energyLabel.text = [NSString stringWithFormat:@"%ld能量",gift.energy];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    collectionView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        collectionView.userInteractionEnabled = YES;
    });
    
    
    Gift *giftData = self.gifts[indexPath.row];
    giftData.count = self.count;

    [self afterDelayCall:giftData];
    
}

- (void)afterDelayCall:(Gift *)giftData {
    if ([GiftReminderViewController isReminder]) {
        GiftReminderViewController *vc = [[GiftReminderViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.gift = giftData;
        vc.delegate = self;
        [self presentViewController:vc animated:NO completion:nil];
    }
    else {
        if(_delegate && [_delegate respondsToSelector:@selector(giftViewController:didSelectGift:)]){
            [_delegate giftViewController:self didSelectGift:giftData];
        }
    }
    
}

- (void)giftReminderViewController:(GiftReminderViewController *)giftReminder gift:(Gift *)gift {
    
    if(_delegate && [_delegate respondsToSelector:@selector(giftViewController:didSelectGift:)]){
        [_delegate giftViewController:self didSelectGift:gift];
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


- (IBAction)countButtonTapped:(UIButton *)sender {
    
    GiftCountViewController *vc = [[GiftCountViewController alloc] init];
    vc.count = self.count;
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.sourceView = sender;
    vc.popoverPresentationController.sourceRect = CGRectMake(0, 0, sender.bounds.size.width / 2.0, sender.bounds.size.height / 2.0);
    vc.popoverPresentationController.backgroundColor =[UIColor whiteColor];
    vc.popoverPresentationController.canOverlapSourceViewRect = NO;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


#pragma mark - <UIPopoverPresentationControllerDelegate>
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


- (void)giftCountViewController:(GiftCountViewController *)giftCountController count:(NSInteger)count {
    
    self.count = count;
    [self.countButton setTitle:[NSString stringWithFormat:@"%ld", count] forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (touches.anyObject.view == self.view) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


@end
