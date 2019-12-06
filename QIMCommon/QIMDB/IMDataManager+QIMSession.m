//
//  IMDataManager+QIMSession.m
//  QIMCommon
//
//  Created by 李露 on 2018/7/5.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "IMDataManager+QIMSession.h"
#import "QIMDataBase.h"

@implementation IMDataManager (QIMSession)

- (void)qimDB_updateSessionLastMsgIdWithSessionId:(NSString *)sessionId
                                    WithLastMsgId:(NSString *)lastMsgId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update IM_SessionList Set LastMessageId = :LastMessageId Where XmppId = :XmppId;";
        [database executeNonQuery:sql withParameters:[NSArray arrayWithObjects:lastMsgId,sessionId, nil]];
    }];
    QIMVerboseLog(@"");
}

- (long long)qimDB_insertSessionWithMsgList:(NSDictionary *)msgLists {
    QIMVerboseLog(@"qimDB_insertSessionWithMsgList : %@", msgLists);
    long long lastMaxMsgTime = 0;
    for (NSString *key in [msgLists allKeys]) {
        NSDictionary *value = [msgLists objectForKey:key];
        BOOL isConsult = [[value objectForKey:@"Consult"] boolValue];
        NSString *userId = [value objectForKey:@"UserId"];
        NSString *realJid = [value objectForKey:@"RealJid"];
        NSInteger chattype = [[value objectForKey:@"ChatType"] integerValue];
        NSArray *msgs = [value objectForKey:@"msgList"];
        long long msgTime = [[value objectForKey:@"lastDate"] longLongValue];
        NSString *msgId = [value objectForKey:@"MsgId"];
        if (lastMaxMsgTime <= msgTime) {
            lastMaxMsgTime = msgTime;
            QIMVerboseLog(@"最终比较出来的时间戳是 : %lld", msgTime);
        }

        if ([key hasPrefix:@"rbt-notice"] || [key hasPrefix:@"rbt-qiangdan"] || [key hasPrefix:@"rbt-zhongbao"] || [key hasPrefix:@"FriendNotify"] || [key hasPrefix:@"rbt-system"]) {
            chattype = ChatType_System;
        }

        if (isConsult) {

            [[IMDataManager qimDB_SharedInstance] qimDB_insertSessionWithSessionId:userId WithUserId:userId WithLastMsgId:userId WithLastUpdateTime:msgTime ChatType:chattype WithRealJid:realJid];
        } else {
            if ([key containsString:@"collection_rbt"]) {
                [[IMDataManager qimDB_SharedInstance] qimDB_insertSessionWithSessionId:key WithUserId:[[key componentsSeparatedByString:@"@"] objectAtIndex:0] WithLastMsgId:msgId WithLastUpdateTime:msgTime ChatType:ChatType_CollectionChat WithRealJid:key];
            } else {
                [[IMDataManager qimDB_SharedInstance] qimDB_insertSessionWithSessionId:key WithUserId:[[key componentsSeparatedByString:@"@"] objectAtIndex:0] WithLastMsgId:msgId WithLastUpdateTime:msgTime ChatType:chattype WithRealJid:key];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationOfflineMessageUpdate" object:key userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationSessionListUpdate" object:nil];
        });
    }
    QIMVerboseLog(@"");
    return lastMaxMsgTime;
}

- (long long)qimDB_insertGroupSessionWithMsgList:(NSDictionary *)tempGroupDic {
    long long lastMaxTime = 0;
    for (NSString *groupId in tempGroupDic) {
        if (groupId.length > 0) {
            NSDictionary *groupMsgDic = [tempGroupDic objectForKey:groupId];
            NSString *messageId = [groupMsgDic objectForKey:@"MsgId"];
            long long msgDate = [[groupMsgDic objectForKey:@"MsgDateTime"] longLongValue];
            if (lastMaxTime < msgDate) {
                lastMaxTime = msgDate;
            }
            [[IMDataManager qimDB_SharedInstance] qimDB_insertSessionWithSessionId:groupId WithUserId:[[groupId componentsSeparatedByString:@"@"] objectAtIndex:0] WithLastMsgId:messageId WithLastUpdateTime:msgDate ChatType:ChatType_GroupChat WithRealJid:groupId];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationOfflineMessageUpdate" object:key userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationSessionListUpdate" object:nil];
        });
    }
    QIMVerboseLog(@"");
    return lastMaxTime;
}

