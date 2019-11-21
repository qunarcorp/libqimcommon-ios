//
//  QIMKit.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QIMCommonEnum.h"

@class QIMMessageModel;
@interface QIMKit : NSObject

+ (QIMKit *)sharedInstance;

- (void)clearQIMManager;

- (NSMutableDictionary *)timeStempDic;

- (dispatch_queue_t)getLastQueue;

- (dispatch_queue_t)getLoadSessionNameQueue;

- (dispatch_queue_t)getLoadHeaderImageQueue;

- (dispatch_queue_t)getLoadSessionContentQueue;

- (dispatch_queue_t)getLoadSessionUnReadCountQueue;

- (dispatch_queue_t)getLoadGroupCardFromDBQueue;

- (dispatch_queue_t)getLoadMsgNickNameQueue;

- (dispatch_queue_t)getLoadMsgMedalListQueue;

- (dispatch_queue_t)getLoad_msgHeaderImageQueue;

- (NSString *)getOpsFoundRNDebugUrl;

- (void)setOpsFoundRNDebugUrl:(NSString *)opsFoundRNDebugUrl;

- (NSString *)qtalkFoundRNDebugUrl;

- (void)setQtalkFoundRNDebugUrl:(NSString *)qtalkFoundRNDebugUrl;

- (NSString *)qtalkSearchRNDebugUrl;

- (void)setQtalkSearchRNDebugUrl:(NSString *)qtalkSearchRNDebugUrl;

- (NSString *)getImagerCache;

/**
 更新remote key
 
 @return 返回remote key
 */
- (NSString *)updateRemoteLoginKey;

@end

@interface QIMKit (Common) <NSXMLParserDelegate>

- (NSData *)updateOrganizationalStructure;

@end


@interface QIMKit (CommonConfig)

//认证


/**
 UK，登录之后服务器下发下来，用作旧接口的验证
 */
- (NSString *)remoteKey;

/**
 get remote key
 
 @return 返回remote key
 */
- (NSString *)myRemotelogginKey;


/**
 第三方认证的key - Ckey/q_ckey
 
 @return 返回Base64后的Key
 */
- (NSString *) thirdpartKeywithValue;


/**
 手动设置客服状态

 @param isMerchant 客服状态
 */
- (void)setIsMerchant:(BOOL)isMerchant;

/**
 客服状态
 */
- (BOOL)isMerchant;

/**
 *  UserName Ex: lilulucas.li
 *
 *  @return UserName
 */
+ (NSString *)getLastUserName;

/**
 更新最后一个登录用户的临时Token
 
 @param token 用户token
 */
- (void)updateLastTempUserToken:(NSString *)token;

/**
 获取最后一个登录用户的临时Token
 
 @return 用户token
 */
- (NSString *)getLastTempUserToken;

/**
 更新最后一个登录用户的token
 
 @param tempUserToken 用户token
 */
- (void)updateLastUserToken:(NSString *)tempUserToken;


/**
 获取最后一个登录用户的token
 
 @return 用户token
 */
- (NSString *)getLastUserToken;

/**
 *  PWD
 *
 *  @return 无用
 */
- (NSString *)getLastPassword;

/**
 *  JID  Ex: lilulucas.li@ejabhost1
 *
 *  @return JID
 */
- (NSString *)getLastJid;

/**
 *  nickName  Ex: 李露lucas
 *
 *  @return MyNickName
 */
- (NSString *)getMyNickName;

/**
 获取当前登录的公司
 */
- (NSString *)getCompany;

/**
 获取当前登录的domain
 */
- (NSString *)getDomain;

- (long long)getCurrentServerTime;


- (int)getServerTimeDiff;

- (NSHTTPCookie *)cookie;

// 更新导航配置
- (void)updateNavigationConfig;

- (void)checkClientConfig;

/**
 获取trdExtendInfo
 
 @return 返回trdExtendInfo
 */
- (NSArray *)trdExtendInfo;

/**
 获取AA收款URL

 @return 返回aaCollectionUrlHost
 */
