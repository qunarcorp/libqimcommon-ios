//
//  IMDataManager+QIMDBGroup.m
//  QIMCommon
//
//  Created by 李露 on 11/24/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager+QIMDBGroup.h"
#import "QIMDataBase.h"
#import "QIMPublicRedefineHeader.h"

@implementation IMDataManager (QIMDBGroup)

- (NSInteger)qimDB_getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr {
    __block NSInteger count = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*), a.GroupId, a.Name, a.Introduce, a.HeaderSrc, b.Topic, b.LastUpdateTime, b.ExtendedFlag FROM IM_Group as a Left Join (Select GroupId, Topic, ExtendedFlag, LastUpdateTime From IM_Group Order By LastUpdateTime Desc Limit 1) as b On (a.GroupId=b.GroupId) Where (a.GroupId Like '%%%@') And (a.GroupId Like '%%%@%%' Or a.Name Like '%%%@%%' Or a.Introduce Like '%%%@%%' Or a.Topic Like '%%%@%%') Order By b.LastUpdateTime Desc;", @"ejabhost2", keyStr, keyStr,keyStr, keyStr];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] intValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return count;
}

- (NSArray *)qimDB_rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    
    __block NSMutableArray *ejabHost2GroupList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT a.GroupId, a.Name, a.Introduce, a.HeaderSrc, b.Topic, b.LastUpdateTime, b.ExtendedFlag FROM IM_Group as a Left Join (Select GroupId, Topic, ExtendedFlag, LastUpdateTime From IM_Group Order By LastUpdateTime Desc Limit 1) as b On (a.GroupId=b.GroupId) Where (a.GroupId Like '%%%@') And (a.GroupId Like '%%%@%%' Or a.Name Like '%%%@%%' Or a.Introduce Like '%%%@%%' Or a.Topic Like '%%%@%%') Order By b.LastUpdateTime Desc LIMIT %ld OFFSET %ld;", @"ejabhost2", keyStr, keyStr,keyStr, keyStr, (long)limit, (long)offset];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (ejabHost2GroupList == nil) {
                ejabHost2GroupList = [[NSMutableArray alloc] init];
            }
            NSString *groupId = [reader objectForColumnIndex:0];
            NSString *groupName = [reader objectForColumnIndex:1];
            NSString *groupIntroduce = [reader objectForColumnIndex:2];
            NSString *groupIcon = [reader objectForColumnIndex:3];
            NSString *groupTopic = [reader objectForColumnIndex:4];
            if (!groupIcon) {
                groupIcon = @"";
            }
            if (!groupTopic) {
                groupTopic = @"";
            }
            NSString *label = [NSString stringWithFormat:@"%@", groupName];
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:groupId forKey:@"uri"];
            [IMDataManager safeSaveForDic:value setObject:label forKey:@"label"];
            [IMDataManager safeSaveForDic:value setObject:groupTopic forKey:@"content"];
            [IMDataManager safeSaveForDic:value setObject:groupIcon forKey:@"icon"];
            [ejabHost2GroupList addObject:value];
        }
    }];
    QIMVerboseLog(@"");
    return ejabHost2GroupList;
}

