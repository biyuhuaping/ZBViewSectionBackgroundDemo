//
//  HeaderReusableView.m
//  ZBCollectionViewSectionBackgroundDemo
//
//  Created by ZB on 2020/2/21.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "HeaderReusableView.h"

@implementation HeaderReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 384, 64) byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
    
    //新建一个图层
    CAShapeLayer *layer = [CAShapeLayer layer];
    //图层边框路径
    layer.path = bezierPath.CGPath;
    //图层填充色,也就是cell的底色
    layer.fillColor = [UIColor redColor].CGColor;
    //图层边框线条颜色
    layer.strokeColor = [UIColor greenColor].CGColor;
    //将图层添加到cell的图层中,并插到最底层
    [self.contentView.layer insertSublayer:layer atIndex:0];
}

@end
