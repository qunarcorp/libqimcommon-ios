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
    QIMVerboseLog(@"更新本地群消息时间戳");
    long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 2) * 1000;
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetGroupHistoryMsgError] longLongValue];
    if (errorTime > 0) {
        self.lastGroupMsgTime = errorTime;
        QIMVerboseLog(@"本地群消息错误时间戳 : %lld", errorTime);
    } else {
        self.lastGroupMsgTime = [[IMDataManager sharedInstance] lastestGroupMessageTime];
    }
    if (self.lastGroupMsgTime == 0) {
        self.lastGroupMsgTime = defaultTime;
    }
    QIMVerboseLog(@"强制塞本地群消息时间戳到为 kGetGroupHistoryMsgError : %f", self.lastGroupMsgTime);
    [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetGroupHistoryMsgError];
    QIMVerboseLog(@"强制塞本地群消息时间戳到为 kGetGroupHistoryMsgError : %f完成", self.lastGroupMsgTime);
    
    QIMVerboseLog(@"强制塞本地群消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetGroupHistoryMsgError] longLongValue]);

    QIMVerboseLog(@"最终获取到的本地群最后消息时间戳为 : %f", self.lastGroupMsgTime);
}

- (void)updateLastMaxMucReadMarkTime {
    QIMVerboseLog(@"更新本地群阅读指针时间戳");
    long long maxMucReadMarkUpdateTime = [[[IMDataManager sharedInstance] qimDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalMucRemarkUpdateTime] WithSubKey:[[QIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
    self.lastMaxMucReadMarkTime = maxMucReadMarkUpdateTime;
    QIMVerboseLog(@"最终获取到的本地群阅读指针最后消息时间戳为 : %f", self.lastMaxMucReadMarkTime);
}

- (void)checkGroupChatMsg {
    long long errorTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetGroupHistoryMsgError] longLongValue];
    QIMVerboseLog(@"检查本地是否有群消息错误时间戳 : %lld", errorTime);
    if (errorTime > 0) {
        [self updateOfflineGroupMessages];
    }
}

- (void)updateOfflineGroupMessages {
    QIMVerboseLog(@"updateOfflineGroupMessages");
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
            if (retryCount > 3) {
                QIMWarnLog(@"重试超过三次，结束请求群历史记录");
                self.latestGroupMessageFlag = NO;
            }
        } while (!getMucHistotySuccess && retryCount < 3);
    } while (self.latestGroupMessageFlag);
    if (!getMucHistotySuccess) {
        return;
    }
    QIMVerboseLog(@"获取群历史记录完成");
}

//拉取离线群历史记录
- (BOOL)getMucHistoryV2WithTimeOut:(NSTimeInterval)timeOut {

    if (!self.remoteKey) {
        [self updateRemoteLoginKey];
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
            self.lastGroupMsgTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 2) * 1000;
        }
        long long lastMsgTime = self.lastGroupMsgTime;
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
        [request setUseCookiePersistence:NO];
        [request setRequestHeaders:cookieProperties];
        [request appendPostData:data];
        [request startSynchronous];
        NSError *error = [request error];
        NSDictionary *result = nil;
        if ([request responseStatusCode] == 200 && !error) {
            NSData *responseData = [request responseData];
            result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        } else {
            QIMErrorLog(@"获取群历史记录失败了了了 : %@, [request responseStatusCode] : %d", error, [request responseStatusCode]);
        }
        
        int errCode = [[result objectForKey:@"errcode"] intValue];
        if (errCode == 0) {
            NSArray *data = [result objectForKey:@"data"];
            QIMVerboseLog(@"获取群历史记录成功。 : %lu", (unsigned long)data.count);
            if (data.count >= DEFAULT_GROUPMSG_NUM) {
                self.latestGroupMessageFlag = YES;
            } else {
                self.latestGroupMessageFlag = NO;
            }
            QIMVerboseLog(@"是否还要继续拉取群离线消息 : %d", self.latestGroupMessageFlag);
            [self dealWithGroupMsg:data];
            getMucHistorySuccess = YES;
        } else {
            if (errCode == 5000) {
                [self updateRemoteLoginKey];
            }
            QIMErrorLog(@"获取群历史记录失败,ErrMsg:%@", result);
        }
        if (getMucHistorySuccess == NO) {
            if (self.lastGroupMsgTime) {
                QIMWarnLog(@"set本地群最后消息时间戳为 : %lf", self.lastGroupMsgTime);
                [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetGroupHistoryMsgError];
            } else {
                QIMWarnLog(@"remove本地群最后消息时间戳");
                [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetGroupHistoryMsgError];
            }
        } else {
            QIMVerboseLog(@"remove本地群最后消息时间戳");
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetGroupHistoryMsgError];
        }
    }
    return getMucHistorySuccess;
}

