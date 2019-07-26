//
//  IMDataManager+WorkFeed.m
//  QIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "IMDataManager+WorkFeed.h"
#import "QIMDataBase.h"
#import "QIMJSONSerializer.h"

@implementation IMDataManager (WorkFeed)

- (BOOL)qimDB_checkMomentWithMomentId:(NSString *)momentId {
    __block BOOL isExist = NO;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select 1 From IM_Work_World Where uuid = '%@';", momentId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            isExist = YES;
        }
        [reader close];
    }];
    return isExist;
}

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
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or Replace into IM_Work_World(id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status, attachCommentList) values(:id, :uuid, :owner, :ownerHost, :isAnonymous, :anonymousName, :anonymousPhoto, :createTime, :updateTime, :content, :atList, :isDelete, :isLike, :likeNum, :commentsNum, :review_status, :attachCommentList);";
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
            NSArray *attachCommentList = [momentDic objectForKey:@"attachCommentList"];
            NSString *attachCommentListStr = [[QIMJSONSerializer sharedInstance] serializeObject:attachCommentList];
            
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
            [param addObject:attachCommentListStr];
            
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
}

- (void)qimDB_bulkdeleteMomentsWithXmppId:(NSString *)xmppId {
    if (xmppId.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Work_World where owner = '%@' and ownerHost = '%@';", [[xmppId componentsSeparatedByString:@"@"] firstObject], [[xmppId componentsSeparatedByString:@"@"] lastObject]];
        [database executeBulkInsert:sql withParameters:nil];
    }];
}

- (void)qimDB_bulkdeleteMoments:(NSArray *)moments {
    if (moments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
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
    }];
}

- (NSDictionary *)qimDB_getWorkMomentWithMomentId:(NSString *)momentId {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status, attachCommentList from IM_Work_World where uuid = '%@'", momentId];
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
            NSString *attachCommentListStr = [reader objectForColumnIndex:16];
            NSArray *attachCommentList = [[QIMJSONSerializer sharedInstance] deserializeObject:attachCommentListStr error:nil];
            
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
            [IMDataManager safeSaveForDic:result setObject:attachCommentList forKey:@"attachCommentList"];
        }
        [reader close];
    }];
    return result;
}

- (NSDictionary *)qimDB_getLastWorkMoment {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status, attachCommentList from IM_Work_World order by createTime desc limit 1";
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
            NSString *attachCommentListStr = [reader objectForColumnIndex:16];
            NSArray *attachCommentList = [[QIMJSONSerializer sharedInstance] deserializeObject:attachCommentListStr error:nil];
            
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
            [IMDataManager safeSaveForDic:result setObject:attachCommentList forKey:@"attachCommentList"];
        }
        [reader close];
    }];
    return result;
}

- (NSArray *)qimDB_getWorkMomentWithXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = nil;
        if (xmppId == nil) {
            sql = [NSString stringWithFormat:@"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status, attachCommentList from IM_Work_World order by createTime desc limit %d offset %d;", limit, offset];
        } else {
            sql = [NSString stringWithFormat:@"select id, uuid, owner, ownerHost, isAnonymous, anonymousName, anonymousPhoto, createTime, updateTime, content, atList, isDelete, isLike, likeNum, commentsNum, review_status, attachCommentList from IM_Work_World where owner='%@' and ownerHost='%@' and isAnonymous = 0 order by createTime desc limit %d offset %d;", [[xmppId componentsSeparatedByString:@"@"] firstObject], [[xmppId componentsSeparatedByString:@"@"] lastObject], limit, offset];
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
            NSString *attachCommentListStr = [reader objectForColumnIndex:16];
            NSArray *attachCommentList = [[QIMJSONSerializer sharedInstance] deserializeObject:attachCommentListStr error:nil];

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
            [IMDataManager safeSaveForDic:msgDic setObject:attachCommentList forKey:@"attachCommentList"];

            [result addObject:msgDic];
        }
        
    }];
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"sql取Moment消息耗时。: %llf", endTime - startTime);
    return result;
}

- (void)qimDB_deleteMomentWithRId:(NSInteger)rId {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Work_World where id = %ld", rId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            
        }
        [reader close];
    }];
}

