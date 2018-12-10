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

- (Message *)getMsgByMsgId:(NSString *)msgId {
    return [[QIMManager sharedInstance] getMsgByMsgId:msgId];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [[QIMManager sharedInstance] checkMsgTimeWithJid:jid WithRealJid:realJid WithMsgDate:msgDate WithGroup:flag];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [[QIMManager sharedInstance] checkMsgTimeWithJid:jid WithMsgDate:msgDate WithGroup:flag];
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

- (void)saveMsg:(Message *)msg ByJid:(NSString *)sid {
    [[QIMManager sharedInstance] saveMsg:msg ByJid:sid];
}

- (void)updateMsg:(Message *)msg ByJid:(NSString *)sid {
    [[QIMManager sharedInstance] updateMsg:msg ByJid:sid];
}

- (void)deleteMsg:(Message *)msg ByJid:(NSString *)sid {
    [[QIMManager sharedInstance] deleteMsg:msg ByJid:sid];
}

- (BOOL)sendControlStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] sendControlStateWithMessagesIdArray:messages WithXmppId:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] sendReadStateWithMessagesIdArray:messages WithXmppId:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] sendReadStateWithMessagesIdArray:messages WithXmppId:xmppId WithRealJid:realJid];
}

- (BOOL)sendReadstateWithGroupLastMessageTime:(long long) lastTime withGroupId:(NSString *) groupId {
   return [[QIMManager sharedInstance] sendReadstateWithGroupLastMessageTime:lastTime withGroupId:groupId];
}

- (Message *)sendShockToUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] sendShockToUserId:userId];
}

- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] revokeMessageWithMessageId:messageId message:message ToJid:jid];
}

- (void)sendFileJson:(NSString *)fileJson ToUserId:(NSString *)userId WithMsgId:(NSString *)msgId {
    [[QIMManager sharedInstance] sendFileJson:fileJson ToUserId:userId WithMsgId:msgId];
}

- (Message *)sendVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] sendVoiceUrl:voiceUrl withVoiceName:voiceName withSeconds:seconds ToUserId:userId];
}

- (Message *)sendMessage:(Message *)msg ToUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] sendMessage:msg ToUserId:userId];
}

- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WihtMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendMessage:msg WithInfo:info ToUserId:userId WihtMsgType:msgType];
}

- (Message *)createNoteReplyMessage:(NSString *)msg ToUserId:(NSString *)user {
    return [[QIMManager sharedInstance] createNoteReplyMessage:msg ToUserId:user];
}

- (Message *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] sendMessage:msg ToGroupId:groupId];
}

- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WihtMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendMessage:msg WithInfo:info ToGroupId:groupId WihtMsgType:msgType];
}

- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WihtMsgType:(int)msgType WithMsgId:(NSString *)msgId {
    return [[QIMManager sharedInstance] sendMessage:msg WithInfo:info ToGroupId:groupId WihtMsgType:msgType WithMsgId:msgId];
}

- (Message *)sendGroupShockToGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] sendGroupShockToGroupId:groupId];
}

- (BOOL)sendReplyMessageId:(NSString *)replyMsgId WithReplyUser:(NSString *)replyUser WithMessageId:(NSString *)msgId WithMessage:(NSString *)message ToGroupId:(NSString *)groupId {
   return [[QIMManager sharedInstance] sendReplyMessageId:replyMsgId WithReplyUser:replyUser WithMessageId:msgId WithMessage:message ToGroupId:groupId];
}

- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] revokeGroupMessageWithMessageId:messageId message:message ToJid:jid];
}

- (void)sendFileJson:(NSString *)fileJson ToGroupId:(NSString *)groupId WihtMsgId:(NSString *)msgId {
    [[QIMManager sharedInstance] sendFileJson:fileJson ToGroupId:groupId WihtMsgId:msgId];
}

- (Message *)sendGroupVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToGroupId:(NSString *)groupId {
   return [[QIMManager sharedInstance] sendGroupVoiceUrl:voiceUrl withVoiceName:voiceName withSeconds:seconds ToGroupId:groupId];
}

- (Message *)createNoteReplyMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] createNoteReplyMessage:msg ToGroupId:groupId];
}

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    [[QIMManager sharedInstance] sendWlanMessage:content to:targetID extendInfo:extendInfo msgType:msgType completionHandler:completionHandler];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}
- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(MessageState)msgState willSave:(BOOL)willSave {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:realJid userType:userType msgType:msgType forMsgId:mId msgState:msgState willSave:willSave];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:realJid userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}

- (Message *)sendMessage:(Message *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson {
    return [[QIMManager sharedInstance] sendMessage:msg withChatType:chatType channelInfo:channelInfo realFrom:realFrom realTo:realTo ochatJson:ochatJson];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType backinfo:backInfo];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId {
    return [[QIMManager sharedInstance] createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId];
}

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid {
    [[QIMManager sharedInstance] synchronizeChatSessionWithUserId:userId WithChatType:chatType WithRealJid:realJid];
}

#pragma mark - 位置共享

- (Message *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WihtMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendShareLocationMessage:msg WithInfo:info ToJid:jid WihtMsgType:msgType];
}

- (Message *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId {
    return [[QIMManager sharedInstance] beginShareLocationToUserId:userId WithShareLocationId:shareLocationId];
}

- (Message *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId {
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

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(MessageState)state{
    [[QIMManager sharedInstance] updateMsgReadCompensateSetWithMsgId:msgId WithAddFlag:flag WithState:state];
}

- (NSMutableSet *)getLastMsgCompensateReadSet {
    return [[QIMManager sharedInstance] getLastMsgCompensateReadSet];
}

- (NSArray *)getNotReaderMsgList {
    return [[QIMManager sharedInstance] getNotReaderMsgList];
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

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid {
    return [[QIMManager sharedInstance] getNotReadMsgCountByJid:jid];
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] getNotReadMsgCountByJid:jid WithRealJid:realJid];
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

- (NSInteger)getLeaveMsgNotReaderCount {
    return [[QIMManager sharedInstance] getLeaveMsgNotReaderCount];
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    [[QIMManager sharedInstance] updateNotReadCountCacheByJid:jid WithRealJid:realJid];
}

- (void)updateMessageStateWithNewState:(MessageState)state ByMsgIdList:(NSArray *)MsgIdList {
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

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WihtLimit:(int)limit WithOffset:(int)offset WihtComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getMsgListByUserId:userId WithRealJid:realJid WihtLimit:limit WithOffset:offset WihtComplete:complete];
}

- (void)getMsgListByUserId:(NSString *)userId FromTimeStamp:(long long)timeStamp WihtComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getMsgListByUserId:userId FromTimeStamp:timeStamp WihtComplete:complete];
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WihtComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getMsgListByUserId:userId WithRealJid:realJid FromTimeStamp:timeStamp WihtComplete:complete];
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getConsultServerMsgLisByUserId:userId WithVirtualId:virtualId WithLimit:limit WithOffset:offset WithComplete:complete];
}

- (NSArray *)getFSMsgByXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getFSMsgByXmppId:xmppId];
}

- (NSDictionary *)getFSMsgByMsgId:(NSString *)msgId {
    return [[QIMManager sharedInstance] getFSMsgByMsgId:msgId];
}

- (void)checkOfflineMsg {
    [[QIMManager sharedInstance] checkOfflineMsg];
}

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord XmppId:(NSString *)xmppid RealJid:(NSString *)realJid {
    return [[QIMManager sharedInstance] searchLocalMessageByKeyword:keyWord XmppId:xmppid RealJid:realJid];
}

@end
