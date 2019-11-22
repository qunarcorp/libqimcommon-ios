//
//  IMDataManager+STIMDBGroup.h
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
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMDBGroup)

- (NSInteger)stIMDB_getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr;

- (NSArray *)stIMDB_rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset;

- (NSInteger)stIMDB_getLocalGroupTotalCountByUserIds:(NSArray *)userIds;

- (NSArray *)stIMDB_searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSArray *)stIMDB_getGroupIdList;

- (NSArray *)stIMDB_getGroupList;

- (NSDictionary *)stIMDB_getGroupCardByGroupId:(NSString *)groupId;

- (NSArray *)stIMDB_getGroupVCardByGroupIds:(NSArray *)groupIds;

- (NSArray *)stIMDB_getGroupListMaxLastUpdateTime;

- (NSArray *)stIMDB_getGroupListMsgMaxTime;

- (NSInteger)stIMDB_getGroupListMaxUTLastUpdateTime;

- (BOOL)stIMDB_needUpdateGroupImage:(NSString *)groupId;

- (NSString *)stIMDB_getGroupHeaderSrc:(NSString *)groupId;

- (BOOL)stIMDB_checkGroup:(NSString *)groupId;

- (void)stIMDB_bulkinsertGroups:(NSArray *) groups;

- (void)stIMDB_insertGroup:(NSString *)groupId;

- (void)stIMDB_updateGroup:(NSString *)groupId WithTopic:(NSString *)topic;

- (void)stIMDB_bulkUpdateGroupCards:(NSArray *)array;

- (void)stIMDB_bulkUpdateIncrementGroupCards:(NSArray *)array;

- (void)stIMDB_updateGroup:(NSString *)groupId
             WithNickName:(NSString *)nickName
                WithTopic:(NSString *)topic
                 WithDesc:(NSString *)desc
            WithHeaderSrc:(NSString *)headerSrc
              WithVersion:(NSString *)version;

- (void)stIMDB_updateGroup:(NSString *)groupId WithNickName:(NSString *)nickName;

- (void)stIMDB_updateGroup:(NSString *)groupId WithDesc:(NSString *)desc;

- (void)stIMDB_updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc;

- (void)stIMDB_bulkDeleteGroups:(NSArray *)groupIdList;

- (void)stIMDB_deleteGroup:(NSString *)groupId;

- (NSDictionary *)stIMDB_getGroupMemberInfoByNickName:(NSString *)nickName;

- (NSDictionary *)stIMDB_getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId;

- (BOOL)stIMDB_checkGroupMember:(NSString *)nickName WithGroupId:(NSString *)groupId;

- (void)stIMDB_insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId;

- (void)stIMDB_bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId;

- (NSArray *)stIMDB_getQChatGroupMember:(NSString *)groupId;

- (NSArray *)stIMDB_getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr;

- (NSArray *)stIMDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr;

- (NSArray *)stIMDB_getGroupMember:(NSString *)groupId WithGroupIdentity:(NSInteger)identity;

- (NSArray *)stIMDB_getGroupMember:(NSString *)groupId;

- (NSDictionary *)stIMDB_getGroupOwnerInfoForGroupId:(NSString *)groupId;

- (void)stIMDB_deleteGroupMemberWithGroupId:(NSString *)groupId;

- (void)stIMDB_deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId;

- (void)stIMDB_deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId;

@end

NS_ASSUME_NONNULL_END
