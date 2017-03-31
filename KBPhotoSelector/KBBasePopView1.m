//
//  KBBasePopView.m
//  KuaiDiYuan_S
//
//  Created by duhongbo on 16/12/8.
//  Copyright © 2016年 KuaidiHelp. All rights reserved.
//

#define kPopViewTag 99991

#import "KBBasePopView1.h"
#import <QuartzCore/QuartzCore.h>

@interface KBBasePopView1()
@property (nonatomic, strong) UIView *modalView;

@end

@implementation KBBasePopView1

+(KBBasePopView1 *)popupWithView:(UIView *)popupView {
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *rootView = keyWindow.rootViewController.view;
    CGRect rect = CGRectMake(0, 0, rootView.frame.size.width, rootView.frame.size.height);
    
    if (rootView.transform.b != 0 && rootView.transform.c != 0) {
        rect = CGRectMake(0, 0, rootView.frame.size.height, rootView.frame.size.width);
    }
    
    KBBasePopView1 *aimView = [[KBBasePopView1 alloc] initWithFrame:rect];
    aimView.backgroundShadowView = [[UIView alloc] initWithFrame:aimView.frame];
    aimView.backgroundShadowView.backgroundColor = [UIColor blackColor];
    aimView.backgroundShadowView.alpha = 0.0;
    
    [popupView setFrame:CGRectMake(popupView.frame.origin.x, [UIScreen mainScreen].bounds.size.width - popupView.frame.size.height,  [UIScreen mainScreen].bounds.size.width, popupView.frame.size.height)];
    
    popupView.tag = kPopViewTag;
    popupView.userInteractionEnabled = YES;
    [aimView addSubview:aimView.backgroundShadowView];
    [aimView addSubview:popupView];
    
    return aimView;
}


-(void)show {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *rootView = keyWindow.rootViewController.view;
    
    CGRect rect = CGRectMake(0, 0, rootView.frame.size.width, rootView.frame.size.height);
    if(rootView.transform.b != 0 && rootView.transform.c != 0)
        rect = CGRectMake(0, 0, rootView.frame.size.height, rootView.frame.size.width);
    self.frame = rect;
    
    _backgroundShadowView.alpha = 0.0;
    [rootView addSubview:self];
    
    __block UIView *vPopUp;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *v = (UIView *)obj;
        if (v.tag == kPopViewTag) {
            vPopUp = v;
        }
    }];
    
    vPopUp.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height * 2.5);
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundShadowView.alpha = 0.4;
                     }
     
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2 animations:^{
                             
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.1 animations:^{
                             }];
                         }];
                     }];
    
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [vPopUp setFrame:CGRectMake(0, self.frame.size.height - vPopUp.frame.size.height, [UIScreen mainScreen].bounds.size.width, vPopUp.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSelf:)];
    [_backgroundShadowView addGestureRecognizer:tap];
}



-(void)hide {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    __block UIView *vPopUp;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *v = (UIView *)obj;
        if (v.tag == kPopViewTag) {
            vPopUp = v;
        }
    }];
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         vPopUp.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height * 1.5);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundShadowView.alpha = 0.0;
                     }
     
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2 animations:^{
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
                     }];
}


- (void)hideSelf:(UITapGestureRecognizer *)tap{
    [_backgroundShadowView removeGestureRecognizer:tap];
    [self hide];
}

@end
