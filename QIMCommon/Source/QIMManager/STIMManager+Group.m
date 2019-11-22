//
//  STIMManager+Group.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "STIMManager+Group.h"
#import <objc/runtime.h>

@implementation STIMManager (Group)

- (void)setGroupList:(NSMutableArray *)groupList {
    objc_setAssociatedObject(self, "groupList", groupList, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableArray *)groupList {
    NSMutableArray *groupList = objc_getAssociatedObject(self, "groupList");
    if (!groupList) {
        groupList = [NSMutableArray arrayWithCapacity:5];
    }
    return groupList;
}

- (void)setGroupInfoDic:(NSMutableDictionary *)groupInfoDic {
    objc_setAssociatedObject(self, "groupInfoDic", groupInfoDic, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableDictionary *)groupInfoDic {
    NSMutableDictionary *groupInfoDic = objc_getAssociatedObject(self, "groupInfoDic");
    if (!groupInfoDic) {
        groupInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return groupInfoDic;
}

- (void)setGroupHeaderImageDic:(NSMutableDictionary *)groupHeaderImageDic {
    objc_setAssociatedObject(self, "groupHeaderImageDic", groupHeaderImageDic, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableDictionary *)groupHeaderImageDic {
    NSMutableDictionary *groupHeaderImageDic = objc_getAssociatedObject(self, "groupHeaderImageDic");
    if (!groupHeaderImageDic) {
        groupHeaderImageDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return groupHeaderImageDic;
}

- (NSString *)getGroupBigHeaderImageUrlWithGroupId:(NSString *)groupId {
    NSDictionary *infoDic = [self getGroupCardByGroupId:groupId];
    NSString *fileUrl = [infoDic objectForKey:@"HeaderSrc"];
    if (fileUrl.length > 0) {
        return fileUrl;
    }
    return @"";
}

- (NSArray *)getGroupList {
    return self.groupList;
}

#pragma mark - Group VCard

- (NSDictionary *)getMemoryGroupCardByGroupId:(NSString *)groupId {
    
    __block NSDictionary *groupVCard = nil;
    if (!self.groupVCardDict) {
        self.groupVCardDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    groupVCard = [self.groupVCardDict objectForKey:groupId];
    return groupVCard;
}

- (NSDictionary *)getGroupCardByGroupId:(NSString *)groupId {
    
    __block NSDictionary *groupVCard = nil;
    dispatch_block_t block = ^{
        if (!self.groupVCardDict) {
            self.groupVCardDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        }
        groupVCard = [self.groupVCardDict objectForKey:groupId];
        if (!groupVCard.count) {
            groupVCard = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupCardByGroupId:groupId];
        }

        [self.groupVCardDict setSTIMSafeObject:groupVCard forKey:groupId];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    return groupVCard;
}

- (NSArray *)syncgroupMember:(NSString *)groupId {
    NSDictionary *dic = [[XmppImManager sharedInstance] groupMembersByGroupId:groupId];
    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertGroupMember:[dic allValues] WithGroupId:groupId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STIMGroupMemberWillUpdate" object:groupId];
    });
    return [dic allValues];
}


/**
 *  根据群ID获取群成员
 *
 *  @param groupId 群Id
 {
 affiliation = none;
 jid = "qtalk\U5ba2\U6237\U7aef\U5f00\U53d1\U7fa4@conference.ejabhost1/\U674e\U9732";
 name = "\U674e\U9732lucas";
 xmppjid = "lilulucas.li@ejabhost1";
 }
 */
- (NSArray *)getGroupMembersByGroupId:(NSString *)groupId {
    NSArray *result = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMember:groupId];
    if ([result count] <= 0) {
        return [self syncgroupMember:groupId];
    }
    return result;
}
 
/**
 *  验证自己是否为群成员
 *
 *  @param groupId 群ID
 */
- (BOOL)isGroupMemberByGroupId:(NSString *)groupId {
    NSDictionary *memberInfo = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMemberInfoByJid:[self getLastJid] WithGroupId:groupId];
    return memberInfo ? YES : NO;
}

- (BOOL)isGroupMemberByUserId:(NSString *)userId ByGroupId:(NSString *)groupId {
    NSDictionary *memberInfo = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMemberInfoByJid:userId WithGroupId:groupId];
    return memberInfo ? YES : NO;
}

#pragma mark - 群头像

+ (UIImage *)defaultGroupHeaderImage {
    static UIImage *__defaultGroupHeaderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeStartalk) {
            NSString *groupHeaderPath = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"STIMCommonResource" BundleName:@"STIMCommonResource" pathForResource:@"STIMdefaultGroupHeader" ofType:@"png"];
            __defaultGroupHeaderImage = [UIImage imageWithContentsOfFile:groupHeaderPath];
        } else {
            NSString *groupHeaderPath = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"STIMCommonResource" BundleName:@"STIMCommonResource" pathForResource:@"STIMGroupDefaultHeader" ofType:@"png"];
            __defaultGroupHeaderImage = [UIImage imageWithContentsOfFile:groupHeaderPath];
        }
    });
    return __defaultGroupHeaderImage;
}

