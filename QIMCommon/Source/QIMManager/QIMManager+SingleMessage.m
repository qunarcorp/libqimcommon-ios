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
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSingleHistoryMsgError] longLongValue];
    QIMVerboseLog(@"检查本地是否有单人消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineMessagesV2];
    }
}

- (void)updateLastMsgTime {
    QIMVerboseLog(@"更新本地单人消息时间戳");
    long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 2) * 1000;
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSingleHistoryMsgError] longLongValue];
    if (errorTime > 0) {
        self.lastSingleMsgTime = errorTime;
        QIMVerboseLog(@"本地单人错误时间戳 : %lld", errorTime);
    } else {
        self.lastSingleMsgTime = [[IMDataManager sharedInstance] lastestMessageTime];
    }
    if (self.lastSingleMsgTime == 0) {
        self.lastSingleMsgTime = defaultTime;
    }
    QIMVerboseLog(@"强制塞本地单人消息时间戳到为 kGetSingleHistoryMsgError : %f", self.lastSingleMsgTime);
    [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleMsgTime) forKey:kGetSingleHistoryMsgError];
    QIMVerboseLog(@"强制塞本地单人消息时间戳到为 kGetSingleHistoryMsgError : %f完成", self.lastSingleMsgTime);
    
    QIMVerboseLog(@"强制塞本地单人消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSingleHistoryMsgError] longLongValue]);
    
    long long defaultTime2 = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 2) * 1000;
    long long errorTime2 = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSingleReadFlagError] longLongValue];
    if (errorTime2 > 0) {
        self.lastSingleReadFlagMsgTime = errorTime2;
        QIMVerboseLog(@"本地单人消息已读z未读状态错误时间戳 : %lld", errorTime2);
    } else {
        self.lastSingleReadFlagMsgTime = self.lastSingleMsgTime;
    }
    
    QIMVerboseLog(@"最终获取到的本地单人最后消息时间戳为 : %lf", self.lastSingleMsgTime);
    QIMVerboseLog(@"最终获取到的本地单人已读未读最后消息时间戳为 : %lf", self.lastSingleReadFlagMsgTime);
}

- (void)getReadFlag {
    //curl -X POST  -H 'content-type: application/json' -d '{"time":1.520480778253E9, "domain":"ejabhost1"}' 'http://l-im3.vc.beta.cn0.qunar.com:8900/qtapi/getreadflag.qunar
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getreadflag.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@",
                         [[QIMNavConfigManager sharedInstance] javaurl],
                         [[XmppImManager sharedInstance] domain],
                         [QIMManager getLastUserName],
                         self.remoteKey,
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    if (self.lastSingleMsgTime <= 0) {
        self.lastSingleMsgTime = [[NSDate date] timeIntervalSince1970] - 3600 * 24 * 4;
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
        if (response.code == 200) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [result objectForKey:@"ret"];
            NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
            if (result && ret && errcode == 0) {
                NSArray *data = [result objectForKey:@"data"];
#warning 这里更新本地数据库本人已发送的消息状态
                [[IMDataManager sharedInstance] bulkUpdateMessageReadStateWithMsg:data];
                QIMVerboseLog(@"移除已读未读状态时间戳");
                [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetSingleReadFlagError];
            } else {
                if (errcode == 5000) {
                    [self updateRemoteLoginKey];
                }
                QIMErrorLog(@"请求消息阅读状态失败，失败原因: %@", [result objectForKey:@"errmsg"]);
                QIMVerboseLog(@"重新设置已读未读状态时间戳");
                [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleReadFlagMsgTime) forKey:kGetSingleReadFlagError];
            }
        } else {
            QIMErrorLog(@"请求消息阅读状态失败了");
            QIMVerboseLog(@"重新设置已读未读状态时间戳");
            [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleReadFlagMsgTime) forKey:kGetSingleReadFlagError];
        }
    } failure:^(NSError *error) {
        
    }];
}

#warning 这里更新本地数据库已接收的消息状态 ，告诉对方已送达，readFlag=3，更新成功之后更新本地数据库状态
- (void)sendRecevieMessageState {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *msgs = [[IMDataManager sharedInstance] getReceiveMsgIdListWithMsgState:QIMMessageType_None WithReceiveDirection:MessageDirection_Received];
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
                BOOL isSuccess = [[XmppImManager sharedInstance] sendReadStateWithMessagesIdArray:jsonString WithXmppid:xmppId WithTo:xmppId WithReadFlag:MessageReadFlagDidSend];
                if (isSuccess) {
                    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_NotRead ByMsgIdList:resultArray];
                } else {
                    [faildArray addObject:jsonString];
                }
            }
        }
    });
}

