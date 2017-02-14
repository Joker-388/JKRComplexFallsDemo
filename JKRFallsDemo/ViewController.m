//
//  ViewController.m
//  JKRFallsDemo
//
//  Created by Lucky on 16/3/22.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "ViewController.h"
#import "JKRFallsLayout.h"
#import <MJExtension.h>
#import <MJRefresh.h>
#import "JKRShopCell.h"
#import "JKRShop.h"

@interface ViewController ()<UICollectionViewDataSource, JKRFallsLayoutDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *shops;

@end

@implementation ViewController

static NSString *const ID = @"shop";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    [self setupRefresh];
}

#pragma mark - 创建collectionView
- (void)setupCollectionView
{
    JKRFallsLayout *fallsLayout = [[JKRFallsLayout alloc] init];
    fallsLayout.delegate = self;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:fallsLayout];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JKRShopCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
}

#pragma mark - 创建上下拉刷新
- (void)setupRefresh
{
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - 加载下拉数据
- (void)loadNewShops
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *shops = [JKRShop mj_objectArrayWithFilename:@"1.plist"];
        [weakSelf.shops removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView reloadData];
            [weakSelf.shops addObjectsFromArray:shops];
            [weakSelf.collectionView.mj_header endRefreshing];
            [weakSelf.collectionView reloadData];
        });
    });
}

#pragma mark - 加载上拉数据
- (void)loadMoreShops
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *shops = [JKRShop mj_objectArrayWithFilename:@"1.plist"];
        [weakSelf.shops addObjectsFromArray:shops];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.collectionView.mj_footer endRefreshing];
            [weakSelf.collectionView reloadData];
        });
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.collectionView.mj_footer.hidden = self.shops.count == 0;
    return self.shops.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JKRShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    if (self.shops && self.shops.count >= indexPath.item+1) cell.shop = self.shops[indexPath.item];
    return cell;
}

- (CGFloat)columnMarginInFallsLayout:(JKRFallsLayout *)fallsLayout
{
    return 5;
}

- (CGFloat)rowMarginInFallsLayout:(JKRFallsLayout *)fallsLayout
{
    return 5;
}

- (CGFloat)columnCountInFallsLayout:(JKRFallsLayout *)fallsLayout
{
    return 4;
}

- (UIEdgeInsets)edgeInsetsInFallsLayout:(JKRFallsLayout *)fallsLayout
{
    return UIEdgeInsetsMake(20, 10, 20, 10);
}

- (NSMutableArray *)shops
{
    if (!_shops) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}

@end
