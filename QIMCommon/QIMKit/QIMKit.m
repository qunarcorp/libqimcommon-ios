//
//  QIMKit.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"
#import "QIMPrivateHeader.h"
#import "Message.pb.h"
#import "AvoidCrash.h"

@implementation QIMKit

static QIMKit *__global_QIMKit = nil;

+ (QIMKit *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_QIMKit = [[QIMKit alloc] init];
    });
    return __global_QIMKit;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initQIMKit];
    }
    return self;
}

- (void)initQIMKit {
    QIMInfoLog(@"QIMKit initialize");
    [QIMFilteredProtocol start];
    [QIMManager sharedInstance];
    [AvoidCrash makeAllEffective];
    NSArray *noneSelClassStrings = @[
                                     @"NSNull",
                                     @"NSNumber",
                                     @"NSString",
                                     @"NSMutableString",
                                     @"NSDictionary",
                                     @"NSMutableDictionary",
                                     @"NSArray",
                                     @"NSMutableArray"
                                     ];
    [AvoidCrash setupNoneSelClassStringsArr:noneSelClassStrings];
    [AvoidCrash avoidCrashExchangeMethodIfDealWithNoneSel:YES];
    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
}

- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    QIMErrorLog(@"QIMKit dealwithCrashMessage : %@",note.userInfo);
}

- (void)clearQIMManager {
    [[QIMManager sharedInstance] clearQIMManager];
}

- (NSMutableDictionary *)timeStempDic {
    return [[QIMManager sharedInstance] timeStempDic];
}

- (dispatch_queue_t)getLastQueue {
    return [[QIMManager sharedInstance] lastQueue];
}

- (NSString *)getImagerCache {
    return [[QIMManager sharedInstance] getImagerCache];
}

- (NSString *)updateRemoteLoginKey {
    return [[QIMManager sharedInstance] updateRemoteLoginKey];
}

@end

@implementation QIMKit (Common)

- (NSData *)updateOrganizationalStructure {
    return [[QIMManager sharedInstance] updateOrganizationalStructure];
}

- (NSData *)updateRosterList {
    return [[QIMManager sharedInstance] updateRosterList];
}

- (void)updateUserSuoXie {
    [[QIMManager sharedInstance] updateUserSuoXie];
}

- (void)synchServerTime {
    [[QIMManager sharedInstance] synchServerTime];
}

- (void)checkRosterListWithForceUpdate:(BOOL)forceUpdate {
    [[QIMManager sharedInstance] checkRosterListWithForceUpdate:forceUpdate];
}

@end

@implementation QIMKit (CommonConfig)

- (NSString *)remoteKey {
    return [[QIMManager sharedInstance] remoteKey];
}

- (NSString *)myRemotelogginKey {
    return [[QIMManager sharedInstance] myRemotelogginKey];
}

- (NSString *) thirdpartKeywithValue {
    return [[QIMManager sharedInstance] thirdpartKeywithValue];
}

- (void)setIsMerchant:(BOOL)isMerchant {
    [[QIMManager sharedInstance] setIsMerchant:isMerchant];
}

- (BOOL)isMerchant {
    return [[QIMManager sharedInstance] isMerchant];
}

+ (NSString *)getLastUserName {
    return [QIMManager getLastUserName];
}

- (NSString *)getLastPassword {
    return [[QIMManager sharedInstance] getLastPassword];
}

- (NSString *)getLastJid {
    return [[QIMManager sharedInstance] getLastJid];
}

- (NSString *)getMyNickName {
    return [[QIMManager sharedInstance] getMyNickName];
}

- (NSString *)getCompany {
    return [[QIMManager sharedInstance] getCompany];
}

- (NSString *)getDomain {
    return [[QIMManager sharedInstance] getDomain];
}

- (NSString *)getClientIp {
    return [[QIMManager sharedInstance] getClientIp];
}

- (long long)getCurrentServerTime {
    return [[QIMManager sharedInstance] getCurrentServerTime];
}

- (int)getServerTimeDiff {
    return [[QIMManager sharedInstance] getServerTimeDiff];
}

- (NSHTTPCookie *)cookie {
    return [[QIMManager sharedInstance] cookie];
}

// 更新导航配置
- (void)updateNavigationConfig {
    [[QIMManager sharedInstance] updateNavigationConfig];
}

- (void)checkClientConfig {
    [[QIMManager sharedInstance] checkClientConfig];
}

- (NSArray *)trdExtendInfo {
    return [[QIMManager sharedInstance] trdExtendInfo];
}

- (NSString *)aaCollectionUrlHost {
    return [[QIMManager sharedInstance] aaCollectionUrlHost];
}

- (NSString *)redPackageUrlHost {
    return [[QIMManager sharedInstance] redPackageUrlHost];
}

- (NSString *)redPackageBalanceUrl {
    return [[QIMManager sharedInstance] redPackageBalanceUrl];
}

- (NSString *)myRedpackageUrl {
    return [[QIMManager sharedInstance] myRedpackageUrl];
}

