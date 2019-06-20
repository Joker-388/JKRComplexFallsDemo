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
- (void)setupCollectionView {
    JKRFallsLayout *fallsLayout = [[JKRFallsLayout alloc] init];
    fallsLayout.delegate = self;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:fallsLayout];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([JKRShopCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
}

#pragma mark - 创建上下拉刷新
- (void)setupRefresh {
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - 加载下拉数据
- (void)loadNewShops {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.easy-mock.com/mock/5cff89e36c54457798010709/shop/finderlist"]];
    request.HTTPMethod = @"GET";
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            [weakSelf.shops removeAllObjects];
            [weakSelf.shops addObjectsFromArray:[JKRShop mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        }
    }];
    [task resume];
}

#pragma mark - 加载上拉数据
- (void)loadMoreShops {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.easy-mock.com/mock/5cff89e36c54457798010709/shop/finderlist"]];
    request.HTTPMethod = @"GET";
    __weak typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            [weakSelf.shops addObjectsFromArray:[JKRShop mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView.mj_footer endRefreshing];
                [weakSelf.collectionView reloadData];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView.mj_header endRefreshing];
                [weakSelf.collectionView reloadData];
            });
        }
    }];
    [task resume];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shops.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JKRShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.shop = self.shops[indexPath.row];
    return cell;
}

- (CGFloat)columnMarginInFallsLayout:(JKRFallsLayout *)fallsLayout {
    return 5;
}

- (CGFloat)rowMarginInFallsLayout:(JKRFallsLayout *)fallsLayout {
    return 5;
}

- (CGFloat)columnCountInFallsLayout:(JKRFallsLayout *)fallsLayout {
    return 4;
}

- (UIEdgeInsets)edgeInsetsInFallsLayout:(JKRFallsLayout *)fallsLayout {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (JKRShop *)shopWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.shops.count) {
        return self.shops[indexPath.row];
    } else {
        return nil;
    }
}

- (NSMutableArray *)shops {
    if (!_shops) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}

@end
