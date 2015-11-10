//
//  PlayerManager.h
//  音乐
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayerManagerDelegate <NSObject>

//当播放一首歌结束以后，让代理去做的事情
- (void)playerDidPlayEnd;
//播放中间一直在重复执行的方法
- (void)playerPlayingWithTime:(NSTimeInterval)time;

@end

@interface PlayerManager : NSObject

//是否正在播放
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) id<PlayerManagerDelegate> delegate;

+ (instancetype)sharedManager;

//给个链接，让AVPlayer播放
- (void)playWithUrlString:(NSString *)urlStr;

//播放
- (void)play;

//暂停
- (void)pause;

//获取当前时间
- (int64_t)getCurrentTime;
//改变进度
- (void)seekToTime:(NSTimeInterval)time;

//改变音量
- (void)changeToVolume:(CGFloat)volume;

//用来访问avplayer的音量
- (CGFloat)volume;

@end
