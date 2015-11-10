//
//  MusicListController.m
//  音乐
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import "MusicListController.h"
#import "MusicCell.h"
#import "PlayerManager.h"
#import "PlayingViewController.h"

#define kWidth  self.view.frame.size.width
#define kHeight self.view.frame.size.height

@interface MusicListController ()<UISearchResultsUpdating>

@property (nonatomic, retain) UIActivityIndicatorView *activityIn;

//监测allMusic的变化
@property (nonatomic, assign) BOOL monitor;

// 放所有歌曲名
@property (nonatomic, retain) NSMutableArray *songNameArray;
// 存放所有搜索结果
@property (nonatomic, retain) NSMutableArray *searchResult;
// 搜索框
@property (nonatomic, retain) UISearchController *searchController;
@end

static NSString *customCell = @"customcell";
@implementation MusicListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MusicCell" bundle:nil] forCellReuseIdentifier:customCell];
    self.searchResult = [NSMutableArray array];
    
    //刷新UI
    //__weak typeof (self)temp = self;
    [DataManager sharedManager].myUpdataUI = ^(){
        [self.tableView reloadData];
        self.monitor = YES;
    };
    
    //给monitor添加观察者
    [self addObserver:self forKeyPath:@"monitor" options:NSKeyValueObservingOptionNew context:nil];
    
    //搜索
    [self search];
    //加载中
    [self loadState];
    
    //键盘弹出调节界面
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardPopup) name:UIKeyboardWillShowNotification object:nil];
    
    //键盘回收调节界面
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardRecover) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_activityIn startAnimating];
}

//- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    //清除观察者:对象通过下面这个方法移除观察者
//    [self removeObserver:self forKeyPath:@"name"];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.active == YES) {
         return _searchResult.count;
    }
    return [DataManager sharedManager].allMusic.count;
}

#pragma mark 键盘弹出
- (void)keyboardPopup{
    
    //[UIView beginAnimations:@"adjust" context:nil];
    //[UIView setAnimationDuration:0.3];
    //[_searchController.searchBar sizeToFit];
    CGRect newRect = self.view.frame;
    newRect.origin.y -= 216;
    self.view.frame = newRect;

    //[UIView commitAnimations];
}

#pragma mark 键盘回收
- (void)keyboardRecover{
    //[UIView beginAnimations:@"back" context:nil];
   // [UIView setAnimationDuration:0.3];
    //[_searchController.searchBar sizeToFit];
    CGRect newRect = self.view.frame;
    newRect.origin.y += 400;
    self.view.frame = newRect;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [_activityIn stopAnimating];
        [_activityIn removeFromSuperview];

    });
    
     MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:customCell forIndexPath:indexPath];
    
    if (_searchController.active == YES) {
        NSString *string = _searchResult[indexPath.row];
        for (MusicModel *music in [DataManager sharedManager].allMusic) {
            if ([string isEqualToString:music.name]) {
                cell.musicModel = music;
            }
        }
    }else{
        MusicModel *musicModel = [DataManager sharedManager].allMusic[indexPath.row];
        cell.musicModel = musicModel;
    }
    
    //取消点击时的背景覆盖效果
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //MusicModel *model = [DataManager sharedManager].allMusic[indexPath.row];
    //播放音乐
    //[[PlayerManager sharedManager] playWithUrlString:model.mp3Url];
    
    //拿到要模态出来的控制器
    PlayingViewController *playingVC = [PlayingViewController sharedPlayingPVC];
    playingVC.index = indexPath.row;
    [self showDetailViewController:playingVC sender:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

#pragma mark 加载状态
- (void)loadState{
    self.activityIn = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    _activityIn.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _activityIn.center = CGPointMake(kWidth/2, kHeight/3);
    _activityIn.backgroundColor = [UIColor blackColor];
    _activityIn.alpha = 0.5;
    _activityIn.layer.masksToBounds = YES;
    _activityIn.layer.cornerRadius = 6;
    [self.view addSubview:_activityIn];
}

#pragma mark _dataManager.allMusic-----KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //NSLog(@"dataManager.allMusic = %@",_dataManager.allMusic);
    self.songNameArray = [NSMutableArray array];
    for (MusicModel *music in [DataManager sharedManager].allMusic) {
        [_songNameArray addObject:music.name];
    }
}

#pragma mark 搜索
- (void)search{
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    //[_searchController.searchBar sizeToFit];
    _searchController.searchBar.placeholder = @"搜索";
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
}

#pragma mark UISearchResultsUpdating协议方法
//updateSearchResultsForSearchController 的方法，当我们对搜索框有任何操作的时候这个方法就会被调用
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_searchResult removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd]%@",self.searchController.searchBar.text];
    NSMutableArray *array = [_songNameArray filteredArrayUsingPredicate:predicate].mutableCopy;
    self.searchResult = array;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
