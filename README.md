# 顶部log</br>



## KBPhotoSelector</br>
KBPhotoSelector是一个iOS系统的照片选择、浏览、删除管理器，功能全面、界面流畅、开箱即用！可自定义最大选择数量，一句代码获取所需图片数组，支持Cocoapods安装，完全独立于主工程（完全适合组件化架构项目与普通MVC、MVVM项目等），基于Apple新一代照片底层框架Photos，便于后续使用带来的新特性。



### 展示</br>
* 效果图




### 安装</br>
* 支持Cocopods
* pod 'KBPhotoBrowser' ~> '0.0.1'
* 111
* 222



### 使用</br>

```swift
import "KBPhotoActionSheet.h"

_photoActionSheet = [[KBPhotoActionSheet alloc]init];
    _photoActionSheet.maxSelectCount = currentCount; //default is 9, please setting yourSelf!
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.photoActionSheet showPreviewPhotoWithSender:self animate:YES lastSelectPhotoModels:nil completion:^(NSArray<UIImage *> * _Nonnull selectPhotos, NSArray<KBSelectPhotoModel *> * _Nonnull selectPhotoModels) {
    
    //--TODO-----Data-----------------
    }];
    
    [weakSelf.photoActionSheet setCanceBlock:^{
    
    //--Hiden this action-------------
    }];

```



### 依赖</br>
Photos Framework
</br>



### 问题反馈&&交流讨论❓</br>
###### [吐槽大会，吐到你笑](blogbo.org)



### 😆勾搭😆</br>


