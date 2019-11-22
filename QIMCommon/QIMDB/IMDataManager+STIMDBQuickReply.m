//
//  IMDataManager+STIMDBQuickReply.m
//  STIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "IMDataManager+STIMDBQuickReply.h"
#import "STIMDataBase.h"

@implementation IMDataManager (STIMDBQuickReply)

#pragma mark - Group

- (long)stIMDB_getQuickReplyGroupVersion {
    __block long version = 0;
    [[self dbInstance] inDatabase:^(STIMDataBase* _Nonnull database) {
        NSString *sql = @"select max(version) from IM_QUICK_REPLY_GROUP";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            version = [[reader objectForColumnIndex:0] longValue];
        }
        [reader close];
    }];
    return version;
}

- (void)stIMDB_clearQuickReplyGroup {
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"delete from IM_QUICK_REPLY_GROUP";
        [database executeNonQuery:sql withParameters:nil];
    }];
}

- (void)stIMDB_bulkInsertQuickReply:(NSArray *)groupItems {
    if (groupItems.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or replace into IM_QUICK_REPLY_GROUP(sid, groupname, groupseq, version) values(:sid, :groupname, :groupseq, :version)";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary * info in groupItems) {
            long sid = [[info objectForKey:@"id"] longValue];
            NSString *groupname = [info objectForKey:@"groupname"];
            long groupseq = [[info objectForKey:@"groupseq"] longValue];
            long version = [[info objectForKey:@"version"] longValue];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:@(sid)];
            [param addObject:(groupname.length > 0) ? groupname : @":NULL"];
            [param addObject:@(groupseq)];
            [param addObject:@(version)];
            
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

- (void)stIMDB_deleteQuickReplyGroup:(NSArray *)groupItems {
    if (groupItems.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableString *groupSql = [NSMutableString stringWithString:@"delete from IM_QUICK_REPLY_GROUP where sid in ("];
        NSMutableString *contentSql = [NSMutableString stringWithString:@"delete from IM_QUICK_REPLY_CONTENT where gid in ("];
        int index = 0;
        for (NSNumber *groupIdNum in groupItems) {
            long groupId = [groupIdNum longValue];
            [groupSql appendFormat:@"%ld", groupId];
            [contentSql appendFormat:@"%ld", groupId];
            if (index < groupItems.count-1) {
                [groupSql appendFormat:@","];
                [contentSql appendFormat:@","];
            } else {
                [groupSql appendString:@");"];
                [contentSql appendString:@");"];
            }
            index++;
        }
        [database executeNonQuery:groupSql withParameters:nil];
        [database executeNonQuery:contentSql withParameters:nil];
    }];
}

- (NSInteger)stIMDB_getQuickReplyGroupCount  {
    __block NSInteger count = 0;
    [[self dbInstance] inDatabase:^(STIMDataBase* _Nonnull database) {
        NSString *sql = @"select count(*) from IM_QUICK_REPLY_GROUP;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    return count;
}

- (NSArray *)stIMDB_getQuickReplyGroup {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(STIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select *from IM_QUICK_REPLY_GROUP order by groupseq;"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
        }
        while ([reader read]) {
            NSString *sid = [reader objectForColumnIndex:0];
            NSString *groupname = [reader objectForColumnIndex:1];
            NSString *groupseq = [reader objectForColumnIndex:2];
            NSString *groupVersion = [reader objectForColumnIndex:3];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setSTIMSafeObject:sid forKey:@"sid"];
            [dic setSTIMSafeObject:groupname forKey:@"groupname"];
            [dic setSTIMSafeObject:groupseq forKey:@"groupseq"];
            [dic setSTIMSafeObject:groupVersion forKey:@"groupVersion"];
            [result addObject:dic];
        }
    }];
    return result;
}

#pragma mark - Item

- (long)stIMDB_getQuickReplyContentVersion {
    __block long version = 0;
    [[self dbInstance] inDatabase:^(STIMDataBase* _Nonnull database) {
        NSString *sql = @"select max(version) from IM_QUICK_REPLY_CONTENT";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            version = [[reader objectForColumnIndex:0] longValue];
        }
        [reader close];
    }];
    return version;
}

- (void)stIMDB_clearQuickReplyContents {
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"delete from IM_QUICK_REPLY_CONTENT";
        [database executeNonQuery:sql withParameters:nil];
    }];
}

- (void)stIMDB_bulkInsertQuickReplyContents:(NSArray *)contentItems {
    if (contentItems.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or replace into IM_QUICK_REPLY_CONTENT(sid, gid, content, contentseq, version) values(:sid, :gid, :content, :contentseq, :version)";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary * info in contentItems) {
            long sid = [[info objectForKey:@"id"] longValue];
            long gid = [[info objectForKey:@"groupid"] longValue];
            NSString *content = [info objectForKey:@"content"];
            long contentseq = [[info objectForKey:@"contentseq"] longValue];
            
            long version = [[info objectForKey:@"version"] longValue];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:@(sid)];
            [param addObject:@(gid)];
            [param addObject:(content.length > 0) ? content : @":NULL"];
            [param addObject:@(contentseq)];
            [param addObject:@(version)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

- (void)stIMDB_deleteQuickReplyContents:(NSArray *)contentItems {
    if (contentItems.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(STIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableString *contentSql = [NSMutableString stringWithString:@"delete from IM_QUICK_REPLY_CONTENT where sid in ("];
        int index = 0;
        for (NSNumber *contentIdNum in contentItems) {
            long contentId = [contentIdNum longValue];
            [contentSql appendFormat:@"%ld", contentId];
            if (index < contentItems.count-1) {
                [contentSql appendFormat:@","];
            } else {
                [contentSql appendString:@");"];
            }
            index++;
        }
        [database executeNonQuery:contentSql withParameters:nil];
    }];
}

- (NSArray *)stIMDB_getQuickReplyContentWithGroupId:(long)groupId {
    
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(STIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select *from IM_QUICK_REPLY_CONTENT where gid=%ld order by contentseq;", groupId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
        }
        while ([reader read]) {
            NSString *sid = [reader objectForColumnIndex:0];
            NSString *gid = [reader objectForColumnIndex:1];
            NSString *content = [reader objectForColumnIndex:2];
            NSString *contentsql = [reader objectForColumnIndex:3];
            NSString *contentversion = [reader objectForColumnIndex:4];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:6];
            [dic setSTIMSafeObject:sid forKey:@"sid"];
            [dic setSTIMSafeObject:gid forKey:@"gid"];
            [dic setSTIMSafeObject:content forKey:@"content"];
            [dic setSTIMSafeObject:contentsql forKey:@"contentsql"];
            [dic setSTIMSafeObject:contentversion forKey:@"contentversion"];
            [result addObject:dic];
        }
    }];
    return result;
}

@end
