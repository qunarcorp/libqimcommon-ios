//
//  STIMKit+STIMMessage.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMMessage.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMMessage)

- (NSArray *)getMsgsForMsgType:(STIMMessageType)msgType {
    return [[STIMManager sharedInstance] getMsgsForMsgType:msgType];
}

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId {
    return [[STIMManager sharedInstance] getMsgDictByMsgId:msgId];
}

- (STIMMessageModel *)getMsgByMsgId:(NSString *)msgId {
    return [[STIMManager sharedInstance] getMsgByMsgId:msgId];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [[STIMManager sharedInstance] checkMsgTimeWithJid:jid WithRealJid:realJid WithMsgDate:msgDate WithGroup:flag];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [[STIMManager sharedInstance] checkMsgTimeWithJid:jid WithMsgDate:msgDate WithGroup:flag];
}

- (void)setAppendInfo:(NSDictionary *)appendInfoDict ForUserId:(NSString *)userId {
    [[STIMManager sharedInstance] setAppendInfo:appendInfoDict ForUserId:userId];
}

- (NSDictionary *)getAppendInfoForUserId:(NSString *)userId {
   return [[STIMManager sharedInstance] getAppendInfoForUserId:userId];
}

- (void)setChannelInfo:(NSString *)channelId ForUserId:(NSString *)userId {
    [[STIMManager sharedInstance] setChannelInfo:channelId ForUserId:userId];
}

- (NSString *)getChancelInfoForUserId:(NSString *)userId {
   return [[STIMManager sharedInstance] getChancelInfoForUserId:userId];
}

- (void)setConversationParam:(NSDictionary *)param WithJid:(NSString *)jid {
    [[STIMManager sharedInstance] setConversationParam:param WithJid:jid];
}

- (NSDictionary *)conversationParamWithJid:(NSString *)jid {
    return [[STIMManager sharedInstance] conversationParamWithJid:jid];
}

- (void)sendTypingToUserId:(NSString *)userId {
    [[STIMManager sharedInstance] sendTypingToUserId:userId];
}

- (void)saveMsg:(STIMMessageModel *)msg ByJid:(NSString *)sid {
    [[STIMManager sharedInstance] saveMsg:msg ByJid:sid];
}

- (void)updateMsg:(STIMMessageModel *)msg ByJid:(NSString *)sid {
    [[STIMManager sharedInstance] updateMsg:msg ByJid:sid];
}

- (void)deleteMsg:(STIMMessageModel *)msg ByJid:(NSString *)sid {
    [[STIMManager sharedInstance] deleteMsg:msg ByJid:sid];
}

- (BOOL)sendControlStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId {
    return [[STIMManager sharedInstance] sendControlStateWithMessagesIdArray:messages WithXmppId:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(STIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId {
    return [[STIMManager sharedInstance] sendReadStateWithMessagesIdArray:messages WithMessageReadFlag:msgReadFlag WithXmppId:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(STIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] sendReadStateWithMessagesIdArray:messages WithMessageReadFlag:msgReadFlag WithXmppId:xmppId WithRealJid:realJid];
}

- (BOOL)sendReadstateWithGroupLastMessageTime:(long long) lastTime withGroupId:(NSString *) groupId {
    return [[STIMManager sharedInstance] sendReadstateWithGroupLastMessageTime:lastTime withGroupId:groupId];
}

- (STIMMessageModel *)sendShockToUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] sendShockToUserId:userId];
}

- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[STIMManager sharedInstance] revokeMessageWithMessageId:messageId message:message ToJid:jid];
}

- (void)revokeConsultMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(int)chatType{
    [[STIMManager sharedInstance] revokeConsultMessageWithMessageId:messageId message:message ToJid:jid realToJid:realToJid chatType:chatType];
}

- (STIMMessageModel *)sendVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] sendVoiceUrl:voiceUrl withVoiceName:voiceName withSeconds:seconds ToUserId:userId];
}

- (STIMMessageModel *)sendMessage:(STIMMessageModel *)msg ToUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] sendMessage:msg ToUserId:userId];
}

- (STIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WithMsgType:(int)msgType {
    return [[STIMManager sharedInstance] sendMessage:msg WithInfo:info ToUserId:userId WithMsgType:msgType];
}

- (STIMMessageModel *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] sendMessage:msg ToGroupId:groupId];
}

