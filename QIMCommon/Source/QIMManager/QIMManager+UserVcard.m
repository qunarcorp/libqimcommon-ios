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
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeStartalk) {
            NSString *singleHeaderPath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMSTdefaultHeader" ofType:@"png"];
            __defaultUserHeaderImage = [NSData dataWithContentsOfFile:singleHeaderPath];
        } else {
            NSString *singleHeaderPath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMManDefaultHeader" ofType:@"png"];
            __defaultUserHeaderImage = [NSData dataWithContentsOfFile:singleHeaderPath];
        }
    });
    return __defaultUserHeaderImage;
}

+ (NSString *)defaultUserHeaderImagePath {
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeStartalk) {
        return [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMSTdefaultHeader" ofType:@"png"];
    } else {
        return [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"QIMManDefaultHeader" ofType:@"png"];
    }
}

#pragma mark - 用户备注

- (void)updateUserMarkupNameWithUserId:(NSString *)userId WithMarkupName:(NSString *)markUpName {
    [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKMarkupNames WithSubKey:userId WithConfigValue:markUpName WithDel:(markUpName.length > 0) ? NO : YES withCallback:nil];
}

- (NSString *)getUserMarkupNameWithUserId:(NSString *)userId {
    if (userId.length <= 0) {
        return nil;
    }
    __block NSString *result = nil;
    
    __weak __typeof(self) weakSelf = self;
    
    dispatch_block_t block = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!strongSelf.userMarkupNameDic.count) {
            NSDictionary *userMarkNameDics = [[IMDataManager qimDB_SharedInstance] qimDB_getUserMarkNameDic];
            strongSelf.userMarkupNameDic = [NSMutableDictionary dictionaryWithDictionary:userMarkNameDics];
        }
        NSMutableDictionary *tempUserMarkupNameDic = [NSMutableDictionary dictionaryWithDictionary:strongSelf.userMarkupNameDic];
        NSString *tempMarkupName = [tempUserMarkupNameDic objectForKey:userId];
        if (!tempMarkupName.length) {
            tempMarkupName = [[strongSelf getUserInfoByUserId:userId] objectForKey:@"Name"];
        }
        
        if (tempMarkupName.length > 0) {
            result = tempMarkupName;
        } else {
            result = [[userId componentsSeparatedByString:@"@"] firstObject];
        }
        [strongSelf.userMarkupNameDic setQIMSafeObject:result forKey:userId];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    return result;
}

#pragma 更新用户签名
- (void)updateUserSignature:(NSString *)signature withCallBack:(QIMKitUpdateSignatureBlock)callback {
    
    //{"user":"xuejie.bi","mood":"134", "domain":"ejabhost1"}
    NSMutableDictionary *usersVCardInfo = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:kUsersVCardInfo]];
    
    NSMutableDictionary *userParam = [NSMutableDictionary dictionaryWithCapacity:1];
    [userParam setQIMSafeObject:[QIMManager getLastUserName] forKey:@"user"];
    [userParam setQIMSafeObject:(signature.length > 0) ? signature : @"" forKey:@"mood"];
    [userParam setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"domain"];
    __weak __typeof(self) weakSelf = self;
    
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:@[userParam] error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/profile/set_profile.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[resultDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSArray *resultData = [resultDic objectForKey:@"data"];
            [strongSelf dealWithUpdateUserProfile:resultData];
            if (callback) {
                callback(YES);
            }
        } else {
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

- (void)dealWithUpdateUserProfile:(NSDictionary *)userProfileArray {
    if ([userProfileArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *userProfile in userProfileArray) {
            NSString *userId = [userProfile objectForKey:@"user"];
            NSString *domain = [userProfile objectForKey:@"domain"];
            NSString *version = [userProfile objectForKey:@"version"];
            NSString *mood = [userProfile objectForKey:@"mood"];
            NSString *headerUrl = [userProfile objectForKey:@"url"];
            
            NSString *userXmppId = [NSString stringWithFormat:@"%@@%@", userId, domain];
            [self updateUserBigHeaderImageUrl:headerUrl WithUserMood:mood WithVersion:version ForUserId:userXmppId];
            [self.userVCardDict removeObjectForKey:userXmppId];
            NSMutableDictionary *usersVCardInfo = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:kUsersVCardInfo]];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:usersVCardInfo[[QIMManager getLastUserName]]];
            if (userInfo.count <= 0) {
                
                userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
                [userInfo setQIMSafeObject:[QIMManager getLastUserName] forKey:@"U"];
                [userInfo setQIMSafeObject:@"0" forKey:@"V"];
            }
            [userInfo setQIMSafeObject:mood ? mood : @"" forKey:@"M"];
            
            if (version > [userInfo[@"V"] intValue]) {
                
                [userInfo setQIMSafeObject:version forKey:@"V"];
            }
            [usersVCardInfo setQIMSafeObject:userInfo forKey:[[QIMManager sharedInstance] getLastJid]];
            [[QIMUserCacheManager sharedInstance] setUserObject:usersVCardInfo forKey:kUsersVCardInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateMyPersonalSignature object:mood ? mood : @""];
            });
        }
    }
}

