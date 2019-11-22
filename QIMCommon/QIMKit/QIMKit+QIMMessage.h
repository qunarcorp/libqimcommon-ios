//
//  QIMKit+QIMMessage.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"
@class QIMMessageModel;

@interface QIMKit (QIMMessage)

/**
 获取指定类型消息
 
 @param msgType 指定消息类型
 @return 返回消息组
 */
- (NSArray *)getMsgsForMsgType:(QIMMessageType)msgType;

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId;

- (QIMMessageModel *)getMsgByMsgId:(NSString *)msgId;

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag;

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag;

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag withFrontInsert:(BOOL)frontInsert;

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag withFrontInsert:(BOOL)frontInsert;

#pragma mark - 公共消息

/**
 根据用户Id设置Message附加属性 {'cctext', 'bu'}
 
 @param appendInfoDict 附加字典
 @param userId 用户Id
 */
- (void)setAppendInfo:(NSDictionary *)appendInfoDict ForUserId:(NSString *)userId;

/**
 根据用户Id获取Message附加属性  {'cctext', 'bu'}
 
 @param userId 用户Id
 */
- (NSDictionary *)getAppendInfoForUserId:(NSString *)userId;

/**
 根据用户Id设置ChannelId
 
 @param channelId channelId
 @param userId 用户Id
 */
- (void)setChannelInfo:(NSString *)channelId ForUserId:(NSString *)userId;

/**
 根据用户Id获取ChannelId
 
 @param userId 用户Id
 */
- (NSString *)getChancelInfoForUserId:(NSString *)userId;


/**
 根据用户Id设置 点击聊天内容中的URL务必拼接的参数 （众包需求）
 
 @param param param
 @param jid 用户Id
 */
- (void)setConversationParam:(NSDictionary *)param WithJid:(NSString *)jid;

/**
 根据用户Id获取 点击聊天内容中的URL务必拼接的参数 （众包需求）
 
 @param jid 用户Id
 */
- (NSDictionary *)conversationParamWithJid:(NSString *)jid;

/**
 发送正在输入消息
 
 @param userId to 给谁？
 */
- (void)sendTypingToUserId:(NSString *)userId;

/**
 消息入库
 
 @param msg message
 @param sid 会话ID(单人为to，群为群id)
 */
- (void)saveMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid;

//更新消息
- (void)updateMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid;

- (void)deleteMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid;

