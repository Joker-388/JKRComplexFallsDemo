//
//  JKRFallsLayout.h
//  JKRFallsDemo
//
//  Created by Lucky on 16/3/22.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKRImageModel.h"
@class JKRFallsLayout;

// 每页图片数
#define PageCount 48

@protocol JKRFallsLayoutDelegate <NSObject>

@optional
/// 列数
- (CGFloat)columnCountInFallsLayout:(JKRFallsLayout *)fallsLayout;
/// 列间距
- (CGFloat)columnMarginInFallsLayout:(JKRFallsLayout *)fallsLayout;
/// 行间距
- (CGFloat)rowMarginInFallsLayout:(JKRFallsLayout *)fallsLayout;
/// collectionView边距
- (UIEdgeInsets)edgeInsetsInFallsLayout:(JKRFallsLayout *)fallsLayout;
/// 返回图片模型
- (JKRImageModel *)modelWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface JKRFallsLayout : UICollectionViewLayout

@property (nonatomic, weak) id<JKRFallsLayoutDelegate> delegate;

@end