- (NSInteger)qimDB_getLocalGroupTotalCountByUserIds:(NSArray *)userIds{
    __block NSInteger count = 0;
    
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSMutableString *sqlGroupId = [NSMutableString stringWithFormat:@"Select GroupId From IM_Group_Member WHERE"];
        NSMutableString *sqlGroup = [NSMutableString stringWithFormat:@"Select GroupId From IM_Group WHERE "];
        for (NSString *userId in userIds) {
            if ([userId isEqualToString:[userIds firstObject]] || [userId isEqualToString:[userIds lastObject]]) {
                [sqlGroupId appendFormat:@" MemberJid like '%%%@%%'", userId];
                [sqlGroup appendFormat:@"%@", [NSString stringWithFormat:@" GroupId like '%%%@%%' OR Name like '%%%@%%'", userId, userId]];
            } else {
                [sqlGroupId appendFormat:@" OR MemberJid like '%%%@%%'", userId];
                [sqlGroup appendFormat:@"%@", [NSString stringWithFormat:@" OR GroupId like '%%%@%%' OR Name like '%%%@%%'", userId, userId]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"Select COUNT(*) From IM_Group Where GroupId in (%@) OR GroupId in (%@);",sqlGroupId, sqlGroup];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] intValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return count;
}

- (NSArray *)qimDB_searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSMutableArray *groupList = nil;
    
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSMutableString *sqlGroupId = [NSMutableString stringWithFormat:@"Select GroupId From IM_Group_Member WHERE"];
        NSMutableString *sqlGroup = [NSMutableString stringWithFormat:@"Select GroupId From IM_Group WHERE "];
        for (NSString *userId in userIds) {
            if ([userId isEqualToString:[userIds firstObject]] || [userId isEqualToString:[userIds lastObject]]) {
                [sqlGroupId appendFormat:@" MemberJid like '%%%@%%'", userId];
                [sqlGroup appendFormat:@"%@", [NSString stringWithFormat:@" GroupId like '%%%@%%' OR Name like '%%%@%%'", userId, userId]];
            } else {
                [sqlGroupId appendFormat:@" OR MemberJid like '%%%@%%'", userId];
                [sqlGroup appendFormat:@"%@", [NSString stringWithFormat:@" OR GroupId like '%%%@%%' OR Name like '%%%@%%'", userId, userId]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime,ExtendedFlag ,(SELECT max(LastUpdateTime) FROM IM_Message WHERE GroupId = XmppId) AS MsgTime From IM_Group Where GroupId in (%@) OR GroupId in (%@) ORDER By MsgTime Desc,Name ASC LIMIT %ld OFFSET %ld;",sqlGroupId, sqlGroup, (long)limit, (long)offset];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (groupList == nil) {
                groupList = [[NSMutableArray alloc] init];
            }
            
            NSString *groupId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *introduce = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *topic = [reader objectForColumnIndex:4];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:5];
            BOOL ExtendedFlag = [[reader objectForColumnIndex:6] boolValue];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:groupId forKey:@"GroupId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:introduce forKey:@"Introduce"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:dic setObject:topic forKey:@"Topic"];
            [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:dic setObject:@(ExtendedFlag) forKey:@"ExtendedFlag"];
            [groupList addObject:dic];
            
        }
    }];
    QIMVerboseLog(@"");
    return groupList;
}

- (NSArray *)qimDB_getGroupIdList {
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select GroupId From IM_Group";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (groupList == nil) {
                groupList = [[NSMutableArray alloc] init];
            }
            
            NSString *groupId = [reader objectForColumnIndex:0];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:groupId forKey:@"GroupId"];
            [groupList addObject:dic];
            
        }
    }];
    QIMVerboseLog(@"");
    return groupList;
}

- (NSArray *)qimDB_getGroupList {
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime,ExtendedFlag ,(SELECT max(LastUpdateTime) FROM IM_Message WHERE GroupId = XmppId) AS MsgTime From IM_Group ORDER By MsgTime Desc,Name ASC;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (groupList == nil) {
                groupList = [[NSMutableArray alloc] init];
            }
            
            NSString *groupId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *introduce = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *topic = [reader objectForColumnIndex:4];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:5];
            BOOL ExtendedFlag = [[reader objectForColumnIndex:6] boolValue];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:groupId forKey:@"GroupId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:introduce forKey:@"Introduce"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:dic setObject:topic forKey:@"Topic"];
            [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:dic setObject:@(ExtendedFlag) forKey:@"ExtendedFlag"];
            [groupList addObject:dic];
            
        }
    }];
    QIMVerboseLog(@"");
    return groupList;
}

