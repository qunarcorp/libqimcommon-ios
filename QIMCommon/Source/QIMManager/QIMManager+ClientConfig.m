//
//  QIMManager+ClientConfig.m
//  QIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMManager+ClientConfig.h"

@implementation QIMManager (ClientConfig)

- (NSString *)transformClientConfigKeyWithType:(QIMClientConfigType)type {

    switch (type) {
        case QIMClientConfigTypeKMarkupNames:
            return @"kMarkupNames";
            break;
        case QIMClientConfigTypeKCollectionCacheKey:
            return @"kCollectionCacheKey";
            break;
        case QIMClientConfigTypeKStickJidDic:
            return @"kStickJidDic";
            break;
        case QIMClientConfigTypeKNotificationSetting:
            return @"kNotificationSetting";
            break;
        case QIMClientConfigTypeKConversationParamDic:
            return @"kConversationParamDic";
            break;
        case QIMClientConfigTypeKQuickResponse:
            return @"kQuickResponse";
            break;
        case QIMClientConfigTypeKChatColorInfo:
            return @"kChatColorInfo";
            break;
        case QIMClientConfigTypeKCurrentFontInfo:
            return @"kCurrentFontInfo";
            break;
        case QIMClientConfigTypeKNoticeStickJidDic:
            return @"kNoticeStickJidDic";
            break;
        case QIMClientConfigTypeKLocalMucRemarkUpdateTime:
            return @"kLocalMucRemarkUpdateTime";
            break;
        case QIMClientConfigTypeKLocalIncrementUpdateTime:
            return @"kLocalIncrementUpdateTime";
            break;
        case QIMClientConfigTypeKLocalTripUpdateTime:
            return @"kLocalTripUpdateTime";
            break;
        case QIMClientConfigTypeKStarContact:
            return @"kStarContact";
            break;
        case QIMClientConfigTypeKBlackList:
            return @"kBlackList";
            break;
        case QIMClientConfigTypeKNotificationSound:
            return @"kNotificationSound";
            break;
        default:
            return @"ALL";
            break;
    }
}

- (void)postUpdateNSNotificationWithType:(QIMClientConfigType)type {
    switch (type) {
        case QIMClientConfigTypeKCollectionCacheKey: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyResetFaceCollectionManager object:[[QIMManager sharedInstance] getClientConfigValueArrayWithType:QIMClientConfigTypeKCollectionCacheKey]];
            });
        }
            break;
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        }
            break;
    }
}

- (void)postUpdateNSNotificationWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey WithConfigValue:(NSString *)configValue {
    switch (type) {
        case QIMClientConfigTypeKMarkupNames: {
            // 通知有问题
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMarkNameUpdate object:@{@"jid":subKey,@"nickName":configValue}];
            });
        }
            break;
        case QIMClientConfigTypeKCollectionCacheKey: {
            
        }
            break;
        case QIMClientConfigTypeKStickJidDic: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        }
            break;
        case QIMClientConfigTypeKNoticeStickJidDic: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kGroupMsgRemindDic object:subKey];
            });
        }
        default:
            break;
    }
}

- (NSInteger)getClientConfigDeleteFlagWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigDeleteFlagWithConfigKey:[self transformClientConfigKeyWithType:type] WithSubKey:subKey];
}

/**
 返回配置Value
 */
- (NSString *)getClientConfigInfoWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey {
    return [self getClientConfigInfoWithType:type WithSubKey:subKey WithDeleteFlag:NO];
}

- (NSString *)getClientConfigInfoWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey WithDeleteFlag:(BOOL)deleteFlag {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:type] WithSubKey:subKey WithDeleteFlag:deleteFlag];
}

/**
 返回字典
 */
- (NSDictionary *)getClientConfigDicWithType:(QIMClientConfigType)type {
    return [self getClientConfigDicWithType:type WithDeleteFlag:NO];
}

- (NSDictionary *)getClientConfigDicWithType:(QIMClientConfigType)type WithDeleteFlag:(BOOL)deleteFlag {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigDicWithConfigKey:[self transformClientConfigKeyWithType:type] WithDeleteFlag:deleteFlag];
}