- (void)qimDB_updateMomentLike:(NSArray *)likeMoments {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
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
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

- (void)qimDB_updateMomentWithLikeNum:(NSInteger)likeMomentNum WithCommentNum:(NSInteger)commentNum withPostId:(NSString *)postId {
    if (postId.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"update IM_Work_World set likeNum = %ld, commentsNum = %ld where uuid = '%@'", likeMomentNum, commentNum, postId];
        [database executeNonQuery:sql withParameters:nil];
    }];
}

#pragma mark - Comment

- (void)qimDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID withcurCommentCreateTime:(long long)createTime {
    if (postUUID.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Work_CommentV2 where postUUID = '%@' and createTime < %lld;", postUUID, createTime];
        [database executeBulkInsert:sql withParameters:nil];
    }];
}

- (long long)qimDB_getCommentCreateTimeWithCurCommentId:(NSInteger)rCommentId {

    __block long long curCommentCreateTime = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select createTime from IM_Work_CommentV2 where id = %ld;", rCommentId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            curCommentCreateTime = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
    }];
    return curCommentCreateTime;
}

- (void)qimDB_bulkUpdateComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"update IM_Work_CommentV2 set Comment='该评论已被删除'";
        [database executeBulkInsert:sql withParameters:nil];
    }];
}

- (void)qimDB_bulkDeleteCommentsAndAllChildComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"delete from IM_Work_CommentV2 where (commentUUID = :commentUUID Or ParentCommentUUID = :ParentCommentUUID or superCommentUUID = : superCommentUUID) or (ParentCommentUUID = :ParentCommentUUID or superCommentUUID = : superCommentUUID);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *commentDic in comments) {
            NSString *uuid = [commentDic objectForKey:@"uuid"];
            NSNumber *isDelete = [commentDic objectForKey:@"isDelete"];
            if ([isDelete boolValue] == YES) {
                NSMutableArray *param = [[NSMutableArray alloc] init];
                [param addObject:uuid];
                [param addObject:uuid];
                [param addObject:uuid];
                [paramList addObject:param];
            }
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
}

- (void)qimDB_bulkDeleteComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"delete from IM_Work_CommentV2 where commentUUID = :commentUUID;";
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
    }];
}

- (void)qimDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID {
    if (postUUID.length <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"delete from IM_Work_CommentV2 where postUUID = '%@';", postUUID];
        [database executeBulkInsert:sql withParameters:nil];
    }];
}

- (void)qimDB_bulkinsertComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    NSMutableArray *newChilds = [[NSMutableArray alloc] init];
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSql = @"delete from IM_Work_CommentV2 where commentUUID=:commentUUID or parentCommentUUID=:parentCommentUUID or superParentUUID=:superParentUUID;";
        
        NSString *sql = @"insert or Replace into IM_Work_CommentV2(anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, superParentUUID, parentCommentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime, atList) values(:anonymousName, :anonymousPhoto, :commentUUID, :content, :createTime, :fromHost, :fromUser, :id, :isAnonymous, :isDelete, :isLike, :likeNum, :superParentUUID, :parentCommentUUID, :postUUID, :reviewStatus, :toAnonymousName, :toAnonymousPhoto, :toHost, :toUser, :toisAnonymous, :updateTime, :atList);";
        NSMutableArray *deleteParamList = [[NSMutableArray alloc] init];
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
            NSString *superParentUUID = [commentDic objectForKey:@"superParentUUID"];
            NSString *parentCommentUUID = [commentDic objectForKey:@"parentCommentUUID"];
            NSString *postUUID = [commentDic objectForKey:@"postUUID"];
            NSNumber *reviewStatus = [commentDic objectForKey:@"reviewStatus"];
            NSString *toAnonymousName = [commentDic objectForKey:@"toAnonymousName"];
            NSString *toAnonymousPhoto = [commentDic objectForKey:@"toAnonymousPhoto"];
            NSString *toHost = [commentDic objectForKey:@"toHost"];
            NSString *toUser = [commentDic objectForKey:@"toUser"];
            NSNumber *toisAnonymous = [commentDic objectForKey:@"toisAnonymous"];
            NSNumber *updateTime = [commentDic objectForKey:@"updateTime"];
            NSArray *newChild = [commentDic objectForKey:@"newChild"];
            NSString *atList = [commentDic objectForKey:@"atList"];
            
            NSMutableArray *deleteParam = [[NSMutableArray alloc] init];
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
            [param addObject:superParentUUID?superParentUUID:@":NULL"];
            [param addObject:parentCommentUUID?parentCommentUUID:@":NULL"];
            [param addObject:postUUID?postUUID:@":NULL"];
            [param addObject:reviewStatus?reviewStatus:@(0)];
            [param addObject:toAnonymousName?toAnonymousName:@":NULL"];
            [param addObject:toAnonymousPhoto?toAnonymousPhoto:@":NULL"];
            [param addObject:toHost?toHost:@":NULL"];
            [param addObject:toUser?toUser:@":NULL"];
            [param addObject:toisAnonymous?toisAnonymous:@(0)];
            [param addObject:updateTime?updateTime:@(0)];
            [param addObject:atList?atList:@":NULL"];
            
            [deleteParam addObject:commentUUID];
            [deleteParam addObject:commentUUID];
            [deleteParam addObject:commentUUID];
            [deleteParamList addObject:deleteParam];
            [paramList addObject:param];
            NSMutableDictionary *newChildDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:newChildDic setObject:newChild forKey:commentUUID];
            [newChilds addObject:newChildDic];
        }
        [database executeBulkInsert:deleteSql withParameters:deleteParamList];
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    [self qimDB_bulkinsertNewChildComments:newChilds];
}

