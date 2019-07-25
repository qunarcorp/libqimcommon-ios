//
//  QIMManager+Found.m
//  QIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMManager+Found.h"

@implementation QIMManager (Found)

- (void)getRemoteFoundNavigation {
    NSString *destUrl = [[QIMNavConfigManager sharedInstance] foundConfigUrl];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    QIMVerboseLog(@"获取发现页应用列表q_ckey : %@", requestHeaders);
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    long long version = [[[IMDataManager qimDB_SharedInstance] qimDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalTripUpdateTime] WithSubKey:[[QIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
    
    [bodyProperties setQIMSafeObject:@([[[QIMAppInfo sharedInstance] AppBuildVersion] integerValue]) forKey:@"version"];
    [bodyProperties setQIMSafeObject:@"IOS" forKey:@"platform"];
    
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:[[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil] withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSArray class]]) {
                NSString *rndataStr = [[QIMJSONSerializer sharedInstance] serializeObject:data];
                [[IMDataManager qimDB_SharedInstance] qimDB_insertFoundListWithAppVersion:[[QIMAppInfo sharedInstance] AppBuildVersion] withFoundList:rndataStr];
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (NSString *)getLocalFoundNavigation {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getFoundListWithAppVersion:[[QIMAppInfo sharedInstance] AppBuildVersion]];
}

@end
