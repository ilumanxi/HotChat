//
//  GiftCountViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/16.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftCountViewController.h"
#import "GiftCount.h"
#import "GiftCountCell.h"

@interface GiftCountViewController ()


@property(nonatomic, copy) NSArray<GiftCount *> *data;

@end

@implementation GiftCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupPreferredContentSize];
    [self setupViews];
    
   
}


- (void)setupData {
    
    _data = @[
        [[GiftCount alloc] initWithCount:9999 text:@"长长久久"],
        [[GiftCount alloc] initWithCount:1314 text:@"一生一世"],
        [[GiftCount alloc] initWithCount:188 text:@"要抱抱"],
        [[GiftCount alloc] initWithCount:66 text:@"一切顺利"],
        [[GiftCount alloc] initWithCount:30 text:@"想你..."],
        [[GiftCount alloc] initWithCount:10 text:@"十全十美"],
        [[GiftCount alloc] initWithCount:5 text:@"喜欢你"],
        [[GiftCount alloc] initWithCount:2 text:@"好事成双"],
        [[GiftCount alloc] initWithCount:1 text:@"一心一意"]
    ];
    
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
    
    GiftCount *model = self.data[indexPath.row];
    
    GiftCountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GiftCountCell" forIndexPath:indexPath];
    cell.countLabel.text = [NSString stringWithFormat:@"%ld%@",model.count, model.text];
    
    if (model.count == self.count) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:241/255.0 green:238/255.0 blue:11/255.0 alpha:1.0];
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GiftCount *model = self.data[indexPath.row];
    
    if (_delegate && [_delegate respondsToSelector:@selector(giftCountViewController:count:)]) {
        [_delegate giftCountViewController:self count:model.count];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
