//
//  QIMKit+QIMNavConfig.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMNavConfig.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMNavConfig)

- (NSString *)qimNav_HttpHost {
    return [[QIMNavConfigManager sharedInstance] httpHost];
}

- (NSString *)qimNav_TakeSmsUrl {
    return [[QIMNavConfigManager sharedInstance] takeSmsUrl];
}

- (NSString *)qimNav_CheckSmsUrl {
    return [[QIMNavConfigManager sharedInstance] checkSmsUrl];
}

- (NSString *)qimNav_NewHttpUrl {
    return [[QIMNavConfigManager sharedInstance] newerHttpUrl];
}

- (NSString *)qimNav_WikiUrl {
    return [[QIMNavConfigManager sharedInstance] wikiUrl];
}

- (NSString *)qimNav_TokenSmsUrl {
    return [[QIMNavConfigManager sharedInstance] tokenSmsUrl];
}

- (NSString *)qimNav_Javaurl {
    return [[QIMNavConfigManager sharedInstance] javaurl];
}

- (NSString *)qimNav_Pubkey {
    return [[QIMNavConfigManager sharedInstance] pubkey];
}

- (NSString *)qimNav_Domain {
    return [[QIMNavConfigManager sharedInstance] domain];
}

- (QTLoginType)qimNav_LoginType {
    return [[QIMNavConfigManager sharedInstance] loginType];
}

- (NSString *)qimNav_XmppHost {
    return [[QIMNavConfigManager sharedInstance] xmppHost];
}

- (NSString *)qimNav_InnerFileHttpHost {
    return [[QIMNavConfigManager sharedInstance] innerFileHttpHost];
}

- (NSString *)qimNav_Port {
    return [[QIMNavConfigManager sharedInstance] port];
}

- (NSString *)qimNav_ProtobufPort {
    return [[QIMNavConfigManager sharedInstance] protobufPort];
}

//hosts
- (NSString *)qimNav_HashHosts {
    return [[QIMNavConfigManager sharedInstance] hashHosts];
}

- (NSString *)qimNav_QCHost {
    return [[QIMNavConfigManager sharedInstance] qcHost];
}

- (NSArray *)qimNav_AdItems {
    return [[QIMNavConfigManager sharedInstance] adItems];
}

- (int)qimNav_AdSec {
    return [[QIMNavConfigManager sharedInstance] adSec];
}

- (BOOL)qimNav_AdShown {
    return [[QIMNavConfigManager sharedInstance] adShown];
}

- (BOOL)qimNav_AdCarousel {
    return [[QIMNavConfigManager sharedInstance] adCarousel];
}

- (int)qimNav_AdCarouselDelay {
    return [[QIMNavConfigManager sharedInstance] adCarouselDelay];
}

- (BOOL)qimNav_AdAllowSkip {
    return [[QIMNavConfigManager sharedInstance] adAllowSkip];
}

- (long long)qimNav_AdInterval {
    return [[QIMNavConfigManager sharedInstance] adInterval];
}

- (NSArray *)qimNav_getLocalNavServerConfigs {
    return [[QIMNavConfigManager sharedInstance] qimNav_getLocalNavServerConfigs];
}

- (NSString *)qimNav_AdSkipTips {
    return [[QIMNavConfigManager sharedInstance] adSkipTips];
}

//imConfig
- (BOOL)qimNav_ShowOA {
    return [[QIMNavConfigManager sharedInstance] showOA];
}

- (BOOL)qimNav_ShowOrganizational {
    return [[QIMNavConfigManager sharedInstance] showOrganizational];
}

//ability
- (NSString *)qimNav_GetPushState {
    return [[QIMNavConfigManager sharedInstance] getPushState];
}

- (NSString *)qimNav_SetPushState {
    return [[QIMNavConfigManager sharedInstance] setPushState];
}

- (NSString *)qimNav_QCloudHost {
    return [[QIMNavConfigManager sharedInstance] qCloudHost];
}

- (NSString *)qimNav_Resetpwd {
    return [[QIMNavConfigManager sharedInstance] resetpwd];
}

- (NSString *)qimNav_Mconfig {
    return [[QIMNavConfigManager sharedInstance] mconfig];
}

- (NSString *)qimNav_SearchUrl {
    return [[QIMNavConfigManager sharedInstance] searchUrl];
}

- (NSString *)qimNav_QcGrabOrder {
    return [[QIMNavConfigManager sharedInstance] qcGrabOrder];
}

- (NSString *)qimNav_QcOrderManager {
    return [[QIMNavConfigManager sharedInstance] qcOrderManager];
}

- (BOOL)qimNav_NewPush {
    return [[QIMNavConfigManager sharedInstance] newPush];
}

- (BOOL)qimNav_Showmsgstat {
    return [[QIMNavConfigManager sharedInstance] showmsgstat];
}

