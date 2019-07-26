//
//  QIMManager+PublicNavUserManager.m
//  QIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMManager+PublicNavUserManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (PublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(QIMKitgetPublicCompanySuccessedBlock)callback {
    if (keyword.length <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(@[]);
            }
        });
    }
    keyword = [keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *destUrl = [NSString stringWithFormat:@"%@%@", [[QIMNavConfigManager sharedInstance] getPubSearchUserHostUrl], [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
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
