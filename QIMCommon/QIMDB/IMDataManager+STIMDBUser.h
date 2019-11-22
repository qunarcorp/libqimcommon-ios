//
//  IMDataManager+STIMDBUser.h
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
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMDBUser)

- (void)stIMDB_bulkInsertOrgansUserInfos:(NSArray *)userInfos;

- (NSString *)stIMDB_getTimeSmtapMsgIdForDate:(NSDate *)date WithUserId:(NSString *)userId;

- (void)stIMDB_bulkUpdateUserSearchIndexs:(NSArray *)searchIndexs;

- (void)stIMDB_bulkInsertUserInfosNotSaveDescInfo:(NSArray *)userInfos;

- (void)stIMDB_bulkUpdateUserBackInfo:(NSDictionary *)userBackInfo WithXmppId:(NSString *)xmppId;

- (void)stIMDB_InsertOrUpdateUserInfos:(NSArray *)userInfos;

- (NSDictionary *)stIMDB_selectUserByJID:(NSString *)jid;


/**
 获取所有的用户备注

 @return 用户备注
 */
- (NSDictionary *)stIMDB_getUserMarkNameDic;

- (void)stIMDB_clearUserList;

- (void)stIMDB_clearUserListForList:(NSArray *)userInfos;

- (void)stIMDB_bulkInsertUserInfos:(NSArray *)userInfos;

- (void)stIMDB_updateUser:(NSString *)userId WithMood:(NSString *)mood WithHeaderSrc:(NSString *)headerSrc WithVersion:(NSString *)version;

- (void)stIMDB_bulkUpdateUserCards:(NSArray *)cards;

- (NSString *)stIMDB_getUserHeaderSrcByUserId:(NSString *)userId;

- (NSDictionary *)stIMDB_selectUserByID:(NSString *)userId;

- (NSDictionary *)stIMDB_selectUserBackInfoByXmppId:(NSString *)xmppId;

- (NSDictionary *)stIMDB_selectUserByIndex:(NSString *)index;

- (NSArray *)stIMDB_selectXmppIdList;

- (NSArray *)stIMDB_selectUserIdList;

- (NSArray *)stIMDB_getOrganUserList;

//Select a.UserId, a.XmppId, a.Name, a.DescInfo, a.HeaderSrc, a.UserInfo, a.LastUpdateTime from IM_Group_Member as b left join IM_Users as a on a.Name = b.Name where GroupId = 'qtalk客户端开发群@conference.ejabhost1'

- (NSArray *)stIMDB_selectUserListBySearchStr:(NSString *)searchStr inGroup:(NSString *) groupId;

- (NSArray *)stIMDB_searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId;

- (NSArray *)stIMDB_selectUserListBySearchStr:(NSString *)searchStr;

- (NSInteger)stIMDB_selectUserListTotalCountBySearchStr:(NSString *)searchStr;

- (NSArray *)stIMDB_selectUserListExMySelfBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSArray *)stIMDB_selectUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSDictionary *)stIMDB_selectUsersDicByXmppIds:(NSArray *)xmppIds;

- (NSArray *)stIMDB_selectUserListByUserIds:(NSArray *)userIds;

- (BOOL)stIMDB_checkExitsUser;

@end

NS_ASSUME_NONNULL_END