- (BOOL)updateOfflineMessagesV2 {
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
                self.lastSingleMsgTime = [[NSDate date] timeIntervalSince1970] - 3600 * 24 * 2;
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
                        NSMutableDictionary *msgList = [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:chatlog to:[self getLastJid] WithDidReadState:MessageState_didRead];
                        for (NSString *key in [msgList allKeys]) {
                            //                        int notReadCount = [self getNotReadMsgCountByJid:key];
                            NSDictionary *value = [msgList objectForKey:key];
                            BOOL isConsult = [[value objectForKey:@"Consult"] boolValue];
                            NSString *userId = [value objectForKey:@"UserId"];
                            NSString *realJid = [value objectForKey:@"RealJid"];
                            ChatType chatType = [[value objectForKey:@"ChatType"] intValue];
                            NSArray *msgs = [value objectForKey:@"msgList"];
                            long long msgTime = [[value objectForKey:@"lastDate"] longLongValue];
                            if (self.lastSingleMsgTime < msgTime) {
                                self.lastSingleMsgTime = msgTime;
                            }
                            BOOL isSystem = NO;
                            if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
                                if ([key hasPrefix:@"rbt-system"] || [key hasPrefix:@"rbt-notice"] || [key hasPrefix:@"rbt-qiangdan"] || [key hasPrefix:@"rbt-zhongbao"]) {
                                    isSystem = YES;
                                }
                            }
                            if (isConsult) {
                                
                                [self addConsultSessionById:userId ByRealJid:realJid WithUserId:userId ByMsgId:nil WithOpen:NO WithLastUpdateTime:msgTime WithChatType:chatType];
                            } else {
                                if ([key containsString:@"collection_rbt"]) {
                                    [self addSessionByType:ChatType_CollectionChat
                                                      ById:key
                                                   ByMsgId:nil
                                               WithMsgTime:msgTime
                                            WithNeedUpdate:NO];
                                } else {
                                    [self addSessionByType:isSystem ? ChatType_System : ChatType_SingleChat
                                                      ById:key
                                                   ByMsgId:nil
                                               WithMsgTime:msgTime
                                            WithNeedUpdate:YES];
                                }
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOfflineMessageUpdate object:key userInfo:nil];
                            });
                        }
                    }
                }
            }
        } while (!isSuccess && retryCount < 3);
    } while (self.latestSingleMessageFlag);
    if (!isSuccess) {
        return NO;
        QIMVerboseLog(@"插入单人历史失败");
    }
    return YES;
}

- (NSArray *)getUserChatlogSince:(NSTimeInterval)lastChatTime success:(BOOL *)flag timeOut:(NSTimeInterval)timeOut {
    
    NSArray *msgList = [[NSArray alloc] init];
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
            time = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 2) * 1000;
        }
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
                    }
                } else {
                    if (errCode == 5000) {
                        [self updateRemoteLoginKey];
                    }
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
        }
        
        if (*flag == NO) {
            if (self.lastSingleMsgTime) {
                QIMVerboseLog(@"本地set单人错误时间戳为: %f", self.lastSingleMsgTime);
                [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSingleMsgTime) forKey:kGetSingleHistoryMsgError];
            } else {
                QIMVerboseLog(@"本地remove单人错误时间戳");
                [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetSingleHistoryMsgError];
            }
        } else {
            QIMVerboseLog(@"本地remove单人错误时间戳");
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetSingleHistoryMsgError];
        }
    }
    return msgList;
}

#warning 单人聊天消息

#pragma mark - 单人ConsultServer消息（下拉加载） qchatId = 5

- (NSArray *)getConsultServerlogWithFrom:(NSString *)from virtualId:(NSString *)virtualId to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction {
    
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
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:cookieProperties];
    [request appendPostData:requestData];
    
    [request startSynchronous];
    NSError *error = [request error];
    NSDictionary *result = nil;
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSArray *msgList = [result objectForKey:@"data"];
            return msgList;
        }
    }
    return msgList;
}

#pragma mark - 单人历史消息（下拉加载）

- (NSArray *)getUserChatlogWithFrom:(NSString *)from to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction {
    
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
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmsgs.qunar?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@&f=t",
                         [[QIMNavConfigManager sharedInstance] javaurl],
                         [[XmppImManager sharedInstance] domain],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         self.remoteKey,
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:cookieProperties];
    [request appendPostData:requestData];
    
    [request startSynchronous];
    NSError *error = [request error];
    NSDictionary *result = nil;
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSArray *msgList = [result objectForKey:@"data"];
            return msgList;
        }
    }
    return nil;
}

@end
