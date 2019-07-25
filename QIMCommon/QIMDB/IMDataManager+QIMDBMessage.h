//
//  IMDataManager+QIMDBMessage.h
//  QIMCommon
//
//  Created by 李露 on 11/24/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+QIMSession.h"
#import "IMDataManager+QIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+QIMDBClientConfig.h"
#import "IMDataManager+QIMDBQuickReply.h"
#import "IMDataManager+QIMNote.h"
#import "IMDataManager+QIMDBGroup.h"
#import "IMDataManager+QIMDBFriend.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"
#import "QIMPublicRedefineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMDBMessage)

- (void)qimDB_updateMsgTimeToMillSecond;

- (long long)qimDB_getMinMsgTimeStampByXmppId:(NSString *)xmppId RealJid:(NSString *)realJid;

- (long long)qimDB_getMinMsgTimeStampByXmppId:(NSString *)xmppId;

- (long long)qimDB_lastestGroupMessageTime;

- (long long)qimDB_getMaxMsgTimeStampByXmppId:(NSString *)xmppId;
- (long long)qimDB_getMaxMsgTimeStampByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid;

- (void)qimDB_updateMessageWithMsgId:(NSString *)msgId
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

- (void)qimDB_updateMessageWithMsgId:(NSString *)msgId
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

- (void)qimDB_revokeMessageByMsgList:(NSArray *)revokeMsglist;

- (void)qimDB_revokeMessageByMsgId:(NSString *)msgId
                       WithContent:(NSString *)content
                       WithMsgType:(int)msgType;

- (void)qimDB_updateMessageWithExtendInfo:(NSString *)extendInfo ForMsgId:(NSString *)msgId;

- (void)qimDB_deleteMessageWithXmppId:(NSString *)xmppId;

- (void)qimDB_deleteMessageByMessageId:(NSString *)messageId ByJid:(NSString *)sid;

- (void)qimDB_updateMessageWithMsgId:(NSString *)msgId
                          WithMsgRaw:(NSString *)msgRaw;

- (void)qimDB_insertMessageWithMsgDic:(NSDictionary *)msgDic;

- (BOOL)qimDB_checkMsgId:(NSString *)msgId;

- (NSMutableArray *)qimDB_searchLocalMessageByKeyword:(NSString *)keyWord
                                               XmppId:(NSString *)xmppid
                                              RealJid:(NSString *)realJid;

#pragma mark - 插入群JSON消息
- (long long)qimDB_bulkInsertIphoneHistoryGroupJSONMsg:(NSArray *)list WithAtAllMsgList:(NSMutableArray<NSDictionary *> **)atAllMsgList WithNormaleAtMsgList:(NSMutableArray <NSDictionary *> **)normalMsgList;

//群翻页消息
- (NSArray *)qimDB_bulkInsertIphoneMucPageJSONMsg:(NSArray *)list withInsertDBFlag:(BOOL)flag;
- (NSArray *)qimDB_bulkInsertIphoneMucPageJSONMsg:(NSArray *)list;

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

/**
 插入离线单人JSON消息
 
 @param list 消息数组
 @param meJid 自身Id
 @param didReadState 是否已读
 */
#pragma mark - 插入离线单人JSON消息
- (long long)qimDB_bulkInsertHistoryChatJSONMsg:(NSArray *)list;

- (NSString *)qimDB_getC2BMessageFeedBackWithMsgId:(NSString *)msgId;

#pragma mark - 单人JSON历史消息翻页
- (NSArray *)qimDB_bulkInsertPageHistoryChatJSONMsg:(NSArray *)list
                                         WithXmppId:(NSString *)xmppId;

- (NSArray *)qimDB_bulkInsertPageHistoryChatJSONMsg:(NSArray *)list
                                         WithXmppId:(NSString *)xmppId
                                   withInsertDBFlag:(BOOL)flag;

- (BOOL)qimDB_bulkInsertMessage:(NSArray *)msgList;

- (void)qimDB_bulkInsertMessage:(NSArray *)msgList WithSessionId:(NSString *)sessionId;

- (void)qimDB_updateMsgState:(int)msgState WithMsgId:(NSString *)msgId;

- (void)qimDB_updateMsgDate:(long long)msgDate WithMsgId:(NSString *)msgId;

// 0 未读 1是读过了
- (void)qimDB_updateMessageReadStateWithMsgId:(NSString *)msgId;

//批量更新消息阅读状态
- (void)qimDB_bulkUpdateMessageReadStateWithMsg:(NSArray *)msgs;

