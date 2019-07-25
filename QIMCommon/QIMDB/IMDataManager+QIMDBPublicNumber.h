//
//  IMDataManager+QIMDBPublicNumber.h
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
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMDBPublicNumber)

#pragma mark - 公众账号
// ******************** 公众账号 ***************************** //

- (NSDictionary *)qimDB_getPublicNumberSession;

- (BOOL)qimDB_checkPublicNumberMsgById:(NSString *)msgId;

- (void)qimDB_checkPublicNumbers:(NSArray *)publicNumberIds;

- (void)qimDB_bulkInsertPublicNumbers:(NSArray *)publicNumberList;

- (void)qimDB_insertPublicNumberXmppId:(NSString *)xmppId
                    WithPublicNumberId:(NSString *)publicNumberId
                  WithPublicNumberType:(int)publicNumberType
                              WithName:(NSString *)name
                         WithHeaderSrc:(NSString *)headerSrc
                          WithDescInfo:(NSString *)descInfo
                       WithSearchIndex:(NSString *)searchIndex
                        WithPublicInfo:(NSString *)publicInfo
                           WithVersion:(int)version;

- (void)qimDB_deletePublicNumberId:(NSString *)publicNumberId;

- (NSArray *)qimDB_getPublicNumberVersionList;

- (NSArray *)qimDB_getPublicNumberList;

- (NSArray *)qimDB_searchPublicNumberListByKeyStr:(NSString *)keyStr;

- (NSInteger)qimDB_getRnSearchPublicNumberListByKeyStr:(NSString *)keyStr;

- (NSArray *)qimDB_rnSearchPublicNumberListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset;

- (NSDictionary *)qimDB_getPublicNumberCardByJId:(NSString *)jid;

- (void)qimDB_insetPublicNumberMsgWithMsgId:(NSString *)msgId
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

- (NSArray *)qimDB_getMsgListByPublicNumberId:(NSString *)publicNumberId
                                    WithLimit:(int)limit
                                   WithOffset:(int)offset
                               WithFilterType:(NSArray *)actionTypes;

@end

NS_ASSUME_NONNULL_END