- (void)qimDB_bulkinsertNewChildComments:(NSArray *)comments {
    if (comments.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSql = @"delete from IM_Work_CommentV2 where parentCommentUUID=:parentCommentUUID or superParentUUID=:superParentUUID;";
        
        NSString *sql = @"insert or Replace into IM_Work_CommentV2(anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, superParentUUID, parentCommentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime, atList) values(:anonymousName, :anonymousPhoto, :commentUUID, :content, :createTime, :fromHost, :fromUser, :id, :isAnonymous, :isDelete, :isLike, :likeNum, :superParentUUID, :parentCommentUUID, :postUUID, :reviewStatus, :toAnonymousName, :toAnonymousPhoto, :toHost, :toUser, :toisAnonymous, :updateTimem, :atList);";
        NSMutableArray *deleteParamList = [[NSMutableArray alloc] init];
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        NSMutableArray *newChilds = [[NSMutableArray alloc] init];
        for (NSDictionary *newChildDic in comments) {
            NSString *ChildParCommentUUID = [[newChildDic allKeys] firstObject];
            NSArray *childComments = [newChildDic objectForKey:ChildParCommentUUID];
            
            for (NSDictionary *commentDic in childComments) {
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
                NSString *superParentUUID = [commentDic objectForKey:@"superParentUUID"];
                NSString *parentCommentUUID = [commentDic objectForKey:@"parentCommentUUID"];
                NSString *postUUID = [commentDic objectForKey:@"postUUID"];
                NSNumber *reviewStatus = [commentDic objectForKey:@"reviewStatus"];
                NSString *toAnonymousName = [commentDic objectForKey:@"toAnonymousName"];
                NSString *toAnonymousPhoto = [commentDic objectForKey:@"toAnonymousPhoto"];
                NSString *toHost = [commentDic objectForKey:@"toHost"];
                NSString *toUser = [commentDic objectForKey:@"toUser"];
                NSNumber *toisAnonymous = [commentDic objectForKey:@"toisAnonymous"];
                NSNumber *updateTime = [commentDic objectForKey:@"updateTime"];
                NSString *atList = [commentDic objectForKey:@"atList"];
                
                NSMutableArray *deleteParam = [[NSMutableArray alloc] init];
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
                [param addObject:superParentUUID?superParentUUID:@":NULL"];
                [param addObject:parentCommentUUID?parentCommentUUID:@":NULL"];
                [param addObject:postUUID?postUUID:@":NULL"];
                [param addObject:reviewStatus?reviewStatus:@(0)];
                [param addObject:toAnonymousName?toAnonymousName:@":NULL"];
                [param addObject:toAnonymousPhoto?toAnonymousPhoto:@":NULL"];
                [param addObject:toHost?toHost:@":NULL"];
                [param addObject:toUser?toUser:@":NULL"];
                [param addObject:toisAnonymous?toisAnonymous:@(0)];
                [param addObject:updateTime?updateTime:@(0)];
                [param addObject:atList?atList:@":NULL"];
                
                [deleteParam addObject:ChildParCommentUUID];
                [deleteParam addObject:ChildParCommentUUID];
                [deleteParamList addObject:deleteParam];
                [paramList addObject:param];
            }
//            NSLog(@"newChildDic : %@", newChildDic);
        }
        [database executeBulkInsert:deleteSql withParameters:deleteParamList];
        [database executeBulkInsert:sql withParameters:paramList];
    }];
}

