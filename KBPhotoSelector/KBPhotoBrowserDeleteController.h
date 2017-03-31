//
//  KBPhotoBrowserDeleteController.h
//  Social
//
//  Created by duhongbo on 17/3/26.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBPhotoBrowserDeleteController : UIViewController

@property (nonatomic, strong) NSMutableArray<UIImage*> *currentSelectedImgeArr; //当前所有图片数组
@property (nonatomic, assign) NSInteger currentIndex; //当前选择的是第几张图片

@property (nonatomic, copy) void(^compeletionDeleteBlock)(NSMutableArray<UIImage*> *currentNewImageArr);


@end
