//
//  IMDataManager+QIMDBCollectionMessage.m
//  QIMCommon
//
//  Created by 李露 on 11/24/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager+QIMDBCollectionMessage.h"
#import "QIMDataBase.h"
#import "QIMPublicRedefineHeader.h"

@implementation IMDataManager (QIMDBCollectionMessage)

/****************** Collection Msg *******************/

- (NSArray *)qimDB_getCollectionAccountList {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"SELECT b.XmppId, c.Name, c.HeaderSrc FROM IM_Collection_User AS b, IM_Collection_User_Card AS c WHERE b.XmppId=c.XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *bindId = [reader objectForColumnIndex:0];
            NSString *bindName = [reader objectForColumnIndex:1];
            NSString *headerSrc = [reader objectForColumnIndex:2];
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:bindId forKey:@"BindId"];
            [IMDataManager safeSaveForDic:value setObject:bindName forKey:@"BindName"];
            [IMDataManager safeSaveForDic:value setObject:headerSrc forKey:@"HeaderSrc"];
            [resultList addObject:value];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

- (void)qimDB_bulkinsertCollectionAccountList:(NSArray *)accounts {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"INSERT OR REPLACE INTO IM_Collection_User(XmppId,BIND) VALUES(:XmppId,:BIND);";
        
        NSMutableArray *paramList = [NSMutableArray array];
        for(NSDictionary *dic in accounts ) {
            NSString *bindId = [dic objectForKey:@"bindname"];
            NSString *bindhost = [dic objectForKey:@"bindhost"];
            NSString *xmppId = nil;
            if (bindId && bindhost) {
                xmppId = [NSString stringWithFormat:@"%@@%@", bindId, bindhost];
            }
            if (xmppId.length > 0) {
                BOOL action = [[dic objectForKey:@"action"] boolValue];
                NSMutableArray *params = [NSMutableArray array];
                [params addObject:xmppId];
                [params addObject:@(action)];
                [paramList addObject:params];
            }
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    QIMVerboseLog(@"");
}

- (NSDictionary *)qimDB_selectCollectionUserByJID:(NSString *)jid{
    if (jid == nil) {
        return nil;
    }
    __block NSMutableDictionary *user = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime,SearchIndex from IM_Collection_User_Card Where XmppId = '%@';", jid];
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

- (void)qimDB_bulkInsertCollectionUserCards:(NSArray *)userCards {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"INSERT OR REPLACE INTO IM_Collection_User_Card(UserId, XmppId, Name, DescInfo, HeaderSrc, SearchIndex, UserInfo, LastUpdateTime, IncrementVersion, ExtendedFlag) VALUES(:UserId,:XmppId,:Name, :DescInfo, :HeaderSrc, :SearchIndex, :UserInfo, :LastUpdateTime, :IncrementVersion, :ExtendedFlag);";
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *userCardDic in userCards) {
            
            NSString *userId = [userCardDic objectForKey:@"bindname"];
            if (!userId) {
                userId = [userCardDic objectForKey:@"username"];
            }
            NSString *bindhost = [userCardDic objectForKey:@"bindhost"];
            if (!bindhost) {
                bindhost = [userCardDic objectForKey:@"domain"];
            }
            NSString *xmppId = nil;
            if (userId && bindhost) {
                xmppId = [NSString stringWithFormat:@"%@@%@", userId, bindhost];
            }
            NSString *name = [userCardDic objectForKey:@"user_name"];
            if (!name) {
                name = [userCardDic objectForKey:@"usernick"];
            }
            NSString *descInfo = [userCardDic objectForKey:@""];
            NSString *headerSrc = [userCardDic objectForKey:@"url"];
            NSString *searchIndex = [userCardDic objectForKey:@""];
            NSNumber *userInfo = [userCardDic objectForKey:@""];
            NSNumber *LastUpdateTime = [userCardDic objectForKey:@""];
            
            NSMutableArray *params = [NSMutableArray array];
            [params addObject:userId?userId:@":NULL"];
            [params addObject:xmppId?xmppId:@":NULL"];
            [params addObject:name?name:@":NULL"];
            [params addObject:descInfo?descInfo:@":NULL"];
            [params addObject:headerSrc?headerSrc:@":NULL"];
            [params addObject:searchIndex?searchIndex:@":NULL"];
            [params addObject:userInfo?userInfo:@":NULL"];
            [params addObject:LastUpdateTime?LastUpdateTime:@":NULL"];
            [params addObject:@":NULL"];
            [params addObject:@":NULL"];
            [paramList addObject:params];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    QIMVerboseLog(@"");
}

- (NSDictionary *)qimDB_getCollectionGroupCardByGroupId:(NSString *)groupId{
    __block NSMutableDictionary *groupCardDic = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime From IM_Collection_Group_Card Where GroupId = '%@';", groupId];
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
    return groupCardDic;
}

- (void)qimDB_bulkInsertCollectionGroupCards:(NSArray *)array{
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert or replace Into IM_Collection_Group_Card(GroupId,Name,Introduce,HeaderSrc,Topic,LastUpdateTime,ExtendedFlag) values(:GroupId,:Name,:Introduce,:HeaderSrc,:Topic,:LastUpdateTime,:ExtendedFlag);";
        NSMutableArray *paramList = [[NSMutableArray alloc] initWithCapacity:2];
        for (NSMutableDictionary *infoDic in array) {
            NSString *groupId = [infoDic objectForKey:@"muc_name"];
            NSString *nickName = [infoDic objectForKey:@"show_name"];
            NSString *desc = [infoDic objectForKey:@"muc_desc"];
            NSString *topic = [infoDic objectForKey:@"muc_title"];
            NSString *headerSrc = [infoDic objectForKey:@"muc_pic"];
            NSString *version = [infoDic objectForKey:@"version"];
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:groupId.length > 0?groupId:@":NULL"];
            [param addObject:nickName.length > 0?nickName:@":NULL"];
            [param addObject:desc.length > 0?desc:@":NULL"];
            [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
            [param addObject:topic.length > 0?topic:@":NULL"];
            [param addObject:version?version:@"0"];
            [param addObject:@":NULL"];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    QIMVerboseLog(@"");
}

- (NSDictionary *)qimDB_getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId {
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select c.Originfrom, s.ChatType, m.content FROM IM_SessionList AS s, IM_Message AS m, IM_Message_Collection AS c WHERE m.MsgId='%@' AND c.MsgId='%@' AND s.ChatType=%@;", lastMsgId, lastMsgId, @(ChatType_CollectionChat)];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            NSString *originFrom = [reader objectForColumnIndex:0];
            NSNumber *chatType = [reader objectForColumnIndex:1];
            NSString *content = [reader objectForColumnIndex:2];
            resultDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:resultDic setObject:originFrom forKey:@"Originfrom"];
            [IMDataManager safeSaveForDic:resultDic setObject:chatType forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:resultDic setObject:content forKey:@"Content"];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return resultDic;
}

- (NSArray *)qimDB_getCollectionSessionListWithBindId:(NSString *)bindId {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT a.Originfrom, a.Originto, case a.Origintype when 'chat' THEN 0 WHEN 'groupchat' THEN 1 end as ChatType, Content, CASE a.Origintype When 'chat' THEN (SELECT Name from IM_Collection_User_Card WHERE XmppId like '%%a.Originfrom%%') ELSE (select Name from IM_Collection_Group_Card WHERE GroupId like '%%a.Originfrom%%') end as Name, CASE a.Origintype WHEN 'chat' Then (select HeaderSrc FROM IM_Collection_User_Card Where XmppId like '%%a.Originfrom%%') ELSE (select HeaderSrc FROM IM_Collection_Group_Card where GroupId like '%%a.Originfrom%%') end as HeaderSrc, CASE a.Origintype WHEN 'chat' Then '' ELSE a.Originfrom end as NickName, a.MsgId, b.LastUpdateTime, b.Type, b.State FROM IM_Message_Collection as a left join IM_Message as b on a.msgId = b.msgid where Originto ='%@' group by originfrom,originto ORDER by LastUpdateTime DESC;", bindId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *OriginFrom = [reader objectForColumnIndex:0];
            if ([OriginFrom containsString:@"/"]) {
                OriginFrom = [[OriginFrom componentsSeparatedByString:@"/"] firstObject];
            }
            NSString *Originto = [reader objectForColumnIndex:1];
            NSNumber *chatType = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSString *name = [reader objectForColumnIndex:4];
            NSString *headerSrc = [reader objectForColumnIndex:5];
            NSString *nickName = [reader objectForColumnIndex:6];
            NSString *msgId = [reader objectForColumnIndex:7];
            NSNumber *LastUpdateTime = [reader objectForColumnIndex:8];
            NSNumber *msgType = [reader objectForColumnIndex:9];
            NSNumber *msgState = [reader objectForColumnIndex:10];
            
            NSMutableDictionary *sessionDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:sessionDic setObject:OriginFrom forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:sessionDic setObject:OriginFrom forKey:@"UserId"];
            [IMDataManager safeSaveForDic:sessionDic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:sessionDic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:sessionDic setObject:msgId forKey:@"LastMsgId"];
            [IMDataManager safeSaveForDic:sessionDic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:sessionDic setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:sessionDic setObject:@(QIMMessageSendState_Success) forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:sessionDic setObject:@(QIMMessageDirection_Received) forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:sessionDic setObject:LastUpdateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:sessionDic setObject:chatType forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:sessionDic setObject:nickName forKey:@"NickName"];
            [resultList addObject:sessionDic];
        }
    }];
    QIMVerboseLog(@"");
    return resultList;
}

