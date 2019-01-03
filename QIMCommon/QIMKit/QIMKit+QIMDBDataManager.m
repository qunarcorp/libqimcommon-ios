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

+ (void) sharedInstanceWihtDBPath:(NSString *)dbPath {
    [IMDataManager sharedInstanceWihtDBPath:dbPath];
}

- (void)setDomain:(NSString*)domain {
    [[IMDataManager sharedInstance] setDomain:domain];
}

- (void)clearUserDescInfo {
    [[IMDataManager sharedInstance] clearUserDescInfo];
}

- (NSString *)getTimeSmtapMsgIdForDate:(NSDate *)date WithUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] getTimeSmtapMsgIdForDate:date WithUserId:userId];
}

// 群
- (NSInteger)getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager sharedInstance] getRNSearchEjabHost2GroupChatListByKeyStr:keyStr];
}

- (NSArray *)rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    return [[IMDataManager sharedInstance] rnSearchEjabHost2GroupChatListByKeyStr:keyStr limit:limit offset:offset];
}

- (BOOL)checkGroup:(NSString *)groupId {
    return [[IMDataManager sharedInstance] checkGroup:groupId];
}

- (void)insertGroup:(NSString *)groupId {
    [[IMDataManager sharedInstance] insertGroup:groupId];
}

- (void)bulkinsertGroups:(NSArray *) groups {
    [[IMDataManager sharedInstance] bulkinsertGroups:groups];
}

- (void) removeAllMessages {
    [[IMDataManager sharedInstance] removeAllMessages];
}

- (void)clearGroupCardVersion {
    [[IMDataManager sharedInstance] clearGroupCardVersion];
}

- (NSArray *)getGroupIdList {
    return [[IMDataManager sharedInstance] getGroupIdList];
}

- (NSArray *)qimDB_getGroupList {
    return [[IMDataManager sharedInstance] qimDB_getGroupList];
}

- (NSInteger)getLocalGroupTotalCountByUserIds:(NSArray *)userIds {
    return [[IMDataManager sharedInstance] getLocalGroupTotalCountByUserIds:userIds];
}

- (NSArray *)searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager sharedInstance] searchGroupByUserIds:userIds WithLimit:limit WithOffset:offset];
}

- (NSArray *)getGroupListMaxLastUpdateTime {
    return [[IMDataManager sharedInstance] getGroupListMaxLastUpdateTime];
}

- (NSArray *)getGroupListMsgMaxTime {
    return [[IMDataManager sharedInstance] getGroupListMsgMaxTime];
}

- (void)bulkUpdateGroupCards:(NSArray *)array {
    [[IMDataManager sharedInstance] bulkUpdateGroupCards:array];
}

- (void)updateGroup:(NSString *)groupId
       WihtNickName:(NSString *)nickName
          WithTopic:(NSString *)topic
           WithDesc:(NSString *)desc
      WithHeaderSrc:(NSString *)headerSrc
        WithVersion:(NSString *)version {
    [[IMDataManager sharedInstance] updateGroup:groupId
                                  WihtNickName:nickName
                                     WithTopic:topic
                                      WithDesc:desc
                                 WithHeaderSrc:headerSrc
                                   WithVersion:version];
}

- (void)updateGroup:(NSString *)groupId WihtNickName:(NSString *)nickName {
    [[IMDataManager sharedInstance] updateGroup:groupId WihtNickName:nickName];
}

- (void)updateGroup:(NSString *)groupId WithTopic:(NSString *)topic {
    [[IMDataManager sharedInstance] updateGroup:groupId WithTopic:topic];
}

- (void)updateGroup:(NSString *)groupId WithDesc:(NSString *)desc {
    [[IMDataManager sharedInstance] updateGroup:groupId WithDesc:desc];
}

- (void)updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc {
    [[IMDataManager sharedInstance] updateGroup:groupId WithHeaderSrc:headerSrc];
}

- (BOOL)needUpdateGroupImage:(NSString *)groupId {
    return [[IMDataManager sharedInstance] needUpdateGroupImage:groupId];
}

- (NSString *)getGroupHeaderSrc:(NSString *)groupId {
    return [[IMDataManager sharedInstance] getGroupHeaderSrc:groupId];
}

- (void)deleteGroup:(NSString *)groupId {
    [[IMDataManager sharedInstance] deleteGroup:groupId];
}

- (NSDictionary *)getGroupMemberInfoByNickName:(NSString *)nickName {
    return [[IMDataManager sharedInstance] getGroupMemberInfoByNickName:nickName];
}

- (NSDictionary *)getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId {
    return [[IMDataManager sharedInstance] getGroupMemberInfoByJid:jid WithGroupId:groupId];
}

- (BOOL)checkGroupMember:(NSString *)nickName WihtGroupId:(NSString *)groupId {
    return [[IMDataManager sharedInstance] checkGroupMember:nickName WihtGroupId:groupId];
}

- (void)insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId {
    [[IMDataManager sharedInstance] insertGroupMember:memberDic WithGroupId:groupId];
}

