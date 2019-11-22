//
//  STIMKit+STIMSearch.m
//  STIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "STIMKit+STIMSearch.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMSearch)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(STIMKitSearchSuccessBlock)successCallback withFaildCallBack:(STIMKitSearchFaildBlock)faildCallback {
    [[STIMManager sharedInstance] searchWithUrl:url withParams:params withSuccessCallBack:successCallback withFaildCallBack:faildCallback];
}

#pragma mark - Searchkey History

- (void)getRemoteSearchKeyHistory {
    [[STIMManager sharedInstance] getRemoteSearchKeyHistory];
}

- (NSArray *)getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit {
    return [[STIMManager sharedInstance] getLocalSearchKeyHistoryWithSearchType:searchType withLimit:limit];
}

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic {
    [[STIMManager sharedInstance] updateLocalSearchKeyHistory:searchDic];
}

- (void)deleteSearchKeyHistory {
    [[STIMManager sharedInstance] deleteSearchKeyHistory];
}

@end
