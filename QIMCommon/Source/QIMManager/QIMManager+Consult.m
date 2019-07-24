
//
//  QIMManager+Consult.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "QIMManager+Consult.h"
#import <objc/runtime.h>

@implementation QIMManager (Consult)

#pragma mark - setter and getter
/*
- (void)setVirtualRealJidDic:(NSMutableDictionary *)virtualRealJidDic {
    objc_setAssociatedObject(self, "virtualRealJidDic", virtualRealJidDic, OBJC_ASSOCIATION_COPY);
}

- (NSMutableDictionary *)virtualRealJidDic {
    NSMutableDictionary *virtualRealJidDic = objc_getAssociatedObject(self, "virtualRealJidDic");
    if (!virtualRealJidDic) {
        virtualRealJidDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return virtualRealJidDic;
}
*/

/*
- (void)setVirtualList:(NSArray *)virtualList {
    objc_setAssociatedObject(self, "virtualList", virtualList, OBJC_ASSOCIATION_COPY);
}

- (NSArray *)getVirtualList{
    
    NSArray *virtualList = [NSArray array];
    if (!virtualList) {
        virtualList = [[XmppImManager sharedInstance] getVirtualList];
    }
    return virtualList;
}

*/

- (void)setVirtualDic:(NSDictionary *)virtualDic {
    objc_setAssociatedObject(self, "virtualDic", virtualDic, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)getVirtualDic {
    NSDictionary *virtualDic = objc_getAssociatedObject(self, "virtualDic");
    if (!virtualDic) {
        virtualDic = [NSDictionary dictionary];
    }
    return virtualDic;
}

- (void)setMyhotLinelist:(NSArray *)myhotLinelist {
    objc_setAssociatedObject(self, "myhotLinelist", myhotLinelist, OBJC_ASSOCIATION_COPY);
}

- (NSArray *)getMyhotLinelist {
    NSArray *myhotLinelist = objc_getAssociatedObject(self, "myhotLinelist");
    if (!myhotLinelist) {
        myhotLinelist = [NSArray array];
    }
    return myhotLinelist;
}

- (QIMMessageModel *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType {
    QIMMessageModel *message = [QIMMessageModel new];
    [message setMessageId:msgId];
    [message setFrom:[self getLastJid]];
    [message setRealFrom:[self getLastJid]];
    [message setTo:toJid];
    [message setRealTo:realToJid];
    [message setMessageDirection:QIMMessageDirection_Sent];
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setExtendInformation:info];
    [message setMessageSendState:QIMMessageSendState_Waiting];
    [message setMessageDate:([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff)*1000];
    
    NSString *sid = nil;
    if (chatType == ChatType_Consult) {
        [message setRealJid:toJid];
        sid = [NSString stringWithFormat:@"%@-%@",toJid,toJid];
    } else {
        [message setRealJid:realToJid];
        sid = [NSString stringWithFormat:@"%@-%@",toJid,realToJid];
    }
    if (msgType != QIMMessageType_TransChatToCustomer_Feedback && msgType != QIMMessageType_TransChatToCustomerService_Feedback && msgType != QIMMessageType_TransChatToCustomerService) {
        [self saveMsg:message ByJid:toJid];
    }
    
    [self saveMsg:message ByJid:toJid];
    NSString *msgRaw = nil;
    NSString *channelInfo = nil;
    
    if (msgType == QIMMessageType_TransChatToCustomer || msgType == QIMMessageType_TransChatToCustomer_Feedback) {
        channelInfo = @"{\"cn\":\"consult\",\"d\":\"send\",\"userType\":\"usr\"}";
    } else {
        channelInfo = @"{\"cn\":\"consult\",\"d\":\"send\",\"userType\":\"common\"}";
    }
    NSDictionary *userAppendInfoDic = [self getAppendInfoForUserId:sid];
    [[XmppImManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:toJid realToJid:realToJid realFromJid:[self getLastJid] channelInfo:channelInfo WithAppendInfoDict:userAppendInfoDic chatId:[NSString stringWithFormat:@"%d",chatType] WithMsgTYpe:msgType OutMsgRaw:&msgRaw];
    
    if (chatType == ChatType_Consult) {
        [self addConsultSessionById:toJid ByRealJid:toJid WithUserId:realToJid ByMsgId:message.messageId WithOpen:NO WithLastUpdateTime:message.messageDate WithChatType:ChatType_Consult];
    } else {
        [self addConsultSessionById:toJid ByRealJid:realToJid WithUserId:realToJid ByMsgId:message.messageId WithOpen:NO WithLastUpdateTime:message.messageDate WithChatType:ChatType_ConsultServer];
    }
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msgId WithMsgRaw:msgRaw];
    }
    return message;
}

- (void)customerConsultServicesayHelloWithUser:(NSString *)user WithVirtualId:(NSString *)virtualId WithFromUser:(NSString *)fromUser{
    NSString *host = @"http://qcadmin.qunar.com";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/notice/sayHello.json?userQName=%@&seatQName=%@&virtualId=%@&line=dujia&u=%@&k=%@&p=iphone&v=%@",host,user,fromUser,virtualId,[QIMManager getLastUserName],self.remoteKey,[[QIMAppInfo sharedInstance] AppBuildVersion]]];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setTimeoutInterval:1];
    [QIMHTTPClient sendRequest:request complete:nil failure:nil];
}

- (void)customerServicesayHelloWithUser:(NSString *)user{
    NSString *host = @"http://qcadmin.qunar.com";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/notice/sayHello.json?userQName=%@&seatQName=%@&line=dujia&u=%@&k=%@&p=iphone&v=%@",host,user,[QIMManager getLastUserName],[QIMManager getLastUserName],self.remoteKey,[[QIMAppInfo sharedInstance] AppBuildVersion]]];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setTimeoutInterval:1];
    [QIMHTTPClient sendRequest:request complete:nil failure:nil];
}

- (NSArray *)searchSuggestWithKeyword:(NSString *)keyword{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/supplier/name/suggest.json?qunarName=%@&query=%@&u=%@&k=%@&p=iphone&v=%@",[[QIMNavConfigManager sharedInstance] qcHost],[QIMManager getLastUserName],[keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[QIMManager getLastUserName],self.remoteKey,[[QIMAppInfo sharedInstance] AppBuildVersion]]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:1];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[infoDic objectForKey:@"ret"] boolValue];
        if (ret) {
            return [infoDic objectForKey:@"data"];
        }
    }
    return nil;
}

