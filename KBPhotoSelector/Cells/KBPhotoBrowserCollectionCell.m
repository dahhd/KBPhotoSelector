//
//  KBPhotoBrowserCollectionCell.m
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoBrowserCollectionCell.h"
#import <Masonry/Masonry.h>

@implementation KBPhotoBrowserCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadCustomViews];
    }
    return self;
}

- (void)loadCustomViews {
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.btnSelected];
    
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    
    [self.btnSelected mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(8);
        make.right.equalTo(self.contentView.mas_right).offset(-8);
        make.height.equalTo(@26);
        make.width.equalTo(@26);
    }];
}




# pragma mark ----getter----
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    return _imageView;
}


- (UIButton *)btnSelected {
    if (!_btnSelected) {
        _btnSelected = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSelected setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
        [_btnSelected setImage:[UIImage imageNamed:@"choose_selected"] forState:UIControlStateSelected];
    }
    return _btnSelected;
}

@end
