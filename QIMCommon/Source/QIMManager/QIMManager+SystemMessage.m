//
//  QIMManager+SystemMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager+SystemMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (SystemMessage)

#pragma mark - 系统消息

- (void)checkHeadlineMsg {
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSystemHistoryMsgError] longLongValue];
    QIMVerboseLog(@"检查本地是否有系统消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineSystemNoticeMessages];
    }
}

- (void)updateLastSystemMsgTime {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        QIMVerboseLog(@"更新本地HeadLine消息时间戳");
        long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
        long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSystemHistoryMsgError] longLongValue];
        if (errorTime > 0) {
            self.lastSystemMsgTime = errorTime;
            QIMVerboseLog(@"本地HeadLine消息错误时间戳 : %lld", errorTime);
        } else {
            self.lastSystemMsgTime = [[IMDataManager qimDB_SharedInstance] qimDB_lastestSystemMessageTime];
        }
        if (self.lastSystemMsgTime == 0) {
            self.lastSystemMsgTime = defaultTime;
        }
        QIMVerboseLog(@"强制塞本地HeadLine消息时间戳到为 kGetNewSystemHistoryMsgError : %f", self.lastSystemMsgTime);
        [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSystemMsgTime) forKey:kGetNewSystemHistoryMsgError];
        QIMVerboseLog(@"强制塞本地HeadLine消息时间戳到为 kGetNewSystemHistoryMsgError : %f完成", self.lastSystemMsgTime);
        QIMVerboseLog(@"强制塞本地HeadLine消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetNewSystemHistoryMsgError] longLongValue]);

        QIMVerboseLog(@"最终获取到的本地HeadLine最后消息时间戳为 : %lf", self.lastSystemMsgTime);
    });
}

- (void)updateOfflineSystemNoticeMessages {

    if (self.remoteKey.length <= 0) {
        [self updateRemoteLoginKey];
    }
    NSString *from = @"SystemMessage";
    [self getSystemMsgHistoryListWithUserId:from WithDomain:[[QIMManager sharedInstance] getDomain] WithVersion:self.lastSingleMsgTime];
}

- (void)getSystemMsgLisByUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:userId WithRealJid:userId WithLimit:limit WithOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
            for (NSDictionary *infoDic in array) {
                QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
            if (list.count < limit && loadMore == YES) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:userId] - timeChange;
                    
                    [self getSystemMsgListWithDirection:0 WithUserId:userId WithFromHost:fromHost WithLimit:limit - list.count withTimeVersion:version toId:[QIMManager getLastUserName] toHost:fromHost withCallBack:^(NSArray *result) {
                        if (result.count > 0) {
                            [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:result];
                        }
                    }];
                });
            }
        } else {
            if (loadMore == YES) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:userId] - timeChange;
                    [self getSystemMsgListWithDirection:0 WithUserId:userId WithFromHost:fromHost WithLimit:limit withTimeVersion:version toId:[QIMManager getLastUserName] toHost:fromHost withCallBack:^(NSArray *resultList) {
                        if (resultList.count > 0) {
                            [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:resultList];
                            NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:userId WithRealJid:nil WithLimit:(int)(resultList.count) WithOffset:offset];
                            NSMutableArray *list = [NSMutableArray array];
                            for (NSDictionary *infoDic in datas) {
                                QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                                [list addObject:msg];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                complete(list);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                complete(@[]);
                            });
                        }
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(@[]);
                });
            }
        }
    });
}

#pragma mark -  获取Notice消息（下拉加载）
- (void)getSystemMsgListWithDirection:(int)direction WithUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(NSInteger)limit withTimeVersion:(long long)version toId:(NSString *)toId toHost:(NSString *)toHost withCallBack:(QIMKitGetSystemMsgListCallBack)callback {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userId forKey:@"from"];
    [params setObject:toId forKey:@"to"];
    [params setObject:[NSString stringWithFormat:@"%d", direction] forKey:@"direction"];
    [params setObject:@(version) forKey:@"time"];
    [params setObject:[self getDomain] forKey:@"domain"];
    [params setObject:@(limit) forKey:@"num"];
    [params setObject:fromHost forKey:@"fhost"];
    [params setObject:toHost forKey:@"thost"];
    [params setObject:@"t" forKey:@"f"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/get_system_msgs.qunar?v=%@&p=iOS&u=%@&k=%@&f=t", [[QIMNavConfigManager sharedInstance] javaurl], [[QIMAppInfo sharedInstance] AppBuildVersion], [QIMManager getLastUserName], self.remoteKey];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:requestData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSArray *msgArray = [result objectForKey:@"data"];
            if (callback) {
                callback(msgArray);
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


#pragma mark -  获取离线Notice消息
- (void)getSystemMsgHistoryListWithUserId:(NSString *)userId WithDomain:(NSString *)domain WithVersion:(long long)version {
    __block CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userId forKey:@"user"];
    [params setObject:@(version) forKey:@"time"];
    [params setObject:[self getDomain] forKey:@"domain"];
    [params setObject:@(DEFAULT_CHATMSG_NUM) forKey:@"num"];
    [params setObject:@"t" forKey:@"f"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/get_system_history.qunar?v=%@&p=iOS&u=%@&k=%@&f=t", [[QIMNavConfigManager sharedInstance] javaurl], [[QIMAppInfo sharedInstance] AppBuildVersion], [QIMManager getLastUserName], self.remoteKey];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:requestData];
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        
        NSDictionary *logDic = @{@"costTime":@([[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]), @"reportTime":@([[NSDate date] timeIntervalSince1970]), @"threadName":@"", @"isMainThread":@([NSThread isMainThread]), @"url":destUrl, @"methodParams":params, @"requestHeaders":requestHeaders, @"describtion":@"请求HeadLine离线消息"};
        
        Class autoManager = NSClassFromString(@"QIMAutoTrackerManager");
        id autoManagerObject = [[autoManager alloc] init];
        [autoManagerObject performSelectorInBackground:@selector(addCATTraceData:) withObject:logDic];
        
        
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSArray *messages = [result objectForKey:@"data"];
                [strongSelf dealWithSystemMessages:messages];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)dealWithSystemMessages:(NSArray *)systemMsgs {
    if (systemMsgs.count <= 0) {
        return;
    }
    long long lastMaxTime = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:systemMsgs];
    if (lastMaxTime >= self.lastSystemMsgTime) {
        self.lastSystemMsgTime = lastMaxTime;
    }
}


@end