/**
 返回配置详情数组
 */
- (NSArray *)getClientConfigInfoArrayWithType:(QIMClientConfigType)type {
    return [self getClientConfigInfoArrayWithType:type WithDeleteFlag:NO];
}

- (NSArray *)getClientConfigInfoArrayWithType:(QIMClientConfigType *)type WithDeleteFlag:(BOOL)deleteFlag {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigInfoArrayWithConfigKey:[self transformClientConfigKeyWithType:type] WithDeleteFlag:deleteFlag];
}


/**
 返回配置Value数组
 */
- (NSArray *)getClientConfigValueArrayWithType:(QIMClientConfigType)type {
    return [self getClientConfigValueArrayWithType:type WithDeleteFlag:NO];
}

- (NSArray *)getClientConfigValueArrayWithType:(QIMClientConfigType)type WithDeleteFlag:(BOOL)deleteFlag {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigValueArrayWithConfigKey:[self transformClientConfigKeyWithType:type] WithDeleteFlag:deleteFlag];
}

- (void)insertNewClientConfigInfoWithData:(NSDictionary *)result {
    NSDictionary *data = [[result objectForKey:@"data"] objectForKey:@"clientConfigInfos"];
    NSInteger version = [[[result objectForKey:@"data"] objectForKey:@"version"] integerValue];
#warning 循环中尽可能避免操作db，汇总之后批量插入
    
    for (NSDictionary *configInfo in data) {
        NSArray *configInfoData = [configInfo objectForKey:@"infos"];
        NSString *key = [configInfo objectForKey:@"key"];
        [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertConfigArrayWithConfigKey:key WithConfigVersion:version ConfigArray:configInfoData];
        if ([key isEqualToString:@"kStickJidDic"]) {
            self.stickJidDic = nil;
            for (NSDictionary *stickInfo in configInfoData) {
                NSString *subkey = [stickInfo objectForKey:@"subkey"];
                NSString *chatId = [[subkey componentsSeparatedByString:@"<>"] firstObject];
                NSString *stickValue = [stickInfo objectForKey:@"configinfo"];
                NSDictionary *stickValueDic = [[QIMJSONSerializer sharedInstance] deserializeObject:stickValue error:nil];
                ChatType chatType = (ChatType)[[stickValueDic objectForKey:@"chatType"] unsignedIntegerValue];
                NSInteger isDel = [[stickInfo objectForKey:@"isdel"] integerValue];
                if (isDel == NO) {
                    [self addSessionByType:chatType ById:chatId ByMsgId:nil WithMsgTime:0 WithNeedUpdate:YES];
                }
            }
        } else if ([key isEqualToString:@"kNoticeStickJidDic"]) {
            if (!self.notMindGroupDic) {
                self.notMindGroupDic = [NSMutableDictionary dictionaryWithCapacity:3];
            }
            for (NSDictionary *noticeStickInfo in configInfoData) {
                NSString *subkey = [noticeStickInfo objectForKey:@"subkey"];
                [self.notMindGroupDic removeObjectForKey:subkey];
            }
            self.notMindGroupDic = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindStateChange object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kRemindStateChange object:@"ForceRefresh"];
            });
        } else if ([key isEqualToString:@"kMarkupNames"]) {
            for (NSDictionary *markupInfo in configInfoData) {
                NSString *subkey = [markupInfo objectForKey:@"subkey"];
                [self.userMarkupNameDic removeObjectForKey:subkey];
            }
            self.userMarkupNameDic = nil;
        } else if ([key isEqualToString:@"kChatColorInfo"]) {
            NSDictionary *newColorInfoDic = [configInfoData firstObject];
            NSString *configInfo = [newColorInfoDic objectForKey:@"configinfo"];
            NSDictionary *colorConfigInfoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:configInfo error:nil];
            [[QIMUserCacheManager sharedInstance] setUserObject:colorConfigInfoDic forKey:kChatColorInfo];
        } else if ([key isEqualToString:@"kCurrentFontInfo"]) {
            NSDictionary *newFontInfoDic = [configInfoData firstObject];
            NSString *configInfo = [newFontInfoDic objectForKey:@"configinfo"];
            NSDictionary *fontConfigInfoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:configInfo error:nil];
            [[QIMUserCacheManager sharedInstance] setUserObject:fontConfigInfoDic forKey:kCurrentFontInfo];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCurrentFontUpdate object:nil];
            });
        } else if ([key isEqualToString:@"kNotificationSound"]) {
            for (NSDictionary *markupInfo in configInfoData) {
                NSString *subkey = [markupInfo objectForKey:@"subkey"];
                if ([subkey isEqualToString:@"ios"]) {
                    self.soundName = [[QIMManager sharedInstance] getClientNotificationSoundName];
                }
            }
        } else {

        }
    }
}

