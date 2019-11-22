//
//  STIMManager+PublicNavUserManager.m
//  STIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMManager+PublicNavUserManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMManager (PublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(STIMKitgetPublicCompanySuccessedBlock)callback {
    if (keyword.length <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(@[]);
            }
        });
    }
    keyword = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *destUrl = [NSString stringWithFormat:@"%@%@", [[STIMNavConfigManager sharedInstance] getPubSearchUserHostUrl], [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    STIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
            if (ret && errcode == 0) {
                NSArray *data = [result objectForKey:@"data"];
                if ([data isKindOfClass:[NSArray class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(data);
                        }
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(@[]);
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(@[]);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(@[]);
            }
        });
    }];
}

@end
