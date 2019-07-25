//
//  QIMKit+AppInfo.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMAppInfo.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMAppInfo)

+ (void)setQIMProjectType:(QIMProjectType)appType {
    [[QIMAppInfo sharedInstance] setAppType:appType];
}

+ (QIMProjectType)getQIMProjectType {
    return [[QIMAppInfo sharedInstance] appType];
}

+ (void)setQIMApplicationState:(QIMApplicationState)appState {
    [[QIMAppInfo sharedInstance] setApplicationState:appState];
}

+ (QIMApplicationState)getQIMApplicationState {
    return [[QIMAppInfo sharedInstance] applicationState];
}

+ (void)setQIMProjectTitleName:(NSString *)appName {
    [[QIMAppInfo sharedInstance] setAppName:appName];
}

+ (NSString *)getQIMProjectTitleName {
    return [[QIMAppInfo sharedInstance] appName];
}

- (NSString *)getPushToken {
    return [[QIMAppInfo sharedInstance] pushToken];
}

- (void)setPushToken:(NSString *)pushToken {
    [[QIMAppInfo sharedInstance] setPushToken:pushToken];
}

// 机器的唯一标识
- (NSString *)appAID {
    return [[QIMAppInfo sharedInstance] appAID];
}

- (NSString *)macAddress {
    return [[QIMAppInfo sharedInstance] macAddress];
}

- (NSString *)Platform {
    return [[QIMAppInfo sharedInstance] Platform];
}

- (NSString *)deviceName {
    return [[QIMAppInfo sharedInstance] deviceName];
}

- (void)setCustomDeviceModel:(NSString *)customDeviceModel {
    [[QIMAppInfo sharedInstance] setCustomDeviceModel:customDeviceModel];
}

- (BOOL)getIsIpad {
    return [[QIMAppInfo sharedInstance] getIsIpad];
}

- (NSString *)SystemVersion {
    return [[QIMAppInfo sharedInstance] SystemVersion];
}

- (NSString *)carrierName {
    return [[QIMAppInfo sharedInstance] carrierName];
}

- (NSString *)AppVersion {
    return [[QIMAppInfo sharedInstance] AppVersion];
}

- (NSString *)AppBuildVersion {
    return [[QIMAppInfo sharedInstance] AppBuildVersion];
}

@end