- (NSArray *)qimDB_getCollectionMsgListWithBindId:(NSString *)bindId {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime, ExtendInfo From IM_Message Where \"To\" = '%@';", bindId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        result = [[NSMutableArray alloc] initWithCapacity:100];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSString *extendInfo = [reader objectForColumnIndex:9];
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:msgDic setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:msgDic setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [result addObject:msgDic];
        }
    }];
    QIMVerboseLog(@"");
    return result;
}

- (BOOL)qimDB_checkCollectionMsgById:(NSString *)msgId {
    __block BOOL flag = NO;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select 1 From IM_Message_Collection Where MsgId = '%@';", msgId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            flag = YES;
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return flag;
}

- (void)qimDB_bulkInsertCollectionMsgWithMsgDics:(NSArray *)msgs {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"INSERT OR IGNORE INTO IM_Message_Collection(MsgId, Originfrom, Originto, Origintype) VALUES(:MsgId, :Originfrom, :Originto, :Origintype);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *msg in msgs) {
            
            NSString *msgId = [msg objectForKey:@"MsgId"];
            NSString *Originfrom = [msg objectForKey:@"Originfrom"];
            Originfrom = [[Originfrom componentsSeparatedByString:@"/"] firstObject];
            NSString *Originto = [msg objectForKey:@"Originto"];
            NSString *Origintype = [msg objectForKey:@"Origintype"];
            
            NSMutableArray *params = [NSMutableArray array];
            [params addObject:msgId?msgId:@":NULL"];
            [params addObject:Originfrom?Originfrom:@":NULL"];
            [params addObject:Originto?Originto:@":NULL"];
            [params addObject:Origintype?Origintype:@":NULL"];
            [paramList addObject:params];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    QIMVerboseLog(@"");
}

