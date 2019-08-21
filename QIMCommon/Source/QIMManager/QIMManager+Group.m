//
//  QIMManager+Group.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "QIMManager+Group.h"
#import <objc/runtime.h>

@implementation QIMManager (Group)

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

//群成员变更通知
- (void)setGroupMemberChangerDic:(NSMutableDictionary *)groupMemberChangerDic {
    objc_setAssociatedObject(self, "groupMemberChangerDic", groupMemberChangerDic, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSMutableDictionary *)groupMemberChangerDic {
    NSMutableDictionary *groupMemberChangerDic = objc_getAssociatedObject(self, "groupMemberChangerDic");
    if (!groupMemberChangerDic) {
        groupMemberChangerDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return groupMemberChangerDic;
}

- (NSArray *)getGroupList {
    return self.groupList;
}

#pragma mark - Group VCard

- (NSDictionary *)getGroupCardByGroupId:(NSString *)groupId {
    
    __block NSDictionary *groupVCard = nil;
    if (!self.groupVCardDict) {
        self.groupVCardDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    groupVCard = [self.groupVCardDict objectForKey:groupId];
    if (!groupVCard.count) {
        groupVCard = [[IMDataManager sharedInstance] getGroupCardByGroupId:groupId];
        dispatch_block_t block = ^{

            [self.groupVCardDict setQIMSafeObject:groupVCard forKey:groupId];
        };
        if (dispatch_get_specific(self.cacheTag))
            block();
        else
            dispatch_sync(self.cacheQueue, block);
    }
    return groupVCard;
}

- (NSArray *)syncgroupMember:(NSString *)groupId {
    NSDictionary *dic = [[XmppImManager sharedInstance] groupMembersByGroupId:groupId];
    [[IMDataManager sharedInstance] bulkInsertGroupMember:[dic allValues] WithGroupId:groupId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QIMGroupMemberWillUpdate" object:groupId];
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
    NSArray *result = [[IMDataManager sharedInstance] qimDB_getGroupMember:groupId];
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
    NSDictionary *memberInfo = [[IMDataManager sharedInstance] getGroupMemberInfoByJid:[self getLastJid] WithGroupId:groupId];
    return memberInfo ? YES : NO;
}

#pragma mark - 群头像

+ (UIImage *)defaultGroupHeaderImage {
    static UIImage *__defaultGroupHeaderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *groupHeaderPath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMGroupDefaultHeader" ofType:@"png"];
        __defaultGroupHeaderImage = [UIImage imageWithContentsOfFile:groupHeaderPath];
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
        NSInteger remind = [[QIMManager sharedInstance] getClientConfigDeleteFlagWithType:QIMClientConfigTypeKNoticeStickJidDic WithSubKey:groupName];
        if (remind == 0) {
            groupPush = NO;
            dispatch_block_t block = ^{

                [self.notMindGroupDic setQIMSafeObject:@(-1) forKey:groupName];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        } else {
            groupPush = YES;
            dispatch_block_t block = ^{
                
                [self.notMindGroupDic setQIMSafeObject:@(1) forKey:groupName];
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
    BOOL success = [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKNoticeStickJidDic WithSubKey:groupId WithConfigValue:configValue WithDel:on];
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRemindStateChange object:groupId];
        });
    }
    return success;
}

- (BOOL)setMucVcardForGroupId:(NSString *)groupId
                 WithNickName:(NSString *)nickName
                    WithTitle:(NSString *)title
                     WithDesc:(NSString *)desc
                WithHeaderSrc:(NSString *)headerSrc {
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (groupId.length > 0) {
        [paramDic setObject:groupId ? groupId : @"" forKey:@"muc_name"];
    }
    if (nickName.length > 0) {
        [paramDic setObject:nickName forKey:@"nick"];
    }
    if (title.length > 0) {
        [paramDic setObject:title forKey:@"title"];
    }
    if (desc.length > 0) {
        [paramDic setObject:desc forKey:@"desc"];
    }
    if (headerSrc.length > 0) {
        [paramDic setObject:headerSrc forKey:@"pic"];
    }
    if (paramDic.count < 2) {
        return NO;
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/setmucvcard?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@[paramDic] error:nil];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    [request appendPostData:data];
    [request setShouldCompressRequestBody:NO];
    [request setAllowCompressedResponse:NO];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error && request.responseStatusCode == 200) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSArray *result = [[[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol] objectForKey:@"data"];
        if (errol == nil && result.count > 0) {
            NSDictionary *resultDic = [result firstObject];
            NSString *groupId = [resultDic objectForKey:@"Set Muc-Vcard"];
            NSString *version = [resultDic objectForKey:@"version"];
            [[IMDataManager sharedInstance] updateGroup:groupId WihtNickName:nickName WithTopic:title WithDesc:desc WithHeaderSrc:headerSrc WithVersion:version];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kGroupCardChanged object:@[groupId]];
                if (nickName.length > 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:@[groupId] userInfo:nil];
                }
            });
            return YES;
        }
    }
    return NO;
}

