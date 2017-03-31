//
//  KBPhotoSelector.h
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KBSelectPhotoModel;

@interface KBPhotoSelector : UIView

@property (nonatomic, weak) UIViewController *senderVc; //跳转Vc

@property (nonatomic, assign) NSInteger maxSelectCount; //最大支持选择照片数量, default is 9


@property (nonatomic, copy) void(^canceBlock)();


- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;


- (void)showPreviewPhotoWithSender:(UIViewController *)senderVc
                           animate:(BOOL)animate
             lastSelectPhotoModels:(NSArray<KBSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<KBSelectPhotoModel *> *selectPhotoModels))completion;

@end

NS_ASSUME_NONNULL_END


@interface CustomerNavgationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end