- (NSArray *)qimDB_getWorkCommentsWithMomentId:(NSString *)momentId WithLimit:(int)limit WithOffset:(int)offset {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, parentCommentUUID, superParentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime, atList from IM_Work_CommentV2 where postUUID='%@' and isDelete=0 and parentCommentUUID='' and superParentUUID='' order by createTime desc limit %d offset %d;", momentId, limit, offset];
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
            NSString *superParentUUID = [reader objectForColumnIndex:13];
            NSString *postUUID = [reader objectForColumnIndex:14];
            NSNumber *reviewStatus = [reader objectForColumnIndex:15];
            NSString *toAnonymousName = [reader objectForColumnIndex:16];
            NSString *toAnonymousPhoto = [reader objectForColumnIndex:17];
            NSString *toHost = [reader objectForColumnIndex:18];
            NSString *toUser = [reader objectForColumnIndex:19];
            NSNumber *toisAnonymous = [reader objectForColumnIndex:20];
            NSNumber *updateTime = [reader objectForColumnIndex:21];
            NSString *atList = [reader objectForColumnIndex:22];
            
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
            [IMDataManager safeSaveForDic:msgDic setObject:superParentUUID forKey:@"superParentUUID"];
            [IMDataManager safeSaveForDic:msgDic setObject:postUUID forKey:@"postUUID"];
            
            [IMDataManager safeSaveForDic:msgDic setObject:reviewStatus forKey:@"reviewStatus"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousName forKey:@"toAnonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousPhoto forKey:@"toAnonymousPhoto"];
            [IMDataManager safeSaveForDic:msgDic setObject:toHost forKey:@"toHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:toUser forKey:@"toUser"];
            [IMDataManager safeSaveForDic:msgDic setObject:toisAnonymous forKey:@"toisAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:updateTime forKey:@"updateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:atList forKey:@"atList"];


            [result addObject:msgDic];
        }
        
    }];
    return [self qimDB_getWorkChildCommentsWithParentComments:result];
}

- (NSArray *)qimDB_getWorkChildCommentsWithParentComments:(NSArray *)comments {
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < comments.count; i++) {
        NSMutableDictionary *parentCommentDic = [comments objectAtIndex:i];
        NSString *commentUUID = [parentCommentDic objectForKey:@"commentUUID"];
        __block NSMutableArray *childComments = nil;
        [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
            NSString *sql = [NSString stringWithFormat:@"select anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, parentCommentUUID, superParentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime, atList from IM_Work_CommentV2 where isDelete=0 and (parentCommentUUID=:'%@' Or superParentUUID='%@') order by createTime desc;", commentUUID, commentUUID];
            DataReader *reader = [database executeReader:sql withParameters:nil];
            if (childComments == nil) {
                childComments = [[NSMutableArray alloc] init];
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
                NSString *superParentUUID = [reader objectForColumnIndex:13];
                NSString *postUUID = [reader objectForColumnIndex:14];
                NSNumber *reviewStatus = [reader objectForColumnIndex:15];
                NSString *toAnonymousName = [reader objectForColumnIndex:16];
                NSString *toAnonymousPhoto = [reader objectForColumnIndex:17];
                NSString *toHost = [reader objectForColumnIndex:18];
                NSString *toUser = [reader objectForColumnIndex:19];
                NSNumber *toisAnonymous = [reader objectForColumnIndex:20];
                NSNumber *updateTime = [reader objectForColumnIndex:21];
                NSString *atList = [reader objectForColumnIndex:22];
                
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
                [IMDataManager safeSaveForDic:msgDic setObject:superParentUUID forKey:@"superParentUUID"];
                [IMDataManager safeSaveForDic:msgDic setObject:postUUID forKey:@"postUUID"];
                
                [IMDataManager safeSaveForDic:msgDic setObject:reviewStatus forKey:@"reviewStatus"];
                [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousName forKey:@"toAnonymousName"];
                [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousPhoto forKey:@"toAnonymousPhoto"];
                [IMDataManager safeSaveForDic:msgDic setObject:toHost forKey:@"toHost"];
                [IMDataManager safeSaveForDic:msgDic setObject:toUser forKey:@"toUser"];
                [IMDataManager safeSaveForDic:msgDic setObject:toisAnonymous forKey:@"toisAnonymous"];
                [IMDataManager safeSaveForDic:msgDic setObject:updateTime forKey:@"updateTime"];
                [IMDataManager safeSaveForDic:msgDic setObject:atList forKey:@"atList"];
                
                
                [childComments addObject:msgDic];
            }
            
        }];
        [IMDataManager safeSaveForDic:parentCommentDic setObject:childComments forKey:@"newChild"];
        [result addObject:parentCommentDic];
    }
    return result;
}

