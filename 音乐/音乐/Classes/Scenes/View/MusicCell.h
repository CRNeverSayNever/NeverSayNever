//
//  MusicCell.h
//  音乐
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *singerLabel;

@property (nonatomic, retain) MusicModel *musicModel;
@end
