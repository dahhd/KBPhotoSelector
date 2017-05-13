//
//  KBPhotoBrowserBigImageController.m
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoBrowserBigImageController.h"
#import "KBPhotoBigImageCollectionCell.h"
#import "KBSelectPhotoModel.h"
#import "KBPhotoBrowserTool.h"
#import "KBPhotoBrowserDefine.h"

#define kItemMargin 30


static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}


@interface KBPhotoBrowserBigImageController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

{
    NSMutableArray<PHAsset*> *_arrayDataSource;
    
    UICollectionView *_collectionView;
    UIButton *_navRightBtn; //导航栏右边选中按钮
    
    //大图滚动scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
    
    //底部View
    UIView *_bottomView;
    UIButton *_btnDone;
}

@end

@implementation KBPhotoBrowserBigImageController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.shouldReverseAssets) {
        [_collectionView setContentOffset:CGPointMake((self.assets.count-self.selectIndex-1)*(kWidth+kItemMargin), 0)];
    } else {
        [_collectionView setContentOffset:CGPointMake(self.selectIndex*(kWidth+kItemMargin), 0)];
    }
    [self changeBtnDoneTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configMyCustomView];
    //[self configAutoLayout];
    [self sortAsset];
}




- (void)configMyCustomView {
    //initNavgationBar
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    [_navRightBtn setBackgroundImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:[UIImage imageNamed:@"choose_selected"] forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navRightBtn];
    
    
    //overr backBtn
    UIImage *navBackImg = [UIImage imageNamed:@"navBackBtn"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    
    //initCollectionView
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layOut.minimumLineSpacing = kItemMargin;
    layOut.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layOut.itemSize = self.view.bounds.size;
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-kItemMargin/2, 0, kWidth+kItemMargin, kHeight) collectionViewLayout:layOut];
    [_collectionView registerClass:[KBPhotoBigImageCollectionCell class] forCellWithReuseIdentifier:@"KBPhotoBigImageCollectionCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
    
    
    
    //initBottomTabBar
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, kWidth, 44)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(kWidth - 100 - 20, 6, 100, 30);
    [_btnDone setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",@"确认",self.arraySelectPhotos.count,_arrayDataSource.count] forState:UIControlStateNormal];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3.0f;
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setBackgroundColor:[UIColor grayColor]];
    [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    _btnDone.enabled = NO;
    [_bottomView addSubview:_btnDone];
    
    [self.view addSubview:_bottomView];
}

- (void)configAutoLayout {
    
}


//初始化页面数据
- (void)sortAsset {
    _arrayDataSource = [NSMutableArray array];
    if (self.shouldReverseAssets) {
        NSEnumerator *enumerator = [self.assets reverseObjectEnumerator];
        id obj;
        while (obj = [enumerator nextObject]) {
            [_arrayDataSource addObject:obj];
        }
        //当前页
        _currentPage = _arrayDataSource.count-self.selectIndex;
    } else {
        [_arrayDataSource addObjectsFromArray:self.assets];
        _currentPage = self.selectIndex + 1;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSource.count];
}




#pragma mark --selectCurrentImageAction--
- (void)navRightBtn_Click:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && sender.selected == NO) {
        alertView.title = [NSString stringWithFormat:@"最多只能选择%ld张",(long)self.maxSelectCount];
        [alertView show];
        return;
    }
    PHAsset *asset = _arrayDataSource[_currentPage-1];
    if (![self isHaveCurrentPageImage]) {
         [sender.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        
        if (![[KBPhotoBrowserTool sharedPhotoBrowserTool] judgeAssetisInLocalAblum:asset]) {
            alertView.title = @"图片已存在本地或已存在iCloud";
            [alertView show];
            return;
        }
        KBSelectPhotoModel *model = [[KBSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    } else {
        [self removeCurrentPageImage];
    }
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
    [self changeBtnDoneTitle];
}

    
- (BOOL)isHaveCurrentPageImage {
    PHAsset *asset = _arrayDataSource[_currentPage-1];
    for (KBSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

    
- (void)removeCurrentPageImage {
    PHAsset *asset = _arrayDataSource[_currentPage-1];
    for (KBSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            [_arraySelectPhotos removeObject:model];
            break;
        }
    }
}
    
    
# pragma mark --update btnDoneTitle && navgationBarTitle--
- (void)changeNavRightBtnStatus {
    if ([self isHaveCurrentPageImage]) {
        _navRightBtn.selected = YES;
    } else {
        _navRightBtn.selected = NO;
    }
}


# pragma mark --update btnDone satatus--
- (void)changeBtnDoneTitle {
    [_btnDone setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",@"确认",self.arraySelectPhotos.count,_arrayDataSource.count] forState:UIControlStateNormal];
    if (self.arraySelectPhotos.count > 0) {
        _btnDone.enabled = YES;
        [_btnDone setBackgroundColor:[UIColor colorWithRed:0.22f green:0.71f blue:0.29f alpha:1.00f]];
    }else {
        _btnDone.enabled = NO;
        [_btnDone setBackgroundColor:[UIColor grayColor]];
    }
    [_btnDone.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
}

    

# pragma mark --showOrhide--TheNav-Tab--
- (void)showNavBarAndBottomView {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    CGRect frame = _bottomView.frame;
    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
    }];
}

- (void)hideNavBarAndBottomView {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    CGRect frame = _bottomView.frame;
    frame.origin.y += frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.frame = frame;
    }];
}


    
#pragma mark --btnDone--Action--
- (void)btnDone_Click:(UIButton *)sender {
    if (self.arraySelectPhotos.count == 0) {
        PHAsset *asset = _arrayDataSource[_currentPage-1];
        if (![[KBPhotoBrowserTool sharedPhotoBrowserTool] judgeAssetisInLocalAblum:asset]) {
            return;
        }
        KBSelectPhotoModel *model = [[KBSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    }
    if (self.btnDoneBlock) {
        self.btnDoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
}
    

# pragma mark --backPopAction--
- (void)btnBack_Click {
    if (self.onSelectedPhotos) {
        self.onSelectedPhotos(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
    
    if (self.isPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        //pop时隐藏collectionView的黑色背景
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


# pragma mark --UICollectionViewDataSource--
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrayDataSource.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KBPhotoBigImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KBPhotoBigImageCollectionCell" forIndexPath:indexPath];
    PHAsset *asset = _arrayDataSource[indexPath.row];
    
    cell.asset = asset;
    @WeakObj(self);
    cell.singleTapCallBack = ^() {  //单击or双击照片
        @StrongObj(self);
        if (self.navigationController.navigationBar.isHidden) {
            [self showNavBarAndBottomView];
        } else {
            [self hideNavBarAndBottomView];
        }
    };
    return cell;
}


#pragma mark --UIScrollViewDelegate--
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == (UIScrollView *)_collectionView) {
        //改变导航标题
        CGFloat page = scrollView.contentOffset.x/(kWidth+kItemMargin);
        NSString *str = [NSString stringWithFormat:@"%.0f", page];
        _currentPage = str.integerValue + 1;
        self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSource.count];
        [self changeNavRightBtnStatus];
    }
}



# pragma mark --check-ThePushController-From-Where--
- (BOOL)checkCurrentControllerBeforeClass {
    BOOL isTrue = NO;
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:NSClassFromString(@"KBSocialNewPostsController")]) {
            isTrue = YES;
            break;
        }
    }
    return isTrue;
}
    
    




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