- (void)bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId {
    [[IMDataManager sharedInstance] bulkInsertGroupMember:members WithGroupId:groupId];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId {
    return [[IMDataManager sharedInstance] getQChatGroupMember:groupId];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr {
    return [[IMDataManager sharedInstance] getQChatGroupMember:groupId BySearchStr:searchStr];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId {
    return [[IMDataManager sharedInstance] qimDB_getGroupMember:groupId];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr {
    return [[IMDataManager sharedInstance] qimDB_getGroupMember:groupId BySearchStr:searchStr];
}

- (NSDictionary *)getGroupOwnerInfoForGroupId:(NSString *)groupId {
    return [[IMDataManager sharedInstance] getGroupOwnerInfoForGroupId:groupId];
}

- (void)deleteGroupMemberWithGroupId:(NSString *)groupId {
    [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupId];
}

- (void)deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId {
    [[IMDataManager sharedInstance] deleteGroupMemberJid:memberJid WithGroupId:groupId];
}

- (void)deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId {
    [[IMDataManager sharedInstance] deleteGroupMember:nickname WithGroupId:groupId];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId chatType:(int)chatType {
    return [[IMDataManager sharedInstance] getChatSessionWithUserId:userId chatType:chatType];
}

- (long long)getMinMsgTimeStampByXmppId:(NSString *)xmppId {
    return [[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:xmppId];
}

- (long long)getMaxMsgTimeStampByXmppId:(NSString *)xmppId {
    return [[IMDataManager sharedInstance] getMaxMsgTimeStampByXmppId:xmppId];
}

- (long long) lastestGroupMessageTime {
    return [[IMDataManager sharedInstance] lastestGroupMessageTime];
}

- (void)bulkInsertUserInfosNotSaveDescInfo:(NSArray *)userInfos {
    [[IMDataManager sharedInstance] bulkInsertUserInfosNotSaveDescInfo:userInfos];
}

- (void)clearUserListForList:(NSArray *)userInfos {
    [[IMDataManager sharedInstance] clearUserListForList:userInfos];
}

- (void)bulkInsertUserInfos:(NSArray *)userInfos {
    [[IMDataManager sharedInstance] bulkInsertUserInfos:userInfos];
}

- (void)InsertOrUpdateUserInfos:(NSArray *)userInfos {
    [[IMDataManager sharedInstance] InsertOrUpdateUserInfos:userInfos];
}

- (NSDictionary *)selectUserBackInfoByXmppId:(NSString *)xmppId {
    return [[IMDataManager sharedInstance] selectUserBackInfoByXmppId:xmppId];
}

- (NSDictionary *)selectUserByID:(NSString *)userId {
    return [[IMDataManager sharedInstance] selectUserByID:userId];
}

- (NSDictionary *)selectUserByJID:(NSString *)jid {
    return [[IMDataManager sharedInstance] selectUserByJID:jid];
}

- (NSDictionary *)selectUserByIndex:(NSString *)index {
    return [[IMDataManager sharedInstance] selectUserByIndex:index];
}

- (NSArray *)selectXmppIdFromSessionList {
    return [[IMDataManager sharedInstance] selectXmppIdFromSessionList];
}

- (NSArray *)selectXmppIdList {
    return [[IMDataManager sharedInstance] selectXmppIdList];
}

- (NSArray *)selectUserIdList {
    return [[IMDataManager sharedInstance] selectUserIdList];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr {
    return [[IMDataManager sharedInstance] selectUserListBySearchStr:searchStr];
}

- (NSInteger)selectUserListTotalCountBySearchStr:(NSString *)searchStr {
    return [[IMDataManager sharedInstance] selectUserListTotalCountBySearchStr:searchStr];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[IMDataManager sharedInstance] selectUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr inGroup:(NSString *) groupId {
    return [[IMDataManager sharedInstance] selectUserListBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)selectUserListByUserIds:(NSArray *)userIds {
    return [[IMDataManager sharedInstance] selectUserListByUserIds:userIds];
}

- (NSDictionary *)selectUsersDicByXmppIds:(NSArray *)xmppIds {
    return [[IMDataManager sharedInstance] selectUsersDicByXmppIds:xmppIds];
}

- (void)bulkUpdateUserSearchIndexs:(NSArray *)searchIndexs {
    [[IMDataManager sharedInstance] bulkUpdateUserSearchIndexs:searchIndexs];
}

- (void)updateUser:(NSString *)userId WithHeaderSrc:(NSString *)headerSrc WithVersion:(NSString *)version {
    [[IMDataManager sharedInstance] updateUser:userId WithHeaderSrc:headerSrc WithVersion:version];
}

- (void)bulkUpdateUserCardsV2:(NSArray *)cards {
    [[IMDataManager sharedInstance] bulkUpdateUserCardsV2:cards];
}

- (void)bulkUpdateUserBackInfo:(NSDictionary *)userBackInfo WithXmppId:(NSString *)xmppId {
    [[IMDataManager sharedInstance] bulkUpdateUserBackInfo:userBackInfo WithXmppId:xmppId];
}

- (NSString *)getUserHeaderSrcByUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] getUserHeaderSrcByUserId:userId];
}

- (BOOL)checkExitsUser {
    return [[IMDataManager sharedInstance] checkExitsUser];
}

- (int)getMaxUserIncrementVersion {
    return [[IMDataManager sharedInstance] getMaxUserIncrementVersion];
}

- (void)updateMessageWithExtendInfo:(NSString *)extendInfo ForMsgId:(NSString *)msgId {
    [[IMDataManager sharedInstance] updateMessageWithExtendInfo:extendInfo ForMsgId:msgId];
}

- (void)deleteMessageWithXmppId:(NSString *)xmppId {
    [[IMDataManager sharedInstance] deleteMessageWithXmppId:xmppId];
}

- (void)deleteMessageByMessageId:(NSString *)messageId ByJid:(NSString *)sid {
    [[IMDataManager sharedInstance] deleteMessageByMessageId:messageId ByJid:sid];
}

- (void)insertMessageWihtMsgId:(NSString *)msgId
                    WithXmppId:(NSString *)xmppId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  WithChatType:(NSInteger)chatType {
    [[IMDataManager sharedInstance] insertMessageWihtMsgId:msgId
                                                WithXmppId:xmppId
                                                  WithFrom:from
                                                    WithTo:to
                                               WithContent:content
                                            WithExtendInfo:extendInfo
                                              WithPlatform:platform
                                               WithMsgType:msgType
                                              WithMsgState:msgState
                                          WithMsgDirection:msgDirection
                                               WihtMsgDate:msgDate
                                             WithReadedTag:readedTag
                                              WithChatType:chatType];
}

- (void)insertMessageWihtMsgId:(NSString *)msgId
                    WithXmppId:(NSString *)xmppId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                    WithMsgRaw:(NSString *)msgRaw
                  WithChatType:(NSInteger)chatType {
    [[IMDataManager sharedInstance] insertMessageWihtMsgId:msgId
                                                WithXmppId:xmppId
                                                  WithFrom:from
                                                    WithTo:to
                                               WithContent:content
                                            WithExtendInfo:extendInfo
                                              WithPlatform:platform
                                               WithMsgType:msgType
                                              WithMsgState:msgState
                                          WithMsgDirection:msgDirection
                                               WihtMsgDate:msgDate
                                             WithReadedTag:readedTag
                                                WithMsgRaw:msgRaw
                                              WithChatType:chatType];
}

- (void) insertMessageWihtMsgId:(NSString *)msgId
                     WithXmppId:(NSString *)xmppId
                       WithFrom:(NSString *)from
                         WithTo:(NSString *)to
                    WithContent:(NSString *)content
                 WithExtendInfo:(NSString *)extendInfo
                   WithPlatform:(int)platform
                    WithMsgType:(int)msgType
                   WithMsgState:(int)msgState
               WithMsgDirection:(int)msgDirection
                    WihtMsgDate:(long long)msgDate
                  WithReadedTag:(int)readedTag
                     WithMsgRaw:(NSString *)msgRaw
                    WithRealJid:(NSString *)realJid
                   WithChatType:(NSInteger)chatType {
    [[IMDataManager sharedInstance] insertMessageWihtMsgId:msgId
                                                WithXmppId:xmppId
                                                  WithFrom:from
                                                    WithTo:to
                                               WithContent:content
                                            WithExtendInfo:extendInfo
                                              WithPlatform:platform
                                               WithMsgType:msgType
                                              WithMsgState:msgState
                                          WithMsgDirection:msgDirection
                                               WihtMsgDate:msgDate
                                             WithReadedTag:readedTag
                                                WithMsgRaw:msgRaw
                                               WithRealJid:realJid
                                              WithChatType:chatType];
}

- (void)updateMessageWithMsgId:(NSString *)msgId
                    WithMsgRaw:(NSString *)msgRaw {
    [[IMDataManager sharedInstance] updateMessageWithMsgId:msgId
                                               WithMsgRaw:msgRaw];
}

- (void)updateMessageWihtMsgId:(NSString *)msgId
                 WithSessionId:(NSString *)sessionId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  ExtendedFlag:(int)ExtendedFlag {
    [[IMDataManager sharedInstance] updateMessageWihtMsgId:msgId
                                            WithSessionId:sessionId
                                                 WithFrom:from
                                                   WithTo:to
                                              WithContent:content
                                             WithPlatform:platform
                                              WithMsgType:msgType
                                             WithMsgState:msgState
                                         WithMsgDirection:msgDirection
                                              WihtMsgDate:msgDate
                                            WithReadedTag:readedTag
                                             ExtendedFlag:ExtendedFlag];
}

- (void)updateMessageWihtMsgId:(NSString *)msgId
                 WithSessionId:(NSString *)sessionId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  ExtendedFlag:(int)ExtendedFlag
                    WithMsgRaw:(NSString *)msgRaw {
    [[IMDataManager sharedInstance] updateMessageWihtMsgId:msgId
                                            WithSessionId:sessionId
                                                 WithFrom:from
                                                   WithTo:to
                                              WithContent:content
                                            WithExtendInfo:extendInfo
                                             WithPlatform:platform
                                              WithMsgType:msgType
                                             WithMsgState:msgState
                                         WithMsgDirection:msgDirection
                                              WihtMsgDate:msgDate
                                            WithReadedTag:readedTag
                                             ExtendedFlag:ExtendedFlag
                                               WithMsgRaw:msgRaw];
}

- (void)revokeMessageByMsgId:(NSString *)msgId
                 WihtContent:(NSString *)content
                 WithMsgType:(int)msgType {
    [[IMDataManager sharedInstance] revokeMessageByMsgId:msgId
                                            WihtContent:content
                                            WithMsgType:msgType];
}

- (BOOL)checkMsgId:(NSString *)msgId {
    return [[IMDataManager sharedInstance] checkMsgId:msgId];
}

- (NSArray *)bulkInsertIphoneMucJSONMsg:(NSArray *)list WihtMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WihtMyRtxId:(NSString *)rtxId {
    return [[IMDataManager sharedInstance] bulkInsertIphoneMucJSONMsg:list
                                                       WihtMyNickName:myNickName
                                                        WithReadMarkT:readMarkT
                                                     WithDidReadState:didReadState
                                                          WihtMyRtxId:rtxId];

}

- (NSArray *)bulkInsertIphoneHistoryGroupMsg:(NSArray *)list WithXmppId:(NSString *)xmppId WihtMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WihtMyRtxId:(NSString *)rtxId {
    return [[IMDataManager sharedInstance] bulkInsertIphoneHistoryGroupMsg:list WithXmppId:xmppId WihtMyNickName:myNickName WithReadMarkT:readMarkT WithDidReadState:didReadState WihtMyRtxId:rtxId];
}

- (NSArray *)bulkInsertHistoryGroupMsg:(NSArray *)list WithXmppId:(NSString *)xmppId WihtMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState {
    return [[IMDataManager sharedInstance] bulkInsertHistoryGroupMsg:list WithXmppId:xmppId WihtMyNickName:myNickName WithReadMarkT:readMarkT WithDidReadState:didReadState];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    return [[IMDataManager sharedInstance] dictionaryWithJsonString:jsonString];
}

- (NSMutableDictionary *)bulkInsertHistoryChatJSONMsg:(NSArray *)list
                                                   to:(NSString *)meJid
                                     WithDidReadState:(int)didReadState {
    return [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:list
                                                                    to:meJid
                                                      WithDidReadState:didReadState];
}

- (NSString *)getC2BMessageFeedBackWithMsgId:(NSString *)msgId {
    return [[IMDataManager sharedInstance] getC2BMessageFeedBackWithMsgId:msgId];
}

- (NSArray *)bulkInsertHistoryChatJSONMsg:(NSArray *)list
                               WithXmppId:(NSString *)xmppId
                         WithDidReadState:(int)didReadState {
    return [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:list
                                                            WithXmppId:xmppId
                                                      WithDidReadState:didReadState];
}

- (void)bulkInsertMessage:(NSArray *)msgList WihtSessionId:(NSString *)sessionId {
    [[IMDataManager sharedInstance] bulkInsertMessage:msgList WihtSessionId:sessionId];
}

- (void)updateMsgState:(int)msgState WithMsgId:(NSString *)msgId {
    [[IMDataManager sharedInstance] updateMsgState:msgState WithMsgId:msgId];
}

- (void)updateMessageReadStateWithMsgId:(NSString *)msgId {
    [[IMDataManager sharedInstance] updateMessageReadStateWithMsgId:msgId];
}

- (void)bulkUpdateMessageReadStateWithMsg:(NSArray *)msgs {
    [[IMDataManager sharedInstance] bulkUpdateMessageReadStateWithMsg:msgs];
}

- (void)updateMessageReadStateWithSessionId:(NSString *)sessionId {
    [[IMDataManager sharedInstance] updateMessageReadStateWithSessionId:sessionId];
}

- (void)updateSessionLastMsgIdWihtSessionId:(NSString *)sessionId
                              WithLastMsgId:(NSString *)lastMsgId {
    [[IMDataManager sharedInstance] updateSessionLastMsgIdWihtSessionId:sessionId
                                                         WithLastMsgId:lastMsgId];
}

- (void)insertSessionWithSessionId:(NSString *)sessinId
                        WithUserId:(NSString *)userId
                     WihtLastMsgId:(NSString *)lastMsgId
                WithLastUpdateTime:(long long)lastUpdateTime
                          ChatType:(int)ChatType
                       WithRealJid:(id)realJid {
    [[IMDataManager sharedInstance] insertSessionWithSessionId:sessinId
                                                   WithUserId:userId
                                                WihtLastMsgId:lastMsgId
                                           WithLastUpdateTime:lastUpdateTime
                                                     ChatType:ChatType
                                                  WithRealJid:realJid];
}

- (void)deleteSession:(NSString *)xmppId RealJid:(NSString *)realJid {
    [[IMDataManager sharedInstance] deleteSession:xmppId RealJid:realJid];
}

- (void)deleteSession:(NSString *)xmppId {
    [[IMDataManager sharedInstance] deleteSession:xmppId];
}

- (NSDictionary *)getLastedSingleChatSession {
    return [[IMDataManager sharedInstance] getLastedSingleChatSession];
}

- (NSDictionary *)qimDb_getPublicNumberSession {
    return [[IMDataManager sharedInstance] qimDb_getPublicNumberSession];
}

- (NSArray *)qimDB_getSessionListWithSingleChatType:(int)chatType {
    return [[IMDataManager sharedInstance] qimDB_getSessionListWithSingleChatType:chatType];
}

- (NSArray *)getSessionListXMPPIDWithSingleChatType:(int)singleChatType {
    return [[IMDataManager sharedInstance] getSessionListXMPPIDWithSingleChatType:singleChatType];
}

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] qimDB_getNotReadMsgListForUserId:userId];
}

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId ForRealJid:(NSString *)realJid {
    return [[IMDataManager sharedInstance] qimDB_getNotReadMsgListForUserId:userId ForRealJid:realJid];
}

- (long long)getReadedTimeStampForUserId:(NSString *)userId WihtMsgDirection:(int)msgDirection WithReadedState:(int)readedState {
    return [[IMDataManager sharedInstance] getReadedTimeStampForUserId:userId WihtMsgDirection:msgDirection WithReadedState:readedState];
}

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId {
    return [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:sesId];
}

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId WithRealJid:(NSString *)realJid WithLimit:(int)limit WihtOffset:(int)offset {
    return [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:sesId WithRealJid:realJid WithLimit:limit WihtOffset:offset];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp {
    return [[IMDataManager sharedInstance] getMsgListByXmppId:xmppId WithRealJid:realJid FromTimeStamp:timeStamp];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId FromTimeStamp:(long long)timeStamp {
    return [[IMDataManager sharedInstance] getMsgListByXmppId:xmppId FromTimeStamp:timeStamp];
}

- (NSDictionary *)getLastMessage {
    return [[IMDataManager sharedInstance] getLastMessage];
}

- (void)updateMsgsContent:(NSString *)content ByMsgId:(NSString *)msgId {
    [[IMDataManager sharedInstance] updateMsgsContent:content ByMsgId:msgId];
}

- (NSDictionary *)getMsgsByMsgId:(NSString *)msgId {
    return [[IMDataManager sharedInstance] getMsgsByMsgId:msgId];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] getChatSessionWithUserId:userId];
}

- (NSInteger)getNotReaderMsgCountByDidReadState:(int)didReadState WidthReceiveDirection:(int)receiveDirection {
    return [[IMDataManager sharedInstance] getNotReaderMsgCountByDidReadState:didReadState WidthReceiveDirection:receiveDirection];
}

- (NSInteger)getNotReaderMsgCountByJid:(NSString *)jid ByDidReadState:(int)didReadState WidthReceiveDirection:(int)receiveDirection {
    return [[IMDataManager sharedInstance] getNotReaderMsgCountByJid:jid ByDidReadState:didReadState WidthReceiveDirection:receiveDirection];
}

- (NSInteger)getNotReaderMsgCountByJid:(NSString *)jid ByRealJid:(NSString *)realJid ByDidReadState:(int)didReadState WidthReceiveDirection:(int)receiveDirection {
    return [[IMDataManager sharedInstance] getNotReaderMsgCountByJid:jid ByRealJid:realJid ByDidReadState:didReadState WidthReceiveDirection:receiveDirection];
}

- (void)updateMessageFromState:(int)fState ToState:(int)tState {
    return [[IMDataManager sharedInstance] updateMessageFromState:fState ToState:tState];
}

- (NSArray *)getMsgIdsByMsgState:(int)notReadMsgState WithDirection:(int)receiveDirection {
    return [[IMDataManager sharedInstance] getMsgIdsByMsgState:notReadMsgState WithDirection:receiveDirection];
}

- (NSInteger)getMessageStateWithMsgId:(NSString *)msgId {
    return [[IMDataManager sharedInstance] getMessageStateWithMsgId:msgId];
}

- (NSArray *)getMsgIdsForDirection:(int)msgDirection WithMsgState:(int)msgState {
    return [[IMDataManager sharedInstance] getMsgIdsForDirection:msgDirection WithMsgState:msgState];
}

- (void)updateMsgIdToDidreadForNotReadMsgIdList:(NSArray *)notReadList AndSourceMsgIdList:(NSArray *)sourceMsgIdList WithDidReadState:(int)didReadState {
    [[IMDataManager sharedInstance] updateMsgIdToDidreadForNotReadMsgIdList:notReadList AndSourceMsgIdList:sourceMsgIdList WithDidReadState:didReadState];
}

- (NSArray *)searchMsgHistoryWithKey:(NSString *)key {
    return [[IMDataManager sharedInstance] searchMsgHistoryWithKey:key];
}

- (NSArray *)searchMsgIdWithKey:(NSString *)key ByXmppId:(NSString *)xmppId {
    return [[IMDataManager sharedInstance] searchMsgIdWithKey:key ByXmppId:xmppId];
}

// ******************** 最近联系人 **************************** //

- (NSArray *)getRecentContacts {
    return [[IMDataManager sharedInstance] getRecentContacts];
}

- (void)insertRecentContact:(NSDictionary *)contact {
    [[IMDataManager sharedInstance] insertRecentContact:contact];
}

- (void)removeRecentContact:(NSString *)xmppId {
    [[IMDataManager sharedInstance] removeRecentContact:xmppId];
}


#pragma mark - 消息数据方法
- (NSArray *) existsMessageUsers {
    return [[IMDataManager sharedInstance] existsMessageUsers];
}

- (long long) lastestMessageTime {
    return [[IMDataManager sharedInstance] lastestMessageTime];
}

- (long long) lastestSystemMessageTime {
    return [[IMDataManager sharedInstance] lastestSystemMessageTime];
}

- (long long) lastestMessageTimeWithNotMessageState:(long long) messageState {
    return [[IMDataManager sharedInstance] lastestMessageTimeWithNotMessageState:messageState];
}

- (NSString *) getLastMsgIdByJid:(NSString *)jid {
    return [[IMDataManager sharedInstance] getLastMsgIdByJid:jid];
}

/****************** FriendSter Msg *******************/
- (void)insertFSMsgWithMsgId:(NSString *)msgId
                  WithXmppId:(NSString *)xmppId
                WithFromUser:(NSString *)fromUser
              WithReplyMsgId:(NSString *)replyMsgId
               WithReplyUser:(NSString *)replyUser
                 WithContent:(NSString *)content
                 WihtMsgDate:(long long)msgDate
            WithExtendedFlag:(NSData *)etxtenedFlag {
    [[IMDataManager sharedInstance] insertFSMsgWithMsgId:msgId
                                             WithXmppId:xmppId
                                           WithFromUser:fromUser
                                         WithReplyMsgId:replyMsgId
                                          WithReplyUser:replyUser
                                            WithContent:content
                                            WihtMsgDate:msgDate
                                       WithExtendedFlag:etxtenedFlag];
}

- (void)bulkInsertFSMsgWithMsgList:(NSArray *)msgList {
    [[IMDataManager sharedInstance] bulkInsertFSMsgWithMsgList:msgList];
}

- (NSArray *)getFSMsgListByXmppId:(NSString *)xmppId {
    return [[IMDataManager sharedInstance] getFSMsgListByXmppId:xmppId];
}

- (NSDictionary *)getFSMsgListByReplyMsgId:(NSString *)replyMsgId {
    return [[IMDataManager sharedInstance] getFSMsgListByReplyMsgId:replyMsgId];
}

/****************** readmark *********************/
- (long long)qimDB_updateGroupMsgWihtMsgState:(int)msgState ByGroupMsgList:(NSArray *)groupMsgList {
    return [[IMDataManager sharedInstance] qimDB_updateGroupMsgWihtMsgState:msgState ByGroupMsgList:groupMsgList];
}

- (void)updateUserMsgWihtMsgState:(int)msgState ByMsgList:(NSArray *)userMsgList {
    [[IMDataManager sharedInstance] updateUserMsgWihtMsgState:msgState ByMsgList:userMsgList];
}

- (void)bulkUpdateChatMsgWithMsgState:(int)msgState ByMsgIdList:(NSArray *)msgIdList {
    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:msgState ByMsgIdList:msgIdList];
}

- (NSArray *)getReceiveMsgIdListWithMsgState:(int)msgState WithReceiveDirection:(int)receiveDirection {
    return [[IMDataManager sharedInstance] getReceiveMsgIdListWithMsgState:msgState WithReceiveDirection:receiveDirection];
}

- (NSArray *)getNotReadMsgListWithMsgState:(int)msgState WithReceiveDirection:(int)receiveDirection {
    return [[IMDataManager sharedInstance] getNotReadMsgListWithMsgState:msgState WithReceiveDirection:receiveDirection];
}

- (void)clearHistoryMsg {
    [[IMDataManager sharedInstance] clearHistoryMsg];
}

- (void)updateSystemMsgState:(int)msgState WithXmppId:(NSString *)xmppId {
    [[IMDataManager sharedInstance] updateSystemMsgState:msgState WithXmppId:xmppId];
}

- (void)closeDataBase {
    [[IMDataManager sharedInstance] closeDataBase];
}

+ (void)clearDataBaseCache {
    [IMDataManager clearDataBaseCache];
}

- (void)qimDB_dbCheckpoint {
    [[IMDataManager sharedInstance] qimDB_dbCheckpoint];
}

- (NSArray *)getPSessionListWithSingleChatType:(int)singleChatType {
    return [[IMDataManager sharedInstance] getPSessionListWithSingleChatType:singleChatType];
}

- (void)updateAllMsgWithMsgState:(int)msgState ByMsgDirection:(int)msgDirection ByReadMarkT:(long long)readMarkT {
    [[IMDataManager sharedInstance] updateAllMsgWithMsgState:msgState ByMsgDirection:msgDirection ByReadMarkT:readMarkT];
}

/*************** Friend List *************/
- (void)bulkInsertFriendList:(NSArray *)friendList {
    [[IMDataManager sharedInstance] bulkInsertFriendList:friendList];
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
    [[IMDataManager sharedInstance] insertFriendWithUserId:userId
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
    [[IMDataManager sharedInstance] deleteFriendListWithXmppId:xmppId];
}

- (void)deleteFriendListWithUserId:(NSString *)userId {
    [[IMDataManager sharedInstance] deleteFriendListWithUserId:userId];
}

- (void)deleteFriendList {
    [[IMDataManager sharedInstance] deleteFriendList];
}
- (void)deleteSessionList {
    [[IMDataManager sharedInstance] deleteSessionList];
}

- (NSMutableArray *)selectFriendList {
    return [[IMDataManager sharedInstance] selectFriendList];
}

- (NSMutableArray *)qimDB_selectFriendListInGroupId:(NSString *)groupId {
    return [[IMDataManager sharedInstance] qimDB_selectFriendListInGroupId:groupId];
}

- (NSDictionary *)selectFriendInfoWithUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] selectFriendInfoWithUserId:userId];
}
- (NSDictionary *)selectFriendInfoWithXmppId:(NSString *)xmppId {
    return [[IMDataManager sharedInstance] selectFriendInfoWithXmppId:xmppId];
}

