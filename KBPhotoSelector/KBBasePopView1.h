//
//  KBBasePopView.h
//  KuaiDiYuan_S
//
//  Created by duhongbo on 16/12/8.
//  Copyright © 2016年 KuaidiHelp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBBasePopView1 : UIView

@property (nonatomic, strong) UIView *backgroundShadowView;//底部半透明背景（遮罩）

+(KBBasePopView1 *)popupWithView:(UIView *)popupView;

-(void)show;
-(void)hide;

@end
