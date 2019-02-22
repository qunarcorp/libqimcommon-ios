//
//  IMDataManager+WorkFeed.m
//  QIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "IMDataManager+WorkFeed.h"
#import "Database.h"

@implementation IMDataManager (WorkFeed)

//创建工作圈表
/*
result = [database executeNonQuery:@"CREATE TABLE IM_Work_World (\
          id                    INTEGER,\
          uuid                  TEXT PRIMARY KEY,\
          owner                 TEXT,\
          ownerHost             TEXT,\
          isAnonymous           INTEGER DEFAULT 0,\
          anonymousName         TEXT,\
          anonymousPhoto        TEXT,\
          createTime            INTEGER,\
          updateTime            INTEGER,\
          content               INTEGER,\
          atList                TEXT,\
          isDelete              INTEGER DEFAULT 0,\
          isLike                INTEGER DEFAULT 0,\
          likeNum               INTEGER,\
          commentsNum           INTEGER,\
          review_status         INTEGER)" withParameters:nil];
*/
- (void)qimDB_bulkinsertMoments:(NSArray *)moments {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or Replace into IM_Work_World(id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status) values(:id, :uuid, :owner, :ownerHost, :isAnonymous, :anonymousName, :anonymousPhoto, :createTime, :updateTime, :content, :atList, :isDelete, :isLike, :likeNum, :commentsNum, :review_status);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *momentDic in moments) {
            NSString *rId = [momentDic objectForKey:@"id"];
            NSString *uuid = [momentDic objectForKey:@"uuid"];
            NSString *owner = [momentDic objectForKey:@"owner"];
            NSString *ownerHost = [momentDic objectForKey:@"ownerHost"];
            NSNumber *isAnonymous = [momentDic objectForKey:@"isAnonymous"];
            NSString *anonymousName = [momentDic objectForKey:@"anonymousName"];
            NSString *anonymousPhoto = [momentDic objectForKey:@"anonymousPhoto"];
            NSNumber *createTime = [momentDic objectForKey:@"createTime"];
            NSNumber *updateTime = [momentDic objectForKey:@"updateTime"];
            NSString *content = [momentDic objectForKey:@"content"];
            NSString *atList = [momentDic objectForKey:@"atList"];
            NSNumber *isDelete = [momentDic objectForKey:@"isDelete"];
            NSNumber *isLike = [momentDic objectForKey:@"isLike"];
            NSNumber *likeNum = [momentDic objectForKey:@"likeNum"];
            NSNumber *commentsNum = [momentDic objectForKey:@"commentsNum"];
            NSNumber *reviewStatus = [momentDic objectForKey:@"reviewStatus"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:rId];
            [param addObject:uuid?uuid:@":NULL"];
            [param addObject:owner?owner:@":NULL"];
            [param addObject:ownerHost?ownerHost:@":NULL"];
            [param addObject:isAnonymous?isAnonymous:@(0)];
            [param addObject:anonymousName?anonymousName:@":NULL"];
            [param addObject:anonymousPhoto?anonymousPhoto:@":NULL"];
            [param addObject:createTime?createTime:@(0)];
            [param addObject:updateTime?updateTime:@(0)];
            [param addObject:content?content:@":NULL"];
            [param addObject:atList?atList:@":NULL"];
            [param addObject:isDelete?isDelete:@(0)];
            [param addObject:isLike?isLike:@(0)];
            [param addObject:likeNum?likeNum:@(0)];
            [param addObject:commentsNum?commentsNum:@(0)];
            [param addObject:reviewStatus];
            
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (void)qimDB_bulkdeleteMoments:(NSArray *)moments {
    if (moments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"delete from IM_Work_World where id = :id;";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *momentDic in moments) {
            NSString *rId = [momentDic objectForKey:@"id"];
            NSString *uuid = [momentDic objectForKey:@"uuid"];
            NSNumber *isDelete = [momentDic objectForKey:@"isDelete"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:rId];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (NSDictionary *)qimDB_getWorkMomentWithMomentId:(NSString *)momentId {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status from IM_Work_World where uuid = :uuid";
        DataReader *reader = [database executeReader:sql withParameters:@[momentId]];
        if (result == nil) {
            result = [[NSMutableDictionary alloc] init];
        }
        if ([reader read]) {
            NSNumber *rid = [reader objectForColumnIndex:0];
            NSString *uuid = [reader objectForColumnIndex:1];
            NSString *owner = [reader objectForColumnIndex:2];
            NSString *ownerHost = [reader objectForColumnIndex:3];
            NSNumber *isAnonymous = [reader objectForColumnIndex:4];
            NSString *anonymousName = [reader objectForColumnIndex:5];
            NSString *anonymousPhoto = [reader objectForColumnIndex:6];
            NSNumber *createTime = [reader objectForColumnIndex:7];
            NSNumber *updateTime = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSString *atList = [reader objectForColumnIndex:10];
            NSNumber *isDelete = [reader objectForColumnIndex:11];
            NSNumber *isLike = [reader objectForColumnIndex:12];
            NSNumber *likeNum = [reader objectForColumnIndex:13];
            NSNumber *commentsNum = [reader objectForColumnIndex:14];
            NSNumber *review_status = [reader objectForColumnIndex:15];
            
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:result setObject:rid forKey:@"id"];
            [IMDataManager safeSaveForDic:result setObject:uuid forKey:@"uuid"];
            [IMDataManager safeSaveForDic:result setObject:owner forKey:@"owner"];
            [IMDataManager safeSaveForDic:result setObject:ownerHost forKey:@"ownerHost"];
            [IMDataManager safeSaveForDic:result setObject:isAnonymous forKey:@"isAnonymous"];
            [IMDataManager safeSaveForDic:result setObject:anonymousName forKey:@"anonymousName"];
            [IMDataManager safeSaveForDic:result setObject:anonymousPhoto forKey:@"anonymousPhoto"];
            [IMDataManager safeSaveForDic:result setObject:createTime forKey:@"createTime"];
            [IMDataManager safeSaveForDic:result setObject:updateTime forKey:@"updateTime"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:result setObject:atList forKey:@"atList"];
            [IMDataManager safeSaveForDic:result setObject:isDelete forKey:@"isDelete"];
            [IMDataManager safeSaveForDic:result setObject:isLike forKey:@"isLike"];
            [IMDataManager safeSaveForDic:result setObject:likeNum forKey:@"likeNum"];
            [IMDataManager safeSaveForDic:result setObject:commentsNum forKey:@"commentsNum"];
            [IMDataManager safeSaveForDic:result setObject:review_status forKey:@"review_status"];
        }
    }];
    return [result autorelease];
}

