//
//  STIMAppSetting.h
//  STIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIMCommonEnum.h"

@interface STIMAppSetting : NSObject

+ (instancetype)sharedInstance;

/**
 判断是否为第一次安装
 */
- (BOOL)isFirstLauched;

- (void)setAppConfigurationMode:(STIMAppConfigurationMode)mode;

- (STIMAppConfigurationMode)getCurrentAppConfigurationMode;

/**
 判断是否为Debug模式
 */
- (BOOL)debugMode;

/**
 获取当前系统语言
 */
- (NSString *)currentLanguage;

/**
 设置高德地图的Key
 */
- (void)setGAODE_APIKEY:(NSString *)key;

/**
 获取高德地图的Key
 */
- (NSString *)GAODE_APIKEY;

@end
