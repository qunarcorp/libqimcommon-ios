//
//  QIMManager+GroupMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager+GroupMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (GroupMessage)

- (void)updateLastGroupMsgTime {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        QIMVerboseLog(@"更新本地群消息时间戳");
        long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewGroupHistoryMsgError] longLongValue];
        if (errorTime > 0) {
            self.lastGroupMsgTime = errorTime;
            QIMVerboseLog(@"本地群消息错误时间戳 : %lld", errorTime);
        } else {
            self.lastGroupMsgTime = [[IMDataManager qimDB_SharedInstance] qimDB_lastestGroupMessageTime];
        }
        if (self.lastGroupMsgTime == 0) {
            self.lastGroupMsgTime = defaultTime;
        }
        QIMVerboseLog(@"强制塞本地群消息时间戳到为 kGetNewGroupHistoryMsgError : %f", self.lastGroupMsgTime);
        [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetNewGroupHistoryMsgError];
        QIMVerboseLog(@"强制塞本地群消息时间戳到为 kGetNewGroupHistoryMsgError : %f完成", self.lastGroupMsgTime);
        
        QIMVerboseLog(@"强制塞本地群消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewGroupHistoryMsgError] longLongValue]);

        QIMVerboseLog(@"最终获取到的本地群最后消息时间戳为 : %f", self.lastGroupMsgTime);
    });
}

- (void)updateLastMaxMucReadMarkTime {
    QIMVerboseLog(@"更新本地群阅读指针时间戳");
    NSInteger userMaxVersion = [[IMDataManager qimDB_SharedInstance] qimDB_getUserCacheDataWithKey:kGetGroupReadMarkVersion withType:8];
    self.lastMaxMucReadMarkTime = userMaxVersion;
    QIMVerboseLog(@"最终获取到的本地群阅读指针最后消息时间戳为 : %f", self.lastMaxMucReadMarkTime);
}

- (void)checkGroupChatMsg {
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewGroupHistoryMsgError] longLongValue];
    QIMVerboseLog(@"检查本地是否有群消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineGroupMessages];
    }
}

- (void)updateOfflineGroupMessages {
    QIMVerboseLog(@"updateOfflineGroupMessages");
    
    NSDictionary *logDic1 = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"methodParams":@"", @"requestHeaders":@"", @"describtion":@"准备开始获取群离线历史消息", @"ext":@{@"lastGroupMsgTime":@(self.lastGroupMsgTime)}};
    
    Class autoManager1 = NSClassFromString(@"QIMAutoTrackerManager");
    id autoManagerObject1 = [[autoManager1 alloc] init];
    [autoManagerObject1 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic1];

    int count = 0;
    BOOL getMucHistotySuccess = NO;
    NSTimeInterval timeOut = 6;
    do {
        count ++;
        QIMWarnLog(@"群历史记录拉第%d批次", count);
        int retryCount = 0;
        do {
            retryCount ++;
            getMucHistotySuccess = [self getMucHistoryV2WithTimeOut:timeOut];
            timeOut += 6;
            QIMWarnLog(@"群历史记录拉重试第%d次", retryCount);
            if (retryCount >= 3) {
                QIMWarnLog(@"重试超过三次，结束请求群历史记录");
                self.latestGroupMessageFlag = NO;
            }
        } while (!getMucHistotySuccess && retryCount < 3);
    } while (self.latestGroupMessageFlag);
    if (!getMucHistotySuccess) {
        
        NSDictionary *logDic = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"methodParams":@"", @"requestHeaders":@"", @"describtion":@"获取群离线历史消息失败了，设置本地群最后消息时间戳", @"ext":@{@"lastGroupMsgTime":@(self.lastGroupMsgTime)}};
        
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];

        QIMVerboseLog(@"获取群历史记录失败了");
        QIMWarnLog(@"拉历史失败之后set本地群最后消息时间戳为 : %lf", self.lastGroupMsgTime);
        [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetNewGroupHistoryMsgError];
    } else {
        QIMVerboseLog(@"获取群历史记录成功了");
        QIMVerboseLog(@"remove本地群最后消息时间戳");
        [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetNewGroupHistoryMsgError];
    }
}

