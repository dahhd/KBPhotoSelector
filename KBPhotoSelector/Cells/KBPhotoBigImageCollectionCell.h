//
//  KBPhotoBigImageCollectionCell.h
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface KBPhotoBigImageCollectionCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) void (^singleTapCallBack)();

@end
