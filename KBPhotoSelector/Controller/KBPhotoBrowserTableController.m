//
//  KBPhotoBrowserTableController.m
//  Social
//
//  Created by duhongbo on 17/3/20.
//  Copyright © 2017年 kuaibao. All rights reserved.
//

#import "KBPhotoBrowserTableController.h"
#import "KBPhotoBrowserDetailController.h"
#import "KBPhotoBrowserTableViewCell.h"
#import "KBSelectPhotoModel.h"
#import "KBPhotoBrowserTool.h"
#import "KBPhotoBrowserDefine.h"

@interface KBPhotoBrowserTableController ()

@end

@implementation KBPhotoBrowserTableController
{
    NSMutableArray<KBPhotoAlbumList*> *_arrayDataSources;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"照片";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _arrayDataSources = [NSMutableArray array];
    
    [self configNavGationBar];
    [self loadAllAblums];
    [self pushAllDetailPhotos];
}


- (void)configNavGationBar {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 44;
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.hidesBackButton = YES;
}


- (void)loadAllAblums {
    //获取相册所有照片
    [_arrayDataSources addObjectsFromArray:[[KBPhotoBrowserTool sharedPhotoBrowserTool]getPhotoAblumList]];
}


- (void)pushAllDetailPhotos {
    if (_arrayDataSources.count == 0) {
        return;
    }
    NSInteger i = 0;
    for (KBPhotoAlbumList *ablum in _arrayDataSources) {
        if (ablum.albumCollectionAsset.assetCollectionSubtype == 209) {
            i = [_arrayDataSources indexOfObject:ablum];
            break;
        }
    }
    [self pushThumbnailVCWithIndex:i animated:NO];
}



- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated {
    KBPhotoAlbumList *ablum = _arrayDataSources[index];
    KBPhotoBrowserDetailController *tvc = [[KBPhotoBrowserDetailController alloc]init];
    tvc.navigationItem.title = ablum.albumTitle;
    tvc.maxSelectCount = self.maxSelectCount;
    tvc.assetCollection = ablum.albumCollectionAsset;
    tvc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    tvc.backSenderVc = self;
    tvc.DoneBlock = self.DoneBlock;
    tvc.CancelBlock = self.CancelBlock;
    [self.navigationController pushViewController:tvc animated:animated];
}



- (void)navRightBtn_Click {
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.arraySelectPhotos removeAllObjects];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayDataSources.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KBPhotoBrowserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KBPhotoBrowserTableViewCell"];
    
    if (!cell) {
        cell = [[KBPhotoBrowserTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KBPhotoBrowserTableViewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    KBPhotoAlbumList *ablumList= _arrayDataSources[indexPath.row];
    
    [[KBPhotoBrowserTool sharedPhotoBrowserTool] requestImageForAsset:ablumList.albumFirstImageAsset size:CGSizeMake(65*3, 65*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.headerImage.image = image;
    }];
    cell.title.text = ablumList.albumTitle;
    cell.titleCount.text = [NSString stringWithFormat:@"(%ld)", ablumList.albumCount];
    return cell;
    
}


#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}



    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
