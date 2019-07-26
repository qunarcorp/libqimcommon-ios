//
//  QIMAppSetting.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"

@interface QIMAppSetting : NSObject

+ (instancetype)sharedInstance;

/**
 判断是否为第一次安装
 */
- (BOOL)isFirstLauched;

- (void)setAppConfigurationMode:(QIMAppConfigurationMode)mode;

- (QIMAppConfigurationMode)getCurrentAppConfigurationMode;

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
