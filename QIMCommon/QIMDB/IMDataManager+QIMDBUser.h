//
//  IMDataManager+QIMDBUser.h
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
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMDBUser)

- (void)qimDB_bulkInsertOrgansUserInfos:(NSArray *)userInfos;

- (NSString *)qimDB_getTimeSmtapMsgIdForDate:(NSDate *)date WithUserId:(NSString *)userId;

- (void)qimDB_bulkUpdateUserSearchIndexs:(NSArray *)searchIndexs;

- (void)qimDB_bulkInsertUserInfosNotSaveDescInfo:(NSArray *)userInfos;

- (void)qimDB_bulkUpdateUserBackInfo:(NSDictionary *)userBackInfo WithXmppId:(NSString *)xmppId;

- (void)qimDB_InsertOrUpdateUserInfos:(NSArray *)userInfos;

- (NSDictionary *)qimDB_selectUserByJID:(NSString *)jid;


/**
 获取所有的用户备注

 @return 用户备注
 */
- (NSDictionary *)qimDB_getUserMarkNameDic;

- (void)qimDB_clearUserList;

- (void)qimDB_clearUserListForList:(NSArray *)userInfos;

- (void)qimDB_bulkInsertUserInfos:(NSArray *)userInfos;

- (void)qimDB_updateUser:(NSString *)userId WithMood:(NSString *)mood WithHeaderSrc:(NSString *)headerSrc WithVersion:(NSString *)version;

- (void)qimDB_bulkUpdateUserCards:(NSArray *)cards;

- (NSString *)qimDB_getUserHeaderSrcByUserId:(NSString *)userId;

- (NSDictionary *)qimDB_selectUserByID:(NSString *)userId;

- (NSDictionary *)qimDB_selectUserBackInfoByXmppId:(NSString *)xmppId;

- (NSDictionary *)qimDB_selectUserByIndex:(NSString *)index;

- (NSArray *)qimDB_selectXmppIdList;

- (NSArray *)qimDB_selectUserIdList;

- (NSArray *)qimDB_getOrganUserList;

//Select a.UserId, a.XmppId, a.Name, a.DescInfo, a.HeaderSrc, a.UserInfo, a.LastUpdateTime from IM_Group_Member as b left join IM_Users as a on a.Name = b.Name where GroupId = 'qtalk客户端开发群@conference.ejabhost1'

- (NSArray *)qimDB_selectUserListBySearchStr:(NSString *)searchStr inGroup:(NSString *) groupId;

- (NSArray *)qimDB_searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId;

- (NSArray *)qimDB_selectUserListBySearchStr:(NSString *)searchStr;

- (NSInteger)qimDB_selectUserListTotalCountBySearchStr:(NSString *)searchStr;

- (NSArray *)qimDB_selectUserListExMySelfBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSArray *)qimDB_selectUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSDictionary *)qimDB_selectUsersDicByXmppIds:(NSArray *)xmppIds;

- (NSArray *)qimDB_selectUserListByUserIds:(NSArray *)userIds;

- (BOOL)qimDB_checkExitsUser;

@end

NS_ASSUME_NONNULL_END