#pragma mark - Group Push

- (BOOL)groupPushState:(NSString *)groupName {
    
    if (groupName.length <= 0) {
        return YES;
    }
    
    __block BOOL result = YES;
    if (!self.notMindGroupDic) {
        self.notMindGroupDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    NSInteger groupPush = [[self.notMindGroupDic objectForKey:groupName] integerValue];
    if (groupPush == 0) {
        NSInteger remind = [[STIMManager sharedInstance] getClientConfigDeleteFlagWithType:STIMClientConfigTypeKNoticeStickJidDic WithSubKey:groupName];
        if (remind == 0) {
            groupPush = NO;
            dispatch_block_t block = ^{

                [self.notMindGroupDic setSTIMSafeObject:@(-1) forKey:groupName];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        } else {
            groupPush = YES;
            dispatch_block_t block = ^{
                
                [self.notMindGroupDic setSTIMSafeObject:@(1) forKey:groupName];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        }
        result = groupPush;
    } else if (groupPush == -1) {
        result = NO;
    } else {
        result = YES;
    }
    
    return result;
}

- (BOOL)updatePushState:(NSString *)groupId withOn:(BOOL)on {
    if (groupId.length <= 0) {
        return NO;
    }
    NSString *configValue = (on == YES) ? @"0" : @"1";
    BOOL success = [[STIMManager sharedInstance] updateRemoteClientConfigWithType:STIMClientConfigTypeKNoticeStickJidDic WithSubKey:groupId WithConfigValue:configValue WithDel:on];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRemindStateChange object:groupId];
        });
    }
    return success;
}

- (void)setMucVcardForGroupId:(NSString *)groupId
                 WithNickName:(NSString *)nickName
                    WithTitle:(NSString *)title
                     WithDesc:(NSString *)desc
                WithHeaderSrc:(NSString *)headerSrc
                 withCallBack:(STIMKitSetMucVCardBlock)callback {
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (groupId.length > 0) {
        [paramDic setObject:groupId ? groupId : @"" forKey:@"muc_name"];
    }
    if (nickName) {
        [paramDic setObject:nickName forKey:@"nick"];
    }
    if (title) {
        [paramDic setObject:title forKey:@"title"];
    }
    if (desc) {
        [paramDic setObject:desc forKey:@"desc"];
    }
    if (headerSrc.length > 0) {
        [paramDic setObject:headerSrc forKey:@"pic"];
    }
    
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:@[paramDic] error:nil];
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/muc/set_muc_vcard.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *resultDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[resultDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSArray *mucList = [resultDic objectForKey:@"data"];
            [self dealWithSetUpdateMucVcard:mucList];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (callback) {
                callback(YES);
            }
        } else {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if (callback) {
                callback(NO);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (callback) {
            callback(NO);
        }
    }];
}

- (void)dealWithSetUpdateMucVcard:(NSArray *)updateList {
    if ([updateList isKindOfClass:[NSArray class]]) {
        for (NSDictionary *groupInfo in updateList) {
            NSString *groupId = [groupInfo objectForKey:@"muc_name"];
            NSString *version = [groupInfo objectForKey:@"version"];
            NSString *muc_desc = [groupInfo objectForKey:@"muc_desc"];
            NSString *muc_title = [groupInfo objectForKey:@"muc_title"];
            NSString *show_name = [groupInfo objectForKey:@"show_name"];
            
            [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroup:groupId WithNickName:show_name WithTopic:muc_title WithDesc:muc_desc WithHeaderSrc:nil WithVersion:version];
            [self.groupVCardDict removeObjectForKey:groupId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCardChanged object:@[groupId]];
                if (show_name.length > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:@[groupId] userInfo:nil];
                }
            });
        }
    }
}

