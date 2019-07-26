//
//  QIMKit+QIMDBDataManager.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMDBDataManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMDBDataManager)

+ (void) sharedInstanceWithDBPath:(NSString *)dbPath {
//    [IMDataManager qimDB_sharedInstanceWithDBPath:dbPath];
}

- (void)setDomain:(NSString*)domain {
//    [[IMDataManager qimDB_SharedInstance] setDomain:domain];
}

- (void)clearUserDescInfo {
//    [[IMDataManager qimDB_SharedInstance] clearUserDescInfo];
}

- (NSString *)getTimeSmtapMsgIdForDate:(NSDate *)date WithUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getTimeSmtapMsgIdForDate:date WithUserId:userId];
}

// 群
- (NSInteger)getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getRNSearchEjabHost2GroupChatListByKeyStr:keyStr];
}

- (NSArray *)rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_rnSearchEjabHost2GroupChatListByKeyStr:keyStr limit:limit offset:offset];
}

- (BOOL)checkGroup:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_checkGroup:groupId];
}

- (void)insertGroup:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_insertGroup:groupId];
}

- (void)bulkinsertGroups:(NSArray *) groups {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkinsertGroups:groups];
}

- (void) removeAllMessages {
//    [[IMDataManager qimDB_SharedInstance] qimDB_removeAllMessages];
}

- (void)clearGroupCardVersion {
//    [[IMDataManager qimDB_SharedInstance] qimDB_clearGroupCardVersion];
}

- (NSArray *)getGroupIdList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupIdList];
}

- (NSArray *)qimDB_getGroupList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupList];
}

- (NSInteger)getLocalGroupTotalCountByUserIds:(NSArray *)userIds {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getLocalGroupTotalCountByUserIds:userIds];
}

- (NSArray *)searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_searchGroupByUserIds:userIds WithLimit:limit WithOffset:offset];
}

- (NSArray *)getGroupListMaxLastUpdateTime {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupListMaxLastUpdateTime];
}

- (NSArray *)getGroupListMsgMaxTime {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupListMsgMaxTime];
}

- (void)bulkUpdateGroupCards:(NSArray *)array {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateGroupCards:array];
}

- (void)updateGroup:(NSString *)groupId
       WithNickName:(NSString *)nickName
          WithTopic:(NSString *)topic
           WithDesc:(NSString *)desc
      WithHeaderSrc:(NSString *)headerSrc
        WithVersion:(NSString *)version {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateGroup:groupId
                                  WithNickName:nickName
                                     WithTopic:topic
                                      WithDesc:desc
                                 WithHeaderSrc:headerSrc
                                   WithVersion:version];
}

- (void)updateGroup:(NSString *)groupId WithNickName:(NSString *)nickName {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateGroup:groupId WithNickName:nickName];
}

- (void)updateGroup:(NSString *)groupId WithTopic:(NSString *)topic {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateGroup:groupId WithTopic:topic];
}

- (void)updateGroup:(NSString *)groupId WithDesc:(NSString *)desc {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateGroup:groupId WithDesc:desc];
}

- (void)updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateGroup:groupId WithHeaderSrc:headerSrc];
}

- (BOOL)needUpdateGroupImage:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_needUpdateGroupImage:groupId];
}

- (NSString *)getGroupHeaderSrc:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupHeaderSrc:groupId];
}

- (void)deleteGroup:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroup:groupId];
}

- (NSDictionary *)getGroupMemberInfoByNickName:(NSString *)nickName {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupMemberInfoByNickName:nickName];
}

- (NSDictionary *)getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupMemberInfoByJid:jid WithGroupId:groupId];
}

- (BOOL)checkGroupMember:(NSString *)nickName WithGroupId:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_checkGroupMember:nickName WithGroupId:groupId];
}

- (void)insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_insertGroupMember:memberDic WithGroupId:groupId];
}

- (void)bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertGroupMember:members WithGroupId:groupId];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getQChatGroupMember:groupId];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getQChatGroupMember:groupId BySearchStr:searchStr];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupMember:groupId];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupMember:groupId BySearchStr:searchStr];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId WithGroupIdentity:(NSInteger)identity {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupMember:groupId WithGroupIdentity:identity];
}

- (NSDictionary *)getGroupOwnerInfoForGroupId:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getGroupOwnerInfoForGroupId:groupId];
}

