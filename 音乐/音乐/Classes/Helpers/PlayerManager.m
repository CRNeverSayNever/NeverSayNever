//
//  PlayerManager.m
//  音乐
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import "PlayerManager.h"

@interface PlayerManager ()

//播放器 -> 全局唯一，因为如果有两个avplayer的话，就会同时播放两个音乐
@property (nonatomic, retain) AVPlayer *player;
//计时器
@property (nonatomic, retain) NSTimer *timer;

@end

static PlayerManager *manager = nil;
@implementation PlayerManager

- (instancetype)init{
    if ([super init]) {
        //添加通知，当self发出AVPlayerItemDidPlayToEndTimeNotification是触发playerDidPlayEnd事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
         self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingWithSeconds) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)playerDidPlayEnd:(NSNotification *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayEnd)]) {
        [self.delegate playerDidPlayEnd];
    }
}

//单例方法
+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [PlayerManager new];
    });
    return manager;
}

#pragma mark 给个链接，让AVPlayer播放
- (void)playWithUrlString:(NSString *)urlStr{
    
    if(self.player.currentItem){
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    //创建一个item
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlStr]];
    
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //当前正在播放的音乐
    [self.player replaceCurrentItemWithPlayerItem:item];
    
}

- (void)play{
    //如果正在播放的花，就不播放了，直接返回就行了
    if(_isPlaying){
        return;
    }
    [self.player play];
    //开始播放后标记一下
    _isPlaying = YES;
    [_timer setFireDate:[NSDate distantPast]];
}

- (void)playingWithSeconds{
    //NSLog(@"%lld",self.player.currentTime.value/self.player.currentTime.timescale);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPlayingWithTime:)]) {
        //计算一下播放器现在播放的秒数
        NSTimeInterval time = self.player.currentTime.value/self.player.currentTime.timescale;
        [self.delegate playerPlayingWithTime:time];
    }
}

- (void)pause{
    [self.player pause];
    //暂停播放后设为no
    _isPlaying = NO;
    [_timer setFireDate:[NSDate distantFuture]];
}

#pragma mark --lazy load
- (AVPlayer *)player{
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //状态变化后的新值
    AVPlayerItemStatus status = [change[@"new"] integerValue];
    switch (status) {
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"准备好了，可以播放");
            //开始播放
            [self play];
            break;
        case AVPlayerItemStatusFailed:
            NSLog(@"音乐加载失败");
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"音乐不存在");
            break;
            
        default:
            break;
    }
}

- (int64_t)getCurrentTime{
    int64_t current = self.player.currentTime.value/self.player.currentTime.timescale;
    return current;
}

- (void)seekToTime:(NSTimeInterval)time{
    //先暂停
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            //拖拽成功后再播放
            [self play];
        }
    }];
}

- (void)changeToVolume:(CGFloat)volume{
    self.player.volume = volume;
}

- (CGFloat)volume{
    return self.player.volume;
}

@end
