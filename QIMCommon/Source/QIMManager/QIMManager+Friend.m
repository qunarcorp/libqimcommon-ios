//
//  QIMManager+Friend.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager+Friend.h"
#import "XmppImManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (Friend)

/**
 *  获取好友列表
 */
- (NSMutableDictionary *)getFriendListDict {
    return self.friendInfoDic;
}


- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)xmppId {
    
    return [[XmppImManager sharedInstance] getVerifyFreindModeWithXmppId:xmppId];
}

- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer {
    
    return [[XmppImManager sharedInstance] setVerifyFreindMode:mode WithQuestion:question WithAnswer:answer];
}

- (NSString *)getFriendsJson {
    
    return [[XmppImManager sharedInstance] getFriendsJson];
}

- (void)updateFriendList {
    
    NSString *friendJson = [self getFriendsJson];
    NSArray *friendList = [[QIMJSONSerializer sharedInstance] deserializeObject:friendJson error:nil];
    if (friendList.count <= 0) {
        
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendList];
        [QIMUUIDTools setUUIDToolsFriendList:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kFriendListUpdate object:nil];
        });
        return;
    }
    {
        NSMutableArray *xmppIds = [NSMutableArray array];
        for (NSDictionary *dic in friendList) {
            
            NSString *userId = [dic objectForKey:@"F"];
            NSString *domain = [dic objectForKey:@"H"];
            NSString *xmppId = [userId stringByAppendingFormat:@"@%@", domain];
            [xmppIds addObject:xmppId];
        }
        NSDictionary *friendDic = [[IMDataManager qimDB_SharedInstance] qimDB_selectUsersDicByXmppIds:xmppIds];
        long long currentTime = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
        NSMutableArray *updateList = [NSMutableArray array];
        dispatch_block_t block = ^{
            
            for (NSMutableDictionary *dic in friendList) {
                
                NSString *userId = [dic objectForKey:@"F"];
                NSString *domain = [dic objectForKey:@"H"];
                NSString *xmppId = [userId stringByAppendingFormat:@"@%@", domain];
                int version = [[dic objectForKey:@"V"] intValue];
                NSMutableDictionary *userDic = [friendDic objectForKey:xmppId];
                if (userDic) {
                    
                    NSString *descInfo = [self.friendDescDic objectForKey:userId];
                    [userDic setQIMSafeObject:descInfo ? descInfo : @"" forKey:@"DescInfo"];
                    [userDic setQIMSafeObject:@(version) forKey:@"Version"];
                    [userDic setQIMSafeObject:@(currentTime) forKey:@"LastUpdateTime"];
                } else {
                    
                    NSDictionary *dic = [self getUserInfoByUserId:xmppId];
                    if (dic) {
                        
                        userDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        NSString *descInfo = [self.friendDescDic objectForKey:userId];
                        [userDic setQIMSafeObject:descInfo ? descInfo : @"" forKey:@"DescInfo"];
                        [userDic setQIMSafeObject:@(version) forKey:@"Version"];
                        [userDic setQIMSafeObject:@(currentTime) forKey:@"LastUpdateTime"];
                    } else {
                        userDic = [NSMutableDictionary dictionaryWithCapacity:3];
                        [userDic setQIMSafeObject:xmppId ? xmppId : @"" forKey:@"XmppId"];
                        [userDic setQIMSafeObject:@(version) forKey:@"Version"];
                        [userDic setQIMSafeObject:userId ? userId : @"" forKey:@"UserId"];
                        [userDic setQIMSafeObject:userId ? userId : @"" forKey:@"Name"];
                        NSString *descInfo = [self.friendDescDic objectForKey:userId];
                        [userDic setQIMSafeObject:descInfo ? descInfo : @"" forKey:@"DescInfo"];
                        [userDic setQIMSafeObject:@(currentTime) forKey:@"LastUpdateTime"];
                    }
                }
                if (userDic) {
                    
                    [updateList addObject:userDic];
                }
            }
        };
        
        if (dispatch_get_specific(self.cacheTag))
            block();
        else
            dispatch_sync(self.cacheQueue, block);
        
        
        if (updateList.count > 0) {
            [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertFriendList:updateList];
        } else {
            
            [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendList];
            [QIMUUIDTools setUUIDToolsFriendList:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kFriendListUpdate object:nil];
        });
    }
}

- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer {
    
    return [[XmppImManager sharedInstance] addFriendPresenceWithXmppId:xmppId WithAnswer:answer];
}

- (void)validationFriendWithXmppId:(NSString *)xmppId WithReason:(NSString *)reason {
    
    return [[XmppImManager sharedInstance] validationFriendWithXmppId:xmppId WithReason:reason];
}

- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId {
    
    [[XmppImManager sharedInstance] agreeFriendRequestWithXmppId:xmppId];
    [[IMDataManager qimDB_SharedInstance] qimDB_updateFriendNotifyWithXmppId:xmppId WithState:1];
}

- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId {
    
    [[XmppImManager sharedInstance] refusedFriendRequestWithXmppId:xmppId];
    [[IMDataManager qimDB_SharedInstance] qimDB_updateFriendNotifyWithXmppId:xmppId WithState:2];
}

//1.删除好友,客户端请求，其中mode1为单项删除，mode为2为双项删除
- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode {
    
    BOOL isSuccess = [[XmppImManager sharedInstance] deleteFriendWithXmppId:xmppId WithMode:mode];
    if (isSuccess) {
        
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendListWithXmppId:xmppId];
    }
    return isSuccess;
}

- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId {
    
    return [[XmppImManager sharedInstance] getReceiveMsgLimitWithXmppId:xmppId];
}

- (BOOL)setReceiveMsgLimitWithMode:(int)mode {
    
    return [[XmppImManager sharedInstance] setReceiveMsgLimitWithMode:mode];
}

- (void)updateFriendInviteList {
    
    if ([QIMManager getLastUserName]) {
        
        NSString *destUrl = [NSString stringWithFormat:@"%@/get_invite_info?server=%@&c=qtalk&u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[XmppImManager sharedInstance] domain], [QIMManager getLastUserName], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        long long maxTime = [[IMDataManager qimDB_SharedInstance] qimDB_getMaxTimeFriendNotify];
        NSDictionary *jsonDic = @{@"user": [QIMManager getLastUserName], @"time": @(maxTime), @"d":[[XmppImManager sharedInstance] domain]};
        destUrl = [destUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        
        NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
        [requestHeader setObject:@"application/json" forKey:@"content-type"];
        
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:jsonDic error:nil];

        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [request setHTTPRequestHeaders:requestHeader];
        
        [request setHTTPBody:data];
        [request setTimeoutInterval:1];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                int errCode = [[resultDic objectForKey:@"errcode"] intValue];
                if (errCode == 0) {
                    
                    NSArray *resultArray = [resultDic objectForKey:@"data"];
                    if ([resultArray isKindOfClass:[NSArray class]]) {
                        
                        NSMutableArray *userIds = [NSMutableArray array];
                        NSMutableDictionary *userInviteDic = [NSMutableDictionary dictionary];
                        for (NSDictionary *dic in resultArray) {
                            
                            NSString *userId = [dic objectForKey:@"I"];
                            [userIds addObject:userId];
                            [userInviteDic setQIMSafeObject:dic forKey:userId];
                        }
                        if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
                            
                            NSArray *list = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserListByUserIds:userIds];
                            for (NSMutableDictionary *userInfoDic in list) {
                                
                                NSString *userId = [userInfoDic objectForKey:@"UserId"];
                                NSDictionary *inviteDic = [userInviteDic objectForKey:userId];
                                NSString *b = [inviteDic objectForKey:@"B"];
                                long long t = [[inviteDic objectForKey:@"T"] longLongValue];
                                [userInfoDic setObject:b forKey:@"UserInfo"];
                                [userInfoDic setObject:@(t) forKey:@"LastUpdateTime"];
                            }
                            [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertFriendNotifyList:list];
                        } else if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
                            
                            NSMutableArray *userList = [NSMutableArray arrayWithCapacity:1];
                            for (NSString *userID in userIds) {
                                
                                NSDictionary *userInfoD = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByJID:userID];
                                if (userInfoD == nil) {
                                    
                                    userInfoD = [[IMDataManager qimDB_SharedInstance] qimDB_selectUserByJID:[NSString stringWithFormat:@"%@@%@", userID, [self getDomain]]];
                                }
                                NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionaryWithDictionary:userInfoD];
                                NSString *userId = [userInfoDic objectForKey:@"UserId"];
                                NSDictionary *inviteDic = [userInviteDic objectForKey:userId];
                                NSString *b = [inviteDic objectForKey:@"B"];
                                long long t = [[inviteDic objectForKey:@"T"] longLongValue];
                                [userInfoDic setQIMSafeObject:b forKey:@"UserInfo"];
                                [userInfoDic setQIMSafeObject:@(t) forKey:@"LastUpdateTime"];
                                [userList addObject:userInfoDic];
                            }
                            [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertFriendNotifyList:userList];
                        }
                        if (resultArray.count > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                QIMVerboseLog(@"抛出通知 updateFriendInviteList:  kNotificationSessionListUpdate");
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
                            });
                        }
                    }
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (NSDictionary *)getLastFriendNotify {
    return nil;
    return [[IMDataManager qimDB_SharedInstance] qimDB_getLastFriendNotify];
}

- (NSInteger)getFriendNotifyCount {
    return 0;
    return [[IMDataManager qimDB_SharedInstance] qimDB_getFriendNotifyCount];
}

@end