- (NSInteger)qimDB_getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState {
    __block int count = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT Count(*) from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where ReadState & 0x02 != 0x02 ORDER by LastUpdateTime;"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return count;
}

- (NSInteger)qimDB_getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId {
    __block int count = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT Count(*) from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (Originto = '%@' and ReadState & 0x02 != 0x02) ORDER by LastUpdateTime;", bindId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return count;
}

-(NSInteger)qimDB_getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId {
    __block int count = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT Count(*) from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (Originto = '%@' and ReadState & 0x02 != 0x02 and Originfrom Like '%%%@%%') ORDER by LastUpdateTime;", bindId, originUserId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    QIMVerboseLog(@"");
    return count;
}

- (void)qimDB_updateCollectionMsgNotReadStateByJid:(NSString *)jid WithReadtate:(NSInteger)readState {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        
        NSString *sql = @"Update IM_Message Set ReadState = :readState Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[@(readState), jid]];
    }];
    QIMVerboseLog(@"");
}

- (void)qimDB_updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithReadState:(NSInteger)readState{
    NSArray *msgList = [self qimDB_getCollectionMsgListWithUserId:bindId originUserId:originUserId];
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableString *sql = [NSMutableString stringWithString:@"Update IM_Message Set ReadState = :readState Where MsgId = :MsgId;"];
        NSMutableArray *params = nil;
        for (NSDictionary *msgDic in msgList) {
            NSString *msgId = [msgDic objectForKey:@"MsgId"];
            if (!params) {
                params = [NSMutableArray array];
            }
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:@(readState)];
            [param addObject:msgId];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
    QIMVerboseLog(@"");
}