- (BOOL)qimDB_checkSession:(NSString *)sessionId withRealJid:(NSString *)realJid withChatType:(int)chatType {
    __block BOOL flag = NO;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select 1 From IM_SessionList Where XmppId = '%@' and RealJid = '%@' and ChatType = %d;", sessionId, realJid, chatType];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            flag = YES;
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return flag;
}

- (void)qimDB_insertSessionWithSessionId:(NSString *)sessinId
                              WithUserId:(NSString *)userId
                           WithLastMsgId:(NSString *)lastMsgId
                      WithLastUpdateTime:(long long)lastUpdateTime
                                ChatType:(int)ChatType
                             WithRealJid:(id)realJid{
    
    BOOL checkExist = [self qimDB_checkSession:sessinId withRealJid:realJid withChatType:ChatType];
    if (checkExist) {
        [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
            NSString *sql = @"Update IM_SessionList Set LastMessageId = :LastMessageId, LastUpdateTime = :LastUpdateTime Where XmppId = :XmppId and RealJid = :RealJid and ChatType = :ChatType and LastUpdateTime <= :LastUpdateTime";
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:5];
            [param addObject:lastMsgId?lastMsgId:@":NULL"];
            [param addObject:[NSNumber numberWithLongLong:lastUpdateTime]];
            [param addObject:sessinId?sessinId:@":NULL"];
            [param addObject:realJid?realJid:@":NULL"];
            [param addObject:[NSNumber numberWithInt:ChatType]];
            [param addObject:[NSNumber numberWithLongLong:lastUpdateTime]];
            [database executeNonQuery:sql withParameters:param];
        }];
    } else {
        [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
            NSString *sql = @"insert or ignore into IM_SessionList(XmppId, UserId, LastMessageId,LastUpdateTime,ChatType,RealJid) Values(:XmppId, :UserId, :LastMessageId,:LastUpdateTime,:ChatType,:RealJid);";
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:5];
            [param addObject:sessinId?sessinId:@":NULL"];
            [param addObject:userId?userId:@":NULL"];
            [param addObject:lastMsgId?lastMsgId:@":NULL"];
            [param addObject:[NSNumber numberWithLongLong:lastUpdateTime]];
            [param addObject:[NSNumber numberWithInt:ChatType]];
            [param addObject:realJid?realJid:@":NULL"];
            [database executeNonQuery:sql withParameters:param];
        }];
    }
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteSession:(NSString *)xmppId RealJid:(NSString *)realJid{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From IM_SessionList Where XmppId=:XmppId AND RealJid=:RealJid;";
        [database executeNonQuery:sql withParameters:@[xmppId, realJid]];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_deleteSessionList:(NSArray *)xmppIds{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSessionSql = [NSString stringWithFormat:@"Delete from IM_SessionList Where XmppId = :XmppId;"];
        NSString *deleteMessageSql = [NSString stringWithFormat:@"Delete From IM_Message Where XmppId = :XmppId;"];
        [database executeBulkInsert:deleteSessionSql withParameters:xmppIds];
        [database executeBulkInsert:deleteMessageSql withParameters:xmppIds];
    }];
}

- (void)qimDB_deleteSession:(NSString *)xmppId{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSessionSql = [NSString stringWithFormat:@"Delete from IM_SessionList Where XmppId = '%@'", xmppId];
        NSString *deleteMessageSql = [NSString stringWithFormat:@"Delete From IM_Message Where XmppId = '%@'", xmppId];
        [database executeNonQuery:deleteSessionSql withParameters:nil];
        [database executeNonQuery:deleteMessageSql withParameters:nil];
    }];
    QIMVerboseLog(@"");
}

