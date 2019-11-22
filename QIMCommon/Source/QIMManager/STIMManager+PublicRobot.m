//
//  STIMManager+PublicRobot.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#import "STIMManager+PublicRobot.h"
#import "STIMPinYinForObjc.h"
#import <objc/runtime.h>
#import "STIMPrivateHeader.h"

@implementation STIMManager (PublicRobot)

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
    NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"kDealInfoDic"];
    
    return [[dic objectForKey:dealId] intValue];
}

- (void)setDealId:(NSString *)dealId ForState:(int)state {
    NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"kDealInfoDic"];
    NSMutableDictionary *dealDic = [NSMutableDictionary dictionary];
    if (dic) {
        [dealDic setDictionary:dic];
    }
    [dealDic setObject:@(state) forKey:dealId];
    [[STIMUserCacheManager sharedInstance] setUserObject:dealDic forKey:@"kDealInfoDic"];
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
    NSString *robotHeaderPath = [NSBundle stimDB_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"robot_default_header" ofType:@"png"];
    return robotHeaderPath;
}

- (NSDictionary *)getPublicNumberCardByJid:(NSString *)jid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getPublicNumberCardByJId:jid];
}

- (NSArray *)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag {
    
    if ([[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/get_robot?u=%@&k=%@&p=iphone&v=%@", [[STIMNavConfigManager sharedInstance] httpHost], [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[STIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:publicNumberIdList error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
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
                            [dictionary setSTIMSafeObject:[cardDic objectForKey:@"rbt_ver"] forKey:@"rbt_ver"];
                            NSString *headerurl = [dictionary objectForKey:@"headerurl"];
                            NSString *fileName = [[headerurl pathComponents] lastObject];
                            [dictionary setSTIMSafeObject:fileName forKey:@"headerSrc"];
                            [dictionary setSTIMSafeObject:[STIMPinYinForObjc chineseConvertToPinYin:[dictionary objectForKey:@"robotCnName"]] forKey:@"searchIndex"];
                            [cardList addObject:dictionary];
                        }
                    }
                } else {
                    STIMErrorLog(@"updatePublicNumberCardByIds error msg %@", errorMsg);
                }
                if (flag) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertPublicNumbers:cardList];
                }
                return cardList;
            }
        }
    }
    return nil;
}

- (void)updateAllPublicNumberCard {
    NSArray *list = [[IMDataManager stIMDB_SharedInstance] stIMDB_getPublicNumberVersionList];
    [self updatePublicNumberCardByIds:list WithNeedUpdate:YES];
}

#pragma mark - sss

- (NSArray *)getPublicNumberList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getPublicNumberList];
}

