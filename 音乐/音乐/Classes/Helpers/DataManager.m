//
//  DataManager.m
//  音乐
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import "DataManager.h"

static DataManager *dataManager = nil;
@implementation DataManager

+ (DataManager *)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [DataManager new];
        [dataManager requestData];
    });
    return dataManager;
}

#pragma mark 解析数据
- (void)requestData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
  
    NSURL *url = [NSURL URLWithString:kMusicListURL];
    NSArray *array = [NSArray arrayWithContentsOfURL:url];
    for (NSDictionary *dic in array) {
        MusicModel *musicModel = [MusicModel new];
        [musicModel setValuesForKeysWithDictionary:dic];
        [self.allMusic addObject:musicModel];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        if (!self.myUpdataUI) {
            NSLog(@"没有block");
        }else{
            self.myUpdataUI();
        }
        
    });
        
    });
}

#pragma mark allMusic---get方法
- (NSMutableArray *)allMusic{
    if (_allMusic == nil) {
        _allMusic = [NSMutableArray new];
    }
    return _allMusic;
}

- (MusicModel *)musicModelWithIndex:(NSInteger)index{
    return self.allMusic[index];
}

@end