- (NSDictionary *)qimDB_getLastWorkMoment {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status from IM_Work_World order by createTime desc limit 1";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (result == nil) {
            result = [[NSMutableDictionary alloc] init];
        }
        if ([reader read]) {
            NSNumber *rid = [reader objectForColumnIndex:0];
            NSString *uuid = [reader objectForColumnIndex:1];
            NSString *owner = [reader objectForColumnIndex:2];
            NSString *ownerHost = [reader objectForColumnIndex:3];
            NSNumber *isAnonymous = [reader objectForColumnIndex:4];
            NSString *anonymousName = [reader objectForColumnIndex:5];
            NSString *anonymousPhoto = [reader objectForColumnIndex:6];
            NSNumber *createTime = [reader objectForColumnIndex:7];
            NSNumber *updateTime = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSString *atList = [reader objectForColumnIndex:10];
            NSNumber *isDelete = [reader objectForColumnIndex:11];
            NSNumber *isLike = [reader objectForColumnIndex:12];
            NSNumber *likeNum = [reader objectForColumnIndex:13];
            NSNumber *commentsNum = [reader objectForColumnIndex:14];
            NSNumber *review_status = [reader objectForColumnIndex:15];
            
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:result setObject:rid forKey:@"id"];
            [IMDataManager safeSaveForDic:result setObject:uuid forKey:@"uuid"];
            [IMDataManager safeSaveForDic:result setObject:owner forKey:@"owner"];
            [IMDataManager safeSaveForDic:result setObject:ownerHost forKey:@"ownerHost"];
            [IMDataManager safeSaveForDic:result setObject:isAnonymous forKey:@"isAnonymous"];
            [IMDataManager safeSaveForDic:result setObject:anonymousName forKey:@"anonymousName"];
            [IMDataManager safeSaveForDic:result setObject:anonymousPhoto forKey:@"anonymousPhoto"];
            [IMDataManager safeSaveForDic:result setObject:createTime forKey:@"createTime"];
            [IMDataManager safeSaveForDic:result setObject:updateTime forKey:@"updateTime"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:result setObject:atList forKey:@"atList"];
            [IMDataManager safeSaveForDic:result setObject:isDelete forKey:@"isDelete"];
            [IMDataManager safeSaveForDic:result setObject:isLike forKey:@"isLike"];
            [IMDataManager safeSaveForDic:result setObject:likeNum forKey:@"likeNum"];
            [IMDataManager safeSaveForDic:result setObject:commentsNum forKey:@"commentsNum"];
            [IMDataManager safeSaveForDic:result setObject:review_status forKey:@"review_status"];
        }
    }];
    return [result autorelease];
}

