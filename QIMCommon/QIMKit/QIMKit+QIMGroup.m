//
//  QIMKit+QIMGroup.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMGroup.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMGroup)

- (void)updateLastGroupMsgTime {
    [[QIMManager sharedInstance] updateLastGroupMsgTime];
}

- (QIMMessageDirection)getGroupMsgDirectionWithSendJid:(NSString *)sendJid {
    return [[QIMManager sharedInstance] getGroupMsgDirectionWithSendJid:sendJid];
}

- (NSArray *)getGroupList {
    return [[QIMManager sharedInstance] getGroupList];
}

- (NSString *)getGroupBigHeaderImageUrlWithGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] getGroupBigHeaderImageUrlWithGroupId:groupId];
}

- (NSArray *)getMyGroupList {
    return [[QIMManager sharedInstance] getMyGroupList];
}

#pragma mark - 群名片

- (NSDictionary *)getUserInfoByGroupName:(NSString *)groupName {
    return [[QIMManager sharedInstance] getUserInfoByGroupName:groupName];
}

- (NSDictionary *)getMemoryGroupCardByGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] getMemoryGroupCardByGroupId:groupId];
}

- (NSDictionary *)getGroupCardByGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] getGroupCardByGroupId:groupId];
}

- (void)updateGroupCardByGroupId:(NSString *)groupId withCache:(BOOL)cache {
    [[QIMManager sharedInstance] updateGroupCardByGroupId:groupId withCache:cache];
}

- (void)updateGroupCardByGroupId:(NSString *)groupId {
    [[QIMManager sharedInstance] updateGroupCardByGroupId:groupId];
}

- (void)updateGroupCard:(NSArray *)groupIds {
    [[QIMManager sharedInstance] updateGroupCard:groupIds];
}

- (void)setMucVcardForGroupId:(NSString *)groupId
                 WithNickName:(NSString *)nickName
                    WithTitle:(NSString *)title
                     WithDesc:(NSString *)desc
                WithHeaderSrc:(NSString *)headerSrc
                 withCallBack:(QIMKitSetMucVCardBlock)callback {
    [[QIMManager sharedInstance] setMucVcardForGroupId:groupId WithNickName:nickName WithTitle:title WithDesc:desc WithHeaderSrc:headerSrc withCallBack:callback];
}

- (BOOL)updateGroupTopic:(NSString *)topic WithGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] updateGroupTopic:topic WithGroupId:groupId];
}

#pragma mark - 群成员

- (NSArray *)syncgroupMember:(NSString *)groupId {
    return [[QIMManager sharedInstance] syncgroupMember:groupId];
}

- (NSArray *)getGroupMembersByGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] getGroupMembersByGroupId:groupId];
}

- (NSString *)getGroupTopicByGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] getGroupTopicByGroupId:groupId];
}

- (BOOL)isGroupMemberByGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] isGroupMemberByGroupId:groupId];
}

- (BOOL)isGroupMemberByUserId:(NSString *)userId ByGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] isGroupMemberByUserId:userId ByGroupId:groupId];
}

- (BOOL)isGroupOwner:(NSString *)groupId {
    return [[QIMManager sharedInstance] isGroupOwner:groupId];
}

- (QIMGroupIdentity)GroupIdentityForUser:(NSString *)userId byGroup:(NSString *)groupId {
    return [[QIMManager sharedInstance] GroupIdentityForUser:userId byGroup:groupId];
}

#pragma mark - 群头像

+ (UIImage *)defaultGroupHeaderImage {
    return [QIMManager defaultGroupHeaderImage];
}

#pragma mark - 群消息设置

- (BOOL)groupPushState:(NSString *)groupId {
    return [[QIMManager sharedInstance] groupPushState:groupId];
}

- (void)updatePushState:(NSString *)groupId withOn:(BOOL)on withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    [[QIMManager sharedInstance] updatePushState:groupId withOn:on withCallback:callback];
}

- (NSDictionary *) defaultGroupSetting {
    return [[QIMManager sharedInstance] defaultGroupSetting];
}

#pragma mark - 创建群 & 邀请人入群

- (void)createGroupByGroupName:(NSString *)groupName
                WithMyNickName:(NSString *)nickName
              WithInviteMember:(NSArray *)members
                   WithSetting:(NSDictionary *)settingDic
                      WithDesc:(NSString *)desc
             WithGroupNickName:(NSString *)groupNickName
                  WithComplate:(void (^)(BOOL,NSString *))complate {
    [[QIMManager sharedInstance] createGroupByGroupName:groupName WithMyNickName:nickName WithInviteMember:members WithSetting:settingDic WithDesc:desc WithGroupNickName:groupNickName WithComplate:complate];
}

-(void)joinGroupWithBuddies:(NSString *)groupID  groupName:(NSString *)groupName WithInviteMember:(NSArray *)members withCallback:(dispatch_block_t) block {
    [[QIMManager sharedInstance] joinGroupWithBuddies:groupID groupName:groupName WithInviteMember:members withCallback:block];
}

- (BOOL)removeGroupMemberWithName:(NSString *)name WithJid:(NSString *)memberJid ForGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] removeGroupMemberWithName:name WithJid:memberJid ForGroupId:groupId];
}

- (BOOL)setGroupAdminWithGroupId:(NSString *)groupId withIsAdmin:(BOOL)isAdmin WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid {
    return [[QIMManager sharedInstance] setGroupAdminWithGroupId:groupId withIsAdmin:isAdmin WithAdminNickName:nickName ForJid:memberJid];
}

- (BOOL)inviteMember:(NSArray *)members ToGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] inviteMember:members ToGroupId:groupId];
}

- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name isInitiative:(BOOL)initiative {
    return [[QIMManager sharedInstance] joinGroupId:groupId ByName:name isInitiative:initiative];
}

- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name WithPassword:(NSString *)password {
    return [[QIMManager sharedInstance] joinGroupId:groupId ByName:name WithPassword:password];
}

- (BOOL)quitGroupId:(NSString *)groupId {
    return [[QIMManager sharedInstance] quitGroupId:groupId];
}

- (BOOL)destructionGroup:(NSString *)groupId {
    return [[QIMManager sharedInstance] destructionGroup:groupId];
}

- (void)updateChatRoomList {
    [[QIMManager sharedInstance] updateChatRoomList];
}

- (void)quickJoinAllGroup {
    [[QIMManager sharedInstance] quickJoinAllGroup];
}

- (void)joinGroupList {
    [[QIMManager sharedInstance] joinGroupList];
}

- (void)getIncrementMucList:(NSTimeInterval)lastTime {
    [[QIMManager sharedInstance] getIncrementMucList:lastTime];
}


#pragma mark - SearchGroup

- (NSInteger)searchGroupTotalCountBySearchStr:(NSString *)searchStr {
    return [[QIMManager sharedInstance] searchGroupTotalCountBySearchStr:searchStr];
}

- (NSArray *)searchGroupBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[QIMManager sharedInstance] searchGroupBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

- (NSArray *)searchGroupUserBySearchStr:(NSString *) searchStr inGroup:(NSString *) groupId {
    return [[QIMManager sharedInstance] searchGroupUserBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId {
    return [[QIMManager sharedInstance] searchUserBySearchStr:searchStr notInGroup:groupId];
}

@end