- (NSArray *)qimDB_getWorkChildCommentsWithParentCommentUUID:(NSString *)commentUUID {
    __block NSMutableArray *childComments = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select anonymousName, anonymousPhoto, commentUUID, content, createTime, fromHost, fromUser, id, isAnonymous, isDelete, isLike, likeNum, parentCommentUUID, superParentUUID, postUUID, reviewStatus, toAnonymousName, toAnonymousPhoto, toHost, toUser, toisAnonymous, updateTime, atList from IM_Work_CommentV2 where isDelete=0 and (parentCommentUUID='%@' Or superParentUUID='%@') order by createTime desc;", commentUUID, commentUUID];
        NSLog(@"child sql : %@", sql);
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (childComments == nil) {
            childComments = [[NSMutableArray alloc] init];
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
            NSString *superParentUUID = [reader objectForColumnIndex:13];
            NSString *postUUID = [reader objectForColumnIndex:14];
            NSNumber *reviewStatus = [reader objectForColumnIndex:15];
            NSString *toAnonymousName = [reader objectForColumnIndex:16];
            NSString *toAnonymousPhoto = [reader objectForColumnIndex:17];
            NSString *toHost = [reader objectForColumnIndex:18];
            NSString *toUser = [reader objectForColumnIndex:19];
            NSNumber *toisAnonymous = [reader objectForColumnIndex:20];
            NSNumber *updateTime = [reader objectForColumnIndex:21];
            NSString *atList = [reader objectForColumnIndex:22];
            
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
            [IMDataManager safeSaveForDic:msgDic setObject:superParentUUID forKey:@"superParentUUID"];
            [IMDataManager safeSaveForDic:msgDic setObject:postUUID forKey:@"postUUID"];
            
            [IMDataManager safeSaveForDic:msgDic setObject:reviewStatus forKey:@"reviewStatus"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousName forKey:@"toAnonymousName"];
            [IMDataManager safeSaveForDic:msgDic setObject:toAnonymousPhoto forKey:@"toAnonymousPhoto"];
            [IMDataManager safeSaveForDic:msgDic setObject:toHost forKey:@"toHost"];
            [IMDataManager safeSaveForDic:msgDic setObject:toUser forKey:@"toUser"];
            [IMDataManager safeSaveForDic:msgDic setObject:toisAnonymous forKey:@"toisAnonymous"];
            [IMDataManager safeSaveForDic:msgDic setObject:updateTime forKey:@"updateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:atList forKey:@"atList"];
            
            
            [childComments addObject:msgDic];
        }
        
    }];
    return childComments;
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
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"insert or IGNORE into IM_Work_NoticeMessage(userFrom, readState, postUUID, fromIsAnonymous, toIsAnonymous, eventType, fromAnonymousPhoto, userTo, uuid, content, userToHost, createTime, userFromHost, fromAnonymousName, toAnonymousName, toAnonymousPhoto) values(:userFrom, :readState, :postUUID, :fromIsAnonymous, :toIsAnonymous, :eventType, :fromAnonymousPhoto, :userTo, :uuid, :content, :userToHost, :createTime, :userFromHost, :fromAnonymousName, :toAnonymousName, :toAnonymousPhoto);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *noticeMsgDic in notices) {
            
            //如果接口未下发userFrom 则下发fromUser
            //todo 预计未来会修改
            NSString *userFrom= @"";
            if ([noticeMsgDic objectForKey:@"fromUser"]) {
                userFrom = [noticeMsgDic objectForKey:@"fromUser"];
            }
            else{
                userFrom = [noticeMsgDic objectForKey:@"userFrom"];
            }
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
            if (userFromHost.length < 0) {
                userFromHost = [noticeMsgDic objectForKey:@"fromHost"];
            }
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
        BOOL success = [database executeBulkInsert:sql withParameters:paramList];
    }];
}
//获取服务器事件差，来获取剩余未读消息
- (long long)qimDB_getWorkNoticeMessagesMaxTime {
    __block long long time = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select max(createTime) from IM_Work_NoticeMessage"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            time = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
    }];
    return time;
}