- (NSDictionary *)qimDB_getGroupCardByGroupId:(NSString *)groupId {
    if (groupId.length <= 0) {
        return nil;
    }
//    [[QIMWatchDog sharedInstance] start];
    __block NSMutableDictionary *groupCardDic = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime From IM_Group Where GroupId = '%@';", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            if (groupCardDic == nil) {
                groupCardDic = [[NSMutableDictionary alloc] init];
            }
            
            NSString *groupId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *introduce = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *topic = [reader objectForColumnIndex:4];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:5];
            
            [IMDataManager safeSaveForDic:groupCardDic setObject:groupId forKey:@"GroupId"];
            [IMDataManager safeSaveForDic:groupCardDic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:groupCardDic setObject:introduce forKey:@"Introduce"];
            [IMDataManager safeSaveForDic:groupCardDic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:groupCardDic setObject:topic forKey:@"Topic"];
            [IMDataManager safeSaveForDic:groupCardDic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
//    QIMVerboseLog(@"数据库取群名片耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTime]);
    return groupCardDic;
}

- (NSArray *)qimDB_getGroupVCardByGroupIds:(NSArray *)groupIds{
    if (groupIds.count <= 0) {
        return nil;
    }
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSMutableString *sql = [NSMutableString stringWithString:@"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime From IM_Group Where GroupId in ("];
        int index = 0;
        for (NSString *groupId in groupIds) {
            [sql appendFormat:@"'%@'",groupId];
            if (index < groupIds.count-1) {
                [sql appendFormat:@","];
            } else {
                [sql appendString:@");"];
            }
            index++;
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (groupList == nil) {
                groupList = [[NSMutableArray alloc] init];
            }
            
            NSString *groupId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *introduce = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *topic = [reader objectForColumnIndex:4];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:5];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:groupId forKey:@"GroupId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:introduce forKey:@"Introduce"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:dic setObject:topic forKey:@"Topic"];
            [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [groupList addObject:dic];
            
        }
    }];
    QIMVerboseLog(@"");
    return groupList;
}

- (NSArray *)qimDB_getGroupListMaxLastUpdateTime {
    
    __block NSMutableArray *Im_groupList = [NSMutableArray arrayWithCapacity:5];
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select GroupId, LastUpdateTime FROM IM_Group Order By LastUpdateTime DESC;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSString *groupId = [reader objectForColumnIndex:0];
            if (groupId.length > 0) {
                NSString *lastUpdateTime = [reader objectForColumnIndex:1];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [IMDataManager safeSaveForDic:dic setObject:groupId forKey:@"GroupId"];
                [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"lastUpdateTime"];
                [Im_groupList addObject:dic];
            }
        }
    }];
    QIMVerboseLog(@"");
    return Im_groupList;
}

- (NSArray *)qimDB_getGroupListMsgMaxTime{
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"Select a.GroupId,max(b.LastUpdateTime) FROM IM_Group as a Left join IM_Message as b on a.GroupId = b.XmppId Group by a.GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (groupList == nil) {
                groupList = [[NSMutableArray alloc] init];
            }
            NSString *groupId = [reader objectForColumnIndex:0];
            if (groupId.length > 0) {
                NSNumber *lastUpdateTime = [reader objectForColumnIndex:1];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [IMDataManager safeSaveForDic:dic setObject:groupId forKey:@"GroupId"];
                [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime?lastUpdateTime:@(0) forKey:@"LastUpdateTime"];
                [groupList addObject:dic];
            }
        }
    }];
    QIMVerboseLog(@"");
    return groupList;
}

- (BOOL)qimDB_needUpdateGroupImage:(NSString *)groupId{
    __block BOOL flag = YES;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select ExtendedFlag From IM_Group Where GroupId = '%@';", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            flag = ![[reader objectForColumnIndex:0] boolValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return flag;
}