- (void)bulkInsertFriendNotifyList:(NSArray *)notifyList {
    [[IMDataManager sharedInstance] bulkInsertFriendNotifyList:notifyList];
}

- (void)insertFriendNotifyWihtUserId:(NSString *)userId
                          WithXmppId:(NSString *)xmppId
                            WithName:(NSString *)name
                        WithDescInfo:(NSString *)descInfo
                         WithHeadSrc:(NSString *)headerSrc
                     WithSearchIndex:(NSString *)searchIndex
                        WihtUserInfo:(NSString *)userInfo
                         WithVersion:(int)version
                           WihtState:(int)state
                  WithLastUpdateTime:(long long)lastUpdateTime {
    [[IMDataManager sharedInstance] insertFriendNotifyWihtUserId:userId
                                                     WithXmppId:xmppId
                                                       WithName:name
                                                   WithDescInfo:descInfo
                                                    WithHeadSrc:headerSrc
                                                WithSearchIndex:searchIndex
                                                   WihtUserInfo:userInfo
                                                    WithVersion:version
                                                      WihtState:state
                                             WithLastUpdateTime:lastUpdateTime];
    
}
- (void)deleteFriendNotifyWithUserId:(NSString *)userId {
    [[IMDataManager sharedInstance] deleteFriendNotifyWithUserId:userId];
}

