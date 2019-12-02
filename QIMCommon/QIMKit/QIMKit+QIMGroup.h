//
//  QIMKit+QIMGroup.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/19.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMGroup)

/**
 更新群消息时间戳
 */
- (void)updateLastGroupMsgTime;

/**
 根据昵称获取群消息来源方向
 
 @param sendJid 昵称
 @return MessageDirection
 */
- (QIMMessageDirection)getGroupMsgDirectionWithSendJid:(NSString *)sendJid;

- (NSArray *)getGroupIdList;

/**
 获取我的群组列表
 */
- (NSArray *)getGroupList;

- (NSString *)getGroupBigHeaderImageUrlWithGroupId:(NSString *)groupId;

/**
 获取我的群组列表
 */
- (NSArray *)getMyGroupList;

#pragma mark - 群名片

- (NSDictionary *)getUserInfoByGroupName:(NSString *)groupName;

- (NSDictionary *)getMemoryGroupCardByGroupId:(NSString *)groupId;

/**
 根据群Id获取群组名片
 
 @param groupId 群组Id
 @return 群组名片Dic
 */
- (NSDictionary *)getGroupCardByGroupId:(NSString *)groupId;

- (void)updateGroupCardByGroupId:(NSString *)groupId withCache:(BOOL)cache;

/**
 根据群Id更新群组名片
 
 @param groupId 群组Id
 */
- (void)updateGroupCardByGroupId:(NSString *)groupId;


/**
 根据群Id列表更新群组名片
 
 @param groupIds 群组Id列表
 */
- (void)updateGroupCard:(NSArray *)groupIds;

/**
 设置群名片信息
 
 @param groupId 群Id
 @param nickName 我的昵称
 @param title 群Title
 @param desc 群公告
 @param headerSrc 群头像地址
 @return 设置群名片是否成功
 */
- (void)setMucVcardForGroupId:(NSString *)groupId
                 WithNickName:(NSString *)nickName
                    WithTitle:(NSString *)title
                     WithDesc:(NSString *)desc
                WithHeaderSrc:(NSString *)headerSrc
                 withCallBack:(QIMKitSetMucVCardBlock)callback;

/**
 更新群公告
 
 @param topic 公告信息
 @param groupId 群Id
 @return 更新群公告是否成功
 */
- (BOOL)updateGroupTopic:(NSString *)topic WithGroupId:(NSString *)groupId;

#pragma mark - 群成员

/**
 根据群Id同步群成员列表
 
 @param groupId 群Id
 @return 群成员列表
 */
- (NSArray *)syncgroupMember:(NSString *)groupId;


/**
 根据群Id获取群成员列表
 
 @param groupId 群Id
 @return 群成员列表
 */
- (NSArray *)getGroupMembersByGroupId:(NSString *)groupId;

/**
 根据群Id获取群组公告信息
 
 @param groupId 群Id
 @return 群公告信息
 */
- (NSString *)getGroupTopicByGroupId:(NSString *)groupId;


/**
 判断本人是否为群成员
 
 @param groupId 群Id
 */
- (BOOL)isGroupMemberByGroupId:(NSString *)groupId;


/**
  判断某人是否为群成员

 @param userId 用户Id
 @param groupId 群Id
 @return 是否存在
 */
- (BOOL)isGroupMemberByUserId:(NSString *)userId ByGroupId:(NSString *)groupId;

/**
 判断本人是否为群主
 
 @param groupId 群组Id
 */
- (BOOL)isGroupOwner:(NSString *)groupId;


/**
 指定的user在群众的身份
 
 @param userId 指定的user(userId为nil，默认为登录用户)
 @param groupId 群id
 @return 返回在群众的身份 QIMGroupIdentity
 */
- (QIMGroupIdentity)GroupIdentityForUser:(NSString *)userId byGroup:(NSString *)groupId;

#pragma mark - 群头像

/**
 群默认头像
 */
+ (UIImage *)defaultGroupHeaderImage;

#pragma mark - 群设置

/**
 根据群组Id获取群免打扰状态
 
 @param groupId 群组Id
 @return 群组免打扰状态
 */
