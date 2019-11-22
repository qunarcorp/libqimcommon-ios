//
//  STIMKit+STIMSearch.h
//  STIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "STIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMKit (STIMSearch)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(STIMKitSearchSuccessBlock)successCallback withFaildCallBack:(STIMKitSearchFaildBlock)faildCallback;

#pragma mark - Searchkey History

- (void)getRemoteSearchKeyHistory;

- (NSArray *)getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit;

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic;

- (void)deleteSearchKeyHistory;

@end

NS_ASSUME_NONNULL_END
