//
//  IMDataManager+QIMDBGroup.h
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
#import "IMDataManager+QIMDBFriend.h"
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMDBGroup)

- (NSInteger)qimDB_getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr;

- (NSArray *)qimDB_rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset;

- (NSInteger)qimDB_getLocalGroupTotalCountByUserIds:(NSArray *)userIds;

- (NSArray *)qimDB_searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSArray *)qimDB_getGroupIdList;

- (NSArray *)qimDB_getGroupList;

- (NSDictionary *)qimDB_getGroupCardByGroupId:(NSString *)groupId;

- (NSArray *)qimDB_getGroupVCardByGroupIds:(NSArray *)groupIds;

- (NSArray *)qimDB_getGroupListMaxLastUpdateTime;

- (NSArray *)qimDB_getGroupListMsgMaxTime;

- (NSInteger)qimDB_getGroupListMaxUTLastUpdateTime;

- (BOOL)qimDB_needUpdateGroupImage:(NSString *)groupId;

- (NSString *)qimDB_getGroupHeaderSrc:(NSString *)groupId;

- (BOOL)qimDB_checkGroup:(NSString *)groupId;

- (void)qimDB_bulkinsertGroups:(NSArray *) groups;

- (void)qimDB_insertGroup:(NSString *)groupId;

- (void)qimDB_updateGroup:(NSString *)groupId WithTopic:(NSString *)topic;

- (void)qimDB_bulkUpdateGroupCards:(NSArray *)array;

- (void)qimDB_bulkUpdateIncrementGroupCards:(NSArray *)array;

- (void)qimDB_updateGroup:(NSString *)groupId
             WithNickName:(NSString *)nickName
                WithTopic:(NSString *)topic
                 WithDesc:(NSString *)desc
            WithHeaderSrc:(NSString *)headerSrc
              WithVersion:(NSString *)version;

- (void)qimDB_updateGroup:(NSString *)groupId WithNickName:(NSString *)nickName;

- (void)qimDB_updateGroup:(NSString *)groupId WithDesc:(NSString *)desc;

- (void)qimDB_updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc;

- (void)qimDB_bulkDeleteGroups:(NSArray *)groupIdList;

- (void)qimDB_deleteGroup:(NSString *)groupId;

- (NSDictionary *)qimDB_getGroupMemberInfoByNickName:(NSString *)nickName;

- (NSDictionary *)qimDB_getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId;

- (BOOL)qimDB_checkGroupMember:(NSString *)nickName WithGroupId:(NSString *)groupId;

- (void)qimDB_insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId;

- (void)qimDB_bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId;

- (NSArray *)qimDB_getQChatGroupMember:(NSString *)groupId;

- (NSArray *)qimDB_getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr;

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr;

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId WithGroupIdentity:(NSInteger)identity;

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId;

- (NSDictionary *)qimDB_getGroupOwnerInfoForGroupId:(NSString *)groupId;

- (void)qimDB_deleteGroupMemberWithGroupId:(NSString *)groupId;

- (void)qimDB_deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId;

- (void)qimDB_deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId;

@end

NS_ASSUME_NONNULL_END