- (NSArray *)getGroupIdList {
    return [[IMDataManager sharedInstance] getGroupIdList];
}

- (NSArray *)getMyGroupList {
    return [[IMDataManager sharedInstance] qimDB_getGroupList];
}

- (void)updateGroupCardByGroupId:(NSString *)groupId {
    if (!groupId) {
        return;
    }
    [self updateGroupCard:@[groupId]];
}

// 3.获取跨域聊天室vcard信息
- (void)updateGroupCard:(NSArray *)groupIds {

    if (groupIds.count <= 0) {
        return;
    }
    if (!self.load_customEvent_queue) {
        self.load_customEvent_queue = dispatch_queue_create("Load CustomEvent Queue", DISPATCH_QUEUE_SERIAL);
    }
    dispatch_async(self.load_customEvent_queue, ^{
        NSArray *groupCardList = [[IMDataManager sharedInstance] getGroupVCardByGroupIds:groupIds];
        NSMutableDictionary *groupIdDic = [NSMutableDictionary dictionary];
        for (NSDictionary *groupDic in groupCardList) {
            NSString *groupId = [groupDic objectForKey:@"GroupId"];
            NSArray *coms = [groupId componentsSeparatedByString:@"@"];
            NSArray *comLastObject = [[coms lastObject] componentsSeparatedByString:@"."];
            NSString *domain = @"";
            if ([comLastObject lastObject]) {
                domain = [comLastObject lastObject];
            }
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
                [[IMDataManager sharedInstance] insertGroup:groupId];
                NSArray *coms = [groupId componentsSeparatedByString:@"@"];
                NSString *comsLastStr = [coms lastObject];
                if (comsLastStr.length >= groupC.length) {
                    NSString *domain = [[coms lastObject] substringFromIndex:groupC.length];
                    if (domain && groupId) {
                        NSMutableArray *users = [groupIdDic objectForKey:domain];
                        if (users == nil) {
                            users = [NSMutableArray arrayWithCapacity:10];
                            [groupIdDic setObject:users forKey:domain];
                        }
                        [users addObject:@{@"muc_name": groupId ? groupId : @"", @"version": @"0"}];
                    }
                }
            }
        }
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *domain in groupIdDic.allKeys) {
            NSArray *users = [groupIdDic objectForKey:domain];
            if (users.count <= 0) {
                return;
            }
            [params addObject:@{@"domain": domain ? domain : @"", @"mucs": users}];
        }
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        
        NSString *destUrl = [NSString stringWithFormat:@"%@/domain/get_muc_vcard?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        
        if (self.remoteKey.length <= 0) {
            [self updateRemoteLoginKey];
        }
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] initWithCapacity:2];
        [requestHeaders setObject:@"application/json;" forKey:@"Content-type"];


        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [request setHTTPRequestHeaders:requestHeaders];
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                QIMErrorLog(@"群名片获取当前线程 : %@", [NSThread currentThread]);
                NSData *responseData = response.data;
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
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
                        
                        [[IMDataManager sharedInstance] bulkUpdateGroupCards:dataList];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:groupIds];
                        });
                    }
                }
            }
        } failure:^(NSError *error) {
            QIMErrorLog(@"获取群名片接口失败。：%@", error);
        }];
    });
}