#pragma mark - 用户名片

- (NSDictionary *)getUserInfoByUserId:(NSString *)myId {
    if (myId.length <= 0) {
        return nil;
    }
    __block NSDictionary *result = nil;
    __weak __typeof(self) weakSelf = self;

    dispatch_block_t block = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!strongSelf.userVCardDict) {
            strongSelf.userVCardDict = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        NSDictionary *tempDic = [strongSelf.userVCardDict objectForKey:myId];
        if (!tempDic) {
            tempDic = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByJID:myId];
        }
        result = tempDic;
        [strongSelf.userVCardDict setQIMSafeObject:tempDic forKey:myId];
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
        
        infoDic = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByJID:userId];
    }
    NSString *fileUrl = [infoDic objectForKey:@"HeaderSrc"];
    if (fileUrl.length > 0) {
        return fileUrl;
    }
    return @"";
}

- (void)updateUserBigHeaderImageUrl:(NSString *)url WithUserMood:(NSString *)mood WithVersion:(NSString *)version ForUserId:(NSString *)userId {
    if (userId.length > 0 && url.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateUser:userId WithMood:mood WithHeaderSrc:url WithVersion:version];
    }
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

static NSMutableArray *cacheUserCardHttpList = nil;
- (void)updateUserCard:(NSString *)xmppId withCache:(BOOL)cache {
    dispatch_block_t block = ^{
        if (YES == cache) {
            if (!cacheUserCardHttpList) {
                cacheUserCardHttpList = [NSMutableArray arrayWithCapacity:3];
            }
            if ([cacheUserCardHttpList containsObject:xmppId]) {
                return;
            } else {
                [cacheUserCardHttpList addObject:xmppId];
                [self updateUserCard:@[xmppId]];
            }
        } else {
            [self updateUserCard:@[xmppId]];
        }
    };
    if (dispatch_get_specific(self.cacheTag)) {
        block();
    } else {
        dispatch_sync(self.cacheQueue, block);
    }
}

