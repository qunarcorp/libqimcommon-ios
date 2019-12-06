//
//  QIMKit+QIMMessage.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMMessage)

- (NSArray *)getMsgsForMsgType:(QIMMessageType)msgType {
    return [[QIMManager sharedInstance] getMsgsForMsgType:msgType];
}

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId {
    return [[QIMManager sharedInstance] getMsgDictByMsgId:msgId];
}

- (QIMMessageModel *)getMsgByMsgId:(NSString *)msgId {
    return [[QIMManager sharedInstance] getMsgByMsgId:msgId];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [[QIMManager sharedInstance] checkMsgTimeWithJid:jid WithRealJid:realJid WithMsgDate:msgDate WithGroup:flag];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [[QIMManager sharedInstance] checkMsgTimeWithJid:jid WithMsgDate:msgDate WithGroup:flag];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag withFrontInsert:(BOOL)frontInsert {
    [[QIMManager sharedInstance] checkMsgTimeWithJid:jid WithRealJid:realJid WithMsgDate:msgDate WithGroup:(BOOL)flag withFrontInsert:frontInsert];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag withFrontInsert:(BOOL)frontInsert {
    [[QIMManager sharedInstance] checkMsgTimeWithJid:jid WithMsgDate:msgDate WithGroup:flag withFrontInsert:frontInsert];
}

- (void)setAppendInfo:(NSDictionary *)appendInfoDict ForUserId:(NSString *)userId {
    [[QIMManager sharedInstance] setAppendInfo:appendInfoDict ForUserId:userId];
}

- (NSDictionary *)getAppendInfoForUserId:(NSString *)userId {
   return [[QIMManager sharedInstance] getAppendInfoForUserId:userId];
}

- (void)setChannelInfo:(NSString *)channelId ForUserId:(NSString *)userId {
    [[QIMManager sharedInstance] setChannelInfo:channelId ForUserId:userId];
}

- (NSString *)getChancelInfoForUserId:(NSString *)userId {
   return [[QIMManager sharedInstance] getChancelInfoForUserId:userId];
}

- (void)setConversationParam:(NSDictionary *)param WithJid:(NSString *)jid {
    [[QIMManager sharedInstance] setConversationParam:param WithJid:jid];
}

- (NSDictionary *)conversationParamWithJid:(NSString *)jid {
    return [[QIMManager sharedInstance] conversationParamWithJid:jid];
}

- (void)sendTypingToUserId:(NSString *)userId {
    [[QIMManager sharedInstance] sendTypingToUserId:userId];
}

- (void)saveMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid {
    [[QIMManager sharedInstance] saveMsg:msg ByJid:sid];
}

- (void)updateMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid {
    [[QIMManager sharedInstance] updateMsg:msg ByJid:sid];
}

- (void)deleteMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid {
    [[QIMManager sharedInstance] deleteMsg:msg ByJid:sid];
}

- (BOOL)sendControlStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] sendControlStateWithMessagesIdArray:messages WithXmppId:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(QIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] sendReadStateWithMessagesIdArray:messages WithMessageReadFlag:msgReadFlag WithXmppId:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(QIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] sendReadStateWithMessagesIdArray:messages WithMessageReadFlag:msgReadFlag WithXmppId:xmppId WithRealJid:realJid];
}

- (BOOL)sendReadstateWithGroupLastMessageTime:(long long) lastTime withGroupId:(NSString *) groupId {
    return [[QIMManager sharedInstance] sendReadstateWithGroupLastMessageTime:lastTime withGroupId:groupId];
}

- (QIMMessageModel *)sendShockToUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] sendShockToUserId:userId];
}

- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] revokeMessageWithMessageId:messageId message:message ToJid:jid];
}

- (void)revokeConsultMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(int)chatType{
    [[QIMManager sharedInstance] revokeConsultMessageWithMessageId:messageId message:message ToJid:jid realToJid:realToJid chatType:chatType];
}

- (QIMMessageModel *)sendVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] sendVoiceUrl:voiceUrl withVoiceName:voiceName withSeconds:seconds ToUserId:userId];
}

- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg ToUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] sendMessage:msg ToUserId:userId];
}

- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WithMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendMessage:msg WithInfo:info ToUserId:userId WithMsgType:msgType];
}

- (QIMMessageModel *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] sendMessage:msg ToGroupId:groupId];
}

- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendMessage:msg WithInfo:info ToGroupId:groupId WithMsgType:msgType];
}

- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType WithMsgId:(NSString *)msgId {
    return [[QIMManager sharedInstance] sendMessage:msg WithInfo:info ToGroupId:groupId WithMsgType:msgType WithMsgId:msgId];
}

- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] revokeGroupMessageWithMessageId:messageId message:message ToJid:jid];
}

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    [[QIMManager sharedInstance] sendWlanMessage:content to:targetID extendInfo:extendInfo msgType:msgType completionHandler:completionHandler];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}
- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(QIMMessageSendState)msgState willSave:(BOOL)willSave {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:realJid userType:userType msgType:msgType forMsgId:mId msgState:msgState willSave:willSave];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:realJid userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}

- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson {
    return [[QIMManager sharedInstance] sendMessage:msg withChatType:chatType channelInfo:channelInfo realFrom:realFrom realTo:realTo ochatJson:ochatJson];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType backinfo:backInfo];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId];
}

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid {
    [[QIMManager sharedInstance] synchronizeChatSessionWithUserId:userId WithChatType:chatType WithRealJid:realJid];
}

