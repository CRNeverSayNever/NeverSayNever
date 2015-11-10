//
//  DataManager.h
//  音乐
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UpdataUI)();
@interface DataManager : NSObject

//存放model的数组
@property (nonatomic, strong) NSMutableArray * allMusic;
@property (nonatomic, copy) UpdataUI myUpdataUI;

+ (DataManager *)sharedManager;

//根据cell的索引返回一个model
//index 索引值

- (MusicModel *)musicModelWithIndex:(NSInteger)index;

@end