- (void)updateRemoteClientConfigWithType:(QIMClientConfigType)type BatchProcessConfigInfo:(NSArray *)configInfoArray WithDel:(BOOL)delFlag withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/configuration/setclientconfig.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setQIMSafeObject:[QIMManager getLastUserName] forKey:@"username"];
    [bodyProperties setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"host"];
    [bodyProperties setQIMSafeObject:configInfoArray forKey:@"batchProcess"];
    [bodyProperties setQIMSafeObject:@"iOS" forKey:@"operate_plat"];
    [bodyProperties setQIMSafeObject:[[XmppImManager sharedInstance] resource] forKey:@"resource"];
    [bodyProperties setQIMSafeObject:delFlag ? @(2) : @(1) forKey:@"type"]; //操作类型1：设置；2：删除或取消
    [bodyProperties setQIMSafeObject:@(delFlag) forKey:@"isdel"];
    [bodyProperties setQIMSafeObject:@([[IMDataManager qimDB_SharedInstance] qimDB_getConfigVersion]) forKey:@"version"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil];
    
    //AFN
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([[result objectForKey:@"ret"] boolValue]) {
            [strongSelf insertNewClientConfigInfoWithData:result];
            [strongSelf postUpdateNSNotificationWithType:type];
            if (callback) {
                callback(YES);
            }
        } else {
            if (callback) {
                callback(NO);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO);
        }
    }];
}

- (void)updateRemoteClientConfigWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey WithConfigValue:(NSString *)configValue WithDel:(BOOL)delFlag withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/configuration/setclientconfig.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    QIMVerboseLog(@"单独设置远端个人配置信息 url : %@", destUrl);

    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setQIMSafeObject:[QIMManager getLastUserName] forKey:@"username"];
    [bodyProperties setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"host"];
    [bodyProperties setQIMSafeObject:[self transformClientConfigKeyWithType:type] forKey:@"key"];
    [bodyProperties setQIMSafeObject:subKey forKey:@"subkey"];
    [bodyProperties setQIMSafeObject:configValue forKey:@"value"];
    [bodyProperties setQIMSafeObject:@"iOS" forKey:@"operate_plat"];
    [bodyProperties setQIMSafeObject:[[XmppImManager sharedInstance] resource] forKey:@"resource"];
    [bodyProperties setQIMSafeObject:delFlag ? @(2) : @(1) forKey:@"type"]; //操作类型1：设置；2：删除或取消
    [bodyProperties setQIMSafeObject:@([[IMDataManager qimDB_SharedInstance] qimDB_getConfigVersion]) forKey:@"version"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil];
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        __typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([[result objectForKey:@"ret"] boolValue]) {
            [strongSelf insertNewClientConfigInfoWithData:result];
            [strongSelf postUpdateNSNotificationWithType:type WithSubKey:subKey WithConfigValue:configValue];
            if (callback) {
                callback(YES);
            }
        } else {
            if (callback) {
                callback(NO);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO);
        }
    }];
}