- (NSInteger)qimDB_getWorkNoticeMessagesCountWithEventType:(NSArray *)eventTyps {
    __block NSInteger count = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from IM_Work_NoticeMessage Where readState=0 and eventType in %@;", eventTyps];
        NSLog(@"qimDB_getWorkNoticeMessagesCountWithEventType sql : %@", sql);
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    return count;
}

- (NSArray *)qimDB_getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql  = [NSString stringWithFormat:@"select userFrom, readState, postUUID, fromIsAnonymous, toIsAnonymous, eventType, fromAnonymousPhoto, userTo, uuid, content, userToHost, createTime, userFromHost, fromAnonymousName, toAnonymousName, toAnonymousPhoto from IM_Work_NoticeMessage where eventType in %@ and  readState = %ld order by createTime desc limit %d offset %d;", eventTypes, readState, limit, offset];
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
        }
        
    }];
    //    QIMVerboseLog(@"sql取消息耗时。: %llf", [[QIMWatchDog sharedInstance] escapedTime]);
    return result;
}

- (NSArray *)qimDB_getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes {
    __block NSMutableArray *result = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql  = [NSString stringWithFormat:@"select userFrom, readState, postUUID, fromIsAnonymous, toIsAnonymous, eventType, fromAnonymousPhoto, userTo, uuid, content, userToHost, createTime, userFromHost, fromAnonymousName, toAnonymousName, toAnonymousPhoto from IM_Work_NoticeMessage where eventType in %@ order by createTime desc limit %d offset %d;", eventTypes, limit, offset];
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
        }
        
    }];
    //    QIMVerboseLog(@"sql取消息耗时。: %llf", [[QIMWatchDog sharedInstance] escapedTime]);
    return result;
}

//我的驼圈儿根据uuid 数组删除deleteListArr
- (void)qimDB_deleteWorkNoticeMessageWithUUid:(NSArray *)deleteListArr{
    if (deleteListArr.count <= 0) {
        return ;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSql = @"delete from IM_Work_NoticeMessage where uuid=:uuid";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *momentDic in deleteListArr) {
            NSString *rId = [momentDic objectForKey:@"id"];
            NSString *uuid = [momentDic objectForKey:@"uuid"];
            NSNumber *isDelete = [momentDic objectForKey:@"isDelete"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:uuid];
            [paramList addObject:param];
        }
        BOOL result = [database executeBulkInsert:deleteSql withParameters:paramList];
    }];
}

- (void)qimDB_deleteWorkNoticeMessageWithEventTypes:(NSArray *)eventTypes {
    if (eventTypes.count <= 0) {
        return ;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *deleteSql = [NSString stringWithFormat:@"delete from IM_Work_NoticeMessage where eventType in %@", eventTypes];
        BOOL result = [database executeBulkInsert:deleteSql withParameters:nil];
    }];
}

- (void)qimDB_updateWorkNoticeMessageReadStateWithTime:(long long)time {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
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

@end
