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
    return [[IMDataManager qimDB_SharedInstance] qimDB_getPublicNumberCardByJId:jid];
}

- (void)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag withCallBack:(QIMKitUpdatePublicNumberCardCallBack)callback {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
//        return nil;
        if (callback) {
            callback(nil);
        }
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/get_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:publicNumberIdList error:nil];
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
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
                    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPublicNumbers:cardList];
                }
                if (callback) {
                    callback(cardList);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)updateAllPublicNumberCard {
    NSArray *list = [[IMDataManager qimDB_SharedInstance] qimDB_getPublicNumberVersionList];
    [self updatePublicNumberCardByIds:list WithNeedUpdate:YES withCallBack:nil];
}

#pragma mark - sss

- (NSArray *)getPublicNumberList {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getPublicNumberList];
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
                    [[IMDataManager qimDB_SharedInstance] qimDB_checkPublicNumbers:pubList];
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

- (void)focusOnPublicNumberId:(NSString *)publicNumberId withCallBack:(QIMKitFocusPublicNumberCallBack)callback {
    
    if (publicNumberId == nil) {
        if (callback) {
            callback(NO);
        }
    }
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        if (callback) {
            callback(NO);
        }
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"user": [QIMManager getLastUserName], @"rbt": publicNumberId, @"method": @"add"} error:nil];

    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            NSString *errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"focusOnPublicNumberId error msg %@", errorMsg);
            if (errorCode == 0) {
                
                if (callback) {
                    callback(YES);
                }
            } else {
                if (callback) {
                    callback(NO);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO);
        }
    }];
}

- (void)cancelFocusOnPublicNumberId:(NSString *)publicNumberId withCallBack:(QIMKitCancelFocusPublicNumberCallBack)callback {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        if (callback) {
            callback(NO);
        }
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/user_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"user": [QIMManager getLastUserName], @"rbt": publicNumberId, @"method": @"del"} error:nil];

    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            NSString *errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"cancelFocusOnPublicNumberId error msg %@", errorMsg);
            if (errorCode == 0) {
                [[IMDataManager qimDB_SharedInstance] qimDB_deletePublicNumberId:publicNumberId];
                if (callback) {
                    callback(YES);
                }
            } else {
                if (callback) {
                    callback(NO);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO);
        }
    }];
}

#pragma mark - 公众号消息

- (QIMMessageModel *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkPNMsgTimeWithJid:publicNumberId WithMsgDate:msgDate];
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:(int) msgType];
    [mesg setChatType:ChatType_PublicNumber];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:publicNumberId];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setMessageSendState:QIMMessageSendState_Waiting];
    [mesg setExtendInformation:extendInfo];
    [self saveMsg:mesg ByJid:publicNumberId];
    return mesg;
}

- (QIMMessageModel *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WithMsgType:(int)msgType {
    
    QIMMessageModel *message = [QIMMessageModel new];
    [message setMessageId:msgId];
    [message setTo:publicNumberId];
    [message setMessageDirection:QIMMessageDirection_Sent];
    [message setChatType:ChatType_PublicNumber];
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setMessageSendState:QIMMessageSendState_Waiting];
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
    NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgListByPublicNumberId:publicNumberId WithLimit:limit WithOffset:offset WithFilterType:@[@(PublicNumberMsgType_Action), @(PublicNumberMsgType_PostBackCookie), @(PublicNumberMsgType_ClientCookie)]];
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
            QIMMessageModel *msg = [QIMMessageModel new];
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
    [[QIMUserCacheManager sharedInstance] setUserObject:self.notReadMsgDic forKey:kNotReadPublicNumberMsgCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPublicNumberMsgNotReadCountChange object:jid];
    });
}

- (void)setNotReaderMsgCount:(int)count ForPublicNumberId:(NSString *)jid {
    [[self notReadMsgByPublicNumberDic] setObject:[NSNumber numberWithInt:count] forKey:jid];
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
        QIMMessageModel *msg = [QIMMessageModel new];
        NSDate *date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        [msg setMessageId:[[IMDataManager qimDB_SharedInstance] qimDB_getTimeSmtapMsgIdForDate:date WithUserId:jid]];
        [msg setChatType:ChatType_PublicNumber];
        [msg setMessageType:QIMMessageType_Time];
        [msg setMessageDate:msgDate - 1];
        [msg setMessageSendState:QIMMessageSendState_Success];
        [msg setMessageReadState:QIMMessageRemoteReadStateDidReaded];
        [self saveMsg:msg ByJid:jid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                object:jid
                                                              userInfo:@{@"message": msg}];
        });
    }
}

- (void)searchRobotByKeyStr:(NSString *)keyStr withCallBack:(QIMKitSearchRobotByKeyStrCallBack)callback {
    
    if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
        [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
        if (callback) {
            callback(nil);
        }
    }
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/search_robot?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:@{@"type": @"1", @"keyword": keyStr} error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
        NSError *errol = nil;
        NSDictionary *value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if (value.count > 0) {
            int errorCode = [[value objectForKey:@"errcode"] intValue];
            id errorMsg = [value objectForKey:@"errmsg"];
            QIMErrorLog(@"searchRobotByKeyStr error msg %@", errorMsg);
            if (errorCode == 0) {
                NSArray *list = [value objectForKey:@"data"];
                if (callback) {
                    callback(list);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

@end