- (void)getRemoteClientConfig {
    NSString *destUrl = [NSString stringWithFormat:@"%@/configuration/getincreclientconfig.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    QIMVerboseLog(@"获取远端个人配置信息 url : %@", destUrl);

    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    QIMVerboseLog(@"获取远端个人配置q_ckey : %@", requestHeaders);

    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setQIMSafeObject:[QIMManager getLastUserName] forKey:@"username"];
    [bodyProperties setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"host"];
    [bodyProperties setQIMSafeObject:@([[IMDataManager qimDB_SharedInstance] qimDB_getConfigVersion]) forKey:@"version"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil];
    QIMVerboseLog(@"获取远端个人配置Body体 : %@", [[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties]);
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    request.useCookiePersistence = NO;
    request.HTTPMethod = QIMHTTPMethodPOST;
    request.HTTPRequestHeaders = cookieProperties;
    request.HTTPBody = requestData;
    __weak __typeof(self) weakSelf = self;
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                [strongSelf insertNewClientConfigInfoWithData:result];
            }
        }
    } failure:^(NSError *error) {
        QIMErrorLog(@"获取远端个人配置失败 : Error : %@", error);
    }];
}

//返回星标联系人或者黑名单用户
- (NSMutableArray *)selectStarOrBlackContacts:(NSString *)pkey {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigArrayStarOrBlackContacts:pkey];
}

//查询不在星标用户的好友
- (NSMutableArray *)selectFriendsNotInStarContacts {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigArrayFriendsNotInStarContacts];
}

//搜索不在星标里面的用户
- (NSMutableArray *)selectUserNotInStartContacts:(NSString *)key {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getConfigArrayUserNotInStartContacts:key];
}

- (BOOL)isStarOrBlackContact:(NSString *)subkey ConfigKey:(NSString *)pkey {
    if([@"kStarContact" isEqualToString:pkey]){
        return [[QIMManager sharedInstance] getClientConfigDeleteFlagWithType:QIMClientConfigTypeKStarContact WithSubKey:subkey] == 0;
    }else if([@"kBlackList" isEqualToString:pkey]){
        return [[QIMManager sharedInstance] getClientConfigDeleteFlagWithType:QIMClientConfigTypeKBlackList WithSubKey:subkey] == 0;
    }else{
        return NO;
    }
}

- (void)setStarOrblackContact:(NSString *)subkey ConfigKey:(NSString *)pkey Flag:(BOOL)value withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    if([@"kStarContact" isEqualToString:pkey]){
        [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStarContact WithSubKey:subkey WithConfigValue:value?@"1":@"0" WithDel:!value withCallback:callback];
    } else if([@"kBlackList" isEqualToString:pkey]){
        [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKBlackList WithSubKey:subkey WithConfigValue:value?@"1":@"0" WithDel:!value withCallback:callback];
    } else{
        
    }
}

- (void)setStarOrblackContacts:(NSDictionary *)map ConfigKey:(NSString *)pkey Flag:(BOOL)value withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    if(map == nil){
        if (callback) {
            callback(NO);
        }
    }
    QIMClientConfigType *configType = QIMClientConfigTypeKStarContact;
    if([@"kBlackList" isEqualToString:pkey]){
        configType = QIMClientConfigTypeKBlackList;
    }
    NSMutableArray *deleteStickList = [NSMutableArray arrayWithCapacity:3];
    NSString *configvalue = value ? @"1" : @"0";
    for(NSString *k in map){
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setQIMSafeObject:k forKey:@"subkey"];
        [dict setQIMSafeObject:pkey forKey:@"key"];
        [dict setQIMSafeObject:configvalue forKey:@"value"];
        [deleteStickList addObject:dict];
    }
    [[QIMManager sharedInstance] updateRemoteClientConfigWithType:configType BatchProcessConfigInfo:deleteStickList WithDel:!value withCallback:callback];
}

- (NSString *)getClientNotificationSoundName {
    return [[QIMManager sharedInstance] getClientConfigInfoWithType:QIMClientConfigTypeKNotificationSound WithSubKey:@"ios"];
}

- (void)setClientNotificationSound:(NSString *)soundName withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKNotificationSound WithSubKey:@"ios" WithConfigValue:soundName WithDel:NO withCallback:callback];
}

@end
