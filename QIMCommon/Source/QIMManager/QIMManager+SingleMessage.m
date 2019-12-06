//
//  QIMManager+SingleMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager+SingleMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (SingleMessage)

- (void)checkSingleChatMsg {
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSingleHistoryMsgError] longLongValue];
    QIMVerboseLog(@"检查本地是否有单人消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineMessagesV2];
    }
}

- (void)updateLastMsgTime {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QIMVerboseLog(@"更新本地单人消息时间戳");
        long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSingleHistoryMsgError] longLongValue];
        if (errorTime > 0) {
            self.lastSingleMsgTime = errorTime;
            QIMVerboseLog(@"本地单人错误时间戳 : %lld", errorTime);
        } else {
            self.lastSingleMsgTime = [[IMDataManager qimDB_SharedInstance] qimDB_lastestMessageTime];
        }
        if (self.lastSingleMsgTime == 0) {
            self.lastSingleMsgTime = defaultTime;
        }
        QIMVerboseLog(@"强制塞本地单人消息时间戳到为 kGetNewSingleHistoryMsgError : %f", self.lastSingleMsgTime);
        [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleMsgTime) forKey:kGetNewSingleHistoryMsgError];
        QIMVerboseLog(@"强制塞本地单人消息时间戳到为 kGetNewSingleHistoryMsgError : %f完成", self.lastSingleMsgTime);
        
        QIMVerboseLog(@"强制塞本地单人消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSingleHistoryMsgError] longLongValue]);
        
        long long defaultTime2 = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        long long errorTime2 = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSingleReadFlagError] longLongValue];
        if (errorTime2 > 0) {
            self.lastSingleReadFlagMsgTime = errorTime2;
            QIMVerboseLog(@"本地单人消息已读z未读状态错误时间戳 : %lld", errorTime2);
        } else {
            self.lastSingleReadFlagMsgTime = self.lastSingleMsgTime;
        }
        
        QIMVerboseLog(@"最终获取到的本地单人最后消息时间戳为 : %lf", self.lastSingleMsgTime);
        QIMVerboseLog(@"最终获取到的本地单人已读未读最后消息时间戳为 : %lf", self.lastSingleReadFlagMsgTime);
    });
}

- (void)getReadFlag {
    __block CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getreadflag.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@",
                         [[QIMNavConfigManager sharedInstance] javaurl],
                         [[XmppImManager sharedInstance] domain],
                         [QIMManager getLastUserName],
                         self.remoteKey,
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    if (self.lastSingleMsgTime <= 0) {
        self.lastSingleMsgTime = ([[NSDate date] timeIntervalSince1970] - 3600 * 24 * 3) * 1000;
    }
    NSDictionary *jsonDic = @{
                              @"domain": [self getDomain],
                              @"time": @(self.lastSingleReadFlagMsgTime),
                              };
    QIMVerboseLog(@"请求单人离线消息阅读状态消息 Body参数 ：%@", jsonDic);
    destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:jsonDic error:nil];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPBody:data];
    [request setHTTPRequestHeaders:cookieProperties];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        
        NSDictionary *logDic = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":requestHeaders, @"describtion":@"请求单人离线消息阅读状态"};
        
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
        
        
        if (response.code == 200) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [result objectForKey:@"ret"];
            NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
            if (result && ret && errcode == 0) {
                NSArray *data = [result objectForKey:@"data"];
#warning 这里更新本地数据库本人已发送的消息状态
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateMessageReadStateWithMsg:data];
                QIMVerboseLog(@"移除已读未读状态时间戳");
                [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetNewSingleReadFlagError];
            } else {
                if (errcode == 5000) {
                    [self updateRemoteLoginKey];
                }
                QIMErrorLog(@"请求消息阅读状态失败，失败原因: %@", [result objectForKey:@"errmsg"]);
                QIMVerboseLog(@"重新设置已读未读状态时间戳");
                [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleReadFlagMsgTime) forKey:kGetNewSingleReadFlagError];
            }
        } else {
            QIMErrorLog(@"请求消息阅读状态失败了");
            QIMVerboseLog(@"重新设置已读未读状态时间戳");
            [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleReadFlagMsgTime) forKey:kGetNewSingleReadFlagError];
        }
    } failure:^(NSError *error) {
        
    }];
}

