//
//  HomeViewController.m
//  ZBViewSectionBackgroundDemo
//
//  Created by ZB on 2020/7/21.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView

// 有多少个分组,默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 16;
}

// 多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section + 3;
}

// header view的高度。
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

// 返回指定section header的view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *headerSectionID = @"headerSectionID";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerSectionID];
    if (!headerView){
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerSectionID];
        headerView.contentView.backgroundColor = [UIColor whiteColor];
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 415, 40)];
        view.backgroundColor = [UIColor redColor];
        
        CGFloat radius = 8;
        CGRect bounds = CGRectInset(view.bounds, 15, 0);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(radius, radius)];
        
        CAShapeLayer *normalLayer = [[CAShapeLayer alloc] init];
        normalLayer.path = bezierPath.CGPath;
        normalLayer.fillColor = [UIColor yellowColor].CGColor;
        [view.layer insertSublayer:normalLayer atIndex:0];
        
        [headerView.contentView addSubview:view];
        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 400, 40)];
//        label.backgroundColor = [UIColor greenColor];
//        label.tag = 1000;
//        label.textColor = [UIColor blueColor];
//        label.font = [UIFont systemFontOfSize:16];
//        [headerView.contentView addSubview:label];
    }
    headerView.textLabel.text = [NSString stringWithFormat:@"第%ld组", section];
//    headerView.detailTextLabel.text = [NSString stringWithFormat:@"==%ld", section];
    UILabel *lab = (UILabel *)[headerView viewWithTag:1000];
    lab.text = [NSString stringWithFormat:@"第%ld组", section];
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat radius = 8;
    cell.backgroundColor = UIColor.clearColor;
    // 创建两个layer
    CAShapeLayer *normalLayer = [[CAShapeLayer alloc] init];
    CAShapeLayer *selectLayer = [[CAShapeLayer alloc] init];
    // 获取显示区域大小
    CGRect bounds = CGRectInset(cell.bounds, 15, 0);
    // 获取每组行数
    NSInteger rowNum = [tableView numberOfRowsInSection:indexPath.section];
    // 贝塞尔曲线
    UIBezierPath *bezierPath = nil;
    
    if (rowNum == 1) {
        // 一组只有一行（四个角全部为圆角）
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    } else {
        if (indexPath.row == 0) {
            // 每组第一行（添加左上和右上的圆角）
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(radius, radius)];
        } else if (indexPath.row == rowNum - 1) {
            // 每组最后一行（添加左下和右下的圆角）
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
        } else {
            // 每组不是首位的行不设置圆角
            bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        }
    }
    
    
    
    //cell 的 backgroundView
    // 把已经绘制好的贝塞尔曲线路径赋值给图层，然后图层根据path进行图像渲染render
    normalLayer.path = bezierPath.CGPath;
    selectLayer.path = bezierPath.CGPath;
    
    UIView *nomarBgView = [[UIView alloc] initWithFrame:bounds];
    // 设置填充颜色
    normalLayer.fillColor = [UIColor whiteColor].CGColor;
    // 添加图层到nomarBgView中
    [nomarBgView.layer insertSublayer:normalLayer atIndex:0];
    nomarBgView.backgroundColor = UIColor.clearColor;
    cell.backgroundView = nomarBgView;
    
    
    //cell selectedBackgroundView 被选中时候的颜色
    UIView *selectBgView = [[UIView alloc] initWithFrame:bounds];
    selectLayer.fillColor = [UIColor yellowColor].CGColor;
    [selectBgView.layer insertSublayer:selectLayer atIndex:0];
    selectBgView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectBgView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;//让cell能响应选中事件，但是选中后的颜色不发生改变
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld组", indexPath.section];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"第%ld行", indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 13.0, *)) {
            _tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
        } else {
            _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
    }
    return _tableView;
}

@end
