//
//  QIMManager+Collection.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#import "QIMManager+Collection.h"

@implementation QIMManager (Collection)

- (NSString *)getCollectionUserHeaderUrlWithXmppId:(NSString *)userId {
    NSDictionary *userInfoDic = [self getCollectionUserInfoByUserId:userId];
    NSString *headerUrl = [userInfoDic objectForKey:@"HeaderSrc"];
    if (![headerUrl qim_hasPrefixHttpHeader] && headerUrl.length > 0) {
        headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMNavConfigManager sharedInstance] innerFileHttpHost], headerUrl];
    }
    return headerUrl;
}

- (NSString *)getCollectionGroupHeaderUrlWithCollectionGroupId:(NSString *)groupId {
    NSDictionary *groupInfoDic = [self getCollectionGroupCardByGroupId:groupId];
    NSString *headerUrl = [groupInfoDic objectForKey:@"HeaderSrc"];
    if (![headerUrl qim_hasPrefixHttpHeader] && headerUrl.length > 0) {
        headerUrl = [NSString stringWithFormat:@"%@/%@", [[QIMNavConfigManager sharedInstance] innerFileHttpHost], headerUrl];
    }
    return headerUrl;
}

- (NSDictionary *)getCollectionUserInfoByUserId:(NSString *)myId {
    __block NSDictionary *result = nil;
    
    dispatch_block_t block = ^{
        if (!self.collectionUserVCardDict) {
            self.collectionUserVCardDict = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        NSDictionary *tempDic = [self.collectionUserVCardDict objectForKey:myId];
        if (!tempDic) {
            tempDic = [[IMDataManager sharedInstance] selectCollectionUserByJID:myId];
            if (tempDic) {
                [self.collectionUserVCardDict setQIMSafeObject:tempDic forKey:myId];
            } else {
                [self updateCollectionUserCardByUserId:myId];
            }
        }
        result = tempDic;
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    return result;
}

/**
 获取代收用户的名片信息
 */
- (void)updateCollectionUserCardByUserIds:(NSArray *)userIds {
    
    if (!userIds) {
        return;
    }
    dispatch_async(self.load_customEvent_queue, ^{
        NSMutableArray *params = [NSMutableArray array];
        //    [{"u":"xuejie.bi", "d":"qunar.com", "v":1}, {"u":"xuejie.bi", "d":"ejabhost1", "v":0}]
        for (NSString *userXmppId in userIds) {
            NSString *userId = [[userXmppId componentsSeparatedByString:@"@"] firstObject];
            NSString *userDomain = [[userXmppId componentsSeparatedByString:@"@"] lastObject];
            [params addObject:@{@"u": userId ? userId : @"", @"d":userDomain ? userDomain : @"", @"v":@(0)}];
        }
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/common/collection/getvcard.qunar",[[QIMNavConfigManager sharedInstance] javaurl]];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPBody:requestData];
        [request setHTTPRequestHeaders:cookieProperties];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                NSData *responseData = response.data;
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSArray *list = [result objectForKey:@"data"];
                    if (list.count > 0) {
                        [[IMDataManager sharedInstance] bulkInsertCollectionUserCards:list];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionUserVCardUpdate object:userIds];
                        });
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    });
}


- (void)updateCollectionUserCardByUserId:(NSString *)userId {
    
    if (!userId) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self updateCollectionUserCardByUserIds:@[userId]];
    });
}


//存储代收消息
- (void)saveCollectionMessage:(NSDictionary *)collectionMsgDic {
    [[IMDataManager sharedInstance] bulkInsertCollectionMsgWihtMsgDics:@[collectionMsgDic]];
}