- (void)updateUserCard:(NSArray *)xmppIds {
    if (xmppIds.count <= 0) {
        return ;
    }
    dispatch_async(self.update_chat_card, ^{
        NSDictionary *usersDic = [[IMDataManager qimDB_SharedInstance] qimDB_selectUsersDicByXmppIds:xmppIds];
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
        NSString *destUrl = [NSString stringWithFormat:@"%@/domain/get_vcard_info.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
        QIMVerboseLog(@"更新用户名片: %@", destUrl);
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        QIMVerboseLog(@"更新用户名片参数 : %@", [[QIMJSONSerializer sharedInstance] serializeObject:params]);
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [request setHTTPRequestHeaders:cookieProperties];
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
        NSString * myUserID = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kLastUserId] lowercaseString];
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
                            NSString *mood = [userDic objectForKey:@"mood"];
                            NSNumber * isToCManager = [userDic objectForKey:@"adminFlag"];
                            if ([myUserID isEqualToString:userId]) {
                                if (isToCManager!=nil) {
                                     [[QIMUserCacheManager sharedInstance] setUserObject:isToCManager forKey:@"isToCManager"];
                                }
                            }
                            [dataDic setQIMSafeObject:userId forKey:@"U"];
                            [dataDic setQIMSafeObject:xmppId forKey:@"X"];
                            [dataDic setQIMSafeObject:name forKey:@"N"];
                            [dataDic setQIMSafeObject:headUrl forKey:@"H"];
                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userDic];
                            [dataDic setQIMSafeObject:data forKey:@"I"];
                            [dataDic setQIMSafeObject:version ? version : @"0" forKey:@"V"];
                            [dataDic setQIMSafeObject:type forKey:@"type"];
                            if ([xmppId isEqualToString:[[QIMManager sharedInstance] getLastJid]]) {
                                if ([type isEqualToString:@"merchant"]) {
                                    [[QIMManager sharedInstance] setIsMerchant:YES];
                                } else {
                                    [[QIMManager sharedInstance] setIsMerchant:NO];
                                }
                            }
                            [dataDic setQIMSafeObject:mood forKey:@"mood"];
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
                        
                        [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateUserCards:dataList];
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
    [[QIMFileManager sharedInstance] qim_uploadMyPhotoData:photoData withCallBack:^(NSString *myPhotoUrl) {
        if (myPhotoUrl.length > 0) {
            NSDictionary *cardDic = @{@"user": [QIMManager getLastUserName], @"url": myPhotoUrl, @"domain":[[XmppImManager sharedInstance] domain]};
            NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@[cardDic] error:nil];
            NSString *destUrl = [NSString stringWithFormat:@"%@/profile/set_profile.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
            [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
                NSInteger errcode = [[resultDic objectForKey:@"errcode"] integerValue];
                if (ret && errcode == 0) {
                    NSArray *resultData = [resultDic objectForKey:@"data"];
                    if ([resultData isKindOfClass:[NSArray class]]) {
                        [self dealWithUpdateMyVCard:resultData];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateFaild object:nil];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateFaild object:nil];
                    });
                }
            } withFailedCallBack:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateFaild object:nil];
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateFaild object:nil];
            });
        }
    }];    
}

- (void)dealWithUpdateMyVCard:(NSArray *)resultData {
    if ([resultData isKindOfClass:[NSArray class]]) {
        NSDictionary *resultDic = [resultData firstObject];
        [self.userNormalHeaderDic removeObjectForKey:[[QIMManager sharedInstance] getLastJid]];
        [self.userVCardDict removeObjectForKey:[[QIMManager sharedInstance] getLastJid]];
        NSString *headerUrl = [resultDic objectForKey:@"url"];
        NSString *mood = [resultDic objectForKey:@"mood"];
        if (![headerUrl qim_hasPrefixHttpHeader]) {
            headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMNavConfigManager sharedInstance] innerFileHttpHost], headerUrl];
        }
        [self updateUserBigHeaderImageUrl:headerUrl WithUserMood:mood WithVersion:[resultDic objectForKey:@"version"] ForUserId:[[QIMManager sharedInstance] getLastJid]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kMyHeaderImgaeUpdateSuccess object:@{@"ok":@(YES), @"headerUrl":(headerUrl.length > 0) ? headerUrl : @""}];
        });
    }
}

#pragma mark - 工作信息Work ----

/**
 + 根据用户Id获取WorkInfo
 + */
- (NSDictionary *)getUserWorkInfoByUserId:(NSString *)userId {
    __block NSDictionary *result = nil;
    dispatch_block_t block = ^{
        NSDictionary *tempDic = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserBackInfoByXmppId:userId];
        if (tempDic) {
            NSString *userWorkInfoStr = [tempDic objectForKey:@"UserWorkInfo"];
            result = [[QIMJSONSerializer sharedInstance] deserializeObject:userWorkInfoStr error:nil];
        } else {
            [[QIMManager sharedInstance] getRemoteUserWorkInfoWithUserId:userId withCallBack:^(NSDictionary *userWorkInfo) {
                result = userWorkInfo;
            }];
        }
    };
    if (dispatch_get_specific(self.cacheTag)) {
        block();
    } else {
        dispatch_sync(self.cacheQueue, block);
    }
    return result;
}

