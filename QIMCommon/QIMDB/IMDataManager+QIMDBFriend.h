//
//  IMDataManager+QIMDBFriend.h
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
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMDBFriend)

/*************** Friend List *************/

- (void)qimDB_bulkInsertFriendList:(NSArray *)friendList;

- (void)qimDB_insertFriendWithUserId:(NSString *)userId
                          WithXmppId:(NSString *)xmppId
                            WithName:(NSString *)name
                     WithSearchIndex:(NSString *)searchIndex
                        WithDescInfo:(NSString *)descInfo
                         WithHeadSrc:(NSString *)headerSrc
                        WithUserInfo:(NSData *)userInfo
                  WithLastUpdateTime:(long long)lastUpdateTime
                WithIncrementVersion:(int)incrementVersion;

- (void)qimDB_deleteFriendListWithXmppId:(NSString *)xmppId;

- (void)qimDB_deleteFriendListWithUserId:(NSString *)userId;

- (void)qimDB_deleteFriendList;

- (void)qimDB_deleteSessionList;

- (NSMutableArray *)qimDB_selectFriendList;

- (NSMutableArray *)qimDB_selectFriendListInGroupId:(NSString *)groupId;

- (NSDictionary *)qimDB_selectFriendInfoWithUserId:(NSString *)userId;

- (NSDictionary *)qimDB_selectFriendInfoWithXmppId:(NSString *)xmppId;

- (void)qimDB_bulkInsertNotifyList:(NSArray *)notifyList;

- (void)qimDB_bulkInsertFriendNotifyList:(NSArray *)notifyList;

- (void)qimDB_insertFriendNotifyWithUserId:(NSString *)userId
                                WithXmppId:(NSString *)xmppId
                                  WithName:(NSString *)name
                              WithDescInfo:(NSString *)descInfo
                               WithHeadSrc:(NSString *)headerSrc
                           WithSearchIndex:(NSString *)searchIndex
                              WithUserInfo:(NSString *)userInfo
                               WithVersion:(int)version
                                 WithState:(int)state
                        WithLastUpdateTime:(long long)lastUpdateTime;

- (void)qimDB_deleteFriendNotifyWithUserId:(NSString *)userId;

- (NSMutableArray *)qimDB_selectFriendNotifys;

- (NSDictionary *)qimDB_getLastFriendNotify;

- (int)qimDB_getFriendNotifyCount;

- (void)qimDB_updateFriendNotifyWithXmppId:(NSString *)xmppId WithState:(int)state;

- (long long)qimDB_getMaxTimeFriendNotify;

@end

NS_ASSUME_NONNULL_END
