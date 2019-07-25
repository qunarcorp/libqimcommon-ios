//
//  QIMKit+QIMAppSetting.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMAppSetting.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMAppSetting)

- (BOOL)isFirstLauched {
    return [[QIMAppSetting sharedInstance] isFirstLauched];
}

+ (void)setAppConfigurationMode:(QIMAppConfigurationMode)mode {
    [[QIMAppSetting sharedInstance] setAppConfigurationMode:mode];
}

+ (QIMAppConfigurationMode)getCurrentAppConfigurationMode {
    return [[QIMAppSetting sharedInstance] getCurrentAppConfigurationMode];
}

- (BOOL)debugMode {
    return [[QIMAppSetting sharedInstance] debugMode];
}

- (NSString *)currentLanguage {
    return [[QIMAppSetting sharedInstance] currentLanguage];
}

/**
 设置高德地图的Key
 */
- (void)setGAODE_APIKEY:(NSString *)key {
    [[QIMAppSetting sharedInstance] setGAODE_APIKEY:key];
}

/**
 获取高德地图的Key
 */
- (NSString *)getGAODE_APIKEY {
    return [[QIMAppSetting sharedInstance] GAODE_APIKEY];
}

@end
