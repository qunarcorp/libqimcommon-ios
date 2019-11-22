
//
//  IMDataManager+STIMFoundList.m
//  STIMCommon
//
//  Created by lilu on 2019/4/17.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "IMDataManager+STIMFoundList.h"
#import "STIMDataBase.h"

@implementation IMDataManager (STIMFoundList)

- (void)stIMDB_insertFoundListWithAppVersion:(NSString *)version withFoundList:(NSString *)foundListStr {
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or replace into IM_Found_List(version, foundList) Values(:version, :foundList)";
        NSMutableArray *parames = [[NSMutableArray alloc] init];
        [parames addObject:version];
        [parames addObject:foundListStr?foundListStr:@":NULL"];
        [database executeNonQuery:sql withParameters:parames];
        parames = nil;
    }];
}

- (NSString *)stIMDB_getFoundListWithAppVersion:(NSString *)version {
    __block NSString *result = nil;
    [[self dbInstance] inDatabase:^(STIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT foundList FROM IM_Found_List WHERE version = %@", version];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            result = [reader objectForColumnIndex:0];
        }
        [reader close];
    }];
    return result;
}

@end
