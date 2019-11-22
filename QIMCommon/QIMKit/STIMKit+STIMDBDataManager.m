//
//  STIMKit+STIMDBDataManager.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMDBDataManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMDBDataManager)

+ (void) sharedInstanceWithDBPath:(NSString *)dbPath {
//    [IMDataManager stIMDB_sharedInstanceWithDBPath:dbPath];
}

- (void)setDomain:(NSString*)domain {
//    [[IMDataManager stIMDB_SharedInstance] setDomain:domain];
}

- (void)clearUserDescInfo {
//    [[IMDataManager stIMDB_SharedInstance] clearUserDescInfo];
}

- (NSString *)getTimeSmtapMsgIdForDate:(NSDate *)date WithUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getTimeSmtapMsgIdForDate:date WithUserId:userId];
}

// 群
- (NSInteger)getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getRNSearchEjabHost2GroupChatListByKeyStr:keyStr];
}

- (NSArray *)rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_rnSearchEjabHost2GroupChatListByKeyStr:keyStr limit:limit offset:offset];
}

- (BOOL)checkGroup:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkGroup:groupId];
}

- (void)insertGroup:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertGroup:groupId];
}

- (void)bulkinsertGroups:(NSArray *) groups {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertGroups:groups];
}

- (void) removeAllMessages {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_removeAllMessages];
}

- (void)clearGroupCardVersion {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_clearGroupCardVersion];
}

- (NSArray *)getGroupIdList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupIdList];
}

- (NSArray *)stIMDB_getGroupList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupList];
}

- (NSInteger)getLocalGroupTotalCountByUserIds:(NSArray *)userIds {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getLocalGroupTotalCountByUserIds:userIds];
}

- (NSArray *)searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_searchGroupByUserIds:userIds WithLimit:limit WithOffset:offset];
}

- (NSArray *)getGroupListMaxLastUpdateTime {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupListMaxLastUpdateTime];
}

- (NSArray *)getGroupListMsgMaxTime {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupListMsgMaxTime];
}

- (void)bulkUpdateGroupCards:(NSArray *)array {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateGroupCards:array];
}

- (void)updateGroup:(NSString *)groupId
       WithNickName:(NSString *)nickName
          WithTopic:(NSString *)topic
           WithDesc:(NSString *)desc
      WithHeaderSrc:(NSString *)headerSrc
        WithVersion:(NSString *)version {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroup:groupId
                                  WithNickName:nickName
                                     WithTopic:topic
                                      WithDesc:desc
                                 WithHeaderSrc:headerSrc
                                   WithVersion:version];
}

- (void)updateGroup:(NSString *)groupId WithNickName:(NSString *)nickName {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroup:groupId WithNickName:nickName];
}

- (void)updateGroup:(NSString *)groupId WithTopic:(NSString *)topic {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroup:groupId WithTopic:topic];
}

- (void)updateGroup:(NSString *)groupId WithDesc:(NSString *)desc {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroup:groupId WithDesc:desc];
}

- (void)updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroup:groupId WithHeaderSrc:headerSrc];
}

- (BOOL)needUpdateGroupImage:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_needUpdateGroupImage:groupId];
}

- (NSString *)getGroupHeaderSrc:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupHeaderSrc:groupId];
}

- (void)deleteGroup:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroup:groupId];
}

- (NSDictionary *)getGroupMemberInfoByNickName:(NSString *)nickName {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMemberInfoByNickName:nickName];
}

- (NSDictionary *)getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMemberInfoByJid:jid WithGroupId:groupId];
}

- (BOOL)checkGroupMember:(NSString *)nickName WithGroupId:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkGroupMember:nickName WithGroupId:groupId];
}

- (void)insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertGroupMember:memberDic WithGroupId:groupId];
}

- (void)bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertGroupMember:members WithGroupId:groupId];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getQChatGroupMember:groupId];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getQChatGroupMember:groupId BySearchStr:searchStr];
}

- (NSArray *)stIMDB_getGroupMember:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMember:groupId];
}

- (NSArray *)stIMDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMember:groupId BySearchStr:searchStr];
}

- (NSArray *)stIMDB_getGroupMember:(NSString *)groupId WithGroupIdentity:(NSInteger)identity {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMember:groupId WithGroupIdentity:identity];
}

- (NSDictionary *)getGroupOwnerInfoForGroupId:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupOwnerInfoForGroupId:groupId];
}

- (void)deleteGroupMemberWithGroupId:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroupMemberWithGroupId:groupId];
}