- (STIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType {
    return [[STIMManager sharedInstance] sendMessage:msg WithInfo:info ToGroupId:groupId WithMsgType:msgType];
}

- (STIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType WithMsgId:(NSString *)msgId {
    return [[STIMManager sharedInstance] sendMessage:msg WithInfo:info ToGroupId:groupId WithMsgType:msgType WithMsgId:msgId];
}

- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[STIMManager sharedInstance] revokeGroupMessageWithMessageId:messageId message:message ToJid:jid];
}

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid {
    [[STIMManager sharedInstance] sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    [[STIMManager sharedInstance] sendWlanMessage:content to:targetID extendInfo:extendInfo msgType:msgType completionHandler:completionHandler];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [[STIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}
- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId msgState:(STIMMessageSendState)msgState willSave:(BOOL)willSave {
    return [[STIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:realJid userType:userType msgType:msgType forMsgId:mId msgState:msgState willSave:willSave];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [[STIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:realJid userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}

- (STIMMessageModel *)sendMessage:(STIMMessageModel *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson {
    return [[STIMManager sharedInstance] sendMessage:msg withChatType:chatType channelInfo:channelInfo realFrom:realFrom realTo:realTo ochatJson:ochatJson];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType {
    return [[STIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType backinfo:(NSString *)backInfo {
    return [[STIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType backinfo:backInfo];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId {
    return [[STIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId];
}

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid {
    [[STIMManager sharedInstance] synchronizeChatSessionWithUserId:userId WithChatType:chatType WithRealJid:realJid];
}

#pragma mark - 位置共享

- (STIMMessageModel *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WithMsgType:(int)msgType {
    return [[STIMManager sharedInstance] sendShareLocationMessage:msg WithInfo:info ToJid:jid WithMsgType:msgType];
}

- (STIMMessageModel *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] beginShareLocationToUserId:userId WithShareLocationId:shareLocationId];
}

- (STIMMessageModel *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] beginShareLocationToGroupId:GroupId WithShareLocationId:shareLocationId];
}

- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] joinShareLocationToUsers:users WithShareLocationId:shareLocationId];
}

- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] sendMyLocationToUsers:users WithLocationInfo:locationInfo ByShareLocationId:shareLocationId];
}

- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] quitShareLocationToUsers:users WithShareLocationId:shareLocationId];
}

- (NSString *)getShareLocationIdByJid:(NSString *)jid {
    return [[STIMManager sharedInstance] getShareLocationIdByJid:jid];
}

- (NSString *)getShareLocationFromIdByShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] getShareLocationFromIdByShareLocationId:shareLocationId];
}

- (NSArray *)getShareLocationUsersByShareLocationId:(NSString *)shareLocationId {
    return [[STIMManager sharedInstance] getShareLocationUsersByShareLocationId:shareLocationId];
}


#pragma mark - 未读数

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(STIMMessageSendState)state{
    [[STIMManager sharedInstance] updateMsgReadCompensateSetWithMsgId:msgId WithAddFlag:flag WithState:state];
}

- (NSMutableSet *)getLastMsgCompensateReadSet {
    return [[STIMManager sharedInstance] getLastMsgCompensateReadSet];
}

- (void)clearAllNoRead {
    [[STIMManager sharedInstance] clearAllNoRead];
}

- (void)clearSystemMsgNotReadWithJid:(NSString *)jid {
    [[STIMManager sharedInstance] clearSystemMsgNotReadWithJid:jid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid {
    [[STIMManager sharedInstance] clearNotReadMsgByJid:jid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid {
    [[STIMManager sharedInstance] clearNotReadMsgByJid:jid ByRealJid:realJid];
}

- (void)clearNotReadMsgByGroupId:(NSString *)groupId {
    [[STIMManager sharedInstance] clearNotReadMsgByGroupId:groupId];
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] getNotReadMsgCountByJid:jid WithRealJid:realJid];
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    return [[STIMManager sharedInstance] getNotReadMsgCountByJid:jid WithRealJid:realJid withChatType:chatType];
}

- (void)updateAppNotReadCount {
    [[STIMManager sharedInstance] updateAppNotReadCount];
}

- (NSInteger)getAppNotReaderCount {
    return [[STIMManager sharedInstance] getAppNotReaderCount];
}

- (NSInteger)getNotRemindNotReaderCount {
    return [[STIMManager sharedInstance] getNotRemindNotReaderCount];
}

- (void)getExploreNotReaderCount {
    [[STIMManager sharedInstance] getExploreNotReaderCount];
}

- (NSInteger)getLeaveMsgNotReaderCount {
    return [[STIMManager sharedInstance] getLeaveMsgNotReaderCount];
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    [[STIMManager sharedInstance] updateNotReadCountCacheByJid:jid WithRealJid:realJid];
}

- (void)updateMessageStateWithNewState:(STIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList {
    [[STIMManager sharedInstance] updateMessageStateWithNewState:state ByMsgIdList:MsgIdList];
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid {
    [[STIMManager sharedInstance] updateNotReadCountCacheByJid:jid];
}

- (void)saveChatId:(NSString *)chatId ForUserId:(NSString *)userId {
    [[STIMManager sharedInstance] saveChatId:chatId ForUserId:userId];
}

- (void)setMsgSentFaild {
    [[STIMManager sharedInstance] setMsgSentFaild];
}

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw {
    return [[STIMManager sharedInstance] parseMessageByMsgRaw:msgRaw];
}

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw {
    return [[STIMManager sharedInstance] parseOriginMessageByMsgRaw:msgRaw];
}

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] getNotReadMsgIdListByUserId:userId WithRealJid:realJid];
}

- (void)getRemoteSearchMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid withVersion:(long long)lastUpdateTime withDirection:(STIMGetMsgDirection)direction WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getRemoteSearchMsgListByUserId:userId WithRealJid:realJid withVersion:lastUpdateTime withDirection:direction WithLimit:limit WithOffset:offset WithComplete:complete];
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete{
    [[STIMManager sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getMsgListByUserId:userId WithRealJid:realJid FromTimeStamp:timeStamp WithComplete:complete];
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getConsultServerMsgLisByUserId:userId WithVirtualId:virtualId WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord XmppId:(NSString *)xmppid RealJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] searchLocalMessageByKeyword:keyWord XmppId:xmppid RealJid:realJid];
}


#pragma mark - 本地消息搜索

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] getLocalMediasByXmppId:xmppId ByRealJid:realJid];
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] getMsgsForMsgType:msgTypes ByXmppId:xmppId ByReadJid:realJid];
}

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    return [[STIMManager sharedInstance] getMsgsByKeyWord:keyWork ByXmppId:xmppId ByReadJid:realJid];
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId {
    return [[STIMManager sharedInstance] getMsgsForMsgType:msgTypes ByXmppId:xmppId];
}

@end
