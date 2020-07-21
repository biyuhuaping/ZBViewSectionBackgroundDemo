//
//  ZBCollectionReusableView.m
//  ZBCollectionViewSectionBackgroundDemo
//
//  Created by ZB on 2020/2/21.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "ZBCollectionReusableView.h"

@implementation ZBCollectionReusableView

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{
    [super applyLayoutAttributes:layoutAttributes];
    //绘制曲线(这里是圆角)
//    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(8, 8)];

    //新建一个图层
    CAShapeLayer *layer = [CAShapeLayer layer];
    //图层边框路径
    layer.path = bezierPath.CGPath;
    //图层填充色,也就是cell的底色
    layer.fillColor = [UIColor whiteColor].CGColor;
    //图层边框线条颜色
//    layer.strokeColor = [UIColor greenColor].CGColor;
    //将图层添加到cell的图层中,并插到最底层
    [self.layer insertSublayer:layer atIndex:0];
}

@end
