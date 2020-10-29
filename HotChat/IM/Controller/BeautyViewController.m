//
//  BeautyViewController.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/28.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "BeautyViewController.h"
#import <TXLiteAVSDK_TRTC/TXBeautyManager.h>

@interface BeautyViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) TXBeautyManager *beauty;

@property (weak, nonatomic) IBOutlet UISlider *beautySlider;

@property (weak, nonatomic) IBOutlet UISlider *whitenessSlider;

@property (weak, nonatomic) IBOutlet UISlider *ruddySlider;



@end

@implementation BeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _beauty = [[TRTCCloud sharedInstance] getBeautyManager];

}


- (IBAction)beautyLevelChaned:(UISlider *)sender {
    [self.beauty setBeautyLevel:sender.value];
}

- (IBAction)whitenessLevelChaned:(UISlider *)sender {
    [self.beauty setWhitenessLevel:sender.value];
}

- (IBAction)ruddyLevelLevelChaned:(UISlider *)sender {
    [self.beauty setRuddyLevel:sender.value];
}







- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (touches.anyObject.view == self.view) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