- (NSArray *)getGroupIdList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupIdList];
}

- (NSArray *)getMyGroupList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupList];
}

static NSMutableArray *cacheGroupCardHttpList = nil;
- (void)updateGroupCardByGroupId:(NSString *)groupId withCache:(BOOL)cache {
    if (!groupId) {
        return;
    }
    if (YES == cache) {
        if (!cacheGroupCardHttpList) {
            cacheGroupCardHttpList = [NSMutableArray arrayWithCapacity:3];
        }
        if ([cacheGroupCardHttpList containsObject:groupId]) {
            return;
        } else {
            [cacheGroupCardHttpList addObject:groupId];
            [self updateGroupCard:@[groupId]];
        }
    } else {
        [self updateGroupCard:@[groupId]];
    }
}

- (void)updateGroupCardByGroupId:(NSString *)groupId {
    if (!groupId) {
        return;
    }
    [self updateGroupCardByGroupId:groupId withCache:NO];
}

// 3.获取跨域聊天室vcard信息
- (void)updateGroupCard:(NSArray *)groupIds {

    if (groupIds.count <= 0) {
        return;
    }
    if (!self.update_group_card) {
        self.update_group_card = dispatch_queue_create("update_group_card", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(self.update_group_card, ^{
        NSArray *groupCardList = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupVCardByGroupIds:groupIds];
        NSMutableDictionary *groupIdDic = [NSMutableDictionary dictionary];
        for (NSDictionary *groupDic in groupCardList) {
            NSString *groupId = [groupDic objectForKey:@"GroupId"];
            NSArray *coms = [groupId componentsSeparatedByString:@"@"];
            NSString *domain = [coms lastObject];
            NSNumber *version = [groupDic objectForKey:@"LastUpdateTime"];
            if (domain && groupId) {
                NSMutableArray *users = [groupIdDic objectForKey:domain];
                if (users == nil) {
                    users = [NSMutableArray array];
                    [groupIdDic setObject:users forKey:domain];
                }
                [users addObject:@{@"muc_name": groupId ? groupId : @"", @"version": version ? version : @"0"}];
            }
        }
        if (groupCardList == nil) {
            for (NSString *groupId in groupIds) {
                NSString *groupC = @"conference.";
                if (![groupId containsString:groupC]) {
                    continue;
                }
                [[IMDataManager stIMDB_SharedInstance] stIMDB_insertGroup:groupId];
                NSArray *coms = [groupId componentsSeparatedByString:@"@"];
                NSString *comsLastStr = [coms lastObject];
                if (comsLastStr.length >= groupC.length) {
                    NSString *domain = comsLastStr;
                    if (domain && groupId) {
                        NSMutableArray *groups = [groupIdDic objectForKey:domain];
                        if (groups == nil) {
                            groups = [NSMutableArray arrayWithCapacity:10];
                            [groupIdDic setObject:groups forKey:domain];
                        }
                        [groups addObject:@{@"muc_name": groupId ? groupId : @"", @"version": @"0"}];
                    }
                }
            }
        }
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *domain in groupIdDic.allKeys) {
            NSArray *groups = [groupIdDic objectForKey:domain];
            if (groups.count <= 0) {
                return;
            }
            [params addObject:@{@"domain": domain ? domain : @"", @"mucs": groups}];
        }
        NSData *requestData = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        
        NSString *destUrl = [NSString stringWithFormat:@"%@/muc/get_muc_vcard.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] initWithCapacity:2];
        [requestHeaders setObject:@"application/json;" forKey:@"Content-type"];
        [requestHeaders setObject:[NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]] forKey:@"Cookie"];

        
        STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:STIMHTTPMethodPOST];
        [request setHTTPRequestHeaders:requestHeaders];
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
        [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
            if (response.code == 200) {
                STIMErrorLog(@"群名片获取当前线程 : %@", [NSThread currentThread]);
                NSData *responseData = response.data;
                NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSMutableArray *dataList = [NSMutableArray array];
                    NSArray *list = [result objectForKey:@"data"];
                    for (NSDictionary *dataDic in list) {
                        NSArray *mucList = [dataDic objectForKey:@"mucs"];
                        if (mucList) {
                            [dataList addObjectsFromArray:mucList];
                        }
                    }
                    if (dataList.count > 0) {
                        
                        dispatch_block_t block = ^{
                            for (NSString *groupId in groupIds) {
                                [self.groupVCardDict removeObjectForKey:groupId];
                            }
                        };
                        
                        if (dispatch_get_specific(self.cacheTag))
                            block();
                        else
                            dispatch_sync(self.cacheQueue, block);
                        
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateGroupCards:dataList];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:groupIds];
                        });
                    }
                }
            }
        } failure:^(NSError *error) {
            STIMErrorLog(@"获取群名片接口失败。：%@", error);
        }];
    });
}

