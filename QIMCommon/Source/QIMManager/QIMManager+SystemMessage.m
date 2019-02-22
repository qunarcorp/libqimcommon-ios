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
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSystemHistoryMsgError] longLongValue];
    QIMVerboseLog(@"检查本地是否有系统消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineSystemNoticeMessages];
    }
}

- (void)updateLastSystemMsgTime {
    QIMVerboseLog(@"更新本地HeadLine消息时间戳");
    long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 2) * 1000;
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSystemHistoryMsgError] longLongValue];
    if (errorTime > 0) {
        self.lastSystemMsgTime = errorTime;
        QIMVerboseLog(@"本地HeadLine消息错误时间戳 : %lld", errorTime);
    } else {
        self.lastSystemMsgTime = [[IMDataManager sharedInstance] lastestSystemMessageTime];
    }
    if (self.lastSystemMsgTime == 0) {
        self.lastSystemMsgTime = defaultTime;
    }
    QIMVerboseLog(@"强制塞本地HeadLine消息时间戳到为 kGetSystemHistoryMsgError : %f", self.lastSystemMsgTime);
    [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastSystemMsgTime) forKey:kGetSystemHistoryMsgError];
    QIMVerboseLog(@"强制塞本地HeadLine消息时间戳到为 kGetSystemHistoryMsgError : %f完成", self.lastSystemMsgTime);
    QIMVerboseLog(@"强制塞本地HeadLine消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetSystemHistoryMsgError] longLongValue]);

    QIMVerboseLog(@"最终获取到的本地HeadLine最后消息时间戳为 : %lf", self.lastSystemMsgTime);
}

- (void)updateOfflineSystemNoticeMessages {

    if (self.remoteKey.length <= 0) {
        [self updateRemoteLoginKey];
    }
    NSString *from = @"SystemMessage";
    [self getSystemMsgHistoryListWithUserId:from WithDomain:[[QIMManager sharedInstance] getDomain] WithVersion:self.lastSingleMsgTime];
}

- (void)getSystemMsgLisByUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:userId WithRealJid:nil WithLimit:limit WihtOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
            for (NSDictionary *infoDic in array) {
                Message *msg = [Message new];
                [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                [msg setFrom:[infoDic objectForKey:@"From"]];
                [msg setNickName:[infoDic objectForKey:@"From"]];
                [msg setTo:[infoDic objectForKey:@"To"]];
                [msg setMessage:[infoDic objectForKey:@"Content"]];
                [msg setExtendInformation:[infoDic objectForKey:@"ExtendInfo"]];
                [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
                [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
                [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
            if (list.count < limit) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:userId] - timeChange;
                    
                    NSArray *result = [self getSystemMsgListWithDirection:0 WithUserId:userId WithFromHost:fromHost WithLimit:limit - list.count withTimeVersion:version toId:[QIMManager getLastUserName] toHost:fromHost];
                    if (result.count > 0) {
                        NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                        [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:result to:[QIMManager getLastUserName] WithDidReadState:MessageState_didRead];
                    }
                });
            }
        } else {
            if (self.load_history_msg == nil) {
                self.load_history_msg = dispatch_queue_create("Load History", 0);
            }
            dispatch_async(self.load_history_msg, ^{
                long long version = [[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:userId] - timeChange;
                NSArray *resultList = [self getSystemMsgListWithDirection:0 WithUserId:userId WithFromHost:fromHost WithLimit:limit withTimeVersion:version toId:[QIMManager getLastUserName] toHost:fromHost];
                if (resultList.count > 0) {
                    NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                    [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:resultList to:[QIMManager getLastUserName] WithDidReadState:MessageState_didRead];
                    NSArray *datas = [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:userId WithRealJid:nil WithLimit:(int)(resultList.count) WihtOffset:offset];
                    NSMutableArray *list = [NSMutableArray array];
                    for (NSDictionary *infoDic in datas) {
                        Message *msg = [Message new];
                        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                        [msg setFrom:[infoDic objectForKey:@"From"]];
                        [msg setTo:[infoDic objectForKey:@"To"]];
                        [msg setMessage:[infoDic objectForKey:@"Content"]];
                        [msg setExtendInformation:[infoDic objectForKey:@"ExtendInfo"]];
                        [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                        [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                        [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                        [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                        [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                        [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                        [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
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
            });
        }
    });
}

#pragma mark -  获取Notice消息（下拉加载）
- (NSArray *)getSystemMsgListWithDirection:(int)direction WithUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(NSInteger)limit withTimeVersion:(long long)version toId:(NSString *)toId toHost:(NSString *)toHost {
    
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
    /*
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userId forKey:@"user"];
    [params setObject:@(version) forKey:@"time"];
    [params setObject:[self getDomain] forKey:@"domain"];
    [params setObject:[self getDomain] forKey:@"host"];
    [params setObject:@(limit) forKey:@"num"];
    [params setObject:@"t" forKey:@"f"];
    */
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/get_system_msgs.qunar?v=%@&p=iOS&u=%@&k=%@&f=t", [[QIMNavConfigManager sharedInstance] javaurl], [[QIMAppInfo sharedInstance] AppBuildVersion], [QIMManager getLastUserName], self.remoteKey];
    NSURL *requestUrl = [NSURL URLWithString:destUrl];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
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
            NSArray *msgArray = [result objectForKey:@"data"];
            return msgArray;
        }
    }
    return nil;
}


#pragma mark -  获取离线Notice消息
- (void)getSystemMsgHistoryListWithUserId:(NSString *)userId WithDomain:(NSString *)domain WithVersion:(long long)version {
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
    NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
    NSMutableDictionary *msgList = [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:systemMsgs to:[self getLastJid] WithDidReadState:MessageState_didRead];
    for (NSString *key in [msgList allKeys]) {
        NSDictionary *value = [msgList objectForKey:key];
        BOOL isConsult = [[value objectForKey:@"Consult"] boolValue];
        NSString *userId = [value objectForKey:@"UserId"];
        NSString *realJid = [value objectForKey:@"RealJid"];
        ChatType chatType = [[value objectForKey:@"ChatType"] intValue];
        NSArray *msgs = [value objectForKey:@"msgList"];
        long long msgTime = [[value objectForKey:@"lastDate"] longLongValue];
        NSString *msgId = nil;
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *infoDic in msgs) {
            Message *msg = [Message new];
            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
            [msg setFrom:[infoDic objectForKey:@"From"]];
            [msg setTo:[infoDic objectForKey:@"To"]];
            [msg setMessage:[infoDic objectForKey:@"Content"]];
            [msg setExtendInformation:[infoDic objectForKey:@"ExtendInfo"]];
            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
            [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
            [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
            [list addObject:msg];
        }
        [self addSessionByType:ChatType_System
                          ById:key
                       ByMsgId:msgId
                   WithMsgTime:msgTime
                WithNeedUpdate:NO];
    }
}


@end
