//
//  QIMManager+Search.m
//  QIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "QIMManager+Search.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (Search)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(QIMKitSearchSuccessBlock)successCallback withFaildCallBack:(QIMKitSearchFaildBlock)faildCallback {
    
    NSInteger action = [[params objectForKey:@"action"] integerValue];
    NSData *bodyData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [self sendTPPOSTRequestWithUrl:url withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            NSString *responseJson = [[QIMJSONSerializer sharedInstance] serializeObject:responseDic];
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
    NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getLocalSearchKeyHistoryWithSearchType:searchType withLimit:5];
    return array;
}

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateLocalSearchKeyHistory:searchDic];
}

- (void)deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteSearchKeyHistoryWithSearchType:searchType];
}

- (void)deleteSearchKeyHistory {
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteSearchKeyHistory];
}

@end
