//
//  STIMManager+GroupMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "STIMManager+GroupMessage.h"
#import "STIMPrivateHeader.h"

@implementation STIMManager (GroupMessage)

- (void)updateLastGroupMsgTime {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        STIMVerboseLog(@"更新本地群消息时间戳");
        long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        long long errorTime = [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewGroupHistoryMsgError] longLongValue];
        if (errorTime > 0) {
            self.lastGroupMsgTime = errorTime;
            STIMVerboseLog(@"本地群消息错误时间戳 : %lld", errorTime);
        } else {
            self.lastGroupMsgTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_lastestGroupMessageTime];
        }
        if (self.lastGroupMsgTime == 0) {
            self.lastGroupMsgTime = defaultTime;
        }
        STIMVerboseLog(@"强制塞本地群消息时间戳到为 kGetNewGroupHistoryMsgError : %f", self.lastGroupMsgTime);
        [[STIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetNewGroupHistoryMsgError];
        STIMVerboseLog(@"强制塞本地群消息时间戳到为 kGetNewGroupHistoryMsgError : %f完成", self.lastGroupMsgTime);
        
        STIMVerboseLog(@"强制塞本地群消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewGroupHistoryMsgError] longLongValue]);

        STIMVerboseLog(@"最终获取到的本地群最后消息时间戳为 : %f", self.lastGroupMsgTime);
    });
}

- (void)updateLastMaxMucReadMarkTime {
    STIMVerboseLog(@"更新本地群阅读指针时间戳");
    NSInteger userMaxVersion = [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserCacheDataWithKey:kGetGroupReadMarkVersion withType:8];
    self.lastMaxMucReadMarkTime = userMaxVersion;
    STIMVerboseLog(@"最终获取到的本地群阅读指针最后消息时间戳为 : %f", self.lastMaxMucReadMarkTime);
}

- (void)checkGroupChatMsg {
    long long errorTime = [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewGroupHistoryMsgError] longLongValue];
    STIMVerboseLog(@"检查本地是否有群消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineGroupMessages];
    }
}

