//
//  STIMManager+Found.m
//  STIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMManager+Found.h"

@implementation STIMManager (Found)

- (void)getRemoteFoundNavigation {
    NSString *destUrl = [[STIMNavConfigManager sharedInstance] foundConfigUrl];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    STIMVerboseLog(@"获取发现页应用列表q_ckey : %@", requestHeaders);
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    long long version = [[[IMDataManager stIMDB_SharedInstance] stIMDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:STIMClientConfigTypeKLocalTripUpdateTime] WithSubKey:[[STIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
    
    [bodyProperties setSTIMSafeObject:@([[[STIMAppInfo sharedInstance] AppBuildVersion] integerValue]) forKey:@"version"];
    [bodyProperties setSTIMSafeObject:@"IOS" forKey:@"platform"];
    
    [[STIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:[[STIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil] withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSArray class]]) {
                NSString *rndataStr = [[STIMJSONSerializer sharedInstance] serializeObject:data];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_insertFoundListWithAppVersion:[[STIMAppInfo sharedInstance] AppBuildVersion] withFoundList:rndataStr];
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (NSString *)getLocalFoundNavigation {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getFoundListWithAppVersion:[[STIMAppInfo sharedInstance] AppBuildVersion]];
}

@end