- (NSDictionary *)qimDB_getLastedSingleChatSession {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT XmppId, UserId, LastMessageId, LastUpdateTime, ChatType, ExtendedFlag FROM IM_SessionList WHERE ChatType = %d ORDER BY LastUpdateTime DESC LIMIT 1;", ChatType_SingleChat];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            result = [[NSMutableDictionary alloc] init];
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *chatType = [reader objectForColumnIndex:4];
            [IMDataManager safeSaveForDic:result setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:result setObject:chatType forKey:@"ChatType"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return result;
}

- (NSArray *)qimDB_getFullSessionListWithSingleChatType:(int)singleChatType {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSNumber *pMaxLastTime = nil;
        NSMutableDictionary *dic = nil;
        NSString *psql = @"Select b.XmppId,A.Name,b.Content,b.Type,b.LastUpdateTime From (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b Left Join IM_Public_Number as a  On a.XmppId=b.XmppId;";
        DataReader *pReader = [database executeReader:psql withParameters:nil];
        if ([pReader read]) {
            dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:0] forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:1] forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:2] forKey:@"Content"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:3] forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:4] forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:dic setObject:@(ChatType_PublicNumber) forKey:@"ChatType"];
            pMaxLastTime = [pReader objectForColumnIndex:4];
        }
        [pReader close];
        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_Users where IM_Users.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_Users WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction,CASE b.LastUpdateTime  When NULL THEN a.LastUpdateTime ELSE b.LastUpdateTime END as orderTime, a.ChatType, case a.ChatType When %d THEN '' ELSE b.[From] END as NickName, 0 as NotReadCount,a.RealJid from IM_SessionList as a left join IM_Message as b on a.XmppId = b.XmppId and b.MsgId = (SELECT MsgId FROM IM_Message WHERE XmppId = a.XmppId  AND (case When a.ChatType = %d or a.ChatType = %d THEN RealJid = a.RealJid ELSE RealJid is null END) Order by LastUpdateTime DESC LIMIT 1) order by OrderTime desc;", singleChatType, singleChatType+1,singleChatType, ChatType_Consult, ChatType_ConsultServer];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        result = [[NSMutableArray alloc] initWithCapacity:100];
        BOOL added = NO;
        while ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *lastMsgId = [reader objectForColumnIndex:4];
            NSString *content = [reader objectForColumnIndex:5];
            NSString *msgType = [reader objectForColumnIndex:6];
            NSNumber *msgState = [reader objectForColumnIndex:7];
            NSNumber *msgDirection = [reader objectForColumnIndex:8];
            NSNumber *msgDateTime = [reader objectForColumnIndex:9];
            NSNumber *chatType = [reader objectForColumnIndex:10];
            NSString *nickName = [reader objectForColumnIndex:11];
            NSString *realJid = [reader objectForColumnIndex:13];
            if (added == NO && msgDateTime && msgDateTime.longLongValue < pMaxLastTime.longLongValue) {
                added = YES;
                [result addObject:dic];
            } else {
                NSMutableDictionary *sessionDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:sessionDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:userId forKey:@"UserId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:name forKey:@"Name"];
                [IMDataManager safeSaveForDic:sessionDic setObject:headerSrc forKey:@"HeaderSrc"];
                [IMDataManager safeSaveForDic:sessionDic setObject:lastMsgId forKey:@"LastMsgId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:content forKey:@"Content"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgType forKey:@"MsgType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgState forKey:@"MsgState"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDirection forKey:@"MsgDirection"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDateTime forKey:@"MsgDateTime"];
                [IMDataManager safeSaveForDic:sessionDic setObject:chatType forKey:@"ChatType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:nickName forKey:@"NickName"];
                [IMDataManager safeSaveForDic:sessionDic setObject:realJid forKey:@"RealJid"];
                [result addObject:sessionDic];
            }
        }
        
    }];
    QIMVerboseLog(@"");
    return result;
}