- (void)deleteGroupMemberWithGroupId:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroupMemberWithGroupId:groupId];
}

- (void)deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroupMemberJid:memberJid WithGroupId:groupId];
}

- (void)deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroupMember:nickname WithGroupId:groupId];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId chatType:(int)chatType {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getChatSessionWithUserId:userId chatType:chatType];
}

- (long long)getMinMsgTimeStampByXmppId:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:xmppId];
}

- (long long)getMaxMsgTimeStampByXmppId:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMaxMsgTimeStampByXmppId:xmppId];
}

- (long long) lastestGroupMessageTime {
    return [[IMDataManager qimDB_SharedInstance] qimDB_lastestGroupMessageTime];
}

- (void)bulkInsertUserInfosNotSaveDescInfo:(NSArray *)userInfos {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertUserInfosNotSaveDescInfo:userInfos];
}

- (void)clearUserListForList:(NSArray *)userInfos {
    [[IMDataManager qimDB_SharedInstance] qimDB_clearUserListForList:userInfos];
}

- (void)bulkInsertUserInfos:(NSArray *)userInfos {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertUserInfos:userInfos];
}

- (void)InsertOrUpdateUserInfos:(NSArray *)userInfos {
    [[IMDataManager qimDB_SharedInstance] qimDB_InsertOrUpdateUserInfos:userInfos];
}

- (NSDictionary *)selectUserBackInfoByXmppId:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserBackInfoByXmppId:xmppId];
}

- (NSDictionary *)selectUserByID:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByID:userId];
}

- (NSDictionary *)selectUserByJID:(NSString *)jid {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByJID:jid];
}

- (NSDictionary *)selectUserByIndex:(NSString *)index {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByIndex:index];
}

- (NSArray *)selectXmppIdList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectXmppIdList];
}

- (NSArray *)selectUserIdList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserIdList];
}

- (NSArray *)getOrganUserList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getOrganUserList];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListBySearchStr:searchStr];
}

- (NSInteger)selectUserListTotalCountBySearchStr:(NSString *)searchStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListTotalCountBySearchStr:searchStr];
}

- (NSArray *)selectUserListExMySelfBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListExMySelfBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr inGroup:(NSString *) groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)selectUserListByUserIds:(NSArray *)userIds {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListByUserIds:userIds];
}

- (NSDictionary *)selectUsersDicByXmppIds:(NSArray *)xmppIds {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUsersDicByXmppIds:xmppIds];
}

- (void)bulkUpdateUserSearchIndexs:(NSArray *)searchIndexs {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateUserSearchIndexs:searchIndexs];
}

- (void)updateUser:(NSString *)userId WithMood:(NSString *)mood WithHeaderSrc:(NSString *)headerSrc WithVersion:(NSString *)version{
    [[IMDataManager qimDB_SharedInstance] qimDB_updateUser:userId WithMood:mood WithHeaderSrc:headerSrc WithVersion:version];
}

- (void)bulkUpdateUserCardsV2:(NSArray *)cards {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateUserCards:cards];
}

- (void)bulkUpdateUserBackInfo:(NSDictionary *)userBackInfo WithXmppId:(NSString *)xmppId {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateUserBackInfo:userBackInfo WithXmppId:xmppId];
}

- (NSString *)getUserHeaderSrcByUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getUserHeaderSrcByUserId:userId];
}

- (BOOL)checkExitsUser {
    return [[IMDataManager qimDB_SharedInstance] qimDB_checkExitsUser];
}

- (void)updateMessageWithExtendInfo:(NSString *)extendInfo ForMsgId:(NSString *)msgId {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithExtendInfo:extendInfo ForMsgId:msgId];
}

- (void)deleteMessageWithXmppId:(NSString *)xmppId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteMessageWithXmppId:xmppId];
}

- (void)deleteMessageByMessageId:(NSString *)messageId ByJid:(NSString *)sid {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteMessageByMessageId:messageId ByJid:sid];
}

- (void)updateMessageWithMsgId:(NSString *)msgId
                    WithMsgRaw:(NSString *)msgRaw {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msgId
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
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msgId
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
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msgId
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
    [[IMDataManager qimDB_SharedInstance] qimDB_revokeMessageByMsgId:msgId
                                            WithContent:content
                                            WithMsgType:msgType];
}