- (NSString *)aaCollectionUrlHost;

/**
 获取红包URL

 @return 返回redPackageUrlHost
 */
- (NSString *)redPackageUrlHost;

/**
 获取余额URL

 @return 返回redPackageBalanceUrl
 */
- (NSString *)redPackageBalanceUrl;

/**
 获取我的红包URL

 @return 返回myRedpackageUrl
 */
- (NSString *)myRedpackageUrl;

#pragma mark get user agent
- (NSString *)getDefaultUserAgentString;

/**
 新消息通知？
 
 @return bool值
 */
- (BOOL)isNewMsgNotify;

/**
 设置新消息通知？
 
 @param flag bool值
 */
- (void)setNewMsgNotify:(BOOL)flag;
//相册是否发送原图
- (BOOL)pickerPixelOriginal;

- (void)setPickerPixelOriginal:(BOOL)flag;

//是否优先展示对方个性签名
- (BOOL)moodshow;

/**
 设置 mood show
 
 @param flag bool值
 */
- (void)setMoodshow:(BOOL)flag;

//是否展示水印
- (BOOL)waterMarkState;


/**
 设置展示水印

 @param flag 展示水印bool值
 */
- (void)setWaterMarkState:(BOOL)flag;

//艾特
/**
 获取At me的
 
 @param jid 会话id
 @return 返回结果
 */
- (NSArray *)getHasAtMeByJid:(NSString *)jid;

/**
 更新艾特消息操作状态
 
 @param groupId 群Id
 @param msgId 艾特消息MsgId
 @param readState 操作状态
 */
- (void)updateAtMeMessageWithJid:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(QIMAtMsgReadState)readState;

/**
 清空艾特消息
 
 @param groupId 群Id
 */
- (void)clearAtMeMessageWithJid:(NSString *)groupId;

/**
 新增离线艾特消息

 @param groupId 群Id
 @param atType at类型
 @param msgId 艾特消息MsgId
 @param msgTime 艾特消息时间戳
 */
- (void)addOfflineAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime;

/**
 新增艾特消息
 
 @param groupId 群Id
 @param atType at类型
 @param msgId 艾特消息MsgId
 @param msgTime 艾特消息时间戳
 */
- (void)addAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime;


//输入框草稿
- (NSDictionary *)getNotSendTextByJid:(NSString *)jid ;

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid;

/**
 qchat获取token
 
 @return 返回token
 */
- (void)getQChatTokenWithBusinessLineName:(NSString *)businessLineName withCallBack:(QIMKitGetQChatTokenSuccessBlock)callback;

- (NSDictionary *)getQVTForQChat;

- (void)removeQVTForQChat;

- (NSString *)getDownloadFilePath;

/**
 清空缓存
 */
- (void)clearcache;

/**
 置顶/ 移除置顶
 
 @param jid 需要置顶的jid
 */
- (void)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback;

/**
 置顶/ 移除置顶
 
 @param jid 需要置顶的jid
 @param chatType 会话类型
 */
- (void)removeStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback;

/**
 是否已置顶
 
 @param jid session id
 @return 返回判定结果
 */
- (BOOL)isStickWithCombineJid:(NSString *)jid;

/**
 获取置顶列表
 
 @return 置顶的会话列表
 */
- (NSDictionary *)stickList;

- (void)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn withCallBack:(QIMKitSetMsgNotifySettingSuccessBlock)callback;

- (BOOL)getLocalMsgNotifySettingWithIndex:(QIMMSGSETTING)setting;

- (void)getMsgNotifyRemoteSettings;

/**
 关闭通知
 */
- (void)sendNoPush;


/**
 上传推送Token到服务器

 @param notificationToken 注册的通知Token
 @param username 用户名
 @param paramU 用户ming
 @param paramK 用户验证的key
 @param deleteFlag 是否删除服务器推送Token
 @return 上传是否成功
 */
- (void)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback;

/**
 发送push Token

 @param myToken 注册的通知token
 @param deleteFlag 是否删除
 */
- (void)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback;

- (void)checkClearCache;

@end
