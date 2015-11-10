//
//  PlayingViewController.m
//  音乐
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import "PlayingViewController.h"
#import "PlayerManager.h"
#import "MusicModel.h"
#import "LyricManager.h"
#import "LyricModel.h"

static NSString * cellIdentifier = @"cell";
@interface PlayingViewController ()<PlayerManagerDelegate,UITableViewDelegate,UITableViewDataSource>

//记录一下当前播放的音乐的索引
@property (nonatomic, assign) NSInteger currentIndex;
//记录当前正在播放的音乐
@property (nonatomic, retain) MusicModel *currentModel;

@property (nonatomic, retain) UIButton *btn;

@property (strong, nonatomic) IBOutlet UITableView *tableView4Lyric;

@property (nonatomic, retain) AVPlayerItem *playerItem;

@property (nonatomic, retain) AVPlayer *player;

@end

static PlayingViewController *playingVC = nil;
@implementation PlayingViewController

+ (instancetype)sharedPlayingPVC{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       //拿到main sb
       UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
       //在main sb 拿到我们要用的视图控制器
       playingVC = [sb instantiateViewControllerWithIdentifier:@"playingVC"];
        
    });
    return playingVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentIndex = -1;
    self.btn = (UIButton *)[self.view viewWithTag:1001];
    //设置自己为播放器的代理，帮播放器干一些事情
    [PlayerManager sharedManager].delegate = self;
    
    //注册
    [self.tableView4Lyric registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView4Lyric.backgroundColor = [UIColor clearColor];
    //音量
    self.slider4Volume.value = [[PlayerManager sharedManager] volume];
    
    // Do any additional setup after loading the view.
}

//播放器播放结束了，开始播放下一首
- (void)playerDidPlayEnd{
    [self action4Next:nil];
    [PlayerManager sharedManager].isPlaying = NO;
}

- (void)buildUI{
    self.songName.text = self.currentModel.name;
    self.singerName.text = self.currentModel.singer;
    self.img4Pic.layer.masksToBounds = YES;
    self.img4Pic.layer.cornerRadius = 120;
    //self.lab4PlayedTime.text = [NSString stringWithFormat:@"%lld",[[PlayerManager sharedManager] getCurrentTime]];
    [self.img4Pic sd_setImageWithURL:[NSURL URLWithString:self.currentModel.picUrl]];
    //更改旋转的角度
    self.img4Pic.transform = CGAffineTransformMakeRotation(0);
    //更改button
    [_btn setBackgroundImage:[UIImage imageNamed:@"pause@2x"] forState:UIControlStateNormal];
    
    self.slider4Time.maximumValue = [self.currentModel.duration integerValue]/1000;
    self.slider4Time.value = 0;
    
    [self.maobin sd_setImageWithURL:[NSURL URLWithString:self.currentModel.blurPicUrl]];
    
    //解析歌词
    [[LyricManager sharedManager] loadLyricWith:self.currentModel.lyric];
    
    [self.tableView4Lyric reloadData];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LyricManager sharedManager].allLyric.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    LyricModel *lyric = [LyricManager sharedManager].allLyric[indexPath.row];
    cell.textLabel.text = lyric.lyricContext;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    //NSLog(@"--%f",lyric.time);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

