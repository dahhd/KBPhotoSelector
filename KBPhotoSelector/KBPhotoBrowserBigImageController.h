//
//  KBPhotoBrowserBigImageController.h
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class KBSelectPhotoModel;

@interface KBPhotoBrowserBigImageController : UIViewController

@property (nonatomic, strong) NSArray<PHAsset*> *assets;

@property (nonatomic, strong) NSMutableArray<KBSelectPhotoModel*> *arraySelectPhotos;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, assign) NSInteger maxSelectCount; //最大选择照片数

@property (nonatomic, assign) BOOL isSelectOriginalPhoto; //是否选择了原图

@property (nonatomic, assign) BOOL isPresent; //该界面显示方式，预览界面查看大图进来是present，从相册小图进来是push

@property (nonatomic, assign) BOOL shouldReverseAssets; //是否需要对接收到的图片数组进行逆序排列

//点击返回按钮的回调
@property (nonatomic, copy) void (^onSelectedPhotos)(NSArray<KBSelectPhotoModel*> *, BOOL isSelectOriginalPhoto);

//点击确定按钮回调
@property (nonatomic, copy) void (^btnDoneBlock)(NSArray<KBSelectPhotoModel*> *,
    BOOL isSelectOriginalPhoto);


@end