- (void)deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroupMemberJid:memberJid WithGroupId:groupId];
}

- (void)deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroupMember:nickname WithGroupId:groupId];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId chatType:(int)chatType {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getChatSessionWithUserId:userId chatType:chatType];
}

- (long long)getMinMsgTimeStampByXmppId:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:xmppId];
}

- (long long)getMaxMsgTimeStampByXmppId:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMaxMsgTimeStampByXmppId:xmppId];
}

- (long long) lastestGroupMessageTime {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_lastestGroupMessageTime];
}

- (void)bulkInsertUserInfosNotSaveDescInfo:(NSArray *)userInfos {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertUserInfosNotSaveDescInfo:userInfos];
}

- (void)clearUserListForList:(NSArray *)userInfos {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_clearUserListForList:userInfos];
}

- (void)bulkInsertUserInfos:(NSArray *)userInfos {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertUserInfos:userInfos];
}

- (void)InsertOrUpdateUserInfos:(NSArray *)userInfos {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_InsertOrUpdateUserInfos:userInfos];
}

- (NSDictionary *)selectUserBackInfoByXmppId:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserBackInfoByXmppId:xmppId];
}

- (NSDictionary *)selectUserByID:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserByID:userId];
}

- (NSDictionary *)selectUserByJID:(NSString *)jid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserByJID:jid];
}

- (NSDictionary *)selectUserByIndex:(NSString *)index {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserByIndex:index];
}

- (NSArray *)selectXmppIdList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectXmppIdList];
}

- (NSArray *)selectUserIdList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserIdList];
}

- (NSArray *)getOrganUserList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getOrganUserList];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListBySearchStr:searchStr];
}

- (NSInteger)selectUserListTotalCountBySearchStr:(NSString *)searchStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListTotalCountBySearchStr:searchStr];
}

- (NSArray *)selectUserListExMySelfBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListExMySelfBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr inGroup:(NSString *) groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)selectUserListByUserIds:(NSArray *)userIds {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListByUserIds:userIds];
}

- (NSDictionary *)selectUsersDicByXmppIds:(NSArray *)xmppIds {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUsersDicByXmppIds:xmppIds];
}

- (void)bulkUpdateUserSearchIndexs:(NSArray *)searchIndexs {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateUserSearchIndexs:searchIndexs];
}

- (void)updateUser:(NSString *)userId WithMood:(NSString *)mood WithHeaderSrc:(NSString *)headerSrc WithVersion:(NSString *)version{
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateUser:userId WithMood:mood WithHeaderSrc:headerSrc WithVersion:version];
}

- (void)bulkUpdateUserCardsV2:(NSArray *)cards {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateUserCards:cards];
}

- (void)bulkUpdateUserBackInfo:(NSDictionary *)userBackInfo WithXmppId:(NSString *)xmppId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateUserBackInfo:userBackInfo WithXmppId:xmppId];
}

- (NSString *)getUserHeaderSrcByUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserHeaderSrcByUserId:userId];
}

- (BOOL)checkExitsUser {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkExitsUser];
}

- (void)updateMessageWithExtendInfo:(NSString *)extendInfo ForMsgId:(NSString *)msgId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithExtendInfo:extendInfo ForMsgId:msgId];
}

- (void)deleteMessageWithXmppId:(NSString *)xmppId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteMessageWithXmppId:xmppId];
}

- (void)deleteMessageByMessageId:(NSString *)messageId ByJid:(NSString *)sid {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteMessageByMessageId:messageId ByJid:sid];
}

- (void)updateMessageWithMsgId:(NSString *)msgId
                    WithMsgRaw:(NSString *)msgRaw {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msgId
                                               WithMsgRaw:msgRaw];
}

- (void)updateMessageWithMsgId:(NSString *)msgId
                 WithSessionId:(NSString *)sessionId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WithMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  ExtendedFlag:(int)ExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msgId
                                            WithSessionId:sessionId
                                                 WithFrom:from
                                                   WithTo:to
                                              WithContent:content
                                             WithPlatform:platform
                                              WithMsgType:msgType
                                             WithMsgState:msgState
                                         WithMsgDirection:msgDirection
                                              WithMsgDate:msgDate
                                            WithReadedTag:readedTag
                                             ExtendedFlag:ExtendedFlag];
}

