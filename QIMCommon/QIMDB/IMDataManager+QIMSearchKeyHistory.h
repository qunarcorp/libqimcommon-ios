//
//  IMDataManager+QIMSearchKeyHistory.h
//  QIMCommon
//
//  Created by lilu on 2019/6/27.
//

#import "IMDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMSearchKeyHistory)

- (NSArray *)qimDB_getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit;

- (void)qimDB_updateLocalSearchKeyHistory:(NSDictionary *)searchDic;

- (void)qimDB_deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType;

- (void)qimDB_deleteSearchKeyHistory;

@end

NS_ASSUME_NONNULL_END
