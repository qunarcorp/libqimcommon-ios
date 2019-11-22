//
//  IMDataManager+STIMSession.h
//  STIMCommon
//
//  Created by 李露 on 2018/7/5.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

@interface IMDataManager (STIMSession)

- (void)stIMDB_updateSessionLastMsgIdWithSessionId:(NSString *)sessionId
                                    WithLastMsgId:(NSString *)lastMsgId;

- (long long)stIMDB_insertSessionWithMsgList:(NSDictionary *)msgLists;

- (long long)stIMDB_insertGroupSessionWithMsgList:(NSDictionary *)tempGroupDic;

- (void)stIMDB_insertSessionWithSessionId:(NSString *)sessinId
                              WithUserId:(NSString *)userId
                           WithLastMsgId:(NSString *)lastMsgId
                      WithLastUpdateTime:(long long)lastUpdateTime
                                ChatType:(int)ChatType
                             WithRealJid:(id)realJid;

- (void)stIMDB_deleteSession:(NSString *)xmppId RealJid:(NSString *)realJid;

- (void)stIMDB_deleteSessionList:(NSArray *)xmppIds;

- (void)stIMDB_deleteSession:(NSString *)xmppId;

- (NSDictionary *)stIMDB_getLastedSingleChatSession;

- (NSArray *)stIMDB_getFullSessionListWithSingleChatType:(int)singleChatType;

- (NSArray *)stIMDB_getNotReadSessionList;

- (NSArray *)stIMDB_getSessionListWithSingleChatType:(int)singleChatType;

- (NSArray *)stIMDB_getSessionListXMPPIDWithSingleChatType:(int)singleChatType;

- (NSDictionary *)stIMDB_getChatSessionWithUserId:(NSString *)userId chatType:(int)chatType;

- (NSDictionary *)stIMDB_getChatSessionWithUserId:(NSString *)userId WithRealJid:(NSString *)realJid;

- (NSDictionary *)stIMDB_getChatSessionWithUserId:(NSString *)userId;

- (NSInteger)stIMDB_getAppNotReadCount;

@end
