//
//  IMDataManager+STIMSearchKeyHistory.m
//  STIMCommon
//
//  Created by lilu on 2019/6/27.
//

#import "IMDataManager+STIMSearchKeyHistory.h"
#import "STIMDataBase.h"

@implementation IMDataManager (STIMSearchKeyHistory)

- (NSArray *)stIMDB_getLocalSearchKeyHistoryWithSearchType:(NSInteger)searchType withLimit:(NSInteger)limit {

    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(STIMDataBase *database) {
        NSString *sql = [NSString stringWithFormat:@"select searchKey from IM_SearchHistory where searchType = %d order by searchTime desc limit %d", searchType, limit];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (nil == result) {
                result = [NSMutableArray arrayWithCapacity:3];
            }
            NSString *searchKey = [reader objectForColumnIndex:0];
            if (searchKey.length > 0) {
                [result addObject:searchKey];
            }
        }
    }];
    return result;
}

- (void)stIMDB_updateLocalSearchKeyHistory:(NSDictionary *)searchDic {
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase *database, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"insert or replace into IM_SearchHistory(searchKey, searchType, searchTime) values(:searchKey, :searchType, :searchTime)"];
        NSString *searchKey = [searchDic objectForKey:@"searchKey"];
        NSInteger searchType = [[searchDic objectForKey:@"searchType"] integerValue];
        NSInteger searchTime = [[searchDic objectForKey:@"searchTime"] integerValue];
        if (searchTime <= 0) {
            searchTime = [NSDate timeIntervalSinceReferenceDate] * 1000;
        }
        NSMutableArray *params = [[NSMutableArray alloc] init];
        [params addObject:searchKey ? searchKey : @":NULL"];
        [params addObject:@(searchType)];
        [params addObject:@(searchTime)];
        [database executeNonQuery:sql withParameters:params];
    }];
}

- (void)stIMDB_deleteSearchKeyHistoryWithSearchType:(NSInteger)searchType {
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase *database, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_SearchHistory where searchType = %ld", searchType];
        [database executeNonQuery:sql withParameters:nil];
    }];
}

- (void)stIMDB_deleteSearchKeyHistory {
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase *database, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_SearchHistory"];
        [database executeNonQuery:sql withParameters:nil];
    }];
}

@end
