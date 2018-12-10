//
//  QIMManager+PublicRobot.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#import "QIMManager+PublicRobot.h"
#import "QIMPinYinForObjc.h"
#import <objc/runtime.h>
#import "QIMPrivateHeader.h"

@implementation QIMManager (PublicRobot)

#pragma mark - setter and getter

- (void)setNotReadMsgByPublicNumberDic:(NSMutableDictionary *)notReadMsgByPublicNumberDic {
    objc_setAssociatedObject(self, "notReadMsgByPublicNumberDic", notReadMsgByPublicNumberDic,
                             OBJC_ASSOCIATION_COPY);
}

- (NSMutableDictionary *)notReadMsgByPublicNumberDic {
    NSMutableDictionary *notReadMsgByPublicNumberDic = objc_getAssociatedObject(self, "notReadMsgByPublicNumberDic");
    if (!notReadMsgByPublicNumberDic) {
        notReadMsgByPublicNumberDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return notReadMsgByPublicNumberDic;
}

- (int)getDealIdState:(NSString *)dealId {
    NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"kDealInfoDic"];
    
    return [[dic objectForKey:dealId] intValue];
}

- (void)setDealId:(NSString *)dealId ForState:(int)state {
    NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"kDealInfoDic"];
    NSMutableDictionary *dealDic = [NSMutableDictionary dictionary];
    if (dic) {
        [dealDic setDictionary:dic];
    }
    [dealDic setObject:@(state) forKey:dealId];
    [[QIMUserCacheManager sharedInstance] setUserObject:dealDic forKey:@"kDealInfoDic"];
}

#pragma mark - 公众号名片信息

- (UIImage *)getPublicNumberHeaderImageByFileName:(NSString *)fileName {
    UIImage *image = nil;
    if (fileName.length > 0) {
        NSString *filePath = [[self getImagerCache] stringByAppendingPathComponent:fileName];
        image = [UIImage imageWithContentsOfFile:filePath];
    }
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:[self getPublicNumberDefaultHeaderPath]];
    }
    return image;
}

- (NSString *)getPublicNumberDefaultHeaderPath {
    NSString *robotHeaderPath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"robot_default_header" ofType:@"png"];
    return robotHeaderPath;
}

- (NSDictionary *)getPublicNumberCardByJid:(NSString *)jid {
    return [[IMDataManager sharedInstance] getPublicNumberCardByJId:jid];
}

- (NSArray *)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/get_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:publicNumberIdList error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            id errorMsg = [value objectForKey:@"errmsg"];
            if (errorCode == 0) {
                NSArray *temp = [value objectForKey:@"data"];
                NSMutableArray *cardList = [NSMutableArray array];
                if ([temp isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *cardDic in temp) {
                        NSDictionary *bodyDic = [cardDic objectForKey:@"rbt_body"];
                        if (bodyDic) {
                            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:bodyDic];
                            [dictionary setQIMSafeObject:[cardDic objectForKey:@"rbt_ver"] forKey:@"rbt_ver"];
                            NSString *headerurl = [dictionary objectForKey:@"headerurl"];
                            NSString *fileName = [[headerurl pathComponents] lastObject];
                            [dictionary setQIMSafeObject:fileName forKey:@"headerSrc"];
                            [dictionary setQIMSafeObject:[QIMPinYinForObjc chineseConvertToPinYin:[dictionary objectForKey:@"robotCnName"]] forKey:@"searchIndex"];
                            [cardList addObject:dictionary];
                        }
                    }
                } else {
                    QIMErrorLog(@"updatePublicNumberCardByIds error msg %@", errorMsg);
                }
                if (flag) {
                    [[IMDataManager sharedInstance] bulkInsertPublicNumbers:cardList];
                }
                return cardList;
            }
        }
    }
    return nil;
}

- (void)updateAllPublicNumberCard {
    NSArray *list = [[IMDataManager sharedInstance] getPublicNumberVersionList];
    [self updatePublicNumberCardByIds:list WithNeedUpdate:YES];
}

#pragma mark - sss

- (NSArray *)recommendRobot {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/recommend_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"type": @"1"} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            id errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"recommendRobot error msg %@", errorMsg);
            if (errorCode == 0) {
                NSArray *list = [[value objectForKey:@"data"] valueForKey:@"rbt_body"];
                return list;
            }
        }
    }
    return nil;
}

