//
//  GiftCountViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftCountViewController.h"
#import "GiftCountCell.h"
#import "HotChat-Swift.h"

@interface GiftCountViewController ()


@property(nonatomic, copy) NSArray<GiftCountDescription *> *data;

@end

@implementation GiftCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupPreferredContentSize];
    [self setupViews];
    
    [GiftHelper giftNumConfigWithSuccess:^(NSArray<GiftCountDescription *> * _Nonnull data) {
        self.data = data;
        [self setupPreferredContentSize];
        [self.tableView reloadData];
    } failed:^(NSError * _Nonnull error) {
    
    }];
}


- (void)setupData {
    _data = [GiftHelper cacheGifCountConfig];
    
}


- (void)setupPreferredContentSize  {
    
    self.preferredContentSize = CGSizeMake(90, 30 * self.data.count);
}

- (void)setupViews {
    self.tableView.rowHeight = 30;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"GiftCountCell" bundle:nil] forCellReuseIdentifier:@"GiftCountCell"];
    
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftCountDescription *model = self.data[indexPath.row];
    
    GiftCountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GiftCountCell" forIndexPath:indexPath];
    cell.countLabel.text = [NSString stringWithFormat:@"%ld%@",model.num, model.name];
    
    if (model.num == self.count) {
        cell.countLabel.textColor = [UIColor whiteColor];
        cell.contentView.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:66.0/255.0 blue:62/255.0 alpha:1.0].CGColor;
        cell.contentView.layer.borderWidth = 0.5;
        cell.contentView.layer.cornerRadius = 2;
        cell.contentView.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:53/255.0 alpha:1.0];
    }
    else {
        cell.countLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        cell.contentView.layer.borderColor = nil;
        cell.contentView.layer.borderWidth = 0;
        cell.contentView.layer.cornerRadius = 0;
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
   
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftCountDescription *model = self.data[indexPath.row];
    
    if (_delegate && [_delegate respondsToSelector:@selector(giftCountViewController:count:)]) {
        [_delegate giftCountViewController:self count:model.num];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
