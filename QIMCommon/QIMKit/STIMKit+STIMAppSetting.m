//
//  STIMKit+STIMAppSetting.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMAppSetting.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMAppSetting)

- (BOOL)isFirstLauched {
    return [[STIMAppSetting sharedInstance] isFirstLauched];
}

+ (void)setAppConfigurationMode:(STIMAppConfigurationMode)mode {
    [[STIMAppSetting sharedInstance] setAppConfigurationMode:mode];
}

+ (STIMAppConfigurationMode)getCurrentAppConfigurationMode {
    return [[STIMAppSetting sharedInstance] getCurrentAppConfigurationMode];
}

- (BOOL)debugMode {
    return [[STIMAppSetting sharedInstance] debugMode];
}

- (NSString *)currentLanguage {
    return [[STIMAppSetting sharedInstance] currentLanguage];
}

/**
 设置高德地图的Key
 */
- (void)setGAODE_APIKEY:(NSString *)key {
    [[STIMAppSetting sharedInstance] setGAODE_APIKEY:key];
}

/**
 获取高德地图的Key
 */
- (NSString *)getGAODE_APIKEY {
    return [[STIMAppSetting sharedInstance] GAODE_APIKEY];
}

@end