#warning 这里更新本地数据库已接收的消息状态 ，告诉对方已送达，readFlag=3，更新成功之后更新本地数据库状态
- (void)sendRecevieMessageState {
    NSArray *msgs = [[IMDataManager qimDB_SharedInstance] qimDB_getReceiveMsgIdListWithMsgReadFlag:QIMMessageRemoteReadStateDidReaded withChatType:ChatType_SingleChat withMsgDirection:QIMMessageDirection_Received];
    if (msgs.count > 0) {
        NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *faildArray = [NSMutableArray arrayWithCapacity:5];
        for (NSDictionary *msg in msgs) {
            NSString *msgId = [msg objectForKey:@"MsgIds"];
            NSString *xmppId = [msg objectForKey:@"XmppId"];
            NSArray *msgIds = [msgId componentsSeparatedByString:@","];
            NSMutableArray *reusltMessageIds = [NSMutableArray arrayWithCapacity:5];
            for (NSString *messageId in msgIds) {
                [reusltMessageIds addObject:@{@"id":messageId}];
            }
            NSString *jsonString = [[QIMJSONSerializer sharedInstance] serializeObject:reusltMessageIds];
            BOOL success = [self sendReadStateWithMessagesIdArray:msgIds WithMessageReadFlag:QIMMessageReadFlagDidSend WithXmppId:xmppId];
            if (success) {
                QIMVerboseLog(@"这里告诉对方%@消息【%@】已送到 成功", xmppId, msgIds);
            } else {
                QIMVerboseLog(@"这里告诉对方%@消息【%@】已送到 失败", xmppId, msgIds);
            }
        }
    }
}

- (BOOL)updateOfflineMessagesV2 {
    if (self.remoteKey.length <= 0) {
        QIMVerboseLog(@"当前RemoteKey为空，不要拉单人历史了");
        
        NSDictionary *logDic = @{@"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"describtion":@"当前RemoteKey为空，不要拉单人历史了"};
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];

        return NO;
    }
    BOOL isSuccess = NO;
    NSTimeInterval timeOut = 6;
    int count = 0;
    do {
        count ++;
        QIMVerboseLog(@"单人历史记录拉第%d批次", count);
        int retryCount = 0;
        do {
            if (self.remoteKey.length <= 0) {
                [self updateRemoteLoginKey];
            }
            if (self.lastSingleMsgTime <= 0) {
                self.lastSingleMsgTime = ([[NSDate date] timeIntervalSince1970] - 3600 * 24 * 3) * 1000;
            }

            QIMVerboseLog(@"self.lastSingleMsgTime : %f", self.lastSingleMsgTime);
            retryCount ++;
            QIMVerboseLog(@"第%d次尝试获取个人历史记录", retryCount);
            @autoreleasepool {
                NSArray *chatlog = [self getUserChatlogSince:self.lastSingleMsgTime success:&isSuccess timeOut:timeOut];
                timeOut += 4;
                QIMVerboseLog(@"单人结束 %d", self.latestSingleMessageFlag);
                
                if (chatlog.count <= 0 || retryCount > 3) {
                    QIMWarnLog(@"三次重试 或者 已经是最后一批消息");
                    self.latestSingleMessageFlag = NO;
                }
                if ([chatlog count] > 0) {
                    @autoreleasepool {
                        long long lastMaxTime = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:chatlog];
                        if (lastMaxTime >= self.lastSingleMsgTime) {
                            self.lastSingleMsgTime = lastMaxTime;
                        } else {
                            //插入数据库失败
                            isSuccess = NO;
                            self.lastSingleMsgTime = 0;
                        }
                    }
                }
            }
        } while (!isSuccess && retryCount < 3);
    } while (self.latestSingleMessageFlag);
    if (!isSuccess) {
        QIMVerboseLog(@"拉取单人历史失败");
        QIMVerboseLog(@"本地set单人错误时间戳为: %f", self.lastSingleMsgTime);
        [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleMsgTime) forKey:kGetNewSingleHistoryMsgError];
        return NO;
    } else {
        QIMVerboseLog(@"拉取单人历史成功");
        QIMVerboseLog(@"本地remove单人错误时间戳");
        [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetNewSingleHistoryMsgError];
    }
    return YES;
}

