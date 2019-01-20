//
//  QIMManager+UserVcard.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/23.
//

#import "QIMManager+UserVcard.h"

@implementation QIMManager (UserVcard)

/**
 第三方Cell默认头像
 
 @return 用户头像
 */
+ (UIImage *)defaultCommonTrdInfoImage {
    static UIImage *__defaultCommonTrdInfoImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *commonTrdInfoImagePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"Activity_default" ofType:@"png"];
        __defaultCommonTrdInfoImage = [UIImage imageWithContentsOfFile:commonTrdInfoImagePath];
    });
    return __defaultCommonTrdInfoImage;
}

+ (NSString *)defaultCommonTrdInfoImagePath {
    
    return [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"Activity_default" ofType:@"png"];
}

+ (NSData *)defaultUserHeaderImage {
     
    static NSData *__defaultUserHeaderImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *singleHeaderPath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMManDefaultHeader" ofType:@"png"];
        __defaultUserHeaderImage = [NSData dataWithContentsOfFile:singleHeaderPath];
    });
    return __defaultUserHeaderImage;
}

+ (NSString *)defaultUserHeaderImagePath {
    return [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMManDefaultHeader" ofType:@"png"];
}

#pragma mark - 用户备注

- (void)updateUserMarkupNameWithUserId:(NSString *)userId WithMarkupName:(NSString *)markUpName {
    [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKMarkupNames WithSubKey:userId WithConfigValue:markUpName WithDel:(markUpName.length > 0) ? NO : YES];
}

- (NSString *)getUserMarkupNameWithUserId:(NSString *)userId {
    
    if (userId.length <= 0) {
        return nil;
    }
    __block NSString *result = nil;
        if (!self.userMarkupNameDic) {
            self.userMarkupNameDic = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        NSString *tempMarkupName = [self.userMarkupNameDic objectForKey:userId];
        if (!tempMarkupName.length) {
            tempMarkupName = [[QIMManager sharedInstance] getClientConfigInfoWithType:QIMClientConfigTypeKMarkupNames WithSubKey:userId];
            if (!tempMarkupName) {
                tempMarkupName = [[self getUserInfoByUserId:userId] objectForKey:@"Name"];
            }
            dispatch_block_t block = ^{

                [self.userMarkupNameDic setQIMSafeObject:tempMarkupName forKey:userId];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        }
        result = tempMarkupName;
    
    return result;
}

#pragma mark - 用户Profile

- (NSDictionary *)getLocalProfileForUserId:(NSString *)userId {
    NSString *filename = [self.userProfilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cfg", userId]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filename];
    if (fileExists) {
        
        NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:filename];
        return result;
    }
    return nil;
}

- (void)userProfilewithUserId:(NSString *)userId needupdate:(BOOL)update withBlock:(void (^)(NSDictionary *))block {
    
    NSString *filename = [self.userProfilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cfg", userId]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filename];
    if (fileExists) {
        
        if (!update) {
            
            NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:filename];
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(result);
                });
            }
        } else {
            
            //强制去Remote获取下
            NSDictionary *userInfo = [self getRemoteUserProfileForUserIds:@[userId]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                block(userInfo);
            });
        }
    } else {
        
        //本地不存在，去Remote获取下
        NSDictionary *userInfo = [self getRemoteUserProfileForUserIds:@[userId]];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(userInfo);
        });
    }
}

