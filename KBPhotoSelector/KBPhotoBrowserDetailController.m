//
//  KBPhotoBrowserDetailController.m
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoBrowserDetailController.h"
#import "KBPhotoBrowserBigImageController.h"
#import "KBPhotoBrowserTableController.h"
#import "KBPhotoBrowserCollectionCell.h"
#import "KBPhotoBrowserTool.h"
#import "KBSelectPhotoModel.h"
#import "KBPhotoBrowserDefine.h"

#import <Photos/Photos.h>
#import "Masonry.h"
// 点击Cell上按钮时，按钮闪动动画
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


@interface KBPhotoBrowserDetailController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    NSMutableArray<PHAsset *> *_arrayDataSources;
    BOOL _isLayoutOK;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView   *bottomTabBarView;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnDone;

@end

@implementation KBPhotoBrowserDetailController

- (void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self navLeftBtn_Click];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arrayDataSources = [NSMutableArray array];
    
    [_arrayDataSources addObjectsFromArray:[[KBPhotoBrowserTool sharedPhotoBrowserTool] getAssetsInAssetCollection:self.assetCollection ascending:YES]];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomTabBarView];
    
    [self getAssetInAssetCollection];
    [self resetBottomBtnsStatus];
    
    CGFloat collectionViewHeight = [UIScreen mainScreen].bounds.size.height - 50;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(collectionViewHeight));
    }];
    
    
    [self.bottomTabBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
    }];
    
    
    [self.btnDone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomTabBarView.mas_centerY);
        make.right.equalTo(self.bottomTabBarView.mas_right).offset(-15);
        make.width.equalTo(@100);
    }];
    
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomTabBarView.mas_centerY);
        make.left.equalTo(self.bottomTabBarView.mas_left).offset(15);
        make.width.equalTo(@80);
    }];
}



- (void)getAssetInAssetCollection {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 44;
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

    
- (void)navLeftBtn_Click{
    self.backSenderVc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    [self.navigationController popViewControllerAnimated:YES];
}
    
    

- (void)navRightBtn_Click {
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KBPhotoBrowserCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KBPhotoBrowserCollectionCell" forIndexPath:indexPath];
    
    cell.btnSelected.selected = NO;
    PHAsset *asset = _arrayDataSources[indexPath.row];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    
    CGSize size = cell.frame.size;
    size.width *= 2.5;
    size.height *= 2.5;
    
    __weak typeof(self) weakSelf = self;
    [[KBPhotoBrowserTool sharedPhotoBrowserTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        cell.imageView.image = image;
        for (KBSelectPhotoModel *model in weakSelf.arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.btnSelected.selected = YES;
                break;
            }
        }
    }];
    cell.btnSelected.tag = indexPath.row;
    [cell.btnSelected addTarget:self action:@selector(cell_btn_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self pushShowBigImgVCWithDataArray:_arrayDataSources selectIndex:indexPath.row];
}


- (void)pushShowBigImgVCWithDataArray:(NSArray<PHAsset *> *)dataArray selectIndex:(NSInteger)selectIndex {
    KBPhotoBrowserBigImageController *svc = [[KBPhotoBrowserBigImageController alloc] init];
    svc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    svc.assets         = dataArray;
    svc.selectIndex    = selectIndex;
    svc.maxSelectCount = _maxSelectCount;
    svc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    svc.isPresent = NO;
    svc.shouldReverseAssets = NO;
    
    
    @WeakObj(self);
    [svc setOnSelectedPhotos:^(NSArray<KBSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        @StrongObj(self);
        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [self.arraySelectPhotos removeAllObjects];
        [self.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [self.collectionView reloadData];
        [self resetBottomBtnsStatus];
    }];
    [svc setBtnDoneBlock:^(NSArray<KBSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        @StrongObj(self);
        self.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [self.arraySelectPhotos removeAllObjects];
        [self.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [self btnDone_Click:nil];
    }];
    
    [self.navigationController pushViewController:svc animated:YES];
}





- (void)cell_btn_Click:(UIButton *)btn {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        alertView.title = [NSString stringWithFormat:@"最多只能选择%ld张",(long)self.maxSelectCount];
        [alertView show];
        return;
    }
    
    PHAsset *asset = _arrayDataSources[btn.tag];
    
    if (!btn.selected) {
        //添加图片到选中数组
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        
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
        for (KBSelectPhotoModel *model in _arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                [_arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
    btn.selected = !btn.selected;
    [self resetBottomBtnsStatus];
}




- (void)btnDone_Click:(UIButton *)sender {
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (void)btnCancel_Click:(UIButton *)sender {
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (void)resetBottomBtnsStatus {
    NSString *newBtnDoneTitle = [NSString stringWithFormat:@"确认(%ld/%ld)",(long)_arraySelectPhotos.count,(long)_arrayDataSources.count];
    if (self.arraySelectPhotos.count > 0) {
        self.btnDone.enabled = YES;
        [self.btnDone setTitle:newBtnDoneTitle forState:UIControlStateNormal];
        self.btnDone.backgroundColor = [UIColor colorWithRed:0.22f green:0.71f blue:0.29f alpha:1.00f];
    } else {
        self.btnDone.enabled = NO;
        [self.btnDone setTitle:newBtnDoneTitle forState:UIControlStateNormal];
        self.btnDone.backgroundColor = [UIColor grayColor];
    }
    [self.btnDone.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
}



# pragma mark --Setter&&Getter--
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        layout.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width-6)/3, ([UIScreen mainScreen].bounds.size.width-6)/3);
        layout.minimumInteritemSpacing = 1.5;
        layout.minimumLineSpacing = 1.5;
        layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
        
        _collectionView.backgroundColor = [UIColor lightGrayColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"KBPhotoBrowserCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"KBPhotoBrowserCollectionCell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}


- (UIView *)bottomTabBarView {
    if (!_bottomTabBarView) {
        _bottomTabBarView = [[UIView alloc]init];
        _bottomTabBarView.backgroundColor = [UIColor whiteColor];
        [_bottomTabBarView addSubview:self.btnCancel];
        [_bottomTabBarView addSubview:self.btnDone];
    }
    return _bottomTabBarView;
}


- (UIButton *)btnDone {
    if (!_btnDone) {
        _btnDone = [[UIButton alloc]init];
        _btnDone.backgroundColor = [UIColor grayColor];
        NSString *btnDoneTitle = [NSString stringWithFormat:@"确认(0/%ld)",(long)_arrayDataSources.count];
        [_btnDone setTitle:btnDoneTitle forState:UIControlStateNormal];
        [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
        _btnDone.enabled = NO;
    }
    return _btnDone;
}


- (UIButton *)btnCancel {
    if (!_btnCancel) {
        _btnCancel = [[UIButton alloc]init];
        [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        _btnCancel.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnCancel setTitleColor:[UIColor colorWithRed:0.22f green:0.71f blue:0.29f alpha:1.00f] forState:UIControlStateNormal];
        [_btnCancel addTarget:self action:@selector(btnCancel_Click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnCancel;
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
