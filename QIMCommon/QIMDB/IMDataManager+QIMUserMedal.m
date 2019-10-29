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


/// 插入勋章列表增量更新版本号
/// @param medalListVersion 版本号
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


/// 插入用户勋章更新增量版本号
/// @param medalListVersion 版本号
- (void)qimDB_updateUserMedalStatusVersion:(NSInteger)userMedalStatusVersion {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableArray *params = [[NSMutableArray alloc] init];
        
        NSString *sql = @"insert or replace into IM_Cache_Data(key, type, value, valueInt) Values(?, ?, ?, ?);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@"medalUserStatusValue"];
        [param addObject:@(10)];
        [param addObject:@"用户勋章列表增量版本"];
        [param addObject:@(userMedalStatusVersion)];
        
        [params addObject:param];
        [database executeBulkInsert:sql withParameters:params];
    }];
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


/// 插入用户勋章列表
/// @param medalList 用户的勋章列表
- (void)qimDB_bulkInsertUserMedalList:(NSArray *)medalList {
    if (!medalList.count) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase * _Nonnull db, BOOL * _Nonnull rollback) {
       NSMutableArray *params = [[NSMutableArray alloc] init];
          NSString *sql = [NSString stringWithFormat:@"insert or Replace into IM_User_Status_Medal(medalId, userId, host, medalStatus, mappingVersion, updateTime) values(:medalId, :userId, :host, :medalStatus, :mappingVersion, :updateTime);"];
          for (NSDictionary *dic in medalList) {
              
              NSInteger medalId = [[dic objectForKey:@"medalId"] integerValue];
              NSString *userId = [dic objectForKey:@"userId"];
              if (userId.length <= 0) {
                  continue;
              }
              NSString *host = [dic objectForKey:@"host"];
              if (host.length <= 0) {
                  continue;
              }
              NSInteger medalStatus = [[dic objectForKey:@"medalStatus"] integerValue];
              NSInteger mappingVersion = [[dic objectForKey:@"mappingVersion"] integerValue];
              NSInteger updateTime = [[dic objectForKey:@"updateTime"] integerValue];
                            
              NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
              [param addObject:@(medalId)];
              [param addObject:userId ? userId : @":NULL"];
              [param addObject:host ? host : @":NULL"];
              [param addObject:@(medalStatus)];
              [param addObject:@(mappingVersion)];
              [param addObject:@(updateTime)];
              [params addObject:param];
          }
          [db executeBulkInsert:sql withParameters:params];
    }];
}


/// 更新某个勋章的佩戴状态
/// @param userMedalDic 勋章佩戴状态
- (void)qimDB_updateUserMedalStatus:(NSDictionary *)userMedalDic {
    if (userMedalDic.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"update IM_User_Status_Medal set mappingVersion=:mappingVersion, medalStatus=:medalStatus, updateTime=:updateTime where userId=:userId and host=:host and medalId=:medalId"];
        
        NSString *userId = [userMedalDic objectForKey:@"userId"];
        NSString *host = [userMedalDic objectForKey:@"host"];
        NSInteger medalId = [[userMedalDic objectForKey:@"medalId"] integerValue];
        NSInteger medalStatus = [[userMedalDic objectForKey:@"medalStatus"] integerValue];
        NSInteger mappingVersion = [[userMedalDic objectForKey:@"mappingVersion"] integerValue];
        long long updateTime = [[userMedalDic objectForKey:@"updateTime"] longLongValue];
        
        NSMutableArray *params = [[NSMutableArray alloc] init];
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
        [param addObject:@(mappingVersion)];
        [param addObject:@(medalStatus)];
        [param addObject:@(updateTime)];
        [param addObject:userId ? userId : @":NULL"];
        [param addObject:host ? host : @":NULL"];
        [param addObject:@(medalId)];
        [params addObject:param];
        [db executeBulkInsert:sql withParameters:params];
    }];
}

