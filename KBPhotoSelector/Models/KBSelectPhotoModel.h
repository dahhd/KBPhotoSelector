//
//  KBSelectPhotoModel.h
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Photos/PHAsset.h>

@interface KBSelectPhotoModel : NSObject

@property (nonatomic, strong) PHAsset  *asset;
@property (nonatomic, copy)   NSString *localIdentifier;

@end