- (NSDictionary *)getRemoteUserProfileForUserIds:(NSArray *)userIds {
    
    if (!userIds) {
        return nil;
    }
    //[{"user":"huajun.liu","version":"1"}]
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *usersVCardInfo = [NSMutableDictionary dictionary];
    NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kUsersVCardInfo];
    if (dic) {
        
        [usersVCardInfo setDictionary:dic];
    }
    for (NSString *userId in userIds) {
        
        NSDictionary *userInfo = [usersVCardInfo objectForKey:userId];
#pragma mark - 拷贝一次, [NSPathStore2 stringByAppendingPathComponent:]
        NSString *userProfilePath = [self.userProfilePath copy];
        NSString *filename = [userProfilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cfg", [NSString stringWithFormat:@"%@@%@", userInfo[@"U"], [self getDomain]]]];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filename];
        if (isExist) {
            
            NSString *user = userInfo[@"U"];
            NSString *version = userInfo[@"V"];
            [users addObject:@{@"user": user ? user : @"", @"version": version ? version : @"0", @"domain":[[XmppImManager sharedInstance] domain]}];
        } else {
            
            NSString *user = [userId componentsSeparatedByString:@"@"].firstObject;
            [users addObject:@{@"user": user ? user : @"", @"version": @"0", @"domain":[[XmppImManager sharedInstance] domain]}];
        }
        
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:users error:nil];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/get_user_profile?u=%@&k=%@&v=%@&p=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion], @"iPhone"]];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request addRequestHeader:@"Content-type" value:@"application/json;"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:[NSMutableData dataWithData:requestData]];
        [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
        [request startSynchronous];
        NSError *error = [request error];
        if ([request responseStatusCode] == 200 && !error) {
            
            NSData *responseData = [request responseData];
            NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            NSArray *result = [resDic objectForKey:@"data"];
            
            if ([result isKindOfClass:[NSArray class]]) {
                if (result.count > 0) {
                    for (NSDictionary *userInfo in result) {
                        
                        [usersVCardInfo setQIMSafeObject:userInfo forKey:[NSString stringWithFormat:@"%@@%@", userInfo[@"U"], [self getDomain]]];
                        if (userInfo) {
                            
                            NSString *filename = [self.userProfilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cfg", [NSString stringWithFormat:@"%@@%@", userInfo[@"U"], [self getDomain]]]];
                            [userInfo writeToFile:filename atomically:YES];
                        }
                    }
                    [[QIMUserCacheManager sharedInstance] setUserObject:usersVCardInfo forKey:kUsersVCardInfo];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //发送更新个性签名等
                        　[[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil];
                    });
                }
            }
            return usersVCardInfo;
        }
    }
    return nil;
}

- (void)updateUserSignatureForUser:(NSString *)userId signature:(NSString *)signature {
    
    //{"user":"xuejie.bi","mood":"134", "domain":"ejabhost1"}
    NSMutableDictionary *usersVCardInfo = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:kUsersVCardInfo]];
    
    NSString *escapeDomainUserId = [[userId componentsSeparatedByString:@"@"] firstObject];
    NSMutableDictionary *userParam = [NSMutableDictionary dictionaryWithCapacity:1];
    [userParam setQIMSafeObject:escapeDomainUserId forKey:@"user"];
    [userParam setQIMSafeObject:(signature.length > 0) ? signature : @"" forKey:@"mood"];
    [userParam setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"domain"];
    
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:userParam error:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/set_user_profile?u=%@&k=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey]];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setObject:@"application/json;" forKey:@"Content-type"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPRequestHeaders:requestHeader];
    [request setHTTPBody:[NSMutableData dataWithData:requestData]];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = response.data;
            NSError *errol = nil;
            NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
            BOOL ret = [[resDic objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *newUserInfo = [resDic objectForKey:@"data"];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:usersVCardInfo[userId]];
                if (userInfo.count <= 0) {
                    
                    userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
                    [userInfo setQIMSafeObject:[userId componentsSeparatedByString:@"@"].firstObject forKey:@"U"];
                    [userInfo setQIMSafeObject:@"0" forKey:@"V"];
                }
                [userInfo setQIMSafeObject:signature ? signature : @"" forKey:@"M"];
                
                if ([newUserInfo[@"version"] intValue] > [userInfo[@"V"] intValue]) {
                    
                    [userInfo setQIMSafeObject:newUserInfo[@"version"] forKey:@"V"];
                }
                
                NSString *filename = [self.userProfilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cfg", userId]];
                [userInfo writeToFile:filename atomically:YES];
                [usersVCardInfo setQIMSafeObject:userInfo forKey:userId];
                [[QIMUserCacheManager sharedInstance] setUserObject:usersVCardInfo forKey:kUsersVCardInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMyPersonalSignature object:nil];
                });
            }
        }
    } failure:^(NSError *error) {
        QIMVerboseLog(@"设置个性签名失败 : %@", error);
    }];
}

