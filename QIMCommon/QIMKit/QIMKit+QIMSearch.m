//
//  QIMKit+QIMSearch.m
//  QIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "QIMKit+QIMSearch.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMSearch)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(QIMKitSearchSuccessBlock)successCallback withFaildCallBack:(QIMKitSearchFaildBlock)faildCallback {
    [[QIMManager sharedInstance] searchWithUrl:url withParams:params withSuccessCallBack:successCallback withFaildCallBack:faildCallback];
}

#pragma mark - Searchkey History

- (void)getRemoteSearchKeyHistory {
    [[QIMManager sharedInstance] getRemoteSearchKeyHistory];
}

- (NSArray *)getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit {
    return [[QIMManager sharedInstance] getLocalSearchKeyHistoryWithSearchType:searchType withLimit:limit];
}

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic {
    [[QIMManager sharedInstance] updateLocalSearchKeyHistory:searchDic];
}

- (void)deleteSearchKeyHistory {
    [[QIMManager sharedInstance] deleteSearchKeyHistory];
}

@end