- (void)updateMessageWithMsgId:(NSString *)msgId
                 WithSessionId:(NSString *)sessionId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WithMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  ExtendedFlag:(int)ExtendedFlag
                    WithMsgRaw:(NSString *)msgRaw {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msgId
                                            WithSessionId:sessionId
                                                 WithFrom:from
                                                   WithTo:to
                                              WithContent:content
                                            WithExtendInfo:extendInfo
                                             WithPlatform:platform
                                              WithMsgType:msgType
                                             WithMsgState:msgState
                                         WithMsgDirection:msgDirection
                                              WithMsgDate:msgDate
                                            WithReadedTag:readedTag
                                             ExtendedFlag:ExtendedFlag
                                               WithMsgRaw:msgRaw];
}

- (void)revokeMessageByMsgId:(NSString *)msgId
                 WithContent:(NSString *)content
                 WithMsgType:(int)msgType {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_revokeMessageByMsgId:msgId
                                            WithContent:content
                                            WithMsgType:msgType];
}

- (BOOL)stIMDB_checkMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkMsgId:msgId];
}
//
//- (NSArray *)bulkInsertIphoneMucJSONMsg:(NSArray *)list WithMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WithMyRtxId:(NSString *)rtxId {
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertIphoneMucJSONMsg:list
//                                                       WithMyNickName:myNickName
//                                                        WithReadMarkT:readMarkT
//                                                     WithDidReadState:didReadState
//                                                          WithMyRtxId:rtxId];
//
//}

- (NSArray *)bulkInsertIphoneHistoryGroupMsg:(NSArray *)list WithXmppId:(NSString *)xmppId WithMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WithMyRtxId:(NSString *)rtxId {
    return nil;
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertIphoneHistoryGroupMsg:list WithXmppId:xmppId WithMyNickName:myNickName WithReadMarkT:readMarkT WithDidReadState:didReadState WithMyRtxId:rtxId];
}

- (NSArray *)bulkInsertHistoryGroupMsg:(NSArray *)list WithXmppId:(NSString *)xmppId WithMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState {
    return nil;
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertHistoryGroupMsg:list WithXmppId:xmppId WithMyNickName:myNickName WithReadMarkT:readMarkT WithDidReadState:didReadState];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    return [[IMDataManager stIMDB_SharedInstance] dictionaryWithJsonString:jsonString];
}

//- (NSMutableDictionary *)bulkInsertHistoryChatJSONMsg:(NSArray *)list {
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertHistoryChatJSONMsg:list];
//}

- (NSString *)getC2BMessageFeedBackWithMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getC2BMessageFeedBackWithMsgId:msgId];
}

- (NSArray *)stIMDB_bulkInsertPageHistoryChatJSONMsg:(NSArray *)list
                                         WithXmppId:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertPageHistoryChatJSONMsg:list
                                                                             WithXmppId:xmppId];
}

- (void)bulkInsertMessage:(NSArray *)msgList WithSessionId:(NSString *)sessionId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertMessage:msgList WithSessionId:sessionId];
}

- (void)updateMsgState:(int)msgState WithMsgId:(NSString *)msgId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMsgState:msgState WithMsgId:msgId];
}

- (void)updateMessageReadStateWithMsgId:(NSString *)msgId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageReadStateWithMsgId:msgId];
}

- (void)bulkUpdateMessageReadStateWithMsg:(NSArray *)msgs {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateMessageReadStateWithMsg:msgs];
}

- (void)updateMessageReadStateWithSessionId:(NSString *)sessionId {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageReadStateWithSessionId:sessionId];
}

- (void)updateSessionLastMsgIdWithSessionId:(NSString *)sessionId
                              WithLastMsgId:(NSString *)lastMsgId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateSessionLastMsgIdWithSessionId:sessionId
                                                         WithLastMsgId:lastMsgId];
}

- (void)insertSessionWithSessionId:(NSString *)sessinId
                        WithUserId:(NSString *)userId
                     WithLastMsgId:(NSString *)lastMsgId
                WithLastUpdateTime:(long long)lastUpdateTime
                          ChatType:(int)ChatType
                       WithRealJid:(id)realJid {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertSessionWithSessionId:sessinId
                                                   WithUserId:userId
                                                WithLastMsgId:lastMsgId
                                           WithLastUpdateTime:lastUpdateTime
                                                     ChatType:ChatType
                                                  WithRealJid:realJid];
}

- (void)deleteSession:(NSString *)xmppId RealJid:(NSString *)realJid {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSession:xmppId RealJid:realJid];
}

- (void)deleteSession:(NSString *)xmppId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSession:xmppId];
}

- (NSDictionary *)getLastedSingleChatSession {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getLastedSingleChatSession];
}

