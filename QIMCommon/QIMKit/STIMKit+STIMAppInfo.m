//
//  STIMKit+AppInfo.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMAppInfo.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMAppInfo)

+ (void)setSTIMProjectType:(STIMProjectType)appType {
    [[STIMAppInfo sharedInstance] setAppType:appType];
}

+ (STIMProjectType)getSTIMProjectType {
    return [[STIMAppInfo sharedInstance] appType];
}

+ (void)setSTIMApplicationState:(STIMApplicationState)appState {
    [[STIMAppInfo sharedInstance] setApplicationState:appState];
}

+ (STIMApplicationState)getSTIMApplicationState {
    return [[STIMAppInfo sharedInstance] applicationState];
}

+ (void)setSTIMProjectTitleName:(NSString *)appName {
    [[STIMAppInfo sharedInstance] setAppName:appName];
}

+ (NSString *)getSTIMProjectTitleName {
    return [[STIMAppInfo sharedInstance] appName];
}

- (NSString *)getPushToken {
    return [[STIMAppInfo sharedInstance] pushToken];
}

- (void)setPushToken:(NSString *)pushToken {
    [[STIMAppInfo sharedInstance] setPushToken:pushToken];
}

// 机器的唯一标识
- (NSString *)appAID {
    return [[STIMAppInfo sharedInstance] appAID];
}

- (NSString *)macAddress {
    return [[STIMAppInfo sharedInstance] macAddress];
}

- (NSString *)Platform {
    return [[STIMAppInfo sharedInstance] Platform];
}

- (NSString *)deviceName {
    return [[STIMAppInfo sharedInstance] deviceName];
}

- (void)setCustomDeviceModel:(NSString *)customDeviceModel {
    [[STIMAppInfo sharedInstance] setCustomDeviceModel:customDeviceModel];
}

- (BOOL)getIsIpad {
    return [[STIMAppInfo sharedInstance] getIsIpad];
}

- (NSString *)SystemVersion {
    return [[STIMAppInfo sharedInstance] SystemVersion];
}

- (NSString *)carrierName {
    return [[STIMAppInfo sharedInstance] carrierName];
}

- (NSString *)AppVersion {
    return [[STIMAppInfo sharedInstance] AppVersion];
}

- (NSString *)AppBuildVersion {
    return [[STIMAppInfo sharedInstance] AppBuildVersion];
}

@end