- (Message *)getCollectionMsgListForMsgId:(NSString *)msgId {
    NSDictionary *infoDic = [[IMDataManager sharedInstance] getCollectionMsgListForMsgId:msgId];
    if (infoDic) {
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
        [msg setRealJid:[infoDic objectForKey:@"RealJid"]];
        [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
        [msg setChatType:[[infoDic objectForKey:@"originType"] intValue]];
        [msg setNickName:[infoDic objectForKey:@"nickName"]];
        [msg setRealJid:[infoDic objectForKey:@"realJid"]];
        return msg;
    }
    return nil;
}

- (NSArray *)getCollectionMsgListForUserId:(NSString *)userId originUserId:(NSString *)originUserId {
    NSArray *array = [[IMDataManager sharedInstance] getCollectionMsgListWithUserId:userId originUserId:originUserId];
    NSMutableArray *list = [NSMutableArray array];
    if (array.count > 0) {
        for (NSDictionary *infoDic in array) {
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
            [msg setRealJid:[infoDic objectForKey:@"RealJid"]];
            [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
            [msg setChatType:[[infoDic objectForKey:@"originType"] intValue]];
            [msg setNickName:[infoDic objectForKey:@"nickName"]];
            [msg setRealJid:[infoDic objectForKey:@"realJid"]];
            [list addObject:msg];
        }
    }
    return list;
}

- (NSDictionary *)getLastCollectionMsgByMsgId:(NSString *)lastMsgId {
    return [[IMDataManager sharedInstance] getLastCollectionMsgWithLastMsgId:lastMsgId];
}

/**
 获取某绑定账号下的代收列表
 
 @param bindId 绑定账号
 */
- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId {
    return [[IMDataManager sharedInstance] getCollectionSessionListWithBindId:bindId];
}

/**
 获取某绑定账号下的代收消息
 
 @param bindId 绑定账号
 */
- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId {
    return [[IMDataManager sharedInstance] getCollectionMsgListWithBindId:bindId];
}

/**
 获取已代收账号列表
 
 @return 已代收账号列表
 */
- (NSArray *)getMyCollectionAccountList {
    return [[IMDataManager sharedInstance] getCollectionAccountList];
}

/**
 获取我的绑定账号列表
 */
- (void)getRemoteCollectionAccountList {
    NSString *javaUrl = [[QIMNavConfigManager sharedInstance] javaurl];
    if (javaUrl.length > 0) {
        NSString *getCollectionAccountUrl = [NSString stringWithFormat:@"%@/qtapi/common/collection/get.qunar", javaUrl];
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:getCollectionAccountUrl]];
        [request setUseCookiePersistence:NO];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        [request setHTTPRequestHeaders:cookieProperties];
        
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSArray *data = [result objectForKey:@"data"];
                    if (data.count > 0) {
                        [[IMDataManager sharedInstance] bulkinsertCollectionAccountList:data];
                        [[IMDataManager sharedInstance] bulkInsertCollectionUserCards:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCollectionMsgList" object:nil userInfo:nil];
                        });
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

/**
 根据Jid清空代收未读消息
 
 @param jid Jid
 */
- (void)clearNotReadCollectionMsgByJid:(NSString *)jid {
    [[IMDataManager sharedInstance] updateCollectionMsgNotReadStateByJid:jid WithMsgState:MessageState_didRead];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *xmppId = [NSString stringWithFormat:@"collection_rbt@%@", [self getDomain]];
        [self.notReadMsgDic removeObjectForKey:xmppId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:xmppId];
    });
}

/**
 根据绑定账号 & 用户Id清空代收 未读消息
 
 @param bindId 绑定账号Id
 @param userId 用户Id
 */
- (void)clearNotReadCollectionMsgByBindId:(NSString *)bindId WithUserId:(NSString *)userId {
    
    [[IMDataManager sharedInstance] updateCollectionMsgNotReadStateForBindId:bindId originUserId:userId WithMsgState:MessageState_didRead];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *xmppId = [NSString stringWithFormat:@"collection_rbt@%@", [self getDomain]];
        [self.notReadMsgDic removeObjectForKey:xmppId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:xmppId];
    });
}

/**
 获取代收总未读消息数
 */
- (NSInteger)getNotReadCollectionMsgCount {
    return [[IMDataManager sharedInstance] getCollectionMsgNotReadCountByDidReadState:MessageState_didRead];
}

/**
 获取某绑定账号下的代收未读消息数
 
 @param bindId 绑定账号Id
 */
- (NSInteger)getNotReadCollectionMsgCountByBindId:(NSString *)bindId {
    return [[IMDataManager sharedInstance] getCollectionMsgNotReadCountByDidReadState:MessageState_didRead ForBindId:bindId];
}

/**
 获取某绑定账号下 单一账号来的代收 未读消息
 
 @param bindId 绑定账号Id
 @param userId 用户Id
 */
- (NSInteger)getNotReadCollectionMsgCountByBindId:(NSString *)bindId WithUserId:(NSString *)userId {
    return [[IMDataManager sharedInstance] getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:MessageState_didRead ForBindId:bindId originUserId:userId];
}

#pragma mark - 代收Group

- (NSDictionary *)getCollectionGroupCardByGroupId:(NSString *)groupId {
    return [[IMDataManager sharedInstance] getCollectionGroupCardByGroupId:groupId];
}

- (void)updateCollectionGroupCardByGroupId:(NSString *)groupId {
    
    if (!groupId) {
        return;
    }
    dispatch_async(self.load_customEvent_queue, ^{

        [self updateCollectionGroupCard:@[groupId]];
    });
}

// 获取代收聊天室vcard信息
- (void)updateCollectionGroupCard:(NSArray *)groupIds {
    if (groupIds.count <= 0) {
        return;
    }
    dispatch_async(self.load_customEvent_queue, ^{

        NSMutableArray *params = [NSMutableArray array];
        for (NSString *groupId in groupIds) {
            [params addObject:@{@"m": groupId ? groupId : @"", @"v":@(0)}];
        }
        NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        NSString *destUrl = [NSString stringWithFormat:@"%@/qtapi/common/collection/getmucvcard.qunar",[[QIMNavConfigManager sharedInstance] javaurl]];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];

        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPMethod:QIMHTTPMethodPOST];
        [request setHTTPBody:[NSMutableData dataWithData:requestData]];
        [request setHTTPRequestHeaders:cookieProperties];
        
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSData *responseData = response.data;
                    NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                    BOOL ret = [[result objectForKey:@"ret"] boolValue];
                    if (ret) {
                        NSArray *list = [result objectForKey:@"data"];
                        if (list.count > 0) {
                            [[IMDataManager sharedInstance] bulkInsertCollectionGroupCards:list];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionGroupNickNameChanged object:groupIds];
                            });
                        }
                    }
                });
            }
        } failure:^(NSError *error) {
            
        }];
    });
}

@end