- (void)getRemoteUserWorkInfoWithUserId:(NSString *)userId withCallBack:(QIMKitGetUserWorkInfoBlock)callback {
    
    NSString *qtalkId = [[userId componentsSeparatedByString:@"@"] firstObject];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    [param setQIMSafeObject:qtalkId forKey:@"qtalk_id"];
    [param setQIMSafeObject:[QIMManager getLastUserName] forKey:@"user_id"];
    [param setQIMSafeObject:[[QIMManager sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
    [param setQIMSafeObject:@"ios" forKey:@"platform"];
    QIMVerboseLog(@"查看用户%@直属领导参数 : %@", userId, [[QIMJSONSerializer sharedInstance] serializeObject:param]);
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:param error:nil];
    NSString *destUrl = [[QIMNavConfigManager sharedInstance] leaderurl];
    __weak __typeof(self) weakSelf = self;
    QIMVerboseLog(@"查看用户%@直属领导url ： %@", userId, destUrl);
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSInteger errcode = [[resultDic objectForKey:@"errcode"] integerValue];
        if (errcode == 0) {
            NSDictionary *resultData = [resultDic objectForKey:@"data"];
            if ([resultData isKindOfClass:[NSDictionary class]]) {
                //插入数据库IM_UsersWorkInfo
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(resultData);
                    }
                });
                NSString *workInfo = [[QIMJSONSerializer sharedInstance] serializeObject:resultData];
                NSDictionary *userBackInfo = @{@"UserWorkInfo":workInfo?workInfo:@""};
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateUserBackInfo:userBackInfo WithXmppId:userId];
                
                NSString *userWorkInfo = [NSDictionary dictionaryWithDictionary:resultData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserLeaderCard object:@{@"UserId":userId, @"LeaderInfo":workInfo}];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(nil);
                }
            });
        }
    } withFailedCallBack:^(NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)getPhoneNumberWithUserId:(NSString *)qtalkId withCallBack:(QIMKitGetPhoneNumberBlock)callback{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    [param setQIMSafeObject:qtalkId forKey:@"qtalk_id"];
    [param setQIMSafeObject:[QIMManager getLastUserName] forKey:@"user_id"];
    [param setQIMSafeObject:[[QIMManager sharedInstance] thirdpartKeywithValue] forKey:@"ckey"];
    [param setQIMSafeObject:@"ios" forKey:@"platform"];
    QIMVerboseLog(@"查看用户%@手机号参数 : %@", qtalkId, [[QIMJSONSerializer sharedInstance] serializeObject:param]);
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:param error:nil];
    NSString *destUrl = [[QIMNavConfigManager sharedInstance] mobileurl];
    QIMVerboseLog(@"查看用户%@手机号Url : %@", qtalkId, destUrl);
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSInteger errcode = [[resultDic objectForKey:@"errcode"] integerValue];
        if (errcode == 0) {
            NSDictionary *resultData = [resultDic objectForKey:@"data"];
            if ([resultData isKindOfClass:[NSDictionary class]]) {
                NSString *phoneNumber = [resultData objectForKey:@"phone"];
                if (callback) {
                    callback(phoneNumber);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        } else {
            if (callback) {
                callback(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

#pragma mark - 跨域搜索

- (void)searchQunarUserBySearchStr:(NSString *)searchStr withCallback:(QIMKitSearchQunarUserBlock)callback {
    if (searchStr.length > 0) {
        NSString *destUrl = [NSString stringWithFormat:@"%@/domain/search_vcard?keyword=%@&server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@", searchStr, [[QIMNavConfigManager sharedInstance] httpHost], [self getDomain], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSArray *msgList = [result objectForKey:@"data"];
                if (callback) {
                    callback(msgList);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        } withFailedCallBack:^(NSError *error) {
            if (callback) {
                callback(nil);
            }
        }];
    }
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr {
    __block NSArray *array = nil;
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        array = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListBySearchStr:searchStr];
        for (NSMutableDictionary *userDic in array) {
            NSString *rtxId = [userDic objectForKey:@"UserId"];
            NSString *desc = [strongSelf.friendDescDic objectForKey:rtxId];
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
        totalCount = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListTotalCountBySearchStr:searchStr];
    };
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return totalCount;
}

- (NSArray *)selectUserListExMySelfBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        
        array = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListExMySelfBySearchStr:searchStr WithLimit:limit WithOffset:offset];
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return array;
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        
        array = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    return array;
}

//好友页面搜索
- (void)searchUserListBySearchStr:(NSString *)searchStr Url:(NSString *)searchURL id:(NSString *)Id limit:(NSInteger)limitNum offset:(NSInteger)offset withCallBack:(QIMKitSearchUserListCallBack)callback {
    
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
        [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
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
                if (callback) {
                    callback(userList);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        } withFailedCallBack:^(NSError *error) {
            if (callback) {
                callback(nil);
            }
        }];
    }
}

@end