//播放器每0.1秒回让代理执行一下这个事件
- (void)playerPlayingWithTime:(NSTimeInterval)time{
    //剩余时间
    NSTimeInterval time2 = [self.currentModel.duration integerValue] / 1000 - time;
    self.lab4PlayedTime.text = [self stringWithTime:time];
    self.lab4LastTime.text = [self stringWithTime:time2];
    self.slider4Time.value = time;
    
    //每0.1秒选择1度
    self.img4Pic.transform = CGAffineTransformRotate(self.img4Pic.transform, M_PI/180);
    
    //根据当前播放时间获取到应该播放那句歌词
    NSInteger index = [[LyricManager sharedManager]indexWith:time];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    //让tableView选择我们找到的歌词
    [self.tableView4Lyric selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (NSString *)stringWithTime:(NSTimeInterval)time{
    NSInteger minutes = time / 60;
    NSInteger seconde = (int)time % 60;
    return [NSString stringWithFormat:@"%ld:%.2ld",minutes,seconde];
}

#pragma mark 播放音乐
/*
//- (void)startPlay{
//    NSLog(@"_index3 = %ld",_index);
//    //取出要播放的model
//    MusicModel *model = [[DataManager sharedManager]musicModelWithIndex:self.index];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:model.mp3Url]];
//    self.playerItem = playerItem;
//    self.player = [PlayerManager sharedManager].player;
//    [[PlayerManager sharedManager].player replaceCurrentItemWithPlayerItem:playerItem];
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderPlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    });
//    
//    [[PlayerManager sharedManager].player play];
//}
*/
- (void)startPlay{
    [[PlayerManager sharedManager] playWithUrlString:self.currentModel.mp3Url];
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //如果要播放的音乐和当前播放的音乐一样，就什么都不干了
    if (_index == _currentIndex) {
        return;
    }
    _currentIndex = _index;
    [self startPlay];
}

#pragma mark 返回--点击事件
- (IBAction)action4Back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 当播放完毕后，按顺序播放下一首
- (void)orderPlayer{
    _index++;
    [self startPlay];
    NSLog(@"_index = %ld",_index);
/*
//  MusicModel *model = [[DataManager sharedManager]musicModelWithIndex:self.index];
//    int64_t durrent = _player.currentTime.value/_player.currentTime.timescale;
//    NSString *string = [NSString stringWithFormat:@"%ld",model.duration];
//    NSString *string1 = [string substringToIndex:3];
//    NSLog(@"+++++%@",string1);
//    NSLog(@"%lld",durrent);
*/
}

#pragma mark 上一首
- (IBAction)action2Prev:(UIButton *)sender {
    _currentIndex--;
    //判断是不是第一首
    if (_currentIndex == -1) {
        _currentIndex = [DataManager sharedManager].allMusic.count - 1;
    }
    [self startPlay];
}

#pragma mark 暂停或者播放
- (IBAction)action4PlayOrPause:(UIButton *)sender {
    //判断是否正在播放
    if ([PlayerManager sharedManager].isPlaying) {
        //如果正在播放，就让播放器暂停，同时改变button的text
        [[PlayerManager sharedManager] pause];
        [sender setBackgroundImage:[UIImage imageNamed:@"play@2x"] forState:UIControlStateNormal];
    }else{
        //暂停状态：开始播放，并改变btn为暂停
        [[PlayerManager sharedManager] play];
        [sender setBackgroundImage:[UIImage imageNamed:@"pause@2x"] forState:UIControlStateNormal];
    }
}

#pragma mark 下一首
- (IBAction)action4Next:(UIButton *)sender {
    _currentIndex++;
    //判断是不是最后一首
    if (_currentIndex == [DataManager sharedManager].allMusic.count) {
        _currentIndex = 0;
    }
    [self startPlay];
    
}
#pragma mark 改变播放的进度
- (IBAction)action4ChangeTime:(UISlider *)sender {
//    int64_t current = [[PlayerManager sharedManager] getCurrentTime];
//    NSTimeInterval time = current;
    [[PlayerManager sharedManager] seekToTime:sender.value];
}
- (IBAction)action4ChangeVolume:(UISlider *)sender {
    [[PlayerManager sharedManager] changeToVolume:sender.value];
}

#pragma mark 重新currentModel的get方法
- (MusicModel *)currentModel{
    //取到最新的model
     MusicModel *model = [[DataManager sharedManager]musicModelWithIndex:self.currentIndex];
    
    return model;
}

#pragma mark 取消状态栏
//- (BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
