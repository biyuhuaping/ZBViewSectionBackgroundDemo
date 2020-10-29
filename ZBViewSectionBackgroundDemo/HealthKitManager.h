//
//  HealthKitManager.h
//  ZBViewSectionBackgroundDemo
//
//  Created by ZB on 2020/10/27.
//  Copyright © 2020 ZB. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HealthKitManager : NSObject

+ (instancetype)shareInstance;

///应用授权检查
- (void)authorizateHealthKit:(void (^)(BOOL success, NSError *error))resultBlock;

///获取健康数据(步数)
- (void)getStepCountWith:(NSString *)day block:(void (^)(double stepCount, NSError *error))queryResultBlock;

///获取协处理器步数
- (void)getCMPStepCount:(void(^)(double stepCount, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
