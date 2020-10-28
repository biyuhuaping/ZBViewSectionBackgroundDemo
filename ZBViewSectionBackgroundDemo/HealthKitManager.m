//
//  HealthKitManager.m
//  ZBViewSectionBackgroundDemo
//
//  Created by ZB on 2020/10/27.
//  Copyright © 2020 ZB. All rights reserved.
//

#import "HealthKitManager.h"
#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>

#define IOS8 ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)

@interface HealthKitManager ()

/// 健康数据查询类
@property (nonatomic, strong) HKHealthStore *healthStore;
/// 协处理器类
@property (nonatomic, strong) CMPedometer *pedometer;

@end

@implementation HealthKitManager

#pragma mark - 初始化单例对象
static HealthKitManager *_healthManager;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_healthManager) {
            _healthManager = [[HealthKitManager alloc]init];
        }
    });
    return _healthManager;
}

#pragma mark - 应用授权检查
- (void)authorizateHealthKit:(void (^)(BOOL success, NSError *error))resultBlock {
    if(IOS8) {
        if ([HKHealthStore isHealthDataAvailable]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSSet *readObjectTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount], nil];
                [self.healthStore requestAuthorizationToShareTypes:nil readTypes:readObjectTypes completion:^(BOOL success, NSError * _Nullable error) {
                    if (resultBlock) {
                        resultBlock(success,error);
                    }
                }];
            });
        }
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"iOS 系统低于8.0不能获取健康数据，请升级系统" forKey:NSLocalizedDescriptionKey];
        NSError *aError = [NSError errorWithDomain:@"xxxx.com.cn" code:0 userInfo:userInfo];
        resultBlock(NO,aError);
    }
}

#pragma mark - 获取当天健康数据(步数)
- (void)getStepCountWith:(NSString *)day block:(void (^)(double stepCount, NSError *error))queryResultBlock {
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc]initWithQuantityType:quantityType quantitySamplePredicate:[self predicateForSamples:day] options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        if (error) {
            [self getCMPStepCount: queryResultBlock];
        } else {
            double stepCount = [result.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
            NSLog(@"当天行走步数 = %lf",stepCount);
            if(stepCount > 0){
                if (queryResultBlock) {
                    queryResultBlock(stepCount,nil);
                }
            } else {
                [self getCMPStepCount: queryResultBlock];
            }
        }
        
    }];
    [self.healthStore executeQuery:query];
}

#pragma mark - 构造当天时间段查询参数
- (NSPredicate *)predicateForSamples:(NSString *)day{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
//    [components setDay:1];

    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-day.integerValue toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

- (NSPredicate *)predicateForSamplesToday1 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];

    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    
    components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];

    [components setDay:([components day] - ([components weekday] - 1))];
    NSDate *thisWeek = [cal dateFromComponents:components];
    
    [components setDay:([components day] - 7)];
    NSDate *lastWeek = [cal dateFromComponents:components];
    
    [components setDay:([components day] - ([components day] -1))];
    NSDate *thisMonth = [cal dateFromComponents:components];
    
    [components setMonth:([components month] - 1)];
    NSDate *lastMonth = [cal dateFromComponents:components];
    NSLog(@"today= %@",today);
    NSLog(@"yesterday= %@",yesterday);
    NSLog(@"thisWeek= %@",thisWeek);
    NSLog(@"lastWeek= %@",lastWeek);
    NSLog(@"thisMonth= %@",thisMonth);
    NSLog(@"lastMonth= %@",lastMonth);
    
    
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [cal dateFromComponents:components];
    NSDate *endDate = [cal dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

#pragma mark - 获取协处理器步数
- (void)getCMPStepCount:(void(^)(double stepCount, NSError *error))completion{
    if ([CMPedometer isStepCountingAvailable] && [CMPedometer isDistanceAvailable]) {
        if (!_pedometer) {
            _pedometer = [[CMPedometer alloc]init];
        }
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *now = [NSDate date];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
        // 开始时间
        NSDate *startDate = [calendar dateFromComponents:components];
        // 结束时间
        NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
        [_pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            if (error) {
                if(completion) completion(0 ,error);
                [self goAppRunSettingPage];
            } else {
                double stepCount = [pedometerData.numberOfSteps doubleValue];
                if(completion)
                    completion(stepCount ,error);
            }
            [self.pedometer stopPedometerUpdates];
        }];
    }
}

#pragma mark - 跳转App运动与健康设置页面
- (void)goAppRunSettingPage {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *msgStr = [NSString stringWithFormat:@"请在【设置->%@->%@】下允许访问权限",appName,@"运动与健身"];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"使用提示" message:msgStr preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            DLog(@"点击了取消");
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alert animated:YES completion:^{
            
        }];
    });
}

#pragma mark - getter
- (HKHealthStore *)healthStore {
    if (!_healthStore) {
        _healthStore = [[HKHealthStore alloc] init];
    }
    return _healthStore;
}

@end
