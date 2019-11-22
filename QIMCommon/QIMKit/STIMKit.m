//
//  STIMKit.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"
#import "STIMPrivateHeader.h"
#import "Message.pb.h"
#import "AvoidCrash.h"

@implementation STIMKit

static STIMKit *__global_STIMKit = nil;

+ (STIMKit *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_STIMKit = [[STIMKit alloc] init];
    });
    return __global_STIMKit;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSTIMKit];
    }
    return self;
}

- (void)initSTIMKit {
    STIMInfoLog(@"STIMKit initialize");
    [STIMFilteredProtocol start];
    [STIMManager sharedInstance];
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
//    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
}

- (void)dealwithCrashMessage:(NSNotification *)note {
    //注意:所有的信息都在userInfo中
    STIMErrorLog(@"STIMKit dealwithCrashMessage : %@",note.userInfo);
}

- (void)clearSTIMManager {
    [[STIMManager sharedInstance] clearSTIMManager];
}

- (NSMutableDictionary *)timeStempDic {
    return [[STIMManager sharedInstance] timeStempDic];
}

- (dispatch_queue_t)getLastQueue {
    return [[STIMManager sharedInstance] lastQueue];
}

- (dispatch_queue_t)getLoadSessionNameQueue {
    return [[[STIMManager sharedInstance] load_session_name] queue];
}

- (dispatch_queue_t)getLoadHeaderImageQueue {
    return [[[STIMManager sharedInstance] load_user_header] queue];
}

- (dispatch_queue_t)getLoadSessionContentQueue {
    return [[[STIMManager sharedInstance] load_session_content] queue];
}

- (dispatch_queue_t)getLoadSessionUnReadCountQueue {
    return [[[STIMManager sharedInstance] load_session_unreadcount] queue];
}

- (dispatch_queue_t)getLoadGroupCardFromDBQueue {
    return [[[STIMManager sharedInstance] load_groupDB_VCard] queue];
}

- (dispatch_queue_t)getLoadMsgNickNameQueue {
    return [[[STIMManager sharedInstance] load_msgNickName] queue];
}

- (dispatch_queue_t)getLoadMsgMedalListQueue {
    return [[[STIMManager sharedInstance] load_msgMedalList] queue];
}

- (dispatch_queue_t)getLoad_msgHeaderImageQueue {
    return [[[STIMManager sharedInstance] load_msgHeaderImage] queue];
}

- (NSString *)getOpsFoundRNDebugUrl {
    return [[STIMManager sharedInstance] opsFoundRNDebugUrl];
}

- (void)setOpsFoundRNDebugUrl:(NSString *)opsFoundRNDebugUrl {
    [[STIMManager sharedInstance] setOpsFoundRNDebugUrl:opsFoundRNDebugUrl];
}

- (NSString *)qtalkFoundRNDebugUrl {
    return [[STIMManager sharedInstance] qtalkFoundRNDebugUrl];
}

- (void)setQtalkFoundRNDebugUrl:(NSString *)qtalkFoundRNDebugUrl {
    [[STIMManager sharedInstance] setQtalkFoundRNDebugUrl:qtalkFoundRNDebugUrl];
}

- (NSString *)qtalkSearchRNDebugUrl {
    return [[STIMManager sharedInstance] qtalkSearchRNDebugUrl];
}

- (void)setQtalkSearchRNDebugUrl:(NSString *)qtalkSearchRNDebugUrl {
    [[STIMManager sharedInstance] setQtalkSearchRNDebugUrl:qtalkSearchRNDebugUrl];
}

- (NSString *)getImagerCache {
    return [[STIMManager sharedInstance] getImagerCache];
}

- (NSString *)updateRemoteLoginKey {
    return [[STIMManager sharedInstance] updateRemoteLoginKey];
}

@end

@implementation STIMKit (Common)

- (NSData *)updateOrganizationalStructure {
    return [[STIMManager sharedInstance] updateOrganizationalStructure];
}

