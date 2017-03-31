//
//  KBPhotoSelector.m
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoSelector.h"
#import "KBPhotoBrowserDefine.h"
#import "KBPhotoBrowserTool.h"
#import "HBProgressHUD.h"
#import "KBSelectPhotoModel.h"
#import "KBPhotoBrowserCollectionCell.h"
#import "KBPhotoBrowserTableController.h"
#import "KBPhotoBrowserBigImageController.h"

#import <Photos/Photos.h>
#import <objc/runtime.h>


double const ScalePhotoWidth = 1000;

typedef void (^handler)(NSArray<UIImage*> *selectPhotos, NSArray<KBSelectPhotoModel*> *selectPhotoModels);

@interface KBPhotoSelector()<PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray <PHAsset*> *arrayDataSource;
@property (nonatomic, strong) NSMutableArray<KBSelectPhotoModel*> * arraySelectPhotos;

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, assign) BOOL senderTabBarIsShow;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) handler handler;

@end


@implementation KBPhotoSelector


- (instancetype)init {
    self = [[[NSBundle mainBundle]loadNibNamed:@"KBPhotoSelector" owner:self options:nil]lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, 160,160);
        self.maxSelectCount = 9; //最大支持照片选择数量默认9张，如有需要，可自行更改
        self.arrayDataSource = [NSMutableArray array];
        self.arraySelectPhotos = [NSMutableArray array];
        
        //如果未获得相机、相册访问权限，监听权限变化
        if (![self judgeIsHavePhotoAblumAuthority]) {
            [[PHPhotoLibrary sharedPhotoLibrary]registerChangeObserver:self];
        }
    }
    return self;
}



- (void)showPreviewPhotoWithSender:(UIViewController *)senderVc
                           animate:(BOOL)animate
             lastSelectPhotoModels:(NSArray<KBSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<KBSelectPhotoModel *> *selectPhotoModels))completion {
    [self showPreview:YES sender:senderVc animate:animate lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}


- (void)showPreview:(BOOL)preview sender:(UIViewController *)senderVc animate:(BOOL)animate lastSelectPhotoModels:(NSArray<KBSelectPhotoModel *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<KBSelectPhotoModel *> * _Nonnull))completion {
    
    self.handler = completion;
    self.senderVc  = senderVc;
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [self.arraySelectPhotos removeAllObjects];
    [self.arraySelectPhotos addObjectsFromArray:lastSelectPhotoModels];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    [self addAssociatedOnSender];
    if (preview) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self loadPhotoFromAlbum];
            
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self noAuthorizationStatusDenied];
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            [self btnPhotoLibrary_Click:nil];
            
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self noAuthorizationStatusDenied];
        }
    }
}


static char RelatedKey;
- (void)addAssociatedOnSender {
    BOOL selfInstanceIsClassVar = NO;
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList(self.senderVc.class, &count);
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        const char * type = ivar_getTypeEncoding(var);
        NSString *className = [NSString stringWithUTF8String:type];
        if ([className isEqualToString:[NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(self.class)]]) {
            selfInstanceIsClassVar = YES;
        }
    }
    if (!selfInstanceIsClassVar) {
        objc_setAssociatedObject(self.senderVc, &RelatedKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}



- (IBAction)btnCancel_Click:(id)sender {
    [self.arraySelectPhotos removeAllObjects];
    if (self.canceBlock) {
        self.canceBlock();
    }
}



- (IBAction)btnCamera_Click:(id)sender {
    NSLog(@"--拍照--");
    if (![self judgeIsHaveCameraAuthority]) {
        [self noAuthorizationStatusDenied];
        return;
    }else {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.senderVc presentViewController:picker animated:YES completion:nil];
        }
    }
}



- (IBAction)btnPhotoLibrary_Click:(id)sender {
    NSLog(@"--从相册选择--");
    if (![self judgeIsHavePhotoAblumAuthority]) {
        [self noAuthorizationStatusDenied];
    } else {
        
        KBPhotoBrowserTableController *photoBrowser = [[KBPhotoBrowserTableController alloc] initWithStyle:UITableViewStylePlain];
        photoBrowser.maxSelectCount = self.maxSelectCount;
        photoBrowser.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
        
        __weak typeof(photoBrowser) weakPB = photoBrowser;
        @WeakObj(self);
        [photoBrowser setDoneBlock:^(NSArray<KBSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto) {
            @StrongObj(self);
            __strong typeof(weakPB) strongPB = weakPB;
            
            self.isSelectOriginalPhoto = isSelectOriginalPhoto;
            [self.arraySelectPhotos removeAllObjects];
            [self.arraySelectPhotos addObjectsFromArray:selPhotoModels];
            
            [self requestSelPhotos:strongPB];
        }];
        
        [photoBrowser setCancelBlock:^{
            if (self.canceBlock) {
                self.canceBlock();
            }
        }];
        
        [self presentVC:photoBrowser];
    }
}



