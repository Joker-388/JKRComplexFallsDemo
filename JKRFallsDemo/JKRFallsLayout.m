//
//  JKRFallsLayout.m
//  JKRFallsDemo
//
//  Created by Lucky on 16/3/22.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "JKRFallsLayout.h"

@interface JKRFallsLayout ()

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attrsArray; ///< 所有的cell的布局
@property (nonatomic, strong) NSMutableArray *columnHeights;                                  ///< 每一列的高度
@property (nonatomic, assign) NSInteger noneDoubleTime;                                       ///< 没有生成大尺寸次数
@property (nonatomic, assign) NSInteger lastDoubleIndex;                                      ///< 最后一次大尺寸的列数
@property (nonatomic, assign) NSInteger lastFixIndex;                                         ///< 最后一次对齐矫正列数

- (CGFloat)columnCount;     ///< 列数
- (CGFloat)columnMargin;    ///< 列边距
- (CGFloat)rowMargin;       ///< 行边距
- (UIEdgeInsets)edgeInsets; ///< collectionView边距

@end

@implementation JKRFallsLayout

#pragma mark - 默认参数
static const CGFloat JKRDefaultColumnCount = 3;                           ///< 默认列数
static const CGFloat JKRDefaultColumnMargin = 10;                         ///< 默认列边距
static const CGFloat JKRDefaultRowMargin = 10;                            ///< 默认行边距
static const UIEdgeInsets JKRDefaultUIEdgeInsets = {10, 10, 10, 10};      ///< 默认collectionView边距

#pragma mark - 布局计算
// collectionView 首次布局和之后重新布局的时候会调用
// 并不是每次滑动都调用，只有在数据源变化的时候才调用
- (void)prepareLayout
{
    // 重写必须调用super方法
    [super prepareLayout];
    
    // 判断如果有50个cell（首次刷新），就重新计算
    if ([self.collectionView numberOfItemsInSection:0] == 50) {
        [self.attrsArray removeAllObjects];
        [self.columnHeights removeAllObjects];
    }
    // 当列高度数组为空时，即为第一行计算，每一列的基础高度加上collection的边框的top值
    if (!self.columnHeights.count) {
        for (NSInteger i = 0; i < self.columnCount; i++) {
            [self.columnHeights addObject:@(self.edgeInsets.top)];
        }
    }
    // 遍历所有的cell，计算所有cell的布局
    for (NSInteger i = self.attrsArray.count; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 计算布局属性并将结果添加到布局属性数组中
        [self.attrsArray addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
}

// 返回布局属性，一个UICollectionViewLayoutAttributes对象数组
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrsArray;
}

// 计算布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // collectionView的宽度
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    // cell的宽度
    CGFloat w = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right -
                 self.columnMargin * (self.columnCount - 1)) / self.columnCount;
    // cell的高度
    NSUInteger randomOfHeight = arc4random() % 100;
    CGFloat h = w * (randomOfHeight >= 50 ? 250 : 320) / 200;
    
    // cell应该拼接的列数
    NSInteger destColumn = 0;
    
    // 高度最小的列数高度
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    // 获取高度最小的列数
    for (NSInteger i = 1; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    // 计算cell的x
    CGFloat x = self.edgeInsets.left + destColumn * (w + self.columnMargin);
    // 计算cell的y
    CGFloat y = minColumnHeight;
    if (y != self.edgeInsets.top) {
        y += self.rowMargin;
    }
    
    // 随机数，用来随机生成大尺寸cell
    NSUInteger randomOfWhetherDouble = arc4random() % 100;
    
    // 判断是否放大
    if (destColumn < self.columnCount - 1                               // 放大的列数不能是最后一列（最后一列方法超出屏幕）
        && _noneDoubleTime >= 1                                         // 如果前个cell有放大就不放大，防止连续出现两个放大
        && (randomOfWhetherDouble >= 45 || _noneDoubleTime >= 8)        // 45%几率可能放大，如果累计8次没有放大，那么满足放大条件就放大
        && [self.columnHeights[destColumn] doubleValue] == [self.columnHeights[destColumn + 1] doubleValue] // 当前列的顶部和下一列的顶部要对齐
        && _lastDoubleIndex != destColumn) {             // 最后一次放大的列不等当前列，防止出现连续两列出现放大不美观
        _noneDoubleTime = 0;
        _lastDoubleIndex = destColumn;
        // 重定义当前cell的布局:宽度*2,高度*2
        attrs.frame = CGRectMake(x, y, w * 2 + self.columnMargin, h * 2 + self.rowMargin);
        // 当前cell列的高度就是当前cell的最大Y值
        self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
        // 当前cell列下一列的高度也是当前cell的最大Y值，因为cell宽度*2,占两列
        self.columnHeights[destColumn + 1] = @(CGRectGetMaxY(attrs.frame));
    } else {
        // 正常cell的布局
        if (_noneDoubleTime <= 3 || _lastFixIndex == destColumn) {                     // 如果没有放大次数小于3且当前列等于上次矫正的列，就不矫正
            attrs.frame = CGRectMake(x, y, w, h);
        } else if (self.columnHeights.count > destColumn + 1                         // 越界判断
            && y + h - [self.columnHeights[destColumn + 1] doubleValue] < w * 0.1) { // 当前cell填充后和上一列的高度偏差不超过cell最大高度的10%，就和下一列对齐
            attrs.frame = CGRectMake(x, y, w, [self.columnHeights[destColumn + 1] doubleValue] - y);
            _lastFixIndex = destColumn;
        } else if (destColumn >= 1                                                   // 越界判断
                   && y + h - [self.columnHeights[destColumn - 1] doubleValue] < w * 0.1) { // 当前cell填充后和上上列的高度偏差不超过cell最大高度的10%，就和下一列对齐
            attrs.frame = CGRectMake(x, y, w, [self.columnHeights[destColumn - 1] doubleValue] - y);
            _lastFixIndex = destColumn;
        } else {
            attrs.frame = CGRectMake(x, y, w, h);
        }
        // 当前cell列的高度就是当前cell的最大Y值
        self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
        _noneDoubleTime += 1;
    }
    // 返回计算获取的布局
    return attrs;
}

// 返回collectionView的ContentSize
- (CGSize)collectionViewContentSize
{
    // collectionView的contentSize的高度等于所有列高度中最大的值
    CGFloat maxColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (maxColumnHeight < columnHeight) {
            maxColumnHeight = columnHeight;
        }
    }
    return CGSizeMake(0, maxColumnHeight + self.edgeInsets.bottom);
}

#pragma mark - 懒加载
- (NSMutableArray *)attrsArray
{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (CGFloat)rowMargin
{
    if ([self.delegate respondsToSelector:@selector(rowMarginInFallsLayout:)]) {
        return [self.delegate rowMarginInFallsLayout:self];
    } else {
        return JKRDefaultRowMargin;
    }
}

- (CGFloat)columnCount
{
    if ([self.delegate respondsToSelector:@selector(columnCountInFallsLayout:)]) {
        return [self.delegate columnCountInFallsLayout:self];
    } else {
        return JKRDefaultColumnCount;
    }
}

- (CGFloat)columnMargin
{
    if ([self.delegate respondsToSelector:@selector(columnMarginInFallsLayout:)]) {
        return [self.delegate columnMarginInFallsLayout:self];
    } else {
        return JKRDefaultColumnMargin;
    }
}

- (UIEdgeInsets)edgeInsets
{
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInFallsLayout:)]) {
        return [self.delegate edgeInsetsInFallsLayout:self];
    } else {
        return JKRDefaultUIEdgeInsets;
    }
}

@end