- (NSDictionary *)qimDb_getPublicNumberSession {
    return nil;
//    return [[IMDataManager stIMDB_SharedInstance] qimDb_getPublicNumberSession];
}

- (NSArray *)stIMDB_getSessionListWithSingleChatType:(int)chatType {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getSessionListWithSingleChatType:chatType];
}

- (NSArray *)getSessionListXMPPIDWithSingleChatType:(int)singleChatType {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getSessionListXMPPIDWithSingleChatType:singleChatType];
}

- (NSArray *)stIMDB_getNotReadMsgListForUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReadMsgListForUserId:userId];
}

- (NSArray *)stIMDB_getNotReadMsgListForUserId:(NSString *)userId ForRealJid:(NSString *)realJid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReadMsgListForUserId:userId ForRealJid:realJid];
}

- (long long)getReadedTimeStampForUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithMsgDirection:(int)msgDirection withUnReadCount:(NSInteger)unReadCount {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getReadedTimeStampForUserId:userId WithRealJid:realJid WithMsgDirection:msgDirection withUnReadCount:unReadCount];
}

- (NSArray *)stIMDB_getMgsListBySessionId:(NSString *)sesId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMgsListBySessionId:sesId];
}

- (NSArray *)stIMDB_getMgsListBySessionId:(NSString *)sesId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMgsListBySessionId:sesId WithRealJid:realJid WithLimit:limit WithOffset:offset];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgListByXmppId:xmppId WithRealJid:realJid FromTimeStamp:timeStamp];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId FromTimeStamp:(long long)timeStamp {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgListByXmppId:xmppId FromTimeStamp:timeStamp];
}

- (NSDictionary *)getMsgsByMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgsByMsgId:msgId];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getChatSessionWithUserId:userId];
}

- (void)updateMessageFromState:(int)fState ToState:(int)tState {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageFromState:fState ToState:tState];
}

- (NSInteger)getMessageStateWithMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMessageStateWithMsgId:msgId];
}

- (NSInteger)getReadStateWithMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getReadStateWithMsgId:msgId];
}

- (NSArray *)getMsgIdsForDirection:(int)msgDirection WithMsgState:(int)msgState {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgIdsForDirection:msgDirection WithMsgState:msgState];
}

- (NSArray *)searchMsgHistoryWithKey:(NSString *)key {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_searchMsgHistoryWithKey:key];
}

- (NSArray *)searchMsgIdWithKey:(NSString *)key ByXmppId:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_searchMsgIdWithKey:key ByXmppId:xmppId];
}

#pragma mark - 消息数据方法

- (long long) lastestMessageTime {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_lastestMessageTime];
}

- (long long) lastestSystemMessageTime {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_lastestSystemMessageTime];
}

- (NSString *) getLastMsgIdByJid:(NSString *)jid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getLastMsgIdByJid:jid];
}

/****************** FriendSter Msg *******************/
- (void)insertFSMsgWithMsgId:(NSString *)msgId
                  WithXmppId:(NSString *)xmppId
                WithFromUser:(NSString *)fromUser
              WithReplyMsgId:(NSString *)replyMsgId
               WithReplyUser:(NSString *)replyUser
                 WithContent:(NSString *)content
                 WithMsgDate:(long long)msgDate
            WithExtendedFlag:(NSData *)etxtenedFlag {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertFSMsgWithMsgId:msgId
//                                             WithXmppId:xmppId
//                                           WithFromUser:fromUser
//                                         WithReplyMsgId:replyMsgId
//                                          WithReplyUser:replyUser
//                                            WithContent:content
//                                            WithMsgDate:msgDate
//                                       WithExtendedFlag:etxtenedFlag];
}

- (void)bulkInsertFSMsgWithMsgList:(NSArray *)msgList {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertFSMsgWithMsgList:msgList];
}

- (NSArray *)getFSMsgListByXmppId:(NSString *)xmppId {
    return nil;
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getFSMsgListByXmppId:xmppId];
}

- (NSDictionary *)getFSMsgListByReplyMsgId:(NSString *)replyMsgId {
    return nil;
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getFSMsgListByReplyMsgId:replyMsgId];
}

/****************** readmark *********************/
- (long long)stIMDB_updateGroupMsgWithMsgState:(int)msgState ByGroupMsgList:(NSArray *)groupMsgList {
    return 0;
//    return [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroupMsgWithMsgState:msgState ByGroupMsgList:groupMsgList];
}

- (void)updateUserMsgWithMsgState:(int)msgState ByMsgList:(NSArray *)userMsgList {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateUserMsgWithMsgState:msgState ByMsgList:userMsgList];
}

