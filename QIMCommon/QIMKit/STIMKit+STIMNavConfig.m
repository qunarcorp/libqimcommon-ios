//
//  STIMKit+STIMNavConfig.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMNavConfig.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMNavConfig)

- (NSString *)qimNav_HttpHost {
    return [[STIMNavConfigManager sharedInstance] httpHost];
}

- (NSString *)qimNav_TakeSmsUrl {
    return [[STIMNavConfigManager sharedInstance] takeSmsUrl];
}

- (NSString *)qimNav_CheckSmsUrl {
    return [[STIMNavConfigManager sharedInstance] checkSmsUrl];
}

- (NSString *)qimNav_NewHttpUrl {
    return [[STIMNavConfigManager sharedInstance] newerHttpUrl];
}

- (NSString *)qimNav_WikiUrl {
    return [[STIMNavConfigManager sharedInstance] wikiUrl];
}

- (NSString *)qimNav_TokenSmsUrl {
    return [[STIMNavConfigManager sharedInstance] tokenSmsUrl];
}

- (NSString *)qimNav_Javaurl {
    return [[STIMNavConfigManager sharedInstance] javaurl];
}

- (NSString *)qimNav_Pubkey {
    return [[STIMNavConfigManager sharedInstance] pubkey];
}

- (NSString *)qimNav_Domain {
    return [[STIMNavConfigManager sharedInstance] domain];
}

- (QTLoginType)qimNav_LoginType {
    return [[STIMNavConfigManager sharedInstance] loginType];
}

- (NSString *)qimNav_XmppHost {
    return [[STIMNavConfigManager sharedInstance] xmppHost];
}

- (NSString *)qimNav_InnerFileHttpHost {
    return [[STIMNavConfigManager sharedInstance] innerFileHttpHost];
}

- (NSString *)qimNav_Port {
    return [[STIMNavConfigManager sharedInstance] port];
}

- (NSString *)qimNav_ProtobufPort {
    return [[STIMNavConfigManager sharedInstance] protobufPort];
}

- (NSString *)qimNav_ShareUrl {
    return [[STIMNavConfigManager sharedInstance] shareUrl];
}

- (NSString *)qimNav_DomainHost {
    return [[STIMNavConfigManager sharedInstance] domainHost];
}

- (NSString *)qimNav_LeaderUrl {
    return [[STIMNavConfigManager sharedInstance] leaderurl];
}

- (NSString *)qimNav_Mobileurl {
    return [[STIMNavConfigManager sharedInstance] mobileurl];
}

- (NSString *)qimNav_resetPwdUrl{
    return [[STIMNavConfigManager sharedInstance] getNewResetPwdUrl];
}

//hosts
- (NSString *)qimNav_HashHosts {
    return [[STIMNavConfigManager sharedInstance] hashHosts];
}

- (NSString *)qimNav_QCHost {
    return [[STIMNavConfigManager sharedInstance] qcHost];
}

- (NSArray *)qimNav_AdItems {
    return [[STIMNavConfigManager sharedInstance] adItems];
}

- (int)qimNav_AdSec {
    return [[STIMNavConfigManager sharedInstance] adSec];
}

- (BOOL)qimNav_AdShown {
    return [[STIMNavConfigManager sharedInstance] adShown];
}

- (BOOL)qimNav_AdCarousel {
    return [[STIMNavConfigManager sharedInstance] adCarousel];
}

- (int)qimNav_AdCarouselDelay {
    return [[STIMNavConfigManager sharedInstance] adCarouselDelay];
}

- (BOOL)qimNav_AdAllowSkip {
    return [[STIMNavConfigManager sharedInstance] adAllowSkip];
}

- (long long)qimNav_AdInterval {
    return [[STIMNavConfigManager sharedInstance] adInterval];
}

- (NSArray *)qimNav_getLocalNavServerConfigs {
    return [[STIMNavConfigManager sharedInstance] qimNav_getLocalNavServerConfigs];
}