- (NSArray *)qimDB_getNotReadSessionList {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSNumber *pMaxLastTime = nil;
        NSMutableDictionary *dic = nil;
        NSString *psql = @"Select b.XmppId,A.Name,b.Content,b.Type,b.LastUpdateTime From (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b Left Join IM_Public_Number as a On a.XmppId=b.XmppId;";
        DataReader *pReader = [database executeReader:psql withParameters:nil];
        if ([pReader read]) {
            dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:0] forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:1] forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:2] forKey:@"Content"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:3] forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:4] forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:dic setObject:@(ChatType_PublicNumber) forKey:@"ChatType"];
            pMaxLastTime = [pReader objectForColumnIndex:4];
        }
        [pReader close];

        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_Users where IM_Users.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_Users WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction, a.ChatType, a.RealJid, a.LastUpdateTime, (case when (select count(*) from IM_Client_Config where DeleteFlag =0 and ConfigKey ='kStickJidDic' and ConfigSubKey=(a.XmppId ||'<>'||a.RealJid))=1 Then 1 ELSE 0 END) as StickState, (case when (select count(*) from IM_Client_Config where ConfigKey='kNoticeStickJidDic'and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then 1 ELSE 0 END) as Reminded, (case when (select count(*) from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then (select ConfigValue from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId) ELSE NULL END) as MarkupName, b.'From', a.UnreadCount from IM_SessionList as a left join IM_Message as b on a.LastMessageId = b.MsgId where a.UnreadCount >0 order by StickState desc, a.LastUpdateTime desc;", ChatType_SingleChat, ChatType_SingleChat];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        result = [[NSMutableArray alloc] initWithCapacity:3];
        BOOL added = NO;
        while ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *lastMsgId = [reader objectForColumnIndex:4];
            NSString *content = [reader objectForColumnIndex:5];
            NSNumber *msgType = [reader objectForColumnIndex:6];
            NSNumber *msgState = [reader objectForColumnIndex:7];
            NSNumber *msgDirection = [reader objectForColumnIndex:8];
            NSNumber *chatType = [reader objectForColumnIndex:9];
            NSString *realJid = [reader objectForColumnIndex:10];
            NSNumber *msgDateTime = [reader objectForColumnIndex:11];
            NSNumber *stickState = [reader objectForColumnIndex:12];
            NSNumber *reminded = [reader objectForColumnIndex:13];
            NSString *markUpName = [reader objectForColumnIndex:14];
            NSString *msgFrom = [reader objectForColumnIndex:15];
            NSNumber *unreadCount = [reader objectForColumnIndex:16];
            if (added == NO && msgDateTime && msgDateTime.longLongValue < pMaxLastTime.longLongValue) {
                added = YES;
                [result addObject:dic];
            } else {
                NSMutableDictionary *sessionDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:sessionDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:userId forKey:@"UserId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:name forKey:@"Name"];
                [IMDataManager safeSaveForDic:sessionDic setObject:headerSrc forKey:@"HeaderSrc"];
                [IMDataManager safeSaveForDic:sessionDic setObject:lastMsgId forKey:@"LastMsgId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:content forKey:@"Content"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgType forKey:@"MsgType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgState forKey:@"MsgState"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDirection forKey:@"MsgDirection"];
                [IMDataManager safeSaveForDic:sessionDic setObject:chatType forKey:@"ChatType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:realJid forKey:@"RealJid"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDateTime forKey:@"MsgDateTime"];
                [IMDataManager safeSaveForDic:sessionDic setObject:stickState forKey:@"StickState"];
                [IMDataManager safeSaveForDic:sessionDic setObject:reminded forKey:@"Reminded"];
                [IMDataManager safeSaveForDic:sessionDic setObject:markUpName forKey:@"MarkUpName"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgFrom forKey:@"MsgFrom"];
                [IMDataManager safeSaveForDic:sessionDic setObject:unreadCount forKey:@"UnreadCount"];
                [result addObject:sessionDic];
            }
        }
        

        long long endTime = [[NSDate date] timeIntervalSince1970] * 1000;
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        QIMVerboseLog(@"生成%ld条未读会话列表 耗时 = %f s", result.count, end - start); //s
    }];
    return result;
}


