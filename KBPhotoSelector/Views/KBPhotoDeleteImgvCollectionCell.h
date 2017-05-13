//
//  KBPhotoDeleteImgvCollectionCell.h
//  Social
//
//  Created by duhongbo on 17/3/26.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBPhotoDeleteImgvCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) void (^singleTapCurImageCallBack)();

@end
