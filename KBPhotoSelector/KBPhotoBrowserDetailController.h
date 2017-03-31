//
//  KBPhotoBrowserDetailController.h
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;
@class KBSelectPhotoModel;
@class KBPhotoBrowserTableController;

@interface KBPhotoBrowserDetailController : UIViewController

//相册属性
@property (nonatomic, strong) PHAssetCollection *assetCollection;

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;
//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<KBSelectPhotoModel*> *arraySelectPhotos;

//用于回调上级列表，把已选择的图片传回去
@property (nonatomic, weak) KBPhotoBrowserTableController *backSenderVc;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<KBSelectPhotoModel*> *selPhotoModels, BOOL isSelectOriginalPhoto);

//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();


@end


