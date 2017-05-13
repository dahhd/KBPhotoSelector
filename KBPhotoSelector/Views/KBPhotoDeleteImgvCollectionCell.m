//
//  KBPhotoDeleteImgvCollectionCell.m
//  Social
//
//  Created by duhongbo on 17/3/26.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoDeleteImgvCollectionCell.h"
#import "KBPhotoBrowserDefine.h"

@interface KBPhotoDeleteImgvCollectionCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView  *imageView;

@end

@implementation KBPhotoDeleteImgvCollectionCell



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.scrollView addSubview:self.imageView];
        [self addSubview:self.scrollView];
    }
    return self;
}



- (void)resetSubviewSize {
    CGRect frame;
    frame.origin = CGPointZero;
    
    UIImage *image = self.imageView.image;
    CGFloat imageScale = image.size.height/image.size.width;
    CGFloat screenScale = kHeight/kWidth;
    if (image.size.width <= self.frame.size.width && image.size.height <= self.frame.size.height) {
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
    } else {
        if (imageScale > screenScale) {
            frame.size.height = self.frame.size.height;
            frame.size.width = self.frame.size.height/imageScale;
        } else {
            frame.size.width = self.frame.size.width;
            frame.size.height = self.frame.size.width * imageScale;
        }
    }
    
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = frame.size;
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.imageView.frame = frame;
    self.imageView.center = self.scrollView.center;
}


#pragma mark -所有手势事件操作-
- (void)singleTapAction:(UITapGestureRecognizer *)singleTap
{
    if (self.singleTapCurImageCallBack) self.singleTapCurImageCallBack();
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap
{
    UIScrollView *scrollView = (UIScrollView *)tap.view;
    
    CGFloat scale = 1;
    if (scrollView.zoomScale != 3.0) {
        scale = 3;
    } else {
        scale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[tap locationInView:tap.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
}



- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}






# pragma mark --Setter&&Getter--
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [_scrollView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _scrollView;
}



- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}




- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
    [self resetSubviewSize];
}


@end
