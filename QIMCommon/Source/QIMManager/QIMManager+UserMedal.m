//
//  QIMManager+UserMedal.m
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMManager+UserMedal.h"

@implementation QIMManager (UserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getUserMedalsWithXmppId:xmppId];
}

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId {
    NSString *destUrl = [NSString stringWithFormat:@"%@/user/get_user_decoration.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyProperty = [[NSMutableDictionary alloc] initWithCapacity:3];
    [bodyProperty setQIMSafeObject:[[xmppId componentsSeparatedByString:@"@"] firstObject] forKey:@"userId"];
    [bodyProperty setQIMSafeObject:[[xmppId componentsSeparatedByString:@"@"] lastObject] forKey:@"host"];
    NSData *bodyData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyProperty error:nil];
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSArray class]]) {
                NSLog(@"str : %@", data);
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertUserMedalsWithData:data];
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
- (void)userMedalStatusModifyWithStatus:(NSInteger)status withMedalId:(NSInteger)medalId withCallBack:(QIMKitUpdateMedalStatusCallBack)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/userMedalStatusModify.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"userId":[QIMManager getLastUserName], @"host" : [[QIMManager sharedInstance] getDomain], @"medalStatus":@(status), @"medalId":@(medalId)};
    NSData *bodyData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            [[IMDataManager qimDB_SharedInstance] qimDB_updateUserMedalStatus:data];
            if (callback) {
                callback(YES, nil);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNewUserMedalList object:[[QIMManager sharedInstance] getLastJid]];
            });
        } else {
            NSString *errmsg = [responseDic objectForKey:@"errmsg"];
            if (callback) {
                callback(NO, errmsg);
            }
        }
        QIMVerboseLog(@"修改勋章佩戴状态 : %@", responseDic);
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
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/allMedalUser.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"medalId":@(0), @"offset":@(0), @"limit":@(10)};
    NSData *bodyData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        QIMVerboseLog(@"获取这个勋章下的所有用户 : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

/**
 * 获取用户勋章列表
 *  @param
 * @param callback
 */
- (void)getRemoteUserMedalListWithUserId:(NSString *)userId {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/userMedalList.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{/*@"userId":[[userId componentsSeparatedByString:@"@"] firstObject], @"host" : [[userId componentsSeparatedByString:@"@"] lastObject],*/ @"version":@([[IMDataManager qimDB_SharedInstance] qimDB_selectUserMedalStatusVersion])};
    NSData *bodyData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            NSArray *userMedals = [data objectForKey:@"userMedals"];
            if ([userMedals isKindOfClass:[NSArray class]]) {
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertUserMedalList:userMedals];
            }
            long long version = [[data objectForKey:@"version"] longLongValue];
            [[IMDataManager qimDB_SharedInstance] qimDB_updateUserMedalStatusVersion:version];
        }
        QIMVerboseLog(@"responseDic : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

/**
 获取远程勋章列表
 */
- (void)getRemoteMedalList {
    NSString *destUrl = [NSString stringWithFormat:@"%@/medal/medalList.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"version":@([[IMDataManager qimDB_SharedInstance] qimDB_selectMedalListVersion])};
    NSData *bodyData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            NSArray *medalList = [data objectForKey:@"medalList"];
            if ([medalList isKindOfClass:[NSArray class]]) {
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertMedalList:medalList];
            }
            NSInteger version = [[data objectForKey:@"version"] integerValue];
            [[IMDataManager qimDB_SharedInstance] qimDB_updateMedalListVersion:version];
        }
        QIMVerboseLog(@"responseDic : %@", responseDic);
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

#pragma mark - Local UserMedal

/// 获取某用户下的某勋章
/// @param medalId 勋章Id
/// @param userId 用户Id
/// @param host 用户Host
- (NSDictionary *)getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getUserMedalWithMedalId:medalId withUserId:userId];
}

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_selectUserWearMedalStatusByUserid:userId];
}

- (NSArray *)getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getUsersInMedal:medalId withLimit:limit withOffset:offset];
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