- (NSDictionary *)updateGroupCard2:(NSString *)groupId {
    
    if (groupId.length <= 0) {
        return nil;
    }
    if (!self.load_customEvent_queue) {
        self.load_customEvent_queue = dispatch_queue_create("Load CustomEvent Queue", DISPATCH_QUEUE_SERIAL);
    }
//    dispatch_async(self.load_customEvent_queue, ^{
        NSDictionary *groupDic = [[IMDataManager sharedInstance] getGroupCardByGroupId:groupId];
        NSMutableDictionary *groupIdDic = [NSMutableDictionary dictionary];
        NSArray *coms = [groupId componentsSeparatedByString:@"@"];
        NSArray *comLastObject = [[coms lastObject] componentsSeparatedByString:@"."];
        NSString *domain = @"";
        if ([comLastObject lastObject]) {
            domain = [comLastObject lastObject];
        }
        NSNumber *version = [groupDic objectForKey:@"LastUpdateTime"];
        if (domain && groupId) {
            NSMutableArray *users = [groupIdDic objectForKey:domain];
            if (users == nil) {
                users = [NSMutableArray array];
                [groupIdDic setObject:users forKey:domain];
            }
            [users addObject:@{@"muc_name": groupId ? groupId : @"", @"version": version ? version : @"0"}];
        }
        
        [[IMDataManager sharedInstance] insertGroup:groupId];
        
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *domain in groupIdDic.allKeys) {
            NSArray *users = [groupIdDic objectForKey:domain];
            if (users.count <= 0) {
                return nil;
            }
            [params addObject:@{@"domain": domain ? domain : @"", @"mucs": users}];
        }
    
    NSArray *array = @[@{
        @"domain" : @"conference.ejabpublic",
        @"mucs" : @[
                      @{
                          @"muc_name" : @"b3981c383416429e9daf82be211c1c2b@conference.ejabpublic",
                          @"version" : @(0)
                      }
                ]
        }];
    
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:array error:nil];
        
        NSString *destUrl = [NSString stringWithFormat:@"%@/domain/get_muc_vcard?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        
        if (self.remoteKey.length <= 0) {
            [self updateRemoteLoginKey];
        }
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        NSMutableDictionary *requestHeaders = [[NSMutableDictionary alloc] initWithCapacity:2];
        [requestHeaders setObject:@"application/json;" forKey:@"Content-type"];
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
        [request setRequestMethod:@"POST"];
        [request setUseCookiePersistence:NO];
        [request setPostBody:[NSMutableData dataWithData:requestData]];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        [request setRequestHeaders:cookieProperties];
        [request startSynchronous];
        NSError *error = [request error];
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
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
                            [self.groupVCardDict removeObjectForKey:groupId];
                        };
                        
                        if (dispatch_get_specific(self.cacheTag))
                            block();
                        else
                            dispatch_sync(self.cacheQueue, block);
                    }
                }
            }
        }
        
        /*
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [request setHTTPRequestHeaders:requestHeaders];
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                QIMErrorLog(@"群名片获取当前线程 : %@", [NSThread currentThread]);
                NSData *responseData = response.data;
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
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
                        
                        [[IMDataManager sharedInstance] bulkUpdateGroupCards:dataList];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kGroupNickNameChanged object:groupIds];
                        });
                    }
                }
            }
        } failure:^(NSError *error) {
            QIMErrorLog(@"获取群名片接口失败。：%@", error);
        }];
        */
//    });
    return nil;
}

#pragma mark - GroupHeader 群头像