- (BOOL)qimDB_checkMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId];
}
//
//- (NSArray *)bulkInsertIphoneMucJSONMsg:(NSArray *)list WithMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WithMyRtxId:(NSString *)rtxId {
//    return [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertIphoneMucJSONMsg:list
//                                                       WithMyNickName:myNickName
//                                                        WithReadMarkT:readMarkT
//                                                     WithDidReadState:didReadState
//                                                          WithMyRtxId:rtxId];
//
//}

- (NSArray *)bulkInsertIphoneHistoryGroupMsg:(NSArray *)list WithXmppId:(NSString *)xmppId WithMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WithMyRtxId:(NSString *)rtxId {
    return nil;
//    return [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertIphoneHistoryGroupMsg:list WithXmppId:xmppId WithMyNickName:myNickName WithReadMarkT:readMarkT WithDidReadState:didReadState WithMyRtxId:rtxId];
}

- (NSArray *)bulkInsertHistoryGroupMsg:(NSArray *)list WithXmppId:(NSString *)xmppId WithMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState {
    return nil;
//    return [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryGroupMsg:list WithXmppId:xmppId WithMyNickName:myNickName WithReadMarkT:readMarkT WithDidReadState:didReadState];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    return [[IMDataManager qimDB_SharedInstance] dictionaryWithJsonString:jsonString];
}

//- (NSMutableDictionary *)bulkInsertHistoryChatJSONMsg:(NSArray *)list {
//    return [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:list];
//}

- (NSString *)getC2BMessageFeedBackWithMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getC2BMessageFeedBackWithMsgId:msgId];
}

- (NSArray *)qimDB_bulkInsertPageHistoryChatJSONMsg:(NSArray *)list
                                         WithXmppId:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPageHistoryChatJSONMsg:list
                                                                             WithXmppId:xmppId];
}

- (void)bulkInsertMessage:(NSArray *)msgList WithSessionId:(NSString *)sessionId {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertMessage:msgList WithSessionId:sessionId];
}

- (void)updateMsgState:(int)msgState WithMsgId:(NSString *)msgId {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgState:msgState WithMsgId:msgId];
}

- (void)updateMessageReadStateWithMsgId:(NSString *)msgId {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageReadStateWithMsgId:msgId];
}

- (void)bulkUpdateMessageReadStateWithMsg:(NSArray *)msgs {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateMessageReadStateWithMsg:msgs];
}

- (void)updateMessageReadStateWithSessionId:(NSString *)sessionId {
//    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageReadStateWithSessionId:sessionId];
}

- (void)updateSessionLastMsgIdWithSessionId:(NSString *)sessionId
                              WithLastMsgId:(NSString *)lastMsgId {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateSessionLastMsgIdWithSessionId:sessionId
                                                         WithLastMsgId:lastMsgId];
}

- (void)insertSessionWithSessionId:(NSString *)sessinId
                        WithUserId:(NSString *)userId
                     WithLastMsgId:(NSString *)lastMsgId
                WithLastUpdateTime:(long long)lastUpdateTime
                          ChatType:(int)ChatType
                       WithRealJid:(id)realJid {
    [[IMDataManager qimDB_SharedInstance] qimDB_insertSessionWithSessionId:sessinId
                                                   WithUserId:userId
                                                WithLastMsgId:lastMsgId
                                           WithLastUpdateTime:lastUpdateTime
                                                     ChatType:ChatType
                                                  WithRealJid:realJid];
}

- (void)deleteSession:(NSString *)xmppId RealJid:(NSString *)realJid {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteSession:xmppId RealJid:realJid];
}

- (void)deleteSession:(NSString *)xmppId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteSession:xmppId];
}

- (NSDictionary *)getLastedSingleChatSession {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getLastedSingleChatSession];
}

- (NSDictionary *)qimDb_getPublicNumberSession {
    return nil;
//    return [[IMDataManager qimDB_SharedInstance] qimDb_getPublicNumberSession];
}

- (NSArray *)qimDB_getSessionListWithSingleChatType:(int)chatType {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getSessionListWithSingleChatType:chatType];
}

