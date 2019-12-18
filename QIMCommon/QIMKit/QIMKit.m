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
//    //监听通知:AvoidCrashNotification, 获取AvoidCrash捕获的崩溃日志的详细信息
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

- (dispatch_queue_t)getLoadSessionNameQueue {
    return [[[QIMManager sharedInstance] load_session_name] queue];
}

- (dispatch_queue_t)getLoadHeaderImageQueue {
    return [[[QIMManager sharedInstance] load_user_header] queue];
}

- (dispatch_queue_t)getLoadSessionContentQueue {
    return [[[QIMManager sharedInstance] load_session_content] queue];
}

- (dispatch_queue_t)getLoadSessionUnReadCountQueue {
    return [[[QIMManager sharedInstance] load_session_unreadcount] queue];
}

- (dispatch_queue_t)getLoadGroupCardFromDBQueue {
    return [[[QIMManager sharedInstance] load_groupDB_VCard] queue];
}

- (dispatch_queue_t)getLoadMsgNickNameQueue {
    return [[[QIMManager sharedInstance] load_msgNickName] queue];
}

- (dispatch_queue_t)getLoadMsgMedalListQueue {
    return [[[QIMManager sharedInstance] load_msgMedalList] queue];
}

- (dispatch_queue_t)getLoad_msgHeaderImageQueue {
    return [[[QIMManager sharedInstance] load_msgHeaderImage] queue];
}

- (NSString *)getOpsFoundRNDebugUrl {
    return [[QIMManager sharedInstance] opsFoundRNDebugUrl];
}

- (void)setOpsFoundRNDebugUrl:(NSString *)opsFoundRNDebugUrl {
    [[QIMManager sharedInstance] setOpsFoundRNDebugUrl:opsFoundRNDebugUrl];
}

- (NSString *)qtalkFoundRNDebugUrl {
    return [[QIMManager sharedInstance] qtalkFoundRNDebugUrl];
}

- (void)setQtalkFoundRNDebugUrl:(NSString *)qtalkFoundRNDebugUrl {
    [[QIMManager sharedInstance] setQtalkFoundRNDebugUrl:qtalkFoundRNDebugUrl];
}

- (NSString *)qtalkSearchRNDebugUrl {
    return [[QIMManager sharedInstance] qtalkSearchRNDebugUrl];
}

- (void)setQtalkSearchRNDebugUrl:(NSString *)qtalkSearchRNDebugUrl {
    [[QIMManager sharedInstance] setQtalkSearchRNDebugUrl:qtalkSearchRNDebugUrl];
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

/**
 更新最后一个登录用户的临时Token
 
 @param token 用户token
 */
- (void)updateLastTempUserToken:(NSString *)token {
    [[QIMManager sharedInstance] updateLastTempUserToken:token];
}

/**
 获取最后一个登录用户的临时Token
 
 @return 用户token
 */
- (NSString *)getLastTempUserToken {
    return [[QIMManager sharedInstance] getLastTempUserToken];
}

/**
 更新最后一个登录用户的token
 
 @param tempUserToken 用户token
 */
- (void)updateLastUserToken:(NSString *)tempUserToken {
    [[QIMManager sharedInstance] updateLastUserToken:tempUserToken];
}

/**
 获取最后一个登录用户的token
 
 @return 用户token
 */
- (NSString *)getLastUserToken {
    return [[QIMManager sharedInstance] getLastUserToken];
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

- (NSString *)getDomain {
    return [[QIMManager sharedInstance] getDomain];
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

#pragma mark get user agent
- (NSString *)getDefaultUserAgentString {
    return [[QIMManager sharedInstance] getDefaultUserAgentString];
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

//是否展示水印
- (BOOL)waterMarkState {
    return [[QIMManager sharedInstance] waterMarkState];
}

- (void)setWaterMarkState:(BOOL)flag {
    [[QIMManager sharedInstance] setWaterMarkState:flag];
}

//艾特消息
- (NSArray *)getHasAtMeByJid:(NSString *)jid  {
    return [[QIMManager sharedInstance] getHasAtMeByJid:jid];
}

- (void)updateAtMeMessageWithJid:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(QIMAtMsgReadState)readState {
    [[QIMManager sharedInstance] updateAtMeMessageWithJid:groupId withMsgIds:msgIds withReadState:readState];
}

- (void)clearAtMeMessageWithJid:(NSString *)groupId {
    [[QIMManager sharedInstance] clearAtMeMessageWithJid:groupId];
}

- (void)addOfflineAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    [[QIMManager sharedInstance] addOfflineAtMeMessageByJid:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
}

- (void)addAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    [[QIMManager sharedInstance] addAtMeMessageByJid:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
}

//输入框草稿
- (NSDictionary *)getNotSendTextByJid:(NSString *)jid {
    return [[QIMManager sharedInstance] getNotSendTextByJid:jid];
}

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid {
    [[QIMManager sharedInstance] setNotSendText:text inputItems:inputItems ForJid:jid];
}

- (void)getQChatTokenWithBusinessLineName:(NSString *)businessLineName qcookie:(NSString *)_q vcookie:(NSString *)_v tcookie:(NSString *)_t withCallBack:(QIMKitGetQChatTokenSuccessBlock)callback{
    [[QIMManager sharedInstance] getQChatTokenWithBusinessLineName:businessLineName qcookie:_q vcookie:_v tcookie:_t withCallBack:callback];
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

- (void)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    [[QIMManager sharedInstance] setStickWithCombineJid:combineJid WithChatType:chatType withCallback:callback];
}

- (void)removeStickWithCombineJid:(NSString *)jid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback{
    [[QIMManager sharedInstance] removeStickWithCombineJid:jid WithChatType:chatType withCallback:callback];
}

- (BOOL)isStickWithCombineJid:(NSString *)jid {
    return [[QIMManager sharedInstance] isStickWithCombineJid:jid];
}

- (NSDictionary *)stickList {
    return [[QIMManager sharedInstance] stickList];
}

- (void)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn withCallBack:(QIMKitSetMsgNotifySettingSuccessBlock)callback {
    [[QIMManager sharedInstance] setMsgNotifySettingWithIndex:setting WithSwitchOn:switchOn withCallBack:callback];
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

- (void)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback {
    [[QIMManager sharedInstance] sendServer:notificationToken withUsername:username withParamU:paramU withParamK:paramK WithDelete:deleteFlag withCallback:callback];
}

- (void)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback {
    [[QIMManager sharedInstance] sendPushTokenWithMyToken:myToken WithDeleteFlag:deleteFlag withCallback:callback];
}

- (void)checkClearCache {
    [[QIMManager sharedInstance] checkClearCache];
}

@end