- (NSArray *)getSuggestOrganizationBySuggestId:(NSString *)suggestId{
    NSString *host = @"http://qcadmin.qunar.com";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/supplier/organization.json?qunarName=%@&id=%@&u=%@&k=%@&p=iphone&v=%@",host,[QIMManager getLastUserName],suggestId,[QIMManager getLastUserName], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]]];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:1];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[infoDic objectForKey:@"ret"] boolValue];
        if (ret) {
            return [infoDic objectForKey:@"data"];
        }
    }
    return nil;
}

- (NSDictionary *)getBusinessInfoByBusinessId:(NSString *)businessId {
    
    NSURL *url = nil;
    if ([QIMNavConfigManager sharedInstance].debug) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/seat/judgmentOrRedistribution.json?shopId=%@",@"https://qcadminbeta.qunar.com",businessId]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/seat/judgmentOrRedistribution.json?shopId=%@",@"https://qcadmin.qunar.com",businessId]];
    }
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:1];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[infoDic objectForKey:@"ret"] boolValue];
        if (ret) {
            return [infoDic objectForKey:@"data"];
        }
    }
    return nil;
}

- (void)getHotlineShopList {
    NSString *destUrl = [NSString stringWithFormat:@"%@/qcadmin/getHotlineShopList.qunar?line=%@&username=%@&host=%@", [[QIMNavConfigManager sharedInstance] newerHttpUrl], @"qtalk", [QIMManager getLastUserName], [[QIMManager sharedInstance] getDomain]];
    __weak __typeof(self) weakSelf = self;
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *allhotlines = [data objectForKey:@"allhotlines"];
                NSArray *myhotlines = [data objectForKey:@"myhotlines"];
                __typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                strongSelf.virtualDic = [NSDictionary dictionaryWithDictionary:allhotlines];
                strongSelf.myhotLinelist = myhotlines;
                NSLog(@"getHotlineShopList.qunar : %@", data);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

//V2版获取客服坐席列表：支持多店铺
- (NSArray *)getSeatSeStatus {
    NSString *urlHost = nil;
    if ([[QIMNavConfigManager sharedInstance] debug]) {
        urlHost = @"https://qcadminbeta.qunar.com";
    } else {
        urlHost = @"https://qcadmin.qunar.com";
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/seat/getSeatSeStatusWithSid.qunar", urlHost]];
    NSString *postDataStr = [NSString stringWithFormat:@"qName=%@", [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableData *postData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resDic objectForKey:@"ret"] boolValue];
        if (ret) {
            NSArray *data = [resDic objectForKey:@"data"];
            if (data.count > 0) {
                return data;
            }
        }
    }
    return nil;
}

//V2版区别Shop来设置服务模式upSeatSeStatusWithSid.qunar
- (BOOL)updateSeatSeStatusWithShopId:(NSInteger)shopId WithStatus:(NSInteger)shopServiceStatus {
    NSString *urlHost = nil;
    if ([[QIMNavConfigManager sharedInstance] debug]) {
        urlHost = @"https://qcadminbeta.qunar.com";
    } else {
        urlHost = @"https://qcadmin.qunar.com";
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/seat/upSeatSeStatusWithSid.qunar", urlHost]];
    NSString *postDataStr = [NSString stringWithFormat:@"qName=%@&st=%ld&sid=%ld", [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], shopServiceStatus, shopId];
    NSMutableData *postData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:postData];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resDic objectForKey:@"ret"] boolValue];
        return ret;
    }
    return NO;
}