- (NSString *)qimDB_getGroupHeaderSrc:(NSString *)groupId{
    
    __block NSString *groupHeaderSrc = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select HeaderSrc From IM_Group Where GroupId = '%@';", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            groupHeaderSrc = [reader objectForColumnIndex:0];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return groupHeaderSrc;
}

- (BOOL)qimDB_checkGroup:(NSString *)groupId{
    __block BOOL flag = NO;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select 1 From IM_Group Where GroupId = '%@';", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            flag = YES;
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return flag;
}

- (void)qimDB_bulkinsertGroups:(NSArray *)groups {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        [database executeBulkInsert:@"insert or IGNORE into IM_Group(GroupId, LastUpdateTime) values(:GroupId, :LastUpdateTime);" withParameters:groups];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_insertGroup:(NSString *)groupId {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or IGNORE into IM_Group(GroupId, LastUpdateTime) values(:GroupId, :LastUpdateTime);";
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:3];
        [param addObject:groupId];
        [param addObject:@(0)];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_updateGroup:(NSString *)groupId WithTopic:(NSString *)topic{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set Topic=:Topic Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:2];
        [param addObject:topic?topic:@":NULL"];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_bulkUpdateGroupCards:(NSArray *)array{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set Name=(CASE WHEN :Name ISNULL then Name else :Name1 end),Introduce=(CASE WHEN :Introduce ISNULL then Introduce else :Introduce1 end), HeaderSrc=(CASE WHEN :HeaderSrc ISNULL then HeaderSrc else :HeaderSrc1 end),Topic=(CASE WHEN :Topic ISNULL then Topic else :Topic1 end), LastUpdateTime=:LastUpdateTime, UTLastUpdateTime=:UTLastUpdateTime, ExtendedFlag=:ExtendedFlag Where GroupId = :GroupId;";
        NSMutableArray *paramList = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSMutableDictionary *infoDic in array) {
            NSString *groupId = [infoDic objectForKey:@"MN"];
            NSString *nickName = [infoDic objectForKey:@"SN"];
            NSString *desc = [infoDic objectForKey:@"MD"];
            NSString *topic = [infoDic objectForKey:@"MT"];
            NSString *headerSrc = [infoDic objectForKey:@"MP"];
            NSString *version = [infoDic objectForKey:@"VS"];
            NSInteger UTLastUpdateTime = [[infoDic objectForKey:@"UT"] integerValue];
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:nickName.length > 0?nickName:@":NULL"];
            [param addObject:nickName.length > 0?nickName:@":NULL"];
            [param addObject:desc.length > 0?desc:@":NULL"];
            [param addObject:desc.length > 0?desc:@":NULL"];
            [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
            [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
            [param addObject:topic.length > 0?topic:@":NULL"];
            [param addObject:topic.length > 0?topic:@":NULL"];
            [param addObject:version?version:@"0"];
            [param addObject:@(UTLastUpdateTime)];
            [param addObject:@(headerSrc.length > 0)];
            [param addObject:groupId];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_bulkUpdateIncrementGroupCards:(NSArray *)array{
    __block NSInteger maxUTTime = 0;
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set Name=(CASE WHEN :Name ISNULL then Name else :Name1 end),Introduce=(CASE WHEN :Introduce ISNULL then Introduce else :Introduce1 end), HeaderSrc=(CASE WHEN :HeaderSrc ISNULL then HeaderSrc else :HeaderSrc1 end),Topic=(CASE WHEN :Topic ISNULL then Topic else :Topic1 end), LastUpdateTime=:LastUpdateTime, UTLastUpdateTime=:UTLastUpdateTime, ExtendedFlag=:ExtendedFlag Where GroupId = :GroupId;";
        NSMutableArray *paramList = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSMutableDictionary *infoDic in array) {
            NSString *groupId = [infoDic objectForKey:@"MN"];
            NSString *nickName = [infoDic objectForKey:@"SN"];
            NSString *desc = [infoDic objectForKey:@"MD"];
            NSString *topic = [infoDic objectForKey:@"MT"];
            NSString *headerSrc = [infoDic objectForKey:@"MP"];
            NSString *version = [infoDic objectForKey:@"VS"];
            NSInteger UTLastUpdateTime = [[infoDic objectForKey:@"UT"] integerValue];
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:nickName.length > 0?nickName:@":NULL"];
            [param addObject:nickName.length > 0?nickName:@":NULL"];
            [param addObject:desc.length > 0?desc:@":NULL"];
            [param addObject:desc.length > 0?desc:@":NULL"];
            [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
            [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
            [param addObject:topic.length > 0?topic:@":NULL"];
            [param addObject:topic.length > 0?topic:@":NULL"];
            [param addObject:version?version:@"0"];
            [param addObject:@(UTLastUpdateTime)];
            if (UTLastUpdateTime > maxUTTime) {
                maxUTTime = UTLastUpdateTime;
            }
            [param addObject:@(headerSrc.length > 0)];
            [param addObject:groupId];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    [[IMDataManager qimDB_SharedInstance] qimDB_UpdateUserCacheDataWithKey:@"kGetIncrementMucGroupCardVersion" withType:12 withValue:@"获取群增量名片" withValueInt:maxUTTime];
    QIMVerboseLog(@"");
}

- (NSInteger)qimDB_getGroupListMaxUTLastUpdateTime {
    NSInteger lastMaxUTTime = [[IMDataManager qimDB_SharedInstance] qimDB_getUserCacheDataWithKey:@"kGetIncrementMucGroupCardVersion" withType:12];
    return lastMaxUTTime;
}

- (void)qimDB_updateGroup:(NSString *)groupId
             WithNickName:(NSString *)nickName
                WithTopic:(NSString *)topic
                 WithDesc:(NSString *)desc
            WithHeaderSrc:(NSString *)headerSrc
              WithVersion:(NSString *)version{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set Name=(CASE WHEN :Name ISNULL then Name else :Name1 end),Introduce=(CASE WHEN :Introduce ISNULL then Introduce else :Introduce1 end), HeaderSrc=(CASE WHEN :HeaderSrc ISNULL then HeaderSrc else :HeaderSrc1 end),Topic=(CASE WHEN :Topic ISNULL then Topic else :Topic1 end), LastUpdateTime=:LastUpdateTime Where GroupId = :GroupId;";
        NSMutableArray *param = [NSMutableArray array];
        [param addObject:nickName.length > 0?nickName:@":NULL"];
        [param addObject:nickName.length > 0?nickName:@":NULL"];
        [param addObject:desc?desc:@":NULL"];
        [param addObject:desc?desc:@":NULL"];
        [param addObject:headerSrc?headerSrc:@":NULL"];
        [param addObject:headerSrc?headerSrc:@":NULL"];
        [param addObject:topic?topic:@":NULL"];
        [param addObject:topic?topic:@":NULL"];
        [param addObject:version];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_updateGroup:(NSString *)groupId WithNickName:(NSString *)nickName{
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set Name=:Name Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:2];
        [param addObject:nickName];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_updateGroup:(NSString *)groupId WithDesc:(NSString *)desc{
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set Introduce=:Introduce Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:2];
        [param addObject:desc];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_Group Set HeaderSrc=:HeaderSrc Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:2];
        [param addObject:headerSrc];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_bulkDeleteGroups:(NSArray *)groupIdList {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *deleteGroupSql = @"Delete From IM_Group Where GroupId = :GroupId;";
        NSString *deleteGroupMemberSql = @"Delete From IM_Group_Member Where GroupId = :GroupId;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSString *groupId in groupIdList) {
            
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:4];
            [param addObject:groupId];
            [params addObject:param];
        }
        [db executeBulkInsert:deleteGroupSql withParameters:params];
        [db executeBulkInsert:deleteGroupMemberSql withParameters:params];
    }];
}