- (NSArray *)qimDB_getWorkMomentWithXmppId:(NSString *)xmppId WihtLimit:(int)limit WithOffset:(int)offset {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = nil;
        if (xmppId == nil) {
            sql = [NSString stringWithFormat:@"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status from IM_Work_World order by createTime desc limit %d offset %d;", limit, offset];
        } else {
            sql = [NSString stringWithFormat:@"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status from IM_Work_World where owner='%@' and ownerHost='%@' and isAnonymous = 0 order by createTime desc limit %d offset %d;", [[xmppId componentsSeparatedByString:@"@"] firstObject], [[xmppId componentsSeparatedByString:@"@"] lastObject], limit, offset];
        }
        NSLog(@"sql : %@", sql);
        DataReader *reader = [database executeReader:sql withParameters:nil];
        NSMutableArray *tempList = nil;
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
        }
        
        while ([reader read]) {
            NSNumber *rid = [reader objectForColumnIndex:0];
            NSString *uuid = [reader objectForColumnIndex:1];
            NSString *owner = [reader objectForColumnIndex:2];
            NSString *ownerHost = [reader objectForColumnIndex:3];
            NSNumber *isAnonymous = [reader objectForColumnIndex:4];
            NSString *anonymousName = [reader objectForColumnIndex:5];
            NSString *anonymousPhoto = [reader objectForColumnIndex:6];
            NSNumber *createTime = [reader objectForColumnIndex:7];
            NSNumber *updateTime = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSString *atList = [reader objectForColumnIndex:10];
            NSNumber *isDelete = [reader objectForColumnIndex:11];
            NSNumber *isLike = [reader objectForColumnIndex:12];
            NSNumber *likeNum = [reader objectForColumnIndex:13];
            NSNumber *commentsNum = [reader objectForColumnIndex:14];
            NSNumber *review_status = [reader objectForColumnIndex:15];

            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:msgDic setObject:rid forKey:@"id"];
            [IMDataManager safeSaveForDic:msgDic setObject:uuid forKey:@"uuid"];
            [IMDataManager safeSaveForDic:msgDic setObject:owner forKey:@"owner"];
            [IMDataManager safeSaveForDic:msgDic setObject:ownerHost forKey:@"ownerHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:isAnonymous forKey:@"isAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:anonymousName forKey:@"anonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:anonymousPhoto forKey:@"anonymousPhoto"];
            [IMDataManager safeSaveForDic:msgDic setObject:createTime forKey:@"createTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:updateTime forKey:@"updateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:msgDic setObject:atList forKey:@"atList"];
            [IMDataManager safeSaveForDic:msgDic setObject:isDelete forKey:@"isDelete"];
            [IMDataManager safeSaveForDic:msgDic setObject:isLike forKey:@"isLike"];
            [IMDataManager safeSaveForDic:msgDic setObject:likeNum forKey:@"likeNum"];
            [IMDataManager safeSaveForDic:msgDic setObject:commentsNum forKey:@"commentsNum"];
            [IMDataManager safeSaveForDic:msgDic setObject:review_status forKey:@"review_status"];

            [result addObject:msgDic];
            [msgDic release];
        }
    }];
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"sql取Moment消息耗时。: %llf", endTime - startTime);
    return [result autorelease];
}