- (BOOL)groupPushState:(NSString *)groupId;

/**
 根据群Id更新群组免打扰状态
 
 @param groupId 群组Id
 @param on 是否免打扰
 @return 更新群组免打扰状态是否成功
 */
- (void)updatePushState:(NSString *)groupId withOn:(BOOL)on withCallback:(QIMKitUpdateRemoteClientConfig)callback;

/**
 默认群组设置
 */
- (NSDictionary *) defaultGroupSetting;

#pragma mark - 创建群 & 邀请人入群

/**
 创建群聊
 
 @param groupName 群名称
 @param nickName 我的昵称
 @param members 群成员列表
 @param settingDic 群设置
 @param desc 群公告
 @param groupNickName 群昵称
 @param complate complate回调
 */
- (void)createGroupByGroupName:(NSString *)groupName
                WithMyNickName:(NSString *)nickName
              WithInviteMember:(NSArray *)members
                   WithSetting:(NSDictionary *)settingDic
                      WithDesc:(NSString *)desc
             WithGroupNickName:(NSString *)groupNickName
                  WithComplate:(void (^)(BOOL,NSString *))complate;

/**
 群组邀请users
 
 @param groupID 群ID
 @param groupName 群名
 @param members 邀请的成员userIDs
 @param block 回调
 */
-(void)joinGroupWithBuddies:(NSString *)groupID  groupName:(NSString *)groupName WithInviteMember:(NSArray *)members withCallback:(dispatch_block_t) block;


/**
 将群成员踢出群组
 
 @param name name
 @param memberJid memberJid
 @param groupId 群组Id
 @return 踢除是否成功
 */
- (BOOL)removeGroupMemberWithName:(NSString *)name WithJid:(NSString *)memberJid ForGroupId:(NSString *)groupId;

/**
 设置群管理
 
 @param groupId 群Id
 @param isAdmin 设置群管理/取消群管理
 @param nickName 群管理的昵称
 @param memberJid 群管理XmppJid
 @return 是否成功
 */
- (BOOL)setGroupAdminWithGroupId:(NSString *)groupId withIsAdmin:(BOOL)isAdmin WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid;

/**
 邀请成员进群
 
 @param members 成员列表
 @param groupId 群组Id
 @return 邀请入群是否成功
 */
- (BOOL)inviteMember:(NSArray *)members ToGroupId:(NSString *)groupId;

/**
 加入群聊
 
 @param groupId 群组Id
 @param name name
 @param initiative initiative
 @return 加入群聊是否成功
 */
- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name isInitiative:(BOOL)initiative;


/**
 使用密码加入群聊
 
 @param groupId 群组Id
 @param name name
 @param password 入群密码
 @return 加入群聊是否成功
 */
- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name WithPassword:(NSString *)password;


/**
 退出群聊
 
 @param groupId 群组Id
 @return 退出是否成功
 */
- (BOOL)quitGroupId:(NSString *)groupId;

/**
 销毁群聊
 
 @param groupId 群组Id
 @return 销毁群聊是否成功
 */
- (BOOL)destructionGroup:(NSString *)groupId;

- (void)updateChatRoomList;

/**
 快速入群
 */
- (void)quickJoinAllGroup;

- (void)joinGroupList;


/**
 增量群列表
 
 @param lastTime 增量时间戳
 */
- (void)getIncrementMucList:(NSTimeInterval)lastTime;


#pragma mark - SearchGroup

/**
 根据关键字搜索群组总数
 
 @param searchStr 关键字
 @return 群组总数
 */
- (NSInteger)searchGroupTotalCountBySearchStr:(NSString *)searchStr;


/**
 根据关键字搜索群组
 
 @param searchStr 关键字
 @param limit limit
 @param offset offset
 @return 搜索出来的群组列表
 */
- (NSArray *)searchGroupBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

/**
 根据关键字搜索在同一个群的用户
 
 @param searchStr 关键字
 @param groupId 群组Id
 @return 结果群成员列表
 */
- (NSArray *)searchGroupUserBySearchStr:(NSString *) searchStr inGroup:(NSString *) groupId;

- (NSArray *)searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId;

@end
