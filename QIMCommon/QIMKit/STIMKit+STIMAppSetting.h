//
//  STIMKit+STIMAppSetting.h
//  STIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMAppSetting)

/**
 判断是否为第一次安装
 */
- (BOOL)isFirstLauched;

/**
 设置当前App环境配置
 */
+ (void)setAppConfigurationMode:(STIMAppConfigurationMode)mode;


/**
 获取当前App环境配置
 */
+ (STIMAppConfigurationMode)getCurrentAppConfigurationMode;

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
- (NSString *)getGAODE_APIKEY;

@end