- (NSArray *)qimDB_getSessionListWithSingleChatType:(int)singleChatType {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSNumber *pMaxLastTime = nil;
        NSMutableDictionary *dic = nil;
        NSString *psql = @"Select b.XmppId,A.Name,b.Content,b.Type,b.LastUpdateTime From (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b Left Join IM_Public_Number as a On a.XmppId=b.XmppId;";
        DataReader *pReader = [database executeReader:psql withParameters:nil];
        if ([pReader read]) {
            dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:0] forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:1] forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:2] forKey:@"Content"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:3] forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:dic setObject:[pReader objectForColumnIndex:4] forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:dic setObject:@(ChatType_PublicNumber) forKey:@"ChatType"];
            pMaxLastTime = [pReader objectForColumnIndex:4];
        }
        [pReader close];
        
        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_Users where IM_Users.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_Users WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction, a.ChatType, a.RealJid, a.LastUpdateTime, (case when (select count(*) from IM_Client_Config where DeleteFlag =0 and ConfigKey ='kStickJidDic' and ConfigSubKey=(a.XmppId ||'<>'||a.RealJid))=1 Then 1 ELSE 0 END) as StickState, (case when (select count(*) from IM_Client_Config where ConfigKey='kNoticeStickJidDic'and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then 1 ELSE 0 END) as Reminded, (case when (select count(*) from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then (select ConfigValue from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId) ELSE NULL END) as MarkupName, b.'From', a.UnreadCount from IM_SessionList as a left join IM_Message as b on a.LastMessageId = b.MsgId order by StickState desc, a.LastUpdateTime desc;", singleChatType, singleChatType];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        result = [[NSMutableArray alloc] initWithCapacity:100];
        BOOL added = NO;
        while ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *lastMsgId = [reader objectForColumnIndex:4];
            NSString *content = [reader objectForColumnIndex:5];
            NSNumber *msgType = [reader objectForColumnIndex:6];
            NSNumber *msgState = [reader objectForColumnIndex:7];
            NSNumber *msgDirection = [reader objectForColumnIndex:8];
            NSNumber *chatType = [reader objectForColumnIndex:9];
            NSString *realJid = [reader objectForColumnIndex:10];
            NSNumber *msgDateTime = [reader objectForColumnIndex:11];
            NSNumber *stickState = [reader objectForColumnIndex:12];
            NSNumber *reminded = [reader objectForColumnIndex:13];
            NSString *markUpName = [reader objectForColumnIndex:14];
            NSString *msgFrom = [reader objectForColumnIndex:15];
            NSNumber *unreadCount = [reader objectForColumnIndex:16];
            if (added == NO && msgDateTime && msgDateTime.longLongValue < pMaxLastTime.longLongValue) {
                added = YES;
                [result addObject:dic];
            } else {
                NSMutableDictionary *sessionDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:sessionDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:userId forKey:@"UserId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:name forKey:@"Name"];
                [IMDataManager safeSaveForDic:sessionDic setObject:headerSrc forKey:@"HeaderSrc"];
                [IMDataManager safeSaveForDic:sessionDic setObject:lastMsgId forKey:@"LastMsgId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:content forKey:@"Content"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgType forKey:@"MsgType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgState forKey:@"MsgState"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDirection forKey:@"MsgDirection"];
                [IMDataManager safeSaveForDic:sessionDic setObject:chatType forKey:@"ChatType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:realJid forKey:@"RealJid"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDateTime forKey:@"MsgDateTime"];
                [IMDataManager safeSaveForDic:sessionDic setObject:stickState forKey:@"StickState"];
                [IMDataManager safeSaveForDic:sessionDic setObject:reminded forKey:@"Reminded"];
                [IMDataManager safeSaveForDic:sessionDic setObject:markUpName forKey:@"MarkUpName"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgFrom forKey:@"MsgFrom"];
                [IMDataManager safeSaveForDic:sessionDic setObject:unreadCount forKey:@"UnreadCount"];
                [result addObject:sessionDic];
            }
        }
        
        long long endTime = [[NSDate date] timeIntervalSince1970] * 1000;
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        NSLog(@"生成%ld条会话列表 耗时 = %f s", result.count, end - start); //s
    }];
    return result;
}

- (NSArray *)qimDB_getSessionListXMPPIDWithSingleChatType:(int)singleChatType {
    
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT XmppId FROM IM_SessionList WHERE ChatType = %d", ChatType_SingleChat];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        result = [[NSMutableArray alloc] initWithCapacity:30];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            if (xmppId.length > 0) {
                [result addObject:xmppId];
            }
        }
        
    }];
    QIMVerboseLog(@"");
    return result;
}

