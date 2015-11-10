//
//  MusicCell.m
//  音乐
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 www.iqiyi.com. All rights reserved.
//

#import "MusicCell.h"

@implementation MusicCell

- (void)setMusicModel:(MusicModel *)musicModel{
    _musicModel = musicModel;
    _songNameLabel.text = musicModel.name;
    _singerLabel.text = musicModel.singer;
    [_pictureView sd_setImageWithURL:[NSURL URLWithString:musicModel.picUrl]];
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