@end

@implementation STIMKit (CommonConfig)

- (NSString *)remoteKey {
    return [[STIMManager sharedInstance] remoteKey];
}

- (NSString *)myRemotelogginKey {
    return [[STIMManager sharedInstance] myRemotelogginKey];
}

- (NSString *) thirdpartKeywithValue {
    return [[STIMManager sharedInstance] thirdpartKeywithValue];
}

- (void)setIsMerchant:(BOOL)isMerchant {
    [[STIMManager sharedInstance] setIsMerchant:isMerchant];
}

- (BOOL)isMerchant {
    return [[STIMManager sharedInstance] isMerchant];
}

+ (NSString *)getLastUserName {
    return [STIMManager getLastUserName];
}

/**
 更新最后一个登录用户的临时Token
 
 @param token 用户token
 */
- (void)updateLastTempUserToken:(NSString *)token {
    [[STIMManager sharedInstance] updateLastTempUserToken:token];
}

/**
 获取最后一个登录用户的临时Token
 
 @return 用户token
 */
- (NSString *)getLastTempUserToken {
    return [[STIMManager sharedInstance] getLastTempUserToken];
}

/**
 更新最后一个登录用户的token
 
 @param tempUserToken 用户token
 */
- (void)updateLastUserToken:(NSString *)tempUserToken {
    [[STIMManager sharedInstance] updateLastUserToken:tempUserToken];
}

/**
 获取最后一个登录用户的token
 
 @return 用户token
 */
- (NSString *)getLastUserToken {
    return [[STIMManager sharedInstance] getLastUserToken];
}

- (NSString *)getLastPassword {
    return [[STIMManager sharedInstance] getLastPassword];
}

- (NSString *)getLastJid {
    return [[STIMManager sharedInstance] getLastJid];
}

- (NSString *)getMyNickName {
    return [[STIMManager sharedInstance] getMyNickName];
}

- (NSString *)getDomain {
    return [[STIMManager sharedInstance] getDomain];
}

- (long long)getCurrentServerTime {
    return [[STIMManager sharedInstance] getCurrentServerTime];
}

- (int)getServerTimeDiff {
    return [[STIMManager sharedInstance] getServerTimeDiff];
}

- (NSHTTPCookie *)cookie {
    return [[STIMManager sharedInstance] cookie];
}

// 更新导航配置
- (void)updateNavigationConfig {
    [[STIMManager sharedInstance] updateNavigationConfig];
}

- (void)checkClientConfig {
    [[STIMManager sharedInstance] checkClientConfig];
}

- (NSArray *)trdExtendInfo {
    return [[STIMManager sharedInstance] trdExtendInfo];
}

- (NSString *)aaCollectionUrlHost {
    return [[STIMManager sharedInstance] aaCollectionUrlHost];
}

- (NSString *)redPackageUrlHost {
    return [[STIMManager sharedInstance] redPackageUrlHost];
}

- (NSString *)redPackageBalanceUrl {
    return [[STIMManager sharedInstance] redPackageBalanceUrl];
}

- (NSString *)myRedpackageUrl {
    return [[STIMManager sharedInstance] myRedpackageUrl];
}

#pragma mark get user agent
- (NSString *)getDefaultUserAgentString {
    return [[STIMManager sharedInstance] getDefaultUserAgentString];
}

- (BOOL)isNewMsgNotify {
    return [[STIMManager sharedInstance] isNewMsgNotify];
}

- (void)setNewMsgNotify:(BOOL)flag {
    [[STIMManager sharedInstance] setNewMsgNotify:flag];
}

- (BOOL)pickerPixelOriginal {
    return [[STIMManager sharedInstance] pickerPixelOriginal];
}

- (void)setPickerPixelOriginal:(BOOL)flag {
    [[STIMManager sharedInstance] setPickerPixelOriginal:flag];
}

- (BOOL)moodshow {
    return [[STIMManager sharedInstance] moodshow];
}

