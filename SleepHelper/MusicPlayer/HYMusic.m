//
//  HYMusic.m
//  HXSD
//
//  Created by pconline on 2017/5/13.
//  Copyright © 2017年 BFMobile. All rights reserved.
//

#import "HYMusic.h"
#import <AVFoundation/AVFoundation.h>

@implementation HYMusic

-(instancetype)initWithTitle:(NSString*)title musicUrl:(NSString*)musicUrl{
    
    if (self == [super init]) {
        self.songName = title;
        self.musicUrl = musicUrl;

        NSURL *url = [NSURL fileURLWithPath:musicUrl];
        AVURLAsset *avURLAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        for (AVMetadataItem *metadata in [avURLAsset metadata]){
//            NSLog(@"metadata.commonKey = %@", metadata.commonKey);
//            NSLog(@"metadata.key = %@", metadata.key);
//            NSLog(@"metadata.stringValue = %@", metadata.stringValue);
//            NSLog(@"metadata.dataValue = %@\n\n", metadata.dataValue);
            //获取图片
            if([(NSString *)[metadata commonKey] isEqualToString:@"artwork"]){
                UIImage *coverImage = [UIImage imageWithData:metadata.dataValue];//提取图片
                self.logo = coverImage;
            }
        }
    }
    return self;
}

@end