- (NSArray *)getSessionListXMPPIDWithSingleChatType:(int)singleChatType {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getSessionListXMPPIDWithSingleChatType:singleChatType];
}

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getNotReadMsgListForUserId:userId];
}

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId ForRealJid:(NSString *)realJid {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getNotReadMsgListForUserId:userId ForRealJid:realJid];
}

- (long long)getReadedTimeStampForUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithMsgDirection:(int)msgDirection withUnReadCount:(NSInteger)unReadCount {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getReadedTimeStampForUserId:userId WithRealJid:realJid WithMsgDirection:msgDirection withUnReadCount:unReadCount];
}

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:sesId];
}

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:sesId WithRealJid:realJid WithLimit:limit WithOffset:offset];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMsgListByXmppId:xmppId WithRealJid:realJid FromTimeStamp:timeStamp];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId FromTimeStamp:(long long)timeStamp {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMsgListByXmppId:xmppId FromTimeStamp:timeStamp];
}

- (NSDictionary *)getMsgsByMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMsgsByMsgId:msgId];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getChatSessionWithUserId:userId];
}

- (void)updateMessageFromState:(int)fState ToState:(int)tState {
    return [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageFromState:fState ToState:tState];
}

- (NSInteger)getMessageStateWithMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMessageStateWithMsgId:msgId];
}

- (NSInteger)getReadStateWithMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getReadStateWithMsgId:msgId];
}

- (NSArray *)getMsgIdsForDirection:(int)msgDirection WithMsgState:(int)msgState {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMsgIdsForDirection:msgDirection WithMsgState:msgState];
}

- (NSArray *)searchMsgHistoryWithKey:(NSString *)key {
    return [[IMDataManager qimDB_SharedInstance] qimDB_searchMsgHistoryWithKey:key];
}

- (NSArray *)searchMsgIdWithKey:(NSString *)key ByXmppId:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_searchMsgIdWithKey:key ByXmppId:xmppId];
}

#pragma mark - 消息数据方法

- (long long) lastestMessageTime {
    return [[IMDataManager qimDB_SharedInstance] qimDB_lastestMessageTime];
}

- (long long) lastestSystemMessageTime {
    return [[IMDataManager qimDB_SharedInstance] qimDB_lastestSystemMessageTime];
}

- (NSString *) getLastMsgIdByJid:(NSString *)jid {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getLastMsgIdByJid:jid];
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
//    [[IMDataManager qimDB_SharedInstance] qimDB_insertFSMsgWithMsgId:msgId
//                                             WithXmppId:xmppId
//                                           WithFromUser:fromUser
//                                         WithReplyMsgId:replyMsgId
//                                          WithReplyUser:replyUser
//                                            WithContent:content
//                                            WithMsgDate:msgDate
//                                       WithExtendedFlag:etxtenedFlag];
}

- (void)bulkInsertFSMsgWithMsgList:(NSArray *)msgList {
//    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertFSMsgWithMsgList:msgList];
}

- (NSArray *)getFSMsgListByXmppId:(NSString *)xmppId {
    return nil;
//    return [[IMDataManager qimDB_SharedInstance] qimDB_getFSMsgListByXmppId:xmppId];
}

- (NSDictionary *)getFSMsgListByReplyMsgId:(NSString *)replyMsgId {
    return nil;
//    return [[IMDataManager qimDB_SharedInstance] qimDB_getFSMsgListByReplyMsgId:replyMsgId];
}

/****************** readmark *********************/
- (long long)qimDB_updateGroupMsgWithMsgState:(int)msgState ByGroupMsgList:(NSArray *)groupMsgList {
    return 0;
//    return [[IMDataManager qimDB_SharedInstance] qimDB_updateGroupMsgWithMsgState:msgState ByGroupMsgList:groupMsgList];
}

- (void)updateUserMsgWithMsgState:(int)msgState ByMsgList:(NSArray *)userMsgList {
//    [[IMDataManager qimDB_SharedInstance] qimDB_updateUserMsgWithMsgState:msgState ByMsgList:userMsgList];
}

- (void)clearHistoryMsg {
    [[IMDataManager qimDB_SharedInstance] qimDB_clearHistoryMsg];
}

- (void)closeDataBase {
    [[IMDataManager qimDB_SharedInstance] qimDB_closeDataBase];
}

+ (void)clearDataBaseCache {
//    [IMDataManager clearDataBaseCache];
}