- (NSMutableArray *)selectFriendNotifys {
    return [[IMDataManager sharedInstance] selectFriendNotifys];
}

- (void)updateFriendNotifyWithXmppId:(NSString *)xmppId WihtState:(int)state {
    [[IMDataManager sharedInstance] updateFriendNotifyWithXmppId:xmppId WihtState:state];
}

- (void)updateFriendNotifyWithUserId:(NSString *)userId WihtState:(int)state {
    [[IMDataManager sharedInstance] updateFriendNotifyWithUserId:userId WihtState:state];
}

- (long long)getMaxTimeFriendNotify {
    return [[IMDataManager sharedInstance] getMaxTimeFriendNotify];
}

// ******************** 公众账号 ***************************** //
- (BOOL)checkPublicNumberMsgById:(NSString *)msgId {
    return [[IMDataManager sharedInstance] checkPublicNumberMsgById:msgId];
}

- (void)checkPublicNumbers:(NSArray *)publicNumberIds {
    [[IMDataManager sharedInstance] checkPublicNumbers:publicNumberIds];
}

- (void)bulkInsertPublicNumbers:(NSArray *)publicNumberList {
    [[IMDataManager sharedInstance] bulkInsertPublicNumbers:publicNumberList];
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
    [[IMDataManager sharedInstance] insertPublicNumberXmppId:xmppId
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
    [[IMDataManager sharedInstance] deletePublicNumberId:publicNumberId];
}

- (NSArray *)getPublicNumberVersionList {
    return [[IMDataManager sharedInstance] getPublicNumberVersionList];
}

- (NSArray *)getPublicNumberList {
    return [[IMDataManager sharedInstance] getPublicNumberList];
}

- (NSArray *)searchPublicNumberListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager sharedInstance] searchPublicNumberListByKeyStr:keyStr];
}

