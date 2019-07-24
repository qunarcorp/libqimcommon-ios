//
//  IMDataManager+QIMDBFriend.m
//  QIMCommon
//
//  Created by 李露 on 11/24/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager+QIMDBFriend.h"
#import "QIMDataBase.h"
#import "QIMPublicRedefineHeader.h"

@implementation IMDataManager (QIMDBFriend)

/*************** Friend List *************/

- (void)qimDB_bulkInsertFriendList:(NSArray *)friendList {
    if (friendList.count <= 0) {
        return;
    }
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableString *deleteSql = [NSMutableString stringWithString:@"Delete From IM_Friend_List Where UserId not in ("];
        NSString *sql = @"Insert or replace Into IM_Friend_List(UserId,XmppId,Name,DescInfo,HeaderSrc,SearchIndex,UserInfo,IncrementVersion,LastUpdateTime) values(:UserId,:XmppId,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:UserInfo,:IncrementVersion,:LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDic in friendList) {
            NSString *userId = [infoDic objectForKey:@"UserId"];
            if (userId.length <= 0) {
                continue;
            }
            if ([infoDic isEqual:[friendList lastObject]]) {
                [deleteSql appendFormat:@"'%@');",userId];
            } else {
                [deleteSql appendFormat:@"'%@',",userId];
            }
            NSString *xmppId = [infoDic objectForKey:@"XmppId"];
            NSString *name = [infoDic objectForKey:@"Name"];
            NSString *descInfo = [infoDic objectForKey:@"DescInfo"];
            NSString *searchIndex = [infoDic objectForKey:@"SearchIndex"];
            NSString *headerSrc = [infoDic objectForKey:@"HeaderSrc"];
            NSDictionary *userInfo = [infoDic objectForKey:@"UserInfo"];
            NSNumber *incrementVersion = [infoDic objectForKey:@"Version"];
            NSNumber *lastUpdateTime = [infoDic objectForKey:@"LastUpdateTime"];
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userId?userId:@":NULL"];
            [param addObject:xmppId?xmppId:@":NULL"];
            [param addObject:name?name:@":NULL"];
            [param addObject:descInfo?descInfo:@":NULL"];
            [param addObject:headerSrc?headerSrc:@":NULL"];
            [param addObject:searchIndex?searchIndex:@":NULL"];
            NSData *userInfoData = nil;
            if (userInfo) {
                userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
            }
            [param addObject:userInfoData?userInfoData:@":NULL"];
            [param addObject:incrementVersion?incrementVersion:@":NULL"];
            [param addObject:lastUpdateTime?lastUpdateTime:@":NULL"];
            [params addObject:param];
        }
        [database executeNonQuery:deleteSql withParameters:nil];
        [database executeBulkInsert:sql withParameters:params];
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"插入好友列表%ld条数据 耗时 = %f s", friendList.count, end - start); //s
}

