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
#import <Toast/Toast.h>

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

@property(nonatomic, retain) Gift *selectedGift;

@property (weak, nonatomic) IBOutlet UILabel *intimacyLabel;

@property (weak, nonatomic) IBOutlet UILabel *charmLabel;

@property (weak, nonatomic) IBOutlet UILabel *richLabel;

@property (weak, nonatomic) IBOutlet UILabel *coinLabel;

@property (weak, nonatomic) IBOutlet GradientView *gradientView;


@end

@implementation GiftViewController


+ (CGFloat)contentHeight { 
    return 409  +  UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.count = 1;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)setSelectedGift:(Gift *)selectedGift {
   
    _selectedGift = selectedGift;
    
    
    self.intimacyLabel.text = [NSString stringWithFormat:@"亲密度\n+%ld℃", selectedGift.intimacy];
    self.intimacyLabel.hidden = selectedGift.intimacy <=0;
    self.charmLabel.text = [NSString stringWithFormat:@"魅力值\n+%ld℃", selectedGift.charm];
    self.charmLabel.hidden = selectedGift.charm <=0;
    self.richLabel.text = [NSString stringWithFormat:@"富豪值\n+%ld℃", selectedGift.rich];
    self.richLabel.hidden = selectedGift.rich <=0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.containerView.clipsToBounds = YES;
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    [self setupViews];
    self.columnCountOfPerRow = 4;
    self.gifts = [GiftManager shared].cahcheGiftList;
    self.intimacyLabel.text = nil;
    self.charmLabel.text = nil;
    self.richLabel.text = nil;
    
    self.coinLabel.text = [NSString stringWithFormat:@"T币：%ld",(long)[LoginManager shared].user.userTanbi];
    
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
    cell.clipsToBounds = YES;
    
    Gift *gift = self.gifts[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:gift.img]];
    cell.nameLabel.text = gift.name;
    
    NSMutableAttributedString *text =  [[NSMutableAttributedString alloc] init];
    
    if (gift.type == 1 || gift.type == 2) {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        
        if (gift.type == 1) {
            textAttachment.image = [UIImage imageNamed:@"gift-energy"];
        }
        else if (gift.type == 2) {
            textAttachment.image = [UIImage imageNamed:@"gift-coin"];
        }
        
        
        //给附件添加图片
       
        //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
        textAttachment.bounds = CGRectMake(0, -(cell.energyLabel.font.lineHeight-cell.energyLabel.font.pointSize) / 2,  textAttachment.image.size.width, textAttachment.image.size.height);
        //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [text appendAttributedString:imageStr];
        [text appendAttributedString:  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld",gift.energy]]];
    }
    else {
        [text appendAttributedString:  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"免费"]]];
    }
   

    [cell.availableCountButton setTitle:[NSString stringWithFormat:@"%ld", LoginManager.shared.user.freeGifts] forState:UIControlStateNormal];
    cell.availableCountButton.hidden = gift.type != 0;
    
    cell.energyLabel.attributedText = text;
    
    
    [cell.tagButton sd_setImageWithURL:[NSURL URLWithString:gift.tag] forState:UIControlStateNormal];
   
    if (gift.isSelected) {
        cell.layer.borderWidth = 1.5;
        cell.layer.borderColor = [UIColor colorWithRed:255/255.0 green:100/255.0 blue:108/255.0 alpha:1].CGColor;
    }
    else {
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = nil;
    }
    
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
   self.selectedGift = self.gifts[indexPath.row];
    
    for (Gift *gift in self.gifts) {
        
        gift.selected = (gift == self.selectedGift);
    }
    
//    [collectionView reloadData];
    
}

- (IBAction)giveAwayButtonTapped:(UIButton *)sender {
    
        sender.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sender.userInteractionEnabled = YES;
        });
    
    if (self.selectedGift) {
        [self afterDelayCall:self.selectedGift];
    }
    else {
        CSToastStyle *style = [CSToastManager sharedStyle];
        
        [self.view makeToast:@"请选择赠送的礼物" duration:3 position:CSToastPositionBottom style: style];
    }
}


- (void)afterDelayCall:(Gift *)giftData {
    
   
    if (giftData.type == 0) {
        giftData.count = 1;
    }
    else {
        giftData.count = self.count;
    }
    
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
    [self.countButton setTitle:[NSString stringWithFormat:@"x%ld", count] forState: UIControlStateNormal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (touches.anyObject.view == self.view) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


@end