- (void)qimDB_dbCheckpoint {
    [[IMDataManager qimDB_SharedInstance] qimDB_dbCheckpoint];
}

/*************** Friend List *************/
- (void)bulkInsertFriendList:(NSArray *)friendList {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertFriendList:friendList];
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
    [[IMDataManager qimDB_SharedInstance] qimDB_insertFriendWithUserId:userId
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
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendListWithXmppId:xmppId];
}

- (void)deleteFriendListWithUserId:(NSString *)userId {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendListWithUserId:userId];
}

- (void)deleteFriendList {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendList];
}
- (void)deleteSessionList {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteSessionList];
}

- (NSMutableArray *)selectFriendList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectFriendList];
}

- (NSMutableArray *)qimDB_selectFriendListInGroupId:(NSString *)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectFriendListInGroupId:groupId];
}

- (NSDictionary *)selectFriendInfoWithUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectFriendInfoWithUserId:userId];
}
- (NSDictionary *)selectFriendInfoWithXmppId:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectFriendInfoWithXmppId:xmppId];
}

- (void)bulkInsertFriendNotifyList:(NSArray *)notifyList {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertFriendNotifyList:notifyList];
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
    [[IMDataManager qimDB_SharedInstance] qimDB_insertFriendNotifyWithUserId:userId
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
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendNotifyWithUserId:userId];
}

- (NSMutableArray *)selectFriendNotifys {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectFriendNotifys];
}

- (void)updateFriendNotifyWithXmppId:(NSString *)xmppId WithState:(int)state {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateFriendNotifyWithXmppId:xmppId WithState:state];
}

- (void)updateFriendNotifyWithUserId:(NSString *)userId WithState:(int)state {
//    [[IMDataManager qimDB_SharedInstance] qimDB_updateFriendNotifyWithUserId:userId WithState:state];
}

- (long long)getMaxTimeFriendNotify {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMaxTimeFriendNotify];
}

// ******************** 公众账号 ***************************** //
- (BOOL)checkPublicNumberMsgById:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_checkPublicNumberMsgById:msgId];
}

- (void)checkPublicNumbers:(NSArray *)publicNumberIds {
    [[IMDataManager qimDB_SharedInstance] qimDB_checkPublicNumbers:publicNumberIds];
}

- (void)bulkInsertPublicNumbers:(NSArray *)publicNumberList {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPublicNumbers:publicNumberList];
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
    [[IMDataManager qimDB_SharedInstance] qimDB_insertPublicNumberXmppId:xmppId
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
    [[IMDataManager qimDB_SharedInstance] qimDB_deletePublicNumberId:publicNumberId];
}

- (NSArray *)getPublicNumberVersionList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getPublicNumberVersionList];
}

- (NSArray *)getPublicNumberList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getPublicNumberList];
}

- (NSArray *)searchPublicNumberListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_searchPublicNumberListByKeyStr:keyStr];
}

- (NSInteger)getRnSearchPublicNumberListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getRnSearchPublicNumberListByKeyStr:keyStr];
}

- (NSArray *)rnSearchPublicNumberListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_rnSearchPublicNumberListByKeyStr:keyStr limit:limit offset:offset];
}

- (NSDictionary *)getPublicNumberCardByJId:(NSString *)jid {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getPublicNumberCardByJId:jid];
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
    [[IMDataManager qimDB_SharedInstance] qimDB_insetPublicNumberMsgWithMsgId:msgId
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
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMsgListByPublicNumberId:publicNumberId WithLimit:limit WithOffset:offset WithFilterType:actionTypes];
}

/****************** Collection Msg *******************/

- (NSArray *)getCollectionAccountList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionAccountList];
}

- (void)bulkinsertCollectionAccountList:(NSArray *)accounts {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkinsertCollectionAccountList:accounts];
}


- (NSDictionary *)selectCollectionUserByJID:(NSString *)jid {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectCollectionUserByJID:jid];
}

- (void)bulkInsertCollectionUserCards:(NSArray *)userCards {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertCollectionUserCards:userCards];
}

- (void)bulkInsertCollectionGroupCards:(NSArray *)groupCards {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertCollectionGroupCards:groupCards];
}

- (NSDictionary *)getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getLastCollectionMsgWithLastMsgId:lastMsgId];;
}

- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionSessionListWithBindId:bindId];
}

- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionMsgListWithBindId:bindId];
}

- (BOOL)checkCollectionMsgById:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_checkCollectionMsgById:msgId];
}

- (void)bulkInsertCollectionMsgWithMsgDics:(NSArray *)msgs {
    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertCollectionMsgWithMsgDics:msgs];
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionMsgNotReadCountByDidReadState:readState];
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionMsgNotReadCountByDidReadState:readState ForBindId:bindId];
}

- (NSInteger)getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:readState ForBindId:bindId originUserId:originUserId];
}

- (void)updateCollectionMsgNotReadStateByJid:(NSString *)jid WithReadtate:(NSInteger)readState {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateCollectionMsgNotReadStateByJid:jid WithReadtate:(NSInteger)readState];
//    [[IMDataManager qimDB_SharedInstance] qimDB_updateCollectionMsgNotReadStateByJid:jid WithMsgState:msgState];
}

- (void)updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithReadState:(NSInteger)readState{
    [[IMDataManager qimDB_SharedInstance] qimDB_updateCollectionMsgNotReadStateForBindId:bindId originUserId:originUserId WithReadState:readState];

//    [[IMDataManager qimDB_SharedInstance] qimDB_updateCollectionMsgNotReadStateForBindId:bindId originUserId:originUserId WithMsgState:msgState];
}

- (NSDictionary *)getCollectionMsgListForMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionMsgListForMsgId:msgId];
}

- (NSArray *)getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getCollectionMsgListWithUserId:userId originUserId:originUserId];
}

/*********************** Group Message State **************************/
- (long long)qimDB_bulkUpdateGroupMessageReadFlag:(NSArray *)mucArray {
    return [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateGroupMessageReadFlag:mucArray];
}

/*********************** QTNotes **********************/

//Main

- (BOOL)checkExitsMainItemWithQid:(NSInteger)qid WithCId:(NSInteger)cid {
    return [[IMDataManager qimDB_SharedInstance] checkExitsMainItemWithQid:qid WithCId:cid];
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
    [[IMDataManager qimDB_SharedInstance] insertQTNotesMainItemWithQId:qid
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
    [[IMDataManager qimDB_SharedInstance] updateToMainWithQId:qid WithCid:cid WithQType:qtype WithQTitle:qtitle WithQDescInfo:qdescInfo WithQContent:qcontent WithQTime:qtime WithQState:qstate WithQExtendedFlag:qExtendedFlag];
}

- (void)updateToMainItemWithDicts:(NSArray *)mainItemList {
    [[IMDataManager qimDB_SharedInstance] updateToMainItemWithDicts:mainItemList];
}

- (void)deleteToMainWithQid:(NSInteger)qid {
    [[IMDataManager qimDB_SharedInstance] deleteToMainWithQid:qid];
}

- (void)deleteToMainWithCid:(NSInteger)cid {
    [[IMDataManager qimDB_SharedInstance] deleteToMainWithCid:cid];
}

- (void)updateToMainItemTimeWithQId:(NSInteger)qid
                          WithQTime:(NSInteger)qTime
                  WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager qimDB_SharedInstance] updateToMainItemTimeWithQId:qid WithQTime:qTime WithQExtendedFlag:qExtendedFlag];
}

- (void)updateMainStateWithQid:(NSInteger)qid
                       WithCid:(NSInteger)cid
                    WithQState:(NSInteger)qstate
             WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager qimDB_SharedInstance] updateMainStateWithQid:qid WithCid:cid WithQState:qstate WithQExtendedFlag:qExtendedFlag];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithQType:qType];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType QString:(NSString *)qString {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithQType:qType QString:qString];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithExceptQState:(NSInteger)qState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithQType:qType WithExceptQState:qState];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithQState:(NSInteger)qState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithQType:qType WithQState:qState];
}

- (NSArray *)getQTNoteMainItemWithQType:(NSInteger)qType WithQDescInfo:(NSString *)descInfo {
    return [[IMDataManager qimDB_SharedInstance] getQTNoteMainItemWithQType:qType WithQDescInfo:descInfo];
}

- (NSArray *)getQTNotesMainItemWithQExtendFlag:(NSInteger)qExtendFlag {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithQExtendFlag:qExtendFlag];
}

