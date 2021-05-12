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
    self.textLabel.text = [NSString stringWithFormat:@"你确定赠送“%@“x%ld吗？", self.gift.name ,self.gift.count];
   
    
    NSMutableAttributedString *text =  [[NSMutableAttributedString alloc] init];
       
       if (self.gift.type == 1 || self.gift.type == 2) {
           NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
           
           if (self.gift.type == 1) {
               textAttachment.image = [UIImage imageNamed:@"gift-energy"];
           }
           else if (self.gift.type == 2) {
               textAttachment.image = [UIImage imageNamed:@"gift-coin"];
           }
           
           
           //给附件添加图片
          
           //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
           textAttachment.bounds = CGRectMake(0, -(self.detailTextLabel.font.lineHeight - self.detailTextLabel.font.pointSize) / 2 + 2,  textAttachment.image.size.width, textAttachment.image.size.height);
           //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
           NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
           
           [text appendAttributedString:imageStr];
           NSInteger price = self.gift.energy * self.gift.count;
           [text appendAttributedString:  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld",price]]];
       }
       else {
           [text appendAttributedString:  [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"免费"]]];
       }
    
    self.detailTextLabel.attributedText = text;
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