- (void)getIncrementGroupCards {
    NSString *destUrl = [NSString stringWithFormat:@"%@/muc/get_user_increment_muc_vcard.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] initWithCapacity:2];
    [requestHeaders setObject:@"application/json;" forKey:@"Content-type"];
    [requestHeaders setObject:[NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]] forKey:@"Cookie"];

    NSInteger maxUTLastTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupListMaxUTLastUpdateTime];
    NSDictionary *paramDic = @{@"lastupdtime":[NSString stringWithFormat:@"%ld", maxUTLastTime], @"userid":[STIMManager getLastUserName]};
    NSData *requestData = [[STIMJSONSerializer sharedInstance] serializeObject:paramDic error:nil];

    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:requestUrl];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPRequestHeaders:requestHeaders];
    [request setHTTPBody:[NSMutableData dataWithData:requestData]];
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            STIMErrorLog(@"群名片获取当前线程 : %@", [NSThread currentThread]);
            NSData *responseData = response.data;
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSArray *dataList = [result objectForKey:@"data"];
                if ([dataList isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateIncrementGroupCards:dataList];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
                });
            }
        }
    } failure:^(NSError *error) {

    }];
}

#pragma mark - 群权限
- (BOOL)isGroupOwner:(NSString *)groupId {
    
    NSDictionary *myInfoDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMemberInfoByJid:[self getLastJid] WithGroupId:groupId];
    NSString *affiliation = [myInfoDic objectForKey:@"affiliation"];
    if ([affiliation isEqualToString:@"owner"]) {
        return YES;
    }
    return NO;
}

- (STIMGroupIdentity)GroupIdentityForUser:(NSString *)userId byGroup:(NSString *)groupId {
    if (userId == nil) {
        userId = [self getLastJid];
    }
    NSDictionary *myInfoDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupMemberInfoByJid:userId WithGroupId:groupId];
    NSString *affiliation = [myInfoDic objectForKey:@"affiliation"];
    STIMGroupIdentity id_ = STIMGroupIdentityNone;
    if ([affiliation isEqualToString:@"owner"]) {
        id_ = STIMGroupIdentityOwner;
    }else if ([affiliation isEqualToString:@"admin"]) {
        id_ = STIMGroupIdentityAdmin;
    }
    return id_;
}


- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name isInitiative:(BOOL)initiative{
    
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertGroup:groupId];
    
    NSDictionary *dict = [[XmppImManager sharedInstance] groupMembersByGroupId:groupId];
    if (dict.count > 0) {
        if (initiative) {
            [self joinGroupWithBuddies:groupId groupName:groupId WithInviteMember:@[[[STIMManager sharedInstance] getLastJid]] withCallback:nil];
        } else {
            
            [self joinGroupWithBuddies:groupId groupName:groupId WithInviteMember:dict withCallback:nil];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setMucVcardForGroupId:groupId WithNickName:nil WithTitle:nil WithDesc:nil WithHeaderSrc:nil withCallBack:nil];
        [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:[[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] WithNeedUpdate:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOpenGroupChatVc object:groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMyGroupListUpdate object:nil];
    });
    
    return YES;
}

- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name WithPassword:(NSString *)password {
    
    return NO;
}

- (BOOL)quitGroupId:(NSString *)groupId {
    
    BOOL quitSuccess = [[XmppImManager sharedInstance] quitGroupDelRegister:groupId];
    if (quitSuccess) {
        [self removeSessionById:groupId];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroup:groupId];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroupMemberWithGroupId:groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomLeave object:groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupListUpdate object:nil];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)destructionGroup:(NSString *)groupId {
    BOOL destorySuccess = [[XmppImManager sharedInstance] destoryChatRoom:groupId];
    if (destorySuccess) {
        [self removeSessionById:groupId];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroup:groupId];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroupMemberWithGroupId:groupId];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)inviteMember:(NSArray *)members ToGroupId:(NSString *)groupId {
    
    BOOL Success = [[XmppImManager sharedInstance] inviteGroupMembers:members ToGroupId:groupId];
    return Success;
}