- (NSString *)getGroupImagePathFromLocalByGroupId:(NSString *)groupId {
    
    NSString *groupHeaderImagePath = [[self getImagerCache] stringByAppendingPathComponent:groupId];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:groupHeaderImagePath];
    if (isExist) {
        return groupHeaderImagePath;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self getGroupHeaderImageFromRemoteWithGroupId:groupId];
        });
        NSString *groupHeaderPath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMGroupDefaultHeader" ofType:@"png"];
        return groupHeaderPath;
    }
}

- (UIImage *)getGroupImageFromLocalByGroupId:(NSString *)groupId {
    
    if (groupId.length <= 0) {
        return nil;
    }
    UIImage *groupImage = [self.groupHeaderImageDic objectForKey:groupId];
    if (groupImage == nil) {
        
        NSString *groupHeaderImagePath = [[self getImagerCache] stringByAppendingPathComponent:groupId];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:groupHeaderImagePath];
        if (isExist) {
            groupImage = [[UIImage alloc] initWithContentsOfFile:groupHeaderImagePath];
            if (groupImage) {
                [self.groupHeaderImageDic setObject:groupImage forKey:groupId];
            } else {
                groupImage = [QIMManager defaultGroupHeaderImage];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    [self getGroupHeaderImageFromRemoteWithGroupId:groupId];
                });
            }
        } else {
            groupImage = [QIMManager defaultGroupHeaderImage];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self getGroupHeaderImageFromRemoteWithGroupId:groupId];
            });
        }
    }
    return groupImage;
}

/**
 根据GroupId从远程拉取群头像
 */
- (void)getGroupHeaderImageFromRemoteWithGroupId:(NSString *)groupId {
    
    NSDictionary *groupVcard = [self getGroupCardByGroupId:groupId];
    if (groupVcard.count) {
        NSString *headerRemoteSrc = [groupVcard objectForKey:@"HeaderSrc"];
        if (headerRemoteSrc.length > 0) {
            NSString *headerUrl = headerRemoteSrc;
            if (![headerRemoteSrc qim_hasPrefixHttpHeader]) {
                headerUrl = [[QIMNavConfigManager sharedInstance].innerFileHttpHost stringByAppendingFormat:@"/%@", headerRemoteSrc];
            }
            QIMVerboseLog(@"根据GroupId开始更新群组头像getGroupHeaderWithGroupId  GroupId : %@, 请求URL : %@", groupId, headerUrl);
            
            QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:headerUrl]];
            [request setTimeoutInterval:2.0f];
            __weak __typeof(self) weakSelf = self;
            [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
                if (response.code == 200) {
                    __typeof(self) strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    NSData *headerImageData = response.data;
                    if (headerImageData.length > 0) {
                        UIImage *groupHeaderImage = [UIImage imageWithData:headerImageData];
                        NSString *headerLocalSrc = [[strongSelf getImagerCache] stringByAppendingPathComponent:groupId];
                        if (headerLocalSrc.length > 0) {
                            [[NSFileManager defaultManager] removeItemAtPath:headerLocalSrc error:nil];
                        }
                        [headerImageData writeToFile:headerLocalSrc atomically:YES];
                        [strongSelf.groupHeaderImageDic setObject:groupHeaderImage forKey:groupId];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kUserHeaderImgUpdate object:groupId];
                        });
                    }
                }
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

- (BOOL)isGroupOwner:(NSString *)groupId {
    
    NSDictionary *myInfoDic = [[IMDataManager sharedInstance] getGroupMemberInfoByJid:[self getLastJid] WithGroupId:groupId];
    NSString *affiliation = [myInfoDic objectForKey:@"affiliation"];
    if ([affiliation isEqualToString:@"owner"]) {
        return YES;
    }
    return NO;
}

