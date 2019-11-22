//
//  STIMManager+Search.m
//  STIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "STIMManager+Search.h"
#import "STIMPrivateHeader.h"

@implementation STIMManager (Search)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(STIMKitSearchSuccessBlock)successCallback withFaildCallBack:(STIMKitSearchFaildBlock)faildCallback {
    
    NSInteger action = [[params objectForKey:@"action"] integerValue];
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [self sendTPPOSTRequestWithUrl:url withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            NSString *responseJson = [[STIMJSONSerializer sharedInstance] serializeObject:responseDic];
            if (successCallback) {
                successCallback(YES, responseJson);
            }
        } else {
            if (faildCallback) {
                faildCallback(NO, nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (faildCallback) {
            faildCallback(YES, nil);
        }
    }];
}

#pragma mark - SearchKey History

- (void)getRemoteSearchKeyHistory {
    
}

- (NSArray *)getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit {
    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getLocalSearchKeyHistoryWithSearchType:searchType withLimit:5];
    return array;
}

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateLocalSearchKeyHistory:searchDic];
}

- (void)deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSearchKeyHistoryWithSearchType:searchType];
}

- (void)deleteSearchKeyHistory {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSearchKeyHistory];
}

@end