- (long long)qimDB_getReadedTimeStampForUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithMsgDirection:(int)msgDirection withUnReadCount:(NSInteger)unReadCount;

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId ForRealJid:(NSString *)realJid;

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId;

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId;

- (NSDictionary *)qimDB_getMsgsByMsgId:(NSString *)msgId;

- (NSArray *)qimDB_getMsgsByMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)qimDB_getMsgsByMsgType:(int)msgType ByXmppId:(NSString *)xmppId;

- (NSArray *)qimDB_getMsgsByMsgType:(int)msgType;

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset;

- (NSArray *)qimDB_getMsgListByXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp;

- (NSArray *)qimDB_getMsgListByXmppId:(NSString *)xmppId FromTimeStamp:(long long)timeStamp;

- (NSInteger)qimDB_getSumNotReaderMsgCountByXmppIds:(NSArray *)xmppIds;

- (NSInteger)qimDB_getNotReaderMsgCountByJid:(NSString *)jid ByRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (NSInteger)qimDB_getNotReaderMsgCountByJid:(NSString *)jid ByRealJid:(NSString *)realJid;

- (void)qimDB_updateMessageFromState:(int)fState ToState:(int)tState;

- (NSInteger)qimDB_getMessageStateWithMsgId:(NSString *)msgId;

- (NSInteger)qimDB_getReadStateWithMsgId:(NSString *)msgId;

- (NSArray *)qimDB_getMsgIdsForDirection:(int)msgDirection WithMsgState:(int)msgState;

- (NSArray *)qimDB_searchMsgHistoryWithKey:(NSString *)key;

- (NSArray *)qimDB_searchMsgIdWithKey:(NSString *)key ByXmppId:(NSString *)xmppId;

#pragma mark - 消息数据方法

- (NSString *)qimDB_getLastMsgIdByJid:(NSString *)jid;

- (long long)qimDB_getMsgTimeWithMsgId:(NSString *)msgId;

- (long long)qimDB_getLastMsgTimeIdByJid:(NSString *)jid;

- (long long)qimDB_lastestMessageTime;

- (long long)qimDB_lastestSystemMessageTime;

- (long long)qimDB_bulkUpdateGroupMessageReadFlag:(NSArray *)mucArray;

- (void)qimDB_clearHistoryMsg;

- (void)qimDB_updateSystemMsgState:(int)msgState withReadState:(QIMMessageRemoteReadState)readState WithXmppId:(NSString *)xmppId;

#pragma mark - 阅读状态

- (NSArray *)qimDB_getReceiveMsgIdListWithMsgReadFlag:(QIMMessageRemoteReadState)remoteReadState withChatType:(ChatType)chatType withMsgDirection:(QIMMessageDirection)receiveDirection;

- (void)qimDB_updateAllMsgWithMsgRemoteState:(NSInteger)msgRemoteFlag ByMsgDirection:(int)msgDirection ByReadMarkT:(long long)readMarkT;

- (void)qimDB_updateGroupMessageRemoteState:(NSInteger)msgRemoteFlag ByGroupReadList:(NSArray *)groupReadList;

- (void)qimDB_updateMsgWithMsgRemoteState:(NSInteger)msgRemoteFlag ByMsgIdList:(NSArray *)msgIdList;

#pragma mark - 本地消息搜索

- (NSArray *)qimDB_getLocalMediaByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

- (NSArray *)qimDB_getMsgsByKeyWord:(NSString *)keywords ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid;

#pragma mark - AT消息
- (void)qimDB_insertAtMessageWithGroupId:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime;

- (void)qimDB_UpdateAtMessageReadStateWithGroupId:(NSString *)groupId withReadState:(QIMAtMsgReadState)readState;

- (void)qimDB_UpdateAtMessageReadStateWithGroupId:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(QIMAtMsgReadState)readState;

- (NSDictionary *)qimDB_getTotalAtMessageDic;

- (NSArray *)qimDB_getAtMessageWithGroupId:(NSString *)groupId;

- (void)qimDB_clearAtMessageWithGroupReadMarkArray:(NSArray *)groupReadMarkArray;

- (BOOL)qimDB_clearAtMessageWithGroupId:(NSString *)groupId withMsgId:(NSString *)msgId;

- (BOOL)qimDB_clearAtMessageWithGroupId:(NSString *)groupId;

- (BOOL)qimDB_clearAtMessage;

@end

NS_ASSUME_NONNULL_END