- (QIMGroupIdentity)GroupIdentityForUser:(NSString *)userId byGroup:(NSString *)groupId {
    if (userId == nil) {
        userId = [self getLastJid];
    }
    NSDictionary *myInfoDic = [[IMDataManager sharedInstance] getGroupMemberInfoByJid:userId WithGroupId:groupId];
    NSString *affiliation = [myInfoDic objectForKey:@"affiliation"];
    QIMGroupIdentity id_ = QIMGroupIdentityNone;
    if ([affiliation isEqualToString:@"owner"]) {
        id_ = QIMGroupIdentityOwner;
    }else if ([affiliation isEqualToString:@"admin"]) {
        id_ = QIMGroupIdentityAdmin;
    }
    return id_;
}

- (NSString *)getGroupaffiliationWithIdentity:(QIMGroupIdentity)identity {
    NSString *affiliation = @"none";
    if (identity == QIMGroupIdentityNone) {
        affiliation = @"none";
    } else if (identity == QIMGroupIdentityAdmin) {
        affiliation = @"admin";
    } else if (identity == QIMGroupIdentityOwner) {
        affiliation = @"owner";
    } else {
        affiliation = @"none";
    }
    return affiliation;
}

- (BOOL)joinGroupId:(NSString *)groupId ByName:(NSString *)name isInitiative:(BOOL)initiative{
    
    [[IMDataManager sharedInstance] insertGroup:groupId];
    
    NSDictionary *dict = [[XmppImManager sharedInstance] groupMembersByGroupId:groupId];
    if (dict.count > 0) {
        if (initiative) {
            [self joinGroupWithBuddies:groupId groupName:groupId WithInviteMember:@[[[QIMManager sharedInstance] getLastJid]] withCallback:nil];
        } else {
            
            [self joinGroupWithBuddies:groupId groupName:groupId WithInviteMember:dict withCallback:nil];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setMucVcardForGroupId:groupId WithNickName:nil WithTitle:nil WithDesc:nil WithHeaderSrc:nil];
        [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:[[NSDate date] qim_timeIntervalSince1970InMilliSecond] WithNeedUpdate:YES];
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
        [[IMDataManager sharedInstance] deleteGroup:groupId];
        [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupId];
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
        [[IMDataManager sharedInstance] deleteGroup:groupId];
        [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupId];
        return YES;
    } else {
        return NO;
    }
}

- (void)addGroupMemberChange:(NSString *)groupId {
    [self.groupMemberChangerDic setObject:groupId forKey:groupId];
    [[QIMUserCacheManager sharedInstance] setUserObject:self.groupMemberChangerDic forKey:kGroupMemberChangeDic];
}

- (void)removeGroupMemberChange:(NSString *)groupId {
    [self.groupMemberChangerDic removeObjectForKey:groupId];
    [[QIMUserCacheManager sharedInstance] setUserObject:self.groupMemberChangerDic forKey:kGroupMemberChangeDic];
}

