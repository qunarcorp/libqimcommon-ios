//
//  IMDataManager+STIMDBMessage.h
//  STIMCommon
//
//  Created by 李露 on 11/24/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"
#import "STIMPublicRedefineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMDBMessage)

- (void)stIMDB_updateMsgTimeToMillSecond;

- (long long)stIMDB_getMinMsgTimeStampByXmppId:(NSString *)xmppId RealJid:(NSString *)realJid;

- (long long)stIMDB_getMinMsgTimeStampByXmppId:(NSString *)xmppId;

- (long long)stIMDB_lastestGroupMessageTime;

- (long long)stIMDB_getMaxMsgTimeStampByXmppId:(NSString *)xmppId;
- (long long)stIMDB_getMaxMsgTimeStampByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid;

- (void)stIMDB_updateMessageWithMsgId:(NSString *)msgId
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
                        ExtendedFlag:(int)ExtendedFlag;

- (void)stIMDB_updateMessageWithMsgId:(NSString *)msgId
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
                          WithMsgRaw:(NSString *)msgRaw;

- (void)stIMDB_revokeMessageByMsgList:(NSArray *)revokeMsglist;

- (void)stIMDB_revokeMessageByMsgId:(NSString *)msgId
                       WithContent:(NSString *)content
                       WithMsgType:(int)msgType;

- (void)stIMDB_updateMessageWithExtendInfo:(NSString *)extendInfo ForMsgId:(NSString *)msgId;

- (void)stIMDB_deleteMessageWithXmppId:(NSString *)xmppId;

- (void)stIMDB_deleteMessageByMessageId:(NSString *)messageId ByJid:(NSString *)sid;

- (void)stIMDB_updateMessageWithMsgId:(NSString *)msgId
                          WithMsgRaw:(NSString *)msgRaw;

- (void)stIMDB_insertMessageWithMsgDic:(NSDictionary *)msgDic;

- (BOOL)stIMDB_checkMsgId:(NSString *)msgId;

- (NSMutableArray *)stIMDB_searchLocalMessageByKeyword:(NSString *)keyWord
                                               XmppId:(NSString *)xmppid
                                              RealJid:(NSString *)realJid;

#pragma mark - 插入群JSON消息
- (long long)stIMDB_bulkInsertIphoneHistoryGroupJSONMsg:(NSArray *)list WithAtAllMsgList:(NSMutableArray<NSDictionary *> **)atAllMsgList WithNormaleAtMsgList:(NSMutableArray <NSDictionary *> **)normalMsgList;

//群翻页消息
- (NSArray *)stIMDB_bulkInsertIphoneMucPageJSONMsg:(NSArray *)list withInsertDBFlag:(BOOL)flag;
- (NSArray *)stIMDB_bulkInsertIphoneMucPageJSONMsg:(NSArray *)list;

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/**
 插入离线单人JSON消息
 
 @param list 消息数组
 @param meJid 自身Id
 @param didReadState 是否已读
 */
#pragma mark - 插入离线单人JSON消息
- (long long)stIMDB_bulkInsertHistoryChatJSONMsg:(NSArray *)list;

- (NSString *)stIMDB_getC2BMessageFeedBackWithMsgId:(NSString *)msgId;

#pragma mark - 单人JSON历史消息翻页
- (NSArray *)stIMDB_bulkInsertPageHistoryChatJSONMsg:(NSArray *)list
                                         WithXmppId:(NSString *)xmppId;

- (NSArray *)stIMDB_bulkInsertPageHistoryChatJSONMsg:(NSArray *)list
                                         WithXmppId:(NSString *)xmppId
                                   withInsertDBFlag:(BOOL)flag;

- (BOOL)stIMDB_bulkInsertMessage:(NSArray *)msgList;

- (void)stIMDB_bulkInsertMessage:(NSArray *)msgList WithSessionId:(NSString *)sessionId;

- (void)stIMDB_updateMsgState:(int)msgState WithMsgId:(NSString *)msgId;

- (void)stIMDB_updateMsgDate:(long long)msgDate WithMsgId:(NSString *)msgId;

// 0 未读 1是读过了
- (void)stIMDB_updateMessageReadStateWithMsgId:(NSString *)msgId;

//批量更新消息阅读状态
- (void)stIMDB_bulkUpdateMessageReadStateWithMsg:(NSArray *)msgs;

- (long long)stIMDB_getReadedTimeStampForUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithMsgDirection:(int)msgDirection withUnReadCount:(NSInteger)unReadCount;

- (NSArray *)stIMDB_getNotReadMsgListForUserId:(NSString *)userId ForRealJid:(NSString *)realJid;