- (void)presentVC:(UIViewController *)vc {
    CustomerNavgationController *nav = [[CustomerNavgationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    nav.previousStatusBarStyle = self.previousStatusBarStyle;
    [nav.navigationBar setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:12.0/225.0 green:186/255.0 blue:160/255.0 alpha:1.00]] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.senderVc presentViewController:nav animated:YES completion:nil];
}



- (void)loadPhotoFromAlbum {
    [self.arrayDataSource removeAllObjects];
    [self.arrayDataSource addObjectsFromArray:[[KBPhotoBrowserTool sharedPhotoBrowserTool] getAllAssetInPhotoAblumWithAscending:NO]];
}




#pragma mark --所选择图片、最终回调--
- (void)requestSelPhotos:(UIViewController *)vc {
    HBProgressHUD *hud = [[HBProgressHUD alloc] init];
    [hud show];
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arraySelectPhotos.count];
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        [photos addObject:@""];
    }
    
    CGFloat scale = self.isSelectOriginalPhoto?1:[UIScreen mainScreen].scale;
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        KBSelectPhotoModel *model = self.arraySelectPhotos[i];
        
        @WeakObj(self);
        [[KBPhotoBrowserTool sharedPhotoBrowserTool] requestImageForAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            @StrongObj(self);
            
            if (image) [photos replaceObjectAtIndex:i withObject:[self scaleImage:image]];
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            
            [self done:photos];
            [hud hide];
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

    
#pragma mark --回调-handler--
- (void)done:(NSArray<UIImage *> *)photos {
    if (self.handler) {
        self.handler(photos, self.arraySelectPhotos.copy);
        self.handler = nil;
    }
}


# pragma mark --UIImagePickerControllerDelegate--
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    @WeakObj(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @StrongObj(self);
        if (self.handler) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [[KBPhotoBrowserTool sharedPhotoBrowserTool] saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {
                        KBSelectPhotoModel *model = [[KBSelectPhotoModel alloc] init];
                        model.asset = asset;
                        model.localIdentifier = asset.localIdentifier;
                        self.handler(@[[self scaleImage:image]], @[model]);
                        
                    } else {
                        //------------------------------------------------
                    }
                });
            }];
        }
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    @WeakObj(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @StrongObj(self);
        if (self.canceBlock) {
            self.canceBlock();
        }
    }];
}



/**
 * @brief 对拿到的图片进行缩放，不然原图直接返回的话会造成内存暴涨
 */
- (UIImage *)scaleImage:(UIImage *)image
{
    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



- (UIImage *)imageWithColor:(UIColor*)color {
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}



# pragma mark --PHPhotoLibraryChangeObserver--
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    @WeakObj(self);
    dispatch_sync(dispatch_get_main_queue(), ^{
        @StrongObj(self);
        [self btnPhotoLibrary_Click:NULL];
        [[PHPhotoLibrary sharedPhotoLibrary]unregisterChangeObserver:self];
    });
}



# pragma mark --检测App是否已经获取访问系统的相机、相册的权限--
- (BOOL)judgeIsHaveCameraAuthority {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (BOOL)judgeIsHavePhotoAblumAuthority {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return self;
    }
    return NO;
}



#pragma mark --无照片查看权限时，alertView提示--
- (void)noAuthorizationStatusDenied {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法获取照片权限" message:@"请到设置-隐私，打开相机与相册权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:doneAction];
    [self.senderVc presentViewController:alertController animated:YES completion:^{}];
}




# pragma mark --Setter&&Getter--
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
        _placeholderLabel.text = @"暂无照片";
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.textColor = [UIColor darkGrayColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.hidden = YES;
    }
    return _placeholderLabel;
}



- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary]unregisterChangeObserver:self];
}
@end



@implementation CustomerNavgationController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
}

@end