- (void)clearHistoryMsg {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_clearHistoryMsg];
}

- (void)closeDataBase {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_closeDataBase];
}

+ (void)clearDataBaseCache {
//    [IMDataManager clearDataBaseCache];
}

- (void)stIMDB_dbCheckpoint {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_dbCheckpoint];
}

/*************** Friend List *************/
- (void)bulkInsertFriendList:(NSArray *)friendList {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertFriendList:friendList];
}
- (void)insertFriendWithUserId:(NSString *)userId
                    WithXmppId:(NSString *)xmppId
                      WithName:(NSString *)name
               WithSearchIndex:(NSString *)searchIndex
                  WithDescInfo:(NSString *)descInfo
                   WithHeadSrc:(NSString *)headerSrc
                  WithUserInfo:(NSData *)userInfo
            WithLastUpdateTime:(long long)lastUpdateTime
          WithIncrementVersion:(int)incrementVersion {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertFriendWithUserId:userId
                                               WithXmppId:xmppId
                                                 WithName:name
                                          WithSearchIndex:searchIndex
                                             WithDescInfo:descInfo
                                              WithHeadSrc:headerSrc
                                             WithUserInfo:userInfo
                                       WithLastUpdateTime:lastUpdateTime
                                     WithIncrementVersion:incrementVersion];
}

- (void)deleteFriendListWithXmppId:(NSString *)xmppId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteFriendListWithXmppId:xmppId];
}

- (void)deleteFriendListWithUserId:(NSString *)userId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteFriendListWithUserId:userId];
}

- (void)deleteFriendList {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteFriendList];
}
- (void)deleteSessionList {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSessionList];
}

- (NSMutableArray *)selectFriendList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectFriendList];
}

- (NSMutableArray *)stIMDB_selectFriendListInGroupId:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectFriendListInGroupId:groupId];
}

- (NSDictionary *)selectFriendInfoWithUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectFriendInfoWithUserId:userId];
}
- (NSDictionary *)selectFriendInfoWithXmppId:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectFriendInfoWithXmppId:xmppId];
}

- (void)bulkInsertFriendNotifyList:(NSArray *)notifyList {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertFriendNotifyList:notifyList];
}

- (void)insertFriendNotifyWithUserId:(NSString *)userId
                          WithXmppId:(NSString *)xmppId
                            WithName:(NSString *)name
                        WithDescInfo:(NSString *)descInfo
                         WithHeadSrc:(NSString *)headerSrc
                     WithSearchIndex:(NSString *)searchIndex
                        WithUserInfo:(NSString *)userInfo
                         WithVersion:(int)version
                           WithState:(int)state
                  WithLastUpdateTime:(long long)lastUpdateTime {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertFriendNotifyWithUserId:userId
                                                     WithXmppId:xmppId
                                                       WithName:name
                                                   WithDescInfo:descInfo
                                                    WithHeadSrc:headerSrc
                                                WithSearchIndex:searchIndex
                                                   WithUserInfo:userInfo
                                                    WithVersion:version
                                                      WithState:state
                                             WithLastUpdateTime:lastUpdateTime];
    
}
- (void)deleteFriendNotifyWithUserId:(NSString *)userId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteFriendNotifyWithUserId:userId];
}

- (NSMutableArray *)selectFriendNotifys {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectFriendNotifys];
}

- (void)updateFriendNotifyWithXmppId:(NSString *)xmppId WithState:(int)state {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateFriendNotifyWithXmppId:xmppId WithState:state];
}

- (void)updateFriendNotifyWithUserId:(NSString *)userId WithState:(int)state {
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateFriendNotifyWithUserId:userId WithState:state];
}

- (long long)getMaxTimeFriendNotify {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMaxTimeFriendNotify];
}

// ******************** 公众账号 ***************************** //
- (BOOL)checkPublicNumberMsgById:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkPublicNumberMsgById:msgId];
}

- (void)checkPublicNumbers:(NSArray *)publicNumberIds {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_checkPublicNumbers:publicNumberIds];
}

- (void)bulkInsertPublicNumbers:(NSArray *)publicNumberList {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertPublicNumbers:publicNumberList];
}

