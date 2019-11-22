//
//  STIMManager+Calendar.m
//  STIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMManager+Calendar.h"

@implementation STIMManager (Calendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_SelectTripByYearMonth:date];
}

- (void)getRemoteUserTripList {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/get_update_list.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"获取该用户会议列表q_ckey : %@", requestHeaders);
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    long long version = [[[IMDataManager stIMDB_SharedInstance] stIMDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:STIMClientConfigTypeKLocalTripUpdateTime] WithSubKey:[[STIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
    
    [bodyProperties setSTIMSafeObject:[NSString stringWithFormat:@"%lld", version] forKey:@"updateTime"];
    [bodyProperties setSTIMSafeObject:[[STIMManager sharedInstance] getLastJid] forKey:@"userName"];
    
    STIMVerboseLog(@"获取该用户会议列表Body : %@", [[STIMJSONSerializer sharedInstance] serializeObject:bodyProperties]);
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    request.HTTPRequestHeaders = cookieProperties;
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSDictionary *tripsData = [result objectForKey:@"data"];
                NSArray *tripsList = [tripsData objectForKey:@"trips"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertTrips:tripsList];

                NSString *updateTime = [tripsData objectForKey:@"updateTime"];
                NSString *jid = [[STIMManager sharedInstance] getLastJid];
                NSArray *configArray = @[@{@"subkey":jid?jid:@"", @"configinfo":updateTime}];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertConfigArrayWithConfigKey:[self transformClientConfigKeyWithType:STIMClientConfigTypeKLocalTripUpdateTime] WithConfigVersion:0 ConfigArray:configArray];
            }
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"获取该用户会议列表失败 : Error : %@", error);
    }];
}

- (void)createTrip:(NSDictionary *)param callBack:(STIMKitCreateTripBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/reserve_scheduling.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"新建行程或更新已有行程q_ckey : %@", requestHeaders);
    STIMVerboseLog(@"新建行程或更新已有行程Body : %@", [[STIMJSONSerializer sharedInstance] serializeObject:param]);

    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:param error:nil]];
    request.HTTPRequestHeaders = cookieProperties;
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSDictionary *tripsData = [result objectForKey:@"data"];
                
                NSArray *tripsList = [tripsData objectForKey:@"trips"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertTrips:tripsList];
                
                NSString *updateTime = [tripsData objectForKey:@"updateTime"];
                NSString *jid = [[STIMManager sharedInstance] getLastJid];
                NSArray *configArray = @[@{@"subkey":jid?jid:@"", @"configinfo":updateTime}];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertConfigArrayWithConfigKey:[self transformClientConfigKeyWithType:STIMClientConfigTypeKLocalTripUpdateTime] WithConfigVersion:0 ConfigArray:configArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(YES, nil);
                    }
                });
            } else {
                NSString *errmsg = [result objectForKey:@"errmsg"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(NO, errmsg);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(NO, @"预定会议室失败");
                }
            });
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"新建行程或更新已有行程失败 : Error : %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(NO, @"预定会议室失败");
            }
        });
    }];
}

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(STIMKitGetTripAreaAvailableRoomBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/room_list.qunar",  [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"根据时间和区域id查询可预定会议室q_ckey : %@", requestHeaders);
    STIMVerboseLog(@"根据时间和区域id查询可预定会议室 Body : %@", [[STIMJSONSerializer sharedInstance] serializeObject:dateDic]);
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:dateDic error:nil]];
    request.HTTPRequestHeaders = cookieProperties;
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSArray *availableRoomData = [result objectForKey:@"data"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(availableRoomData);
                    }
                });
            }
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"根据时间和区域id查询可预定会议室失败 : Error : %@", error);
    }];
}

- (void)tripMemberCheck:(NSDictionary *)params callback:(STIMKitGetTripMemberCheckBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/get_scheduling_conflict.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"检查用户该时间段是否有冲突行程q_ckey : %@", requestHeaders);
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:params error:nil]];
    request.HTTPRequestHeaders = cookieProperties;
    
    STIMVerboseLog(@"检查用户该时间段是否有冲突行程Body : %@", [[STIMJSONSerializer sharedInstance] serializeObject:params]);
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSDictionary *resultData = [result objectForKey:@"data"];
                BOOL isConform = [[resultData objectForKey:@"isConform"] boolValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(isConform);
                    }
                });
            }
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"检查用户该时间段是否有冲突行程失败 : Error : %@", error);
    }];
}

- (void)getAllCityList:(STIMKitGetTripAllCitysBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/allCitys.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"获取所有城市q_ckey : %@", requestHeaders);
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodGET];
    request.HTTPRequestHeaders = cookieProperties;
    
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSArray *resultData = [result objectForKey:@"data"];
                if ([resultData isKindOfClass:[NSArray class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(resultData);
                        }
                    });
                }
            }
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"检查用户该时间段是否有冲突行程失败 : Error : %@", error);
    }];
}

- (void)getAreaByCityId:(NSDictionary *)params :(STIMKitGetTripAreaAvailableRoomByCityIdBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/getAreaByCityId.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"根据城市Id获取可用画区域参数q_ckey : %@", requestHeaders);
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:params error:nil]];
    request.HTTPRequestHeaders = cookieProperties;

    STIMVerboseLog(@"根据城市Id获取可用画区域参数 : %@", [[STIMJSONSerializer sharedInstance] serializeObject:params]);

    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSDictionary *resultData = [result objectForKey:@"data"];
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    NSArray *areaList = [resultData objectForKey:@"list"];
                    if ([areaList isKindOfClass:[NSArray class]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (callback) {
                                callback(areaList);
                            }
                        });
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"检查用户该时间段是否有冲突行程失败 : Error : %@", error);
    }];
}

- (NSArray *)getLocalAreaList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getLocalArea];
}

- (void)getRemoteAreaList {
    NSString *destUrl = [NSString stringWithFormat:@"%@/scheduling/area_list.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"获取远端支持的行程区域q_ckey : %@", requestHeaders);
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    request.useCookiePersistence = NO;
    request.HTTPRequestHeaders = cookieProperties;
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            if ([[result objectForKey:@"ret"] boolValue]) {
                NSDictionary *areaData = [result objectForKey:@"data"];
                NSArray *areaList = [areaData objectForKey:@"list"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertArea:areaList];
            }
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"获取远端支持的行程区域失败 : Error : %@", error);
    }];
}

@end
