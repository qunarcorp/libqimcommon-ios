//
//  IMDataManager+QIMNote.m
//  QIMCommon
//
//  Created by 李露 on 10/29/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager+QIMNote.h"
#import "QIMDataBase.h"

@implementation IMDataManager (QIMNote)

/*********************** QTNotes Main **********************/

- (BOOL)checkExitsMainItemWithQid:(NSInteger)qid WithCId:(NSInteger)cid {
    __block BOOL existFlag = NO;
    if (cid < 1) {
        cid = [[IMDataManager qimDB_SharedInstance] getMaxQTNoteMainItemCid] + 1;
    }
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select Count(*) From qcloud_main Where q_id = %ld Or c_id = %ld;", qid, cid];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            existFlag = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    return existFlag;
}

- (void)insertQTNotesMainItemWithQId:(NSInteger)qid
                             WithCid:(NSInteger)cid
                           WithQType:(NSInteger)qtype
                          WithQTitle:(NSString *)qtitle
                      WithQIntroduce:(NSString *)qIntroduce
                        WithQContent:(NSString *)qContent
                           WithQTime:(NSInteger)qTime
                          WithQState:(NSInteger)qstate
                   WithQExtendedFlag:(NSInteger)qExtendedFlag {
    
    if (cid < 1) {
        cid = [[IMDataManager qimDB_SharedInstance]getMaxQTNoteMainItemCid] + 1;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert Or Replace into qcloud_main(q_id, c_id, q_type, q_title, q_introduce, q_content, q_time, q_state, q_ExtendedFlag) Values(:q_id, :c_id, :q_type, :q_title, :q_introduce, :q_content, :q_time, :q_state, :q_ExtendedFlag);";
        NSMutableArray *parames = [[NSMutableArray alloc] init];
        [parames addObject:@(qid)];
        [parames addObject:@(cid)];
        [parames addObject:@(qtype)];
        [parames addObject:qtitle ? qtitle : @":NULL"];
        [parames addObject:qIntroduce ? qIntroduce : @":NULL"];
        [parames addObject:qContent ? qContent : @":NULL"];
        [parames addObject:@(qTime)];
        [parames addObject:@(qstate)];
        [parames addObject:@(qExtendedFlag)];
        [database executeNonQuery:sql withParameters:parames];
    }];
}

- (void)updateToMainWithQId:(NSInteger)qid
                    WithCid:(NSInteger)cid
                  WithQType:(NSInteger)qtype
                 WithQTitle:(NSString *)qtitle
              WithQDescInfo:(NSString *)qdescInfo
               WithQContent:(NSString *)qcontent
                  WithQTime:(NSInteger)qtime
                 WithQState:(NSInteger)qstate
          WithQExtendedFlag:(NSInteger)qExtendedFlag {
    if (cid < 1) {
        cid = [[IMDataManager qimDB_SharedInstance]getMaxQTNoteMainItemCid] + 1;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update qcloud_main Set q_id = :q_id, q_title = :q_title, q_introduce = :q_introduce, q_content = :q_content, q_time = :q_time, q_state = :q_state, q_ExtendedFlag = :q_ExtendedFlag Where q_id = :q_id2 OR c_id = :c_id;";
        NSMutableArray *parames = [[NSMutableArray alloc] init];
        [parames addObject:@(qid)];
        [parames addObject:qtitle ? qtitle : @":NULL"];
        [parames addObject:qdescInfo ? qdescInfo : @":NULL"];
        [parames addObject:qcontent ? qcontent : @":NULL"];
        [parames addObject:@(qtime)];
        [parames addObject:@(qstate)];
        [parames addObject:@(qExtendedFlag)];
        [parames addObject:@(qid)];
        [parames addObject:@(cid)];
        [database executeNonQuery:sql withParameters:parames];
    }];
}