- (NSInteger)getRnSearchPublicNumberListByKeyStr:(NSString *)keyStr {
    return [[IMDataManager sharedInstance] getRnSearchPublicNumberListByKeyStr:keyStr];
}

- (NSArray *)rnSearchPublicNumberListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    return [[IMDataManager sharedInstance] rnSearchPublicNumberListByKeyStr:keyStr limit:limit offset:offset];
}

- (NSDictionary *)getPublicNumberCardByJId:(NSString *)jid {
    return [[IMDataManager sharedInstance] getPublicNumberCardByJId:jid];
}

- (void)insetPublicNumberMsgWihtMsgId:(NSString *)msgId
                        WithSessionId:(NSString *)sessionId
                             WithFrom:(NSString *)from
                               WithTo:(NSString *)to
                          WithContent:(NSString *)content
                         WithPlatform:(int)platform
                          WithMsgType:(int)msgType
                         WithMsgState:(int)msgState
                     WithMsgDirection:(int)msgDirection
                          WihtMsgDate:(long long)msgDate
                        WithReadedTag:(int)readedTag {
    [[IMDataManager sharedInstance] insetPublicNumberMsgWihtMsgId:msgId
                                                   WithSessionId:sessionId
                                                        WithFrom:from
                                                          WithTo:to
                                                     WithContent:content
                                                    WithPlatform:platform
                                                     WithMsgType:msgType
                                                    WithMsgState:msgState
                                                WithMsgDirection:msgDirection
                                                     WihtMsgDate:msgDate
                                                   WithReadedTag:readedTag];
}