- (NSDictionary *)userSeatStatusDict:(int)userStatus {
    
    NSDictionary *userStatusDict = nil;
    for (NSDictionary *dict in [[QIMManager sharedInstance] availableUserSeatStatus]) {
        int status = [[dict objectForKey:@"Status"] intValue];
        if (userStatus == status) {
            userStatusDict = dict;
        }
    }
    return userStatusDict;
}

- (NSString *)userStatusTitleWithStatus:(int)userStatus {
    NSString *statusTitlt = nil;
    for (NSDictionary *dict in [[QIMManager sharedInstance] availableUserSeatStatus]) {
        int status = [[dict objectForKey:@"Status"] intValue];
        if (userStatus == status) {
            statusTitlt = [dict objectForKey:@"StatusTitle"];
        }
    }
    return statusTitlt;
}

- (NSArray *)availableUserSeatStatus {
    
    NSArray *serviceStatus = @[@{@"StatusTitle":@"标准模式", @"StatusDesc":@"（在线时才接收咨询，默认）", @"Status":@(0)}, @{@"StatusTitle":@"超人模式", @"StatusDesc":@"（不在线也接受咨询）", @"Status":@(4)}, @{@"StatusTitle":@"勿扰模式", @"StatusDesc":@"（在线也不接受咨询）", @"Status":@(1)}];
    return serviceStatus;
}

- (void)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId withBlock:(QIMCloseSessionBlock)block{
    
    if (!shopId.length || !visitorId.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(nil);
            }
        });
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/admin/api/seat/closeSession.qunar?userName=%@&seatName=%@&virtualname=%@", [[QIMNavConfigManager sharedInstance] javaurl], visitorId, [[QIMManager sharedInstance] getLastJid], shopId];
    [self sendTPPOSTRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSString *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSString class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) {
                        block(data);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:virtualId WithRealJid:userId WithLimit:limit WithOffset:offset];
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
                    long long version = [[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:virtualId RealJid:userId] - timeChange;
                    
                    NSArray *result = [self getConsultServerlogWithFrom:[self getLastJid] virtualId:virtualId to:userId version:version count:(int)(limit - list.count) direction:QIMMessageDirection_Sent];
                    if (result.count > 0) {
                        [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:result];
                    }
                });
            }
        } else {
            if (loadMore == YES) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:virtualId RealJid:userId] - timeChange;
                    NSArray *resultList = [self getConsultServerlogWithFrom:[self getLastJid] virtualId:virtualId to:userId version:version count:limit direction:QIMMessageDirection_Sent];
                    
                    if (resultList.count > 0) {
                        [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertHistoryChatJSONMsg:resultList];
                        NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:virtualId WithRealJid:userId WithLimit:limit WithOffset:offset];
                        NSMutableArray *list = [NSMutableArray array];
                        for (NSDictionary *infoDic in datas) {
                            QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                            /*
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
                             [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                             */
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
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(@[]);
                });
            }
        }
    });
}

@end