- (NSArray *)getQTNotesSubItemWithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithQSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesMainItemWithQExtendedFlag:(NSInteger)qExtendedFlag needConvertToString:(BOOL)flag {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithQExtendedFlag:qExtendedFlag needConvertToString:flag];
}

- (NSDictionary *)getQTNotesMainItemWithCid:(NSInteger)cid {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesMainItemWithCid:cid];
}

- (NSInteger)getQTNoteMainItemMaxTimeWithQType:(NSInteger)qType {
    return [[IMDataManager qimDB_SharedInstance] getQTNoteMainItemMaxTimeWithQType:qType];
}

- (NSInteger)getMaxQTNoteMainItemCid {
    return [[IMDataManager qimDB_SharedInstance] getMaxQTNoteMainItemCid];
}

//Sub

- (BOOL)checkExitsSubItemWithQsid:(NSInteger)qsid WithCsid:(NSInteger)csid {
    return [[IMDataManager qimDB_SharedInstance] checkExitsSubItemWithQsid:qsid WithCsid:csid];
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
    [[IMDataManager qimDB_SharedInstance] insertQTNotesSubItemWithCId:cid WithQSId:qsid WithCSId:csid WithQSType:qstype WithQSTitle:qstitle WithQSIntroduce:qsIntroduce WithQSContent:qsContent WithQSTime:qsTime WithQState:qSstate WithQS_ExtendedFlag:qs_ExtendedFlag];
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
    [[IMDataManager qimDB_SharedInstance] updateToSubWithCid:cid WithQSid:qsid WithCSid:csid WithQSTitle:qSTitle WithQSDescInfo:qsDescInfo WithQSContent:qsContent WithQSTime:qsTime WithQSState:qsState WithQS_ExtendedFlag:qs_ExtendedFlag];
}

- (void)updateToSubItemWithDicts:(NSArray *)subItemList {
    [[IMDataManager qimDB_SharedInstance] updateToSubItemWithDicts:subItemList];
}

- (void)deleteToSubWithCId:(NSInteger)cid {
    [[IMDataManager qimDB_SharedInstance] deleteToSubWithCId:cid];
}

- (void)deleteToSubWithCSId:(NSInteger)Csid {
    [[IMDataManager qimDB_SharedInstance] deleteToSubWithCSId:Csid];
}

- (void)updateSubStateWithCSId:(NSInteger)Csid
                   WithQSState:(NSInteger)qsState
            WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[IMDataManager qimDB_SharedInstance] updateSubStateWithCSId:Csid WithQSState:qsState WithQsExtendedFlag:qsExtendedFlag];
}

- (void)updateToSubItemTimeWithCSId:(NSInteger)csid
                         WithQSTime:(NSInteger)qsTime
                 WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[IMDataManager qimDB_SharedInstance] updateToSubItemTimeWithCSId:csid WithQSTime:qsTime WithQsExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag needConvertToString:(BOOL)flag {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag needConvertToString:flag];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid QSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithCid:cid QSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithQSState:(NSInteger)qsState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithExpectQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSState:(NSInteger)qsState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithCid:cid WithQSState:qsState];
}

- (NSDictionary *)getQTNotesSubItemWithCid:(NSInteger)cid WithUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithCid:cid WithUserId:userId];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithCid:cid WithExpectQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithQSState:(NSInteger)qsState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithCid:cid WithQSType:qsType WithQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager qimDB_SharedInstance] getQTNotesSubItemWithCid:cid WithQSType:qsType WithExpectQSState:qsType];
}

- (NSInteger)getQTNoteSubItemMaxTimeWithCid:(NSInteger)cid
                                 WithQSType:(NSInteger)qsType {
    return [[IMDataManager qimDB_SharedInstance] getQTNoteSubItemMaxTimeWithCid:cid WithQSType:qsType];
}

- (NSDictionary *)getQTNoteSubItemWithParmDict:(NSDictionary *)paramDict {
    return [[IMDataManager qimDB_SharedInstance] getQTNoteSubItemWithParmDict:paramDict];
}

- (NSInteger)getMaxQTNoteSubItemCSid {
    return [[IMDataManager qimDB_SharedInstance] getMaxQTNoteSubItemCSid];
}

@end