#pragma mark - 用户名片

- (NSDictionary *)getUserInfoByRTX:(NSString *)rtxId {
    
    __block NSDictionary *result = nil;
    
    dispatch_block_t block = ^{
        NSDictionary *tempDic = [[IMDataManager sharedInstance] selectUserByID:rtxId];
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

- (NSDictionary *)getUserInfoByUserId:(NSString *)myId {
    if (myId.length <= 0) {
        return nil;
    }
    __block NSDictionary *result = nil;
    if (!self.userVCardDict) {
        self.userVCardDict = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    NSDictionary *tempDic = [self.userVCardDict objectForKey:myId];
    if (!tempDic) {
        tempDic = [[IMDataManager sharedInstance] selectUserByJID:myId];
        
        dispatch_block_t block = ^{
            [self.userVCardDict setQIMSafeObject:tempDic forKey:myId];
        };
        if (dispatch_get_specific(self.cacheTag))
            block();
        else
            dispatch_sync(self.cacheQueue, block);
    }
    result = tempDic;
    
    return result;
}

- (NSDictionary *)getUserInfoByName:(NSString *)nickName {
    if (!nickName) {
        return nil;
    }
    __block NSDictionary *result = nil;
    __block NSString *filename = nil;
    __block BOOL fileExists = NO;
    dispatch_block_t block = ^{
        
        NSDictionary *memUserInfo = [self.userInfoDic objectForKey:nickName];
        NSString *userHeaderSrc = [memUserInfo objectForKey:@"HeaderSrc"];
        if (memUserInfo.count && userHeaderSrc.length > 0) {
            result = memUserInfo;
        } else {
            NSDictionary *tempDic = [[IMDataManager sharedInstance] selectUserByIndex:nickName];
            if (tempDic) {
                
                if (!self.userInfoDic) {
                    self.userInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
                }
                [self.userInfoDic setObject:tempDic forKey:nickName];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:tempDic];
                if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
                    
                    NSString *rtxId = [dic objectForKey:@"UserId"];
                    NSString *desc = [self.friendDescDic objectForKey:rtxId];
                    if (desc) {
                        
                        [dic setObject:desc forKey:@"DescInfo"];
                    }
                    filename = [self.userVcard stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cfg", rtxId]];
                    
                    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filename];
                    
                }
                result = dic;
                if (!fileExists) {
                    [result writeToFile:filename atomically:YES];
                }
            }
        }
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    return result;
}

#pragma mark - 用户原始尺寸头像

- (NSString *)getUserBigHeaderImageUrlWithUserId:(NSString *)userId {
    NSDictionary *infoDic = [self getUserInfoByUserId:userId];
    if (!infoDic) {
        
        infoDic = [[IMDataManager sharedInstance] selectUserByJID:userId];
    }
    NSString *fileUrl = [infoDic objectForKey:@"HeaderSrc"];
    if (fileUrl.length > 0) {
        return fileUrl;
    }
    return @"";
}

- (void)updateUserBigHeaderImageUrl:(NSString *)url WihtVersion:(NSString *)version ForUserId:(NSString *)userId {
    if (url.length > 0) {
        /*
        NSDictionary *temp = [self.userBigHeaderDic objectForKey:userId];
        if (temp == nil) {
            temp 
         = [NSDictionary dictionary];
        }
        NSMutableDictionary *userBigHeaderDic = [NSMutableDictionary dictionaryWithDictionary:temp];
        NSString *oldVersion = [userBigHeaderDic objectForKey:@"Version"];
        if (![oldVersion isEqualToString:version] && oldVersion.length > 0) {
            NSString *fileName = [userBigHeaderDic objectForKey:@"FileName"];
            if (fileName.length > 0) {
                [[NSFileManager defaultManager] removeItemAtPath:[self.imageCachePath stringByAppendingPathComponent:fileName]
                                                           error:nil];
            }
            [userBigHeaderDic removeObjectForKey:@"FileName"];
            [userBigHeaderDic setObject:version forKey:@"Version"];
            [userBigHeaderDic setObject:url forKey:@"Url"];
            [self.userBigHeaderDic setObject:userBigHeaderDic forKey:userId];
            [[QIMUserCacheManager sharedInstance] setUserObject:self.userBigHeaderDic forKey:kUserBigHeaderDic];
        }
        */
        [[IMDataManager sharedInstance] updateUser:userId WithHeaderSrc:url WithVersion:version];
    }
}

#pragma mark - QChat用户名片

- (NSDictionary *)getQChatUserInfoForUser:(NSString *)user {
    return nil;
    NSArray *coms = [user componentsSeparatedByString:@"@"];
    NSString *userId = [coms firstObject];
    NSString *domain = [coms lastObject];
    if (coms.count == 1) {
        domain = [self getDomain];
    }
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:@{@"domain": domain ? domain : @"", @"users": @[@{@"user": userId ? userId : @"", @"version": @"0"}]}];
    NSMutableData *tempPostData = [NSMutableData dataWithData:[[QIMJSONSerializer sharedInstance] serializeObject:params error:nil]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/domain/get_vcard_info?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]]];
    QIMVerboseLog(@" === 准备获取QChat用户名片 ==== ");
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempPostData];
    QIMVerboseLog(@" === 获取QTChat用户名片请求参数 %@ === ", params);
    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        NSArray *datas = [resDic objectForKey:@"data"];
        NSArray *result = nil;
        if (datas.count) {
            result = [[datas firstObject] objectForKey:@"users"];
        }
        if (errol == nil && result.count > 0) {
            QIMVerboseLog(@"=== 获取QChat用户名片成功, 请求结果 === %@", result);
            
            NSMutableArray *members = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *infoDic in result) {
                
                NSString *dStr = [[infoDic objectForKey:@"imageurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                @autoreleasepool {
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:dStr]];
                    NSString *contentType = @"jpeg";
                    if ([infoDic objectForKey:@"imageurl"]) {
                        
                        NSString *fileName = [[IMDataManager sharedInstance] getUserHeaderSrcByUserId:user];
                        if (fileName.length <= 0) {
                            
                            fileName = [NSString stringWithFormat:@"%@.%@", [infoDic objectForKey:@"username"], contentType];
                        }
                        NSString *headerSrc = [self.imageCachePath stringByAppendingPathComponent:fileName];
                        [imageData writeToFile:headerSrc atomically:YES];
                        [members addObject:@{@"U": [user componentsSeparatedByString:@"@"].firstObject, @"N": [infoDic objectForKey:@"webname"] ? [infoDic objectForKey:@"webname"] : [infoDic objectForKey:@"nickname"], @"V": @"0", @"H": fileName, @"D": [infoDic objectForKey:@"suppliername"] ? [infoDic objectForKey:@"suppliername"] : @""}];
                    }
                }
            }
            [[IMDataManager sharedInstance] InsertOrUpdateUserInfos:members];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (NSDictionary *memberDic in members) {
                    
                    NSString *userId = [[memberDic objectForKey:@"U"] stringByAppendingFormat:@"@%@", [self getDomain]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserCard object:userId];
                }
            });
        }
        return result.count ? result.firstObject : nil;
    }
    return nil;
}

