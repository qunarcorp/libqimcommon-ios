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

@end