#pragma mark - 获取离线单人消息
- (NSArray *)getUserChatlogSince:(NSTimeInterval)lastChatTime success:(BOOL *)flag timeOut:(NSTimeInterval)timeOut {
    
    __block NSArray *msgList = [[NSArray alloc] init];
    NSString *jid = [QIMManager getLastUserName];
    if ([jid length] > 0) {
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/gethistory.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@&f=t",
                             [[QIMNavConfigManager sharedInstance] javaurl],
                             [[XmppImManager sharedInstance] domain],
                             [jid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             self.remoteKey,
                             [[QIMAppInfo sharedInstance] AppBuildVersion]];
        
        long long time = lastChatTime;
        if (time <= 0) {
            time = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        }
        [self checkMsTimeInterval:&time];
        NSDictionary *jsonDic = @{@"user": [QIMManager getLastUserName],
                                  @"domain": [self getDomain],
                                  @"host": [self getDomain],
                                  @"time": @(time),
                                  @"num": @DEFAULT_CHATMSG_NUM,
                                  @"f" : @"t",
                                  };
        QIMVerboseLog(@"请求单人离线JSON消息 Url : %@, Body参数 ：%@", destUrl, jsonDic);
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:jsonDic error:nil];
        
        dispatch_semaphore_t sema=dispatch_semaphore_create(0);
        [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if (result) {
                int errCode = [[result objectForKey:@"errcode"] intValue];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (errCode == 0) {
                    if (ret) {
                        msgList = [result objectForKey:@"data"];
                        //请求回来的数据 >= 默认值，再次获取一次
                        if (msgList.count >= DEFAULT_CHATMSG_NUM) {
                            self.latestSingleMessageFlag = YES;
                        } else {
                            self.latestSingleMessageFlag = NO;
                            //最后一次获取
                        }
                        QIMVerboseLog(@"是否还要继续获取单人离线JSON消息 ： %d", self.latestSingleMessageFlag);
                        *flag = YES;
                        QIMVerboseLog(@"获取单人历史JSON记录请求成功");
                        
//                        NSDictionary *logDic3 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"是否还要继续获取单人离线JSON消息", @"ext":@{@"是否还要继续获取单人离线JSON消息":@(self.latestSingleMessageFlag)}};
//                        Class autoManager3 = NSClassFromString(@"QIMAutoTrackerManager");
//                        id autoManagerObject3 = [[autoManager3 alloc] init];
//                        [autoManagerObject3 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic3];
                    }
                } else {
                    *flag = NO;
                    if (errCode == 5000) {
                        [self updateRemoteLoginKey];
                    }
                    
//                    NSDictionary *logDic4 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"获取单人历史JSON记录请求失败", @"ext":@{@"Error":result?result:@""}};
//                    Class autoManager4 = NSClassFromString(@"QIMAutoTrackerManager");
//                    id autoManagerObject4 = [[autoManager4 alloc] init];
//                    [autoManagerObject4 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic4];
                    
                    QIMErrorLog(@"获取单人历史JSON记录请求失败,ErrMsg:%@", [result objectForKey:@"errmsg"]);
                }
            } else {
                QIMErrorLog(@"获取单人历史JSON记录失败");
            }
            dispatch_semaphore_signal(sema);
        } withFailedCallBack:^(NSError *error) {
            *flag = NO;
            if (error) {
                QIMErrorLog(@"获取单人历史JSON记录请求失败,ErrMsg:%@",error);
            } else {
                QIMErrorLog(@"获取单人历史JSON记录失败");
            }
            dispatch_semaphore_signal(sema);
            
//            NSDictionary *logDic5 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"获取单人历史JSON记录请求失败", @"ext":@{@"Error":error?error:@""}};
//            Class autoManager5 = NSClassFromString(@"QIMAutoTrackerManager");
//            id autoManagerObject5 = [[autoManager5 alloc] init];
//            [autoManagerObject5 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic5];

        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        /*
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
        [request setUseCookiePersistence:NO];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
        [request setRequestHeaders:cookieProperties];
        QIMVerboseLog(@"请求单人离线JSON消息 Ckey ：%@", cookieProperties);
        [request appendPostData:data];
        
        [request startSynchronous];
        QIMVerboseLog(@"获取单人历史记录Url: %@,Body 参数 : %@ loginComplate耗时 : %llf", destUrl, jsonDic, [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
        NSError *error = [request error];
        
        
        NSDictionary *logDic = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"请求单人离线消息"};
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
        
        
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if (result) {
                int errCode = [[result objectForKey:@"errcode"] intValue];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (errCode == 0) {
                    if (ret) {
                        msgList = [result objectForKey:@"data"];
                        //请求回来的数据 >= 默认值，再次获取一次
                        if (msgList.count >= DEFAULT_CHATMSG_NUM) {
                            self.latestSingleMessageFlag = YES;
                        } else {
                            self.latestSingleMessageFlag = NO;
                            //最后一次获取
                        }
                        QIMVerboseLog(@"是否还要继续获取单人离线JSON消息 ： %d", self.latestSingleMessageFlag);
                        *flag = YES;
                        QIMVerboseLog(@"获取单人历史JSON记录请求成功");

                        NSDictionary *logDic3 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"是否还要继续获取单人离线JSON消息", @"ext":@{@"是否还要继续获取单人离线JSON消息":@(self.latestSingleMessageFlag)}};
                        Class autoManager3 = NSClassFromString(@"QIMAutoTrackerManager");
                        id autoManagerObject3 = [[autoManager3 alloc] init];
                        [autoManagerObject3 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic3];
                    }
                } else {
                    *flag = NO;
                    if (errCode == 5000) {
                        [self updateRemoteLoginKey];
                    }

                    NSDictionary *logDic4 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"获取单人历史JSON记录请求失败", @"ext":@{@"Error":result?result:@""}};
                    Class autoManager4 = NSClassFromString(@"QIMAutoTrackerManager");
                    id autoManagerObject4 = [[autoManager4 alloc] init];
                    [autoManagerObject4 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic4];

                    QIMErrorLog(@"获取单人历史JSON记录请求失败,ErrMsg:%@", [result objectForKey:@"errmsg"]);
                }
            } else {
                QIMErrorLog(@"获取单人历史JSON记录失败");
            }
            result = nil;
        } else {
            *flag = NO;
            if (error) {
                QIMErrorLog(@"获取单人历史JSON记录请求失败,ErrMsg:%@",error);
            } else {
                QIMErrorLog(@"获取单人历史JSON记录失败");
            }

            NSDictionary *logDic5 = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":jsonDic, @"requestHeaders":cookieProperties, @"describtion":@"获取单人历史JSON记录请求失败", @"ext":@{@"Error":error?error:@""}};
            Class autoManager5 = NSClassFromString(@"QIMAutoTrackerManager");
            id autoManagerObject5 = [[autoManager5 alloc] init];
            [autoManagerObject5 performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic5];
        }
        */
    }
    return msgList;
}