- (NSString *)qimNav_AdSkipTips {
    return [[STIMNavConfigManager sharedInstance] adSkipTips];
}

//imConfig
- (BOOL)qimNav_ShowOA {
    return [[STIMNavConfigManager sharedInstance] showOA];
}

- (BOOL)qimNav_ShowOrganizational {
    return [[STIMNavConfigManager sharedInstance] showOrganizational];
}

- (NSString *)qimNav_Email {
    return [[STIMNavConfigManager sharedInstance] email];
}

- (NSString *)qimNav_UploadLog {
    return [[STIMNavConfigManager sharedInstance] uploadLog];
}

//ability
- (NSString *)qimNav_GetPushState {
    return [[STIMNavConfigManager sharedInstance] getPushState];
}

- (NSString *)qimNav_SetPushState {
    return [[STIMNavConfigManager sharedInstance] setPushState];
}

- (NSString *)qimNav_QCloudHost {
    return [[STIMNavConfigManager sharedInstance] qCloudHost];
}

- (NSString *)qimNav_Resetpwd {
    return [[STIMNavConfigManager sharedInstance] resetpwd];
}

- (NSString *)qimNav_Mconfig {
    return [[STIMNavConfigManager sharedInstance] mconfig];
}

- (NSString *)qimNav_SearchUrl {
    return [[STIMNavConfigManager sharedInstance] searchUrl];
}

- (NSString *)qimNav_New_SearchUrl {
    return [[STIMNavConfigManager sharedInstance] qSearchUrl];
}

- (NSString *)qimNav_QcGrabOrder {
    return [[STIMNavConfigManager sharedInstance] qcGrabOrder];
}

- (NSString *)qimNav_QcOrderManager {
    return [[STIMNavConfigManager sharedInstance] qcOrderManager];
}

- (BOOL)qimNav_NewPush {
    return [[STIMNavConfigManager sharedInstance] newPush];
}

- (BOOL)qimNav_Showmsgstat {
    return [[STIMNavConfigManager sharedInstance] showmsgstat];
}

//RN Ability
- (BOOL)qimNav_RNMineView {
    return [[STIMNavConfigManager sharedInstance] RNMineView];
}

- (BOOL)qimNav_RNAboutView {
    return [[STIMNavConfigManager sharedInstance] RNAboutView];
}

- (BOOL)qimNav_RNGroupCardView {
    return [[STIMNavConfigManager sharedInstance] RNGroupCardView];
}

- (BOOL)qimNav_RNContactView {
    return [[STIMNavConfigManager sharedInstance] RNContactView];
}

- (BOOL)qimNav_RNSettingView {
    return [[STIMNavConfigManager sharedInstance] RNSettingView];
}

- (BOOL)qimNav_RNUserCardView {
    return [[STIMNavConfigManager sharedInstance] RNUserCardView];
}

- (BOOL)qimNav_RNGroupListView {
    return [[STIMNavConfigManager sharedInstance] RNGroupListView];
}

- (BOOL)qimNav_RNPublicNumberListView {
    return [[STIMNavConfigManager sharedInstance] RNPublicNumberListView];
}

- (void)qimNav_setRNMineView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNMineView:showFlag];
}

- (void)qimNav_setRNAboutView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNAboutView:showFlag];
}

- (void)qimNav_setRNGroupCardView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNGroupCardView:showFlag];
}

- (void)qimNav_setRNContactView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNContactView:showFlag];
}

- (void)qimNav_setRNSettingView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNSettingView:showFlag];
}

- (void)qimNav_setRNUserCardView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNUserCardView:showFlag];
}

- (void)qimNav_setRNGroupListView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNGroupListView:showFlag];
}

- (void)qimNav_setRNPublicNumberListView:(BOOL)showFlag {
    [[STIMNavConfigManager sharedInstance] setRNPublicNumberListView:showFlag];
}