//拉取离线群历史记录
- (BOOL)getMucHistoryV2WithTimeOut:(NSTimeInterval)timeOut {
    if (self.remoteKey.length <= 0) {
        NSDictionary *logDic = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"describtion":@"当前remoteKey为空，不要拉群历史了"};
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];

        QIMVerboseLog(@"当前remoteKey为空，不要拉群历史了");
        return NO;
    }
    __block BOOL getMucHistorySuccess = NO;
    NSString *jid = [QIMManager getLastUserName];
    if ([jid length] > 0) {
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmuchistory.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iOS&v=%@",
                             [[QIMNavConfigManager sharedInstance] javaurl],
                             [[XmppImManager sharedInstance] domain],
                             jid,
                             self.remoteKey,
                             [[QIMAppInfo sharedInstance] AppBuildVersion]];
        
        if (self.lastGroupMsgTime <= 0) {
            self.lastGroupMsgTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        }
        long long lastMsgTime = self.lastGroupMsgTime;
        [self checkMsTimeInterval:&lastMsgTime];
        
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setQIMSafeObject:@(lastMsgTime) forKey:@"time"];
        [params setQIMSafeObject:jid forKey:@"user"];
        [params setQIMSafeObject:[NSString stringWithFormat:@"conference.%@", [self getDomain]] forKey:@"domain"];
        [params setQIMSafeObject:[self getDomain] forKey:@"host"];
        [params setQIMSafeObject:@(DEFAULT_GROUPMSG_NUM) forKey:@"num"];
        QIMVerboseLog(@"JSON请求群历史消息请求URL为:%@", destUrl);
        QIMVerboseLog(@"JSON请求群历史消息参数为:%@", params);
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        QIMVerboseLog(@"JSON请求群历史消息Ckey为:%@", cookieProperties);
        __block NSDictionary *result = nil;
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
            result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            dispatch_semaphore_signal(sema);
        } withFailedCallBack:^(NSError *error) {
            getMucHistorySuccess == NO;
            
            NSDictionary *logDic3 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"获取群离线消息失败了", @"ext":@{@"Error": error ? error : @""}};
            
            Class autoManager3 = NSClassFromString(@"QIMAutoTrackerManager");
            id autoManagerObject3 = [[autoManager3 alloc] init];
            [autoManagerObject3 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic3];
            
            QIMErrorLog(@"获取群历史记录失败了了了 : %@", error);
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        if (result.count > 0) {
            int errCode = [[result objectForKey:@"errcode"] intValue];
            if (errCode == 0) {
                NSArray *data = [result objectForKey:@"data"];
                QIMVerboseLog(@"获取群历史记录成功。 : %lu", (unsigned long)data.count);
                if (data.count >= DEFAULT_GROUPMSG_NUM) {
                    self.latestGroupMessageFlag = YES;
                } else {
                    self.latestGroupMessageFlag = NO;
                }
                
                NSDictionary *logDic4 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"ext":@{@"是否还要继续拉取群离线消息":@(self.latestGroupMessageFlag)},@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"是否还要继续拉取群离线消息"};
                
                Class autoManager4 = NSClassFromString(@"QIMAutoTrackerManager");
                id autoManagerObject4 = [[autoManager4 alloc] init];
                [autoManagerObject4 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic4];
                
                QIMVerboseLog(@"是否还要继续拉取群离线消息 : %d", self.latestGroupMessageFlag);
                [self dealWithGroupMsg:data successed:&getMucHistorySuccess];
            } else {
                getMucHistorySuccess == NO;
                if (errCode == 5000) {
                    [self updateRemoteLoginKey];
                }
                
                NSDictionary *logDic5 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"获取群离线消息失败了", @"ext":@{@"Error":result?result:@""}};
                
                Class autoManager5 = NSClassFromString(@"QIMAutoTrackerManager");
                id autoManagerObject5 = [[autoManager5 alloc] init];
                [autoManagerObject5 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic5];
                
                QIMErrorLog(@"获取群历史记录失败,ErrMsg:%@", result);
            }
        } else {
            getMucHistorySuccess == NO;
            
            QIMErrorLog(@"获取群历史记录失败了了了, 没有result");
        }
        /*
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
        [request setUseCookiePersistence:NO];
        [request setRequestHeaders:cookieProperties];
        [request appendPostData:data];
        [request startSynchronous];
        
        QIMVerboseLog(@"获取群历史记录Url : %@, Body参数: %@ loginComplate耗时 : %llf", destUrl, params, [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
        
        NSDictionary *logDic = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"请求群离线消息"};
        
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
        
        NSError *error = [request error];
        NSDictionary *result = nil;
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        } else {
            getMucHistorySuccess == NO;

            NSDictionary *logDic3 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"获取群离线消息失败了", @"ext":@{@"HTTPStatusCode":@([request responseStatusCode]), @"Error": error ? error : @""}};

            Class autoManager3 = NSClassFromString(@"QIMAutoTrackerManager");
            id autoManagerObject3 = [[autoManager3 alloc] init];
            [autoManagerObject3 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic3];

            QIMErrorLog(@"获取群历史记录失败了了了 : %@, [request responseStatusCode] : %d", error, [request responseStatusCode]);
        }
        if (result.count > 0) {
            int errCode = [[result objectForKey:@"errcode"] intValue];
            if (errCode == 0) {
                NSArray *data = [result objectForKey:@"data"];
                QIMVerboseLog(@"获取群历史记录成功。 : %lu", (unsigned long)data.count);
                if (data.count >= DEFAULT_GROUPMSG_NUM) {
                    self.latestGroupMessageFlag = YES;
                } else {
                    self.latestGroupMessageFlag = NO;
                }

                NSDictionary *logDic4 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"ext":@{@"是否还要继续拉取群离线消息":@(self.latestGroupMessageFlag)},@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"是否还要继续拉取群离线消息"};

                Class autoManager4 = NSClassFromString(@"QIMAutoTrackerManager");
                id autoManagerObject4 = [[autoManager4 alloc] init];
                [autoManagerObject4 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic4];

                QIMVerboseLog(@"是否还要继续拉取群离线消息 : %d", self.latestGroupMessageFlag);
                [self dealWithGroupMsg:data successed:&getMucHistorySuccess];
            } else {
                getMucHistorySuccess == NO;
                if (errCode == 5000) {
                    [self updateRemoteLoginKey];
                }


                NSDictionary *logDic5 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"获取群离线消息失败了", @"ext":@{@"Error":result?result:@""}};

                Class autoManager5 = NSClassFromString(@"QIMAutoTrackerManager");
                id autoManagerObject5 = [[autoManager5 alloc] init];
                [autoManagerObject5 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic5];

                QIMErrorLog(@"获取群历史记录失败,ErrMsg:%@", result);
            }
        } else {
            getMucHistorySuccess == NO;
            
            QIMErrorLog(@"获取群历史记录失败了了了, 没有result");
        }
        */
    }
    return getMucHistorySuccess;
}