- (void)updatePublicNumberList {
    // 获取公众号列表
    
    if ([[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[STIMNavConfigManager sharedInstance] httpHost], [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[STIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:@{@"user": [STIMManager getLastUserName] ? [STIMManager getLastUserName] : @"", @"method": @"get"} error:nil];

    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setObject:@"application/json" forKey:@"content-type"];
    
    STIMHTTPRequest *requeset = [[STIMHTTPRequest alloc] initWithURL:requestUrl];
    [requeset setHTTPRequestHeaders:requestHeader];
    [requeset setHTTPBody:data];
    [STIMHTTPClient sendRequest:requeset complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            NSError *errol = nil;
            NSDictionary *value = [[STIMJSONSerializer sharedInstance] deserializeObject:response.data error:&errol];
            if (value.count > 0) {
                int errorCode = [[value objectForKey:@"errcode"] intValue];
                id errorMsg = [value objectForKey:@"errmsg"];
                STIMErrorLog(@"updatePublicNumberList error msg %@", errorMsg);
                if (errorCode == 0) {
                    NSArray *pubList = [value objectForKey:@"data"];
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_checkPublicNumbers:pubList];
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
    if ([[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return NO;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[STIMNavConfigManager sharedInstance] httpHost], [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[STIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:@{@"user": [STIMManager getLastUserName], @"rbt": publicNumberId, @"method": @"add"} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            NSString *errorMsg = [value objectForKey:@"errmsg"];
            STIMErrorLog(@"focusOnPublicNumberId error msg %@", errorMsg);
            if (errorCode == 0) {
                
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)cancelFocusOnPublicNumberId:(NSString *)publicNumberId {
    
    if ([[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[STIMNavConfigManager sharedInstance] httpHost], [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[STIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:@{@"user": [STIMManager getLastUserName], @"rbt": publicNumberId, @"method": @"del"} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            NSString *errorMsg = [value objectForKey:@"errmsg"];
            STIMErrorLog(@"cancelFocusOnPublicNumberId error msg %@", errorMsg);
            if (errorCode == 0) {
                [[IMDataManager stIMDB_SharedInstance] stIMDB_deletePublicNumberId:publicNumberId];
                return YES;
            }
        }
        
    }
    return NO;
}

#pragma mark - 公众号消息

- (STIMMessageModel *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkPNMsgTimeWithJid:publicNumberId WithMsgDate:msgDate];
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setMessageType:(int) msgType];
    [mesg setChatType:ChatType_PublicNumber];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:publicNumberId];
    [mesg setFrom:[[STIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setMessageSendState:STIMMessageSendState_Waiting];
    [mesg setExtendInformation:extendInfo];
    [self saveMsg:mesg ByJid:publicNumberId];
    return mesg;
}

- (STIMMessageModel *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WithMsgType:(int)msgType {
    
    STIMMessageModel *message = [STIMMessageModel new];
    [message setMessageId:msgId];
    [message setTo:publicNumberId];
    [message setMessageDirection:STIMMessageDirection_Sent];
    [message setChatType:ChatType_PublicNumber];
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setMessageSendState:STIMMessageSendState_Waiting];
    [message setMessageDate:([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000];
    [[XmppImManager sharedInstance] sendPublicNumberMessage:msg WithInfo:nil toJid:publicNumberId WithMsgId:msgId WithMsgType:msgType];
    if (message.messageType != PublicNumberMsgType_Action && message.messageType != PublicNumberMsgType_ClientCookie && message.messageType != PublicNumberMsgType_PostBackCookie) {
        [self checkPNMsgTimeWithJid:publicNumberId WithMsgDate:message.messageDate];
        [self saveMsg:message ByJid:publicNumberId];
    }
    return message;
}

- (NSArray *)getPublicNumberMsgListById:(NSString *)publicNumberId WithLimit:(int)limit WithOffset:(int)offset {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgListByPublicNumberId:publicNumberId WithLimit:limit WithOffset:offset WithFilterType:@[@(PublicNumberMsgType_Action), @(PublicNumberMsgType_PostBackCookie), @(PublicNumberMsgType_ClientCookie)]];
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
            long long msgDate = [[dic objectForKey:@"LastUpdateTime"] longLongValue];
            STIMMessageModel *msg = [STIMMessageModel new];
            [msg setMessageId:msgId];
            [msg setXmppId:xmppId];
            [msg setFrom:from];
            [msg setTo:to];
            [msg setMessage:content];
            [msg setMessageType:msgType];
            [msg setMessageSendState:msgState];
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
    [[STIMUserCacheManager sharedInstance] setUserObject:self.notReadMsgDic forKey:kNotReadPublicNumberMsgCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPublicNumberMsgNotReadCountChange object:jid];
    });
}

- (void)setNotReaderMsgCount:(int)count ForPublicNumberId:(NSString *)jid {
    [[self notReadMsgByPublicNumberDic] setObject:[NSNumber numberWithInt:count] forKey:jid];
    [[STIMUserCacheManager sharedInstance] setUserObject:self.notReadMsgDic forKey:kNotReadPublicNumberMsgCount];
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
        STIMMessageModel *msg = [STIMMessageModel new];
        NSDate *date = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        [msg setMessageId:[[IMDataManager stIMDB_SharedInstance] stIMDB_getTimeSmtapMsgIdForDate:date WithUserId:jid]];
        [msg setChatType:ChatType_PublicNumber];
        [msg setMessageType:STIMMessageType_Time];
        [msg setMessageDate:msgDate - 1];
        [msg setMessageSendState:STIMMessageSendState_Success];
        [msg setMessageReadState:STIMMessageRemoteReadStateDidReaded];
        [self saveMsg:msg ByJid:jid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                object:jid
                                                              userInfo:@{@"message": msg}];
        });
    }
}

- (NSArray *)searchRobotByKeyStr:(NSString *)keyStr {
    
    if ([[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[STIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        return nil;
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/search_robot?u=%@&k=%@&p=iphone&v=%@", [[STIMNavConfigManager sharedInstance] httpHost], [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[STIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:@{@"type": @"1", @"keyword": keyStr} error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *value = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            id errorMsg = [value objectForKey:@"errmsg"];
            STIMErrorLog(@"searchRobotByKeyStr error msg %@", errorMsg);
            if (errorCode == 0) {
                NSArray *list = [value objectForKey:@"data"];
                return list;
            }
        }
    }
    return nil;
}

@end
