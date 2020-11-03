//
//  GiftReminderViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/11/2.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "GiftReminderViewController.h"
#import <SDWebImage/SDWebImage.h>

@interface GiftReminderViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;



@end

@implementation GiftReminderViewController

+ (BOOL)isReminder {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GiftReminder.isReminder"] == nil) {
        return  YES;
    }
    
    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"GiftReminder.isReminder"];
}

+ (void)setReminder:(BOOL)reminder {
    [[NSUserDefaults standardUserDefaults] setBool:reminder forKey:@"GiftReminder.isReminder"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.gift.img]];
    self.textLabel.text = [NSString stringWithFormat:@"你确定赠送“%@“x1吗？", self.gift.name];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%ld能量",self.gift.energy];
    
}

- (IBAction)reminderButtonTapped:(id)sender {
    
    self.reminderButton.selected = !self.reminderButton.isSelected;
}



- (IBAction)doneButtonTapped:(id)sender {
    
    if (self.reminderButton.isSelected) {
        [GiftReminderViewController setReminder:NO];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(giftReminderViewController:gift:)]) {
        [_delegate giftReminderViewController:self gift:self.gift];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (touches.anyObject.view == self.view) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    
    
}


@end