- (void)updateToMainItemWithDicts:(NSArray *)mainItemList {
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        //q_ExtendedFlag = 3为远程更新过
        NSString *sql = @"Update qcloud_main Set q_id = :q_id, q_time = :q_time, q_ExtendedFlag = 3 Where c_id = :c_id;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *mainItem in mainItemList) {
            NSInteger cId = [[mainItem objectForKey:@"cid"] integerValue];
            NSInteger qId = [[mainItem objectForKey:@"qid"] integerValue];
            NSInteger version = [[mainItem objectForKey:@"version"] integerValue];
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
            [param addObject:@(qId)];
            [param addObject:@(version)];
            [param addObject:@(cId)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

- (void)deleteToMainWithQid:(NSInteger)qid {
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From qcloud_main Where q_id = :q_id;";
        [database executeNonQuery:sql withParameters:@[@(qid)]];
    }];
}

- (void)deleteToMainWithCid:(NSInteger)cid {
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From qcloud_main Where c_id = :c_id;";
        [database executeNonQuery:sql withParameters:@[@(cid)]];
        sql = @"Delete From qcloud_sub Where c_id = :c_id;";
        [database executeNonQuery:sql withParameters:@[@(cid)]];
    }];
}

- (void)updateToMainItemTimeWithQId:(NSInteger)qid
                          WithQTime:(NSInteger)qTime
                  WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update qcloud_main Set q_time = :q_time Where q_id = :q_id;";
        [database executeNonQuery:sql withParameters:@[@(qTime), @(qid)]];
    }];
}

- (void)updateMainStateWithQid:(NSInteger)qid
                       WithCid:(NSInteger)cid
                    WithQState:(NSInteger)qstate
             WithQExtendedFlag:(NSInteger)qExtendedFlag {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update qcloud_main Set q_id = :q_id, q_state = :q_state, q_ExtendedFlag = :q_ExtendedFlag Where c_id = :c_id;";
        NSMutableArray *parames = [[NSMutableArray alloc] init];
        [parames addObject:@(qid)];
        [parames addObject:@(qstate)];
        [parames addObject:@(qExtendedFlag)];
        [parames addObject:@(cid)];
        [database executeNonQuery:sql withParameters:parames];
    }];
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType {
    NSString *param = [NSString stringWithFormat:@"q_type = %ld", (long)qType];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return result;
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType QString:(NSString *)qString {
    NSString *param = [NSString stringWithFormat:@"q_type = %ld AND q_title LIKE '%%%@%%'", (long)qType, qString];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return result;
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithExceptQState:(NSInteger)qState {
    NSString *param = [NSString stringWithFormat:@"q_type = %ld And q_state != %ld", (long)qType, (long)qState];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return result;
}

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithQState:(NSInteger)qState {
    NSString *param = [NSString stringWithFormat:@"q_type = %ld And q_state = %ld", (long)qType, (long)qState];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return result;
}

- (NSArray *)getQTNoteMainItemWithQType:(NSInteger)qType WithQDescInfo:(NSString *)descInfo {
    NSString *param = [NSString stringWithFormat:@"q_type = %ld And q_introduce = '%@'", (long)qType, descInfo];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return result;
}

- (NSArray *)getQTNotesMainItemWithQExtendFlag:(NSInteger)qExtendFlag {
    NSString *param = [NSString stringWithFormat:@"q_ExtendedFlag = %ld", (long)qExtendFlag];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return result;
}

- (NSArray *)getQTNotesMainItemWithQExtendedFlag:(NSInteger)qExtendedFlag needConvertToString:(BOOL)flag {
    __block NSMutableArray *resultList = nil;
    __block BOOL needConvertToStringFlag = flag;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *param = [NSString stringWithFormat:@"q_ExtendedFlag = %ld", (long)qExtendedFlag];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select *from qcloud_main Where %@ Order By q_time Desc;", param];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSNumber *q_id = [reader objectForColumnIndex:0];
            NSNumber *c_id = [reader objectForColumnIndex:1];
            NSNumber *q_type = [reader objectForColumnIndex:2];
            NSString *q_title = [reader objectForColumnIndex:3];
            NSString *q_introduce = [reader objectForColumnIndex:4];
            NSString *q_content = [reader objectForColumnIndex:5];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            if (needConvertToStringFlag) {
                NSString *strCid = [NSString stringWithFormat:@"%@", c_id];
                [IMDataManager safeSaveForDic:paramDic setObject:strCid forKey:@"cid"];
            } else {
                [IMDataManager safeSaveForDic:paramDic setObject:c_id forKey:@"c_id"];
            }
            [IMDataManager safeSaveForDic:paramDic setObject:q_type forKey:@"type"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_title ? q_title : @"" forKey:@"title"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_introduce ? q_introduce : @"" forKey:@"desc"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_content ? q_content : @"" forKey:@"content"];
            [resultList addObject:paramDic];
        }
        
    }];
    return resultList;
}