#warning 单人聊天消息

#pragma mark - 单人ConsultServer消息（下拉加载） qchatId = 5

- (void)getConsultServerlogWithFrom:(NSString *)from virtualId:(NSString *)virtualId to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction withCallBack:(QIMKitGetConsultServerMsgListCallBack)callback {
    
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];

    __block NSArray *msgList = nil;
    NSArray *fromComs = [from componentsSeparatedByString:@"@"];
    NSArray *toComs = [to componentsSeparatedByString:@"@"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fromComs.firstObject forKey:@"from"];
    [params setObject:toComs.firstObject forKey:@"to"];
    [params setObject:[[virtualId componentsSeparatedByString:@"@"] firstObject] forKey:@"virtual"];
    [params setObject:[NSString stringWithFormat:@"%d", direction] forKey:@"direction"];
    [params setObject:@(version) forKey:@"time"];
    [params setObject:[self getDomain] forKey:@"domain"];
    [params setObject:@(count) forKey:@"num"];
    [params setObject:fromComs.lastObject forKey:@"fhost"];
    [params setObject:toComs.lastObject forKey:@"thost"];
    [params setObject:@"t" forKey:@"f"];
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getconsultmsgs.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@",
                         [[QIMNavConfigManager sharedInstance] javaurl],
                         [[XmppImManager sharedInstance] domain],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         self.remoteKey,
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
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

#pragma mark - 单人历史消息（下拉加载）

- (void)getUserChatlogWithFrom:(NSString *)from to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction include:(BOOL)include withCallBack:(QIMKitGetUserChatMsgListCallBack)callback {

    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];

    NSArray *fromComs = [from componentsSeparatedByString:@"@"];
    NSArray *toComs = [to componentsSeparatedByString:@"@"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:fromComs.firstObject forKey:@"from"];
    [params setObject:toComs.firstObject forKey:@"to"];
    [params setObject:[NSString stringWithFormat:@"%d", direction] forKey:@"direction"];
    [params setObject:@(version) forKey:@"time"];
    [params setObject:[self getDomain] forKey:@"domain"];
    [params setObject:@(count) forKey:@"num"];
    [params setObject:fromComs.lastObject forKey:@"fhost"];
    [params setObject:toComs.lastObject forKey:@"thost"];
    [params setObject:@"t" forKey:@"f"];
    if (include == YES) {
        [params setObject:@"t" forKey:@"include"];
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmsgs.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@&f=t",
                         [[QIMNavConfigManager sharedInstance] javaurl],
                         [[XmppImManager sharedInstance] domain],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         self.remoteKey,
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    
    NSDictionary *logDic = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"describtion":@"单人Chat消息（下拉加载)"};
    Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
    id autoManagerObject = [[autoManager alloc] init];
    [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
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

@end
