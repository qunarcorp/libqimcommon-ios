//
//  QIMManager+Search.h
//  QIMCommon
//
//  Created by lilu on 2019/6/19.
//

#import "QIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMManager (Search)

- (void)searchWithUrl:(NSString *)url withParams:(NSDictionary *)params withSuccessCallBack:(QIMKitSearchSuccessBlock)successCallback withFaildCallBack:(QIMKitSearchFaildBlock)faildCallback;

#pragma mark - Searchkey History

- (void)getRemoteSearchKeyHistory;

- (NSArray *)getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit;

- (void)updateLocalSearchKeyHistory:(NSDictionary *)searchDic;

- (void)deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType;

- (void)deleteSearchKeyHistory;

@end

NS_ASSUME_NONNULL_END