- (void)dealWithGroupMsg:(NSArray * _Nonnull)data successed:(BOOL *)flag {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    if (data.count > 0) {
        NSMutableArray <NSDictionary *>*atAllMsgList = [[NSMutableArray alloc] initWithCapacity:3];
        NSMutableArray <NSDictionary *>*normalMsgList = [[NSMutableArray alloc] initWithCapacity:3];
        long long lastTime = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertIphoneHistoryGroupJSONMsg:data WithAtAllMsgList:&atAllMsgList WithNormaleAtMsgList:&normalMsgList];
        if (self.lastGroupMsgTime <= lastTime) {
            self.lastGroupMsgTime = lastTime;
            *flag = YES;
        } else {
            *flag = NO;
        }
        for (NSDictionary *infoDic in atAllMsgList) {
            NSString *groupId = [infoDic objectForKey:@"SessionId"];
            QIMMessageModel *msg = [QIMMessageModel new];
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
            [self addOfflineAtMeMessageByJid:groupId withType:QIMAtTypeALL withMsgId:[infoDic objectForKey:@"MsgId"] withMsgTime:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        }
        for (NSDictionary *infoDic in normalMsgList) {
            NSString *groupId = [infoDic objectForKey:@"SessionId"];
            QIMMessageModel *msg = [QIMMessageModel new];
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
            [self addOfflineAtMeMessageByJid:groupId withType:QIMAtTypeSP withMsgId:[infoDic objectForKey:@"MsgId"] withMsgTime:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        }
    } else {
        *flag = YES;
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"处理群离线消息历史记录%ld条，耗时%fs", data.count, end - start); //s
}

//拉取群翻页历史记录
- (void)getMucMsgListWithGroupId:(NSString *)groupId WithDirection:(int)direction WithLimit:(int)limit WithVersion:(long long)version include:(BOOL)include withCallBack:(QIMKitGetMucMsgListCallBack)callback {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *coms = [groupId componentsSeparatedByString:@"@"];
    NSString *groupC = @"conference.";
    NSString *groupN = [coms firstObject];
    NSString *domain = [[coms lastObject] substringFromIndex:groupC.length];
    [params setQIMSafeObject:groupN ? groupN : @"" forKey:@"muc"];
    [params setQIMSafeObject:domain forKey:@"domain"];
    [params setQIMSafeObject:[NSString stringWithFormat:@"%lld", version] forKey:@"time"];
    [params setQIMSafeObject:[NSString stringWithFormat:@"%d", limit] forKey:@"num"];
    [params setQIMSafeObject:@"1" forKey:@"type"];
    [params setQIMSafeObject:[QIMManager getLastUserName] forKey:@"u"];
    [params setQIMSafeObject:[NSString stringWithFormat:@"%d", direction] forKey:@"direction"];
    if (YES == include) {
        [params setQIMSafeObject:@"t" forKey:@"include"];
    }
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmucmsgs.qunar?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] javaurl], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    QIMVerboseLog(@"JSON请求群翻页历史记录URL为:%@", destUrl);
    QIMVerboseLog(@"JSON请求群翻页历史记录参数为:%@", params);
    
    //Mark by AFN
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            if (callback) {
                callback([result objectForKey:@"data"]);
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

//更新群阅读指针
- (void)updateMucReadMark {
    __block CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    if (self.remoteKey.length <= 0) {
        [self updateRemoteLoginKey];
    }
    __block BOOL getMucReadMarkSuccess = NO;
    NSString *jid = [QIMManager getLastUserName];
    if ([jid length] > 0) {        
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/get_muc_readmark1.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iOS&v=%@",
                             [[QIMNavConfigManager sharedInstance] javaurl],
                             [[XmppImManager sharedInstance] domain],
                             jid,
                             self.remoteKey,
                             [[QIMAppInfo sharedInstance] AppBuildVersion]];
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setQIMSafeObject:jid forKey:@"user"];
        [params setQIMSafeObject:[self getDomain] forKey:@"host"];
        [params setQIMSafeObject:@(self.lastMaxMucReadMarkTime) forKey:@"time"];
        QIMVerboseLog(@"JSON请求群ReadMark阅读指针URL为:%@", destUrl);
        QIMVerboseLog(@"JSON请求群ReadMark阅读指针参数为:%@", params);
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:@"application/json" forKey:@"content-type"];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        QIMVerboseLog(@"JSON请求群ReadMark阅读指针Ckey为 : %@", cookieProperties);
        
        QIMHTTPRequest *request = [QIMHTTPRequest requestWithURL:[NSURL URLWithString:destUrl]];
        request.HTTPMethod = QIMHTTPMethodPOST;
        request.HTTPBody = data;
        request.HTTPRequestHeaders = cookieProperties;
        __block NSDictionary *result = nil;
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            
            NSDictionary *logDic = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"请求群离线阅读指针"};
            
            Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
            id autoManagerObject = [[autoManager alloc] init];
            [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
            
            
             QIMVerboseLog(@"http请求获取群阅读指针结果 : %@", response);
             result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
             BOOL errcode = [[result objectForKey:@"ret"] boolValue];
             NSString *errmsg = [result objectForKey:@"errmsg"];
             if (errcode != 0 && result.count > 0 && response.code == 200) {
                 NSMutableArray *mucData = [result objectForKey:@"data"];
             
                 [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateGroupMessageReadFlag:mucData];
                 /*
                 if (maxMucReadMarkTime > self.lastMaxMucReadMarkTime) {
                     QIMVerboseLog(@"插入本地群阅读指针zuida时间戳 : %lld", maxMucReadMarkTime);
                     [[IMDataManager qimDB_SharedInstance] qimDB_UpdateUserCacheDataWithKey:kGetGroupReadMarkVersion withType:8 withValue:@"群阅读指针时间戳V2" withValueInt:maxMucReadMarkTime];
                 }
                 */
                 self.hasAtMeDic = nil;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     QIMVerboseLog(@"获取群阅读指针之后强制刷新NavBar未读数");
                     [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
                 });
                 getMucReadMarkSuccess = YES;
             } else {
                 getMucReadMarkSuccess = NO;
                 QIMErrorLog(@"获取群阅读指针失败, 失败原因 ： %@", errmsg);
             }
        } failure:^(NSError *error) {
            QIMErrorLog(@"error : %@", error);
        }];
    } else {
        QIMErrorLog(@"获取群阅读指针错误，原因：当前用户名为空");
    }
}

@end
