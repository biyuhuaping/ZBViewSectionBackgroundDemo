//
//  WorkViewController.m
//  ZBViewSectionBackgroundDemo
//
//  Created by ZB on 2020/10/27.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "WorkViewController.h"
#import "HealthKitManager.h"

@interface WorkViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation WorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //从健康应用中获取权限
    [[HealthKitManager shareInstance] authorizateHealthKit:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"获取步数权限成功");
        }
        else {
            NSLog(@"获取步数权限失败");
        }
    }];
}

//点击获取步数
- (IBAction)getStepCountAction:(id)sender {
    [[HealthKitManager shareInstance] getStepCountWith:self.textField.text block:^(double stepCount, NSError * _Nonnull error){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"%@天步数：%0.f",self.textField.text,stepCount];
            self.textField.text = @"";
        });
    }];
}

//收起键盘
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
    [self.view endEditing:YES];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