- (NSArray *)getMsgListByPublicNumberId:(NSString *)publicNumberId
                              WithLimit:(int)limit
                             WihtOffset:(int)offset
                         WithFilterType:(NSArray *)actionTypes {
    return [[IMDataManager sharedInstance] getMsgListByPublicNumberId:publicNumberId WithLimit:limit WihtOffset:offset WithFilterType:actionTypes];
}

/****************** Collection Msg *******************/

- (NSArray *)getCollectionAccountList {
    return [[IMDataManager sharedInstance] getCollectionAccountList];
}

- (void)bulkinsertCollectionAccountList:(NSArray *)accounts {
    [[IMDataManager sharedInstance] bulkinsertCollectionAccountList:accounts];
}


- (NSDictionary *)selectCollectionUserByJID:(NSString *)jid {
    return [[IMDataManager sharedInstance] selectCollectionUserByJID:jid];
}

- (void)bulkInsertCollectionUserCards:(NSArray *)userCards {
    [[IMDataManager sharedInstance] bulkInsertCollectionUserCards:userCards];
}

- (void)bulkInsertCollectionGroupCards:(NSArray *)groupCards {
    [[IMDataManager sharedInstance] bulkInsertCollectionGroupCards:groupCards];
}

- (NSDictionary *)getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId {
    return [[IMDataManager sharedInstance] getLastCollectionMsgWithLastMsgId:lastMsgId];;
}

- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId {
    return [[IMDataManager sharedInstance] getCollectionSessionListWithBindId:bindId];
}

- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId {
    return [[IMDataManager sharedInstance] getCollectionMsgListWithBindId:bindId];
}

- (BOOL)checkCollectionMsgById:(NSString *)msgId {
    return [[IMDataManager sharedInstance] checkCollectionMsgById:msgId];
}

- (void)bulkInsertCollectionMsgWihtMsgDics:(NSArray *)msgs {
    [[IMDataManager sharedInstance] bulkInsertCollectionMsgWihtMsgDics:msgs];
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState {
    return [[IMDataManager sharedInstance] getCollectionMsgNotReadCountByDidReadState:readState];
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId {
    return [[IMDataManager sharedInstance] getCollectionMsgNotReadCountByDidReadState:readState ForBindId:bindId];
}

- (NSInteger)getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId {
    return [[IMDataManager sharedInstance] getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:readState ForBindId:bindId originUserId:originUserId];
}

- (void)updateCollectionMsgNotReadStateByJid:(NSString *)jid WithMsgState:(NSInteger)msgState {
    [[IMDataManager sharedInstance] updateCollectionMsgNotReadStateByJid:jid WithMsgState:msgState];
}

- (void)updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithMsgState:(NSInteger)msgState {
    [[IMDataManager sharedInstance] updateCollectionMsgNotReadStateForBindId:bindId originUserId:originUserId WithMsgState:msgState];
}

- (NSDictionary *)getCollectionMsgListForMsgId:(NSString *)msgId {
    return [[IMDataManager sharedInstance] getCollectionMsgListForMsgId:msgId];
}

- (NSArray *)getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId {
    return [[IMDataManager sharedInstance] getCollectionMsgListWithUserId:userId originUserId:originUserId];
}

/*********************** Group Message State **************************/
- (long long)qimDB_bulkUpdateGroupMessageReadFlag:(NSArray *)mucArray {
    return [[IMDataManager sharedInstance] qimDB_bulkUpdateGroupMessageReadFlag:mucArray];
}

- (void)qimDB_bulkUpdateGroupPushState:(NSArray *)stateList {
    [[IMDataManager sharedInstance] qimDB_bulkUpdateGroupPushState:stateList];
}

- (int)getGroupPushStateWithGroupId:(NSString *)groupId {
    return [[IMDataManager sharedInstance] getGroupPushStateWithGroupId:groupId];
}

- (void)updateGroup:(NSString *)groupId WithPushState:(int)pushState {
    [[IMDataManager sharedInstance] updateGroup:groupId WithPushState:pushState];
}

/*********************** QTNotes **********************/

//Main

- (BOOL)checkExitsMainItemWithQid:(NSInteger)qid WithCId:(NSInteger)cid {
    return [[IMDataManager sharedInstance] checkExitsMainItemWithQid:qid WithCId:cid];
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
    [[IMDataManager sharedInstance] insertQTNotesMainItemWithQId:qid
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
    [[IMDataManager sharedInstance] updateToMainWithQId:qid WithCid:cid WithQType:qtype WithQTitle:qtitle WithQDescInfo:qdescInfo WithQContent:qcontent WithQTime:qtime WithQState:qstate WithQExtendedFlag:qExtendedFlag];
}

- (void)updateToMainItemWithDicts:(NSArray *)mainItemList {
    [[IMDataManager sharedInstance] updateToMainItemWithDicts:mainItemList];
}

- (void)deleteToMainWithQid:(NSInteger)qid {
    [[IMDataManager sharedInstance] deleteToMainWithQid:qid];
}

- (void)deleteToMainWithCid:(NSInteger)cid {
    [[IMDataManager sharedInstance] deleteToMainWithCid:cid];
}

- (void)updateToMainItemTimeWithQId:(NSInteger)qid
                          WithQTime:(NSInteger)qTime
                  WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager sharedInstance] updateToMainItemTimeWithQId:qid WithQTime:qTime WithQExtendedFlag:qExtendedFlag];
}

