//
//  WorkViewController.m
//  ZBViewSectionBackgroundDemo
//
//  Created by ZB on 2020/10/27.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "WorkViewController.h"
#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>

@interface WorkViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation WorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //查看healthKit在设备上是否可用，ipad不支持HealthKit
    if(![HKHealthStore isHealthDataAvailable]) {
        NSLog(@"设备不支持healthKit");
    }
    
    //创建healthStore实例对象
    self.healthStore = [[HKHealthStore alloc] init];
    
    //设置需要获取的权限这里仅设置了步数
    HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSet *healthSet = [NSSet setWithObjects:stepCount, nil];
    
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"获取步数权限成功");
            //获取步数后我们调用获取步数的方法
            HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            [self fetchSumOfSamplesTodayForType:stepType unit:[HKUnit countUnit] completion:^(double stepCount, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",[NSString stringWithFormat:@"%.f",stepCount]);
                });
            }];
        }
        else {
            NSLog(@"获取步数权限失败");
        }
    }];
}

- (IBAction)getStepCountAction:(id)sender {
    [[HealthKitManager shareInstance] getStepCountWith:self.textField.text block:^(double stepCount, NSError * _Nonnull error) {
        NSLog(@"步数%f, %@",stepCount, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = [NSString stringWithFormat:@"步数：%0.f",stepCount];
        });
    }];
}

#pragma mark - 读取健康数据
- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [self predicateForSamplesToday];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        
        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];
            
            completionHandler(value, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

#pragma mark - 获取当天的步数
- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:1370000000];
    NSDate *startDate = [calendar startOfDayForDate:now];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

@end