- (BOOL)isNewMsgNotify {
    return [[QIMManager sharedInstance] isNewMsgNotify];
}

- (void)setNewMsgNotify:(BOOL)flag {
    [[QIMManager sharedInstance] setNewMsgNotify:flag];
}

- (BOOL)pickerPixelOriginal {
    return [[QIMManager sharedInstance] pickerPixelOriginal];
}

- (void)setPickerPixelOriginal:(BOOL)flag {
    [[QIMManager sharedInstance] setPickerPixelOriginal:flag];
}

- (BOOL)moodshow {
    return [[QIMManager sharedInstance] moodshow];
}

- (void)setMoodshow:(BOOL)flag {
    [[QIMManager sharedInstance] setMoodshow:flag];
}

- (NSArray *)getHasAtMeByJid:(NSString *)jid  {
    return [[QIMManager sharedInstance] getHasAtMeByJid:jid];
}

- (void)addAtMeByJid:(NSString *)jid WithNickName:(NSString *)nickName {
    [[QIMManager sharedInstance] addAtMeByJid:jid WithNickName:nickName];
}

- (void)removeAtMeByJid:(NSString *)jid {
    [[QIMManager sharedInstance] removeAtMeByJid:jid];
}

- (void)addAtALLByJid:(NSString *)jid WithMsgId:(NSString *)msgId WihtMsg:(Message *)message WithNickName:(NSString *)nickName {
    [[QIMManager sharedInstance] addAtALLByJid:jid WithMsgId:msgId WihtMsg:message WithNickName:nickName];
}

- (void)removeAtAllByJid:(NSString *)jid {
    [[QIMManager sharedInstance] removeAtAllByJid:jid];
}

- (NSDictionary *)getAtAllInfoByJid:(NSString *)jid {
    return [[QIMManager sharedInstance] getAtAllInfoByJid:jid];
}

- (NSDictionary *)getNotSendTextByJid:(NSString *)jid {
    return [[QIMManager sharedInstance] getNotSendTextByJid:jid];
}

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid {
    [[QIMManager sharedInstance] setNotSendText:text inputItems:inputItems ForJid:jid];
}

- (NSDictionary *)getQChatToken {
    return [[QIMManager sharedInstance] getQChatToken];
}

- (NSDictionary *)getQVTForQChat {
    return [[QIMManager sharedInstance] getQVTForQChat];
}

- (void)removeQVTForQChat {
    [[QIMManager sharedInstance] removeQVTForQChat];
}

- (NSString *)getDownloadFilePath {
    return [[QIMManager sharedInstance] getDownloadFilePath];
}

- (void)clearcache {
    [[QIMManager sharedInstance] clearcache];
}

- (BOOL)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType {
    return [[QIMManager sharedInstance] setStickWithCombineJid:combineJid WithChatType:chatType];
}

- (BOOL)removeStickWithCombineJid:(NSString *)jid WithChatType:(ChatType)chatType {
    return [[QIMManager sharedInstance] removeStickWithCombineJid:jid WithChatType:chatType];
}

- (BOOL)isStickWithCombineJid:(NSString *)jid {
    return [[QIMManager sharedInstance] isStickWithCombineJid:jid];
}

- (NSDictionary *)stickList {
    return [[QIMManager sharedInstance] stickList];
}

- (BOOL)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn {
    return [[QIMManager sharedInstance] setMsgNotifySettingWithIndex:setting WithSwitchOn:switchOn];
}

- (BOOL)getLocalMsgNotifySettingWithIndex:(QIMMSGSETTING)setting {
    return [[QIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:setting];
}

- (void)getMsgNotifyRemoteSettings {
    [[QIMManager sharedInstance] getMsgNotifyRemoteSettings];
}

#pragma mark - kNotificationSetting

- (void)sendNoPush {
    [[QIMManager sharedInstance] sendNoPush];
}

- (BOOL)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag {
    return [[QIMManager sharedInstance] sendServer:notificationToken withUsername:username withParamU:paramU withParamK:paramK WithDelete:deleteFlag];
}

- (BOOL)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag {
    return [[QIMManager sharedInstance] sendPushTokenWithMyToken:myToken WithDeleteFlag:deleteFlag];
}

- (void)checkClearCache {
    [[QIMManager sharedInstance] checkClearCache];
}

- (NSString *)userOnlineStatus:(NSString *)sid {
    return [[QIMManager sharedInstance] userOnlineStatus:sid];
}

- (BOOL)isUserOnline:(NSString *)userId {
    return [[QIMManager sharedInstance] isUserOnline:userId];
}

- (UserPrecenseStatus)getUserPrecenseStatus:(NSString *)jid {
    return [[QIMManager sharedInstance] getUserPrecenseStatus:jid];
}

- (UserPrecenseStatus)getUserPrecenseStatus:(NSString *)jid status:(NSString **)status {
    return [[QIMManager sharedInstance] getUserPrecenseStatus:jid status:status];
}

@end
