//
//  KBPhotoBrowserTableController.h
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KBSelectPhotoModel;

@interface KBPhotoBrowserTableController : UITableViewController

@property (nonatomic, assign) NSInteger maxSelectCount;
@property (nonatomic, strong) NSMutableArray<KBSelectPhotoModel*> *arraySelectPhotos;

//选择完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<KBSelectPhotoModel*> *selPhotoModels, BOOL isSelectOriginalPhoto);
//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();

@end