- (void)setMoodshow:(BOOL)flag {
    [[STIMManager sharedInstance] setMoodshow:flag];
}

//是否展示水印
- (BOOL)waterMarkState {
    return [[STIMManager sharedInstance] waterMarkState];
}

- (void)setWaterMarkState:(BOOL)flag {
    [[STIMManager sharedInstance] setWaterMarkState:flag];
}

//艾特消息
- (NSArray *)getHasAtMeByJid:(NSString *)jid  {
    return [[STIMManager sharedInstance] getHasAtMeByJid:jid];
}

- (void)updateAtMeMessageWithJid:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(STIMAtMsgReadState)readState {
    [[STIMManager sharedInstance] updateAtMeMessageWithJid:groupId withMsgIds:msgIds withReadState:readState];
}

- (void)clearAtMeMessageWithJid:(NSString *)groupId {
    [[STIMManager sharedInstance] clearAtMeMessageWithJid:groupId];
}

- (void)addOfflineAtMeMessageByJid:(NSString *)groupId withType:(STIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    [[STIMManager sharedInstance] addOfflineAtMeMessageByJid:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
}

- (void)addAtMeMessageByJid:(NSString *)groupId withType:(STIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    [[STIMManager sharedInstance] addAtMeMessageByJid:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
}

//输入框草稿
- (NSDictionary *)getNotSendTextByJid:(NSString *)jid {
    return [[STIMManager sharedInstance] getNotSendTextByJid:jid];
}

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid {
    [[STIMManager sharedInstance] setNotSendText:text inputItems:inputItems ForJid:jid];
}

- (NSDictionary *)getQChatTokenWithBusinessLineName:(NSString *)businessLineName {
    return [[STIMManager sharedInstance] getQChatTokenWithBusinessLineName:businessLineName];
}

- (NSDictionary *)getQVTForQChat {
    return [[STIMManager sharedInstance] getQVTForQChat];
}

- (void)removeQVTForQChat {
    [[STIMManager sharedInstance] removeQVTForQChat];
}

- (NSString *)getDownloadFilePath {
    return [[STIMManager sharedInstance] getDownloadFilePath];
}

- (void)clearcache {
    [[STIMManager sharedInstance] clearcache];
}

- (BOOL)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType {
    return [[STIMManager sharedInstance] setStickWithCombineJid:combineJid WithChatType:chatType];
}

- (BOOL)removeStickWithCombineJid:(NSString *)jid WithChatType:(ChatType)chatType {
    return [[STIMManager sharedInstance] removeStickWithCombineJid:jid WithChatType:chatType];
}

- (BOOL)isStickWithCombineJid:(NSString *)jid {
    return [[STIMManager sharedInstance] isStickWithCombineJid:jid];
}

- (NSDictionary *)stickList {
    return [[STIMManager sharedInstance] stickList];
}

- (BOOL)setMsgNotifySettingWithIndex:(STIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn {
    return [[STIMManager sharedInstance] setMsgNotifySettingWithIndex:setting WithSwitchOn:switchOn];
}

- (BOOL)getLocalMsgNotifySettingWithIndex:(STIMMSGSETTING)setting {
    return [[STIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:setting];
}

- (void)getMsgNotifyRemoteSettings {
    [[STIMManager sharedInstance] getMsgNotifyRemoteSettings];
}

#pragma mark - kNotificationSetting

- (void)sendNoPush {
    [[STIMManager sharedInstance] sendNoPush];
}

- (BOOL)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag {
    return [[STIMManager sharedInstance] sendServer:notificationToken withUsername:username withParamU:paramU withParamK:paramK WithDelete:deleteFlag];
}

- (BOOL)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag {
    return [[STIMManager sharedInstance] sendPushTokenWithMyToken:myToken WithDeleteFlag:deleteFlag];
}

- (void)checkClearCache {
    [[STIMManager sharedInstance] checkClearCache];
}

@end