- (void)updateMainStateWithQid:(NSInteger)qid
                       WithCid:(NSInteger)cid
                    WithQState:(NSInteger)qstate
             WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[IMDataManager sharedInstance] updateMainStateWithQid:qid WithCid:cid WithQState:qstate WithQExtendedFlag:qExtendedFlag];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithQType:qType];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType QString:(NSString *)qString {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithQType:qType QString:qString];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithExceptQState:(NSInteger)qState {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithQType:qType WithExceptQState:qState];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithQState:(NSInteger)qState {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithQType:qType WithQState:qState];
}

- (NSArray *)getQTNoteMainItemWithQType:(NSInteger)qType WithQDescInfo:(NSString *)descInfo {
    return [[IMDataManager sharedInstance] getQTNoteMainItemWithQType:qType WithQDescInfo:descInfo];
}

- (NSArray *)getQTNotesMainItemWithQExtendFlag:(NSInteger)qExtendFlag {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithQExtendFlag:qExtendFlag];
}

- (NSArray *)getQTNotesSubItemWithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithQSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesMainItemWithQExtendedFlag:(NSInteger)qExtendedFlag needConvertToString:(BOOL)flag {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithQExtendedFlag:qExtendedFlag needConvertToString:flag];
}

- (NSDictionary *)getQTNotesMainItemWithCid:(NSInteger)cid {
    return [[IMDataManager sharedInstance] getQTNotesMainItemWithCid:cid];
}

- (NSInteger)getQTNoteMainItemMaxTimeWithQType:(NSInteger)qType {
    return [[IMDataManager sharedInstance] getQTNoteMainItemMaxTimeWithQType:qType];
}

- (NSInteger)getMaxQTNoteMainItemCid {
    return [[IMDataManager sharedInstance] getMaxQTNoteMainItemCid];
}

//Sub

- (BOOL)checkExitsSubItemWithQsid:(NSInteger)qsid WithCsid:(NSInteger)csid {
    return [[IMDataManager sharedInstance] checkExitsSubItemWithQsid:qsid WithCsid:csid];
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
    [[IMDataManager sharedInstance] insertQTNotesSubItemWithCId:cid WithQSId:qsid WithCSId:csid WithQSType:qstype WithQSTitle:qstitle WithQSIntroduce:qsIntroduce WithQSContent:qsContent WithQSTime:qsTime WithQState:qSstate WithQS_ExtendedFlag:qs_ExtendedFlag];
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
    [[IMDataManager sharedInstance] updateToSubWithCid:cid WithQSid:qsid WithCSid:csid WithQSTitle:qSTitle WithQSDescInfo:qsDescInfo WithQSContent:qsContent WithQSTime:qsTime WithQSState:qsState WithQS_ExtendedFlag:qs_ExtendedFlag];
}

- (void)updateToSubItemWithDicts:(NSArray *)subItemList {
    [[IMDataManager sharedInstance] updateToSubItemWithDicts:subItemList];
}

- (void)deleteToSubWithCId:(NSInteger)cid {
    [[IMDataManager sharedInstance] deleteToSubWithCId:cid];
}

- (void)deleteToSubWithCSId:(NSInteger)Csid {
    [[IMDataManager sharedInstance] deleteToSubWithCSId:Csid];
}

- (void)updateSubStateWithCSId:(NSInteger)Csid
                   WithQSState:(NSInteger)qsState
            WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[IMDataManager sharedInstance] updateSubStateWithCSId:Csid WithQSState:qsState WithQsExtendedFlag:qsExtendedFlag];
}

- (void)updateToSubItemTimeWithCSId:(NSInteger)csid
                         WithQSTime:(NSInteger)qsTime
                 WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[IMDataManager sharedInstance] updateToSubItemTimeWithCSId:csid WithQSTime:qsTime WithQsExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag needConvertToString:(BOOL)flag {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag needConvertToString:flag];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid QSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithCid:cid QSExtendedFlag:qsExtendedFlag];
}

- (NSArray *)getQTNotesSubItemWithQSState:(NSInteger)qsState {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithExpectQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSState:(NSInteger)qsState {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithCid:cid WithQSState:qsState];
}

- (NSDictionary *)getQTNotesSubItemWithCid:(NSInteger)cid WithUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithCid:cid WithUserId:userId];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithCid:cid WithExpectQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithQSState:(NSInteger)qsState {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithCid:cid WithQSType:qsType WithQSState:qsState];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithExpectQSState:(NSInteger)qsState {
    return [[IMDataManager sharedInstance] getQTNotesSubItemWithCid:cid WithQSType:qsType WithExpectQSState:qsType];
}

- (NSInteger)getQTNoteSubItemMaxTimeWithCid:(NSInteger)cid
                                 WithQSType:(NSInteger)qsType {
    return [[IMDataManager sharedInstance] getQTNoteSubItemMaxTimeWithCid:cid WithQSType:qsType];
}

- (NSDictionary *)getQTNoteSubItemWithParmDict:(NSDictionary *)paramDict {
    return [[IMDataManager sharedInstance] getQTNoteSubItemWithParmDict:paramDict];
}

- (NSInteger)getMaxQTNoteSubItemCSid {
    return [[IMDataManager sharedInstance] getMaxQTNoteSubItemCSid];
}

@end
