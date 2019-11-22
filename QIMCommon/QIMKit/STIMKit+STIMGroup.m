//
//  STIMKit+STIMGroup.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMGroup.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMGroup)

- (void)updateLastGroupMsgTime {
    [[STIMManager sharedInstance] updateLastGroupMsgTime];
}

- (STIMMessageDirection)getGroupMsgDirectionWithSendJid:(NSString *)sendJid {
    return [[STIMManager sharedInstance] getGroupMsgDirectionWithSendJid:sendJid];
}

- (NSArray *)getGroupList {
    return [[STIMManager sharedInstance] getGroupList];
}

- (NSString *)getGroupBigHeaderImageUrlWithGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getGroupBigHeaderImageUrlWithGroupId:groupId];
}

- (NSArray *)getMyGroupList {
    return [[STIMManager sharedInstance] getMyGroupList];
}

#pragma mark - 群名片

- (NSDictionary *)getUserInfoByGroupName:(NSString *)groupName {
    return [[STIMManager sharedInstance] getUserInfoByGroupName:groupName];
}

- (NSDictionary *)getMemoryGroupCardByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getMemoryGroupCardByGroupId:groupId];
}

- (NSDictionary *)getGroupCardByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getGroupCardByGroupId:groupId];
}

- (void)updateGroupCardByGroupId:(NSString *)groupId withCache:(BOOL)cache {
    [[STIMManager sharedInstance] updateGroupCardByGroupId:groupId withCache:cache];
}

- (void)updateGroupCardByGroupId:(NSString *)groupId {
    [[STIMManager sharedInstance] updateGroupCardByGroupId:groupId];
}

- (void)updateGroupCard:(NSArray *)groupIds {
    [[STIMManager sharedInstance] updateGroupCard:groupIds];
}

- (void)setMucVcardForGroupId:(NSString *)groupId
                 WithNickName:(NSString *)nickName
                    WithTitle:(NSString *)title
                     WithDesc:(NSString *)desc
                WithHeaderSrc:(NSString *)headerSrc
                 withCallBack:(STIMKitSetMucVCardBlock)callback {
    [[STIMManager sharedInstance] setMucVcardForGroupId:groupId WithNickName:nickName WithTitle:title WithDesc:desc WithHeaderSrc:headerSrc withCallBack:callback];
}

- (BOOL)updateGroupTopic:(NSString *)topic WithGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] updateGroupTopic:topic WithGroupId:groupId];
}

#pragma mark - 群成员

- (NSArray *)syncgroupMember:(NSString *)groupId {
    return [[STIMManager sharedInstance] syncgroupMember:groupId];
}

- (NSArray *)getGroupMembersByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getGroupMembersByGroupId:groupId];
}

- (NSString *)getGroupTopicByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getGroupTopicByGroupId:groupId];
}

- (BOOL)isGroupMemberByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] isGroupMemberByGroupId:groupId];
}

- (BOOL)isGroupMemberByUserId:(NSString *)userId ByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] isGroupMemberByUserId:userId ByGroupId:groupId];
}

- (BOOL)isGroupOwner:(NSString *)groupId {
    return [[STIMManager sharedInstance] isGroupOwner:groupId];
}

- (STIMGroupIdentity)GroupIdentityForUser:(NSString *)userId byGroup:(NSString *)groupId {
    return [[STIMManager sharedInstance] GroupIdentityForUser:userId byGroup:groupId];
}

#pragma mark - 群头像

+ (UIImage *)defaultGroupHeaderImage {
    return [STIMManager defaultGroupHeaderImage];
}

#pragma mark - 群消息设置

- (BOOL)groupPushState:(NSString *)groupId {
    return [[STIMManager sharedInstance] groupPushState:groupId];
}

- (BOOL)updatePushState:(NSString *)groupId withOn:(BOOL)on {
    return [[STIMManager sharedInstance] updatePushState:groupId withOn:on];
}

- (NSDictionary *) defaultGroupSetting {
    return [[STIMManager sharedInstance] defaultGroupSetting];
}

#pragma mark - 创建群 & 邀请人入群

- (void)createGroupByGroupName:(NSString *)groupName
                WithMyNickName:(NSString *)nickName
              WithInviteMember:(NSArray *)members
                   WithSetting:(NSDictionary *)settingDic
                      WithDesc:(NSString *)desc
             WithGroupNickName:(NSString *)groupNickName
                  WithComplate:(void (^)(BOOL,NSString *))complate {
    [[STIMManager sharedInstance] createGroupByGroupName:groupName WithMyNickName:nickName WithInviteMember:members WithSetting:settingDic WithDesc:desc WithGroupNickName:groupNickName WithComplate:complate];
}

-(void)joinGroupWithBuddies:(NSString *)groupID  groupName:(NSString *)groupName WithInviteMember:(NSArray *)members withCallback:(dispatch_block_t) block {
    [[STIMManager sharedInstance] joinGroupWithBuddies:groupID groupName:groupName WithInviteMember:members withCallback:block];
}

- (BOOL)removeGroupMemberWithName:(NSString *)name WithJid:(NSString *)memberJid ForGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] removeGroupMemberWithName:name WithJid:memberJid ForGroupId:groupId];
}

- (BOOL)setGroupAdminWithGroupId:(NSString *)groupId withIsAdmin:(BOOL)isAdmin WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid {
    return [[STIMManager sharedInstance] setGroupAdminWithGroupId:groupId withIsAdmin:isAdmin WithAdminNickName:nickName ForJid:memberJid];
}

- (BOOL)inviteMember:(NSArray *)members ToGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] inviteMember:members ToGroupId:groupId];
}

- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name isInitiative:(BOOL)initiative {
    return [[STIMManager sharedInstance] joinGroupId:groupId ByName:name isInitiative:initiative];
}

- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name WithPassword:(NSString *)password {
    return [[STIMManager sharedInstance] joinGroupId:groupId ByName:name WithPassword:password];
}

- (BOOL)quitGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] quitGroupId:groupId];
}

- (BOOL)destructionGroup:(NSString *)groupId {
    return [[STIMManager sharedInstance] destructionGroup:groupId];
}

- (void)updateChatRoomList {
    [[STIMManager sharedInstance] updateChatRoomList];
}

- (void)quickJoinAllGroup {
    [[STIMManager sharedInstance] quickJoinAllGroup];
}

- (void)joinGroupList {
    [[STIMManager sharedInstance] joinGroupList];
}

- (void)getIncrementMucList:(NSTimeInterval)lastTime {
    [[STIMManager sharedInstance] getIncrementMucList:lastTime];
}


#pragma mark - SearchGroup

- (NSInteger)searchGroupTotalCountBySearchStr:(NSString *)searchStr {
    return [[STIMManager sharedInstance] searchGroupTotalCountBySearchStr:searchStr];
}

- (NSArray *)searchGroupBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[STIMManager sharedInstance] searchGroupBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)searchGroupUserBySearchStr:(NSString *) searchStr inGroup:(NSString *) groupId {
    return [[STIMManager sharedInstance] searchGroupUserBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId {
    return [[STIMManager sharedInstance] searchUserBySearchStr:searchStr notInGroup:groupId];
}

@end