- (void)insertPublicNumberXmppId:(NSString *)xmppId
              WithPublicNumberId:(NSString *)publicNumberId
            WithPublicNumberType:(int)publicNumberType
                        WithName:(NSString *)name
                   WithHeaderSrc:(NSString *)headerSrc
                    WithDescInfo:(NSString *)descInfo
                 WithSearchIndex:(NSString *)searchIndex
                  WithPublicInfo:(NSString *)publicInfo
                     WithVersion:(int)version {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertPublicNumberXmppId:xmppId
                                         WithPublicNumberId:publicNumberId
                                       WithPublicNumberType:publicNumberType
                                                   WithName:name
                                              WithHeaderSrc:headerSrc
                                               WithDescInfo:descInfo
                                            WithSearchIndex:searchIndex
                                             WithPublicInfo:publicInfo
                                                WithVersion:version];
}

- (void)deletePublicNumberId:(NSString *)publicNumberId {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deletePublicNumberId:publicNumberId];
}

- (NSArray *)getPublicNumberVersionList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getPublicNumberVersionList];
}

- (NSArray *)getPublicNumberList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getPublicNumberList];
}

- (NSArray *)searchPublicNumberListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_searchPublicNumberListByKeyStr:keyStr];
}

- (NSInteger)getRnSearchPublicNumberListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getRnSearchPublicNumberListByKeyStr:keyStr];
}

- (NSArray *)rnSearchPublicNumberListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_rnSearchPublicNumberListByKeyStr:keyStr limit:limit offset:offset];
}

- (NSDictionary *)getPublicNumberCardByJId:(NSString *)jid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getPublicNumberCardByJId:jid];
}

- (void)insetPublicNumberMsgWithMsgId:(NSString *)msgId
                        WithSessionId:(NSString *)sessionId
                             WithFrom:(NSString *)from
                               WithTo:(NSString *)to
                          WithContent:(NSString *)content
                         WithPlatform:(int)platform
                          WithMsgType:(int)msgType
                         WithMsgState:(int)msgState
                     WithMsgDirection:(int)msgDirection
                          WithMsgDate:(long long)msgDate
                        WithReadedTag:(int)readedTag {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insetPublicNumberMsgWithMsgId:msgId
                                                   WithSessionId:sessionId
                                                        WithFrom:from
                                                          WithTo:to
                                                     WithContent:content
                                                    WithPlatform:platform
                                                     WithMsgType:msgType
                                                    WithMsgState:msgState
                                                WithMsgDirection:msgDirection
                                                     WithMsgDate:msgDate
                                                   WithReadedTag:readedTag];
}

- (NSArray *)getMsgListByPublicNumberId:(NSString *)publicNumberId
                              WithLimit:(int)limit
                             WithOffset:(int)offset
                         WithFilterType:(NSArray *)actionTypes {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgListByPublicNumberId:publicNumberId WithLimit:limit WithOffset:offset WithFilterType:actionTypes];
}

/****************** Collection Msg *******************/

- (NSArray *)getCollectionAccountList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionAccountList];
}

- (void)bulkinsertCollectionAccountList:(NSArray *)accounts {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertCollectionAccountList:accounts];
}


- (NSDictionary *)selectCollectionUserByJID:(NSString *)jid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectCollectionUserByJID:jid];
}

- (void)bulkInsertCollectionUserCards:(NSArray *)userCards {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertCollectionUserCards:userCards];
}

- (void)bulkInsertCollectionGroupCards:(NSArray *)groupCards {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertCollectionGroupCards:groupCards];
}

- (NSDictionary *)getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getLastCollectionMsgWithLastMsgId:lastMsgId];;
}

- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionSessionListWithBindId:bindId];
}

- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionMsgListWithBindId:bindId];
}

- (BOOL)checkCollectionMsgById:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkCollectionMsgById:msgId];
}

- (void)bulkInsertCollectionMsgWithMsgDics:(NSArray *)msgs {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertCollectionMsgWithMsgDics:msgs];
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionMsgNotReadCountByDidReadState:readState];
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionMsgNotReadCountByDidReadState:readState ForBindId:bindId];
}

- (NSInteger)getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:readState ForBindId:bindId originUserId:originUserId];
}

- (void)updateCollectionMsgNotReadStateByJid:(NSString *)jid WithReadtate:(NSInteger)readState {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateCollectionMsgNotReadStateByJid:jid WithReadtate:(NSInteger)readState];
//    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateCollectionMsgNotReadStateByJid:jid WithMsgState:msgState];
}

- (void)updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithReadState:(NSInteger)readState{
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateCollectionMsgNotReadStateForBindId:bindId originUserId:originUserId WithReadState:readState];

//    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateCollectionMsgNotReadStateForBindId:bindId originUserId:originUserId WithMsgState:msgState];
}

