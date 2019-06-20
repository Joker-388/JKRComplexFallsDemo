//
//  JKRShopCell.m
//  JKRFallsDemo
//
//  Created by Lucky on 16/3/22.
//  Copyright © 2016年 Lucky. All rights reserved.
//

#import "JKRShopCell.h"
#import "JKRImageModel.h"
#import <UIImageView+WebCache.h>

@interface JKRShopCell ()

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation JKRShopCell

- (void)setModel:(JKRImageModel *)model {
    _model = model;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"loading"]];
}

@end