- (void)backupErrorGroupMsgWithFlag:(BOOL)flag {
    if (flag == NO) {
        if (self.lastGroupMsgTime) {
            QIMVerboseLog(@"set本地群最后消息时间戳为 : %lf", self.lastGroupMsgTime);
            [[QIMUserCacheManager sharedInstance] setUserObject:@(self.lastGroupMsgTime) forKey:kGetGroupHistoryMsgError];
        } else {
            QIMVerboseLog(@"remove本地群最后消息时间戳");
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetGroupHistoryMsgError];
        }
    } else {
        QIMVerboseLog(@"remove本地群最后消息时间戳");
        [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetGroupHistoryMsgError];
    }
}

- (void)dealWithGroupMsg:(NSArray * _Nonnull)data {
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    if (data.count > 0) {
        NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
        NSMutableArray <NSDictionary *>*atAllMsgList = [[NSMutableArray alloc] initWithCapacity:3];
        NSMutableArray <NSDictionary *>*normalMsgList = [[NSMutableArray alloc] initWithCapacity:3];
        NSDictionary *tempGroupDic = [[IMDataManager sharedInstance] bulkInsertIphoneHistoryGroupJSONMsg:data WihtMyNickName:[self getMyNickName] WihtSupportMsgTypes:msgTypeList WithReadMarkT:0 WithDidReadState:MessageState_NotRead WihtMyRtxId:[[QIMManager sharedInstance] getLastJid] WithAtAllMsgList:&atAllMsgList WithNormaleAtMsgList:&normalMsgList];
        for (NSString *groupId in tempGroupDic) {
            if (groupId.length > 0) {
                NSDictionary *groupMsgDic = [tempGroupDic objectForKey:groupId];
                Message *msg = [Message new];
                [msg setMessageId:[groupMsgDic objectForKey:@"MsgId"]];
                [msg setFrom:[groupMsgDic objectForKey:@"From"]];
                [msg setTo:[groupMsgDic objectForKey:@"To"]];
                [msg setMessage:[groupMsgDic objectForKey:@"Content"]];
                NSString *extendInfo = [groupMsgDic objectForKey:@"ExtendInfo"];
                [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                [msg setPlatform:[[groupMsgDic objectForKey:@"Platform"] intValue]];
                [msg setMessageType:[[groupMsgDic objectForKey:@"MsgType"] intValue]];
                [msg setMessageState:[[groupMsgDic objectForKey:@"MsgState"] intValue]];
                [msg setMessageDirection:[[groupMsgDic objectForKey:@"MsgDirection"] intValue]];
                [msg setMessageDate:[[groupMsgDic objectForKey:@"MsgDateTime"] longLongValue]];
                [msg setPropress:[[groupMsgDic objectForKey:@"ExtendedFlag"] floatValue]];
                [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:msg.messageId WithMsgTime:msg.messageDate WithNeedUpdate:YES];
                if (self.lastGroupMsgTime < [[groupMsgDic objectForKey:@"MsgDateTime"] longLongValue]) {
                    self.lastGroupMsgTime = [[groupMsgDic objectForKey:@"MsgDateTime"] longLongValue];
                }
            }
        }
        for (NSDictionary *infoDic in atAllMsgList) {
            NSString *groupId = [infoDic objectForKey:@"SessionId"];
            Message *msg = [Message new];
            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
            [msg setFrom:[infoDic objectForKey:@"From"]];
            [msg setTo:[infoDic objectForKey:@"To"]];
            [msg setMessage:[infoDic objectForKey:@"Content"]];
            NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
            [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
            [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
            [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
            
            [self addAtALLByJid:groupId WithMsgId:msg.messageId WihtMsg:msg WithNickName:msg.from];
        }
        for (NSDictionary *infoDic in normalMsgList) {
            NSString *groupId = [infoDic objectForKey:@"SessionId"];
            Message *msg = [Message new];
            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
            [msg setFrom:[infoDic objectForKey:@"From"]];
            [msg setTo:[infoDic objectForKey:@"To"]];
            [msg setMessage:[infoDic objectForKey:@"Content"]];
            NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
            [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
            [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
            [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
            [self addAtMeByJid:groupId WithNickName:msg.from];
        }
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"处理群离线消息历史记录%ld条，耗时%fs", data.count, end - start); //s
}

//拉取群翻页历史记录
- (NSArray *)getMucMsgListWihtGroupId:(NSString *)groupId WithDirection:(int)direction WithLimit:(int)limit WithVersion:(long long)version {
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
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/getmucmsgs.qunar?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] javaurl], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    QIMVerboseLog(@"JSON请求群翻页历史记录URL为:%@", destUrl);
    QIMVerboseLog(@"JSON请求群翻页历史记录参数为:%@", params);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json" forKey:@"Content-type"];
    [request setRequestHeaders:cookieProperties];
    QIMVerboseLog(@"JSON请求群翻页历史记录 Ckey 为:%@", cookieProperties);
    [request appendPostData:requestData];

    [request startSynchronous];
    NSError *error = [request error];
    NSDictionary *result = nil;
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            return [result objectForKey:@"data"];
        }
    }
    return nil;
}

//更新群阅读指针
- (void)updateMucReadMark {
    if (!self.remoteKey) {
        [self updateRemoteLoginKey];
    }
    __block BOOL getMucReadMarkSuccess = NO;
    NSString *jid = [QIMManager getLastUserName];
    if ([jid length] > 0) {
        [[QIMWatchDog sharedInstance] start];
        
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
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        QIMVerboseLog(@"JSON请求群ReadMark阅读指针Ckey为 : %@", cookieProperties);
        
        QIMHTTPRequest *request = [QIMHTTPRequest requestWithURL:[NSURL URLWithString:destUrl]];
        request.HTTPMethod = QIMHTTPMethodPOST;
        request.HTTPBody = data;
        request.HTTPRequestHeaders = cookieProperties;
        __block NSDictionary *result = nil;
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
             QIMVerboseLog(@"获取群阅读指针结果 : %@", response);
             if (response.code != 200) {
                 result;
             }
             result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
             BOOL errcode = [[result objectForKey:@"ret"] boolValue];
             NSString *errmsg = [result objectForKey:@"errmsg"];
             if (errcode != 0) {
                 NSMutableArray *mucData = [result objectForKey:@"data"];
             
                 long long maxMucReadMarkTime = [[IMDataManager sharedInstance] qimDB_bulkUpdateGroupMessageReadFlag:mucData];
                 if (maxMucReadMarkTime > self.lastMaxMucReadMarkTime) {
                     NSString *jid = [[QIMManager sharedInstance] getLastJid];
                     NSString *updateTime = [NSString stringWithFormat:@"%lld", maxMucReadMarkTime];
                     NSArray *configArray = @[@{@"subkey":jid?jid:@"", @"configinfo":updateTime}];
                     [[IMDataManager sharedInstance] qimDB_bulkInsertConfigArrayWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalMucRemarkUpdateTime] WithConfigVersion:0 ConfigArray:configArray];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     QIMVerboseLog(@"获取群阅读指针之后强制刷新NavBar未读数");
                     [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@"ForceRefresh"];
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