- (NSDictionary *)getCollectionMsgListForMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionMsgListForMsgId:msgId];
}

- (NSArray *)getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getCollectionMsgListWithUserId:userId originUserId:originUserId];
}

/*********************** Group Message State **************************/
- (long long)stIMDB_bulkUpdateGroupMessageReadFlag:(NSArray *)mucArray {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateGroupMessageReadFlag:mucArray];
}

/*********************** QTNotes **********************/

//Main

- (BOOL)checkExitsMainItemWithQid:(NSInteger)qid WithCId:(NSInteger)cid {
    return [[IMDataManager stIMDB_SharedInstance] checkExitsMainItemWithQid:qid WithCId:cid];
}

- (void)insertQTNotesMainItemWithQId:(NSInteger)qid
                             WithCid:(NSInteger)cid
                           WithQType:(NSInteger)qtype
                          WithQTitle:(NSString *)qtitle
                      WithQIntroduce:(NSString *)qIntroduce
                        WithQContent:(NSString *)qContent
                           WithQTime:(NSInteger)qTime
                          WithQState:(NSInteger)qstate
                   WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] insertQTNotesMainItemWithQId:qid
                                                        WithCid:cid
                                                      WithQType:qtype
                                                     WithQTitle:qtitle
                                                 WithQIntroduce:qIntroduce
                                                   WithQContent:qContent
                                                      WithQTime:qTime
                                                     WithQState:qstate
                                              WithQExtendedFlag:qExtendedFlag];
}

- (void)updateToMainWithQId:(NSInteger)qid
                    WithCid:(NSInteger)cid
                  WithQType:(NSInteger)qtype
                 WithQTitle:(NSString *)qtitle
              WithQDescInfo:(NSString *)qdescInfo
               WithQContent:(NSString *)qcontent
                  WithQTime:(NSInteger)qtime
                 WithQState:(NSInteger)qstate
          WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] updateToMainWithQId:qid WithCid:cid WithQType:qtype WithQTitle:qtitle WithQDescInfo:qdescInfo WithQContent:qcontent WithQTime:qtime WithQState:qstate WithQExtendedFlag:qExtendedFlag];
}

- (void)updateToMainItemWithDicts:(NSArray *)mainItemList {
    [[IMDataManager stIMDB_SharedInstance] updateToMainItemWithDicts:mainItemList];
}

- (void)deleteToMainWithQid:(NSInteger)qid {
    [[IMDataManager stIMDB_SharedInstance] deleteToMainWithQid:qid];
}

- (void)deleteToMainWithCid:(NSInteger)cid {
    [[IMDataManager stIMDB_SharedInstance] deleteToMainWithCid:cid];
}

- (void)updateToMainItemTimeWithQId:(NSInteger)qid
                          WithQTime:(NSInteger)qTime
                  WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] updateToMainItemTimeWithQId:qid WithQTime:qTime WithQExtendedFlag:qExtendedFlag];
}

- (void)updateMainStateWithQid:(NSInteger)qid
                       WithCid:(NSInteger)cid
                    WithQState:(NSInteger)qstate
             WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] updateMainStateWithQid:qid WithCid:cid WithQState:qstate WithQExtendedFlag:qExtendedFlag];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithQType:qType];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType QString:(NSString *)qString {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithQType:qType QString:qString];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithExceptQState:(NSInteger)qState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithQType:qType WithExceptQState:qState];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithQState:(NSInteger)qState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithQType:qType WithQState:qState];
}

- (NSArray *)getQTNoteMainItemWithQType:(NSInteger)qType WithQDescInfo:(NSString *)descInfo {
    return [[IMDataManager stIMDB_SharedInstance] getQTNoteMainItemWithQType:qType WithQDescInfo:descInfo];
}

- (NSArray *)getQTNotesMainItemWithQExtendFlag:(NSInteger)qExtendFlag {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithQExtendFlag:qExtendFlag];
}

- (NSArray *)getQTNotesSubItemWithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithQSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesMainItemWithQExtendedFlag:(NSInteger)qExtendedFlag needConvertToString:(BOOL)flag {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithQExtendedFlag:qExtendedFlag needConvertToString:flag];
}

- (NSDictionary *)getQTNotesMainItemWithCid:(NSInteger)cid {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesMainItemWithCid:cid];
}

- (NSInteger)getQTNoteMainItemMaxTimeWithQType:(NSInteger)qType {
    return [[IMDataManager stIMDB_SharedInstance] getQTNoteMainItemMaxTimeWithQType:qType];
}