- (void)qimDB_deleteMomentWithRId:(NSInteger)rId {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"delete from IM_Work_World where id = :id";
        DataReader *reader = [database executeReader:sql withParameters:@[@(rId)]];
        if ([reader read]) {
            
        }
    }];
}

- (void)qimDB_updateMomentLike:(NSArray *)likeMoments {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Work_World Set isLike = :isLike, likeNum = :likeNum Where uuid = :uuid;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *likeDic in likeMoments) {
            NSNumber *isLike = [likeDic objectForKey:@"isLike"];
            NSNumber *likeNum = [likeDic objectForKey:@"likeNum"];
            NSString *uuid = [likeDic objectForKey:@"postId"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:isLike];
            [param addObject:likeNum];
            [param addObject:uuid];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (void)qimDB_updateMomentWithLikeNum:(NSInteger)likeMomentNum WithCommentNum:(NSInteger)commentNum withPostId:(NSString *)postId {
    if (postId.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"update IM_Work_World set likeNum = %ld, commentsNum = %ld where uuid = '%@'", likeMomentNum, commentNum, postId];
        [database executeNonQuery:sql withParameters:nil];
    }];
}

#pragma mark - Comment

- (void)qimDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID withcurCommentCreateTime:(long long)createTime {
    if (postUUID.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Work_Comment where postUUID = '%@' and createTime < %lld;", postUUID, createTime];
        [database executeBulkInsert:sql withParameters:nil];
    }];
}

- (long long)qimDB_getCommentCreateTimeWithCurCommentId:(NSInteger)rCommentId {

    __block long long curCommentCreateTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select createTime from IM_Work_Comment where id = %ld;", rCommentId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            curCommentCreateTime = [[reader objectForColumnIndex:0] longLongValue];
        }
    }];
    return curCommentCreateTime;
}

- (void)qimDB_bulkDeleteComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"delete from IM_Work_Comment where commentUUID = :commentUUID;";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *commentDic in comments) {
            NSString *uuid = [commentDic objectForKey:@"uuid"];
            NSNumber *isDelete = [commentDic objectForKey:@"isDelete"];
            if ([isDelete boolValue] == YES) {
                NSMutableArray *param = [[NSMutableArray alloc] init];
                [param addObject:uuid];
                [paramList addObject:param];
            }
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (void)qimDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID {
    if (postUUID.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Work_Comment where postUUID = '%@';", postUUID];
        [database executeBulkInsert:sql withParameters:nil];
    }];
}