- (void)updateQChatGroupMembersCardForGroupId:(NSString *)groupId {
    NSArray *members = [self getGroupMembersByGroupId:groupId];
    NSMutableArray *needUpdateUserIds = [NSMutableArray array];
    for (NSDictionary *memberDic in members) {
        NSString *xmppJid = [memberDic objectForKey:@"xmppjid"];
        if (xmppJid.length > 0) {
            [needUpdateUserIds addObject:xmppJid];
        }
    }
    // 只更昵称
    [self updateUserCard:needUpdateUserIds];
}

#pragma mark - 分割线-----------

- (void)updateUserCard:(NSArray *)xmppIds {
    if (xmppIds.count <= 0) {
        return ;
    }
    dispatch_async(self.load_customEvent_queue, ^{
        NSDictionary *usersDic = [[IMDataManager sharedInstance] selectUsersDicByXmppIds:xmppIds];
        NSMutableDictionary *xmppIdDic = [NSMutableDictionary dictionary];
        for (NSString *xmppId in xmppIds) {
            NSDictionary *userDic = [usersDic objectForKey:xmppId];
            if (userDic) {
                NSString *xmppId = [userDic objectForKey:@"XmppId"];
                NSArray *coms = [xmppId componentsSeparatedByString:@"@"];
                NSString *userId = [coms firstObject];
                NSString *domain = [coms lastObject];
                if (domain && userId) {
                    NSMutableArray *users = [xmppIdDic objectForKey:domain];
                    if (users == nil) {
                        users = [NSMutableArray array];
                        [xmppIdDic setObject:users forKey:domain];
                    }
                    [users addObject:@{@"user": userId, @"version": [userDic objectForKey:@"LastUpdateTime"]}];
                }
            } else {
                NSArray *coms = [xmppId componentsSeparatedByString:@"@"];
                NSString *userId = [coms firstObject];
                NSString *domain = [coms lastObject];
                if (domain && userId) {
                    NSMutableArray *users = [xmppIdDic objectForKey:domain];
                    if (users == nil) {
                        users = [NSMutableArray array];
                        [xmppIdDic setObject:users forKey:domain];
                    }
                    [users addObject:@{@"user": userId, @"version": @"0"}];
                }
            }
        }
        NSMutableArray *params = [NSMutableArray array];
        for (NSString *domain in xmppIdDic.allKeys) {
            NSArray *users = [xmppIdDic objectForKey:domain];
            [params addObject:@{@"domain": domain, @"users": users}];
        }
        
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSString *destUrl = [NSString stringWithFormat:@"%@/domain/get_vcard_info?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        QIMVerboseLog(@"更新用户名片: %@", destUrl);
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        QIMVerboseLog(@"更新用户名片参数 : %@", [[QIMJSONSerializer sharedInstance] serializeObject:params]);
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [request setHTTPRequestHeaders:@{@"Content-type":@"application/json;"}];
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            QIMVerboseLog(@"用户名片结果 : %@", response);
            if (response.code == 200) {
                NSData *responseData = response.data;
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSMutableArray *dataList = [NSMutableArray array];
                    NSArray *list = [result objectForKey:@"data"];
                    for (NSDictionary *dataDic in list) {
                        NSString *domain = [dataDic objectForKey:@"domain"];
                        NSArray *userList = [dataDic objectForKey:@"users"];
                        for (NSDictionary *userDic in userList) {
                            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                            NSString *type = [userDic objectForKey:@"type"];
                            NSString *userId = [userDic objectForKey:@"username"];
                            NSString *xmppId = [userId stringByAppendingFormat:@"@%@", domain];
                            NSString *webName = [userDic objectForKey:@"webname"];
                            NSString *nickName = [userDic objectForKey:@"nickname"];
                            NSString *name = webName ? webName : nickName;
                            NSString *headUrl = [userDic objectForKey:@"imageurl"];
                            NSString *version = [userDic objectForKey:@"V"];
                            [dataDic setQIMSafeObject:userId forKey:@"U"];
                            [dataDic setQIMSafeObject:xmppId forKey:@"X"];
                            [dataDic setQIMSafeObject:name forKey:@"N"];
                            [dataDic setQIMSafeObject:headUrl forKey:@"H"];
                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userDic];
                            [dataDic setQIMSafeObject:data forKey:@"I"];
                            [dataDic setQIMSafeObject:version ? version : @"0" forKey:@"V"];
                            [dataDic setQIMSafeObject:type forKey:@"type"];
                            [dataList addObject:dataDic];
                        }
                    }
                    if (dataList.count > 0) {
                        dispatch_block_t block = ^{
                            for (NSString *userId in xmppIds) {
                                [self.userVCardDict removeObjectForKey:userId];
                            }
                        };
                        
                        if (dispatch_get_specific(self.cacheTag))
                            block();
                        else
                            dispatch_sync(self.cacheQueue, block);
                        
                        [[IMDataManager sharedInstance] bulkUpdateUserCardsV2:dataList];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kUserVCardUpdate object:xmppIds];
                        });
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

- (void)updateMyCard {
    
    [self updateUserCard:@[[self getLastJid]]];
    NSString *headerSrc = [[QIMManager sharedInstance] getUserBigHeaderImageUrlWithUserId:[self getLastJid]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateSuccess object:@{@"ok":@(YES), @"headerUrl":(headerSrc.length > 0) ? headerSrc : @""}];
    });
}