- (void)qimDB_deleteGroup:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Group Where GroupId = :GroupId;";
        [database executeNonQuery:sql withParameters:@[groupId]];
        sql = @"Delete From IM_Group_Member Where GroupId = :GroupId;";
        [database executeNonQuery:sql withParameters:@[groupId]];
    }];
    QIMVerboseLog(@"");
}

- (NSDictionary *)qimDB_getGroupMemberInfoByNickName:(NSString *)nickName{
    __block NSMutableDictionary *infoDic = nil;
    if (nickName) {
        [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
            NSString *sql = [NSString stringWithFormat:@"Select MemberJid, GroupId, Name, Affiliation From IM_Group_Member Where Name = '%@';", nickName];
            DataReader *reader = [database executeReader:sql withParameters:nil];
            if ([reader read]) {
                NSString *memberId = [reader objectForColumnIndex:0];
                NSString *name = [reader objectForColumnIndex:2];
                NSString *affiliation = [reader objectForColumnIndex:3];
                infoDic = [[NSMutableDictionary alloc] init];
                [infoDic setObject:memberId forKey:@"jid"];
                [infoDic setObject:name forKey:@"name"];
                [infoDic setObject:affiliation forKey:@"affiliation"];
            }
            [reader close];
        }];
    }
    QIMVerboseLog(@"");
    return infoDic;
}

