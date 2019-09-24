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

/**************************************新版勋章********************************/


/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectMedalListVersion {
    __block NSInteger result = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select valueInt from IM_Cache_Data where key=? and type=?"];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@"medalListVersionValue"];
        [param addObject:@(10)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        if ([reader read]) {
            result = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
        
    }];
    return result;
}

/**
 查询勋章状态版本号
 */
- (NSInteger)qimDB_selectUserMedalStatusVersion {
    __block NSInteger result = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select valueInt from IM_Cache_Data where key=? and type=?"];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@"medalUserStatusValue"];
        [param addObject:@(10)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        if ([reader read]) {
            result = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
        
    }];
    return result;
}


/// 插入勋章列表
/// @param medalList 勋章列表List
- (void)qimDB_bulkInsertMedalList:(NSArray *)medalList {
    if (!medalList.count) {
        return;
    }
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase * _Nonnull db, BOOL * _Nonnull rollback) {
       NSMutableArray *params = [[NSMutableArray alloc] init];
        /*
         
         medalId               INTEGER,\
         medalName             TEXT,\
         obtainCondition       TEXT,\
         smallIcon             TEXT,\
         bigLightIcon          TEXT,\
         bigGrayIcon           TEXT,\
         bigLockIcon           BLOB,\
         status                INTEGER,\
         primary key           (medalId)
         */
        
          NSString *sql = [NSString stringWithFormat:@"insert or Replace into IM_Medal_List(medalId, medalName, obtainCondition, smallIcon, bigLightIcon, bigGrayIcon, bigLockIcon, status) values(:medalId, :medalName, :obtainCondition, :smallIcon, :bigLightIcon, :bigGrayIcon, :bigLockIcon, :status);"];
          for (NSDictionary *dic in medalList) {
              
              NSInteger medalId = [[dic objectForKey:@"id"] integerValue];
              NSString *medalName = [dic objectForKey:@"medalName"];
              NSString *obtainCondition = [dic objectForKey:@"obtainCondition"];
              
              NSDictionary *iconDic = [dic objectForKey:@"icon"];
              NSString *smallIcon = [iconDic objectForKey:@"small"];
              NSString *bigLightIcon = [iconDic objectForKey:@"bigLight"];
              NSString *bigGrayIcon = [iconDic objectForKey:@"bigGray"];
              NSString *bigLockIcon = [iconDic objectForKey:@"bigLock"];
              
              NSInteger status = [[dic objectForKey:@"status"] integerValue];
              
              NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
              [param addObject:@(medalId)];
              [param addObject:medalName ? medalName : @":NULL"];
              [param addObject:obtainCondition ? obtainCondition : @":NULL"];
              [param addObject:smallIcon ? smallIcon : @":NULL"];
              [param addObject:bigLightIcon ? bigLightIcon : @":NULL"];
              [param addObject:bigGrayIcon ? bigGrayIcon : @":NULL"];
              [param addObject:bigLockIcon ? bigLockIcon : @":NULL"];
              [param addObject:@(status)];
              [params addObject:param];
          }
          [db executeBulkInsert:sql withParameters:params];
    }];
}

- (void)qimDB_bulkInsertUserMedalList:(NSArray *)medalList {
    if (!medalList.count) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase * _Nonnull db, BOOL * _Nonnull rollback) {
       NSMutableArray *params = [[NSMutableArray alloc] init];
        /*
         CREATE TABLE IF NOT EXISTS IM_User_Status_Medal(\
         medalId               INTEGER,\
         userId                TEXT,\
         medalStatus           INTEGER,\
         mappingVersion        INTEGER,\
         updateTime            TEXT,\
         primary key  (medalId,userId));
         */
          NSString *sql = [NSString stringWithFormat:@"insert or Replace into IM_User_Status_Medal(medalId, userId, medalStatus, mappingVersion, updateTime) values(:medalId, :userId, :medalStatus, :mappingVersion, :updateTime);"];
          for (NSDictionary *dic in medalList) {
              
              NSInteger medalId = [[dic objectForKey:@"medalId"] integerValue];
              NSString *userId = [dic objectForKey:@"userId"];
              if (userId.length <= 0) {
                  continue;
              }
              NSInteger medalStatus = [[dic objectForKey:@"medalStatus"] integerValue];
              NSInteger mappingVersion = [[dic objectForKey:@"mappingVersion"] integerValue];
              NSInteger updateTime = [[dic objectForKey:@"updateTime"] integerValue];
                            
              NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
              [param addObject:@(medalId)];
              [param addObject:userId ? userId : @":NULL"];
              [param addObject:@(medalStatus)];
              [param addObject:@(mappingVersion)];
              [param addObject:@(updateTime)];
              [params addObject:param];
          }
          [db executeBulkInsert:sql withParameters:params];
    }];
}

