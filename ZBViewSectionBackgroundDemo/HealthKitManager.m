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
        NSLog(@"设备不支持healthKit");
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
//    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *endDate = [NSDate date];//[calendar startOfDayForDate:[NSDate date]];
    NSDate *startDate = [self getDayDateWithSpace:-day.integerValue byCurrentDate:endDate];
    return [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
}

/// 根据cDate 返回差N天的date，
/// @param daySpace 天差值：-以前，+未来
/// @param cDate cDate description
- (NSDate *)getDayDateWithSpace:(NSInteger)daySpace byCurrentDate:(NSDate *)cDate{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    comps.day = daySpace;
    return [greCalendar dateByAddingComponents:comps toDate:cDate options:0];
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