- (void)registerPublicNumber {
    
    NSDictionary *cardDic = [self getSharebook];
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/register_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setQIMSafeObject:@"application/json" forKey:@"content-type"];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:cardDic error:nil];

    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [request setHTTPBody:data];
    [request setHTTPRequestHeaders:requestHeader];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSError *errol = nil;
            NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:&errol];
            if (value.count > 0) {
                int errorCode = [[value objectForKey:@"errcode"] intValue];
                NSString *errorMsg = [value objectForKey:@"errmsg"];
                QIMErrorLog(@"registerPublicNumber error msg %@", errorMsg);
                if (errorCode == 0) {
                    return;
                } else if (errorCode == 500) {
                    [self updateRemoteLoginKey];
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSArray *)getPublicNumberList {
    return [[IMDataManager sharedInstance] getPublicNumberList];
}

- (void)updatePublicNumberList {
    // 获取公众号列表
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"user": [QIMManager getLastUserName] ? [QIMManager getLastUserName] : @"", @"method": @"get"} error:nil];

    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setObject:@"application/json" forKey:@"content-type"];
    
    QIMHTTPRequest *requeset = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [requeset setHTTPRequestHeaders:requestHeader];
    [requeset setHTTPBody:data];
    [QIMHTTPClient sendRequest:requeset complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSError *errol = nil;
            NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:&errol];
            if (value.count > 0) {
                int errorCode = [[value objectForKey:@"errcode"] intValue];
                id errorMsg = [value objectForKey:@"errmsg"];
                QIMErrorLog(@"updatePublicNumberList error msg %@", errorMsg);
                if (errorCode == 0) {
                    NSArray *pubList = [value objectForKey:@"data"];
                    [[IMDataManager sharedInstance] checkPublicNumbers:pubList];
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [self updateAllPublicNumberCard];
                    });
                    return;
                } else if (errorCode == 5000) {
                    [self updateRemoteLoginKey];
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (BOOL)focusOnPublicNumberId:(NSString *)publicNumberId {
    
    if (publicNumberId == nil) {
        return NO;
    }
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return NO;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"user": [QIMManager getLastUserName], @"rbt": publicNumberId, @"method": @"add"} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            NSString *errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"focusOnPublicNumberId error msg %@", errorMsg);
            if (errorCode == 0) {
                
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)cancelFocusOnPublicNumberId:(NSString *)publicNumberId {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"user": [QIMManager getLastUserName], @"rbt": publicNumberId, @"method": @"del"} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            NSString *errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"cancelFocusOnPublicNumberId error msg %@", errorMsg);
            if (errorCode == 0) {
                [[IMDataManager sharedInstance] deletePublicNumberId:publicNumberId];
                return YES;
            }
        }
        
    }
    return NO;
}

#pragma mark - 公众号消息

- (Message *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkPNMsgTimeWithJid:publicNumberId WithMsgDate:msgDate];
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:(int) msgType];
    [mesg setChatType:ChatType_PublicNumber];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:publicNumberId];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setMessageState:MessageState_Waiting];
    [mesg setExtendInformation:extendInfo];
    [self saveMsg:mesg ByJid:publicNumberId];
    return mesg;
}

- (Message *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WihtMsgType:(int)msgType {
    
    Message *message = [Message new];
    [message setMessageId:msgId];
    [message setTo:publicNumberId];
    [message setMessageDirection:MessageDirection_Sent];
    [message setChatType:ChatType_PublicNumber];
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setMessageState:MessageState_Waiting];
    [message setMessageDate:([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000];
    [[XmppImManager sharedInstance] sendPublicNumberMessage:msg WithInfo:nil toJid:publicNumberId WithMsgId:msgId WithMsgType:msgType];
    if (message.messageType != PublicNumberMsgType_Action && message.messageType != PublicNumberMsgType_ClientCookie && message.messageType != PublicNumberMsgType_PostBackCookie) {
        [self checkPNMsgTimeWithJid:publicNumberId WithMsgDate:message.messageDate];
        [self saveMsg:message ByJid:publicNumberId];
    }
    return message;
}

- (NSArray *)getPublicNumberMsgListById:(NSString *)publicNumberId WihtLimit:(int)limit WithOffset:(int)offset {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *array = [[IMDataManager sharedInstance] getMsgListByPublicNumberId:publicNumberId WithLimit:limit WihtOffset:offset WithFilterType:@[@(PublicNumberMsgType_Action), @(PublicNumberMsgType_PostBackCookie), @(PublicNumberMsgType_ClientCookie)]];
    if (array.count > 0) {
        for (int i = (int) array.count - 1; i >= 0; i--) {
            NSDictionary *dic = [array objectAtIndex:i];
            NSString *msgId = [dic objectForKey:@"MsgId"];
            NSString *xmppId = [dic objectForKey:@"XmppId"];
            NSString *from = [dic objectForKey:@"From"];
            NSString *to = [dic objectForKey:@"To"];
            NSString *content = [dic objectForKey:@"Content"];
            int msgType = [[dic objectForKey:@"Type"] intValue];
            int msgState = [[dic objectForKey:@"State"] intValue];
            int msgDirection = [[dic objectForKey:@"Direction"] intValue];
            //            int readerTag = [[dic objectForKey:@"ReadedTag"] intValue];
            long long msgDate = [[dic objectForKey:@"LastUpdateTime"] longLongValue];
            Message *msg = [Message new];
            [msg setMessageId:msgId];
            [msg setXmppId:xmppId];
            [msg setFrom:from];
            [msg setTo:to];
            [msg setMessage:content];
            [msg setMessageType:msgType];
            [msg setMessageState:msgState];
            [msg setMessageDirection:msgDirection];
            [msg setMessageDate:msgDate];
            [result addObject:msg];
        }
    }
    return result;
}

- (void)clearNotReadMsgByPublicNumberId:(NSString *)jid {
    [[self notReadMsgByPublicNumberDic] removeObjectForKey:jid];
    //Comment
    [[QIMUserCacheManager sharedInstance] setUserObject:self.notReadMsgDic forKey:kNotReadPublicNumberMsgCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPublicNumberMsgNotReadCountChange object:jid];
    });
}