- (NSDictionary *)defaultGroupSetting {
    
    return nil;
}

- (void)createGroupByGroupName:(NSString *)groupName
                WithMyNickName:(NSString *)nickName
              WithInviteMember:(NSArray *)members
                   WithSetting:(NSDictionary *)settingDic
                      WithDesc:(NSString *)desc
             WithGroupNickName:(NSString *)groupNickName
                  WithComplate:(void (^)(BOOL,NSString *))complate{
    groupName = [groupName lowercaseString];
    if ([[XmppImManager sharedInstance] pbCreateChatRomm:groupName]) {
        NSString *groupId = [NSString stringWithFormat:@"%@@conference.%@",groupName,[self getDomain]];
        [[XmppImManager sharedInstance] registerJoinGroup:groupId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMyGroupListUpdate object:nil];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_insertGroup:groupId];
        if (members.count > 0) {
            [self joinGroupWithBuddies:groupId groupName:groupNickName WithInviteMember:members withCallback:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setMucVcardForGroupId:groupId WithNickName:groupNickName WithTitle:nil WithDesc:desc WithHeaderSrc:nil withCallBack:nil];
            [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:[[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] WithNeedUpdate:YES];
            complate(YES,groupId);
        });
    } else {
        complate(NO,nil);
    }
}

-(void)joinGroupWithBuddies:(NSString *)groupID  groupName:(NSString *)groupName WithInviteMember:(NSArray *)members withCallback:(dispatch_block_t) block {
    
    [[XmppImManager sharedInstance] inviteGroupMembers:members ToGroupId:groupID];
    if (block) {
        block();
    }
}

- (BOOL)removeGroupMemberWithName:(NSString *)name WithJid:(NSString *)memberJid ForGroupId:(NSString *)groupId {
    
    return [[XmppImManager sharedInstance] removeGroupId:groupId ForMemberJid:memberJid WithNickName:name];
}

- (BOOL)setGroupAdminWithGroupId:(NSString *)groupId withIsAdmin:(BOOL)isAdmin WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid {
    if (YES == isAdmin) {
        return [[XmppImManager sharedInstance] setGroupId:groupId WithAdminNickName:nickName ForJid:memberJid];
    } else {
        return [[XmppImManager sharedInstance] setGroupId:groupId WithMemberNickName:nickName ForJid:memberJid];
    }
}

#pragma mark - SearchGroup

- (NSInteger)searchGroupTotalCountBySearchStr:(NSString *)searchStr {
    __block NSInteger totalCount = 0;
    dispatch_block_t block = ^{
        totalCount = [[IMDataManager stIMDB_SharedInstance] stIMDB_getLocalGroupTotalCountByUserIds:@[searchStr]];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return totalCount;
}

- (NSArray *)searchGroupBySearchStr:(NSString *)searchStr  WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        array = [[IMDataManager stIMDB_SharedInstance] stIMDB_searchGroupByUserIds:@[searchStr] WithLimit:limit WithOffset:offset];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return array;
}

- (NSArray *)searchGroupUserBySearchStr:(NSString *)searchStr inGroup:(NSString *)groupId {
    
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserListBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_searchUserBySearchStr:searchStr notInGroup:groupId];
}

- (STIMMessageDirection)getGroupMsgDirectionWithSendJid:(NSString *)sendJid {
    STIMMessageDirection direction = [sendJid isEqualToString:[self getLastJid]] ? STIMMessageDirection_Sent : STIMMessageDirection_Received;
    return direction;
}

- (void)updateChatRoomList {
    
    if ([self.groupList count] > 0) {
        
        [self.groupList removeAllObjects];
    }
    self.isStartPushNotify = YES;
}

- (void)quickJoinAllGroup {
    if ([[STIMAppInfo sharedInstance] appType] != STIMProjectTypeQChat) {
        self.lastMaxGroupVersion = [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserCacheDataWithKey:kGetIncrementMucListVersion withType:11];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
           [self getIncrementMucList:self.lastMaxGroupVersion];
        });
    } else {
        [[XmppImManager sharedInstance] quickJoinAllGroup];
    }
}