- (BOOL)isGroupMemberChangeByGroupId:(NSString *)groupId {
    return [self.groupMemberChangerDic objectForKey:groupId] != nil;
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
        [[IMDataManager sharedInstance] insertGroup:groupId];
        if (members.count > 0) {
            [self joinGroupWithBuddies:groupId groupName:groupNickName WithInviteMember:members withCallback:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setMucVcardForGroupId:groupId WithNickName:groupNickName WithTitle:nil WithDesc:desc WithHeaderSrc:nil];
            [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:[[NSDate date] qim_timeIntervalSince1970InMilliSecond] WithNeedUpdate:YES];
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

#pragma mark - SearchGroup

- (NSInteger)searchGroupTotalCountBySearchStr:(NSString *)searchStr {
    __block NSInteger totalCount = 0;
    dispatch_block_t block = ^{
        totalCount = [[IMDataManager sharedInstance] getLocalGroupTotalCountByUserIds:@[searchStr]];
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
        array = [[IMDataManager sharedInstance] searchGroupByUserIds:@[searchStr] WithLimit:limit WithOffset:offset];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return array;
}

- (NSArray *)searchGroupUserBySearchStr:(NSString *)searchStr inGroup:(NSString *)groupId {
    
    return [[IMDataManager sharedInstance] selectUserListBySearchStr:searchStr inGroup:groupId];
}

- (NSArray *)searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId {
    return [[IMDataManager sharedInstance] searchUserBySearchStr:searchStr notInGroup:groupId];
}

- (MessageDirection)getGroupMsgDirectionWithSendJid:(NSString *)sendJid {
    MessageDirection direction = [sendJid isEqualToString:[self getLastJid]] ? MessageDirection_Sent : MessageDirection_Received;
    return direction;
}

- (void)updateChatRoomList {
    
    if ([self.groupList count] > 0) {
        
        [self.groupList removeAllObjects];
    }
    self.isStartPushNotify = YES;
}

- (void)quickJoinAllGroup {
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
        self.lastMaxGroupVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"lastJoinGroupTime"] doubleValue];
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
            [[IMDataManager sharedInstance] deleteGroup:groupName];
            [self removeSessionById:groupName];
            [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupName];
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
        NSDictionary *tempDic = [[IMDataManager sharedInstance] selectUserByIndex:groupName];
        if (tempDic) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
            if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
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
    
    QIMVerboseLog(@" ======= 开始通过增量群列表拉群列表数据 =========");
    NSString *destUrl = [NSString stringWithFormat:@"%@/get_increment_mucs?u=%@&k=%@", [[QIMNavConfigManager sharedInstance] httpHost], [QIMManager getLastUserName], self.remoteKey];
    destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *param = @{@"u" : [QIMManager getLastUserName], @"t" : @(lastTime) ? @(lastTime) : @(0), @"d": [[XmppImManager sharedInstance] domain]};
    QIMVerboseLog(@"增量群列表拉群列表参数 : %@", [[QIMJSONSerializer sharedInstance] serializeObject:param]);
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:param error:nil];
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeaders setObject:@"application/json;" forKey:@"content-type"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPRequestHeaders:requestHeaders];
    [request setHTTPBody:data];
    __weak __typeof(self) weakSelf = self;
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = response.data;
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSArray *newGroupList = [result objectForKey:@"data"];
                if (strongSelf.updateGroupList == nil) {
                    strongSelf.updateGroupList = [NSMutableArray arrayWithCapacity:[newGroupList count]];
                }
                for (NSDictionary *group in newGroupList) {
                    NSString *groupId = [group objectForKey:@"M"];
                    NSString *groupDomain = [group objectForKey:@"D"];
                    NSTimeInterval groupUpdateTime = [[group objectForKey:@"T"] doubleValue];
                    NSInteger flag = [[group objectForKey:@"F"] integerValue];
                    if (strongSelf.lastMaxGroupVersion < groupUpdateTime) {
                        strongSelf.lastMaxGroupVersion = groupUpdateTime;
                    }
                    NSString *newGroupId = [NSString stringWithFormat:@"%@@%@", groupId, groupDomain];
                    //flag 为 Ture 新增，NO 为销毁或退出
                    if (flag) {
                        [strongSelf.updateGroupList addObject:newGroupId];
                        [[IMDataManager sharedInstance] insertGroup:newGroupId];
                    } else {
                        NSMutableArray *tempMyGroups = [NSMutableArray arrayWithArray:[strongSelf getMyGroupList]];
                        for (NSDictionary *myGroup in tempMyGroups) {
                            NSString *groupId = [myGroup objectForKey:@"GroupId"];
                            if ([newGroupId isEqualToString:groupId]) {
                                [strongSelf.groupList removeObject:myGroup];
                                NSString *combineGroupId = [NSString stringWithFormat:@"%@<>%@", groupId, groupId];
                                [strongSelf removeStickWithCombineJid:combineGroupId WithChatType:ChatType_GroupChat];
                                [[IMDataManager sharedInstance] deleteGroup:groupId];
                                [strongSelf removeSessionById:groupId];
                                [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupId];
                            }
                        }
                    }
                }
            }
            [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastMaxGroupVersion) forKey:@"lastJoinGroupTime"];
        }
    } failure:^(NSError *error) {
        
    }];
}

@end
