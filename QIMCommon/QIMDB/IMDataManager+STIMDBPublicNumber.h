//
//  IMDataManager+STIMDBPublicNumber.h
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
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMDBPublicNumber)

#pragma mark - 公众账号
// ******************** 公众账号 ***************************** //

- (NSDictionary *)stIMDB_getPublicNumberSession;

- (BOOL)stIMDB_checkPublicNumberMsgById:(NSString *)msgId;

- (void)stIMDB_checkPublicNumbers:(NSArray *)publicNumberIds;

- (void)stIMDB_bulkInsertPublicNumbers:(NSArray *)publicNumberList;

- (void)stIMDB_insertPublicNumberXmppId:(NSString *)xmppId
                    WithPublicNumberId:(NSString *)publicNumberId
                  WithPublicNumberType:(int)publicNumberType
                              WithName:(NSString *)name
                         WithHeaderSrc:(NSString *)headerSrc
                          WithDescInfo:(NSString *)descInfo
                       WithSearchIndex:(NSString *)searchIndex
                        WithPublicInfo:(NSString *)publicInfo
                           WithVersion:(int)version;

- (void)stIMDB_deletePublicNumberId:(NSString *)publicNumberId;

- (NSArray *)stIMDB_getPublicNumberVersionList;

- (NSArray *)stIMDB_getPublicNumberList;

- (NSArray *)stIMDB_searchPublicNumberListByKeyStr:(NSString *)keyStr;

- (NSInteger)stIMDB_getRnSearchPublicNumberListByKeyStr:(NSString *)keyStr;

- (NSArray *)stIMDB_rnSearchPublicNumberListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset;

- (NSDictionary *)stIMDB_getPublicNumberCardByJId:(NSString *)jid;

- (void)stIMDB_insetPublicNumberMsgWithMsgId:(NSString *)msgId
                              WithSessionId:(NSString *)sessionId
                                   WithFrom:(NSString *)from
                                     WithTo:(NSString *)to
                                WithContent:(NSString *)content
                               WithPlatform:(int)platform
                                WithMsgType:(int)msgType
                               WithMsgState:(int)msgState
                           WithMsgDirection:(int)msgDirection
                                WithMsgDate:(long long)msgDate
                              WithReadedTag:(int)readedTag;

- (NSArray *)stIMDB_getMsgListByPublicNumberId:(NSString *)publicNumberId
                                    WithLimit:(int)limit
                                   WithOffset:(int)offset
                               WithFilterType:(NSArray *)actionTypes;

@end

NS_ASSUME_NONNULL_END