- (void)qimDB_bulkinsertComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or Replace into IM_Work_Comment(anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, parentCommentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime) values(:anonymousName, :anonymousPhoto, :commentUUID, :content, :createTime, :fromHost, :fromUser, :id, :isAnonymous, :isDelete, :isLike, :likeNum, :parentCommentUUID, :postUUID, :reviewStatus, :toAnonymousName, :toAnonymousPhoto, :toHost, :toUser, :toisAnonymous, :updateTime);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *commentDic in comments) {
            
            NSString *anonymousName = [commentDic objectForKey:@"anonymousName"];
            NSString *anonymousPhoto = [commentDic objectForKey:@"anonymousPhoto"];
            NSString *commentUUID = [commentDic objectForKey:@"commentUUID"];
            NSString *content = [commentDic objectForKey:@"content"];
            NSNumber *createTime = [commentDic objectForKey:@"createTime"];
            NSString *fromHost = [commentDic objectForKey:@"fromHost"];
            NSString *fromUser = [commentDic objectForKey:@"fromUser"];
            NSNumber *rid = [commentDic objectForKey:@"id"];
            NSNumber *isAnonymous = [commentDic objectForKey:@"isAnonymous"];
            NSNumber *isDelete = [commentDic objectForKey:@"isDelete"];
            NSNumber *isLike = [commentDic objectForKey:@"isLike"];
            NSNumber *likeNum = [commentDic objectForKey:@"likeNum"];
            NSString *parentCommentUUID = [commentDic objectForKey:@"parentCommentUUID"];
            NSString *postUUID = [commentDic objectForKey:@"postUUID"];
            NSNumber *reviewStatus = [commentDic objectForKey:@"reviewStatus"];
            NSString *toAnonymousName = [commentDic objectForKey:@"toAnonymousName"];
            NSString *toAnonymousPhoto = [commentDic objectForKey:@"toAnonymousPhoto"];
            NSString *toHost = [commentDic objectForKey:@"toHost"];
            NSString *toUser = [commentDic objectForKey:@"toUser"];
            NSNumber *toisAnonymous = [commentDic objectForKey:@"toisAnonymous"];
            NSNumber *updateTime = [commentDic objectForKey:@"updateTime"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:anonymousName?anonymousName:@":NULL"];
            [param addObject:anonymousPhoto?anonymousPhoto:@":NULL"];
            [param addObject:commentUUID?commentUUID:@":NULL"];
            [param addObject:content?content:@":NULL"];
            [param addObject:createTime?createTime:@(0)];
            [param addObject:fromHost?fromHost:@":NULL"];
            [param addObject:fromUser?fromUser:@":NULL"];
            [param addObject:rid?rid:@(0)];
            [param addObject:isAnonymous?isAnonymous:@(0)];
            [param addObject:isDelete?isDelete:@(0)];
            [param addObject:isLike?isLike:@(0)];
            [param addObject:likeNum?likeNum:@(0)];
            [param addObject:parentCommentUUID?parentCommentUUID:@":NULL"];
            [param addObject:postUUID?postUUID:@":NULL"];
            [param addObject:reviewStatus?reviewStatus:@(0)];
            [param addObject:toAnonymousName?toAnonymousName:@":NULL"];
            [param addObject:toAnonymousPhoto?toAnonymousPhoto:@":NULL"];
            [param addObject:toHost?toHost:@":NULL"];
            [param addObject:toUser?toUser:@":NULL"];
            [param addObject:toisAnonymous?toisAnonymous:@(0)];
            [param addObject:updateTime?updateTime:@(0)];

            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (NSArray *)qimDB_getWorkCommentsWithMomentId:(NSString *)momentId WihtLimit:(int)limit WithOffset:(int)offset {
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, parentCommentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime from IM_Work_Comment where postUUID='%@' and isDelete=0 order by createTime desc limit %d offset %d;", momentId, limit, offset];
        NSLog(@"sql : %@", sql);
        DataReader *reader = [database executeReader:sql withParameters:nil];
        NSMutableArray *tempList = nil;
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
        }
        
        while ([reader read]) {
            NSString *anonymousName = [reader objectForColumnIndex:0];
            NSString *anonymousPhoto = [reader objectForColumnIndex:1];
            NSString *commentUUID = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *createTime = [reader objectForColumnIndex:4];
            NSString *fromHost = [reader objectForColumnIndex:5];
            NSString *fromUser = [reader objectForColumnIndex:6];
            NSNumber *rid = [reader objectForColumnIndex:7];
            NSNumber *isAnonymous = [reader objectForColumnIndex:8];
            NSNumber *isDelete = [reader objectForColumnIndex:9];
            NSNumber *isLike = [reader objectForColumnIndex:10];
            NSNumber *likeNum = [reader objectForColumnIndex:11];
            NSString *parentCommentUUID = [reader objectForColumnIndex:12];
            NSString *postUUID = [reader objectForColumnIndex:13];
            NSNumber *reviewStatus = [reader objectForColumnIndex:14];
            NSString *toAnonymousName = [reader objectForColumnIndex:15];
            NSString *toAnonymousPhoto = [reader objectForColumnIndex:16];
            NSString *toHost = [reader objectForColumnIndex:17];
            NSString *toUser = [reader objectForColumnIndex:18];
            NSNumber *toisAnonymous = [reader objectForColumnIndex:19];
            NSNumber *updateTime = [reader objectForColumnIndex:20];
            
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:msgDic setObject:anonymousName forKey:@"anonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:anonymousPhoto forKey:@"anonymousPhoto"];
            [IMDataManager safeSaveForDic:msgDic setObject:commentUUID forKey:@"commentUUID"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:msgDic setObject:createTime forKey:@"createTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:fromHost forKey:@"fromHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:fromUser forKey:@"fromUser"];
            [IMDataManager safeSaveForDic:msgDic setObject:rid forKey:@"rid"];
            
            [IMDataManager safeSaveForDic:msgDic setObject:isAnonymous forKey:@"isAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:isDelete forKey:@"isDelete"];
            [IMDataManager safeSaveForDic:msgDic setObject:isLike forKey:@"isLike"];
            [IMDataManager safeSaveForDic:msgDic setObject:likeNum forKey:@"likeNum"];
            [IMDataManager safeSaveForDic:msgDic setObject:parentCommentUUID forKey:@"parentCommentUUID"];
            [IMDataManager safeSaveForDic:msgDic setObject:postUUID forKey:@"postUUID"];
            
            [IMDataManager safeSaveForDic:msgDic setObject:reviewStatus forKey:@"reviewStatus"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousName forKey:@"toAnonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousPhoto forKey:@"toAnonymousPhoto"];
            [IMDataManager safeSaveForDic:msgDic setObject:toHost forKey:@"toHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:toUser forKey:@"toUser"];
            [IMDataManager safeSaveForDic:msgDic setObject:toisAnonymous forKey:@"toisAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:updateTime forKey:@"updateTime"];


            [result addObject:msgDic];
            [msgDic release];
        }
    }];
    //    QIMVerboseLog(@"sql取消息耗时。: %llf", [[QIMWatchDog sharedInstance] escapedTime]);
    return [result autorelease];
}


#pragma mark - NoticeMessage

- (void)qimDB_bulkinsertNoticeMessage:(NSArray *)notices {
    if (notices.count <= 0) {
        return;
    }
    /*
    userFrom              TEXT,\
    readState             INTEGER,\
    postUUID              TEXT,\
    fromIsAnonymous       INTEGER,\
    toIsAnonymous         INTEGER,\
    eventType             INTEGER,\
    fromAnonymousPhoto    TEXT,\
    userTo                TEXT,\
    uuid                  TEXT PRIMARY KEY,,\
    content               TEXT,\
    userToHost            TEXT,\
    createTime            INTEGER,\
    userFromHost          TEXT,\
    fromAnonymousName     TEXT
    */
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or Replace into IM_Work_NoticeMessage(userFrom, readState, postUUID, fromIsAnonymous, toIsAnonymous, eventType, fromAnonymousPhoto, userTo, uuid, content, userToHost, createTime, userFromHost, fromAnonymousName, toAnonymousName, toAnonymousPhoto) values(:userFrom, :readState, :postUUID, :fromIsAnonymous, :toIsAnonymous, :eventType, :fromAnonymousPhoto, :userTo, :uuid, :content, :userToHost, :createTime, :userFromHost, :fromAnonymousName, :toAnonymousName, :toAnonymousPhoto);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *noticeMsgDic in notices) {
            
            NSString *userFrom = [noticeMsgDic objectForKey:@"userFrom"];
            NSNumber *readState = [noticeMsgDic objectForKey:@"readState"];
            NSString *postUUID = [noticeMsgDic objectForKey:@"postUUID"];
            NSNumber *fromIsAnonymous = [noticeMsgDic objectForKey:@"fromIsAnonymous"];
            NSNumber *toIsAnonymous = [noticeMsgDic objectForKey:@"toIsAnonymous"];
            NSNumber *eventType = [noticeMsgDic objectForKey:@"eventType"];
            NSString *fromAnonymousPhoto = [noticeMsgDic objectForKey:@"fromAnonymousPhoto"];
            NSString *userTo = [noticeMsgDic objectForKey:@"userTo"];
            
            NSString *uuid = [noticeMsgDic objectForKey:@"uuid"];
            NSString *content = [noticeMsgDic objectForKey:@"content"];
            NSString *userToHost = [noticeMsgDic objectForKey:@"userToHost"];
            NSNumber *createTime = [noticeMsgDic objectForKey:@"createTime"];
            NSString *userFromHost = [noticeMsgDic objectForKey:@"userFromHost"];
            NSString *fromAnonymousName = [noticeMsgDic objectForKey:@"fromAnonymousName"];
            NSString *toAnonymousName = [noticeMsgDic objectForKey:@"toAnonymousName"];
            NSString *toAnonymousPhoto = [noticeMsgDic objectForKey:@"toAnonymousPhoto"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userFrom?userFrom:@":NULL"];
            [param addObject:readState?readState:@(0)];
            [param addObject:postUUID?postUUID:@":NULL"];
            [param addObject:fromIsAnonymous?fromIsAnonymous:@(0)];
            [param addObject:toIsAnonymous?toIsAnonymous:@(0)];
            [param addObject:eventType?eventType:@(0)];
            [param addObject:fromAnonymousPhoto?fromAnonymousPhoto:@":NULL"];
            [param addObject:userTo?userTo:@":NULL"];
            [param addObject:uuid?uuid:@":NULL"];
            [param addObject:content?content:@":NULL"];
            [param addObject:userToHost?userToHost:@":NULL"];
            [param addObject:createTime?createTime:@(0)];
            [param addObject:userFromHost?userFromHost:@":NULL"];
            [param addObject:fromAnonymousName?fromAnonymousName:@":NULL"];
            [param addObject:toAnonymousName?toAnonymousName:@":NULL"];
            [param addObject:toAnonymousPhoto?toAnonymousPhoto:@":NULL"];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (long long)qimDB_getWorkNoticeMessagesMaxTime {
    __block long long time = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select max(createTime) from IM_Work_NoticeMessage"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            time = [[reader objectForColumnIndex:0] longLongValue];
        }
    }];
    return time;
}

