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
    
    self.preferredContentSize = CGSizeMake(90, 25 * self.data.count);
}

- (void)setupViews {
    self.tableView.rowHeight = 25;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.bounces = NO;
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
        cell.contentView.backgroundColor = [UIColor colorWithRed:241/255.0 green:238/255.0 blue:11/255.0 alpha:1.0];
    }
    else {
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