//OPS
- (NSString *)qimNav_OpsHost {
    return [[STIMNavConfigManager sharedInstance] opsHost];
}

//Video
- (NSString *)qimNav_Group_room_host {
    return [[STIMNavConfigManager sharedInstance] group_room_host];
}

- (NSString *)qimNav_Signal_host {
    return [[STIMNavConfigManager sharedInstance] signal_host];
}

- (NSString *)qimNav_WssHost {
    return [[STIMNavConfigManager sharedInstance] wssHost];
}

- (NSString *)qimNav_VideoApiHost {
    return [[STIMNavConfigManager sharedInstance] videoApiHost];
}

-(NSString *)qimNav_VideoUrl{
    return [[STIMNavConfigManager sharedInstance] videourl];
}

//Versions
- (long long)qimNav_NavVersion {
    return [[STIMNavConfigManager sharedInstance] navVersion];
}

- (long long)qimNav_CheckConfigVersion {
    return [[STIMNavConfigManager sharedInstance] checkConfigVersion];
}

- (NSString *)qimNav_NavUrl {
    return [[STIMNavConfigManager sharedInstance] navUrl];
}

- (NSString *)qimNav_NavTitle {
    return [[STIMNavConfigManager sharedInstance] navTitle];
}

- (BOOL)qimNav_Debug {
    return [[STIMNavConfigManager sharedInstance] debug];
}

- (NSArray *)qimNav_getDebugers {
    return [[STIMNavConfigManager sharedInstance] qimNav_getDebugers];
}

- (NSString *)qimNav_HealthcheckUrl {
    return [[STIMNavConfigManager sharedInstance] healthcheckUrl];
}

- (NSMutableArray *)qimNav_localNavConfigs {
    return [[STIMNavConfigManager sharedInstance] localNavConfigs];
}

- (BOOL)qimNav_updateNavigationConfigWithCheck:(BOOL)check {
    return [[STIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithCheck:check];
}

- (void)qimNav_clearAdvertSource {
    [[STIMNavConfigManager sharedInstance] qimNav_clearAdvertSource];
}

- (void)qimNav_swicthLocalNavConfigWithNavDict:(NSDictionary *)navDict {
    [[STIMNavConfigManager sharedInstance] qimNav_swicthLocalNavConfigWithNavDict:navDict];
}

- (NSString *)qimNav_getAdvertImageFilePath {
    return [[STIMNavConfigManager sharedInstance] qimNav_getAdvertImageFilePath];
}

- (void)qimNav_updateAdvertConfigWithCheck:(BOOL)check {
    [[STIMNavConfigManager sharedInstance] qimNav_updateAdvertConfigWithCheck:check];
}

- (BOOL)qimNav_updateNavigationConfigWithDomain:(NSString *)domain WithUserName:(NSString *)userName {
    return [[STIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithDomain:domain WithUserName:userName];
}

- (BOOL)qimNav_updateNavigationConfigWithNavUrl:(NSString *)navUrl WithUserName:(NSString *)userName {
    return [[STIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithNavUrl:navUrl WithUserName:userName];
}

- (BOOL)qimNav_updateNavigationConfigWithNavDict:(NSDictionary *)navDict WithUserName:(NSString *)userName Check:(BOOL)check WithForcedUpdate:(BOOL)forcedUpdate {
    return [[STIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithNavDict:navDict WithUserName:userName Check:check WithForcedUpdate:forcedUpdate];
}

-(NSString *)qimNav_webAppUrl{
    return [[STIMNavConfigManager sharedInstance] getWebAppUrl];
}

- (NSString *)qimNav_getManagerAppUrl{
    return [[STIMNavConfigManager sharedInstance] getManagerAppUrl];
}

- (NSString *)qimNav_AppWebHostUrl{
  //web页host地址
    return [[STIMNavConfigManager sharedInstance] appWeb];
}

-(BOOL)qimNav_isToC{
    return [[STIMNavConfigManager sharedInstance] isToC];
}

@end