- (NSInteger)getMaxQTNoteMainItemCid {
    return [[IMDataManager stIMDB_SharedInstance] getMaxQTNoteMainItemCid];
}

//Sub

- (BOOL)checkExitsSubItemWithQsid:(NSInteger)qsid WithCsid:(NSInteger)csid {
    return [[IMDataManager stIMDB_SharedInstance] checkExitsSubItemWithQsid:qsid WithCsid:csid];
}

- (void)insertQTNotesSubItemWithCId:(NSInteger)cid
                           WithQSId:(NSInteger)qsid
                           WithCSId:(NSInteger)csid
                         WithQSType:(NSInteger)qstype
                        WithQSTitle:(NSString *)qstitle
                    WithQSIntroduce:(NSString *)qsIntroduce
                      WithQSContent:(NSString *)qsContent
                         WithQSTime:(NSInteger)qsTime
                         WithQState:(NSInteger)qSstate
                WithQS_ExtendedFlag:(NSInteger)qs_ExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] insertQTNotesSubItemWithCId:cid WithQSId:qsid WithCSId:csid WithQSType:qstype WithQSTitle:qstitle WithQSIntroduce:qsIntroduce WithQSContent:qsContent WithQSTime:qsTime WithQState:qSstate WithQS_ExtendedFlag:qs_ExtendedFlag];
}

- (void)updateToSubWithCid:(NSInteger)cid
                  WithQSid:(NSInteger)qsid
                  WithCSid:(NSInteger)csid
               WithQSTitle:(NSString *)qSTitle
            WithQSDescInfo:(NSString *)qsDescInfo
             WithQSContent:(NSString *)qsContent
                WithQSTime:(NSInteger)qsTime
               WithQSState:(NSInteger)qsState
       WithQS_ExtendedFlag:(NSInteger)qs_ExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] updateToSubWithCid:cid WithQSid:qsid WithCSid:csid WithQSTitle:qSTitle WithQSDescInfo:qsDescInfo WithQSContent:qsContent WithQSTime:qsTime WithQSState:qsState WithQS_ExtendedFlag:qs_ExtendedFlag];
}

- (void)updateToSubItemWithDicts:(NSArray *)subItemList {
    [[IMDataManager stIMDB_SharedInstance] updateToSubItemWithDicts:subItemList];
}

- (void)deleteToSubWithCId:(NSInteger)cid {
    [[IMDataManager stIMDB_SharedInstance] deleteToSubWithCId:cid];
}

- (void)deleteToSubWithCSId:(NSInteger)Csid {
    [[IMDataManager stIMDB_SharedInstance] deleteToSubWithCSId:Csid];
}

- (void)updateSubStateWithCSId:(NSInteger)Csid
                   WithQSState:(NSInteger)qsState
            WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] updateSubStateWithCSId:Csid WithQSState:qsState WithQsExtendedFlag:qsExtendedFlag];
}

- (void)updateToSubItemTimeWithCSId:(NSInteger)csid
                         WithQSTime:(NSInteger)qsTime
                 WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[IMDataManager stIMDB_SharedInstance] updateToSubItemTimeWithCSId:csid WithQSTime:qsTime WithQsExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag needConvertToString:(BOOL)flag {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag needConvertToString:flag];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid QSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithCid:cid QSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithQSState:(NSInteger)qsState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithExpectQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSState:(NSInteger)qsState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithCid:cid WithQSState:qsState];
}

- (NSDictionary *)getQTNotesSubItemWithCid:(NSInteger)cid WithUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithCid:cid WithUserId:userId];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithCid:cid WithExpectQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithQSState:(NSInteger)qsState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithCid:cid WithQSType:qsType WithQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager stIMDB_SharedInstance] getQTNotesSubItemWithCid:cid WithQSType:qsType WithExpectQSState:qsType];
}

- (NSInteger)getQTNoteSubItemMaxTimeWithCid:(NSInteger)cid
                                 WithQSType:(NSInteger)qsType {
    return [[IMDataManager stIMDB_SharedInstance] getQTNoteSubItemMaxTimeWithCid:cid WithQSType:qsType];
}

- (NSDictionary *)getQTNoteSubItemWithParmDict:(NSDictionary *)paramDict {
    return [[IMDataManager stIMDB_SharedInstance] getQTNoteSubItemWithParmDict:paramDict];
}

- (NSInteger)getMaxQTNoteSubItemCSid {
    return [[IMDataManager stIMDB_SharedInstance] getMaxQTNoteSubItemCSid];
}

@end