- (NSInteger)qimDB_getWorkNoticeMessagesCount {
    __block NSInteger count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from IM_Work_NoticeMessage Where readState=0 and eventType=1;"];
        NSLog(@"sql : %@", sql);
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    NSLog(@"qimDB_getWorkNoticeMessagesCount : %ld", count);
    return count;
}

- (NSArray *)qimDB_getWorkNoticeMessagesWihtLimit:(int)limit WithOffset:(int)offset {
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select userFrom, readState, postUUID, fromIsAnonymous, toIsAnonymous, eventType, fromAnonymousPhoto, userTo, uuid, content, userToHost, createTime, userFromHost, fromAnonymousName, toAnonymousName, toAnonymousPhoto from IM_Work_NoticeMessage where eventType=1 and readState=0 order by createTime desc limit %d offset %d;", limit, offset];
        NSLog(@"sql : %@", sql);
        DataReader *reader = [database executeReader:sql withParameters:nil];
        NSMutableArray *tempList = nil;
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
        }
        while ([reader read]) {
        
            NSString *userFrom = [reader objectForColumnIndex:0];
            NSNumber *readState = [reader objectForColumnIndex:1];
            NSString *postUUID = [reader objectForColumnIndex:2];
            NSNumber *fromIsAnonymous = [reader objectForColumnIndex:3];
            NSNumber *toIsAnonymous = [reader objectForColumnIndex:4];
            NSNumber *eventType = [reader objectForColumnIndex:5];
            NSString *fromAnonymousPhoto = [reader objectForColumnIndex:6];
            NSString *userTo = [reader objectForColumnIndex:7];
            
            NSString *uuid = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSString *userToHost = [reader objectForColumnIndex:10];
            NSNumber *createTime = [reader objectForColumnIndex:11];
            NSString *userFromHost = [reader objectForColumnIndex:12];
            NSString *fromAnonymousName = [reader objectForColumnIndex:13];
            NSString *toAnonymousName = [reader objectForColumnIndex:14];
            NSString *toAnonymousPhoto = [reader objectForColumnIndex:15];
            
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:msgDic setObject:userFrom forKey:@"userFrom"];
            [IMDataManager safeSaveForDic:msgDic setObject:readState forKey:@"readState"];
            [IMDataManager safeSaveForDic:msgDic setObject:postUUID forKey:@"postUUID"];
            [IMDataManager safeSaveForDic:msgDic setObject:fromIsAnonymous forKey:@"fromIsAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:toIsAnonymous forKey:@"toIsAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:eventType forKey:@"eventType"];
            [IMDataManager safeSaveForDic:msgDic setObject:fromAnonymousPhoto forKey:@"fromAnonymousPhoto"];
            [IMDataManager safeSaveForDic:msgDic setObject:userTo forKey:@"userTo"];
            
            [IMDataManager safeSaveForDic:msgDic setObject:uuid forKey:@"uuid"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:msgDic setObject:userToHost forKey:@"userToHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:createTime forKey:@"createTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:userFromHost forKey:@"userFromHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:fromAnonymousName forKey:@"fromAnonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousName forKey:@"toAnonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousPhoto forKey:@"toAnonymousPhoto"];
            
            [result addObject:msgDic];
            [msgDic release];
        }
    }];
    //    QIMVerboseLog(@"sql取消息耗时。: %llf", [[QIMWatchDog sharedInstance] escapedTime]);
    return [result autorelease];
}

