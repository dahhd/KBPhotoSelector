//
//  KBPhotoBrowserTableViewCell.m
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoBrowserTableViewCell.h"
#import <Masonry/Masonry.h>

@implementation KBPhotoBrowserTableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadCustomViews];
    }
    return self;
}



- (void)loadCustomViews {
    [self.contentView addSubview:self.headerImage];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.titleCount];
    
    __weak typeof(self) __weakSelf = self;
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) __strongSelf = self;
        make.left.equalTo(self.contentView.mas_left);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@56);
        make.width.equalTo(@66);
        
    }];
    
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) __strongSelf = self;
        make.left.equalTo(self.headerImage.mas_right).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@21);
        make.width.equalTo(@110);
    }];
    
    
    [self.titleCount mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong typeof(self) __strongSelf = self;
        make.left.equalTo(self.title.mas_right).offset(10);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@21);
        make.width.equalTo(@70);
    }];
    
}


















# pragma mark ----getter----

-(UIImageView *)headerImage {
    if (!_headerImage) {
        _headerImage = [UIImageView new];
        
    }
    return _headerImage;
}




- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.font = [UIFont systemFontOfSize:17];
    }
    return _title;
}



- (UILabel *)titleCount {
    if (!_titleCount) {
        _titleCount = [UILabel new];
        _titleCount.font = [UIFont systemFontOfSize:17];
    }
    return _titleCount;
}





@end
