//
//  STIMManager+Search.h
//  STIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "STIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMManager (Search)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(STIMKitSearchSuccessBlock)successCallback withFaildCallBack:(STIMKitSearchFaildBlock)faildCallback;

#pragma mark - Searchkey History

- (void)getRemoteSearchKeyHistory;

- (NSArray *)getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit;

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic;

- (void)deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType;

- (void)deleteSearchKeyHistory;

@end

NS_ASSUME_NONNULL_END