- (NSDictionary *)qimDB_getChatSessionWithUserId:(NSString *)userId chatType:(int)chatType{
    
    __block NSMutableDictionary *chatSession = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select a.XmppId, a.UserId, case a.ChatType When %d THEN (Select Name From IM_Users WHERE UserId = a.UserId) ELSE (SELECT Name From IM_Group WHERE GroupId = a.XmppId) END as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_Users WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, a.LastMessageId, b.Content, b.Type, b.State, b.Direction, b.LastUpdateTime, a.ChatType, case a.ChatType When %d THEN '' ELSE b.\"From\" END as NickName,(Select count(*) From IM_Message Where XmppId = a.XmppId And ReadedTag = 0) as NotReadCount From IM_SessionList as a left join IM_Message as b on (a.LastMessageId = b.MsgId ) Where a.XmppId='%@' Order by b.LastUpdateTime DESC;",chatType,chatType+1,chatType, userId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *lastMsgId = [reader objectForColumnIndex:4];
            NSString *content = [reader objectForColumnIndex:5];
            NSString *msgType = [reader objectForColumnIndex:6];
            NSNumber *msgState = [reader objectForColumnIndex:7];
            NSNumber *msgDirection = [reader objectForColumnIndex:8];
            NSNumber *msgDateTime = [reader objectForColumnIndex:9];
            NSNumber *chatType = [reader objectForColumnIndex:10];
            NSString *nickName = [reader objectForColumnIndex:11];
            
            chatSession = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:chatSession setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:chatSession setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:chatSession setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:chatSession setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:chatSession setObject:lastMsgId forKey:@"LastMsgId"];
            [IMDataManager safeSaveForDic:chatSession setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:chatSession setObject:chatType forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:chatSession setObject:nickName forKey:@"NickName"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return chatSession;
}

- (NSDictionary *)qimDB_getChatSessionWithUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    __block NSMutableDictionary *chatSession = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"select XmppId, UserId, LastMessageId, LastUpdateTime, ChatType, RealJid from IM_SessionList where XmppId='%@' And RealJid='%@';", userId, realJid];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *lastMsgId = [reader objectForColumnIndex:2];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:3];
            NSNumber *chatType = [reader objectForColumnIndex:4];
            NSString *realJid = [reader objectForColumnIndex:5];
            
            chatSession = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:chatSession setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:chatSession setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:chatSession setObject:lastMsgId forKey:@"LastMsgId"];
            [IMDataManager safeSaveForDic:chatSession setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:chatSession setObject:chatType forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:chatSession setObject:realJid forKey:@"RealJid"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return chatSession;
}


- (NSDictionary *)qimDB_getChatSessionWithUserId:(NSString *)userId{
    
    __block NSMutableDictionary *chatSession = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select a.XmppId, a.UserId, case a.ChatType When 0 THEN (Select Name From IM_Users WHERE UserId = a.UserId) ELSE (SELECT Name From IM_Group WHERE GroupId = a.XmppId) END as Name, case a.ChatType When 0 THEN (Select HeaderSrc From IM_Users WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, a.LastMessageId, b.Content, b.Type, b.State, b.Direction, b.LastUpdateTime, a.ChatType,(Select count(*) From IM_Message Where XmppId = a.XmppId) as NotReadCount From IM_SessionList as a left join IM_Message as b on (a.LastMessageId = b.MsgId ) Where a.XmppId= '%@' Order by b.LastUpdateTime DESC;", userId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *headerSrc = [reader objectForColumnIndex:3];
            NSString *lastMsgId = [reader objectForColumnIndex:4];
            NSString *content = [reader objectForColumnIndex:5];
            NSString *msgType = [reader objectForColumnIndex:6];
            NSNumber *msgState = [reader objectForColumnIndex:7];
            NSNumber *msgDirection = [reader objectForColumnIndex:8];
            NSNumber *msgDateTime = [reader objectForColumnIndex:9];
            NSNumber *chatType = [reader objectForColumnIndex:10];
            
            chatSession = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:chatSession setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:chatSession setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:chatSession setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:chatSession setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:chatSession setObject:lastMsgId forKey:@"LastMsgId"];
            [IMDataManager safeSaveForDic:chatSession setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:chatSession setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:chatSession setObject:chatType forKey:@"ChatType"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return chatSession;
}

- (NSInteger)qimDB_getAppNotReadCount {
    __block NSInteger count = 0;
    //    [[QIMWatchDog sharedInstance] start];
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"SELECT sum(UnreadCount) FROM IM_SessionList";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    //    QIMVerboseLog(@"获取未读数耗时 :%lf", [[QIMWatchDog sharedInstance] escapedTime]);
    QIMVerboseLog(@"");
    return count;
}

@end