//RN Ability
- (BOOL)qimNav_RNMineView {
    return [[QIMNavConfigManager sharedInstance] RNMineView];
}

- (BOOL)qimNav_RNAboutView {
    return [[QIMNavConfigManager sharedInstance] RNAboutView];
}

- (BOOL)qimNav_RNGroupCardView {
    return [[QIMNavConfigManager sharedInstance] RNGroupCardView];
}

- (BOOL)qimNav_RNContactView {
    return [[QIMNavConfigManager sharedInstance] RNContactView];
}

- (BOOL)qimNav_RNSettingView {
    return [[QIMNavConfigManager sharedInstance] RNSettingView];
}

- (BOOL)qimNav_RNUserCardView {
    return [[QIMNavConfigManager sharedInstance] RNUserCardView];
}

- (BOOL)qimNav_RNGroupListView {
    return [[QIMNavConfigManager sharedInstance] RNGroupListView];
}

- (BOOL)qimNav_RNPublicNumberListView {
    return [[QIMNavConfigManager sharedInstance] RNPublicNumberListView];
}

- (void)qimNav_setRNMineView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNMineView:showFlag];
}

- (void)qimNav_setRNAboutView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNAboutView:showFlag];
}

- (void)qimNav_setRNGroupCardView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNGroupCardView:showFlag];
}

- (void)qimNav_setRNContactView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNContactView:showFlag];
}

- (void)qimNav_setRNSettingView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNSettingView:showFlag];
}

- (void)qimNav_setRNUserCardView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNUserCardView:showFlag];
}

- (void)qimNav_setRNGroupListView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNGroupListView:showFlag];
}

- (void)qimNav_setRNPublicNumberListView:(BOOL)showFlag {
    [[QIMNavConfigManager sharedInstance] setRNPublicNumberListView:showFlag];
}

//OPS
- (NSString *)qimNav_OpsHost {
    return [[QIMNavConfigManager sharedInstance] opsHost];
}

//Video
- (NSString *)qimNav_Group_room_host {
    return [[QIMNavConfigManager sharedInstance] group_room_host];
}

- (NSString *)qimNav_Signal_host {
    return [[QIMNavConfigManager sharedInstance] signal_host];
}

- (NSString *)qimNav_WssHost {
    return [[QIMNavConfigManager sharedInstance] wssHost];
}

- (NSString *)qimNav_VideoApiHost {
    return [[QIMNavConfigManager sharedInstance] videoApiHost];
}

//Versions
- (long long)qimNav_NavVersion {
    return [[QIMNavConfigManager sharedInstance] navVersion];
}

- (long long)qimNav_CheckConfigVersion {
    return [[QIMNavConfigManager sharedInstance] checkConfigVersion];
}

- (NSString *)qimNav_NavUrl {
    return [[QIMNavConfigManager sharedInstance] navUrl];
}

- (NSString *)qimNav_NavTitle {
    return [[QIMNavConfigManager sharedInstance] navTitle];
}

- (BOOL)qimNav_Debug {
    return [[QIMNavConfigManager sharedInstance] debug];
}

- (NSArray *)qimNav_getDebugers {
    return [[QIMNavConfigManager sharedInstance] qimNav_getDebugers];
}

- (NSString *)qimNav_HealthcheckUrl {
    return [[QIMNavConfigManager sharedInstance] healthcheckUrl];
}

- (BOOL)qimNav_updateNavigationConfigWithCheck:(BOOL)check {
    return [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithCheck:check];
}

- (void)qimNav_clearAdvertSource {
    [[QIMNavConfigManager sharedInstance] qimNav_clearAdvertSource];
}

- (void)qimNav_swicthLocalNavConfigWithNavDict:(NSDictionary *)navDict {
    [[QIMNavConfigManager sharedInstance] qimNav_swicthLocalNavConfigWithNavDict:navDict];
}

- (NSString *)qimNav_getAdvertImageFilePath {
    return [[QIMNavConfigManager sharedInstance] qimNav_getAdvertImageFilePath];
}

- (void)qimNav_updateAdvertConfigWithCheck:(BOOL)check {
    [[QIMNavConfigManager sharedInstance] qimNav_updateAdvertConfigWithCheck:check];
}

- (BOOL)qimNav_updateNavigationConfigWithDomain:(NSString *)domain WithUserName:(NSString *)userName {
    return [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithDomain:domain WithUserName:userName];
}

- (BOOL)qimNav_updateNavigationConfigWithNavDict:(NSDictionary *)navDict WithUserName:(NSString *)userName Check:(BOOL)check WithForcedUpdate:(BOOL)forcedUpdate {
    return [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithNavDict:navDict WithUserName:userName Check:check WithForcedUpdate:forcedUpdate];
}

@end