- (NSDictionary *)getQTNotesMainItemWithCid:(NSInteger)cid {
    NSString *param = [NSString stringWithFormat:@"c_id = %ld", (long)cid];
    NSArray *result = [self getQTNotesMainItemWithParams:param];
    return [result firstObject];
}

- (NSArray *)getQTNotesMainItemWithParams:(NSString *)param {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select *from qcloud_main Where %@ Order By q_time Desc;", param];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSNumber *q_id = [reader objectForColumnIndex:0];
            NSNumber *c_id = [reader objectForColumnIndex:1];
            NSNumber *q_type = [reader objectForColumnIndex:2];
            NSString *q_title = [reader objectForColumnIndex:3];
            NSString *q_introduce = [reader objectForColumnIndex:4];
            NSString *q_content = [reader objectForColumnIndex:5];
            NSNumber *q_time = [reader objectForColumnIndex:6];
            NSNumber *q_state = [reader objectForColumnIndex:7];
            NSNumber *q_ExtendedFlag = [reader objectForColumnIndex:8];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:q_id forKey:@"q_id"];
            [IMDataManager safeSaveForDic:paramDic setObject:c_id forKey:@"c_id"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_type forKey:@"q_type"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_title forKey:@"q_title"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_introduce forKey:@"q_introduce"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_content forKey:@"q_content"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_time forKey:@"q_time"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_state forKey:@"q_state"];
            [IMDataManager safeSaveForDic:paramDic setObject:q_ExtendedFlag forKey:@"q_ExtendedFlag"];
            [resultList addObject:paramDic];
        }
        
    }];
    return resultList;
}

- (NSInteger)getQTNoteMainItemMaxTimeWithQType:(NSInteger)qType {
    __block NSInteger maxTime = -1;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select MAX(q_time) From qcloud_main Where q_type = %ld;", qType];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            maxTime = ceil([[reader objectForColumnIndex:0] integerValue]);
        }
        [reader close];
    }];
    return maxTime;
}

- (NSInteger)getMaxQTNoteMainItemCid {
    __block NSInteger maxCId = -1;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = @"Select MAX(c_id) From qcloud_main;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            maxCId = ceil([[reader objectForColumnIndex:0] doubleValue]);
        }
        [reader close];
    }];
    return maxCId;
}

/*********************** QTNotes Sub **********************/

- (BOOL)checkExitsSubItemWithQsid:(NSInteger)qsid WithCsid:(NSInteger)csid {
    __block BOOL existFlag = NO;
    if (csid < 1) {
        csid = [[IMDataManager qimDB_SharedInstance]getMaxQTNoteSubItemCSid] + 1;
    }
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select Count(*) From qcloud_sub Where qs_id = %ld Or cs_id = %ld;", qsid, csid];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            existFlag = [[reader objectForColumnIndex:0] integerValue];
        }
        [reader close];
    }];
    return existFlag;
}