- (void)updateOfflineGroupMessages {
    STIMVerboseLog(@"updateOfflineGroupMessages");
    
    NSDictionary *logDic1 = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"methodParams":@"", @"requestHeaders":@"", @"describtion":@"准备开始获取群离线历史消息", @"ext":@{@"lastGroupMsgTime":@(self.lastGroupMsgTime)}};
    
    Class autoManager1 = NSClassFromString(@"STIMAutoTrackerManager");
    id autoManagerObject1 = [[autoManager1 alloc] init];
    [autoManagerObject1 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic1];

    int count = 0;
    BOOL getMucHistotySuccess = NO;
    NSTimeInterval timeOut = 6;
    do {
        count ++;
        STIMWarnLog(@"群历史记录拉第%d批次", count);
        int retryCount = 0;
        do {
            retryCount ++;
            getMucHistotySuccess = [self getMucHistoryV2WithTimeOut:timeOut];
            timeOut += 6;
            STIMWarnLog(@"群历史记录拉重试第%d次", retryCount);
            if (retryCount >= 3) {
                STIMWarnLog(@"重试超过三次，结束请求群历史记录");
                self.latestGroupMessageFlag = NO;
            }
        } while (!getMucHistotySuccess && retryCount < 3);
    } while (self.latestGroupMessageFlag);
    if (!getMucHistotySuccess) {
        
        NSDictionary *logDic = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"methodParams":@"", @"requestHeaders":@"", @"describtion":@"获取群离线历史消息失败了，设置本地群最后消息时间戳", @"ext":@{@"lastGroupMsgTime":@(self.lastGroupMsgTime)}};
        
        Class autoManager = NSClassFromString(@"STIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];

        STIMVerboseLog(@"获取群历史记录失败了");
        STIMWarnLog(@"拉历史失败之后set本地群最后消息时间戳为 : %lf", self.lastGroupMsgTime);
        [[STIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetNewGroupHistoryMsgError];
    } else {
        STIMVerboseLog(@"获取群历史记录成功了");
        STIMVerboseLog(@"remove本地群最后消息时间戳");
        [[STIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetNewGroupHistoryMsgError];
    }
}

//拉取离线群历史记录
- (BOOL)getMucHistoryV2WithTimeOut:(NSTimeInterval)timeOut {
    if (self.remoteKey.length <= 0) {
        NSDictionary *logDic = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"describtion":@"当前remoteKey为空，不要拉群历史了"};
        Class autoManager = NSClassFromString(@"STIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];

        STIMVerboseLog(@"当前remoteKey为空，不要拉群历史了");
        return NO;
    }
    __block BOOL getMucHistorySuccess = NO;
    NSString *jid = [STIMManager getLastUserName];
    if ([jid length] > 0) {
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmuchistory.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iOS&v=%@",
                             [[STIMNavConfigManager sharedInstance] javaurl],
                             [[XmppImManager sharedInstance] domain],
                             jid,
                             self.remoteKey,
                             [[STIMAppInfo sharedInstance] AppBuildVersion]];
        
        if (self.lastGroupMsgTime <= 0) {
            self.lastGroupMsgTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        }
        long long lastMsgTime = self.lastGroupMsgTime;
        [self checkMsTimeInterval:&lastMsgTime];
        
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        CFAbsoluteTime startTime = [[STIMWatchDog sharedInstance] startTime];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setSTIMSafeObject:@(lastMsgTime) forKey:@"time"];
        [params setSTIMSafeObject:jid forKey:@"user"];
        [params setSTIMSafeObject:[NSString stringWithFormat:@"conference.%@", [self getDomain]] forKey:@"domain"];
        [params setSTIMSafeObject:[self getDomain] forKey:@"host"];
        [params setSTIMSafeObject:@(DEFAULT_GROUPMSG_NUM) forKey:@"num"];
        STIMVerboseLog(@"JSON请求群历史消息请求URL为:%@", destUrl);
        STIMVerboseLog(@"JSON请求群历史消息参数为:%@", params);
        NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        STIMVerboseLog(@"JSON请求群历史消息Ckey为:%@", cookieProperties);
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
        [request setUseCookiePersistence:NO];
        [request setRequestHeaders:cookieProperties];
        [request appendPostData:data];
        [request startSynchronous];
        
        STIMVerboseLog(@"获取群历史记录Url : %@, Body参数: %@ loginComplate耗时 : %llf", destUrl, params, [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
        
        NSDictionary *logDic = @{@"costTime":@([[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"请求群离线消息"};
        
        Class autoManager = NSClassFromString(@"STIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
        
        NSError *error = [request error];
        NSDictionary *result = nil;
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        } else {
            getMucHistorySuccess == NO;

            NSDictionary *logDic3 = @{@"costTime":@([[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"获取群离线消息失败了", @"ext":@{@"HTTPStatusCode":@([request responseStatusCode]), @"Error": error ? error : @""}};

            Class autoManager3 = NSClassFromString(@"STIMAutoTrackerManager");
            id autoManagerObject3 = [[autoManager3 alloc] init];
            [autoManagerObject3 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic3];

            STIMErrorLog(@"获取群历史记录失败了了了 : %@, [request responseStatusCode] : %d", error, [request responseStatusCode]);
        }
        if (result.count > 0) {
            int errCode = [[result objectForKey:@"errcode"] intValue];
            if (errCode == 0) {
                NSArray *data = [result objectForKey:@"data"];
                STIMVerboseLog(@"获取群历史记录成功。 : %lu", (unsigned long)data.count);
                if (data.count >= DEFAULT_GROUPMSG_NUM) {
                    self.latestGroupMessageFlag = YES;
                } else {
                    self.latestGroupMessageFlag = NO;
                }

                NSDictionary *logDic4 = @{@"costTime":@([[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"ext":@{@"是否还要继续拉取群离线消息":@(self.latestGroupMessageFlag)},@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"是否还要继续拉取群离线消息"};

                Class autoManager4 = NSClassFromString(@"STIMAutoTrackerManager");
                id autoManagerObject4 = [[autoManager4 alloc] init];
                [autoManagerObject4 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic4];

                STIMVerboseLog(@"是否还要继续拉取群离线消息 : %d", self.latestGroupMessageFlag);
                [self dealWithGroupMsg:data successed:&getMucHistorySuccess];
            } else {
                getMucHistorySuccess == NO;
                if (errCode == 5000) {
                    [self updateRemoteLoginKey];
                }


                NSDictionary *logDic5 = @{@"costTime":@([[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"获取群离线消息失败了", @"ext":@{@"Error":result?result:@""}};

                Class autoManager5 = NSClassFromString(@"STIMAutoTrackerManager");
                id autoManagerObject5 = [[autoManager5 alloc] init];
                [autoManagerObject5 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic5];

                STIMErrorLog(@"获取群历史记录失败,ErrMsg:%@", result);
            }
        } else {
            getMucHistorySuccess == NO;
            
            STIMErrorLog(@"获取群历史记录失败了了了, 没有result");
        }
    }
    return getMucHistorySuccess;
}

- (void)dealWithGroupMsg:(NSArray * _Nonnull)data successed:(BOOL *)flag {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    if (data.count > 0) {
        NSMutableArray <NSDictionary *>*atAllMsgList = [[NSMutableArray alloc] initWithCapacity:3];
        NSMutableArray <NSDictionary *>*normalMsgList = [[NSMutableArray alloc] initWithCapacity:3];
        long long lastTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertIphoneHistoryGroupJSONMsg:data WithAtAllMsgList:&atAllMsgList WithNormaleAtMsgList:&normalMsgList];
        if (self.lastGroupMsgTime <= lastTime) {
            self.lastGroupMsgTime = lastTime;
            *flag = YES;
        } else {
            *flag = NO;
        }
        for (NSDictionary *infoDic in atAllMsgList) {
            NSString *groupId = [infoDic objectForKey:@"SessionId"];
            STIMMessageModel *msg = [STIMMessageModel new];
            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
            [msg setFrom:[infoDic objectForKey:@"From"]];
            [msg setTo:[infoDic objectForKey:@"To"]];
            [msg setMessage:[infoDic objectForKey:@"Content"]];
            NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
            [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
            [msg setMessageSendState:[[infoDic objectForKey:@"MsgState"] intValue]];
            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
            [self addOfflineAtMeMessageByJid:groupId withType:STIMAtTypeALL withMsgId:[infoDic objectForKey:@"MsgId"] withMsgTime:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        }
        for (NSDictionary *infoDic in normalMsgList) {
            NSString *groupId = [infoDic objectForKey:@"SessionId"];
            STIMMessageModel *msg = [STIMMessageModel new];
            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
            [msg setFrom:[infoDic objectForKey:@"From"]];
            [msg setTo:[infoDic objectForKey:@"To"]];
            [msg setMessage:[infoDic objectForKey:@"Content"]];
            NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
            [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
            [msg setMessageSendState:[[infoDic objectForKey:@"MsgState"] intValue]];
            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
            [self addOfflineAtMeMessageByJid:groupId withType:STIMAtTypeSP withMsgId:[infoDic objectForKey:@"MsgId"] withMsgTime:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        }
    } else {
        *flag = YES;
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    STIMVerboseLog(@"处理群离线消息历史记录%ld条，耗时%fs", data.count, end - start); //s
}

//拉取群翻页历史记录
- (NSArray *)getMucMsgListWithGroupId:(NSString *)groupId WithDirection:(int)direction WithLimit:(int)limit WithVersion:(long long)version include:(BOOL)include {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *coms = [groupId componentsSeparatedByString:@"@"];
    NSString *groupC = @"conference.";
    NSString *groupN = [coms firstObject];
    NSString *domain = [[coms lastObject] substringFromIndex:groupC.length];
    [params setSTIMSafeObject:groupN ? groupN : @"" forKey:@"muc"];
    [params setSTIMSafeObject:domain forKey:@"domain"];
    [params setSTIMSafeObject:[NSString stringWithFormat:@"%lld", version] forKey:@"time"];
    [params setSTIMSafeObject:[NSString stringWithFormat:@"%d", limit] forKey:@"num"];
    [params setSTIMSafeObject:@"1" forKey:@"type"];
    [params setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"u"];
    [params setSTIMSafeObject:[NSString stringWithFormat:@"%d", direction] forKey:@"direction"];
    if (YES == include) {
        [params setSTIMSafeObject:@"t" forKey:@"include"];
    }
    NSData *requestData = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmucmsgs.qunar?u=%@&k=%@&platform=iphone&version=%@", [[STIMNavConfigManager sharedInstance] javaurl], [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[STIMAppInfo sharedInstance] AppBuildVersion]];
    STIMVerboseLog(@"JSON请求群翻页历史记录URL为:%@", destUrl);
    STIMVerboseLog(@"JSON请求群翻页历史记录参数为:%@", params);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:cookieProperties];
    STIMVerboseLog(@"JSON请求群翻页历史记录 Ckey 为:%@", cookieProperties);
    [request appendPostData:requestData];

    [request startSynchronous];
    NSError *error = [request error];
    NSDictionary *result = nil;
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            return [result objectForKey:@"data"];
        }
    }
    return nil;
}

//更新群阅读指针
- (void)updateMucReadMark {
    __block CFAbsoluteTime startTime = [[STIMWatchDog sharedInstance] startTime];
    if (self.remoteKey.length <= 0) {
        [self updateRemoteLoginKey];
    }
    __block BOOL getMucReadMarkSuccess = NO;
    NSString *jid = [STIMManager getLastUserName];
    if ([jid length] > 0) {        
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/get_muc_readmark1.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iOS&v=%@",
                             [[STIMNavConfigManager sharedInstance] javaurl],
                             [[XmppImManager sharedInstance] domain],
                             jid,
                             self.remoteKey,
                             [[STIMAppInfo sharedInstance] AppBuildVersion]];
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setSTIMSafeObject:jid forKey:@"user"];
        [params setSTIMSafeObject:[self getDomain] forKey:@"host"];
        [params setSTIMSafeObject:@(self.lastMaxMucReadMarkTime) forKey:@"time"];
        STIMVerboseLog(@"JSON请求群ReadMark阅读指针URL为:%@", destUrl);
        STIMVerboseLog(@"JSON请求群ReadMark阅读指针参数为:%@", params);
        NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        STIMVerboseLog(@"JSON请求群ReadMark阅读指针Ckey为 : %@", cookieProperties);
        
        STIMHTTPRequest *request = [STIMHTTPRequest requestWithURL:[NSURL URLWithString:destUrl]];
        request.HTTPMethod = STIMHTTPMethodPOST;
        request.HTTPBody = data;
        request.HTTPRequestHeaders = cookieProperties;
        __block NSDictionary *result = nil;
        [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
            
            NSDictionary *logDic = @{@"costTime":@([[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"请求群离线阅读指针"};
            
            Class autoManager = NSClassFromString(@"STIMAutoTrackerManager");
            id autoManagerObject = [[autoManager alloc] init];
            [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
            
            
             STIMVerboseLog(@"http请求获取群阅读指针结果 : %@", response);
             result = [[STIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
             BOOL errcode = [[result objectForKey:@"ret"] boolValue];
             NSString *errmsg = [result objectForKey:@"errmsg"];
             if (errcode != 0 && result.count > 0 && response.code == 200) {
                 NSMutableArray *mucData = [result objectForKey:@"data"];
             
                 [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateGroupMessageReadFlag:mucData];
                 /*
                 if (maxMucReadMarkTime > self.lastMaxMucReadMarkTime) {
                     STIMVerboseLog(@"插入本地群阅读指针zuida时间戳 : %lld", maxMucReadMarkTime);
                     [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateUserCacheDataWithKey:kGetGroupReadMarkVersion withType:8 withValue:@"群阅读指针时间戳V2" withValueInt:maxMucReadMarkTime];
                 }
                 */
                 self.hasAtMeDic = nil;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     STIMVerboseLog(@"获取群阅读指针之后强制刷新NavBar未读数");
                     [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
                 });
                 getMucReadMarkSuccess = YES;
             } else {
                 getMucReadMarkSuccess = NO;
                 STIMErrorLog(@"获取群阅读指针失败, 失败原因 ： %@", errmsg);
             }
        } failure:^(NSError *error) {
            STIMErrorLog(@"error : %@", error);
        }];
    } else {
        STIMErrorLog(@"获取群阅读指针错误，原因：当前用户名为空");
    }
}

@end
