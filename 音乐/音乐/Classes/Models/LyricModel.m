//
//  LyricModel.m
//  音乐
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import "LyricModel.h"

@implementation LyricModel

- (instancetype)initWithTime:(NSTimeInterval)time lyric:(NSString *)lyric{
    if ([super init]) {
        self.time = time;
        self.lyricContext = lyric;
    }
    return self;
}

@end