- (NSDictionary *)qimDB_getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId{
    __block NSMutableDictionary *infoDic = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select MemberId, GroupId, Name, Affiliation From IM_Group_Member Where MemberJid = '%@' And GroupId = '%@';", jid, groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            NSString *memberId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *affiliation = [reader objectForColumnIndex:3];
            infoDic = [[NSMutableDictionary alloc] init];
            [infoDic setObject:memberId forKey:@"jid"];
            [infoDic setObject:name forKey:@"name"];
            [infoDic setObject:affiliation forKey:@"affiliation"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return infoDic;
}

- (BOOL)qimDB_checkGroupMember:(NSString *)nickName WithGroupId:(NSString *)groupId{
    __block BOOL flag = NO;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *memId = [groupId stringByAppendingFormat:@"/%@",nickName];
        NSString *sql = [NSString stringWithFormat:@"Select 1 From IM_Group_Member Where MemberId = :MemberId;", memId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            flag = YES;
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return flag;
}

- (void)qimDB_insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or Replace into IM_Group_Member(MemberId, GroupId, Name, MemberJid, Affiliation, LastUpdateTime) values(:MemberId, :GroupId, :Name, :MemberJid, :Affiliation, :LastUpdateTime);";
        NSString *memId = [groupId stringByAppendingFormat:@"/%@",[memberDic objectForKey:@"name"]];
        NSString *name = [memberDic objectForKey:@"name"];
        NSString *Affiliation = [memberDic objectForKey:@"affiliation"];
        NSString *jid = [memberDic objectForKey:@"jid"];
        NSNumber *LastUpdateTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:4];
        [param addObject:memId];
        [param addObject:groupId];
        [param addObject:name];
        [param addObject:jid];
        [param addObject:Affiliation];
        [param addObject:LastUpdateTime];
        [database executeNonQuery:sql withParameters:param];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId{
    if (!members) {
        return;
    }
    groupId = [groupId copy];
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableString *deleteSql = [NSMutableString stringWithString: @"Delete From IM_Group_Member Where MemberId not in ("];
        NSMutableArray *params = [[NSMutableArray alloc] init];
        
        for (NSDictionary *memberDic in members) {
            
            NSString *memId = [groupId stringByAppendingFormat:@"/%@",[memberDic objectForKey:@"name"]];  //448353735b6b4a7e91ef9f70ade46fd8@conference.ejabhost1/李露lucas
            NSString *name = [memberDic objectForKey:@"name"];  //李露lucas
            NSString *affiliation = [memberDic objectForKey:@"affiliation"]; //owner / admin / none
            NSNumber *lastUpdateTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
            NSString *memberXmppJid = [memberDic objectForKey:@"jid"];
            if ([memberDic isEqual:members.lastObject]) {
                
                [deleteSql appendFormat:@"'%@') and GroupId='%@';",memId,groupId];
            } else {
                [deleteSql appendFormat:@"'%@',", memId];
            }
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:4];
            [param addObject:memId];
            [param addObject:groupId];
            [param addObject:name];
            [param addObject:memberXmppJid];
            [param addObject:affiliation];
            [param addObject:lastUpdateTime];
            [params addObject:param];
        }
        
        [database executeNonQuery:deleteSql withParameters:nil];
        
        NSString *sql = @"insert or REPLACE into IM_Group_Member(MemberId, GroupId, Name, MemberJid, Affiliation, LastUpdateTime)  values(:MemberId, :GroupId, :Name, :MemberJid, :Affiliation, :LastUpdateTime);";
        [database executeBulkInsert:sql withParameters:params];
    }];
    QIMVerboseLog(@"");
}

