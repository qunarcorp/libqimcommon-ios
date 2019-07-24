
//
//  IMDataManager+QIMFoundList.m
//  QIMCommon
//
//  Created by lilu on 2019/4/17.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "IMDataManager+QIMFoundList.h"
#import "QIMDataBase.h"

@implementation IMDataManager (QIMFoundList)

- (void)qimDB_insertFoundListWithAppVersion:(NSString *)version withFoundList:(NSString *)foundListStr {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or replace into IM_Found_List(version, foundList) Values(:version, :foundList)";
        NSMutableArray *parames = [[NSMutableArray alloc] init];
        [parames addObject:version];
        [parames addObject:foundListStr?foundListStr:@":NULL"];
        [database executeNonQuery:sql withParameters:parames];
        parames = nil;
    }];
}

- (NSString *)qimDB_getFoundListWithAppVersion:(NSString *)version {
    __block NSString *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
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
