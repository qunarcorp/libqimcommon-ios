//
//  IMDataManager+STIMSearchKeyHistory.h
//  STIMCommon
//
//  Created by lilu on 2019/6/27.
//

#import "IMDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMSearchKeyHistory)

- (NSArray *)stIMDB_getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit;

- (void)stIMDB_updateLocalSearchKeyHistory:(NSDictionary *)searchDic;

- (void)stIMDB_deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType;

- (void)stIMDB_deleteSearchKeyHistory;

@end

NS_ASSUME_NONNULL_END
