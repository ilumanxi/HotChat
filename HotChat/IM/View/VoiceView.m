//
//  VoiceView.m
//  HotChat
//
//  Created by 风起兮 on 2020/10/27.
//  Copyright © 2020 风起兮. All rights reserved.
//

#import "VoiceView.h"
#import "TUIRecordView.h"
#import "THeader.h"
#import "THelper.h"
#import "TUIKit.h"
#import <AVFoundation/AVFoundation.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"

@interface VoiceView() <AVAudioRecorderDelegate>
@property (nonatomic, strong) TUIRecordView *record;
@property (nonatomic, strong) NSDate *recordStartTime;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *recordTimer;
@end

@implementation VoiceView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [_recordButton addTarget:self action:@selector(recordBtnDown:) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(recordBtnUp:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(recordBtnCancel:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [_recordButton addTarget:self action:@selector(recordBtnExit:) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(recordBtnEnter:) forControlEvents:UIControlEventTouchDragEnter];
    _recordLabel.text = @"按住说话";
}


- (void)recordBtnDown:(UIButton *)sender
{
    AVAudioSessionRecordPermission permission = AVAudioSession.sharedInstance.recordPermission;
    //在此添加新的判定 undetermined，否则新安装后的第一次询问会出错。新安装后的第一次询问为 undetermined，而非 denied。
    if (permission == AVAudioSessionRecordPermissionDenied || permission == AVAudioSessionRecordPermissionUndetermined) {
        [AVAudioSession.sharedInstance requestRecordPermission:^(BOOL granted) {
            if (!granted) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"无法访问麦克风" message:@"开启麦克风权限才能发送语音消息" preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:[UIAlertAction actionWithTitle:@"以后再说" style:UIAlertActionStyleCancel handler:nil]];
                [ac addAction:[UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIApplication *app = [UIApplication sharedApplication];
                    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([app canOpenURL:settingsURL]) {
                        [app openURL:settingsURL];
                    }
                }]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mm_viewController presentViewController:ac animated:YES completion:nil];
                });
            }
        }];
        return;
    }
    //在此包一层判断，添加一层保护措施。
    if(permission == AVAudioSessionRecordPermissionGranted){
        if(!_record){
            _record = [[TUIRecordView alloc] init];
            _record.frame = [UIScreen mainScreen].bounds;
        }
        [self.window addSubview:_record];
        _recordStartTime = [NSDate date];
        [_record setStatus:Record_Status_Recording];
//        _recordButton.backgroundColor = [UIColor lightGrayColor];
        _recordLabel.text = @"松开结束";
        [self startRecord];
    }
}

- (void)recordBtnUp:(UIButton *)sender
{
    if (AVAudioSession.sharedInstance.recordPermission == AVAudioSessionRecordPermissionDenied) {
        return;
    }
//    _recordButton.backgroundColor = [UIColor clearColor];
    _recordLabel.text = @"按住说话";
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:_recordStartTime];
    if(interval < 1 || interval > 60){
        if(interval < 1){
            [_record setStatus:Record_Status_TooShort];
        }
        else{
            [_record setStatus:Record_Status_TooLong];
        }
        [self cancelRecord];
        __weak typeof(self) ws = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.record removeFromSuperview];
        });
    }
    else{
        [_record removeFromSuperview];
        NSString *path = [self stopRecord];
        _record = nil;
        if (path) {
            if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendVoice:)]){
                [_delegate voiceView:self didSendVoice:path];
            }
        }
    }
}

- (void)recordBtnCancel:(UIButton *)sender
{
    [_record removeFromSuperview];
//    _recordButton.backgroundColor = [UIColor clearColor];
    _recordLabel.text = @"按住说话";
    [self cancelRecord];
}

- (void)recordBtnExit:(UIButton *)sender
{
    [_record setStatus:Record_Status_Cancel];
    _recordLabel.text = @"松开取消";
}

- (void)recordBtnEnter:(UIButton *)sender
{
    [_record setStatus:Record_Status_Recording];
    _recordLabel.text = @"松开结束";
}

- (void)startRecord
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive:YES error:&error];

    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];

    NSString *path = [TUIKit_Voice_Path stringByAppendingString:[THelper genVoiceName:nil withExtension:@"m4a"]];
    NSURL *url = [NSURL fileURLWithPath:path];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    [_recorder record];
    [_recorder updateMeters];

    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordTick:) userInfo:nil repeats:YES];
}

- (void)cancelRecord
{
    if(_recordTimer){
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    if([_recorder isRecording]){
        [_recorder stop];
    }
    NSString *path = _recorder.url.path;
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (NSString *)stopRecord
{
    if(_recordTimer){
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    if([_recorder isRecording]){
        [_recorder stop];
    }
    return _recorder.url.path;
}

- (void)recordTick:(NSTimer *)timer{
    [_recorder updateMeters];
    float power = [_recorder averagePowerForChannel:0];
    [_record setPower:power];
    
    //在此处添加一个时长判定，如果时长超过60s，则取消录制，提示时间过长,同时不再显示 recordView。
    //此处使用 recorder 的属性，使得录音结果尽量精准。注意：由于语音的时长为整形，所以 60.X 秒的情况会被向下取整。但因为 ticker 0.5秒执行一次，所以因该都会在超时时显示为60s
    NSTimeInterval interval = _recorder.currentTime;
    if(interval >= 55 && interval < 60){
        NSInteger seconds = 60 - interval;
        NSString *secondsString = [NSString stringWithFormat:@"将在 %ld 秒后结束录制",(long)seconds + 1];//此处加long，是为了消除编译器警告。此处 +1 是为了向上取整，优化时间逻辑。
        _record.title.text = secondsString;
    }
    if(interval >= 60){
        NSString *path = [self stopRecord];
        [_record setStatus:Record_Status_TooLong];
        __weak typeof(self) ws = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ws.record removeFromSuperview];
        });
        if (path) {
            if(_delegate && [_delegate respondsToSelector:@selector(inputBar:didSendVoice:)]){
                [_delegate voiceView:self didSendVoice:path];
            }
        }
    }
    
}

@end