#pragma mark - 位置共享

- (QIMMessageModel *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WithMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendShareLocationMessage:msg WithInfo:info ToJid:jid WithMsgType:msgType];
}

- (QIMMessageModel *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] beginShareLocationToUserId:userId WithShareLocationId:shareLocationId];
}

- (QIMMessageModel *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] beginShareLocationToGroupId:GroupId WithShareLocationId:shareLocationId];
}

- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] joinShareLocationToUsers:users WithShareLocationId:shareLocationId];
}

- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] sendMyLocationToUsers:users WithLocationInfo:locationInfo ByShareLocationId:shareLocationId];
}

- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] quitShareLocationToUsers:users WithShareLocationId:shareLocationId];
}

- (NSString *)getShareLocationIdByJid:(NSString *)jid {
    return [[QIMManager sharedInstance] getShareLocationIdByJid:jid];
}

- (NSString *)getShareLocationFromIdByShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] getShareLocationFromIdByShareLocationId:shareLocationId];
}

- (NSArray *)getShareLocationUsersByShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] getShareLocationUsersByShareLocationId:shareLocationId];
}


#pragma mark - 未读数

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(QIMMessageSendState)state{
    [[QIMManager sharedInstance] updateMsgReadCompensateSetWithMsgId:msgId WithAddFlag:flag WithState:state];
}

- (NSMutableSet *)getLastMsgCompensateReadSet {
    return [[QIMManager sharedInstance] getLastMsgCompensateReadSet];
}

- (void)clearAllNoRead {
    [[QIMManager sharedInstance] clearAllNoRead];
}

- (void)clearSystemMsgNotReadWithJid:(NSString *)jid {
    [[QIMManager sharedInstance] clearSystemMsgNotReadWithJid:jid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid {
    [[QIMManager sharedInstance] clearNotReadMsgByJid:jid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid {
    [[QIMManager sharedInstance] clearNotReadMsgByJid:jid ByRealJid:realJid];
}

- (void)clearNotReadMsgByGroupId:(NSString *)groupId {
    [[QIMManager sharedInstance] clearNotReadMsgByGroupId:groupId];
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] getNotReadMsgCountByJid:jid WithRealJid:realJid];
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    return [[QIMManager sharedInstance] getNotReadMsgCountByJid:jid WithRealJid:realJid withChatType:chatType];
}

- (void)updateAppNotReadCount {
    [[QIMManager sharedInstance] updateAppNotReadCount];
}

- (NSInteger)getAppNotReaderCount {
    return [[QIMManager sharedInstance] getAppNotReaderCount];
}

- (NSInteger)getNotRemindNotReaderCount {
    return [[QIMManager sharedInstance] getNotRemindNotReaderCount];
}

- (void)getExploreNotReaderCount {
    [[QIMManager sharedInstance] getExploreNotReaderCount];
}

- (void)getLeaveMsgNotReaderCountWithCallBack:(QIMKitGetLeaveMsgNotReaderCountBlock)callback {
    [[QIMManager sharedInstance] getLeaveMsgNotReaderCountWithCallBack:callback];
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    [[QIMManager sharedInstance] updateNotReadCountCacheByJid:jid WithRealJid:realJid];
}

- (void)updateMessageStateWithNewState:(QIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList {
    [[QIMManager sharedInstance] updateMessageStateWithNewState:state ByMsgIdList:MsgIdList];
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid {
    [[QIMManager sharedInstance] updateNotReadCountCacheByJid:jid];
}

- (void)saveChatId:(NSString *)chatId ForUserId:(NSString *)userId {
    [[QIMManager sharedInstance] saveChatId:chatId ForUserId:userId];
}

- (void)setMsgSentFaild {
    [[QIMManager sharedInstance] setMsgSentFaild];
}

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw {
    return [[QIMManager sharedInstance] parseMessageByMsgRaw:msgRaw];
}

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw {
    return [[QIMManager sharedInstance] parseOriginMessageByMsgRaw:msgRaw];
}

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] getNotReadMsgIdListByUserId:userId WithRealJid:realJid];
}

- (void)getRemoteSearchMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid withVersion:(long long)lastUpdateTime withDirection:(QIMGetMsgDirection)direction WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getRemoteSearchMsgListByUserId:userId WithRealJid:realJid withVersion:lastUpdateTime withDirection:direction WithLimit:limit WithOffset:offset WithComplete:complete];
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete{
    [[QIMManager sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getMsgListByUserId:userId WithRealJid:realJid FromTimeStamp:timeStamp WithComplete:complete];
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getConsultServerMsgLisByUserId:userId WithVirtualId:virtualId WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord XmppId:(NSString *)xmppid RealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] searchLocalMessageByKeyword:keyWord XmppId:xmppid RealJid:realJid];
}


#pragma mark - 本地消息搜索

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] getLocalMediasByXmppId:xmppId ByRealJid:realJid];
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] getMsgsForMsgType:msgTypes ByXmppId:xmppId ByReadJid:realJid];
}

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] getMsgsByKeyWord:keyWork ByXmppId:xmppId ByReadJid:realJid];
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getMsgsForMsgType:msgTypes ByXmppId:xmppId];
}

@end