- (NSArray *)qimDB_getQChatGroupMember:(NSString *)groupId{
    __block NSMutableArray *members = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select a.MemberId, b.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_Users b on a.MemberJid = b.XmppId Where GroupId = '%@' Order By a.Name;", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (members == nil) {
                members = [[NSMutableArray alloc] init];
            }
            NSString *memberId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *jid = [reader objectForColumnIndex:2];
            NSString *affiliation = [reader objectForColumnIndex:3];
            if (jid == nil) {
                continue;
            }
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:memberId forKey:@"jid"];
            [dic setObject:name forKey:@"name"];
            [dic setObject:jid forKey:@"xmppjid"];
            [dic setObject:affiliation forKey:@"affiliation"];
            [members addObject:dic];
        }
    }];
    QIMVerboseLog(@"");
    return members;
}

- (NSArray *)qimDB_getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr{
    __block NSMutableArray *members = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select a.MemberId, b.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_Users b on a.MemberJid = b.XmppId Where GroupId = '%@' and (b.UserId like '%%%@%%' OR b.Name like '%%%@%%' OR b.SearchIndex like '%%%@%%' COLLATE NOCASE) Order By a.Name;", groupId, searchStr,searchStr,searchStr];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (members == nil) {
                members = [[NSMutableArray alloc] init];
            }
            NSString *memberId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *jid = [reader objectForColumnIndex:2];
            NSString *affiliation = [reader objectForColumnIndex:3];
            if (jid == nil) {
                continue;
            }
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:memberId forKey:@"jid"];
            [dic setObject:name forKey:@"name"];
            [dic setObject:jid forKey:@"xmppjid"];
            [dic setObject:affiliation forKey:@"affiliation"];
            [members addObject:dic];
        }
    }];
    QIMVerboseLog(@"");
    return members;
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr{
    __block NSMutableArray *members = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select a.MemberId, a.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_Users b on a.MemberJid = b.XmppId Where GroupId = '%@' and (b.UserId like \"%%%@%%\" OR b.Name like \"%%%@%%\" OR b.SearchIndex like \"%%%@%%\" COLLATE NOCASE) Order By a.Name;", groupId, searchStr,searchStr,searchStr];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (members == nil) {
                members = [[NSMutableArray alloc] init];
            }
            NSString *memberId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *jid = [reader objectForColumnIndex:2];
            NSString *affiliation = [reader objectForColumnIndex:3];
            if (jid == nil)
                continue;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:memberId forKey:@"jid"];
            [dic setObject:name forKey:@"name"];
            [dic setObject:jid forKey:@"xmppjid"];
            [dic setObject:affiliation forKey:@"affiliation"];
            [members addObject:dic];
        }
    }];
    QIMVerboseLog(@"");
    return members;
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId WithGroupIdentity:(NSInteger)identity {
    __block NSMutableArray *members = nil;
    NSMutableArray *identityArray = [[NSMutableArray alloc] init];
    if (identity == 0) {
        //Owner
        identityArray = @[@"admin", @"none"];
    } else if (identity == 1) {
        identityArray = @[@"none"];
    } else {
        
    }
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select a.MemberId, a.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_Users b on a.MemberJid = b.XmppId Where GroupId = '%@' and a.Affiliation in (", groupId, identityArray];
        if (identityArray.count) {
            for (NSString *affiliation in identityArray) {
                if ([affiliation isEqual:identityArray.lastObject]) {
                    [sql appendFormat:@"'%@') Order By a.Name;",affiliation];
                } else {
                    [sql appendFormat:@"'%@',",affiliation];
                }
            }
        } else {
            [sql appendFormat:@"'%@') Order By a.Name;"];
        }

        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (members == nil) {
                members = [[NSMutableArray alloc] init];
            }
            NSString *memberId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:1];
            NSString *jid = [reader objectForColumnIndex:2];
            NSString *affiliation = [reader objectForColumnIndex:3];
            if (jid == nil)
                continue;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:memberId forKey:@"jid"];
            [dic setObject:name forKey:@"name"];
            [dic setObject:jid forKey:@"xmppjid"];
            [dic setObject:affiliation forKey:@"affiliation"];
            [members addObject:dic];
        }
    }];
    return members;
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId{
    __block NSMutableArray *members = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select MemberJid, Name, Affiliation From IM_Group_Member Where GroupId = '%@' Order By Affiliation = 'owner' Desc, Affiliation = 'admin' Desc, Affiliation = 'none' Desc;", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (members == nil) {
                members = [[NSMutableArray alloc] init];
            }
            NSString *memberXmppJid = [reader objectForColumnIndex:0];
            NSString *memberName = [reader objectForColumnIndex:1];
            NSString *jid = memberXmppJid;
            NSString *affiliation = [reader objectForColumnIndex:2];
            if (jid == nil) {
                continue;
            }
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:memberXmppJid forKey:@"jid"];
            [dic setObject:memberName forKey:@"name"];
            [dic setObject:jid forKey:@"xmppjid"];
            [dic setObject:affiliation forKey:@"affiliation"];
            [members addObject:dic];
        }
    }];
    QIMVerboseLog(@"");
    return members;
}