- (void)updateMyPhoto:(NSData *)photoData {
    NSString *myPhotoUrl = [QIMHttpApi updateMyPhoto:photoData];
    if (myPhotoUrl.length > 0) {
        NSDictionary *cardDic = @{@"user": [QIMManager getLastUserName], @"url": myPhotoUrl, @"domain":[[XmppImManager sharedInstance] domain]};
        NSString *destUrl = [NSString stringWithFormat:@"%@/setvcardinfo?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@[cardDic] error:nil];
        
        NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
        [requestHeader setObject:@"application/json" forKey:@"content-type"];
        
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [request setHTTPBody:data];
        [request setHTTPRequestHeaders:requestHeader];
        __weak __typeof(self) weakSelf = self;
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                NSString *myHeaderExtension = [[QIMFileManager sharedInstance] getFileExtFromUrl:myPhotoUrl];
                NSString *smallHeaderSrc = [strongSelf.imageCachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_90.%@", [[QIMManager sharedInstance] getLastJid], myHeaderExtension]];
                [strongSelf.userNormalHeaderDic removeObjectForKey:[[QIMManager sharedInstance] getLastJid]];
                BOOL writeToSmallLocalSuccess = [photoData writeToFile:smallHeaderSrc atomically:YES];
                if (writeToSmallLocalSuccess) {
                    QIMVerboseLog(@"写入我的小头像成功");
                } else {
                    QIMVerboseLog(@"写入我的小头像失败");
                }
                QIMVerboseLog(@"result : %@", result);
                
                NSArray *resultData = [result objectForKey:@"data"];
                if ([resultData isKindOfClass:[NSArray class]]) {
                    NSDictionary *resultDic = [resultData firstObject];
                    [strongSelf updateUserBigHeaderImageUrl:myPhotoUrl WihtVersion:[resultDic objectForKey:@"version"] ForUserId:[QIMManager getLastUserName]];
                    NSString *headerUrl = myPhotoUrl;
                    if (![myPhotoUrl qim_hasPrefixHttpHeader]) {
                        headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMNavConfigManager sharedInstance] innerFileHttpHost], myPhotoUrl];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateSuccess object:@{@"ok":@(YES), @"headerUrl":(headerUrl.length > 0) ? headerUrl : @""}];
                    });
                }
            }
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateFaild object:nil];
            });
        }];
    }
}

