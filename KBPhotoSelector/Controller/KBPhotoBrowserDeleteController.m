//
//  KBPhotoBrowserDeleteController.m
//  Social
//
//  Created by duhongbo on 17/3/26.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoBrowserDeleteController.h"
#import "KBPhotoDeleteImgvCollectionCell.h"
#import "KBPhotoBrowserDefine.h"

@interface KBPhotoBrowserDeleteController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
    
{
    UIButton *_navDeleteBtn;
    UICollectionView *_curCollectionView;
    
    NSInteger _currentPage;
    NSMutableArray<UIImage*> *_curImagesDataSource;
}
    
@end

@implementation KBPhotoBrowserDeleteController
    
    
- (instancetype)init {
    if (self = [super init]) {
        _curImagesDataSource = [NSMutableArray array];
    }
    return self;
}
    
    
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_curCollectionView setContentOffset:CGPointMake(self.currentIndex*(kWidth+kItemMargin), 0)];
}
    
    
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configCurrentViews];
}
    
    
    
- (void)configCurrentViews {
    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _curImagesDataSource.count];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    //init_NavDeleteBtn
    _navDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navDeleteBtn.frame = CGRectMake(0, 0, 25, 25);
    [_navDeleteBtn setBackgroundImage:[UIImage imageNamed:@"express_delete_icon"] forState:UIControlStateNormal];
    [_navDeleteBtn setBackgroundImage:[UIImage imageNamed:@"express_delete_icon"] forState:UIControlStateSelected];
    [_navDeleteBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navDeleteBtn];
    
    
    //overr backBtn
    UIImage *navBackImg = [UIImage imageNamed:@"navBackBtn"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    
    //init_CollectionView
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layOut.minimumLineSpacing = kItemMargin;
    layOut.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layOut.itemSize = self.view.bounds.size;
    
    _curCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-kItemMargin/2, 0, kWidth+kItemMargin, kHeight) collectionViewLayout:layOut];
    _curCollectionView.backgroundColor = [UIColor blackColor];
    [_curCollectionView registerClass:[KBPhotoDeleteImgvCollectionCell class] forCellWithReuseIdentifier:@"KBPhotoDeleteImgvCollectionCell"];
    _curCollectionView.dataSource = self;
    _curCollectionView.delegate = self;
    _curCollectionView.pagingEnabled = YES;
    [self.view addSubview:_curCollectionView];
}
    
    
    
    
    //删除当前页图片-按钮
- (void)navRightBtn_Click:(UIButton *)sender {
    if (_curImagesDataSource.count == 1) {
        [_curImagesDataSource removeAllObjects];
        if (self.compeletionDeleteBlock) {
            self.compeletionDeleteBlock(_curImagesDataSource);
        }
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
        return;
    }
    
    
    UIImage *curImage = _curImagesDataSource[_currentPage - 1];
    __weak typeof(_curImagesDataSource) __weakImageSource = _curImagesDataSource;
    [__weakImageSource enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj,
                                                    NSUInteger idx,
                                                    BOOL * _Nonnull stop) {
        
        if ([curImage isEqual:obj]) {
            *stop = YES;
            if (*stop == YES) {
                [_curImagesDataSource removeObject:obj];
            }
        }
    }];
    
    [self scrollViewDidScroll:_curCollectionView];
    [_curCollectionView reloadData];
}
    
    
    
    
    
- (void)btnBack_Click {
    if (self.compeletionDeleteBlock) {
        self.compeletionDeleteBlock(_curImagesDataSource);
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}
    
    
    
# pragma mark --UICollectionViewDataSource--
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
    
    
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _curImagesDataSource.count;
}
    
    
    
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KBPhotoDeleteImgvCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KBPhotoDeleteImgvCollectionCell" forIndexPath:indexPath];
    cell.image = _curImagesDataSource[indexPath.row];
    
    __weak typeof(self) __weakSelf = self;
    cell.singleTapCurImageCallBack = ^{
        if (__weakSelf.navigationController.navigationBar.isHidden) {
            [__weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        } else {
            [__weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
    };
    return cell;
}
    
    
# pragma mark --UICollectionViewDelegate--
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == (UIScrollView *)_curCollectionView) {
        //改变导航标题
        CGFloat page = scrollView.contentOffset.x/(kWidth+kItemMargin);
        NSString *str = [NSString stringWithFormat:@"%.0f", page];
        _currentPage = str.integerValue + 1;
        self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld",_currentPage,_curImagesDataSource.count];
    }
}
    
    
- (void)setCurrentSelectedImgeArr:(NSMutableArray<UIImage *> *)currentSelectedImgeArr {
    _curImagesDataSource = currentSelectedImgeArr;
}
    
    
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    _currentPage = currentIndex + 1;
}
    
    
- (void)dealloc {
    NSLog(@"KBPhotoBrowserDeleteController---dealloc");
}
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
    
    
@end