- (void)qimDB_insertFriendWithUserId:(NSString *)userId
                          WithXmppId:(NSString *)xmppId
                            WithName:(NSString *)name
                     WithSearchIndex:(NSString *)searchIndex
                        WithDescInfo:(NSString *)descInfo
                         WithHeadSrc:(NSString *)headerSrc
                        WithUserInfo:(NSData *)userInfo
                  WithLastUpdateTime:(long long)lastUpdateTime
                WithIncrementVersion:(int)incrementVersion {
    if (userId.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert Into IM_Friend_List(UserId,XmppId,Name,DescInfo,HeaderSrc,SearchIndex,UserInfo,IncrementVersion,LastUpdateTime) values(:UserId,:XmppId,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:UserInfo,:IncrementVersion,:LastUpdateTime);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId?userId:@":NULL"];
        [param addObject:xmppId?xmppId:@":NULL"];
        [param addObject:name?name:@":NULL"];
        [param addObject:searchIndex?searchIndex:@":NULL"];
        [param addObject:descInfo?descInfo:@":NULL"];
        [param addObject:headerSrc?headerSrc:@":NULL"];
        NSData *userInfoData = nil;
        if (userInfo) {
            userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
        }
        [param addObject:userInfoData?userInfoData:@":NULL"];
        [param addObject:@(incrementVersion)];
        [param addObject:@(lastUpdateTime)];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteFriendListWithXmppId:(NSString *)xmppId {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Friend_List Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[xmppId]];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteFriendListWithUserId:(NSString *)userId {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Friend_List Where UserId=:UserId;";
        [database executeNonQuery:sql withParameters:@[userId]];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteFriendList {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSql = @"Delete From IM_Friend_List;";
        [database executeNonQuery:deleteSql withParameters:nil];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteSessionList {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSql = @"Delete From IM_SessionList;";
        [database executeNonQuery:deleteSql withParameters:nil];
    }];
    QIMVerboseLog(@"");
}

- (NSMutableArray *)qimDB_selectFriendList {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo,SearchIndex From IM_Friend_List Order By Name Desc;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *userInfoData = [reader objectForColumnIndex:5];
            NSData *SearchIndex = [reader objectForColumnIndex:6];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:paramDic setObject:name.length>0?name:userId forKey:@"Name"];
            [IMDataManager safeSaveForDic:paramDic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:paramDic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:paramDic setObject:SearchIndex forKey:@"SearchIndex"];
            if (userInfoData) {
                [IMDataManager safeSaveForDic:paramDic setObject:[NSKeyedUnarchiver unarchiveObjectWithData:userInfoData] forKey:@"UserInfo"];
            }
            [resultList addObject:paramDic];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

- (NSMutableArray *)qimDB_selectFriendListInGroupId:(NSString *)groupId {
    if (groupId.length <= 0) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select a.UserId,a.XmppId,b.Name,b.HeaderSrc,b.SearchIndex from IM_Friend_List as a join IM_Users as b where a.XmppId = b.XmppId and a.XmppId NOT IN(select MemberJid from IM_Group_Member where GroupId = '%@');", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSData *SearchIndex = [reader objectForColumnIndex:4];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:paramDic setObject:name.length>0?name:userId forKey:@"Name"];
            [IMDataManager safeSaveForDic:paramDic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:paramDic setObject:SearchIndex forKey:@"SearchIndex"];
            [resultList addObject:paramDic];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

- (NSDictionary *)qimDB_selectFriendInfoWithUserId:(NSString *)userId {
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo From IM_Friend_List Where XmppId= '%@';", userId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *userInfoData = [reader objectForColumnIndex:5];
            resultDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:resultDic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:resultDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:resultDic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:resultDic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:resultDic setObject:headerSrc forKey:@"HeaderSrc"];
            if (userInfoData) {
                [IMDataManager safeSaveForDic:resultDic setObject:[NSKeyedUnarchiver unarchiveObjectWithData:userInfoData] forKey:@"UserInfo"];
            }
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return resultDic;
}

- (NSDictionary *)qimDB_selectFriendInfoWithXmppId:(NSString *)xmppId {
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo From IM_Friend_List Where XmppId='%@';", xmppId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *userInfoData = [reader objectForColumnIndex:5];
            resultDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:resultDic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:resultDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:resultDic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:resultDic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:resultDic setObject:headerSrc forKey:@"HeaderSrc"];
            if (userInfoData) {
                [IMDataManager safeSaveForDic:resultDic setObject:[NSKeyedUnarchiver unarchiveObjectWithData:userInfoData] forKey:@"UserInfo"];
            }
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return resultDic;
}