#pragma mark - 工作信息Work ----

/**
 + 根据用户Id获取WorkInfo
 + */
- (NSDictionary *)getUserWorkInfoByUserId:(NSString *)userId {
    __block NSDictionary *result = nil;
    dispatch_block_t block = ^{
        NSDictionary *tempDic = [[IMDataManager sharedInstance] selectUserBackInfoByXmppId:userId];
        if (tempDic) {
            NSString *userWorkInfoStr = [tempDic objectForKey:@"UserWorkInfo"];
            result = [[QIMJSONSerializer sharedInstance] deserializeObject:userWorkInfoStr error:nil];
        } else {
            result = [[QIMManager sharedInstance] getRemoteUserWorkInfoWithUserId:userId];
        }
    };
    if (dispatch_get_specific(self.cacheTag)) {
        block();
    } else {
        dispatch_sync(self.cacheQueue, block);
    }
    return result;
}

- (NSDictionary *)getRemoteUserWorkInfoWithUserId:(NSString *)userId {
    NSDictionary *userWorkInfo = nil;
    
    NSString *qtalkId = [[userId componentsSeparatedByString:@"@"] firstObject];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    [param setQIMSafeObject:qtalkId forKey:@"qtalk_id"];
    [param setQIMSafeObject:[QIMManager getLastUserName] forKey:@"user_id"];
    [param setQIMSafeObject:[[QIMManager sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
    [param setQIMSafeObject:@"ios" forKey:@"platform"];
    QIMVerboseLog(@"查看用户%@直属领导参数 : %@", userId, [[QIMJSONSerializer sharedInstance] serializeObject:param]);
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:param error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/ops/opsapp/api/info", [[QIMNavConfigManager sharedInstance] opsHost]];
    QIMVerboseLog(@"查看用户%@直属领导url ： %@", userId, destUrl);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request addRequestHeader:@"Content-type" value:@"application/json;"];
    [request setRequestMethod:@"POST"];
    
    [request setPostBody:[NSMutableData dataWithData:requestData]];
    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error && [request responseStatusCode] == 200) {
        NSData *data = [request responseData];
        NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
        BOOL errcode = [[dic objectForKey:@"errcode"] integerValue];
        if (errcode == 0) {
            NSDictionary *data = [dic objectForKey:@"data"];
            QIMVerboseLog(@"查看用户%@直属领导结果 ： %@", userId, dic);
            if (data.count) {
                //插入数据库IM_User_BackInfo
                NSString *workInfo = [[QIMJSONSerializer sharedInstance] serializeObject:data];
                NSDictionary *userBackInfo = @{@"UserWorkInfo":workInfo?workInfo:@""};
                [[IMDataManager sharedInstance] bulkUpdateUserBackInfo:userBackInfo WithXmppId:userId];
                
                userWorkInfo = [NSDictionary dictionaryWithDictionary:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserLeaderCard object:@{@"UserId":userId, @"userLead":workInfo}];
                });
            }
        }
    } else {
        QIMVerboseLog(@"查看用户%@直属领导 失败 ： %ld, Error : %@", userId, [request responseStatusCode], error);
    }
    return userWorkInfo;
}