/// 获取某用户下的某勋章详情
/// @param medalId 勋章Id
/// @param userId 用户Id
/// @param host 用户Host
- (NSDictionary *)qimDB_getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId {
    if (userId.length <= 0) {
         return nil;
     }
     __block NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
     [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
         NSString *sql = @"select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon, a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), COALESCE(host, ?), b.medalStatus, (select count(*) from IM_User_Status_Medal where medalId=a.medalId and (medalStatus & 0x02 = 0x02 or medalStatus & 0x01 = 0x01)) as userCount from IM_Medal_List as a left join IM_User_Status_Medal as b on a.medalid  = b.medalid and b.medalid = ? and b.UserId = ? and b.host = ? where a.status = 1 and (b.medalStatus & 0x02 = 0x02 or b.medalStatus & 0x01 = 0x01) order by b.medalStatus desc, b.updateTime;";
         NSMutableArray *param = [[NSMutableArray alloc] init];
         NSString *userName = [[userId componentsSeparatedByString:@"@"] firstObject];
         NSString *userHost = [[userId componentsSeparatedByString:@"@"] lastObject];
         [param addObject:userName];
         [param addObject:userHost];
         [param addObject:@(medalId)];
         [param addObject:userName];
         [param addObject:userHost];
         DataReader *reader = [database executeReader:sql withParameters:param];
         if ([reader read]) {
             NSString *medalid = [reader objectForColumnIndex:0];
             NSString *medalName = [reader objectForColumnIndex:1];
             NSString *obtainCondition = [reader objectForColumnIndex:2];
             NSString *smallIcon = [reader objectForColumnIndex:3];
             NSString *bigLightIcon = [reader objectForColumnIndex:4];
             NSString *BigGrayIcon = [reader objectForColumnIndex:5];
             NSString *bigLockIcon = [reader objectForColumnIndex:6];
             NSNumber *status = [reader objectForColumnIndex:7];
             NSString *userId = [reader objectForColumnIndex:8];
             NSString *host = [reader objectForColumnIndex:9];
             NSNumber *medalStatus = [reader objectForColumnIndex:10];
             NSNumber *userCount = [reader objectForColumnIndex:11];
             
             [IMDataManager safeSaveForDic:paramDic setObject:medalid forKey:@"medalId"];
             [IMDataManager safeSaveForDic:paramDic setObject:medalName forKey:@"medalName"];
             [IMDataManager safeSaveForDic:paramDic setObject:obtainCondition forKey:@"obtainCondition"];
             [IMDataManager safeSaveForDic:paramDic setObject:smallIcon forKey:@"smallIcon"];
             [IMDataManager safeSaveForDic:paramDic setObject:bigLightIcon forKey:@"bigLightIcon"];
             [IMDataManager safeSaveForDic:paramDic setObject:(BigGrayIcon.length > 0) ? BigGrayIcon : bigLightIcon forKey:@"bigGrayIcon"];
             [IMDataManager safeSaveForDic:paramDic setObject:bigLockIcon forKey:@"bigLockIcon"];
             [IMDataManager safeSaveForDic:paramDic setObject:status forKey:@"status"];
             [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"medalUserId"];
             [IMDataManager safeSaveForDic:paramDic setObject:host forKey:@"medalUserHost"];
             [IMDataManager safeSaveForDic:paramDic setObject:medalStatus forKey:@"medalUserStatus"];
             [IMDataManager safeSaveForDic:paramDic setObject:userCount forKey:@"userCount"];
         }
         [reader close];
     }];
     return paramDic;
}


/// 获取用户所拥有的所有勋章列表
/// @param userId 用户Id
- (NSArray *)qimDB_selectUserWearMedalStatusByUserid:(NSString *)userId {
    if (userId.length <= 0) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon, a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), COALESCE(host, ?), COALESCE(b.medalStatus, 0), (select count(*) from IM_User_Status_Medal as e where e.medalId=a.medalId and (e.medalstatus & 0x01 = 0x01 or e.medalStatus & 0x02 = 0x02)) as userCount from IM_Medal_List as a left join IM_User_Status_Medal as b on a.medalid  = b.medalid and b.UserId = ? and b.Host = ? where a.status = 1 order by b.medalStatus desc, b.updateTime;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        NSString *userName = [[userId componentsSeparatedByString:@"@"] firstObject];
        NSString *userHost = [[userId componentsSeparatedByString:@"@"] lastObject];
        [param addObject:userName];
        [param addObject:userHost];
        [param addObject:userName];
        [param addObject:userHost];
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
            NSString *userHost = [reader objectForColumnIndex:9];
            NSNumber *medalStatus = [reader objectForColumnIndex:10];
            NSNumber *userCount = [reader objectForColumnIndex:11];
            
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:medalid forKey:@"medalId"];
            [IMDataManager safeSaveForDic:paramDic setObject:medalName forKey:@"medalName"];
            [IMDataManager safeSaveForDic:paramDic setObject:obtainCondition forKey:@"obtainCondition"];
            [IMDataManager safeSaveForDic:paramDic setObject:smallIcon forKey:@"smallIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLightIcon forKey:@"bigLightIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:(BigGrayIcon.length > 0) ? BigGrayIcon : bigLightIcon forKey:@"bigGrayIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLockIcon forKey:@"bigLockIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:status forKey:@"status"];
            [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"medalUserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:userHost forKey:@"medalUserHost"];
            [IMDataManager safeSaveForDic:paramDic setObject:medalStatus forKey:@"medalUserStatus"];
            [IMDataManager safeSaveForDic:paramDic setObject:userCount forKey:@"userCount"];
            
            [resultList addObject:paramDic];
        }
    }];
    return resultList;
}

/// 获取某个勋章下的用户list
/// @param medalId 勋章Id
/// @param limit limit
/// @param offset offset
- (NSArray *)qimDB_getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase * _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select d.UserId, d.XmppId, d.Name, d.DescInfo, d.headersrc from im_users as d left join (select b.UserId||'@'||b.host as XmppId from IM_Medal_List as a left join IM_User_Status_Medal as b on a.medalid = b.medalId where b.medalId = ? and a.status = 1 and (b.medalstatus & 0x01 = 0x01 or b.medalStatus & 0x02 = 0x02) order by b.updateTime desc LIMIT ? OFFSET ?) as c where d.XmppId = c.XmppId;"];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@(medalId)];
        [param addObject:@(limit)];
        [param addObject:@(offset)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *userName = [reader objectForColumnIndex:2];
            NSString *DescInfo = [reader objectForColumnIndex:3];
            NSString *headersrc = [reader objectForColumnIndex:4];
            
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:paramDic setObject:userName forKey:@"Name"];
            [IMDataManager safeSaveForDic:paramDic setObject:DescInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:paramDic setObject:headersrc forKey:@"HeaderSrc"];
            [resultList addObject:paramDic];
        }
    }];
    return resultList;
}

@end