- (void)qimDB_bulkInsertNotifyList:(NSArray *)notifyList {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert Or Replace Into IM_Friend_Notify(UserId,XmppId,Name,DescInfo,HeaderSrc,SearchIndex,UserInfo,Version,State,LastUpdateTime) values(:UserId,:XmppId,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:UserInfo,:Version,:State,:LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in notifyList) {
            NSString *userId = [dic objectForKey:@"UserId"];
            NSString *xmppId = [dic objectForKey:@"XmppId"];
            NSString *name = [dic objectForKey:@"Name"];
            NSString *descInfo = [dic objectForKey:@"DescInfo"];
            NSString *headerSrc = [dic objectForKey:@"HeaderSrc"];
            NSString *searchIndex = [dic objectForKey:@"SearchIndex"];
            NSString *userInfo = [dic objectForKey:@"UserInfo"];
            int state = [[dic objectForKey:@"State"] intValue];
            long long lastUpdateTime = [[dic objectForKey:@"LastUpdateTime"] longLongValue];
            int version =[[dic objectForKey:@"Version"] intValue];
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userId?userId:@":NULL"];
            [param addObject:xmppId?xmppId:@":NULL"];
            [param addObject:name?name:@":NULL"];
            [param addObject:descInfo?descInfo:@":NULL"];
            [param addObject:headerSrc?headerSrc:@":NULL"];
            [param addObject:searchIndex?searchIndex:@":NULL"];
            NSData *userInfoData = nil;
            if (userInfo) {
                userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
            }
            [param addObject:userInfoData?userInfoData:@":NULL"];
            [param addObject:@(version)];
            [param addObject:@(state)];
            [param addObject:@(lastUpdateTime)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_bulkInsertFriendNotifyList:(NSArray *)notifyList {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert Or Replace Into IM_Friend_Notify(UserId,XmppId,Name,DescInfo,HeaderSrc,SearchIndex,UserInfo,Version,State,LastUpdateTime) values(:UserId,:XmppId,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:UserInfo,:Version,:State,:LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *userInfoDic in notifyList) {
            NSString *userId = [userInfoDic objectForKey:@"UserId"];
            NSString *xmppId = [userInfoDic objectForKey:@"XmppId"];
            NSString *name = [userInfoDic objectForKey:@"Name"];
            NSString *descInfo = [userInfoDic objectForKey:@"DescInfo"];
            NSString *headerSrc = [userInfoDic objectForKey:@"HeaderSrc"];
            NSString *searchIndex = [userInfoDic objectForKey:@"SearchIndex"];
            NSString *userInfo = [userInfoDic objectForKey:@"UserInfo"];
            int version = 0;
            int state = [[userInfoDic objectForKey:@"State"] intValue];
            long long lastUpdateTime = [[userInfoDic objectForKey:@"LastUpdateTime"] longLongValue];
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userId?userId:@":NULL"];
            [param addObject:xmppId?xmppId:@":NULL"];
            [param addObject:name?name:@":NULL"];
            [param addObject:descInfo?descInfo:@":NULL"];
            [param addObject:headerSrc?headerSrc:@":NULL"];
            [param addObject:searchIndex?searchIndex:@":NULL"];
            NSData *userInfoData = nil;
            if (userInfo) {
                userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
            }
            [param addObject:userInfoData?userInfoData:@":NULL"];
            [param addObject:@(version)];
            [param addObject:@(state)];
            [param addObject:@(lastUpdateTime)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
    QIMVerboseLog(@"");
}
- (void)qimDB_insertFriendNotifyWithUserId:(NSString *)userId
                                WithXmppId:(NSString *)xmppId
                                  WithName:(NSString *)name
                              WithDescInfo:(NSString *)descInfo
                               WithHeadSrc:(NSString *)headerSrc
                           WithSearchIndex:(NSString *)searchIndex
                              WithUserInfo:(NSString *)userInfo
                               WithVersion:(int)version
                                 WithState:(int)state
                        WithLastUpdateTime:(long long)lastUpdateTime {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert Or Replace Into IM_Friend_Notify(UserId,XmppId,Name,DescInfo,HeaderSrc,SearchIndex,UserInfo,Version,State,LastUpdateTime) values(:UserId,:XmppId,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:UserInfo,:Version,:State,:LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        [params addObject:userId?userId:@":NULL"];
        [params addObject:xmppId?xmppId:@":NULL"];
        [params addObject:name?name:@":NULL"];
        [params addObject:descInfo?descInfo:@":NULL"];
        [params addObject:headerSrc?headerSrc:@":NULL"];
        [params addObject:searchIndex?searchIndex:@":NULL"];
        NSData *userInfoData = nil;
        if (userInfo) {
            userInfoData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
        }
        [params addObject:userInfoData?userInfoData:@":NULL"];
        [params addObject:@(version)];
        [params addObject:@(state)];
        [params addObject:@(lastUpdateTime)];
        [database executeNonQuery:sql withParameters:params];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteFriendNotifyWithUserId:(NSString *)userId {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Friend_Notify Where UserId=:UserId;";
        [database executeNonQuery:sql withParameters:@[userId]];
    }];
    QIMVerboseLog(@"");
}

- (NSMutableArray *)qimDB_selectFriendNotifys {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo,State,LastUpdateTime From IM_Friend_Notify Order By LastUpdateTime Desc;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *userInfoData = [reader objectForColumnIndex:5];
            NSDictionary *userInfo = nil;
            if (userInfoData) {
                userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
            }
            NSNumber *state = [reader objectForColumnIndex:6];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:paramDic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:paramDic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:paramDic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:paramDic setObject:userInfo forKey:@"UserInfo"];
            [IMDataManager safeSaveForDic:paramDic setObject:state forKey:@"State"];
            [resultList addObject:paramDic];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

- (NSDictionary *)qimDB_getLastFriendNotify {
    __block NSMutableDictionary *friendNotify = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo,State,LastUpdateTime From IM_Friend_Notify Order By LastUpdateTime DESC Limit 1;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            friendNotify = [[NSMutableDictionary alloc] init];
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *userInfoData = [reader objectForColumnIndex:5];
            NSDictionary *userInfo = nil;
            if (userInfoData) {
                userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
            }
            NSNumber *state = [reader objectForColumnIndex:6];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:7];
            friendNotify = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:friendNotify setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:friendNotify setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:friendNotify setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:friendNotify setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:friendNotify setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:friendNotify setObject:userInfo forKey:@"UserInfo"];
            [IMDataManager safeSaveForDic:friendNotify setObject:state forKey:@"State"];
            [IMDataManager safeSaveForDic:friendNotify setObject:lastUpdateTime forKey:@"LastUpdateTime"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return friendNotify;
}

- (int)qimDB_getFriendNotifyCount {
    
    __block int FriendNotifyCount = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo,State,LastUpdateTime From IM_Friend_Notify Order By LastUpdateTime Desc;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSNumber *state = [reader objectForColumnIndex:6];
            if ([state isEqualToNumber:@(0)]) {
                FriendNotifyCount++;
            }
        }
    }];
    QIMVerboseLog(@"");
    return FriendNotifyCount;
}

- (void)qimDB_updateFriendNotifyWithXmppId:(NSString *)xmppId WithState:(int)state {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Friend_Notify Set State = :State Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[@(state),xmppId]];
    }];
    QIMVerboseLog(@"");
}

- (long long)qimDB_getMaxTimeFriendNotify {
    __block long long maxTime = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select Max(LastUpdateTime) From IM_Friend_Notify;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            maxTime = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return maxTime;
}

@end