- (NSString *)getPhoneNumberWithUserId:(NSString *)qtalkId {
    __block NSString *phoneNumber = nil;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    [param setQIMSafeObject:qtalkId forKey:@"qtalk_id"];
    [param setQIMSafeObject:[QIMManager getLastUserName] forKey:@"user_id"];
    [param setQIMSafeObject:[[QIMManager sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
    [param setQIMSafeObject:@"ios" forKey:@"platform"];
    QIMVerboseLog(@"查看用户%@手机号参数 : %@", qtalkId, [[QIMJSONSerializer sharedInstance] serializeObject:param]);
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:param error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/ops/opsapp/api/mobile-phone", [[QIMNavConfigManager sharedInstance] opsHost]];
    QIMVerboseLog(@"查看用户%@手机号Url : %@", qtalkId, destUrl);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request addRequestHeader:@"Content-type" value:@"application/json;"];
    [request setRequestMethod:@"POST"];
    
    [request setPostBody:[NSMutableData dataWithData:requestData]];
    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error && [request responseStatusCode] == 200) {
        NSData *data = [request responseData];
        NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
        QIMVerboseLog(@"查看用户%@手机号结果 : %@", qtalkId, dic);
        BOOL errcode = [[dic objectForKey:@"errcode"] integerValue];
        if (errcode == 0) {
            NSDictionary *data = [dic objectForKey:@"data"];
            phoneNumber = [data objectForKey:@"phone"];
        }
    } else {
        QIMVerboseLog(@"查看用户%@手机号失败 ： %ld, Error : %@", qtalkId, [request responseStatusCode], error);
    }
    return phoneNumber;
}

#pragma mark - 跨域搜索

- (NSArray *)searchQunarUserBySearchStr:(NSString *)searchStr {
    if (searchStr.length > 0) {
        NSString *destUrl = [NSString stringWithFormat:@"%@/domain/search_vcard?keyword=%@&server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@", searchStr, [[QIMNavConfigManager sharedInstance] httpHost], [[XmppImManager sharedInstance] domain], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request startSynchronous];
        
        NSError *error = [request error];
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSArray *msgList = [result objectForKey:@"data"];
                return msgList;
            }
        }
    }
    return nil;
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr {
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        
        array = [[IMDataManager sharedInstance] selectUserListBySearchStr:searchStr];
        for (NSMutableDictionary *userDic in array) {
            NSString *rtxId = [userDic objectForKey:@"UserId"];
            NSString *desc = [self.friendDescDic objectForKey:rtxId];
            if (desc) {
                [userDic setObject:desc forKey:@"DescInfo"];
            }
        }
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return array;
}

