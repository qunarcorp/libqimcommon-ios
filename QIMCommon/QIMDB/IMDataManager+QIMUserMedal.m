//
//  IMDataManager+QIMUserMedal.m
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager+QIMUserMedal.h"
#import "QIMDataBase.h"

@implementation IMDataManager (QIMUserMedal)

- (NSArray *)qimDB_getUserMedalsWithXmppId:(NSString *)xmppId {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select XmppId, Type, URL, URLDesc, LastUpdateTime From IM_Users_Medal Where XmppId='%@' Order By LastUpdateTime Desc;", xmppId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *XmppId = [reader objectForColumnIndex:0];
            NSString *type = [reader objectForColumnIndex:1];
            NSString *URL = [reader objectForColumnIndex:2];
            NSString *URLDesc = [reader objectForColumnIndex:3];
            NSNumber *LastUpdateTime = [reader objectForColumnIndex:4];

            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:XmppId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:type forKey:@"type"];
            [IMDataManager safeSaveForDic:paramDic setObject:URL forKey:@"url"];
            [IMDataManager safeSaveForDic:paramDic setObject:URLDesc forKey:@"desc"];
            [IMDataManager safeSaveForDic:paramDic setObject:LastUpdateTime forKey:@"LastUpdateTime"];
            [resultList addObject:paramDic];
        }
        
    }];
    return resultList;
}

- (void)qimDB_bulkInsertUserMedalsWithData:(NSArray *)userMedals {
    if (userMedals.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableArray *params = [[NSMutableArray alloc] init];
        NSString *sql = [NSString stringWithFormat:@"insert or Replace into IM_Users_Medal(XmppId, Type, URL, URLDesc, LastUpdateTime) values(:XmppId, :Type, :URL, :URLDesc, :LastUpdateTime);"];
        for (NSDictionary *dic in userMedals) {
            NSString *userId = [dic objectForKey:@"userId"];
            NSString *host = [dic objectForKey:@"host"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@", userId, host];
            NSString *type = [dic objectForKey:@"type"];
            NSString *url = [dic objectForKey:@"url"];
            NSString *urldesc = [dic objectForKey:@"desc"];
            NSNumber *updateTime = [dic objectForKey:@"upt"];
            
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
            [param addObject:xmppId ? xmppId : @""];
            [param addObject:type ? type : @""];
            [param addObject:url ? url : @":NULL"];
            [param addObject:urldesc ? urldesc : @""];
            [param addObject:updateTime ? updateTime : @(0)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

@end