- (void)setNotReaderMsgCount:(int)count ForPublicNumberId:(NSString *)jid {
    [[self notReadMsgByPublicNumberDic] setObject:[NSNumber numberWithInt:count] forKey:jid];
    //Comment
    [[QIMUserCacheManager sharedInstance] setUserObject:self.notReadMsgDic forKey:kNotReadPublicNumberMsgCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPublicNumberMsgNotReadCountChange object:jid];
    });
}

- (int)getNotReaderMsgCountByPublicNumberId:(NSString *)jid {
    return [[[self notReadMsgByPublicNumberDic] objectForKey:jid] intValue];
}

- (void)checkPNMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate {
    NSNumber *globalMsgDate = [self.timeStempDic objectForKey:jid];
    if (msgDate - globalMsgDate.longLongValue >= 2 * 60 * 1000) {
        [self.timeStempDic setObject:@(msgDate) forKey:jid];
        Message *msg = [Message new];
        NSDate *date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        [msg setMessageId:[[IMDataManager sharedInstance] getTimeSmtapMsgIdForDate:date WithUserId:jid]];
        [msg setChatType:ChatType_PublicNumber];
        [msg setMessageType:QIMMessageType_Time];
        [msg setMessageDate:msgDate - 1];
        [msg setMessageState:MessageState_didRead];
        [self saveMsg:msg ByJid:jid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                object:jid
                                                              userInfo:@{@"message": msg}];
        });
    }
}

- (NSArray *)searchRobotByKeyStr:(NSString *)keyStr {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/search_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"type": @"1", @"keyword": keyStr} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            id errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"searchRobotByKeyStr error msg %@", errorMsg);
            if (errorCode == 0) {
                NSArray *list = [value objectForKey:@"data"];
                return list;
            }
        }
    }
    return nil;
}