- (void)insertQTNotesSubItemWithCId:(NSInteger)cid
                           WithQSId:(NSInteger)qsid
                           WithCSId:(NSInteger)csid
                         WithQSType:(NSInteger)qstype
                        WithQSTitle:(NSString *)qstitle
                    WithQSIntroduce:(NSString *)qsIntroduce
                      WithQSContent:(NSString *)qsContent
                         WithQSTime:(NSInteger)qsTime
                         WithQState:(NSInteger)qSstate
                WithQS_ExtendedFlag:(NSInteger)qs_ExtendedFlag {
    if (csid < 1) {
        csid = [[IMDataManager qimDB_SharedInstance] getMaxQTNoteSubItemCSid] + 1;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Insert Or Replace into qcloud_sub(c_id, qs_id, cs_id, qs_type, qs_title, qs_introduce, qs_content, qs_time, qs_state, qs_ExtendedFlag) Values(:c_id, :qs_id, :cs_id, :qs_type, :qs_title, :qs_introduce, :qs_content, :qs_time, :qs_state, :qs_ExtendedFlag);";
        NSMutableArray *parames = [NSMutableArray arrayWithCapacity:3];
        [parames addObject:@(cid)];
        [parames addObject:@(qsid)];
        [parames addObject:@(csid)];
        [parames addObject:@(qstype)];
        [parames addObject:qstitle ? qstitle : @":NULL"];
        [parames addObject:qsIntroduce ? qsIntroduce : @":NULL"];
        [parames addObject:qsContent ? qsContent : @":NULL"];
        [parames addObject:@(qsTime)];
        [parames addObject:@(qSstate)];
        [parames addObject:@(qs_ExtendedFlag)];
        [database executeNonQuery:sql withParameters:parames];
    }];
}

- (void)updateToSubWithCid:(NSInteger)cid
                  WithQSid:(NSInteger)qsid
                  WithCSid:(NSInteger)csid
               WithQSTitle:(NSString *)qSTitle
            WithQSDescInfo:(NSString *)qsDescInfo
             WithQSContent:(NSString *)qsContent
                WithQSTime:(NSInteger)qsTime
               WithQSState:(NSInteger)qsState
       WithQS_ExtendedFlag:(NSInteger)qs_ExtendedFlag {
    if (csid < 1) {
        csid = [[IMDataManager qimDB_SharedInstance] getMaxQTNoteSubItemCSid] + 1;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        
        NSString *sql = @"Update qcloud_sub Set c_id = :c_id, qs_id = :qs_id, qs_title = :qs_title, qs_introduce = :qs_introduce, qs_content = :qs_content, qs_time = :qs_time, qs_state = :qs_state, qs_ExtendedFlag = :qs_ExtendedFlag Where cs_id = :cs_id;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@(cid)];
        [param addObject:@(qsid)];
        [param addObject:qSTitle ? qSTitle : @":NULL"];
        [param addObject:qsDescInfo ? qsDescInfo : @":NULL"];
        [param addObject:qsContent ? qsContent : @":NULL"];
        [param addObject:@(qsTime)];
        [param addObject:@(qsState)];
        [param addObject:@(qs_ExtendedFlag)];
        [param addObject:@(csid)];
        [database executeNonQuery:sql withParameters:param];
    }];
}

- (void)updateToSubItemWithDicts:(NSArray *)subItemList {
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update qcloud_sub Set qs_id = :qs_id, qs_time = :qs_time, qs_ExtendedFlag = 3 Where cs_id = :cs_id;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *subItem in subItemList) {
            NSInteger csId = [[subItem objectForKey:@"csid"] integerValue];
            NSInteger qsId = [[subItem objectForKey:@"qsid"] integerValue];
            NSInteger version = [[subItem objectForKey:@"version"] integerValue];
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
            [param addObject:@(qsId)];
            [param addObject:@(version)];
            [param addObject:@(csId)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

- (void)deleteToSubWithCId:(NSInteger)cid {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From qcloud_sub Where c_id = :c_id;";
        [database executeNonQuery:sql withParameters:@[@(cid)]];
    }];
}

- (void)deleteToSubWithCSId:(NSInteger)Csid {
    
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Delete From qcloud_sub Where cs_id = :cs_id;";
        [database executeNonQuery:sql withParameters:@[@(Csid)]];
    }];
}