- (void)checkGroupList:(NSArray *)groupList {
    
    NSArray *oldGroupList = [self getMyGroupList];
    
    for (NSDictionary *myGroup in oldGroupList) {
        NSString *groupName = [myGroup objectForKey:@"GroupId"];
        if (![[groupList valueForKey:@"groupId"] containsObject:groupName]) {
            [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroup:groupName];
            [self removeSessionById:groupName];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteGroupMemberWithGroupId:groupName];
        }
    }
}

- (void)joinGroupList {
    
    for (NSDictionary *group in [self getMyGroupList]) {
        NSString *groupId = [group objectForKey:@"GroupId"];
        NSString *nickname = [self getMyNickName];
        NSString *password = nil;
        [self joinGroupId:groupId ByName:nickname WithPassword:password];
    }
}

- (NSDictionary *)getUserInfoByGroupName:(NSString *)groupName {
    
    __block NSDictionary *result = nil;
    
    dispatch_block_t block = ^{
        NSDictionary *tempDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserByIndex:groupName];
        if (tempDic) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
            if ([[STIMAppInfo sharedInstance] appType] != STIMProjectTypeQChat) {
                NSString *rtxId = [dic objectForKey:@"UserId"];
                NSString *desc = [self.friendDescDic objectForKey:rtxId];
                if (desc) {
                    [dic setObject:desc forKey:@"DescInfo"];
                }
            }
            result = dic;
        }
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    return result;
}

- (void)getIncrementMucList:(NSTimeInterval)lastTime {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        STIMVerboseLog(@" ======= 开始通过增量群列表拉群列表数据 =========");
        
        NSString *destUrl = [NSString stringWithFormat:@"%@/muc/get_increment_mucs.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
        NSDictionary *param = @{@"u" : [STIMManager getLastUserName], @"t" : @(lastTime) ? @(lastTime) : @(0), @"d": [[XmppImManager sharedInstance] domain]};
        STIMVerboseLog(@"增量群列表拉群列表参数 : %@", [[STIMJSONSerializer sharedInstance] serializeObject:param]);
        NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:param error:nil];
        
        [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
            NSDictionary *resultDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
            NSInteger errcode = [[resultDic objectForKey:@"errcode"] integerValue];
            if (ret && errcode == 0) {
                NSArray *newGroupList = [resultDic objectForKey:@"data"];
                if ([newGroupList isKindOfClass:[NSArray class]]) {
                    [self dealWithIncrement_mucs:newGroupList];
                }
            } else {
                STIMErrorLog(@"增量群列表失败 : %@", [resultDic objectForKey:@"errmsg"]);
            }
        } withFailedCallBack:^(NSError *error) {
            
        }];
    });
}

- (void)dealWithIncrement_mucs:(NSArray *)newGroupList {
    if (self.updateGroupList == nil) {
        self.updateGroupList = [NSMutableArray arrayWithCapacity:[newGroupList count]];
    }
    NSMutableArray *updateGroupList = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *deleteGroupList = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *removeSessionList = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *deleteGroupMemberList = [NSMutableArray arrayWithCapacity:3];
    for (NSDictionary *group in newGroupList) {
        NSString *groupId = [group objectForKey:@"M"];
        NSString *groupDomain = [group objectForKey:@"D"];
        NSTimeInterval groupUpdateTime = [[group objectForKey:@"T"] doubleValue];
        NSInteger flag = [[group objectForKey:@"F"] integerValue];
        if (self.lastMaxGroupVersion < groupUpdateTime) {
            self.lastMaxGroupVersion = groupUpdateTime;
        }
        NSString *newGroupId = [NSString stringWithFormat:@"%@@%@", groupId, groupDomain];
        //flag 为 Ture 新增，NO 为销毁或退出
        if (flag) {
            NSArray *tempGroup = @[newGroupId, @(0)];
            [updateGroupList addObject:tempGroup];
        } else {
            NSArray *tempGroup = @[newGroupId];
            [deleteGroupList addObject:tempGroup];
        }
    }
    if (updateGroupList.count > 0) {
        //更新群组
        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertGroups:updateGroupList];
    }
    if (deleteGroupList.count > 0) {
        //删除群组
        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteGroups:deleteGroupList];
    }
    //删除session
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSessionList:deleteGroupList];
    
    [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateUserCacheDataWithKey:kGetIncrementMucListVersion withType:11 withValue:@"群列表时间戳" withValueInt:self.lastMaxGroupVersion];
}

@end