- (NSDictionary *)getQtalkRobotDic {
    NSMutableArray *actionList = [NSMutableArray array];
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    [action setObject:@"Qtalk主页" forKey:@"mainaction"];
    [action setObject:@{@"action": @"openurl", @"value": @"http://qtalk.corp.qunar.com"} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    action = [NSMutableDictionary dictionary];
    [action setObject:@"Hello请求" forKey:@"mainaction"];
    [action setObject:@{@"action": @"sendmsg", @"value": @"{\\\"cmd\\\":1}"} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    action = [NSMutableDictionary dictionary];
    [action setObject:@"扫码" forKey:@"mainaction"];
    NSMutableArray *subActions = [NSMutableArray array];
    [subActions addObject:@{@"subaction": @"二维码", @"actioncontent": @{@"action": @"qrcode"}}];
    [subActions addObject:@{@"subaction": @"条形码", @"actioncontent": @{@"method": @"reply"}}];
    [action setObject:subActions forKey:@"subactions"];
    [actionList addObject:action];
    
    NSMutableDictionary *cardDic = [NSMutableDictionary dictionary];
    [cardDic setObject:@"qtalkrobot" forKey:@"robotEnName"];
    [cardDic setObject:@"Qtalk官方" forKey:@"robotCnName"];
    [cardDic setObject:@"xxxx" forKey:@"headerulr"];
    [cardDic setObject:@"测试机器人1号" forKey:@"robotDesc"];
    [cardDic setObject:@"来自Qtalk开发小组" forKey:@"fromsource"];
    [cardDic setObject:@"110" forKey:@"tel"];
    [cardDic setObject:@"http://www.baidu.com" forKey:@"requestUrl"];
    [cardDic setObject:@(YES) forKey:@"receiveswitch"];
    [cardDic setObject:actionList forKey:@"actionlist"];
    return cardDic;
}

- (NSDictionary *)getBaomingQiandao {
    NSMutableArray *actionList = [NSMutableArray array];
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    [action setObject:@"扫码报名/签到" forKey:@"mainaction"];
    [action setObject:@{@"action": @"qrcode"} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    NSMutableDictionary *cardDic = [NSMutableDictionary dictionary];
    [cardDic setObject:@"signupandsignin" forKey:@"robotEnName"];
    [cardDic setObject:@"培训活动报名和签到" forKey:@"robotCnName"];
    [cardDic setObject:@"https://qt.qunar.com/cgi-bin/get_file.pl?file=20150908/2714d292c249fbcdc3de4d7395e99a2d.png" forKey:@"headerurl"];
    [cardDic setObject:@"提供培训活动的扫码报名和签到的功能" forKey:@"robotDesc"];
    [cardDic setObject:@"http://qtown.corp.qunar.com/activity/qrCode/signUpAndSignIn" forKey:@"requestUrl"];
    [cardDic setObject:@(YES) forKey:@"receiveswitch"];
    [cardDic setObject:actionList forKey:@"actionlist"];
    return cardDic;
}

- (NSDictionary *)getSharebook {
    NSMutableArray *actionList = [NSMutableArray array];
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    [action setObject:@"扫码共享图书" forKey:@"mainaction"];
    [action setObject:@{@"action": @"barcode", @"value": @{@"method": @"share"}} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    action = [NSMutableDictionary dictionary];
    [action setObject:@"确认共享" forKey:@"mainaction"];
    [action setObject:@{@"action": @"postbackcookie", @"value": @{@"method": @"sync", @"id": @"sync", @"key": @"isbn"}} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    NSMutableDictionary *cardDic = [NSMutableDictionary dictionary];
    [cardDic setObject:@"sharebook" forKey:@"robotEnName"];
    [cardDic setObject:@"扫码共享图书" forKey:@"robotCnName"];
    [cardDic setObject:@"https://qt.qunar.com/cgi-bin/get_file.pl?file=20150908/2714d292c249fbcdc3de4d7395e99a2d.png" forKey:@"headerurl"];
    [cardDic setObject:@"Qunar员工可以使用手机扫描图书条形码共享自己的图书" forKey:@"robotDesc"];
    [cardDic setObject:@"http://library.qunar.it/share/client/shareBook" forKey:@"requestUrl"];
    [cardDic setObject:@(YES) forKey:@"receiveswitch"];
    [cardDic setObject:actionList forKey:@"actionlist"];
    return cardDic;
}

- (NSDictionary *)getQBug {
    NSMutableArray *actionList = [NSMutableArray array];
    NSMutableDictionary *action = [NSMutableDictionary dictionary];
    [action setObject:@"扫码共享图书" forKey:@"mainaction"];
    [action setObject:@{@"action": @"barcode", @"value": @{@"method": @"share"}} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    action = [NSMutableDictionary dictionary];
    [action setObject:@"确认共享" forKey:@"mainaction"];
    [action setObject:@{@"action": @"postbackcookie", @"value": @{@"method": @"sync", @"id": @"sync", @"key": @"isbn"}} forKey:@"actioncontent"];
    [actionList addObject:action];
    
    NSMutableDictionary *cardDic = [NSMutableDictionary dictionary];
    [cardDic setObject:@"sharebook" forKey:@"robotEnName"];
    [cardDic setObject:@"扫码共享图书" forKey:@"robotCnName"];
    [cardDic setObject:@"https://qt.qunar.com/cgi-bin/get_file.pl?file=20150908/2714d292c249fbcdc3de4d7395e99a2d.png" forKey:@"headerurl"];
    [cardDic setObject:@"Qunar员工可以使用手机扫描图书条形码共享自己的图书" forKey:@"robotDesc"];
    [cardDic setObject:@"http://library.qunar.it/share/client/shareBook" forKey:@"requestUrl"];
    [cardDic setObject:@(YES) forKey:@"receiveswitch"];
    [cardDic setObject:actionList forKey:@"actionlist"];
    return cardDic;
}

@end
