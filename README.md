# 顶部</br>
![shields.io](https://img.shields.io/teamcity/codebetter/bt428.svg)  ![Mozilla Add-on](https://img.shields.io/amo/d/dustman.svg?style=flat-square)  ![Yii2](https://img.shields.io/badge/Powered_by-Photos_Framework-green.svg?style=flat)  ![Packagist](https://img.shields.io/packagist/v/symfony/symfony.svg?style=flat-square)  ![Packagist](https://img.shields.io/packagist/l/doctrine/orm.svg?style=flat-square)

## KBPhotoSelector</br>
KBPhotoSelector是一个iOS系统的照片选择、浏览、删除管理器，功能全面、界面流畅、开箱即用！可自定义最大选择数量，一句代码获取所需图片数组，支持Cocoapods安装，完全独立于主工程（完全适合组件化架构项目与普通MVC、MVVM项目等），基于Apple新一代照片底层框架Photos，便于后续使用带来的新特性。



### 展示</br>
* 效果图



***
### 安装</br>
* 支持Cocopods
* pod 'KBPhotoSelector' ~> '0.0.1'
* pod update



### 使用</br>

```swift
import KBPhotoActionSheet.h

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
PhotosKit Framework
</br>



### 问题反馈&&交流讨论❓</br>
###### [吐槽大会，吐到你笑]()


### 😆勾搭😆</br>