- (void)qimDB_updateWorkNoticeMessageReadStateWithTime:(long long)time {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"update IM_Work_NoticeMessage set readState=1 where readState=0 and createTime <= %lld", time];
        NSLog(@"qimDB_updateWorkNoticeMessageReadStateWithTime sql : %@", sql);
        BOOL success = [database executeNonQuery:sql withParameters:nil];
        if (success) {
            NSLog(@"qimDB_updateWorkNoticeMessageReadStateWithTime success");
        } else {
            NSLog(@"qimDB_updateWorkNoticeMessageReadStateWithTime faild");
        }
    }];
}

- (NSDictionary *)qimDB_getLastWorkMomentMessageDic {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select userFrom, readState, postUUID, fromIsAnonymous, toIsAnonymous, eventType, fromAnonymousPhoto, userTo, uuid, content, userToHost, createTime, userFromHost, fromAnonymousName, toAnonymousName, toAnonymousPhoto from IM_Work_NoticeMessage where eventType=0 order by createTime desc limit 1"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            if (!result) {
                result = [[NSMutableDictionary alloc] init];
            }
            NSString *userFrom = [reader objectForColumnIndex:0];
            NSNumber *readState = [reader objectForColumnIndex:1];
            NSString *postUUID = [reader objectForColumnIndex:2];
            NSNumber *fromIsAnonymous = [reader objectForColumnIndex:3];
            NSNumber *toIsAnonymous = [reader objectForColumnIndex:4];
            NSNumber *eventType = [reader objectForColumnIndex:5];
            NSString *fromAnonymousPhoto = [reader objectForColumnIndex:6];
            NSString *userTo = [reader objectForColumnIndex:7];
            
            NSString *uuid = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSString *userToHost = [reader objectForColumnIndex:10];
            NSNumber *createTime = [reader objectForColumnIndex:11];
            NSString *userFromHost = [reader objectForColumnIndex:12];
            NSString *fromAnonymousName = [reader objectForColumnIndex:13];
            NSString *toAnonymousName = [reader objectForColumnIndex:14];
            NSString *toAnonymousPhoto = [reader objectForColumnIndex:15];
            
            [IMDataManager safeSaveForDic:result setObject:userFrom forKey:@"userFrom"];
            [IMDataManager safeSaveForDic:result setObject:readState forKey:@"readState"];
            [IMDataManager safeSaveForDic:result setObject:postUUID forKey:@"postUUID"];
            [IMDataManager safeSaveForDic:result setObject:fromIsAnonymous forKey:@"fromIsAnonymous"];
            [IMDataManager safeSaveForDic:result setObject:toIsAnonymous forKey:@"toIsAnonymous"];
            [IMDataManager safeSaveForDic:result setObject:eventType forKey:@"eventType"];
            [IMDataManager safeSaveForDic:result setObject:fromAnonymousPhoto forKey:@"fromAnonymousPhoto"];
            [IMDataManager safeSaveForDic:result setObject:userTo forKey:@"userTo"];
            
            [IMDataManager safeSaveForDic:result setObject:uuid forKey:@"uuid"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:result setObject:userToHost forKey:@"userToHost"];
            [IMDataManager safeSaveForDic:result setObject:createTime forKey:@"createTime"];
            [IMDataManager safeSaveForDic:result setObject:userFromHost forKey:@"userFromHost"];
            [IMDataManager safeSaveForDic:result setObject:fromAnonymousName forKey:@"fromAnonymousName"];
            [IMDataManager safeSaveForDic:result setObject:toAnonymousName forKey:@"toAnonymousName"];
            [IMDataManager safeSaveForDic:result setObject:toAnonymousPhoto forKey:@"toAnonymousPhoto"];
        }
    }];
    return [result autorelease];
}

@end