- (NSDictionary *)qimDB_getCollectionMsgListForMsgId:(NSString *)msgId {
    __block NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT a.MsgId, Originfrom, Originto, Origintype, XmppId, Platform, \"From\", \"To\", Content, ExtendInfo, Type, State, Direction, ContentResolve, ReadState, LastUpdateTime, MessageRaw, RealJid from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (a.MsgId = '%@') ORDER by LastUpdateTime;", msgId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *originfrom = [reader objectForColumnIndex:1];
            NSString *originto = [reader objectForColumnIndex:2];
            NSString *originChatType = [reader objectForColumnIndex:3];
            NSString *xmppId = [reader objectForColumnIndex:4];
            NSNumber *platform = [reader objectForColumnIndex:5];
            NSString *from = [reader objectForColumnIndex:6];
            NSString *to = [reader objectForColumnIndex:7];
            NSString *content = [reader objectForColumnIndex:8];
            NSString *extendInfo = [reader objectForColumnIndex:9];
            NSNumber *msgType = [reader objectForColumnIndex:10];
            NSNumber *state = [reader objectForColumnIndex:11];
            NSNumber *direction = [reader objectForColumnIndex:12];
            NSString *contentResolve = [reader objectForColumnIndex:13];
            NSNumber *readState = [reader objectForColumnIndex:14];
            NSNumber *msgDateTime = [reader objectForColumnIndex:15];
            NSString *messageRaw = [reader objectForColumnIndex:16];
            NSString *realJid = [reader objectForColumnIndex:17];
            
            [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:originfrom forKey:@"OriginFrom"];
            [IMDataManager safeSaveForDic:msgDic setObject:originto forKey:@"OriginTo"];
            [IMDataManager safeSaveForDic:msgDic setObject:originChatType forKey:@"OriginChatType"];
            [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:msgDic setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:msgDic setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:msgDic setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:msgDic setObject:state forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:msgDic setObject:direction forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:msgDic setObject:contentResolve forKey:@"ContentResolve"];
            [IMDataManager safeSaveForDic:msgDic setObject:readState forKey:@"ReadState"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:messageRaw forKey:@"MessageRaw"];
            [IMDataManager safeSaveForDic:msgDic setObject:realJid forKey:@"RealJid"];
        }
    }];
    QIMVerboseLog(@"");
    return msgDic;
}

- (NSArray *)qimDB_getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId{
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT a.MsgId, Originfrom, Originto, Origintype, XmppId, Platform, \"From\", \"To\", Content, ExtendInfo, Type, State, Direction, ContentResolve, ReadState, LastUpdateTime, MessageRaw, RealJid from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (Originto = '%@' and Originfrom Like '%%%@%%') ORDER by LastUpdateTime", userId, originUserId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *originfrom = [reader objectForColumnIndex:1];
            NSString *originto = [reader objectForColumnIndex:2];
            NSString *originChatType = [reader objectForColumnIndex:3];
            NSString *xmppId = [reader objectForColumnIndex:4];
            NSNumber *platform = [reader objectForColumnIndex:5];
            NSString *from = [reader objectForColumnIndex:6];
            NSString *to = [reader objectForColumnIndex:7];
            NSString *content = [reader objectForColumnIndex:8];
            NSString *extendInfo = [reader objectForColumnIndex:9];
            NSNumber *msgType = [reader objectForColumnIndex:10];
            NSNumber *state = [reader objectForColumnIndex:11];
            NSNumber *direction = [reader objectForColumnIndex:12];
            NSString *contentResolve = [reader objectForColumnIndex:13];
            NSNumber *readState = [reader objectForColumnIndex:14];
            NSNumber *msgDateTime = [reader objectForColumnIndex:15];
            NSString *messageRaw = [reader objectForColumnIndex:16];
            NSString *realJid = [reader objectForColumnIndex:17];
            
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:originfrom forKey:@"OriginFrom"];
            [IMDataManager safeSaveForDic:msgDic setObject:originto forKey:@"OriginTo"];
            [IMDataManager safeSaveForDic:msgDic setObject:originChatType forKey:@"OriginChatType"];
            [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:msgDic setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:msgDic setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:msgDic setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:msgDic setObject:state forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:msgDic setObject:direction forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:msgDic setObject:contentResolve forKey:@"ContentResolve"];
            [IMDataManager safeSaveForDic:msgDic setObject:readState forKey:@"ReadState"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:messageRaw forKey:@"MessageRaw"];
            [IMDataManager safeSaveForDic:msgDic setObject:realJid forKey:@"RealJid"];
            [result addObject:msgDic];
        }
        
    }];
    QIMVerboseLog(@"");
    return result;
}

@end