- (void)updateSubStateWithCSId:(NSInteger)Csid
                   WithQSState:(NSInteger)qsState
            WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update qcloud_sub Set qs_state = :qs_state, qs_ExtendedFlag = :qs_ExtendedFlag Where cs_id = :cs_id;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@(qsState)];
        [param addObject:@(qsExtendedFlag)];
        [param addObject:@(Csid)];
        [database executeNonQuery:sql withParameters:param];
    }];
}

- (void)updateToSubItemTimeWithCSId:(NSInteger)csid
                         WithQSTime:(NSInteger)qsTime
                 WithQsExtendedFlag:(NSInteger)qsExtendedFlag {
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = @"Update qcloud_sub Set qs_time = :qs_time, qs_ExtendedFlag = :qs_ExtendedFlag Where cs_id = :cs_id;";
        [database executeNonQuery:sql withParameters:@[@(qsTime), @(qsExtendedFlag), @(csid)]];
    }];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag {
    return [self getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:qsExtendedFlag needConvertToString:NO];
}

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag needConvertToString:(BOOL)flag {
    __block NSMutableArray *resultList = nil;
    __block BOOL needConvertToStringFlag = flag;
    __block NSString *Qid = qid;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *param = [NSString stringWithFormat:@"qs_ExtendedFlag = %ld", (long)qsExtendedFlag];
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select *from qcloud_sub Where %@ Order By qs_time Desc;", param];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSNumber *c_id = [reader objectForColumnIndex:0];
            NSString *qs_id = [reader objectForColumnIndex:1];
            NSString *cs_id = [reader objectForColumnIndex:2];
            NSString *qs_type = [reader objectForColumnIndex:3];
            NSString *qs_title = [reader objectForColumnIndex:4];
            NSString *qs_introduce = [reader objectForColumnIndex:5];
            NSString *qs_content = [reader objectForColumnIndex:6];
            NSNumber *qs_time = [reader objectForColumnIndex:7];
            NSNumber *qs_state = [reader objectForColumnIndex:8];
            NSNumber *qs_ExtendedFlag = [reader objectForColumnIndex:9];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            if (needConvertToStringFlag) {
                NSString *strCsid = [NSString stringWithFormat:@"%@", cs_id];
                [IMDataManager safeSaveForDic:paramDic setObject:strCsid forKey:@"csid"];
            } else {
                [IMDataManager safeSaveForDic:paramDic setObject:cs_id forKey:@"cs_id"];
            }
            [IMDataManager safeSaveForDic:paramDic setObject:qs_id forKey:@"qsid"];
            [IMDataManager safeSaveForDic:paramDic setObject:Qid forKey:@"qid"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_type forKey:@"type"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_title ? qs_title : @"" forKey:@"title"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_introduce ? qs_introduce : @"" forKey:@"desc"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_content ? qs_content : @"" forKey:@"content"];
            [resultList addObject:paramDic];
        }
        
    }];
    return resultList;
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid QSExtendedFlag:(NSInteger)qsExtendedFlag {
    NSString *param = [NSString stringWithFormat:@"c_id = %ld AND qs_ExtendedFlag = %ld", (long)cid, (long)qsExtendedFlag];
    NSArray *result = [self getQTNotesSubItemWithParams:param];
    return result;
}

- (NSArray *)getQTNotesSubItemWithQSState:(NSInteger)qsState {
    NSString *parma = [NSString stringWithFormat:@" qs_state = %ld", (long)qsState];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return result;
}

