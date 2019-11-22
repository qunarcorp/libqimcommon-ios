//
//  STIMManager+UserMedal.m
//  STIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMManager+UserMedal.h"

@implementation STIMManager (UserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserMedalsWithXmppId:xmppId];
}

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId {
    NSString *destUrl = [NSString stringWithFormat:@"%@/user/get_user_decoration.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyProperty = [[NSMutableDictionary alloc] initWithCapacity:3];
    [bodyProperty setSTIMSafeObject:[[xmppId componentsSeparatedByString:@"@"] firstObject] forKey:@"userId"];
    [bodyProperty setSTIMSafeObject:[[xmppId componentsSeparatedByString:@"@"] lastObject] forKey:@"host"];
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyProperty error:nil];
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSArray class]]) {
                NSLog(@"str : %@", data);
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertUserMedalsWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateUserMedal object:@{@"UserId":xmppId, @"UserMedals":data}];
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

/**************************************新版勋章********************************/


/**
 修改勋章佩戴状态

 @param status 勋章佩戴状态
 @param medalId 勋章Id
 */
- (void)userMedalStatusModifyWithStatus:(NSInteger)status withMedalId:(NSInteger)medalId withCallBack:(STIMKitUpdateMedalStatusCallBack)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/userMedalStatusModify.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"userId":[STIMManager getLastUserName], @"host" : [[STIMManager sharedInstance] getDomain], @"medalStatus":@(status), @"medalId":@(medalId)};
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_updateUserMedalStatus:data];
            if (callback) {
                callback(YES, nil);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNewUserMedalList object:[[STIMManager sharedInstance] getLastJid]];
            });
        } else {
            NSString *errmsg = [responseDic objectForKey:@"errmsg"];
            if (callback) {
                callback(NO, errmsg);
            }
        }
        STIMVerboseLog(@"修改勋章佩戴状态 : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO, @"修改状态失败");
        }
    }];
}

/**
 获取这个勋章下的所有用户
 */
- (void)getAllMedalUser {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/allMedalUser.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"medalId":@(0), @"offset":@(0), @"limit":@(10)};
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        STIMVerboseLog(@"获取这个勋章下的所有用户 : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

/**
 * 获取用户勋章列表
 *  @param
 * @param callback
 */
- (void)getRemoteUserMedalListWithUserId:(NSString *)userId {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/userMedalList.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{/*@"userId":[[userId componentsSeparatedByString:@"@"] firstObject], @"host" : [[userId componentsSeparatedByString:@"@"] lastObject],*/ @"version":@([[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserMedalStatusVersion])};
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            NSArray *userMedals = [data objectForKey:@"userMedals"];
            if ([userMedals isKindOfClass:[NSArray class]]) {
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertUserMedalList:userMedals];
            }
            long long version = [[data objectForKey:@"version"] longLongValue];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_updateUserMedalStatusVersion:version];
        }
        STIMVerboseLog(@"responseDic : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

/**
 获取远程勋章列表
 */
- (void)getRemoteMedalList {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/medalList.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"version":@([[IMDataManager stIMDB_SharedInstance] stIMDB_selectMedalListVersion])};
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            NSArray *medalList = [data objectForKey:@"medalList"];
            if ([medalList isKindOfClass:[NSArray class]]) {
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertMedalList:medalList];
            }
            NSInteger version = [[data objectForKey:@"version"] integerValue];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMedalListVersion:version];
        }
        STIMVerboseLog(@"responseDic : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

#pragma mark - Local UserMedal

/// 获取某用户下的某勋章
/// @param medalId 勋章Id
/// @param userId 用户Id
/// @param host 用户Host
- (NSDictionary *)getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserMedalWithMedalId:medalId withUserId:userId];
}

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_selectUserWearMedalStatusByUserid:userId];
}

- (NSArray *)getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getUsersInMedal:medalId withLimit:limit withOffset:offset];
}

- (NSArray *)getUserWearMedalSmallIconListByUserid:(NSString *)xmppId {
    NSArray *localUserMedals = [self getUserWearMedalStatusByUserid:xmppId];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSDictionary *medalDic in localUserMedals) {
       
        NSInteger medalStatus = [[medalDic objectForKey:@"medalUserStatus"] integerValue];
        NSString *medalSmallIcon = [medalDic objectForKey:@"smallIcon"];
        if ((medalStatus & 0x02) == 0x02) {
            if (medalSmallIcon.length > 0) {
                [tempArray addObject:medalSmallIcon];
            }
        }
    }
    return tempArray;
}

- (NSArray *)getUserHaveMedalSmallIconListByUserid:(NSString *)xmppId {
    NSArray *localUserMedals = [self getUserWearMedalStatusByUserid:xmppId];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSDictionary *medalDic in localUserMedals) {
       
        NSInteger medalStatus = [[medalDic objectForKey:@"medalUserStatus"] integerValue];
        NSString *medalSmallIcon = [medalDic objectForKey:@"smallIcon"];
        if ((medalStatus & 0x02) == 0x02 || (medalStatus & 0x01) == 0x01) {
            if (medalSmallIcon.length > 0) {
                [tempArray addObject:medalSmallIcon];
            }
        }
    }
    return tempArray;
}

@end
