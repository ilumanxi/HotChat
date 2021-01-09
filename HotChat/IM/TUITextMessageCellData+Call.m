//
//  TUITextMessageCellData+Call.m
//  HotChat
//
//  Created by 风起兮 on 2021/1/5.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "TUITextMessageCellData+Call.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "UIColor+TUIDarkMode.h"

@implementation TUITextMessageCellData (Call)


- (BOOL)isAV {
    if (self.innerMessage.elemType == V2TIM_ELEM_TYPE_CUSTOM) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.innerMessage.customElem.data options:NSJSONReadingFragmentsAllowed error: nil];
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[dict[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingFragmentsAllowed error: nil];
        
        if ([data[@"businessID"] isEqualToString:AVCall] && [data[@"call_type"] integerValue] != CallType_Unknown) {
            return  YES;
        }
    }
    
    return NO;
    
}

- (NSAttributedString *)formatMessageString:(NSString *)text
{
    NSString *chatText = text;
    
    //先判断text是否存在
    if (chatText == nil || chatText.length == 0) {
        NSLog(@"TTextMessageCell formatMessageString failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    
    if ([self isAV]) {
        chatText = [chatText stringByReplacingOccurrencesOfString:@"结束通话，" withString:@""];
    }

    //1、创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:chatText];
    
    if ([self isAV]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.innerMessage.customElem.data options:NSJSONReadingFragmentsAllowed error: nil];
        
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[dict[@"data"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingFragmentsAllowed error: nil];
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        
        if ([data[@"call_type"] integerValue] == CallType_Audio) {
            textAttachment.image = [UIImage imageNamed:@"call-audio"];
        }
        else if ([data[@"call_type"] integerValue] == CallType_Video) {
            textAttachment.image = [UIImage imageNamed:@"call-video"];
        }
        
        // 图片间距
        [attributeString addAttribute:NSKernAttributeName value:@(8) range:NSMakeRange(attributeString.length - 1, 1)];
        
        //给附件添加图片
       
        //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
        textAttachment.bounds = CGRectMake(0, -(self.textFont.lineHeight-self.textFont.pointSize) / 2,  textAttachment.image.size.width, textAttachment.image.size.height);
        //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributeString appendAttributedString:imageStr];
    }

    if([TUIKit sharedInstance].config.faceGroups.count == 0){
        [attributeString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }

    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:chatText options:0 range:NSMakeRange(0, chatText.length)];

    TFaceGroup *group = [TUIKit sharedInstance].config.faceGroups[0];

    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [chatText substringWithRange:range];

        for (TFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr]) {
                //face[i][@"png"]就是我们要加载的图片
                //新建文字附件来存放我们的图片,iOS7才新加的对象
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                //给附件添加图片
                textAttachment.image = [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
                //调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                textAttachment.bounds = CGRectMake(0, -(self.textFont.lineHeight-self.textFont.pointSize)/2, self.textFont.pointSize, self.textFont.pointSize);
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
                break;
            }
        }
    }

    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }


    [attributeString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributeString.length)];

    return attributeString;
}

@end
