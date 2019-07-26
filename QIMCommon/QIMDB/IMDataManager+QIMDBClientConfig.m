//
//  IMDataManager+QIMDBClientConfig.m
//  QIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "IMDataManager+QIMDBClientConfig.h"
#import "QIMDataBase.h"

@implementation IMDataManager (QIMDBClientConfig)

- (void)qimDB_clearClientConfig {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"delete from IM_Client_Config";
        [database executeNonQuery:sql withParameters:nil];
    }];
    QIMVerboseLog(@"");
}

- (NSInteger)qimDB_getConfigVersion {
    __block NSInteger configVersion = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select ConfigVersion from IM_Client_Config order by ConfigVersion DESC limit(1);";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            configVersion = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return configVersion;
}

- (void)qimDB_deleteConfigWithConfigKey:(NSString *)configKey {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Client_Config Where ConfigKey = '%@'", configKey];
        [database executeNonQuery:sql withParameters:nil];
    }];
    QIMVerboseLog(@"");
}

- (NSInteger)qimDB_getConfigDeleteFlagWithConfigKey:(NSString *)configKey WithSubKey:(NSString *)subKey {
    __block NSInteger delegetFlag = -1;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select DeleteFlag from IM_Client_Config Where ConfigKey = '%@' And ConfigSubKey = '%@'", configKey, subKey];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            delegetFlag = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return delegetFlag;
}

- (NSString *)qimDB_getConfigInfoWithConfigKey:(NSString *)configKey WithSubKey:(NSString *)subKey WithDeleteFlag:(BOOL)deleteFlag {
    __block NSString *configValue = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql =  [NSString stringWithFormat:@"select ConfigValue from IM_Client_Config where ConfigKey = '%@' And ConfigSubKey = '%@' And DeleteFlag = %d limit 1;", configKey, subKey, deleteFlag];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            configValue = [reader objectForColumnIndex:0];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return configValue;
}

- (NSMutableDictionary *)qimDB_getConfigDicWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql =  [NSString stringWithFormat:@"select ConfigSubKey, ConfigValue from IM_Client_Config where ConfigKey = '%@' And DeleteFlag = %d;", configKey, deleteFlag];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableDictionary alloc] init];
            }
            NSString *configSubKey = [reader objectForColumnIndex:0];
            NSString *configValue = [reader objectForColumnIndex:1];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setQIMSafeObject:configSubKey forKey:@"ConfigSubKey"];
            [dic setQIMSafeObject:configValue forKey:@"ConfigValue"];
            
            [result setQIMSafeObject:dic forKey:configSubKey];
        }
    }];
    QIMVerboseLog(@"");
    return result;
}

- (NSArray *)qimDB_getConfigInfoArrayWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql =  [NSString stringWithFormat:@"select ConfigSubKey, ConfigValue from IM_Client_Config where ConfigKey = '%@' And DeleteFlag = %d;", configKey, deleteFlag];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            NSString *configSubKey = [reader objectForColumnIndex:0];
            NSString *configValue = [reader objectForColumnIndex:1];
            NSInteger deleteFlag = [[reader objectForColumnIndex:2] integerValue];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setQIMSafeObject:configSubKey forKey:@"ConfigSubKey"];
            [dic setQIMSafeObject:configValue forKey:@"ConfigValue"];
            [dic setQIMSafeObject:@(deleteFlag) forKey:@"DeleteFlag"];
            [result addObject:dic];
        }
    }];
    QIMVerboseLog(@"");
    return result;
}

- (NSArray *)qimDB_getConfigValueArrayWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql =  [NSString stringWithFormat:@"select ConfigValue from IM_Client_Config where ConfigKey = '%@' And DeleteFlag = %d;", configKey, deleteFlag];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            NSString *configValue = [reader objectForColumnIndex:0];
            [result addObject:configValue];
        }
    }];
    QIMVerboseLog(@"");
    return result;
}