- (NSArray *)stIMDB_getNotReadMsgListForUserId:(NSString *)userId;

- (NSArray *)stIMDB_getMgsListBySessionId:(NSString *)sesId;

- (NSDictionary *)stIMDB_getMsgsByMsgId:(NSString *)msgId;

- (NSArray *)stIMDB_getMsgsByMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)stIMDB_getMsgsByMsgType:(int)msgType ByXmppId:(NSString *)xmppId;

- (NSArray *)stIMDB_getMsgsByMsgType:(int)msgType;

- (NSArray *)stIMDB_getMgsListBySessionId:(NSString *)sesId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset;

- (NSArray *)stIMDB_getMsgListByXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp;

- (NSArray *)stIMDB_getMsgListByXmppId:(NSString *)xmppId FromTimeStamp:(long long)timeStamp;

- (NSInteger)stIMDB_getSumNotReaderMsgCountByXmppIds:(NSArray *)xmppIds;

- (NSInteger)stIMDB_getNotReaderMsgCountByJid:(NSString *)jid ByRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (NSInteger)stIMDB_getNotReaderMsgCountByJid:(NSString *)jid ByRealJid:(NSString *)realJid;

- (void)stIMDB_updateMessageFromState:(int)fState ToState:(int)tState;

- (NSInteger)stIMDB_getMessageStateWithMsgId:(NSString *)msgId;

- (NSInteger)stIMDB_getReadStateWithMsgId:(NSString *)msgId;

- (NSArray *)stIMDB_getMsgIdsForDirection:(int)msgDirection WithMsgState:(int)msgState;

- (NSArray *)stIMDB_searchMsgHistoryWithKey:(NSString *)key;

- (NSArray *)stIMDB_searchMsgIdWithKey:(NSString *)key ByXmppId:(NSString *)xmppId;

#pragma mark - 消息数据方法

- (NSString *)stIMDB_getLastMsgIdByJid:(NSString *)jid;

- (long long)stIMDB_getMsgTimeWithMsgId:(NSString *)msgId;

- (long long)stIMDB_getLastMsgTimeIdByJid:(NSString *)jid;

- (long long)stIMDB_lastestMessageTime;

- (long long)stIMDB_lastestSystemMessageTime;

- (long long)stIMDB_bulkUpdateGroupMessageReadFlag:(NSArray *)mucArray;

- (void)stIMDB_clearHistoryMsg;

- (void)stIMDB_updateSystemMsgState:(int)msgState withReadState:(STIMMessageRemoteReadState)readState WithXmppId:(NSString *)xmppId;

#pragma mark - 阅读状态

- (NSArray *)stIMDB_getReceiveMsgIdListWithMsgReadFlag:(STIMMessageRemoteReadState)remoteReadState withChatType:(ChatType)chatType withMsgDirection:(STIMMessageDirection)receiveDirection;

- (void)stIMDB_updateAllMsgWithMsgRemoteState:(NSInteger)msgRemoteFlag ByMsgDirection:(int)msgDirection ByReadMarkT:(long long)readMarkT;

- (void)stIMDB_updateGroupMessageRemoteState:(NSInteger)msgRemoteFlag ByGroupReadList:(NSArray *)groupReadList;

- (void)stIMDB_updateMsgWithMsgRemoteState:(NSInteger)msgRemoteFlag ByMsgIdList:(NSArray *)msgIdList;

#pragma mark - 本地消息搜索

- (NSArray *)stIMDB_getLocalMediaByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)stIMDB_getMsgsByKeyWord:(NSString *)keywords ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

#pragma mark - AT消息
- (void)stIMDB_insertAtMessageWithGroupId:(NSString *)groupId withType:(STIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime;

- (void)stIMDB_UpdateAtMessageReadStateWithGroupId:(NSString *)groupId withReadState:(STIMAtMsgReadState)readState;

- (void)stIMDB_UpdateAtMessageReadStateWithGroupId:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(STIMAtMsgReadState)readState;

- (NSDictionary *)stIMDB_getTotalAtMessageDic;

- (NSArray *)stIMDB_getAtMessageWithGroupId:(NSString *)groupId;

- (void)stIMDB_clearAtMessageWithGroupReadMarkArray:(NSArray *)groupReadMarkArray;

- (BOOL)stIMDB_clearAtMessageWithGroupId:(NSString *)groupId withMsgId:(NSString *)msgId;

- (BOOL)stIMDB_clearAtMessageWithGroupId:(NSString *)groupId;

- (BOOL)stIMDB_clearAtMessage;

@end

NS_ASSUME_NONNULL_END
