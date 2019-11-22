//
//  QIMManager+Message.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMManager.h"

#pragma mark - 消息

@interface QIMManager (Message)

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
 
 @param param param
 @param jid 用户Id
 */
- (NSDictionary *)conversationParamWithJid:(NSString *)jid;

- (void)sendTypingToUserId:(NSString *)userId;

- (void)saveMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid;

//更新消息
- (void)updateMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid;

- (void)deleteMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid;

//更新群消息阅读状态
- (void)updateLocalGroupMessageRemoteState:(NSInteger)remoteState withXmppId:(NSString *)xmppId ByReadList:(NSArray *)readList;

//更新单人消息阅读状态
- (void)updateLocalMessageRemoteState:(NSInteger)remoteState withXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid ByMsgIdList:(NSArray *)msgIdList;

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
- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid;


/**
 撤销consult消息
 @param messageId messageId
 @param message message
 @param jid jid
 
 */
- (void)revokeConsultMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(int)chatType;


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
 @param jid
 */
- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid;

//发送wlan消息
-(void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int) msgType completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;


// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave;
- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(QIMMessageSendState)msgState willSave:(BOOL)willSave ;
- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave;
- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson;
- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType;

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo;
- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId;
//- (QIMMessageModel *)sendMessage:(NSString *)msg ToUserId:(NSString *)userId;

//- (void)setNotReaderMsgCount:(int)count ForJid:(NSString *)jid;

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid;

#pragma mark - 位置共享

- (QIMMessageModel *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WithMsgType:(int)msgType;
- (QIMMessageModel *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId;
- (QIMMessageModel *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId;
- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;
- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId;
- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;
- (NSString *)getShareLocationIdByJid:(NSString *)jid;
- (NSString *)getShareLocationFromIdByShareLocationId:(NSString *)shareLocationId;
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
- (void)updateMessageControlStateWithNewState:(QIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList;
- (void)updateMessageStateWithNewState:(QIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList;

- (void)updateNotReadCountCacheByJid:(NSString *)jid;

- (void)saveChatId:(NSString *)chatId ForUserId:(NSString *)userId;

- (void)setMsgSentFaild;

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw;

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw;

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid;

- (QIMMessageModel *)getMessageModelWithByDBMsgDic:(NSDictionary *)dbMsgDic;

- (void)getRemoteSearchMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid withVersion:(long long)lastUpdateTime withDirection:(QIMGetMsgDirection)direction WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete;

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete;

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WithComplete:(void (^)(NSArray *))complete;

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord
                                         XmppId:(NSString *)xmppid
                                        RealJid:(NSString *)realJid;

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid;

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId;

@end