- (NSArray *)qimDB_selectUserHaveMedalStatus:(NSString *)userId {
    if (userId.length <= 0) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon, a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), COALESCE(medalStatus, 0) from IM_Medal_List as a left join IM_User_Status_Medal as b on a.medalid  = b.medalid and b.UserId = ? where  a.status = 1 order by b.medalStatus desc, b.updateTime";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *medalid = [reader objectForColumnIndex:0];
            NSString *medalName = [reader objectForColumnIndex:1];
            NSString *obtainCondition = [reader objectForColumnIndex:2];
            NSString *smallIcon = [reader objectForColumnIndex:3];
            NSString *bigLightIcon = [reader objectForColumnIndex:4];
            NSString *BigGrayIcon = [reader objectForColumnIndex:5];
            NSString *bigLockIcon = [reader objectForColumnIndex:6];
            NSNumber *status = [reader objectForColumnIndex:7];
            
            
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:medalid forKey:@"medalid"];
            [IMDataManager safeSaveForDic:paramDic setObject:medalName forKey:@"medalName"];
            [IMDataManager safeSaveForDic:paramDic setObject:obtainCondition forKey:@"obtainCondition"];
            [IMDataManager safeSaveForDic:paramDic setObject:smallIcon forKey:@"smallIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLightIcon forKey:@"bigLightIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:BigGrayIcon forKey:@"BigGrayIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLockIcon forKey:@"bigLockIcon"];

            [resultList addObject:paramDic];
        }
    }];
    return resultList;
}

- (NSArray *)qimDB_selectUserWearMedalStatusByUserid:(NSString *)userId {
    if (userId.length <= 0) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon, a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), b.medalStatus, 0 from IM_Medal_List as a left join IM_User_Status_Medal as b on a.medalid  = b.medalid and b.UserId = ? where a.status = 1 and (b.medalStatus & 0x02 = 0x02) order by b.medalStatus desc, b.updateTime";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *medalid = [reader objectForColumnIndex:0];
            NSString *medalName = [reader objectForColumnIndex:1];
            NSString *obtainCondition = [reader objectForColumnIndex:2];
            NSString *smallIcon = [reader objectForColumnIndex:3];
            NSString *bigLightIcon = [reader objectForColumnIndex:4];
            NSString *BigGrayIcon = [reader objectForColumnIndex:5];
            NSString *bigLockIcon = [reader objectForColumnIndex:6];
            NSNumber *status = [reader objectForColumnIndex:7];
            NSString *userId = [reader objectForColumnIndex:8];
            NSNumber *medalStatus = [reader objectForColumnIndex:9];
            
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:medalid forKey:@"medalid"];
            [IMDataManager safeSaveForDic:paramDic setObject:medalName forKey:@"medalName"];
            [IMDataManager safeSaveForDic:paramDic setObject:obtainCondition forKey:@"obtainCondition"];
            [IMDataManager safeSaveForDic:paramDic setObject:smallIcon forKey:@"smallIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:@"http:\/\/l-im1.vc.beta.cn0.qunar.com:9090\/file\/v2\/download\/temp\/new\/48c774c0cad68ff209c0ce887ec9abff.png?name=48c774c0cad68ff209c0ce887ec9abff.png" forKey:@"smallIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLightIcon forKey:@"bigLightIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:BigGrayIcon forKey:@"bigGrayIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLockIcon forKey:@"bigLockIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:status forKey:@"status"];
            [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"medalUserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:medalStatus forKey:@"medalUserStatus"];
            
            [resultList addObject:paramDic];
        }
    }];
    return resultList;
}

- (void)qimDB_updateMedalListVersion:(NSInteger)medalListVersion {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableArray *params = [[NSMutableArray alloc] init];
        
        NSString *sql = @"insert or replace into IM_Cache_Data(key, type, value, valueInt) Values(?, ?, ?, ?);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@"medalListVersionValue"];
        [param addObject:@(10)];
        [param addObject:@"勋章列表增量版本"];
        [param addObject:@(medalListVersion)];
        
        [params addObject:param];
        [database executeBulkInsert:sql withParameters:params];
    }];
}

@end
