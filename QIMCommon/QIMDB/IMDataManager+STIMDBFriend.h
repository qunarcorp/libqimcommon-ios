//
//  IMDataManager+STIMDBFriend.h
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
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMDBFriend)

/*************** Friend List *************/

- (void)stIMDB_bulkInsertFriendList:(NSArray *)friendList;

- (void)stIMDB_insertFriendWithUserId:(NSString *)userId
                          WithXmppId:(NSString *)xmppId
                            WithName:(NSString *)name
                     WithSearchIndex:(NSString *)searchIndex
                        WithDescInfo:(NSString *)descInfo
                         WithHeadSrc:(NSString *)headerSrc
                        WithUserInfo:(NSData *)userInfo
                  WithLastUpdateTime:(long long)lastUpdateTime
                WithIncrementVersion:(int)incrementVersion;

- (void)stIMDB_deleteFriendListWithXmppId:(NSString *)xmppId;

- (void)stIMDB_deleteFriendListWithUserId:(NSString *)userId;

- (void)stIMDB_deleteFriendList;

- (void)stIMDB_deleteSessionList;

- (NSMutableArray *)stIMDB_selectFriendList;

- (NSMutableArray *)stIMDB_selectFriendListInGroupId:(NSString *)groupId;

- (NSDictionary *)stIMDB_selectFriendInfoWithUserId:(NSString *)userId;

- (NSDictionary *)stIMDB_selectFriendInfoWithXmppId:(NSString *)xmppId;

- (void)stIMDB_bulkInsertNotifyList:(NSArray *)notifyList;

- (void)stIMDB_bulkInsertFriendNotifyList:(NSArray *)notifyList;

- (void)stIMDB_insertFriendNotifyWithUserId:(NSString *)userId
                                WithXmppId:(NSString *)xmppId
                                  WithName:(NSString *)name
                              WithDescInfo:(NSString *)descInfo
                               WithHeadSrc:(NSString *)headerSrc
                           WithSearchIndex:(NSString *)searchIndex
                              WithUserInfo:(NSString *)userInfo
                               WithVersion:(int)version
                                 WithState:(int)state
                        WithLastUpdateTime:(long long)lastUpdateTime;

- (void)stIMDB_deleteFriendNotifyWithUserId:(NSString *)userId;

- (NSMutableArray *)stIMDB_selectFriendNotifys;

- (NSDictionary *)stIMDB_getLastFriendNotify;

- (int)stIMDB_getFriendNotifyCount;

- (void)stIMDB_updateFriendNotifyWithXmppId:(NSString *)xmppId WithState:(int)state;

- (long long)stIMDB_getMaxTimeFriendNotify;

@end

NS_ASSUME_NONNULL_END