- (NSInteger)searchUserListTotalCountBySearchStr:(NSString *)searchStr {
    __block NSInteger totalCount = 0;
    dispatch_block_t block = ^{
        totalCount = [[IMDataManager sharedInstance] selectUserListTotalCountBySearchStr:searchStr];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return totalCount;
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        
        array = [[IMDataManager sharedInstance] selectUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return array;
}

//好友页面搜索
- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr Url:(NSString *)searchURL id:(NSString *)Id limit:(NSInteger)limitNum offset:(NSInteger)offset {
    
    if (searchStr.length > 0) {
        
        long long time = ([[NSDate date] timeIntervalSince1970]) * 1000;
        
        NSString *k2 = [NSString stringWithFormat:@"%@%lld",[[QIMManager sharedInstance] remoteKey],time];
        
        NSString *newString = [NSString stringWithFormat:@"u=%@&k=%@&t=%lld", [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [k2 qim_getMD5], time];
        NSString *destUrl = [searchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        
        NSNumber *limitNumber = [NSNumber numberWithInteger:limitNum];
        NSNumber *offsetNumber = [NSNumber numberWithInteger:offset];
        NSString *ckey = [[newString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSDictionary *paramDic = @{@"ckey": ckey, @"id": Id, @"key": searchStr, @"limit": limitNumber, @"offset": offsetNumber};
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:paramDic error:nil];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request appendPostData:requestData];
        [request setRequestMethod:@"POST"];
        [request startSynchronous];
        NSError *error = [request error];
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"errcode"] boolValue];
            if (!ret) {
                
                NSMutableArray *userList = [NSMutableArray arrayWithCapacity:20];
                NSArray *users = [result objectForKey:@"data"][@"users"];
                for (NSDictionary *user in users) {
                    
                    NSString *icon = user[@"icon"];
                    NSString *label = user[@"label"];
                    NSString *content = user[@"content"];
                    NSString *uri = user[@"uri"];
                    if (icon && label && content && uri) {
                        
                        NSDictionary *userDict = @{@"icon": icon, @"Name": label, @"DescInfo": content, @"XmppId": uri};
                        if (userDict) {
                            
                            [userList addObject:userDict];
                        }
                    }
                }
                return userList;
            }
        }
    }
    return nil;
}

@end
