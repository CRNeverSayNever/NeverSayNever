//
//  LyricManager.h
//  音乐
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyricManager : NSObject

//对外的歌词数组
@property (nonatomic, retain) NSArray *allLyric;

+ (instancetype)sharedManager;

//解析歌词
- (void)loadLyricWith:(NSString *)lyricStr;

//根据播放时间获取到该播放的歌词的索引
- (NSInteger)indexWith:(NSTimeInterval)time;

@end
