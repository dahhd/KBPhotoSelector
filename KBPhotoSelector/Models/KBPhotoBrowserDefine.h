//
//  KBPhotoBrowserDefine.h
//  Social
//
//  Created by duhongbo on 17/3/21.
//  Copyright © 2017年 kuaibao. All rights reserved.
//


#ifndef KBPhotoBrowserDefine_h
#define KBPhotoBrowserDefine_h

/*
static inline void SetViewWidth (UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

static inline CGFloat GetViewWidth (UIView *view) {
    return view.frame.size.width;
}

static inline void SetViewHeight (UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

static inline CGFloat GetViewHeight (UIView *view) {
    return view.frame.size.height;
}
*/

#define NAV_BAR_COLOR kGetColor(12, 186, 160)

#define kScale [UIScreen mainScreen].scale

#define kWidth [UIScreen mainScreen].bounds.size.width

#define kHeight [UIScreen mainScreen].bounds.size.height

#define kMaxImageWidth 500
#define kItemMargin 30

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]


#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;


#endif /* KBPhotoBrowserDefine_h */