- (void)qimDB_bulkInsertConfigArrayWithConfigKey:(NSString *)configKey WithConfigVersion:(NSInteger)configVersion ConfigArray:(NSArray *)configArray {
    if (configKey.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase * _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or replace into IM_Client_Config(ConfigKey, ConfigSubKey, ConfigValue, ConfigVersion, DeleteFlag) values(:ConfigKey, :ConfigSubKey, :ConfigValue, :ConfigVersion, :DeleteFlag)";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary * info in configArray) {
            /* {
             configinfo = "https://qim.qunar.com/file/v2/download/perm/4c2fa68a2ea22d741de647167795a584.gif";
             isdel = 0;
             subkey = 4c2fa68a2ea22d741de647167795a584;
             } */
            
            NSString *subKey = [info objectForKey:@"subkey"];
            NSString *configInfo = [info objectForKey:@"configinfo"];
            NSInteger isDel = [[info objectForKey:@"isdel"] integerValue];
            
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:4];
            [param addObject:configKey ? configKey : @":NULL"];
            [param addObject:subKey ? subKey : @":NULL"];
            [param addObject:configInfo ? configInfo : @":NULL"];
            [param addObject:@(configVersion)];
            [param addObject:@(isDel)];
            
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
    QIMVerboseLog(@"");
}

// ********************* 黑名单&星标联系人 ************************ //
-(NSMutableArray *)qimDB_getConfigArrayStarOrBlackContacts:(NSString *)pkey{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select b.UserId,a.ConfigSubKey,b.Name,b.HeaderSrc from IM_Client_Config as a left JOIN IM_Users as b on a.ConfigSubKey = b.XmppId where a.DeleteFlag = 0 and ConfigKey= '%@';",pkey];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppid = [reader objectForColumnIndex:1];
            NSString *nickName = [reader objectForColumnIndex:2];
            NSString *headUrl = [reader objectForColumnIndex:3];

            //Comment by lilulucas.li 9.28
//            if (![headUrl qim_hasPrefixHttpHeader] && [headUrl hasPrefix:@"file/v"]) {
//                headUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headUrl];
//            }
            
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:userId forKey:@"userId"];
            [IMDataManager safeSaveForDic:value setObject:xmppid forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:value setObject:nickName forKey:@"Name"];
            [IMDataManager safeSaveForDic:value setObject:headUrl forKey:@"HeaderUri"];
            [resultList addObject:value];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

-(NSMutableArray *)qimDB_getConfigArrayFriendsNotInStarContacts{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select a.UserId,a.XmppId,b.Name,b.HeaderSrc from IM_Friend_List as a left join IM_Users as b on a.XmppId = b.XmppId where a.XmppId not in (select ConfigSubKey from IM_Client_Config where ConfigKey='%@' and DeleteFlag = %d);",@"kStarContact",0];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppid = [reader objectForColumnIndex:1];
            NSString *nickName = [reader objectForColumnIndex:2];
            NSString *headUrl = [reader objectForColumnIndex:3];
            
            //Comment by lilulucas.li 9.28
//            if (![headUrl qim_hasPrefixHttpHeader] && [headUrl hasPrefix:@"file/v"]) {
//                headUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headUrl];
//            }
            
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:userId forKey:@"userId"];
            [IMDataManager safeSaveForDic:value setObject:xmppid forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:value setObject:nickName forKey:@"Name"];
            [IMDataManager safeSaveForDic:value setObject:headUrl forKey:@"HeaderUri"];
            [resultList addObject:value];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

-(NSMutableArray *)qimDB_getConfigArrayUserNotInStartContacts:(NSString *)key{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select UserId,XmppId,Name,HeaderSrc from IM_Users Where (UserId like %%%@%% or Name like  %%%@%% or SearchIndex like %%%@%%) and XmppId NOT IN(select ConfigSubKey from IM_Users_CONFIG where ConfigKey = '%@' and DeleteFlag = %d) order by UserId limit 100; ",key,key,key,@"kStarContact",0];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppid = [reader objectForColumnIndex:1];
            NSString *nickName = [reader objectForColumnIndex:2];
            NSString *headUrl = [reader objectForColumnIndex:3];
            //Comment by lilulucas.li 9.28
//            if (![headUrl qim_hasPrefixHttpHeader] && [headUrl hasPrefix:@"file/v"]) {
//                headUrl = [NSString stringWithFormat:@"%@/%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], headUrl];
//            }
            
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:userId forKey:@"userId"];
            [IMDataManager safeSaveForDic:value setObject:xmppid forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:value setObject:nickName forKey:@"Name"];
            [IMDataManager safeSaveForDic:value setObject:headUrl forKey:@"HeaderUri"];
            [resultList addObject:value];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}


@end
