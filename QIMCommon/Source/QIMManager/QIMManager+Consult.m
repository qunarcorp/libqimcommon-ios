
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

- (Message *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType {
    Message *message = [Message new];
    [message setMessageId:msgId];
    [message setFrom:[self getLastJid]];
    [message setRealFrom:[self getLastJid]];
    [message setTo:toJid];
    [message setRealTo:realToJid];
    [message setMessageDirection:MessageDirection_Sent];
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setExtendInformation:info];
    [message setMessageState:MessageState_Waiting];
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
        [[IMDataManager sharedInstance] updateMessageWithMsgId:msgId WithMsgRaw:msgRaw];
    }
    return message;
}


- (void)chatTransferTo:(NSString *)user message:(NSString *)message chatId:(NSString *)chatId {
    
    [[XmppImManager sharedInstance] chatTransferTo:user message:message chatId:chatId];
}

- (void)chatTransferFrom:(NSString *)from To:(NSString *)to User:(NSString *)user Reson:(NSString *)reson chatId:(NSString *)chatId WithMsgId:(NSString *)msgId {
    
    [[XmppImManager sharedInstance] chatTransferFrom:from To:to User:user Reson:reson chatId:chatId WithMsgId:msgId];
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

- (NSString *)getRealJidForVirtual:(NSString *)virtualJid{
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        NSString *realJid = [self.virtualRealJidDic objectForKey:virtualJid];
        if (realJid == nil) {
            NSDictionary *result = [self getBusinessInfoByBusinessId:virtualJid];
            realJid = [[[result objectForKey:@"seat"] objectForKey:@"qunarName"] stringByAppendingFormat:@"@%@",[self getDomain]];
            [self.virtualRealJidDic setQIMSafeObject:realJid forKey:virtualJid];
        }
        return realJid;
    } else {
        NSString *realJid = [self.virtualRealJidDic objectForKey:virtualJid];
        if (realJid == nil) {
            realJid = [[XmppImManager sharedInstance] getRealJidForVirtual:virtualJid];
            [self.virtualRealJidDic setQIMSafeObject:realJid forKey:virtualJid];
        }
        return realJid;
    }
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

- (NSString *)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId {
    
    if (!shopId.length || !visitorId.length) {
        return nil;
    }
    shopId = [[shopId componentsSeparatedByString:@"@"] firstObject];
    NSString *destUrl = [NSString stringWithFormat:@"%@/admin/api/seat/closeSession.qunar?userName=%@&seatName=%@&virtualname=%@", [[QIMNavConfigManager sharedInstance] javaurl], visitorId, [[QIMManager sharedInstance] getLastJid], shopId];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    [request setUseCookiePersistence:NO];
    [request startSynchronous];
    NSError *error = request.error;
    if (!error && [request responseStatusCode] == 200) {
        NSData *responseData = [request responseData];
        NSDictionary *responseDict = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDict objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *promotMsg = [responseDict objectForKey:@"data"];
            return promotMsg;
        }
    }
    return nil;
}


@end