- (BOOL)sendControlStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId;

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(QIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId;

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(QIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid;

- (BOOL)sendReadstateWithGroupLastMessageTime:(long long) lastTime withGroupId:(NSString *) groupId;

#pragma mark - 单人消息

/**
 发送窗口抖动
 
 @param userId 对方用户Id
 */
- (QIMMessageModel *)sendShockToUserId:(NSString *)userId;


/**
 撤销单人消息
 
 @param messageId messageId
 @param message message
 @param jid jid
 */
- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid ;

/**
 撤销资讯类消息
 
 @param messageId messageId
 @param message message
 @param jid jid
 */
- (void)revokeConsultMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(ChatType)chatType;

/**
 发送语音消息
 
 @param voiceUrl 语音文件地址
 @param voiceName 语音文件名
 @param seconds 语音时长
 @param userId 接收方Id
 */
- (QIMMessageModel *)sendVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToUserId:(NSString *)userId;


/**
 发送消息
 
 @param msg 消息Message对象
 @param userId 接收方Id
 */
- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg ToUserId:(NSString *)userId;

/**
 发送单人消息
 
 @param msg 消息Body
 @param info 消息ExtendInfo
 @param userId 接收Id
 @param msgType 消息Type
 */
- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WithMsgType:(int)msgType;

#pragma mark - 群消息

/**
 发送群消息
 
 @param msg 消息Body
 @param groupId 群Id
 */
- (QIMMessageModel *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId ;


/**
 发送群消息
 
 @param msg 消息Body
 @param info 消息ExtendInfo
 @param groupId 群Id
 @param msgType 消息Type
 */
- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType;


/**
 发送群消息
 
 @param msg 消息Body
 @param info 消息ExtendInfo
 @param groupId 群Id
 @param msgType 消息Type
 @param msgId 消息Id
 */
- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType WithMsgId:(NSString *)msgId;

/**
 撤销群消息
 
 @param messageId messageId
 @param message message
 @param jid jid
 */
- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid;

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid;

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler;

/**
 创建消息
 
 @param msg 消息文本
 @param extendInfo 扩展消息
 @param userId 用户id(单人id/群id/虚拟id)
 @param userType 会话类型 ChatType
 @param msgType 消息类型 MessageType
 @param mId 消息id，传nil会默认生成
 @param willSave 是否入库
 @return 返回创建的消息
 */
- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(QIMMessageSendState)msgState willSave:(BOOL)willSave;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave;

- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId;

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid;

#pragma mark - 位置共享

/**
 发送共享位置消息
 
 @param msg 消息描述
 @param info 扩展消息
 @param jid 对象id
 @param msgType 消息类型
 @return 返回消息本身
 */
- (QIMMessageModel *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WithMsgType:(int)msgType;

/**
 共享位置开始
 
 @param userId 用户id
 @param shareLocationId 共享位置标识
 @return 返回消息本身
 */
- (QIMMessageModel *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId;

/**
 共享位置开始(群)
 
 @param GroupId 群id
 @param shareLocationId 共享位置标识
 @return 返回消息本身
 */
- (QIMMessageModel *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId;

/**
 加入消息共享
 
 @param users 共享消息的用户组
 @param shareLocationId 共享消息标识
 @return 是否成功
 */
- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;

/**
 发送我的位置给其他用户
 
 @param users 共享位置的用户组
 @param locationInfo 位置信息
 @param shareLocationId 共享消息标识
 @return 是否成功
 */
- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId;

/**
 退出位置共享
 
 @param users 共享位置的用户组
 @param shareLocationId 共享消息标识
 @return 是否成功
 */
- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;

/**
 获取共享标识
 
 @param jid jid
 @return 返回共享消息标识
 */
- (NSString *)getShareLocationIdByJid:(NSString *)jid;

/**
 获取共享位置信息
 
 @param shareLocationId 共享位置标识
 @return 返回共享位置信息
 */
- (NSString *)getShareLocationFromIdByShareLocationId:(NSString *)shareLocationId;

/**
 获取共享位置用户组
 
 @param shareLocationId 共享位置标识
 @return 返回用户组
 */
- (NSArray *)getShareLocationUsersByShareLocationId:(NSString *)shareLocationId;


#pragma mark - 未读数

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(QIMMessageSendState)state;

- (NSMutableSet *)getLastMsgCompensateReadSet;

/**
 清空所有未读消息
 */
- (void) clearAllNoRead;

/**
 清空HeadLine未读消息
 */
- (void)clearSystemMsgNotReadWithJid:(NSString *)jid;

/**
 根据Jid清空未读消息
 
 @param jid 用户Id
 */
- (void)clearNotReadMsgByJid:(NSString *)jid;

/**
 根据Jid & RealJid清空未读消息
 
 @param jid 用户Id
 @param realJid 真实用户Id
 */
- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid;

/**
 根据群Id清空未读消息
 
 @param groupId 群id
 */
- (void)clearNotReadMsgByGroupId:(NSString *)groupId;

/**
 获取Jid & 真实Id下的未读消息数
 
 @param jid 用户Id
 @param realJid 真实用户Id
 */
- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid;

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (void)updateAppNotReadCount;

/**
 获取App总未读数
 */
- (NSInteger)getAppNotReaderCount;

/**
 获取接收但不提醒的未读数
 */
- (NSInteger)getNotRemindNotReaderCount;

/**
 获取骆驼帮未读消息数
 */
- (void)getExploreNotReaderCount;

/**
 获取QChat商家未回复留言数
 */
- (void)getLeaveMsgNotReaderCountWithCallBack:(QIMKitGetLeaveMsgNotReaderCountBlock)callback;

- (void)updateNotReadCountCacheByJid:(NSString *)jid WithRealJid:(NSString *)realJid;
- (void)updateMessageStateWithNewState:(QIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList;

- (void)updateNotReadCountCacheByJid:(NSString *)jid;

- (void)saveChatId:(NSString *)chatId ForUserId:(NSString *)userId;

- (void)setMsgSentFaild;

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw;

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw;

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid;


/**
 搜索时候

 @param userId 用户名
 @param realJid 真实jid
 @param lastUpdateTime 时间戳
 @param direction 获取方向
 @param limit 获取条数
 @param offset 偏移量
 @param complete 回调block
 */
- (void)getRemoteSearchMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid withVersion:(long long)lastUpdateTime withDirection:(QIMGetMsgDirection)direction WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete;

/**
 获取消息列表
 
 @param userId   用户名
 @param limit    获取条数
 @param realJid  真实jid
 @param offset   偏移量
 @param complete 回调block
 */
- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete;

/**
 获取消息列表
 
 @param userId 虚拟id
 @param realJid 真实id
 
 @param timeStamp 时间戳
 @param complete 回调block
 */
- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WithComplete:(void (^)(NSArray *))complete;

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete;

// ******************** 本地消息搜索 ***************************//

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord
                                         XmppId:(NSString *)xmppid
                                        RealJid:(NSString *)realJid;

#pragma mark - 本地消息搜索

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid;

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId;

@end