- (NSArray *)getQTNotesSubItemWithExpectQSState:(NSInteger)qsState {
    NSString *parma = [NSString stringWithFormat:@"qs_state != %ld", (long)qsState];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return result;
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSState:(NSInteger)qsState {
    NSString *parma = [NSString stringWithFormat:@"c_id = %ld AND qs_state = %ld", (long)cid, (long)qsState];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return result;
}

- (NSDictionary *)getQTNotesSubItemWithCid:(NSInteger)cid WithUserId:(NSString *)userId {
    NSString *parma = [NSString stringWithFormat:@"c_id = %ld AND qs_title = '%@'", (long)cid, userId];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return [result firstObject];
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithExpectQSState:(NSInteger)qsState {
    NSString *parma = [NSString stringWithFormat:@"c_id = %ld AND qs_state != %ld", (long)cid, (long)qsState];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return result;
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithQSState:(NSInteger)qsState {
    NSString *parma = [NSString stringWithFormat:@"c_id = %ld AND qs_type = %ld AND qs_state = %ld", (long)cid, (long)qsType, (long)qsState];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return result;
}

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithExpectQSState:(NSInteger)qsState {
    NSString *parma = [NSString stringWithFormat:@"c_id = %ld AND qs_type = %ld AND qs_state != %ld", (long)cid, (long)qsType, (long)qsState];
    NSArray *result = [self getQTNotesSubItemWithParams:parma];
    return result;
}

- (NSArray *)getQTNotesSubItemWithParams:(NSString *)param {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select *from qcloud_sub Where %@ Order By qs_time Desc;", param];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSNumber *c_id = [reader objectForColumnIndex:0];
            NSString *qs_id = [reader objectForColumnIndex:1];
            NSString *cs_id = [reader objectForColumnIndex:2];
            NSString *qs_type = [reader objectForColumnIndex:3];
            NSString *qs_title = [reader objectForColumnIndex:4];
            NSString *qs_introduce = [reader objectForColumnIndex:5];
            NSString *qs_content = [reader objectForColumnIndex:6];
            NSNumber *qs_time = [reader objectForColumnIndex:7];
            NSNumber *qs_state = [reader objectForColumnIndex:8];
            NSNumber *qs_ExtendedFlag = [reader objectForColumnIndex:9];
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:c_id forKey:@"c_id"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_id forKey:@"qs_id"];
            [IMDataManager safeSaveForDic:paramDic setObject:cs_id forKey:@"cs_id"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_type forKey:@"qs_type"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_title forKey:@"qs_title"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_introduce forKey:@"qs_introduce"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_content forKey:@"qs_content"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_time forKey:@"qs_time"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_state forKey:@"qs_state"];
            [IMDataManager safeSaveForDic:paramDic setObject:qs_ExtendedFlag forKey:@"qs_ExtendedFlag"];
            [resultList addObject:paramDic];
        }
        
    }];
    return resultList;
}

- (NSInteger)getQTNoteSubItemMaxTimeWithCid:(NSInteger)cid
                                 WithQSType:(NSInteger)qsType {
    __block NSInteger maxTime = -1;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select MAX(qs_time) From qcloud_sub Where c_id = %ld AND qs_type = %ld;", cid, qsType];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            maxTime = ceil([[reader objectForColumnIndex:0] integerValue]);
        }
        [reader close];
    }];
    return maxTime;
}
- (NSDictionary *)getQTNoteSubItemWithParmDict:(NSDictionary *)paramDict {
    NSString *parmaSql = [NSString stringWithFormat:@""];
    for (NSString *key in paramDict.allKeys) {
        NSString *paramStr = [NSString stringWithFormat:@"%@ = %@", key, [paramDict objectForKey:key]];
        parmaSql = [parmaSql stringByAppendingString:paramStr];
        if (paramDict.allKeys.count > 1) {
            parmaSql = [parmaSql stringByAppendingString:@" AND "];
        }
    }
    NSArray *result = [self getQTNotesSubItemWithParams:parmaSql];
    if (result.count == 1) {
        return [result lastObject];
    }
    return nil;
}

- (NSInteger)getMaxQTNoteSubItemCSid {
    __block NSInteger maxCSId = -1;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        
        NSString *sql = @"Select MAX(cs_id) From qcloud_sub;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            maxCSId = ceil([[reader objectForColumnIndex:0] integerValue]);
        }
        [reader close];
    }];
    return maxCSId;
}

@end