- (NSDictionary *)qimDB_getGroupOwnerInfoForGroupId:(NSString *)groupId{
    if (groupId.length <= 0) {
        return nil;
    }
    __block NSDictionary *user = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT b.* FROM IM_Group_Member as a LEFT JOIN IM_Users as b on a.MemberJid = b.XmppId WHERE GroupId = '%@' And Affiliation = 'owner';", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            user = [[NSMutableDictionary alloc] init];
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *XmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *data = [reader objectForColumnIndex:5];
            NSNumber *dateTime = [reader objectForColumnIndex:6];
            NSString *searchIndex = [reader objectForColumnIndex:7];
            [IMDataManager safeSaveForDic:user setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:user setObject:XmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:user setObject:name?name:userId forKey:@"Name"];
            [IMDataManager safeSaveForDic:user setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:user setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:user setObject:data forKey:@"UserInfo"];
            [IMDataManager safeSaveForDic:user setObject:dateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:user setObject:searchIndex forKey:@"SearchIndex"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return user;
}

- (void)qimDB_deleteGroupMemberWithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Group_Member Where GroupId=:GroupId;";
        [database executeNonQuery:sql withParameters:@[groupId]];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Group_Member Where GroupId=:GroupId and MemberJid = :MemberJid;";
        [database executeNonQuery:sql withParameters:@[groupId,memberJid]];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_Group_Member Where MemberId = :MemberId;";
        NSString *memId = [groupId stringByAppendingFormat:@"/%@",nickname];
        [database executeNonQuery:sql withParameters:@[memId]];
    }];
    QIMVerboseLog(@"");
}

@end
