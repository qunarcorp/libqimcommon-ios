
//
//  IMDataManager.m
//  qunarChatIphone
//
//  Created by ping.xue on 14-3-19.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "IMDataManager.h"
#import "Database.h"
#import "Message.pb.h"
#import "QIMDBLogger.h"
#import "QIMWatchDog.h"
#import "QIMPublicRedefineHeader.h"

static IMDataManager *__global_data_manager = nil;
@interface IMDataManager()
@end

@implementation IMDataManager{
    NSString *_dbPath;
    NSString *_domain;
    NSDateFormatter *_timeSmtapFormatter;
}

+ (IMDataManager *) sharedInstance {
    return __global_data_manager;
}

- (void) setdbPath:(NSString *) dbPath {
    [_dbPath release];
    _dbPath = [dbPath retain];
}

+(IMDataManager *) sharedInstanceWihtDBPath:(NSString *)dbPath{
    
    if (__global_data_manager) {
        __global_data_manager = [[IMDataManager alloc] initWithDBPath:dbPath];
    } else {
        __global_data_manager = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            __global_data_manager = [[IMDataManager alloc] initWithDBPath:dbPath];
            [__global_data_manager setdbPath:dbPath];
        });
        if (!__global_data_manager) {
            __global_data_manager = [[IMDataManager alloc] initWithDBPath:dbPath];
            [__global_data_manager setdbPath:dbPath];
        }
    }
    return __global_data_manager;
}

- (void)setDomain:(NSString*)domain{
    _domain = domain;
}

- (NSString *) OriginalUUID {
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    NSString *result = [[NSString alloc] initWithString:(__bridge NSString*)UUIDString];
    if (UUID)
    CFRelease(UUID);
    if (UUIDString)
    CFRelease(UUIDString);
    return [result autorelease];
}

- (NSString *)UUID{
    return [[self OriginalUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}


- (id)initWithDBPath:(NSString *)dbPath{
    self = [super init];
    if (self) {
        
        _dbPath = [dbPath copy];
        
        _timeSmtapFormatter = [[NSDateFormatter alloc] init];
        [_timeSmtapFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        QIMVerboseLog(@"DB Path %@", _dbPath);
        BOOL notCheckCreateDataBase = [[NSFileManager defaultManager] fileExistsAtPath:_dbPath] == NO;
        BOOL isSuccess = [DatabaseManager OpenByFullPath:_dbPath];
        if (isSuccess == NO) {
            // 防止数据库文件无效 But 有一种数据库文件能打开 缺不是有效文件 不知怎么解
            [[NSFileManager defaultManager] removeItemAtPath:_dbPath error:nil];
            [DatabaseManager OpenByFullPath:_dbPath];
        }
        NSArray *paths = [_dbPath pathComponents];
        NSString *dbValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"dbVersion"];
        NSString *currentValue = [NSString stringWithFormat:@"%@_%lld",[paths objectAtIndex:paths.count-2] , [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] longLongValue]];
        if (notCheckCreateDataBase || [currentValue isEqualToString:dbValue] == NO) {
            __block BOOL result = NO;
            [[self dbInstance] syncUsingTransaction:^(Database *database) {
                result = [self createDb:database];
            }];
            if (result) {
                QIMVerboseLog(@"创建DB文件成功");
                [[NSUserDefaults standardUserDefaults] setObject:currentValue forKey:@"dbVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                QIMVerboseLog(@"创建DB文件失败");
            }
        } else {
            QIMVerboseLog(@"notCheckCreateDataBase : %d, [currentValue isEqualToString:dbValue] : %d", notCheckCreateDataBase, [currentValue isEqualToString:dbValue]);
        }
        
//        [self initSQLiteLog];
        [self updateMsgTimeToMillSecond];
        
    }
    return self;
}

- (void)initSQLiteLog {
    QIMDBLogger *sqliteLogger = [[QIMDBLogger alloc] initWithLogDirectory:[self sqliteLogFilesDirectory] WithDBOperator:[self dbInstance]];
    sqliteLogger.saveThreshold     = 500;
    sqliteLogger.saveInterval      = 60;               // 60 seconds
    sqliteLogger.maxAge            = 60 * 60 * 24 * 7; //  7 days
    sqliteLogger.deleteInterval    = 60 * 5;           //  5 minutes
    sqliteLogger.deleteOnEverySave = NO;
    
    [DDLog addLogger:sqliteLogger];
}

- (NSString *)sqliteLogFilesDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    
    return [basePath stringByAppendingPathComponent:@"SQLiteLogger"];
}

- (DatabaseOperator *) dbInstance {
    return [DatabaseManager GetInstance:_dbPath];
}

+ (void)safeSaveForDic:(NSMutableDictionary *)dic setObject:(id)value forKey:(id)key{
    if (dic && value && key) {
        [dic setObject:value forKey:key];
    }
}

- (BOOL)createDb:(Database *)database {
    BOOL result = NO;
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_User(\
              UserId                TEXT,\
              XmppId                TEXT PRIMARY KEY,\
              Name                  TEXT,\
              DescInfo              TEXT,\
              HeaderSrc             TEXT,\
              SearchIndex           TEXT,\
              UserInfo              BLOB,\
              LastUpdateTime        INTEGER,\
              IncrementVersion      INTEGER,\
              ExtendedFlag          BLOB\
              );"
                        withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_USER_USERID ON \
                  IM_User(UserId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_USER_XMPPID ON \
                  IM_User(XmppId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_USER_NAME ON \
                  IM_User(Name);"
                            withParameters:nil];
        if ([database checkExistsOnTable:@"IM_User" withColumn:@"IncrementVersion"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_User ADD IncrementVersion INTEGER;" withParameters:nil];
        }
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Group(\
              GroupId               TEXT PRIMARY KEY,\
              Name                  TEXT,\
              Introduce             TEXT,\
              HeaderSrc             TEXT,\
              Topic                 TEXT,\
              LastUpdateTime        INTEGER,\
              MsgState              INTEGER,\
              ExtendedFlag          BLOB\
              );"
                        withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_GROUP_GROUPID ON \
                  IM_Group(GroupId);"
                            withParameters:nil];
        if ([database checkExistsOnTable:@"IM_Group" withColumn:@"PushState"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_Group ADD PushState INTEGER;" withParameters:nil];
        }
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Group_Member(\
              MemberId              TEXT PRIMARY KEY,\
              GroupId               TEXT,\
              MemberJid             TEXT,\
              Name                  TEXT,\
              Affiliation           TEXT,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );"
                        withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_GROUP_MEMBER_MEMBERID ON \
                  IM_Group_Member(MemberId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_GROUP_MEMBER_GROUPID ON \
                  IM_Group_Member(GroupId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE unique index IF NOT EXISTS IX_IM_GROUP_MEMBER_GROUPID_JID_UINDEX ON \
                  IM_Group_Member(GroupId,MemberJid);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_SessionList(\
              XmppId                TEXT,\
              RealJid               TEXT,\
              UserId                TEXT,\
              LastMessageId         TEXT,\
              LastUpdateTime        INTEGER,\
              ChatType              INTEGER,\
              ExtendedFlag          BLOB,\
              primary key (XmppId,RealJid));" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_SESSION_MESSAGEID ON \
                  IM_SessionList(LastMessageId);"
                            withParameters:nil];
        
        if ([database checkExistsOnTable:@"IM_SessionList" withColumn:@"RealJid"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_SessionList ADD RealJid TEXT;" withParameters:nil];
            // 修改主键
            // BEGIN TRANSACTION;
            //            CREATE TEMPORARY TABLE t1_backup(a,b);
            //            INSERT INTO t1_backup SELECT a,b FROM t1;
            //            DROP TABLE t1;
            //            CREATE TABLE t1(a,b);
            //            INSERT INTO t1 SELECT a,b FROM t1_backup;
            //            DROP TABLE t1_backup;
            //            COMMIT;
            [database executeNonQuery:@"CREATE TEMPORARY TABLE t1_backup(\
             XmppId                TEXT,\
             RealJid               TEXT,\
             UserId                TEXT,\
             LastMessageId         TEXT,\
             LastUpdateTime        INTEGER,\
             ChatType              INTEGER,\
             ExtendedFlag          BLOB,\
             primary key (XmppId,RealJid));" withParameters:nil];
            [database executeNonQuery:@"INSERT INTO t1_backup SELECT XmppId,XmppId,UserId,LastMessageId,LastUpdateTime,ChatType,ExtendedFlag FROM IM_SessionList;" withParameters:nil];
            [database executeNonQuery:@"DROP TABLE IM_SessionList;" withParameters:nil];
            [database executeNonQuery:@"CREATE TABLE IM_SessionList(\
             XmppId                TEXT,\
             RealJid               TEXT,\
             UserId                TEXT,\
             LastMessageId         TEXT,\
             LastUpdateTime        INTEGER,\
             ChatType              INTEGER,\
             ExtendedFlag          BLOB,\
             primary key (XmppId,RealJid));" withParameters:nil];
            [database executeNonQuery:@"INSERT INTO IM_SessionList SELECT * FROM t1_backup;" withParameters:nil];
            [database executeNonQuery:@"DROP TABLE t1_backup;" withParameters:nil];
            result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_SESSION_MESSAGEID ON \
                      IM_SessionList(LastMessageId);"
                                withParameters:nil];
        }
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Message(\
              MsgId                 TEXT PRIMARY KEY,\
              XmppId                TEXT,\
              Platform              INTEGER,\
              'From'                TEXT,\
              'To'                  TEXT,\
              Content               TEXT,\
              Type                  INTEGER,\
              State                 INTEGER,\
              Direction             INTEGER,\
              ContentResolve        TEXT,\
              ReadedTag             INTEGER DEFAULT 0,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );" withParameters:nil];
    if (result) {
        ///这里做update操作： DROP索引
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_XMPPID;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_FROM;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_TO;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_STATE;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_STATE_DIRECTION;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_XMPPID_LastUpdateTime;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_REALJID;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_REALJID_XMPPID_LastUpdateTime;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_XMPPID;" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_MODIFYSTATE" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_IM_MESSAGE_XMPPID_LastUpdateTime_ReadedTag_State" withParameters:nil];
        result = [database executeNonQuery:@"DROP INDEX IF EXISTS IX_MESSAGE_LASTUPDATEIME_XMPPID" withParameters:nil];
        
        if ([database checkExistsOnTable:@"IM_Message" withColumn:@"MessageRaw"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_Message ADD MessageRaw TEXT;" withParameters:nil];
        }
        
        if ([database checkExistsOnTable:@"IM_Message" withColumn:@"RealJid"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_Message ADD RealJid TEXT;" withParameters:nil];
        }
        
        if ([database checkExistsOnTable:@"IM_Message" withColumn:@"ChatType"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_Message ADD ChatType INTEGER;" withParameters:nil];
        }
        
        if ([database checkExistsOnTable:@"IM_Message" withColumn:@"ExtendInfo"] == NO) {
            [database executeNonQuery:@"ALTER TABLE IM_Message ADD ExtendInfo TEXT;" withParameters:nil];
        }
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_MESSAGE_XMPPID_LastUpdateTime ON \
                  IM_Message(XmppId, LastUpdateTime);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_MESSAGE_ChatType_State ON \
                  IM_Message(ChatType, State);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Recent_Contacts(\
              XmppId                TEXT PRIMARY KEY,\
              Type                  INTEGER,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );"
                        withParameters:nil];
    
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Public_Number(\
              XmppId                TEXT PRIMARY KEY,\
              PublicNumberId        TEXT,\
              PublicNumberType      INTEGER,\
              Name                  TEXT,\
              DescInfo              TEXT,\
              HeaderSrc             TEXT,\
              SearchIndex           TEXT,\
              PublicNumberInfo      BLOB,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );" withParameters:nil];
    if (result) {
        if ([database checkExistsOnTable:@"IM_Public_Number" withColumn:@"PublicNumberId"] == NO) {
            [database executeNonQuery:@"Delete From IM_Public_Number;" withParameters:nil];
            [database executeNonQuery:@"ALTER TABLE IM_Public_Number ADD PublicNumberID TEXT;" withParameters:nil];
        }
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_PUBLIC_NUMBER_PNID ON \
                  IM_Public_Number(PublicNumberId);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Public_Number_Message(\
              MsgId                 TEXT PRIMARY KEY,\
              XmppId                TEXT,\
              'From'                TEXT,\
              'To'                  TEXT,\
              Content               TEXT,\
              Type                  INTEGER,\
              State                 INTEGER,\
              Direction             INTEGER,\
              ReadedTag             INTEGER DEFAULT 0,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_PUBLIC_NUMBER_MESSAGE_XMPPID ON \
                  IM_Public_Number_Message(XmppId);"
                            withParameters:nil];
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_PUBLIC_NUMBER_MESSAGE_FROM ON \
                  IM_Public_Number_Message('From');"
                            withParameters:nil];
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_PUBLIC_NUMBER_MESSAGE_TO ON \
                  IM_Public_Number_Message('To');"
                            withParameters:nil];
    }
    
    //    IM_Collection_User 已绑定的账号
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Collection_User(\
              XmppId                TEXT PRIMARY KEY,\
              BIND                  BLOB\
              );"
                        withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_XMPPID ON \
                  IM_Collection_User(XmppId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_BIND ON \
                  IM_Collection_User(BIND);"
                            withParameters:nil];
    }
    
    //    IM_Collection_User_Card 代收用户名片
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Collection_User_Card(\
              UserId                TEXT,\
              XmppId                TEXT PRIMARY KEY,\
              Name                  TEXT,\
              DescInfo              TEXT,\
              HeaderSrc             TEXT,\
              SearchIndex           TEXT,\
              UserInfo              BLOB,\
              LastUpdateTime        INTEGER,\
              IncrementVersion      INTEGER,\
              ExtendedFlag          BLOB\
              );"
                        withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_USERID ON \
                  IM_Collection_User_Card(UserId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_NAME ON \
                  IM_Collection_User_Card(Name);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_DESCINFO ON \
                  IM_Collection_User_Card(DescInfo);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_SEARCHINDEX ON \
                  IM_Collection_User_Card(SearchIndex);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_USERINFO ON \
                  IM_Collection_User_Card(UserInfo);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_INCREMENTVERSION ON \
                  IM_Collection_User_Card(IncrementVersion);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_USER_CARD_EXTENDEDFLAG ON \
                  IM_Collection_User_Card(ExtendedFlag);"
                            withParameters:nil];
    }
    
    //    IM_Collection_Group_Card 代收群名片
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Collection_Group_Card(\
              GroupId               TEXT PRIMARY KEY,\
              Name                  TEXT,\
              Introduce             TEXT,\
              HeaderSrc             TEXT,\
              Topic                 TEXT,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );"
                        withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_GROUP_CARD_NAME ON \
                  IM_Collection_Group_Card(Name);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_GROUP_CARD_LASTUPDATETIME ON \
                  IM_Collection_Group_Card(LastUpdateTime);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Collection_SessionList(\
              XmppId                TEXT,\
              BindId                TEXT,\
              RealJid               TEXT,\
              UserId                TEXT,\
              LastMessageId         TEXT,\
              LastUpdateTime        INTEGER,\
              ChatType              INTEGER,\
              ExtendedFlag          BLOB,\
              primary key (XmppId,BindId,RealJid));" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_COLLECTION_SESSIONLIST_LASTMESSAGEID ON \
                  IM_Collection_SessionList(LastMessageId);"
                            withParameters:nil];
    }
    
    //    IM_Message_Collection 代收消息附属表
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Message_Collection(\
              MsgId                 TEXT PRIMARY KEY,\
              Originfrom            TEXT,\
              Originto              TEXT,\
              Origintype            TEXT\
              );" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_MESSAGE_COLLECTION_ORIGINFROM ON \
                  IM_Message_Collection(ORIGINFROM);"
                            withParameters:nil];
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_MESSAGE_COLLECTION_ORIGINTO ON \
                  IM_Message_Collection(Originto);"
                            withParameters:nil];
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_MESSAGE_COLLECTION_ORIGINTYPE ON \
                  IM_Message_Collection(Origintype);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Friendster_Message(\
              MsgId                 TEXT PRIMARY KEY,\
              XmppId                TEXT,\
              FromUser              TEXT,\
              ReplyMsgId            TEXT,\
              ReplyUser             TEXT,\
              Content               Text,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );" withParameters:nil];
    if (result) {
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIENDSTER_MESSAGE_XMPPID ON \
                  IM_Friendster_Message(XmppId);"
                            withParameters:nil];
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIENDSTER_MESSAGE_REPLYMSGID ON \
                  IM_Friendster_Message(ReplyMsgId);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Friend_List(\
              UserId                TEXT,\
              XmppId                TEXT PRIMARY KEY,\
              Name                  TEXT,\
              DescInfo              TEXT,\
              HeaderSrc             TEXT,\
              SearchIndex           TEXT,\
              UserInfo              BLOB,\
              LastUpdateTime        INTEGER,\
              IncrementVersion      INTEGER,\
              ExtendedFlag          BLOB\
              );" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIEND_LIST_USERID ON \
                  IM_Friend_List(UserId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIEND_LIST_XMPPID ON \
                  IM_Friend_List(XmppId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIEND_LIST_NAME ON \
                  IM_Friend_List(Name);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery: @"CREATE TABLE IF NOT EXISTS IM_Friend_Notify(\
              UserId                TEXT ,\
              XmppId                TEXT PRIMARY KEY,\
              Name                  TEXT,\
              DescInfo              TEXT,\
              HeaderSrc             TEXT,\
              SearchIndex           TEXT,\
              UserInfo              BLOB,\
              State                 INTEGER,\
              Version               INTEGER,\
              LastUpdateTime        INTEGER,\
              ExtendedFlag          BLOB\
              );" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIEND_NOTIFY_USERID ON \
                  IM_Friend_Notify(UserId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIEND_NOTIFY_XMPPID ON \
                  IM_Friend_Notify(XmppId);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_FRIEND_NOTIFY_NAME ON \
                  IM_Friend_Notify(Name);"
                            withParameters:nil];
    }
    
    //q_id 服务器返值 qc_id 本地生成
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS qcloud_main(\
              q_id                  INTEGER, \
              c_id                  INTEGER PRIMARY KEY, \
              q_type                INTEGER, \
              q_title               TEXT,\
              q_introduce           TEXT,\
              q_content             TEXT,\
              q_time                INTEGER,\
              q_state               INTEGER,\
              q_ExtendedFlag        INTRGER\
              );" withParameters:nil];
    if (result) {
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_MAIN_Q_ID ON \
                  qcloud_main(q_id);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_MAIN_Q_TYPE ON \
                  qcloud_main(q_type);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_MAIN_Q_TIME_TYPE ON \
                  qcloud_main(q_time,q_type);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_MAIN_Q_STATE ON \
                  qcloud_main(q_state);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_MAIN_Q_Flag ON \
                  qcloud_main(q_ExtendedFlag);" withParameters:nil];
    }
    //q_id qs_id 服务器返值 qc_id qcs_id 本地生成
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS qcloud_sub(\
              c_id                  INTEGER,\
              qs_id                 INTEGER, \
              cs_id                 INTEGER PRIMARY KEY, \
              qs_type               INTEGER, \
              qs_title              TEXT,\
              qs_introduce          TEXT,\
              qs_content            TEXT,\
              qs_time               INTEGER,\
              qs_state              INTEGER,\
              qs_ExtendedFlag       INTEGER\
              );" withParameters:nil];
    if (result) {
        
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_SUB_C_ID ON \
                  qcloud_sub(c_id);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_SUB_QS_ID ON \
                  qcloud_sub(qs_id);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_SUB_Q_TYPE ON \
                  qcloud_sub(qs_type);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_SUB_Q_TIME ON \
                  qcloud_sub(qs_time);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_SUB_QS_STATE ON \
                  qcloud_sub(qs_state);"
                            withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS QCLOUD_SUB_QS_ExtendedFlag ON \
                  qcloud_sub(qs_ExtendedFlag);"
                            withParameters:nil];
    }
    
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_User_BackInfo(\
              XmppId                 TEXT PRIMARY KEY, \
              UserWorkInfo           TEXT,\
              LastUpdateTime         INTEGER\
              );" withParameters:nil];
    
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_Client_Config(\
               ConfigKey             TEXT,\
               ConfigSubKey          TEXT,\
               ConfigValue           TEXT,\
               ConfigVersion         INTEGER,\
               DeleteFlag            INTEGER,\
              primary key (ConfigKey,ConfigSubKey));" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_CLIENT_CONFIG_CONFIGKEY ON \
                  IM_Client_Config(ConfigKey);" withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_CLIENT_CONFIG_CONFIGVERSION ON \
                  IM_Client_Config(ConfigVersion);" withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_CLIENT_CONFIG_DELETEFLAG ON \
                  IM_Client_Config(DeleteFlag);" withParameters:nil];
    }
    
    //快捷回复组表
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_QUICK_REPLY_GROUP(\
              sid              LONG,\
              groupname        TEXT,\
              groupseq         LONG,\
              version          LONG DEFAULT 1,\
              primary key      (sid));" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_QUICK_REPLY_GROUP_SID ON \
                  IM_QUICK_REPLY_GROUP(sid);" withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_QUICK_REPLY_GROUP_GROUPSEQ ON \
                  IM_QUICK_REPLY_GROUP(groupseq);" withParameters:nil];
    }
    //快捷回复单条记录表
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_QUICK_REPLY_CONTENT(\
              sid             LONG,\
              gid             LONG,\
              content         TEXT,\
              contentseq      LONG,\
              version         LONG DEFAULT 1,\
              primary key     (gid, sid));" withParameters:nil];
    if (result) {
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_QUICK_REPLY_CONTENT_GID ON \
                  IM_QUICK_REPLY_CONTENT(gid);" withParameters:nil];
        result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IX_IM_QUICK_REPLY_CONTENT_CONTENTSEQ ON \
                  IM_QUICK_REPLY_CONTENT(contentseq);" withParameters:nil];
    }
    
    //行程区域表
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_TRIP_AREA (\
              AreaID TEXT PRIMARY KEY,\
              Enable TEXT,\
              AreaName TEXT,\
              MorningStarts TEXT,\
              EveningEnds TEXT,\
              Description TEXT);" withParameters:nil];
    
    //行程详情表
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_TRIP_INFO (\
              tripId TEXT PRIMARY KEY,\
              tripName TEXT,\
              tripDate TEXT,\
              tripType TEXT,\
              tripIntr TEXT,\
              tripInviter TEXT,\
              beginTime TEXT,\
              endTime TEXT,scheduleTime TEXT,\
              appointment TEXT,\
              tripLocale TEXT,\
              tripLocaleNumber TEXT,\
              tripRoom TEXT,\
              tripRoomNumber TEXT,\
              memberList TEXT,\
              tripRemark TEXT,\
              canceled Text);" withParameters:nil];
    
    //创建log表
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS logs (\
              context integer,\
              level integer,\
              message text,\
              timestamp double);" withParameters:nil];
    
    result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS timestamp ON logs (timestamp);" withParameters:nil];
    
    //创建用户勋章表
    result = [database executeNonQuery:@"CREATE TABLE IF NOT EXISTS IM_User_Medal (\
              XmppId                TEXT,\
              Type                  TEXT,\
              URL                   TEXT,\
              URLDesc               TEXT,\
              LastUpdateTime        INTEGER DEFAULT 0,\
              primary key (XmppId,Type));" withParameters:nil];
    
    result = [database executeNonQuery:@"CREATE INDEX IF NOT EXISTS IM_USER_MEDAL_XMPPID ON IM_User_Medal (XmppId);" withParameters:nil];
    return result;
}

- (NSInteger)parserplatForm:(NSString *)platFormStr {
    NSInteger platForm = 2;
    if ([platFormStr isEqualToString:@"ClientTypeMac"]) {
        platForm = 1;
    } else if ([platFormStr isEqualToString:@"ClientTypeiOS"]) {
        platForm = 2;
    } else if ([platFormStr isEqualToString:@"ClientTypePc"]) {
        platForm = 3;
    } else if ([platFormStr isEqualToString:@"ClientTypeAndroid"]) {
        platForm = 4;
    } else if ([platFormStr isEqualToString:@"ClientTypeLinux"]) {
        platForm = 5;
    } else if ([platFormStr isEqualToString:@"ClientTypeWeb"]) {
        platForm = 6;
    } else {
        platForm = 2;
    }
    return platForm;
}

- (void)updateMsgTimeToMillSecond{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UpdateMsgTimeToMillSecond"] == nil) {
        [[self dbInstance] syncUsingTransaction:^(Database *database) {
            NSString *sql = @"Update IM_Message Set LastUpdateTime = LastUpdateTime * 1000 Where LastUpdateTime < 140000000000;";
            [database executeNonQuery:sql withParameters:nil];
            NSString *sql1 = @"Update IM_Public_Number_Message Set LastUpdateTime = LastUpdateTime * 1000 Where LastUpdateTime < 140000000000;";
            [database executeNonQuery:sql1 withParameters:nil];
        }];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"UpdateMsgTimeToMillSecond"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)clearUserDescInfo{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_User Set DescInfo=:DescInfo;";
        [database executeNonQuery:sql withParameters:@[@":NULL"]];
    }];
}

- (NSString *)getTimeSmtapMsgIdForDate:(NSDate *)date WithUserId:(NSString *)userId{
    if (_timeSmtapFormatter) {
        NSString *dateStr = [_timeSmtapFormatter stringFromDate:date];
        NSString *timeSmtapMsgId = [NSString stringWithFormat:@"Time Smtap %@ For %@",dateStr,userId];
        return timeSmtapMsgId;
    }
    return @"";
}

- (void)bulkUpdateUserSearchIndexs:(NSArray *)searchIndexs{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_User Set SearchIndex = :SearchIndex Where UserId=:UserId;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *searchIndexDic in searchIndexs) {
            NSString *userId = [searchIndexDic objectForKey:@"U"];
            NSMutableString *searchIndex = [[NSMutableString alloc] init];
            for (NSString *str in searchIndexDic.allValues) {
                [searchIndex appendString:str];
                [searchIndex appendString:@"|"];
            }
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:searchIndex];
            [param addObject:userId];
            [params addObject:param];
            [param release];
            param = nil;
            [searchIndex release];
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (void)bulkInsertUserInfosNotSaveDescInfo:(NSArray *)userInfos{

    if (userInfos.count <= 0) {
        return;
    }
    [[self dbInstance] usingTransaction:^(Database *database) {
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        long maxLastUpdateTime = 0;
        NSString *sql = @"insert or Replace into IM_User(UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime) values(:UserID, :XmppId, :Name, :DescInfo, :HeaderSrc, :UserInfo, :LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDic in userInfos) {
            NSString *userId = [infoDic objectForKey:@"U"];
            NSString *domain = [infoDic objectForKey:@"Domain"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@",userId, (domain.length > 0) ? domain : _domain];
            NSString *Name = [infoDic objectForKey:@"N"];
            NSString *DescInfo = [infoDic objectForKey:@"D"];
            NSString *HeaderSrc = @":NULL";
            NSString *UserInfo = @":NULL";
            NSInteger LastUpdateTime = [[infoDic objectForKey:@"V"] integerValue];
            if (LastUpdateTime > maxLastUpdateTime) {
                maxLastUpdateTime = LastUpdateTime;
            }
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userId ? userId : @""];
            [param addObject:xmppId ? xmppId : @""];
            [param addObject:Name ? Name : @""];
            [param addObject:DescInfo ? DescInfo : @":NULL"];
            [param addObject:HeaderSrc ? HeaderSrc : @""];
            [param addObject:UserInfo ? UserInfo : @""];
            [param addObject:@(0)];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        QIMVerboseLog(@"更新组织架构%ld条数据 耗时 = %f s", userInfos.count, end - start); //s
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateMaxRosterListTime" object:@(maxLastUpdateTime)];
    }];
}

- (void)bulkUpdateUserBackInfo:(NSDictionary *)userBackInfo WithXmppId:(NSString *)xmppId {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *insertSql = @"insert or replace into IM_User_BackInfo(XmppId, UserWorkInfo, LastUpdateTime) values(:XmppId, :UserWorkInfo, :LastUpdateTime);";
        NSString *userWorkInfoStr = [userBackInfo objectForKey:@"UserWorkInfo"];
        NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
        NSTimeInterval time=[nowDate timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
        
        NSMutableArray *insertParam = [[NSMutableArray alloc] init];
        [insertParam addObject:xmppId?xmppId:@":NULL"];
        [insertParam addObject:userWorkInfoStr?userWorkInfoStr:@":NULL"];
        [insertParam addObject:@(time)];
        
        [database executeNonQuery:insertSql withParameters:insertParam];
        [insertParam release];
        insertParam = nil;
    }];
}

- (void)InsertOrUpdateUserInfos:(NSArray *)userInfos{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or replace into IM_User(UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime) values(:UserID, :XmppId, :Name, :DescInfo, :HeaderSrc, :UserInfo, :LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDic in userInfos) {
            NSString *userId = [infoDic objectForKey:@"U"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@",userId, _domain];
            NSString *Name = [infoDic objectForKey:@"N"];
            NSString *DescInfo = [infoDic objectForKey:@"D"] ? [infoDic objectForKey:@"D"] : @":NULL";
            NSString *HeaderSrc = [infoDic objectForKey:@"H"] ? [infoDic objectForKey:@"H"] : @":NULL";
            NSString *UserInfo = @":NULL";
            NSString *LastUpdateTime = @"0";
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userId];
            [param addObject:xmppId];
            [param addObject:Name];
            [param addObject:DescInfo];
            [param addObject:HeaderSrc];
            [param addObject:UserInfo];
            [param addObject:LastUpdateTime];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (NSDictionary *)selectUserByJID:(NSString *)jid{
    if (jid == nil) {
        return nil;
    }
    __block NSMutableDictionary *user = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime,SearchIndex from IM_User Where XmppId = :XmppId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:jid];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
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
        
    }];
    return [user autorelease];
}

- (void)clearUserList {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *deleteSql = [NSMutableString stringWithString:@"Delete From IM_User"];
        [database executeNonQuery:deleteSql withParameters:nil];
    }];
}

- (void)clearUserListForList:(NSArray *)userInfos{
    if (userInfos.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *deleteSql = [NSMutableString stringWithString:@"Delete From IM_User Where UserId not in ("];
        for (NSDictionary *infoDic in userInfos) {
            NSString *userId = [infoDic objectForKey:@"U"];
            if (userId) {
                [deleteSql appendFormat:@"'%@',",userId];
            }
        }
        [deleteSql deleteCharactersInRange:NSMakeRange(deleteSql.length - 1, 1)];
        [deleteSql appendString:@");"];
        [database executeNonQuery:deleteSql withParameters:nil];
    }];
}

- (void)bulkInsertUserInfos:(NSArray *)userInfos{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or Replace into IM_User(UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime) values(:UserID, :XmppId, :Name, :DescInfo, :HeaderSrc, :UserInfo, :LastUpdateTime);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *infoDic in userInfos) {
            NSString *userId = [infoDic objectForKey:@"U"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@",userId, _domain];
            NSString *Name = [infoDic objectForKey:@"N"];
            NSString *DescInfo = [infoDic objectForKey:@"D"];
            NSString *HeaderSrc = @":NULL";
            NSString *UserInfo = @":NULL";
            NSString *LastUpdateTime = @"0";
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:userId];
            [param addObject:xmppId];
            [param addObject:Name];
            [param addObject:DescInfo];
            [param addObject:HeaderSrc];
            [param addObject:UserInfo];
            [param addObject:LastUpdateTime];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (void)updateUser:(NSString *)userId WithHeaderSrc:(NSString *)headerSrc WithVersion:(NSString *)version{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] usingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_User Set HeaderSrc = :HeaderSrc,LastUpdateTime = :LastUpdateTime Where UserId=:UserId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:headerSrc?headerSrc:@":NULL"];
        [param addObject:version];
        [param addObject:userId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"更新用户信息 耗时 = %f s userId : %@, headerSrc: %@, version: %@", end - start, userId, headerSrc, version); //s
}

- (void)bulkUpdateUserCardsV2:(NSArray *)cards{
    [[self dbInstance] usingTransaction:^(Database *database) {
        NSString *insertSql = @"insert or IGNORE into IM_User(UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime) values(:UserID, :XmppId, :Name, :DescInfo, :HeaderSrc, :UserInfo, :LastUpdateTime);";
        NSString *sql = @"Update IM_User Set Name = (CASE WHEN :Name ISNULL then Name else :Name1 end), DescInfo = (CASE WHEN :DescInfo ISNULL then DescInfo else :DescInfo1 end), HeaderSrc = :HeaderSrc, UserInfo = :UserInfo, LastUpdateTime=:LastUpdateTime Where XmppId = :XmppId;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        NSMutableArray *insertParams = [[NSMutableArray alloc] init];
        for (NSDictionary *userDic in cards) {
            NSString *userId = [userDic objectForKey:@"U"];
            NSString *xmppId = [userDic objectForKey:@"X"];
            NSString *Name = [userDic objectForKey:@"N"];
            if ([Name isKindOfClass:[NSNull class]] || Name.length <=0 || [Name.lowercaseString isEqualToString:@"undefined"]) {
                Name = @":NULL";
            }
            NSString *DescInfo = [userDic objectForKey:@"D"];
            if ([DescInfo isKindOfClass:[NSNull class]] || DescInfo.length <=0 || [DescInfo.lowercaseString isEqualToString:@"undefined"]) {
                DescInfo = @":NULL";
            }
            NSString *HeaderSrc = [userDic objectForKey:@"H"];
            NSString *UserInfo = [userDic objectForKey:@"I"];
            NSString *LastUpdateTime = [userDic objectForKey:@"V"];
            
            NSMutableArray *insertParam = [[NSMutableArray alloc] init];
            [insertParam addObject:userId?userId:@":NULL"];
            [insertParam addObject:xmppId?xmppId:@":NULL"];
            [insertParam addObject:Name?Name:@":NULL"];
            [insertParam addObject:DescInfo?DescInfo:@":NULL"];
            [insertParam addObject:HeaderSrc?HeaderSrc:@":NULL"];
            [insertParam addObject:UserInfo?UserInfo:@":NULL"];
            [insertParam addObject:LastUpdateTime];
            [insertParams addObject:insertParam?insertParam:@":NULL"];
            [insertParam release];
            insertParam = nil;
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            //            [param addObject:userId];
            [param addObject:Name?Name:@":NULL"];
            [param addObject:Name?Name:@":NULL"];
            [param addObject:DescInfo?DescInfo:@":NULL"];
            [param addObject:DescInfo?DescInfo:@":NULL"];
            [param addObject:HeaderSrc?HeaderSrc:@":NULL"];
            [param addObject:UserInfo?UserInfo:@":NULL"];
            [param addObject:LastUpdateTime];
            [param addObject:xmppId?xmppId:@":NULL"];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:insertSql withParameters:insertParams];
        [insertParams release];
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (NSString *)getUserHeaderSrcByUserId:(NSString *)userId{
    
    if (userId == nil) {
        return nil;
    }
    __block NSString *headerSrc = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select HeaderSrc From IM_User Where XmppId=:XmppId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        if ([reader read]) {
            headerSrc = [[reader objectForColumnIndex:0] retain];
        }
    }];
    return [headerSrc autorelease];
}

//- (void)insertUserInfoWihtUserId:(NSString *)userId
//                        WithName:(NSString *)name
//                    WithDescInfo:(NSString *)descInfo
//                     WithHeadSrc:(NSString *)headerSrc
//                    WihtUserInfo:(NSData *)userInfo{
//    if (userId.length > 0) {
//        [[self dbInstance] syncUsingTransaction:^(Database *database) {
//            NSString *sql = @"insert or replace into IM_User(UserId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime) values(:UserID, :Domain, :NickName, :Header, :UserInfo, :LastUpdateTime);";
//            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:5];
//            [param addObject:userId];
//            [param addObject:name?name:@":NULL"];
//            [param addObject:descInfo?descInfo:@":NULL"];
//            [param addObject:headerSrc?headerSrc:@":NULL"];
//            [param addObject:userInfo?userInfo:@":NULL"];
//            [param addObject:[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
//            [database executeNonQuery:sql withParameters:param];
//            [param release];
//            param = nil;
//        }];
//    } else {
//        QIMVerboseLog(@"Add UserId is NUll");
//    }
//}

- (NSDictionary *)selectUserByID:(NSString *)userId{
    if (userId == nil) {
        return nil;
    }
    __block NSMutableDictionary *user = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime from IM_User Where UserId = :UserId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        if ([reader read]) {
            user = [[NSMutableDictionary alloc] init];
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *XmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSData *data = [reader objectForColumnIndex:5];
            NSNumber *dateTime = [reader objectForColumnIndex:6];
            
            [IMDataManager safeSaveForDic:user setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:user setObject:XmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:user setObject:name?name:userId forKey:@"Name"];
            [IMDataManager safeSaveForDic:user setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:user setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:user setObject:data forKey:@"UserInfo"];
            [IMDataManager safeSaveForDic:user setObject:dateTime forKey:@"LastUpdateTime"];
            
        }
        
    }];
    return [user autorelease];
}

- (NSDictionary *)selectUserBackInfoByXmppId:(NSString *)xmppId {
    if (!xmppId) {
        return nil;
    }
    __block NSMutableDictionary *userBackInfo = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT *from IM_User_BackInfo Where XmppId = :XmppId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:xmppId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        if ([reader read]) {
            userBackInfo = [[NSMutableDictionary alloc] init];
            NSString *workInfo = [reader objectForColumnName:@"UserWorkInfo"];
            NSNumber *dateTime = [reader objectForColumnName:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:userBackInfo setObject:workInfo forKey:@"UserWorkInfo"];
            [IMDataManager safeSaveForDic:userBackInfo setObject:dateTime forKey:@"LastUpdateTime"];
        }
    }];
    return [userBackInfo autorelease];
}

- (void) removeAllMessages {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"delete from IM_Message;";
        [database executeNonQuery:sql withParameters:nil];
    }];
}

//- (NSDictionary *)selectUserByName:(NSString *)name{
//    if(name == nil)
//        return nil;
//
//    __block NSMutableDictionary *user = nil;
//    [[self dbInstance] syncUsingTransaction:^(Database *database) {
//
//        NSString *sql = @"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime from IM_User Where Name = :Name;";
//        NSMutableArray *param = [[NSMutableArray alloc] init];
//        [param addObject:name];
//        DataReader *reader = [database executeReader:sql withParameters:param];
//        [param release];
//        if ([reader read]) {
//            user = [[NSMutableDictionary alloc] init];
//            NSString *userId = [reader objectForColumnIndex:0];
//            NSString *XmppId = [reader objectForColumnIndex:1];
//            NSString *name = [reader objectForColumnIndex:2];
//            NSString *descInfo = [reader objectForColumnIndex:3];
//            NSString *headerScr = [reader objectForColumnIndex:4];
//            NSData *data = [reader objectForColumnIndex:5];
//            NSNumber *dateTime = [reader objectForColumnIndex:6];
//
//            [IMDataManager safeSaveForDic:user setObject:userId forKey:@"UserId"];
//            [IMDataManager safeSaveForDic:user setObject:XmppId forKey:@"XmppId"];
//            [IMDataManager safeSaveForDic:user setObject:name?name:userId forKey:@"Name"];
//            [IMDataManager safeSaveForDic:user setObject:descInfo forKey:@"DescInfo"];
//            [IMDataManager safeSaveForDic:user setObject:headerScr forKey:@"HeaderScr"];
//            [IMDataManager safeSaveForDic:user setObject:data forKey:@"UserInfo"];
//            [IMDataManager safeSaveForDic:user setObject:dateTime forKey:@"LastUpdateTime"];
//        }
//
//    }];
//    return [user autorelease];
//}

- (NSDictionary *)selectUserByIndex:(NSString *)index{
    if (index == nil) {
        return nil;
    }
    __block NSMutableDictionary *user = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select UserId, XmppId, Name, DescInfo, HeaderSrc, SearchIndex, LastUpdateTime from IM_User Where Name = :Name OR UserId = :UserId OR XmppId = :XmppId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:index];
        [param addObject:index];
        [param addObject:index];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        if ([reader read]) {
            user = [[NSMutableDictionary alloc] init];
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *XmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSString *searchIndex = [reader objectForColumnIndex:5];
            NSNumber *dateTime = [reader objectForColumnIndex:6];
            
            [IMDataManager safeSaveForDic:user setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:user setObject:XmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:user setObject:name?name:userId forKey:@"Name"];
            [IMDataManager safeSaveForDic:user setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:user setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:user setObject:searchIndex forKey:@"SearchIndex"];
            [IMDataManager safeSaveForDic:user setObject:dateTime forKey:@"LastUpdateTime"];
        }
        
    }];
    return [user autorelease];
}

- (NSArray *)selectXmppIdFromSessionList {
    __block NSMutableArray *list = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select XmppId From IM_SessionList Where XmppId not like '%conference.%'";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (list == nil) {
                list = [[NSMutableArray alloc] init];
            }
            [list addObject:[reader objectForColumnIndex:0]];
        }
    }];
    return [list autorelease];
}

- (NSArray *)selectXmppIdList{
    __block NSMutableArray *list = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select XmppId From IM_User;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (list == nil) {
                list = [[NSMutableArray alloc] init];
            }
            [list addObject:[reader objectForColumnIndex:0]];
        }
    }];
    return [list autorelease];
}

- (NSArray *)selectUserIdList{
    __block NSMutableArray *list = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select UserId From IM_User;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (list == nil) {
                list = [[NSMutableArray alloc] init];
            }
            [list addObject:[reader objectForColumnIndex:0]];
        }
    }];
    return [list autorelease];
}

//Select a.UserId, a.XmppId, a.Name, a.DescInfo, a.HeaderSrc, a.UserInfo, a.LastUpdateTime from IM_Group_Member as b left join IM_User as a on a.Name = b.Name where GroupId = 'qtalk客户端开发群@conference.ejabhost1'

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr inGroup:(NSString *) groupId {
    __block NSMutableArray *list = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"Select a.UserId, a.XmppId, a.Name, a.DescInfo, a.HeaderSrc, a.UserInfo, a.LastUpdateTime from IM_Group_Member as b left join IM_User as a on a.Name = b.Name and (a.UserId like '%%%@%%' OR a.Name like '%%%@%%' OR a.SearchIndex like '%%%@%%') WHERE GroupId = ?;",searchStr,searchStr,searchStr];
        
        DataReader *reader = [database executeReader:sql withParameters:[NSArray arrayWithObject:groupId]];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
        }
        while ([reader read]) {
            NSString *userId = [reader objectForColumnIndex:0];
            if (userId == nil) {
                continue;
            }
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [list addObject:dic];
        }
    }];
    return [list autorelease];
}

- (NSArray *)searchUserBySearchStr:(NSString *)searchStr notInGroup:(NSString *)groupId {
    __block NSMutableArray *list = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select *from IM_User as a where a.XmppId not in (select MemberJid from IM_Group_Member where GroupId='%@') and (a.UserId like '%%%@%%' OR a.Name like '%%%@%%' OR a.SearchIndex like '%%%@%%');", groupId, searchStr,searchStr,searchStr];
        
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
        }
        while ([reader read]) {
            NSString *userId = [reader objectForColumnIndex:0];
            if (userId == nil) {
                continue;
            }
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [list addObject:dic];
        }
    }];
    return [list autorelease];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr {
    return [self selectUserListBySearchStr:searchStr WithLimit:-1 WithOffset:-1];
}

- (NSInteger)selectUserListTotalCountBySearchStr:(NSString *)searchStr {
    return [[self selectUserListBySearchStr:searchStr] count];
}

- (NSArray *)selectUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSMutableArray *list = nil;
    __block NSMutableArray *firstlist = [NSMutableArray array];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime,SearchIndex from IM_User as a LEFT JOIN (select *from IM_Client_Config where ConfigValue like '%%%@%%' and ConfigKey='kMarkupNames') as b where (a.XmppId=b.ConfigSubKey or a.UserId like '%%%@%%' OR a.Name like '%%%@%%' OR a.SearchIndex like '%%%@%%');", searchStr, searchStr, searchStr, searchStr];
        if (limit != -1 && offset != -1) {
            sql = [sql stringByAppendingString:[NSString stringWithFormat:@"LIMIT %ld OFFSET %ld", (long)limit, (long)offset]];
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (list == nil) {
                list = [[NSMutableArray alloc] init];
            }
            NSString *userId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSString *searchIndex = [reader objectForColumnIndex:7];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            searchIndex = [NSString stringWithFormat:@"|%@",searchIndex];
            if ([userId isEqualToString:searchStr] || [xmppId isEqualToString:searchStr] || [name isEqualToString:searchStr] || [searchIndex rangeOfString:[NSString stringWithFormat:@"|%@|",searchStr] options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                [firstlist addObject:dic];
            } else {
                [list addObject:dic];
            }
        }
    }];
    
    if (firstlist.count > 0) {
        [list insertObjects:firstlist atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, firstlist.count)]];
    }
    return [list autorelease];
}

- (NSDictionary *)selectUsersDicByXmppIds:(NSArray *)xmppIds{
    __block NSMutableDictionary *usersDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime,SearchIndex from IM_User Where XmppId in ("];
        NSString *lastXmppId = [xmppIds lastObject];
        for (NSString *xmppId in xmppIds) {
            if ([lastXmppId isEqualToString:xmppId]) {
                [sql appendFormat:@"'%@');",xmppId];
            } else {
                [sql appendFormat:@"'%@',",xmppId];
            }
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (usersDic == nil) {
            usersDic = [[NSMutableDictionary alloc] init];
        }
        while ([reader read]) {
            NSString *userId = [reader objectForColumnIndex:0];
            if (userId == nil)
            continue;
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSString *userInfo = [reader objectForColumnIndex:5];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:6];
            NSString *searchIndex = [reader objectForColumnIndex:7];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:dic setObject:userInfo forKey:@"UserInfo"];
            [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:dic setObject:searchIndex forKey:@"SearchIndex"];
            [usersDic setObject:dic forKey:xmppId];
        }
    }];
    return [usersDic autorelease];
}

- (NSArray *)selectUserListByUserIds:(NSArray *)userIds{
    __block NSMutableArray *list = nil;
    if (userIds.count <= 0) {
        return nil;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime,SearchIndex from IM_User Where UserId in ("];
        NSString *lastUserId = [userIds lastObject];
        for (NSString *userId in userIds) {
            if ([lastUserId isEqualToString:userId]) {
                [sql appendFormat:@"'%@');",userId];
            } else {
                [sql appendFormat:@"'%@',",userId];
            }
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if (list == nil) {
            list = [[NSMutableArray alloc] init];
        }
        while ([reader read]) {
            NSString *userId = [reader objectForColumnIndex:0];
            if (userId == nil)
            continue;
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *descInfo = [reader objectForColumnIndex:3];
            NSString *headerSrc = [reader objectForColumnIndex:4];
            NSString *userInfo = [reader objectForColumnIndex:5];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:6];
            NSString *searchIndex = [reader objectForColumnIndex:7];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [IMDataManager safeSaveForDic:dic setObject:userId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:dic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:dic setObject:userInfo forKey:@"UserInfo"];
            [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:dic setObject:searchIndex forKey:@"SearchIndex"];
            [list addObject:dic];
        }
    }];
    return [list autorelease];
}

- (BOOL)checkExitsUser{
    __block BOOL exits = NO;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select UserId From IM_User Limit 1;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            exits = YES;
        }
    }];
    return exits;
}

//- (int)getMaxUserIncrementVersion{
//    __block int maxIncrementVersion = 0;
//    [[self dbInstance] syncUsingTransaction:^(Database *database) {
//        NSString *sql = @"Select Max(IncrementVersion) From IM_User;";
//        DataReader *reader = [database executeReader:sql withParameters:nil];
//        if ([reader read]) {
//            maxIncrementVersion = [[reader objectForColumnIndex:0] intValue];
//        }
//    }];
//    return maxIncrementVersion;
//}

- (void)clearGroupCardVersion{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group set LastUpdateTime = NULL;";
        [database executeNonQuery:sql withParameters:nil];
    }];
}

- (NSInteger)getRNSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr {
    __block NSInteger count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*), a.GroupId, a.Name, a.Introduce, a.HeaderSrc, b.Topic, b.LastUpdateTime, b.ExtendedFlag FROM IM_Group as a Left Join (Select GroupId, Topic, ExtendedFlag, LastUpdateTime From IM_Group Order By LastUpdateTime Desc Limit 1) as b On (a.GroupId=b.GroupId) Where (a.GroupId Like '%%%@') And (a.GroupId Like '%%%@%%' Or a.Name Like '%%%@%%' Or a.Introduce Like '%%%@%%' Or a.Topic Like '%%%@%%') Order By b.LastUpdateTime Desc;", @"ejabhost2", keyStr, keyStr,keyStr, keyStr];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] intValue];
        }
    }];
    return count;
}

- (NSArray *)rnSearchEjabHost2GroupChatListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    
    __block NSMutableArray *ejabHost2GroupList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
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
            [value release];
            value = nil;
        }
    }];
    return [ejabHost2GroupList autorelease];
}

- (NSInteger)getLocalGroupTotalCountByUserIds:(NSArray *)userIds{
    __block NSInteger count = 0;
    
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
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
    }];
    return count;
}

- (NSArray *)searchGroupByUserIds:(NSArray *)userIds WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    __block NSMutableArray *groupList = nil;
    
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
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
    return [groupList autorelease];
}

- (NSArray *)getGroupIdList {
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
    return [groupList autorelease];
}

- (NSArray *)qimDB_getGroupList {
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
    return [groupList autorelease];
}

- (NSDictionary *)getGroupCardByGroupId:(NSString *)groupId {
    if (groupId.length <= 0) {
        return nil;
    }
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    __block NSMutableDictionary *groupCardDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime From IM_Group Where GroupId = :GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
    }];
    QIMVerboseLog(@"数据库取群名片耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return [groupCardDic autorelease];
}

- (NSArray *)getGroupVCardByGroupIds:(NSArray *)groupIds{
    if (groupIds.count <= 0) {
        return nil;
    }
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
    return [groupList autorelease];
}

- (NSArray *)getGroupListMaxLastUpdateTime {
    
    __block NSMutableArray *Im_groupList = [NSMutableArray arrayWithCapacity:5];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
    return [Im_groupList autorelease];
}

- (NSArray *)getGroupListMsgMaxTime{
    __block NSMutableArray *groupList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
    return [groupList autorelease];
}

- (BOOL)needUpdateGroupImage:(NSString *)groupId{
    __block BOOL flag = YES;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select ExtendedFlag From IM_Group Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:groupId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        if ([reader read]) {
            flag = ![[reader objectForColumnIndex:0] boolValue];
        }
    }];
    return flag;
}

- (NSString *)getGroupHeaderSrc:(NSString *)groupId{
    
    __block NSString *groupHeaderSrc = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select HeaderSrc From IM_Group Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:groupId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        if ([reader read]) {
            groupHeaderSrc = [[reader objectForColumnIndex:0] retain];
        }
    }];
    return [groupHeaderSrc autorelease];
}

- (BOOL)checkGroup:(NSString *)groupId{
    __block BOOL flag = NO;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select 1 From IM_Group Where GroupId = :GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
        if ([reader read]) {
            flag = YES;
        }
    }];
    return flag;
}

- (void) bulkinsertGroups:(NSArray *) groups {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        [database executeBulkInsert:@"insert or IGNORE into IM_Group(GroupId, Name, LastUpdateTime) values(:GroupId, :Name, :LastUpdateTime);" withParameters:groups];
    }];
}

- (void)insertGroup:(NSString *)groupId {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or IGNORE into IM_Group(GroupId, Name, LastUpdateTime) values(:GroupId, :Name, :LastUpdateTime);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:groupId];
        [param addObject:[[groupId componentsSeparatedByString:@"@"] objectAtIndex:0]];
        [param addObject:@(0)];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)updateGroup:(NSString *)groupId WithTopic:(NSString *)topic{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set Topic=:Topic Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:topic?topic:@":NULL"];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)bulkUpdateGroupCards:(NSArray *)array{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set Name=(CASE WHEN :Name ISNULL then Name else :Name1 end),Introduce=(CASE WHEN :Introduce ISNULL then Introduce else :Introduce1 end), HeaderSrc=(CASE WHEN :HeaderSrc ISNULL then HeaderSrc else :HeaderSrc1 end),Topic=(CASE WHEN :Topic ISNULL then Topic else :Topic1 end), LastUpdateTime=:LastUpdateTime,ExtendedFlag=:ExtendedFlag Where GroupId = :GroupId;";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *infoDic in array) {
            NSString *groupId = [infoDic objectForKey:@"MN"];
            NSString *nickName = [infoDic objectForKey:@"SN"];
            NSString *desc = [infoDic objectForKey:@"MD"];
            NSString *topic = [infoDic objectForKey:@"MT"];
            NSString *headerSrc = [infoDic objectForKey:@"MP"];
            NSString *version = [infoDic objectForKey:@"VS"];
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
            [param addObject:@(headerSrc.length > 0)];
            [param addObject:groupId];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (void)updateGroup:(NSString *)groupId
       WihtNickName:(NSString *)nickName
          WithTopic:(NSString *)topic
           WithDesc:(NSString *)desc
      WithHeaderSrc:(NSString *)headerSrc
        WithVersion:(NSString *)version{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set Name=(CASE WHEN :Name ISNULL then Name else :Name1 end),Introduce=(CASE WHEN :Introduce ISNULL then Introduce else :Introduce1 end), HeaderSrc=(CASE WHEN :HeaderSrc ISNULL then HeaderSrc else :HeaderSrc1 end),Topic=(CASE WHEN :Topic ISNULL then Topic else :Topic1 end), LastUpdateTime=:LastUpdateTime Where GroupId = :GroupId;";
        NSMutableArray *param = [NSMutableArray array];
        [param addObject:nickName.length > 0?nickName:@":NULL"];
        [param addObject:nickName.length > 0?nickName:@":NULL"];
        [param addObject:desc.length > 0?desc:@":NULL"];
        [param addObject:desc.length > 0?desc:@":NULL"];
        [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
        [param addObject:headerSrc.length > 0?headerSrc:@":NULL"];
        [param addObject:topic.length > 0?topic:@":NULL"];
        [param addObject:topic.length > 0?topic:@":NULL"];
        [param addObject:version];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
    }];
}

- (void)updateGroup:(NSString *)groupId WihtNickName:(NSString *)nickName{
    
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set Name=:Name Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:nickName];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)updateGroup:(NSString *)groupId WithDesc:(NSString *)desc{
    
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set Introduce=:Introduce Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:desc];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)updateGroup:(NSString *)groupId WithHeaderSrc:(NSString *)headerSrc{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set HeaderSrc=:HeaderSrc Where GroupId = :GroupId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:headerSrc];
        [param addObject:groupId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)deleteGroup:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Group Where GroupId = :GroupId;";
        [database executeNonQuery:sql withParameters:@[groupId]];
        sql = @"Delete From IM_Group_Member Where GroupId = :GroupId;";
        [database executeNonQuery:sql withParameters:@[groupId]];
    }];
}

- (NSDictionary *)getGroupMemberInfoByNickName:(NSString *)nickName{
    __block NSMutableDictionary *infoDic = nil;
    if (nickName) {
        [[self dbInstance] syncUsingTransaction:^(Database *database) {
            NSString *sql = @"Select  MemberJid, GroupId, Name, Affiliation From IM_Group_Member Where Name = :Name;";
            DataReader *reader = [database executeReader:sql withParameters:@[nickName]];
            if ([reader read]) {
                NSString *memberId = [reader objectForColumnIndex:0];
                NSString *name = [reader objectForColumnIndex:2];
                NSString *affiliation = [reader objectForColumnIndex:3];
                infoDic = [[NSMutableDictionary alloc] init];
                [infoDic setObject:memberId forKey:@"jid"];
                [infoDic setObject:name forKey:@"name"];
                [infoDic setObject:affiliation forKey:@"affiliation"];
            }
        }];
    }
    return [infoDic autorelease];
}

- (NSDictionary *)getGroupMemberInfoByJid:(NSString *)jid WithGroupId:(NSString *)groupId{
    __block NSMutableDictionary *infoDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select  MemberId, GroupId, Name, Affiliation From IM_Group_Member Where MemberJid = :MemberJid And GroupId = :GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:@[jid,groupId]];
        if ([reader read]) {
            NSString *memberId = [reader objectForColumnIndex:0];
            NSString *name = [reader objectForColumnIndex:2];
            NSString *affiliation = [reader objectForColumnIndex:3];
            infoDic = [[NSMutableDictionary alloc] init];
            [infoDic setObject:memberId forKey:@"jid"];
            [infoDic setObject:name forKey:@"name"];
            [infoDic setObject:affiliation forKey:@"affiliation"];
        }
    }];
    return [infoDic autorelease];
}

- (BOOL)checkGroupMember:(NSString *)nickName WihtGroupId:(NSString *)groupId{
    __block BOOL flag = NO;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select 1 From IM_Group_Member Where MemberId = :MemberId;";
        NSString *memId = [groupId stringByAppendingFormat:@"/%@",nickName];
        DataReader *reader = [database executeReader:sql withParameters:@[memId]];
        if ([reader read]) {
            flag = YES;
        }
    }];
    return flag;
}

- (void)insertGroupMember:(NSDictionary *)memberDic WithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or Replace into IM_Group_Member(MemberId, GroupId, Name, MemberJid, Affiliation, LastUpdateTime) values(:MemberId, :GroupId, :Name, :MemberJid, :Affiliation, :LastUpdateTime);";
        NSString *memId = [groupId stringByAppendingFormat:@"/%@",[memberDic objectForKey:@"name"]];
        NSString *name = [memberDic objectForKey:@"name"];
        NSString *Affiliation = [memberDic objectForKey:@"affiliation"];
        NSString *jid = [memberDic objectForKey:@"jid"];
        NSNumber *LastUpdateTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:memId];
        [param addObject:groupId];
        [param addObject:name];
        [param addObject:jid];
        [param addObject:Affiliation];
        [param addObject:LastUpdateTime];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)bulkInsertGroupMember:(NSArray *)members WithGroupId:(NSString *)groupId{
    if (!members) {
        return;
    }
    groupId = [groupId copy];
    [[self dbInstance] usingTransaction:^(Database *database) {
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
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:memId];
            [param addObject:groupId];
            [param addObject:name];
            [param addObject:memberXmppJid];
            [param addObject:affiliation];
            [param addObject:lastUpdateTime];
            [params addObject:param];
            [param release];
            param = nil;
        }
        
        [database executeNonQuery:deleteSql withParameters:nil];
        
        NSString *sql = @"insert or REPLACE into IM_Group_Member(MemberId, GroupId, Name, MemberJid, Affiliation, LastUpdateTime)  values(:MemberId, :GroupId, :Name, :MemberJid, :Affiliation, :LastUpdateTime);";
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId{
    __block NSMutableArray *members = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select a.MemberId, b.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_User b on a.MemberJid = b.XmppId Where GroupId = ? Order By a.Name;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
            [dic release];
            dic = nil;
        }
    }];
    return [members autorelease];
}

- (NSArray *)getQChatGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr{
    __block NSMutableArray *members = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"Select a.MemberId, b.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_User b on a.MemberJid = b.XmppId Where GroupId = ? and (b.UserId like '%%%@%%' OR b.Name like '%%%@%%' OR b.SearchIndex like '%%%@%%' COLLATE NOCASE) Order By a.Name;",searchStr,searchStr,searchStr];
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
            [dic release];
            dic = nil;
        }
    }];
    return [members autorelease];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId BySearchStr:(NSString *)searchStr{
    __block NSMutableArray *members = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"Select a.MemberId, a.Name, b.XmppId as Jid, a.Affiliation, a.LastUpdateTime From IM_Group_Member a left join IM_User b on a.MemberJid = b.XmppId Where GroupId = :GroupId and (b.UserId like \"%%%@%%\" OR b.Name like \"%%%@%%\" OR b.SearchIndex like \"%%%@%%\" COLLATE NOCASE) Order By a.Name;",searchStr,searchStr,searchStr];
        //        NSString *sql = @"Select MemberId, Name, Affiliation, LastUpdateTime From IM_Group_Member Where GroupId = :GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
            [dic release];
            dic = nil;
        }
    }];
    return [members autorelease];
}

- (NSArray *)qimDB_getGroupMember:(NSString *)groupId{
    __block NSMutableArray *members = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select MemberJid, Name, Affiliation From IM_Group_Member Where GroupId = :GroupId Order By Name;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
            [dic release];
            dic = nil;
        }
    }];
    return [members autorelease];
}

- (NSDictionary *)getGroupOwnerInfoForGroupId:(NSString *)groupId{
    if (groupId.length <= 0) {
        return nil;
    }
    __block NSDictionary *user = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT b.* FROM IM_Group_Member as a LEFT JOIN IM_User as b on a.MemberJid = b.XmppId WHERE GroupId = :GroupId And Affiliation = 'owner';";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
    }];
    return [user autorelease];
}

- (void)deleteGroupMemberWithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Group_Member Where GroupId=:GroupId;";
        [database executeNonQuery:sql withParameters:@[groupId]];
    }];
}

- (void)deleteGroupMemberJid:(NSString *)memberJid WithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Group_Member Where GroupId=:GroupId and MemberJid = :MemberJid;";
        [database executeNonQuery:sql withParameters:@[groupId,memberJid]];
    }];
}

- (void)deleteGroupMember:(NSString *)nickname WithGroupId:(NSString *)groupId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Group_Member Where MemberId = :MemberId;";
        NSString *memId = [groupId stringByAppendingFormat:@"/%@",nickname];
        [database executeNonQuery:sql withParameters:@[memId]];
    }];
}


- (long long)getMinMsgTimeStampByXmppId:(NSString *)xmppId RealJid:(NSString *)realJid{
    __block long long timeStamp = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select min(LastUpdateTime) From IM_Message Where XmppId = :XmppId And RealJid = :RealJid;";
        DataReader *reader = [database executeReader:sql withParameters:@[xmppId, realJid]];
        if ([reader read]) {
            id value = [reader objectForColumnIndex:0];
            if (value) {
                timeStamp = floor([value doubleValue]);
            } else {
                timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
            }
        } else {
            timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
        }
    }];
    return timeStamp;
}

- (long long)getMinMsgTimeStampByXmppId:(NSString *)xmppId{
    __block long long timeStamp = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select min(LastUpdateTime) From IM_Message Where XmppId = :XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[xmppId]];
        if ([reader read]) {
            id value = [reader objectForColumnIndex:0];
            if (value) {
                timeStamp = floor([value doubleValue]);
            } else {
                timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
            }
        } else {
            timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
        }
    }];
    return timeStamp;
}

- (long long) lastestGroupMessageTime {
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    __block long long maxRemoteTimeStamp = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *newSql = @"select LastUpdateTime from IM_Message Where ChatType = 1 And (State == 2 Or State == 16) ORDER by LastUpdateTime desc limit(1);";
        DataReader *newReader = [database executeReader:newSql withParameters:nil];
        if ([newReader read]) {
            maxRemoteTimeStamp = [[newReader objectForColumnIndex:0] longLongValue];
        } else {
            QIMVerboseLog(@"取个群时间戳老逻辑");
            NSString *sql = @"select max(LastUpdateTime) from IM_Message where XmppId like '%@conference.%' And (State == 2 Or State == 16);";
            DataReader *reader = [database executeReader:sql withParameters:nil];
            if ([reader read]) {
                maxRemoteTimeStamp = ceil([[reader objectForColumnIndex:0] longLongValue]);
            }
        }
    }];
    QIMVerboseLog(@"取个群时间戳这么长时间 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return maxRemoteTimeStamp;
}

- (long long)getMaxMsgTimeStampByXmppId:(NSString *)xmppId {
    __block long long timeStamp = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select max(LastUpdateTime) From IM_Message Where XmppId = :XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[xmppId]];
        if ([reader read]) {
            timeStamp = ceil([[reader objectForColumnIndex:0] doubleValue]);
        }
    }];
    return timeStamp;
}

- (void)updateMessageWihtMsgId:(NSString *)msgId
                 WithSessionId:(NSString *)sessionId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  ExtendedFlag:(int)ExtendedFlag {
    [self updateMessageWihtMsgId:msgId WithSessionId:sessionId WithFrom:from WithTo:to WithContent:content WithPlatform:platform WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:readedTag ExtendedFlag:ExtendedFlag WithMsgRaw:nil];
}


- (void)updateMessageWihtMsgId:(NSString *)msgId
                 WithSessionId:(NSString *)sessionId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  ExtendedFlag:(int)ExtendedFlag
                    WithMsgRaw:(NSString *)msgRaw{
    
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set XmppId=:XmppId, \"From\"=:from, \"To\"=:to, Content=:content, ExtendInfo=:ExtendInfo, Platform=:platform, Type=:type, State=:state, Direction=:Direction,LastUpdateTime=:LastUpdateTime,ReadedTag=:ReadedTag,ExtendedFlag=:ExtendedFlag,MessageRaw=:MessageRaw Where MsgId=:MsgId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:sessionId];
        [param addObject:from?from:@":NULL"];
        [param addObject:to?to:@":NULL"];
        [param addObject:content?content:@":NULL"];
        [param addObject:extendInfo?extendInfo:@":NULL"];
        [param addObject:[NSNumber numberWithInt:platform]];
        [param addObject:[NSNumber numberWithInt:msgType]];
        [param addObject:[NSNumber numberWithInt:msgState]];
        [param addObject:[NSNumber numberWithInt:msgDirection]];
        [param addObject:[NSNumber numberWithLongLong:msgDate]];
        [param addObject:[NSNumber numberWithInt:0]];
        [param addObject:[NSNumber numberWithInt:ExtendedFlag]];
        [param addObject:msgRaw?msgRaw:@":NULL"];
        [param addObject:msgId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
    
}

- (void)revokeMessageByMsgList:(NSArray *)revokeMsglist {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set Content = :content, Type = :type Where MsgId=:MsgId;";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *subItem in revokeMsglist) {
            NSString *msgId = [subItem objectForKey:@"messageId"];
            NSString *content = [subItem objectForKey:@"message"];
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:content];
            [param addObject:@(-1)];
            [param addObject:msgId];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}

- (void)revokeMessageByMsgId:(NSString *)msgId
                 WihtContent:(NSString *)content
                 WithMsgType:(int)msgType{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set Content=:content,Type=:type Where MsgId=:MsgId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:content];
        [param addObject:@(msgType)];
        [param addObject:msgId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)updateMessageWithExtendInfo:(NSString *)extendInfo ForMsgId:(NSString *)msgId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set ExtendedFlag=:ExtendedFlag Where MsgId=:MsgId;";
        [database executeNonQuery:sql withParameters:@[extendInfo,msgId]];
    }];
}

- (void)deleteMessageWithXmppId:(NSString *)xmppId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Message Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[xmppId]];
    }];
}

- (void)deleteMessageByMessageId:(NSString *)messageId ByJid:(NSString *)sid{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Message Where MsgId=:MsgId;";
        [database executeNonQuery:sql withParameters:@[messageId]];
    }];
}

- (void)updateMessageWithMsgId:(NSString *)msgId
                    WithMsgRaw:(NSString *)msgRaw{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set MessageRaw=:MessageRaw Where MsgId=:MsgId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:msgRaw?msgRaw:@":NULL"];
        [param addObject:msgId];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)insertMessageWihtMsgId:(NSString *)msgId
                    WithXmppId:(NSString *)xmppId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                  WithChatType:(NSInteger)chatType{
    return [self insertMessageWihtMsgId:msgId WithXmppId:xmppId WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:platform WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:readedTag WithMsgRaw:nil WithChatType:chatType];
}

- (void)insertMessageWihtMsgId:(NSString *)msgId
                    WithXmppId:(NSString *)xmppId
                      WithFrom:(NSString *)from
                        WithTo:(NSString *)to
                   WithContent:(NSString *)content
                WithExtendInfo:(NSString *)extendInfo
                  WithPlatform:(int)platform
                   WithMsgType:(int)msgType
                  WithMsgState:(int)msgState
              WithMsgDirection:(int)msgDirection
                   WihtMsgDate:(long long)msgDate
                 WithReadedTag:(int)readedTag
                    WithMsgRaw:(NSString *)msgRaw
                  WithChatType:(NSInteger)chatType{
    return [self insertMessageWihtMsgId:msgId WithXmppId:xmppId WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:platform WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:readedTag WithMsgRaw:msgRaw WithRealJid:nil WithChatType:chatType];
}

- (void) insertMessageWihtMsgId:(NSString *)msgId
                     WithXmppId:(NSString *)xmppId
                       WithFrom:(NSString *)from
                         WithTo:(NSString *)to
                    WithContent:(NSString *)content
                 WithExtendInfo:(NSString *)extendInfo
                   WithPlatform:(int)platform
                    WithMsgType:(int)msgType
                   WithMsgState:(int)msgState
               WithMsgDirection:(int)msgDirection
                    WihtMsgDate:(long long)msgDate
                  WithReadedTag:(int)readedTag
                     WithMsgRaw:(NSString *)msgRaw
                    WithRealJid:(NSString *)realJid
                   WithChatType:(NSInteger)chatType {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or IGNORE into IM_Message(MsgId, XmppId, \"From\", \"To\", Content, ExtendInfo, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,ExtendedFlag,MessageRaw,RealJid, ChatType) values(:MsgId, :XmppId, :From, :To, :Content, :ExtendInfo, :Platform, :Type, :State, :Direction, :LastUpdateTime, :ReadedTag,:ExtendedFlag,:MessageRaw,:RealJid, :ChatType);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:msgId?msgId:@":NULL"];
        [param addObject:xmppId?xmppId:@":NULL"];
        [param addObject:from?from:@":NULL"];
        [param addObject:to?to:@":NULL"];
        [param addObject:content?content:@":NULL"];
        [param addObject:extendInfo?extendInfo:@":NULL"];
        [param addObject:[NSNumber numberWithInt:platform]];
        [param addObject:[NSNumber numberWithInt:msgType]];
        [param addObject:[NSNumber numberWithInt:msgState]];
        [param addObject:[NSNumber numberWithInt:msgDirection]];
        [param addObject:[NSNumber numberWithLongLong:msgDate]];
        [param addObject:[NSNumber numberWithInt:0]];
        [param addObject:[NSNumber numberWithInt:0]];
        [param addObject:msgRaw?msgRaw:@":NULL"];
        [param addObject:realJid?realJid:@":NULL"];
        [param addObject:[NSNumber numberWithInteger:chatType]];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (BOOL)checkMsgId:(NSString *)msgId{
    __block BOOL flag = NO;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select 1 From IM_Message Where MsgId = :MsgId;";
        DataReader *reader = [database executeReader:sql withParameters:@[msgId]];
        if ([reader read]) {
            flag = YES;
        }
    }];
    return flag;
}

- (NSMutableArray *)qimDB_searchLocalMessageByKeyword:(NSString *)keyWord
                                               XmppId:(NSString *)xmppid
                                              RealJid:(NSString *)realJid {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select a.'From',a.Content,a.LastUpdateTime,b.Name,b.HeaderSrc,a.MsgId from IM_Message as a left join IM_User as b on a.'from' = b.Xmppid  where a.Content like '%%%@%%' and a.XmppId = '%@'  ORDER by a.LastUpdateTime desc limit 1000;",keyWord,xmppid];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *from = [reader objectForColumnIndex:0];
            double time = [[reader objectForColumnIndex:2]doubleValue];
            NSString *content = [reader objectForColumnIndex:1];
            NSString *nickName = [reader objectForColumnIndex:3];
            NSString *headUrl = [reader objectForColumnIndex:4];
            NSString *msgId = [reader objectForColumnIndex:5];
            
            NSString *date = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:time] qim_formattedDateDescription];
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:from forKey:@"from"];
            [IMDataManager safeSaveForDic:value setObject:date forKey:@"time"];
            [IMDataManager safeSaveForDic:value setObject:@(time) forKey:@"timeLong"];
            [IMDataManager safeSaveForDic:value setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:value setObject:nickName forKey:@"nickName"];
            [IMDataManager safeSaveForDic:value setObject:msgId forKey:@"msgId"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
        
    }];
    return [resultList autorelease];
}

#pragma mark - 插入群JSON消息
- (NSDictionary *)bulkInsertIphoneHistoryGroupJSONMsg:(NSArray *)list WihtMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WihtMyRtxId:(NSString *)rtxId WithAtAllMsgList:(NSMutableArray<NSDictionary *> **)atAllMsgList WithNormaleAtMsgList:(NSMutableArray <NSDictionary *> **)normalMsgList{
    
    QIMVerboseLog(@"群消息插入本地数据库数量 : %lld", list.count);
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSMutableDictionary *groupMsgTimeDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *msgList = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *fsMsgList = [[NSMutableArray alloc] init];
    NSMutableArray *updateMsgList = [[NSMutableArray alloc] init];
    if (!*normalMsgList) {
        *normalMsgList = [[NSMutableArray alloc] init];
    }
    if (!*atAllMsgList) {
        *atAllMsgList = [[NSMutableArray alloc] init];
    }
    for (NSDictionary *dic in list) {
        
        NSDictionary *message = [dic objectForKey:@"message"];
        NSDictionary *msgBody = [dic objectForKey:@"body"];
        if (msgBody) {
            int platform = 0;
            int msgType = [[msgBody objectForKey:@"msgType"] intValue];
            NSString *extendInfo = [msgBody objectForKey:@"extendInfo"];
            
            //红包消息详情，AA收款详情
            if (msgType == 1024 || msgType == 1025) {
                NSDictionary *infoDic = [self dictionaryWithJsonString:extendInfo];
                NSString *fId = [infoDic objectForKey:@"From_User"];
                NSString *openId = [infoDic objectForKey:@"Open_User"];
                
                if ([fId isEqualToString:rtxId] == NO || [openId isEqualToString:rtxId] == NO) {
                    continue;
                }
            }
            NSString *msgId = [msgBody objectForKey:@"id"];
            NSString *msg = [msgBody objectForKey:@"content"];
            if (msgType == -1) {
                //撤销消息
                [updateMsgList addObject:@{@"messageId":msgId?msgId:@"", @"message":msg?msg:@"该消息被撤回"}];
            }
            NSString *replyMsgId = [msgBody objectForKey:@"replyMsgId"];
            NSString *replyUser = [msgBody objectForKey:@"replyUser"];
            NSString *xmppId = [message objectForKey:@"to"];
            NSString *sendJid = [message objectForKey:@"sendjid"];
            NSString *compensateJid = [message objectForKey:@"from"];
            //默认取sendJid，revoke特殊一些，补偿取from
            compensateJid = (sendJid.length > 0) ? sendJid : compensateJid;
            long long msec_times = [[dic objectForKey:@"t"] doubleValue] * 1000;
            NSDate *date = nil;
            if (msec_times > 0) {
                
            } else {
                msec_times = [[message objectForKey:@"msec_times"] longLongValue];
            }
            date = [NSDate dateWithTimeIntervalSince1970:msec_times / 1000.0];
            if (date == nil) {
                date = [NSDate date];
            }
            platform = [self parserplatForm:[message objectForKey:@"client_type"]];
            long long lastGroupMsgDate = [[groupMsgTimeDic objectForKey:xmppId] longLongValue];
            if (lastGroupMsgDate < date.timeIntervalSince1970 - 60 * 2) {
                lastGroupMsgDate = date.timeIntervalSince1970;
                [groupMsgTimeDic setObject:@(lastGroupMsgDate) forKey:xmppId];
                NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
                [msgDic setObject:[self getTimeSmtapMsgIdForDate:date WithUserId:xmppId] forKey:@"MsgId"];
                [msgDic setObject:xmppId forKey:@"SessionId"];
                [msgDic setObject:@(101) forKey:@"MsgType"];
                [msgDic setObject:@(platform) forKey:@"Platform"];
                [msgDic setObject:@(0) forKey:@"MsgDirection"];
                [msgDic setObject:@(msec_times-1) forKey:@"MsgDateTime"];
                [msgDic setObject:@(16) forKey:@"MsgState"];
                [msgDic setObject:@(1) forKey:@"ReadedTag"];
                [msgDic setObject:@(1) forKey:@"ChatType"];
                [msgList addObject:msgDic];
            }
            if (msgId == nil) {
                msgId = [date description];
            }
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [msgDic setObject:msgId forKey:@"MsgId"];
            [msgDic setObject:xmppId forKey:@"SessionId"];
            [msgDic setObject:compensateJid?compensateJid:@"" forKey:@"From"];
            [msgDic setObject:rtxId?rtxId:@"" forKey:@"To"];
            [msgDic setObject:msg?msg:@"" forKey:@"Content"];
            [msgDic setObject:extendInfo?extendInfo:@"" forKey:@"ExtendInfo"];
            [msgDic setObject:@(platform) forKey:@"Platform"];
            int direction = ([rtxId isEqualToString:compensateJid]) ? 0 : 1;
            [msgDic setObject:@(direction) forKey:@"MsgDirection"];
            [msgDic setObject:@(msgType) forKey:@"MsgType"];
            [msgDic setObject:@(msec_times) forKey:@"MsgDateTime"];
            [msgDic setObject:@(1) forKey:@"ChatType"];
            NSInteger insertReadFlag = 0;
            if (msec_times <= readMarkT) {
                [msgDic setObject:@(didReadState) forKey:@"MsgState"];
                insertReadFlag = 1;
            } else {
                if (direction == 0) {
                    insertReadFlag = 1;
                    [msgDic setObject:@(2) forKey:@"MsgState"];
                } else {
                    insertReadFlag = 0;
                    [msgDic setObject:@(0) forKey:@"MsgState"];
                }
            }
            [msgDic setObject:@(insertReadFlag) forKey:@"ReadedTag"];
            NSData *xmlData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
            [msgDic setObject:xml?xml:@"" forKey:@"MsgRaw"];
            [msgList addObject:msgDic];
            [resultDic setObject:msgDic forKey:xmppId];
            
            if (direction == 1) {
                if ([msg rangeOfString:@"@"].location != NSNotFound) {
                    NSArray *array = [msg componentsSeparatedByString:@"@"];
                    BOOL hasAt = NO;
                    BOOL hasAtAll = NO;
                    for (NSString *str in array) {
                        if ([[str lowercaseString] hasPrefix:@"all"] || [str hasPrefix:@"全体成员"]) {
                            hasAtAll = YES;
                            break;
                        }
                        NSString *prefix = rtxId;
                        if (prefix && [str hasPrefix:prefix]) {
                            hasAt = YES;
                            break;
                        }
                    }
                    if (hasAtAll) {
                        [*atAllMsgList addObject:msgDic];
                    }
                    if (hasAt) {
                        [*normalMsgList addObject:msgDic];
                    }
                    [msgDic release];
                    msgDic = nil;
                }
            }
            if (replyMsgId) {
                NSMutableDictionary *fsMsgDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:msgId forKey:@"MsgId"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:compensateJid forKey:@"FromUser"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:replyMsgId forKey:@"ReplyMsgId"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:replyUser forKey:@"ReplyUser"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:msg forKey:@"Content"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:@(date.timeIntervalSince1970*1000) forKey:@"MsgDate"];
                [fsMsgList addObject:fsMsgDic];
                [fsMsgDic release];
                fsMsgDic = nil;
            }
        }
    }
    [self bulkInsertMessage:msgList];
    if (fsMsgList.count > 0) {
        [self bulkInsertFSMsgWithMsgList:fsMsgList];
    }
    if (updateMsgList.count > 0) {
        [self revokeMessageByMsgList:updateMsgList];
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"插入群消息历史记录%ld条，耗时%fs", msgList.count, end - start); //s
    return [resultDic autorelease];
}

//群翻页消息
- (NSArray *)bulkInsertIphoneMucJSONMsg:(NSArray *)list WihtMyNickName:(NSString *)myNickName WithReadMarkT:(long long)readMarkT WithDidReadState:(int)didReadState WihtMyRtxId:(NSString *)rtxId{
    
    NSMutableArray *msgList = [[NSMutableArray alloc] init];
    NSMutableArray *fsMsgList = [[NSMutableArray alloc] init];
    NSMutableArray *updateMsgList = [[NSMutableArray alloc] init];
    long long lastGroupMsgDate = 0;
    for (NSDictionary *dic in list) {
        
        NSDictionary *message = [dic objectForKey:@"message"];
        NSDictionary *msgBody = [dic objectForKey:@"body"];
        if (msgBody) {
            int platform = 0;
            int msgType = [[msgBody objectForKey:@"msgType"] intValue];
            NSString *extendInfo = [msgBody objectForKey:@"extendInfo"];
            if (msgType == 1024 || msgType == 1025) {
                NSDictionary *infoDic = [self dictionaryWithJsonString:extendInfo];
                NSString *fId = [infoDic objectForKey:@"From_User"];
                NSString *openId = [infoDic objectForKey:@"Open_User"];
                
                if ([fId isEqualToString:rtxId] == NO || [openId isEqualToString:rtxId] == NO) {
                    continue;
                }
            }
            NSString *sendJid = [message objectForKey:@"sendjid"];
            NSString *compensateJid = [message objectForKey:@"from"];
            compensateJid = (sendJid.length > 0) ? sendJid : compensateJid;
            NSString *msgId = [msgBody objectForKey:@"id"];
            NSString *msg = [msgBody objectForKey:@"content"];
            if (msgType == -1) {
                //撤销消息
                [updateMsgList addObject:@{@"messageId":msgId?msgId:@"", @"message":msg?msg:@"该消息被撤回"}];
            }
            NSString *replyMsgId = [msgBody objectForKey:@"replyMsgId"];
            NSString *replyUser = [msgBody objectForKey:@"replyUser"];
            //翻页消息Check下
            if ([self checkMsgId:msgId]) {
                continue;
            }
            NSString *xmppId = [message objectForKey:@"to"];
            long long msec_times = [[dic objectForKey:@"t"] doubleValue] * 1000;
            NSDate *date = nil;
            if (msec_times > 0) {
                
            } else {
                msec_times = [[message objectForKey:@"msec_times"] longLongValue];
            }
            date = [NSDate dateWithTimeIntervalSince1970:msec_times / 1000.0];
            if (date == nil) {
                date = [NSDate date];
            }
            platform = [self parserplatForm:[message objectForKey:@"client_type"]];
            
            if (lastGroupMsgDate < date.timeIntervalSince1970 - 60 * 2) {
                lastGroupMsgDate = date.timeIntervalSince1970;
                NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
                [msgDic setObject:[self getTimeSmtapMsgIdForDate:date WithUserId:xmppId] forKey:@"MsgId"];
                [msgDic setObject:xmppId forKey:@"SessionId"];
                [msgDic setObject:@(101) forKey:@"MsgType"];
                [msgDic setObject:@(platform) forKey:@"Platform"];
                [msgDic setObject:@(0) forKey:@"MsgDirection"];
                [msgDic setObject:@(msec_times-1) forKey:@"MsgDateTime"];
                [msgDic setObject:@(16) forKey:@"MsgState"];
                [msgDic setObject:@(1) forKey:@"ReadedTag"];
                [msgDic setObject:@(1) forKey:@"ChatType"];
                [msgList addObject:msgDic];
            }
            if (msgId == nil) {
                msgId = [date description];
            }
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [msgDic setObject:msgId forKey:@"MsgId"];
            [msgDic setObject:xmppId forKey:@"SessionId"];
            [msgDic setObject:compensateJid?compensateJid:@"" forKey:@"From"];
            [msgDic setObject:rtxId?rtxId:@"" forKey:@"To"];
            [msgDic setObject:msg?msg:@"" forKey:@"Content"];
            [msgDic setObject:extendInfo?extendInfo:@"" forKey:@"ExtendInfo"];
            [msgDic setObject:@(platform) forKey:@"Platform"];
            int direction = ([compensateJid isEqualToString:rtxId]) ? 0 : 1;
            [msgDic setObject:@(direction) forKey:@"MsgDirection"];
            [msgDic setObject:@(msgType) forKey:@"MsgType"];
            [msgDic setObject:@(msec_times) forKey:@"MsgDateTime"];
            [msgDic setObject:@(1) forKey:@"ChatType"];
            NSInteger insertReadFlag = 0;
            if (msec_times <= readMarkT) {
                [msgDic setObject:@(didReadState) forKey:@"MsgState"];
                insertReadFlag = 1;
            } else {
                if (direction == 0) {
                    insertReadFlag = 1;
                    [msgDic setObject:@(2) forKey:@"MsgState"];
                } else {
                    insertReadFlag = 0;
                    [msgDic setObject:@(0) forKey:@"MsgState"];
                }
            }
            [msgDic setObject:@(insertReadFlag) forKey:@"ReadedTag"];
            NSData *xmlData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
            [msgDic setObject:xml?xml:@"" forKey:@"MsgRaw"];
            [msgList addObject:msgDic];
            if (replyMsgId) {
                NSMutableDictionary *fsMsgDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:msgId forKey:@"MsgId"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:compensateJid forKey:@"FromUser"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:replyMsgId forKey:@"ReplyMsgId"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:replyUser forKey:@"ReplyUser"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:msg forKey:@"Content"];
                [IMDataManager safeSaveForDic:fsMsgDic setObject:@(date.timeIntervalSince1970*1000) forKey:@"MsgDate"];
                [fsMsgList addObject:fsMsgDic];
                [fsMsgDic release];
                fsMsgDic = nil;
            }
        }
    }
    [self bulkInsertMessage:msgList];
    if (fsMsgList.count > 0) {
        [self bulkInsertFSMsgWithMsgList:fsMsgList];
    }
    if (updateMsgList.count > 0) {
        [self revokeMessageByMsgList:updateMsgList];
    }
    return [msgList autorelease];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        QIMVerboseLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 插入离线单人JSON消息
 
 @param list 消息数组
 @param meJid 自身Id
 @param didReadState 是否已读
 */
#pragma mark - 插入离线单人JSON消息
- (NSMutableDictionary *)bulkInsertHistoryChatJSONMsg:(NSArray *)list
                                                   to:(NSString *)meJid
                                     WithDidReadState:(int)didReadState{
    QIMVerboseLog(@"插入离线单人JSON消息数量 : %lu", (unsigned long)list.count);
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *updateMsgList = [[NSMutableArray alloc] init];
    NSMutableArray *insertMsgList = [[NSMutableArray alloc] init];
    NSMutableArray *collectionOriginMsgList = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in list) {
        NSMutableDictionary *result = nil;
        NSString *key = nil;
//        NSMutableArray *msgList = nil;
        long long lastDate = 0;
        NSString *realJid = nil;
        NSString *userId = nil;
        
        NSString *from = [dic objectForKey:@"from"];
        NSString *fromDomain = [dic objectForKey:@"from_host"];
        NSString *fromJid = [from stringByAppendingFormat:@"@%@", fromDomain ? fromDomain : _domain];
        NSString *to = [dic objectForKey:@"to"];
        NSString *toDomain = [dic objectForKey:@"to_host"];
        NSString *toJid = [to stringByAppendingFormat:@"@%@", toDomain ? toDomain : _domain];
        NSDictionary *message = [dic objectForKey:@"message"];
        
        
        NSString *type = nil;
        NSString *client_type = nil;
        BOOL systemMessage = NO;
        if (message) {
            type = [message objectForKey:@"type"];
            client_type = [message objectForKey:@"client_type"];
        }
        if ([type isEqualToString:@"headline"]) {
            from = @"SystemMessage";
            systemMessage = YES;
            fromJid = [from stringByAppendingFormat:@"@%@", fromDomain?fromDomain:_domain];
        }
        NSDictionary *msgBody = [dic objectForKey:@"body"];
        if (msgBody != nil) {
            
            NSString *extendInfo = [msgBody objectForKey:@"extendInfo"];
            int msgType = [[msgBody objectForKey:@"msgType"] intValue];
            
            //Message
            NSString *msgId = [msgBody objectForKey:@"id"];
            NSString *chatId = [message objectForKey:@"qchatid"];
            if (chatId == nil) {
                chatId = [message objectForKey:@"chatid"];
            }
            if (chatId == nil) {
                chatId = @"4";
            }
            NSInteger platForm = [self parserplatForm:client_type];
            BOOL isConsult = NO;
            if (msgId == nil) {
                msgId = [self UUID];
            }
            NSString *msg = [msgBody objectForKey:@"content"];
            NSString *channelInfo = [message objectForKey:@"channelInfo"];
            
            if ([type isEqualToString:@"revoke"]) {
                [updateMsgList addObject:@{@"messageId":msgId?msgId:@"", @"message":msg?msg:@"该消息已被撤回"}];
            } else if ([type isEqualToString:@"collection"]) {
                
                NSString *originFrom = [message objectForKey:@"originfrom"];
                NSString *originTo = [message objectForKey:@"originto"];
                NSString *originType = [message objectForKey:@"origintype"];
                NSDictionary *originMessageDict = @{@"Originfrom":originFrom?originFrom:originFrom, @"Originto":originTo?originTo:@"", @"Origintype":originType?originType:@"chat", @"MsgId":msgId?msgId:@""};
                [collectionOriginMsgList addObject:originMessageDict];
            } else {
                
            }
            
            if (msgType == 1024) {
                chatId = @"4";
            } else if (msgType == 1002) {
                chatId = @"4";
            }
            
            if ([type isEqualToString:@"note"]) {
                msgType = -11;
            } else if ([type isEqualToString:@"consult"]) {
                isConsult = YES;
            }else if (![type isEqualToString:@"chat"] && ![type isEqualToString:@"revoke"] && ![type isEqualToString:@"subscription"] && ![type isEqualToString:@"headline"] && ![type isEqualToString:@"collection"]){
                continue;
            }
            
            // 初始化缓存结构
            int direction = 0;
            if ([fromJid isEqualToString:meJid]) {
                if (isConsult) {
                    NSString *realTo = [message objectForKey:@"realto"];
                    // 自己发的
                    realJid = [realTo componentsSeparatedByString:@"/"].firstObject;
                    if (chatId.intValue == 4) {
                        key = [[NSString stringWithFormat:@"%@-%@",toJid,toJid] retain];
                    } else {
                        key = [[NSString stringWithFormat:@"%@-%@",toJid,realJid] retain];
                    }
                    userId = toJid;
                } else {
                    key = [toJid retain];
                }
                direction = 0;
                result = [[resultDic objectForKey:key] retain];
                if (result == nil) {
                    result = [[NSMutableDictionary alloc] init];
                    if (key) {
                        [resultDic setObject:result forKey:key];
                    }
                }
                if (msgType == 1003 || msgType == 1004) {
                    continue;
                } else if (msgType == 1004) {
                    chatId = @"5";
                } else if (msgType == 1002) {
                    chatId = @"5";
                    NSString *content = extendInfo.length > 0?extendInfo:msg;
                    NSDictionary *contentDic = [self dictionaryWithJsonString:content];
                    realJid = [contentDic objectForKey:@"u"];
                }
            } else {
                direction = 1;
                if (isConsult) {
                    NSString *realfrom = [message objectForKey:@"realfrom"];
                    // 自己收的
                    if (msgType == 1004) {
                        NSString *content = extendInfo.length>0?extendInfo:msg;
                        NSDictionary *infoDic = [self dictionaryWithJsonString:content];
                        realJid = [infoDic objectForKey:@"u"];
                    } else {
                        realJid = [realfrom componentsSeparatedByString:@"/"].firstObject;
                    }
                    if (chatId.intValue == 4) {
                        key = [[NSString stringWithFormat:@"%@-%@",fromJid,realJid] retain];
                    } else {
                        key = [[NSString stringWithFormat:@"%@-%@",fromJid,fromJid] retain];
                    }
                    userId = fromJid;
                } else {
                    key = [fromJid retain];
                }
                result = [[resultDic objectForKey:key] retain];
                if (result == nil) {
                    result = [[NSMutableDictionary alloc] init];
                    if (key) {
                        [resultDic setObject:result forKey:key];
                    }
                }
                if (msgType == 1004) {
                    // 转移会话给同事的回馈 但是 显示位置不应该在两个同事之间的会话 所以换from 并且 去除 多点登陆时候的产生的多余消息
                    chatId = @"4";
                    NSString *content = extendInfo.length > 0?extendInfo:msg;
                    NSDictionary *contentDic = [self dictionaryWithJsonString:content];
                    realJid = [contentDic objectForKey:@"u"];
                } else if (msgType == 1002) {
                    chatId = @"4";
                    NSString *content = extendInfo.length > 0?extendInfo:msg;
                    NSDictionary *contentDic = [self dictionaryWithJsonString:content];
                    realJid = [contentDic objectForKey:@"u"];
                    continue;
                }
            }
            lastDate = [[result objectForKey:@"lastDate"] longLongValue];
            NSDate *date = nil;
            long long msecTime = [[dic objectForKey:@"t"] doubleValue] * 1000.0;
            if (msecTime > 0) {
                date = [NSDate dateWithTimeIntervalSince1970:msecTime / 1000.0];
            } else {
                msecTime = [[message objectForKey:@"msec_times"] longLongValue];
                if (msecTime > 0) {
                   date = [NSDate dateWithTimeIntervalSince1970:msecTime / 1000.0];
                } else {
                    NSString *stampValue = [dic[@"time"] objectForKey:@"stamp"];
                    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                    NSDate *date1 = [dateFormatter dateFromString:stampValue];
                    if (date1) {
                        date = date1;
                    }
                }
            }
            if (date == nil) {
                date = [NSDate date];
            }
            if (lastDate / 1000.0 < date.timeIntervalSince1970 - 60 * 2 || lastDate == 0 && msgType != 2004) {
                lastDate = date.timeIntervalSince1970 * 1000;
                NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
                [msgDic setObject:[self getTimeSmtapMsgIdForDate:date WithUserId:key] forKey:@"MsgId"];
                [msgDic setObject:isConsult?userId:key forKey:@"SessionId"];
                [msgDic setObject:@(101) forKey:@"MsgType"];
                [msgDic setObject:@(platForm) forKey:@"Platform"];
                [msgDic setObject:@(0) forKey:@"MsgDirection"];
                [msgDic setObject:@(msecTime - 1) forKey:@"MsgDateTime"];
                [msgDic setObject:@(16) forKey:@"MsgState"];
                [msgDic setObject:@(1) forKey:@"ReadedTag"];
                [msgDic setObject:systemMessage ? @(2) : @(0) forKey:@"ChatType"];
                if (isConsult) {
                    if (direction == 0) {
                        if (chatId.intValue == 5) {
                            if (realJid) {
                                [msgDic setObject:realJid forKey:@"RealJid"];
                            }
                        } else {
                            if (userId) {
                                [msgDic setObject:userId forKey:@"RealJid"];
                            }
                        }
                    } else {
                        if (chatId.intValue == 5) {
                            if (userId) {
                                [msgDic setObject:userId forKey:@"RealJid"];
                            }
                        } else {
                            if (realJid) {
                                [msgDic setObject:realJid forKey:@"RealJid"];
                            }
                        }
                    }
                }
                [insertMsgList addObject:msgDic];
            }
            if (msgId==nil) {
                msgId = [date description];
            }
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [msgDic setObject:msgId forKey:@"MsgId"];
            [msgDic setObject:isConsult?userId:key forKey:@"SessionId"];
            NSString *realXmppId = realJid?realJid:from;
            if ([type isEqualToString:@"collection"]) {
                NSString *originFrom = [message objectForKey:@"originfrom"];
                NSString *realfrom = [message objectForKey:@"realfrom"];
                realXmppId = realfrom.length?realfrom:originFrom;
                [msgDic setObject:realXmppId forKey:@"From"];
            } else {
                [msgDic setObject:(isConsult && direction == 1) ? realXmppId : fromJid forKey:@"From"];
            }
            [msgDic setObject:toJid?toJid:@"" forKey:@"To"];
            [msgDic setObject:@(platForm) forKey:@"Platform"];
            [msgDic setObject:@(direction) forKey:@"MsgDirection"];
            [msgDic setObject:@(msgType) forKey:@"MsgType"];
            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
            [msgDic setObject:dic?dic:@"" forKey:@"MsgRaw"];
            [pool drain];
            if (channelInfo) {
                [msgDic setObject:channelInfo forKey:@"channelid"];
            }
            [msgDic setObject:msg forKey:@"Content"];
            [msgDic setObject:extendInfo?extendInfo:@"" forKey:@"ExtendInfo"];
            [result setObject:@(msecTime) forKey:@"lastDate"];
            [msgDic setObject:@(msecTime) forKey:@"MsgDateTime"];
            [msgDic setObject:systemMessage ? @(2) : @(0) forKey:@"ChatType"];
            NSInteger readFlag = [[dic objectForKey:@"read_flag"] integerValue];
            NSInteger msgState = 0;
            if (readFlag == 0) {
                msgState = 0;   //第一次拉回来的离线历史消息，假如之前没有同步过已送达状态，暂时设置MsgState = 0，之后更新
            } else if (readFlag == 1) {
                msgState = 15;
            } else if (readFlag == 3) {
                msgState = didReadState;
            }
            if (readFlag == 3) {
                readFlag = 1;
            } else {
                readFlag = 0;
            }
            [msgDic setObject:@(msgState) forKey:@"MsgState"];
            [msgDic setObject:@(readFlag) forKey:@"ReadedTag"];
            if (isConsult) {
                [result setObject:@(YES) forKey:@"Consult"];
                if (userId) {
                    [result setObject:userId forKey:@"UserId"];
                }
                if (direction == 0) {
                    if (chatId.intValue == ConsultServerChat) {
                        [result setObject:@(ConsultServerChat) forKey:@"ChatType"];
                        if (realJid) {
                            [msgDic setObject:realJid forKey:@"RealJid"];
                            [result setObject:realJid forKey:@"RealJid"];
                        }
                    } else {
                        [result setObject:@(ConsultChat) forKey:@"ChatType"];
                        if (userId) {
                            [msgDic setObject:userId forKey:@"RealJid"];
                            [result setObject:userId forKey:@"RealJid"];
                        }
                    }
                } else {
                    if (chatId.intValue == ConsultServerChat) {
                        [result setObject:@(ConsultChat) forKey:@"ChatType"];
                        if (userId) {
                            [msgDic setObject:userId forKey:@"RealJid"];
                            [result setObject:userId forKey:@"RealJid"];
                        }
                    } else {
                        [result setObject:@(ConsultServerChat) forKey:@"ChatType"];
                        if (realJid) {
                            [msgDic setObject:realJid forKey:@"RealJid"];
                            [result setObject:realJid forKey:@"RealJid"];
                        }
                    }
                }
            }
            [insertMsgList addObject:msgDic];
            [msgDic release];
            msgDic = nil;
        }
    }
    [self bulkInsertMessage:insertMsgList];
    if (updateMsgList.count > 0) {
        [self revokeMessageByMsgList:updateMsgList];
    }
    if (collectionOriginMsgList.count > 0) {
        [self bulkInsertCollectionMsgWihtMsgDics:collectionOriginMsgList];
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"插入单人历史消息%ld条， 耗时 = %f s", insertMsgList.count, end - start); //s
    [insertMsgList release];
    [updateMsgList release];
    return [resultDic autorelease];
}

- (NSString *)getC2BMessageFeedBackWithMsgId:(NSString *)msgId {
    
    __block NSString *c2BMessageFeedBackStr = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"Select Content from IM_Message Where Type = 2004 AND Content like '%%%@%%';", msgId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            c2BMessageFeedBackStr = [[reader objectForColumnIndex:0] retain];
        }
    }];
    return [c2BMessageFeedBackStr autorelease];
}

#pragma mark - 单人JSON历史消息翻页
- (NSArray *)bulkInsertHistoryChatJSONMsg:(NSArray *)list
                               WithXmppId:(NSString *)xmppId
                         WithDidReadState:(int)didReadState{
#pragma mark - bulkInsertHistoryChatJSONMsg JSOn
    NSMutableArray *msgList = [[NSMutableArray alloc] init];
    NSMutableArray *updateMsgList = [[NSMutableArray alloc] init];
    NSMutableArray *insertMsgList = [[NSMutableArray alloc] init];
    long long lastDate = 0;
    for (NSDictionary *dic in list) {
        NSString *key = nil;
        NSString *realJid = nil;
        NSString *userId = nil;
        
        NSString *from = [dic objectForKey:@"from"];
        NSString *fromDomain = [dic objectForKey:@"from_host"];
        NSString *fromJid = [from stringByAppendingFormat:@"@%@", fromDomain ? fromDomain : _domain];
        NSString *to = [dic objectForKey:@"to"];
        NSString *toDomain = [dic objectForKey:@"to_host"];
        NSString *toJid = [to stringByAppendingFormat:@"@%@", toDomain ? toDomain : _domain];
        NSDictionary *message = [dic objectForKey:@"message"];
        
        NSString *type = nil;
        NSString *client_type = nil;
        
        BOOL systemMessage = NO;
        if (message) {
            type = [message objectForKey:@"type"];
            client_type = [message objectForKey:@"client_type"];
        }
        if ([type isEqualToString:@"headline"]) {
            from = @"SystemMessage";
            systemMessage = YES;
            fromJid = [from stringByAppendingFormat:@"@%@", fromDomain?fromDomain:_domain];
        }
        
        NSDictionary *msgBody = [dic objectForKey:@"body"];
        if (msgBody) {
            NSString *extendInfo = [msgBody objectForKey:@"extendInfo"];
            int msgType = [[msgBody objectForKey:@"msgType"] intValue];
            
            //Message
            NSString *msgId = [msgBody objectForKey:@"id"];
            NSString *chatId = [message objectForKey:@"qchatid"];
            if (chatId == nil) {
                chatId = [message objectForKey:@"chatid"];
            }
            if (chatId == nil) {
                chatId = @"4";
            }
            NSInteger platForm = [self parserplatForm:client_type];
            BOOL isConsult = NO;
            if (msgId == nil) {
                msgId = [self UUID];
            }
            NSString *msg = [msgBody objectForKey:@"content"];
            long long msecTime = [[message objectForKey:@"msec_times"] longLongValue];
            NSString *channelInfo = [message objectForKey:@"channelInfo"];
            
            if ([type isEqualToString:@"revoke"]) {
                [updateMsgList addObject:@{@"messageId":msgId?msgId:@"", @"message":msg?msg:@"该消息已被撤回"}];
            } else {
                
            }
            
            if (msgType == 1024) {
                chatId = @"4";
            } else if (msgType == 1002) {
                chatId = @"4";
            }
            
            if ([type isEqualToString:@"note"]) {
                msgType = -11;
            } else if ([type isEqualToString:@"consult"]) {
                isConsult = YES;
            } else if (![type isEqualToString:@"chat"] && ![type isEqualToString:@"revoke"] && ![type isEqualToString:@"subscription"] && ![type isEqualToString:@"headline"] && ![type isEqualToString:@"collection"]){
                continue;
            }
            
            // 初始化缓存结构
            int direction = 0;
            if (isConsult) {
                NSString *realXmppFrom = [[[message objectForKey:@"realfrom"] componentsSeparatedByString:@"@"] firstObject];
                NSString *realXmppTo = [message objectForKey:@"realto"];
                if ([realXmppFrom isEqualToString:self.userId]) {
                    //自己发的
                    if (chatId.intValue == 4) {
                        key = [[NSString stringWithFormat:@"%@-%@",toJid,toJid] retain];
                    } else {
                        key = [[NSString stringWithFormat:@"%@-%@",toJid,realJid] retain];
                    }
                    direction = 0;
                    if (msgType == 1003 || msgType == 1004) {
                        continue;
                    } else if (msgType == 1004) {
                        chatId = @"5";
                    } else if (msgType == 1002) {
                        chatId = @"5";
                        NSString *content = extendInfo.length > 0?extendInfo:msg;
                        NSDictionary *contentDic = [self dictionaryWithJsonString:content];
                        realJid = [contentDic objectForKey:@"u"];
                    } else {
                        realJid = realXmppTo;
                    }
                } else {
                    direction = 1;
                    NSString *realfrom = @"";
                    if (chatId.intValue == 4) {
                        realfrom = [message objectForKey:@"realfrom"];
                    } else {
                        realfrom = [message objectForKey:@"realto"];
                    }
                    // 自己收的
                    if (msgType == 1004) {
                        NSString *content = extendInfo.length>0?extendInfo:msg;
                        NSDictionary *infoDic = [self dictionaryWithJsonString:content];
                        realJid = [infoDic objectForKey:@"u"];
                    } else {
                        realJid = [realfrom componentsSeparatedByString:@"/"].firstObject;
                    }
                    if (chatId.intValue == 4) {
                        key = [[NSString stringWithFormat:@"%@-%@",fromJid,realJid] retain];
                    } else {
                        key = [[NSString stringWithFormat:@"%@-%@",fromJid,fromJid] retain];
                    }
                    userId = fromJid;
                    if (msgType == 1004) {
                        // 转移会话给同事的回馈 但是 显示位置不应该在两个同事之间的会话 所以换from 并且 去除 多点登陆时候的产生的多余消息
                        chatId = @"4";
                        NSString *content = extendInfo.length > 0?extendInfo:msg;
                        NSDictionary *contentDic = [self dictionaryWithJsonString:content];
                        realJid = [contentDic objectForKey:@"u"];
                    } else if (msgType == 1002) {
                        chatId = @"4";
                        NSString *content = extendInfo.length > 0?extendInfo:msg;
                        NSDictionary *contentDic = [self dictionaryWithJsonString:content];
                        realJid = [contentDic objectForKey:@"u"];
                        continue;
                    }
                }
            } else {
                if ([xmppId isEqualToString:fromJid] == NO) {
                    
                    key = [toJid retain];
                    direction = 0;
                } else {
                    direction = 1;
                    key = [fromJid retain];
                }
            }
            
            NSDate *date = nil;
            if (msecTime > 0) {
                date = [NSDate dateWithTimeIntervalSince1970:msecTime / 1000.0];
            } else {
                NSString *stampValue = [dic[@"time"] objectForKey:@"stamp"];
                //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                NSDate *date1 = [dateFormatter dateFromString:stampValue];
                if (date1) {
                    date = date1;
                }
            }
            if (date == nil) {
                date = [NSDate date];
            }
            
            if (lastDate < date.timeIntervalSince1970 - 60 * 2 && msgType != 2004) {
                lastDate = date.timeIntervalSince1970;
                NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
                [msgDic setObject:[self getTimeSmtapMsgIdForDate:date WithUserId:key] forKey:@"MsgId"];
                [msgDic setObject:isConsult?xmppId:key forKey:@"SessionId"];
                [msgDic setObject:@(101) forKey:@"MsgType"];
                [msgDic setObject:@(platForm) forKey:@"Platform"];
                [msgDic setObject:@(0) forKey:@"MsgDirection"];
                [msgDic setObject:@(date.timeIntervalSince1970*1000-1) forKey:@"MsgDateTime"];
                [msgDic setObject:@(16) forKey:@"MsgState"];
                [msgDic setObject:@(1) forKey:@"ReadedTag"];
                [msgDic setObject:systemMessage ? @(2) : @(0) forKey:@"ChatType"];
                if (isConsult) {
                    if (direction == 0) {
                        if (chatId.intValue == 5) {
                            if (realJid) {
                                [msgDic setObject:realJid forKey:@"RealJid"];
                            }
                        } else {
                            if (userId) {
                                [msgDic setObject:userId forKey:@"RealJid"];
                            }
                        }
                    } else {
                        if (chatId.intValue == 5) {
                            if (userId) {
                                [msgDic setObject:userId forKey:@"RealJid"];
                            }
                        } else {
                            if (realJid) {
                                [msgDic setObject:realJid forKey:@"RealJid"];
                            }
                        }
                    }
                }
                [msgList addObject:msgDic];
                [insertMsgList addObject:msgDic];
            }
            if (msgId==nil) {
                msgId = [date description];
            }
            NSMutableDictionary *msgDic = [NSMutableDictionary dictionary];
            [msgDic setObject:msgId forKey:@"MsgId"];
            [msgDic setObject:isConsult?xmppId:key forKey:@"SessionId"];
            NSString *realXmppId = realJid?realJid:fromJid;
//            realXmppId = [[realXmppId componentsSeparatedByString:@"@"] firstObject];
            NSString *realXmppFrom = [[[message objectForKey:@"realfrom"] componentsSeparatedByString:@"@"] firstObject];
            NSString *realXmppTo = [[[message objectForKey:@"realto"] componentsSeparatedByString:@"@"] firstObject];
            if ([type isEqualToString:@"collection"]) {
                NSString *originFrom = [message objectForKey:@"originfrom"];
                NSString *realfrom = [message objectForKey:@"realfrom"];
                realXmppId = realfrom.length?realfrom:originFrom;
                [msgDic setObject:realXmppId forKey:@"From"];
            } else {
                [msgDic setObject:(isConsult && direction == 1) ?realXmppFrom:realXmppId forKey:@"From"];
            }
            [msgDic setObject:realXmppTo?realXmppTo:to forKey:@"To"];
            [msgDic setObject:@(platForm) forKey:@"Platform"];
            [msgDic setObject:@(direction) forKey:@"MsgDirection"];
            [msgDic setObject:@(msgType) forKey:@"MsgType"];
            [msgDic setObject:systemMessage ? @(2) : @(0) forKey:@"ChatType"];
//            NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//            NSData *msgRawData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//            NSString *msgRaw = [[NSString alloc] initWithData:msgRawData encoding:NSUTF8StringEncoding];
            [msgDic setObject:dic?dic:@"" forKey:@"MsgRaw"];
            if (channelInfo) {
                [msgDic setObject:channelInfo forKey:@"channelid"];
            }
//            [msgRaw release];
//            msgRaw = nil;
//            [pool drain];
            /*
            if (msgType == 2004) {
                msg = extendInfo.length > 0 ? extendInfo : msg;
            }
            */
            [msgDic setObject:msg forKey:@"Content"];
            [msgDic setObject:extendInfo?extendInfo:@"" forKey:@"ExtendInfo"];
            [msgDic setObject:@(date.timeIntervalSince1970*1000) forKey:@"MsgDateTime"];
            NSInteger readFlag = [[dic objectForKey:@"read_flag"] integerValue];
            NSInteger msgState = 0;
            if (readFlag == 0) {
                msgState = 0;   //第一次拉回来的离线历史消息，假如之前没有同步过已送达状态，暂时设置MsgState = 0，之后更新
            } else if (readFlag == 1) {
                msgState = 15;
            } else if (readFlag == 3) {
                msgState = didReadState;
            }
            if (readFlag == 3) {
                readFlag = 1;
            } else {
                readFlag = 0;
            }
            [msgDic setObject:@(msgState) forKey:@"MsgState"];
            [msgDic setObject:@(readFlag) forKey:@"ReadedTag"];
            if (channelInfo) {
                [msgDic setObject:channelInfo forKey:@"channelid"];
            }
            if (isConsult) {
                if (direction == 0) {
                    //                    if (chatId.intValue == 5) {
                    if (realJid) {
                        [msgDic setObject:realJid forKey:@"RealJid"];
                    }
                    //                    } else {
                    //                        if (xmppId) {
                    //                            [msgDic setObject:xmppId forKey:@"RealJid"];
                    //                        }
                    //                    }
                } else {
                    //                    if (chatId.intValue == 5) {
                    //                        if (xmppId) {
                    //                            [msgDic setObject:xmppId forKey:@"RealJid"];
                    //                        }
                    //                    } else {
                    if (realJid) {
                        [msgDic setObject:realJid forKey:@"RealJid"];
                    }
                    //                    }
                }
            }
            [msgList addObject:msgDic];
        }
    }
    [self bulkInsertMessage:msgList WihtSessionId:xmppId];
    return [msgList autorelease];
}

- (void) bulkInsertMessage:(NSArray *)msgList {
    if (msgList.count <= 0) {
        return;
    }
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"insert or IGNORE into IM_Message(MsgId, XmppId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,MessageRaw,RealJid, ChatType, ExtendInfo) values(:MsgId, :XmppId, :From, :To, :Content, :Platform, :Type, :State, :Direction, :LastUpdateTime, :ReadedTag,:MessageRaw,:RealJid, :ChatType, :ExtendInfo);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *msgDic in msgList) {
            NSString *msgId = [msgDic objectForKey:@"MsgId"];
            NSString *sessionId = [msgDic objectForKey:@"SessionId"];
            NSString *from = [msgDic objectForKey:@"From"];
            NSString *to = [msgDic objectForKey:@"To"];
            NSString *content = [msgDic objectForKey:@"Content"];
            NSNumber *platform = [msgDic objectForKey:@"Platform"];
            NSNumber *msgType = [msgDic objectForKey:@"MsgType"];
            NSNumber *msgState = [msgDic objectForKey:@"MsgState"];
            NSNumber *msgDirection = [msgDic objectForKey:@"MsgDirection"];
            NSNumber *lastUpdateTime = [msgDic objectForKey:@"MsgDateTime"];
            NSNumber *readedTag = [msgDic objectForKey:@"ReadedTag"];
            NSString *msgRaw = [msgDic objectForKey:@"MsgRaw"];
            NSString *realJid = [msgDic objectForKey:@"RealJid"];
            NSNumber *chatType = [msgDic objectForKey:@"ChatType"];
            NSString *extendInfo = [msgDic objectForKey:@"ExtendInfo"];
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:msgId?msgId:@":NULL"];
            [param addObject:sessionId?sessionId:@":NULL"];
            [param addObject:from?from:@":NULL"];
            [param addObject:to?to:@":NULL"];
            [param addObject:content?content:@":NULL"];
            [param addObject:platform];
            [param addObject:msgType];
            [param addObject:msgState];
            [param addObject:msgDirection];
            [param addObject:lastUpdateTime];
            [param addObject:readedTag];
            [param addObject:msgRaw?msgRaw:@":NULL"];
            [param addObject:realJid?realJid:@":NULL"];
            [param addObject:chatType];
            [param addObject:extendInfo?extendInfo:@":NULL"];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
        
    }];
    QIMVerboseLog(@"插入%ld条消息， 耗时 : %lf", msgList.count, [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
}

// msg Key
- (void)bulkInsertMessage:(NSArray *)msgList WihtSessionId:(NSString *)sessionId{
    
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    [[self dbInstance] usingTransaction:^(Database *database) {
        
        NSString *sql = @"insert or IGNORE into IM_Message(MsgId, XmppId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,MessageRaw, RealJid, ExtendInfo) values(:MsgId, :XmppId, :From, :To, :Content, :Platform, :Type, :State, :Direction, :LastUpdateTime, :ReadedTag,:MessageRaw, :RealJid, :ExtendInfo);";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (NSDictionary *msgDic in msgList) {
            NSString *msgId = [msgDic objectForKey:@"MsgId"];
            NSString *sessionId = [msgDic objectForKey:@"SessionId"];
            NSString *from = [msgDic objectForKey:@"From"];
            NSString *to = [msgDic objectForKey:@"To"];
            NSString *content = [msgDic objectForKey:@"Content"];
            NSNumber *platform = [msgDic objectForKey:@"Platform"];
            NSNumber *msgType = [msgDic objectForKey:@"MsgType"];
            NSNumber *msgState = [msgDic objectForKey:@"MsgState"];
            NSNumber *msgDirection = [msgDic objectForKey:@"MsgDirection"];
            NSNumber *lastUpdateTime = [msgDic objectForKey:@"MsgDateTime"];
            NSNumber *readedTag = [msgDic objectForKey:@"ReadedTag"];
            NSString *msgRaw = [msgDic objectForKey:@"MsgRaw"];
            NSString *realJid = [msgDic objectForKey:@"RealJid"];
            NSString *extendInfo = [msgDic objectForKey:@"ExtendInfo"];
            
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:msgId?msgId:@":NULL"];
            [param addObject:sessionId?sessionId:@":NULL"];
            [param addObject:from?from:@":NULL"];
            [param addObject:to?to:@":NULL"];
            [param addObject:content?content:@":NULL"];
            [param addObject:platform];
            [param addObject:msgType];
            [param addObject:msgState];
            [param addObject:msgDirection];
            [param addObject:lastUpdateTime];
            [param addObject:readedTag];
            [param addObject:msgRaw?msgRaw:@":NULL"];
            [param addObject:realJid?realJid:@":NULL"];
            [param addObject:extendInfo?extendInfo:@":NULL"];
            [params addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
    QIMVerboseLog(@"插入会话%@ %ld条消息， 耗时 : %lf",sessionId, msgList.count, [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
}

- (void)updateMsgState:(int)msgState WithMsgId:(NSString *)msgId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Update IM_Message Set State = :State Where MsgId = :MsgId;";
        [database executeNonQuery:sql withParameters:[NSArray arrayWithObjects:@(msgState), msgId, nil]];
    }];
}

- (void)updateMsgDate:(long long)msgDate WithMsgId:(NSString *)msgId{
    if (msgDate <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set LastUpdateTime = :LastUpdateTime Where MsgId = :MsgId;";
        [database executeNonQuery:sql withParameters:[NSArray arrayWithObjects:@(msgDate),msgId, nil]];
    }];
}

// 0 未读 1是读过了
- (void)updateMessageReadStateWithMsgId:(NSString *)msgId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set ReadedTag = 1 Where  MsgId = :MsgId;";
        [database executeNonQuery:sql withParameters:[NSArray arrayWithObjects:msgId, nil]];
    }];
}

//批量更新消息阅读状态
- (void)bulkUpdateMessageReadStateWithMsg:(NSArray *)msgs {
    if (msgs.count <= 0) {
        return;
    }
    
    //    0 - 已发送， 更新MsgState = MessageSuccess
    //    1 - 已送达, 更新MsgState = MessageNotRead
    //    0， 1 - 对方未读， 更新ReadFlag = 0
    //    3 - 对方已读，更新readFlag = 1， 更新msgState = MessgaeRead
    
    QIMVerboseLog(@"批量更新消息阅读状态 : %@", msgs);
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set ReadedTag = :ReadedTag, State = :State1 Where MsgId=:MsgId And State < :State2;";
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *msgInfo in msgs) {
            NSString *msgId = [msgInfo objectForKey:@"msgid"];
            NSInteger readFlag = [[msgInfo objectForKey:@"readflag"] integerValue];
            NSInteger msgState = 0;
            NSString *msgStateLog = @"";
            if (readFlag == 0) {
                msgState = 2;      //只送达至服务器，未送达至对方用户
                msgStateLog = @"已送达至服务器，但未送达至对方用户";
            } else if (readFlag == 1) {
                msgState = 15;      //已送达，对方未读
                msgStateLog = @"已成功送达至对方用户，对方未读";
            } else if (readFlag == 3) {
                msgState = 0x10;    //对方已读
                msgStateLog = @"对方已读";
            } else {
                msgState = 2; //发送成功
                msgStateLog = @"发送状态未知";
            }
            if (readFlag == 3) {
                readFlag = 1;
            } else {
                readFlag = 0;
            }
//            QIMVerboseLog(@"MsgId : %@, 阅读状态 : %@", msgId, msgStateLog);
            [paramList addObject:@[@(readFlag), @(msgState), msgId, @(msgState)]];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"批量更新%ld条消息阅读状态 耗时 = %f s", msgs.count, end - start); //
}

- (void)updateMessageReadStateWithSessionId:(NSString *)sessionId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set ReadedTag = 1 Where XmppId = :XmppId;";
        [database executeNonQuery:sql withParameters:[NSArray arrayWithObjects:sessionId, nil]];
    }];
}

- (void)updateSessionLastMsgIdWihtSessionId:(NSString *)sessionId
                              WithLastMsgId:(NSString *)lastMsgId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_SessionList Set LastMessageId = :LastMessageId Where XmppId = :XmppId;";
        [database executeNonQuery:sql withParameters:[NSArray arrayWithObjects:lastMsgId,sessionId, nil]];
    }];
}

- (void)insertSessionWithSessionId:(NSString *)sessinId
                        WithUserId:(NSString *)userId
                     WihtLastMsgId:(NSString *)lastMsgId
                WithLastUpdateTime:(long long)lastUpdateTime
                          ChatType:(int)ChatType
                       WithRealJid:(id)realJid{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or replace into IM_SessionList(XmppId, UserId, LastMessageId,LastUpdateTime,ChatType,RealJid) Values(:XmppId, :UserId, :LastMessageId,:LastUpdateTime,:ChatType,:RealJid);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:sessinId?sessinId:@":NULL"];
        [param addObject:userId?userId:@":NULL"];
        [param addObject:lastMsgId?lastMsgId:@":NULL"];
        [param addObject:[NSNumber numberWithLongLong:lastUpdateTime]];
        [param addObject:[NSNumber numberWithInt:ChatType]];
        [param addObject:realJid?realJid:@":NULL"];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)deleteSession:(NSString *)xmppId RealJid:(NSString *)realJid{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_SessionList Where XmppId=:XmppId AND RealJid=:RealJid;";
        [database executeNonQuery:sql withParameters:@[xmppId, realJid]];
    }];
}

- (void)deleteSession:(NSString *)xmppId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_SessionList Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[xmppId]];
    }];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"Delete From IM_Message Where XmppId Like '%%%@%%'", xmppId];
        [database executeNonQuery:sql withParameters:nil];
    }];
}

- (NSDictionary *)getLastedSingleChatSession {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT XmppId, UserId, LastMessageId, LastUpdateTime, ChatType, ExtendedFlag FROM IM_SessionList WHERE ChatType = %d ORDER BY LastUpdateTime DESC LIMIT 1;", SingleChat];
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
    }];
    return [result autorelease];
}

- (NSArray *)getFullSessionListWithSingleChatType:(int)singleChatType {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
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
            [IMDataManager safeSaveForDic:dic setObject:@(PublicNumberChat) forKey:@"ChatType"];
            pMaxLastTime = [pReader objectForColumnIndex:4];
        }
         NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_User where IM_User.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction,CASE b.LastUpdateTime  When NULL THEN a.LastUpdateTime ELSE b.LastUpdateTime END as orderTime, a.ChatType, case a.ChatType When %d THEN '' ELSE b.[From] END as NickName, 0 as NotReadCount,a.RealJid from IM_SessionList as a left join IM_Message as b on a.XmppId = b.XmppId and b.MsgId = (SELECT MsgId FROM IM_Message WHERE XmppId = a.XmppId  AND (case When a.ChatType = %d or a.ChatType = %d THEN RealJid = a.RealJid ELSE RealJid is null END) Order by LastUpdateTime DESC LIMIT 1) order by OrderTime desc;", singleChatType, singleChatType+1,singleChatType, ConsultChat, ConsultServerChat];
         DataReader *reader = [database executeReader:sql withParameters:nil];
         
         result = [[NSMutableArray alloc] init];
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
                 [sessionDic release];
                 }
             }
    }];
    return [result autorelease];
}


- (NSDictionary *)qimDb_getPublicNumberSession {
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *psql = @"Select b.XmppId,A.Name,b.Content,b.Type,b.LastUpdateTime From (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b Left Join IM_Public_Number as a On a.XmppId=b.XmppId;";
        DataReader *pReader = [database executeReader:psql withParameters:nil];
        if ([pReader read]) {
            result = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:result setObject:[pReader objectForColumnIndex:0] forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:[pReader objectForColumnIndex:1] forKey:@"Name"];
            [IMDataManager safeSaveForDic:result setObject:[pReader objectForColumnIndex:2] forKey:@"Content"];
            [IMDataManager safeSaveForDic:result setObject:[pReader objectForColumnIndex:3] forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:result setObject:[pReader objectForColumnIndex:4] forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:result setObject:@(PublicNumberChat) forKey:@"ChatType"];
        }
    }];
    return [result autorelease];
}

- (NSArray *)qimDB_getNotReadSessionList {
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN 0 THEN (select name from IM_User where IM_User.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When 0 THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction, a.ChatType, a.RealJid, a.LastUpdateTime, (case when (select count(*) from IM_Client_Config where DeleteFlag =0 and ConfigKey ='kStickJidDic' and ConfigSubKey=(a.XmppId ||'<>'||a.RealJid))=1 Then 1 ELSE 0 END) as StickState, (case when (select count(*) from IM_Client_Config where ConfigKey='kNoticeStickJidDic'and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then 1 ELSE 0 END) as Reminded, (case when (select count(*) from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then (select ConfigValue from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId) ELSE NULL END) as MarkupName, b.'From', case a.ChatType WHEN 4 THEN (SELECT COUNT(*) FROM IM_Message Where XmppId = a.XmppId And RealJid = a.RealJid And State < 16 And Direction=1) when 5 then (SELECT COUNT(*) FROM IM_Message Where XmppId = a.XmppId And RealJid = RealJid And State < 16 And Direction=1) else (SELECT COUNT(*) FROM IM_Message Where XmppId = a.XmppId And State < 16 And Direction=1) End as UnReadCount from IM_SessionList as a left join IM_Message as b on a.LastMessageId = b.MsgId where UnReadCount<>0 order by StickState desc, a.LastUpdateTime desc;"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        result = [[NSMutableArray alloc] init];
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
            NSNumber *unReadCount = [reader objectForColumnIndex:16];
            
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
            [IMDataManager safeSaveForDic:sessionDic setObject:unReadCount forKey:@"UnReadCount"];
            [result addObject:sessionDic];
            [sessionDic release];
        }
    }];
    return [result autorelease];
}

- (NSArray *)qimDB_getSessionListWithSingleChatType:(int)singleChatType {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
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
            [IMDataManager safeSaveForDic:dic setObject:@(PublicNumberChat) forKey:@"ChatType"];
            pMaxLastTime = [pReader objectForColumnIndex:4];
        }
        /*
        NSString *sql = @"select *from IM_SessionList ORDER by LastUpdateTime Desc";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        BOOL added = NO;
        result = [[NSMutableArray alloc] initWithCapacity:50];
        while ([reader read]) {
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *realJid = [reader objectForColumnIndex:1];
            NSString *userId = [reader objectForColumnIndex:2];
            NSString *lastMsgId = [reader objectForColumnIndex:3];
            NSNumber *msgDateTime = [reader objectForColumnIndex:4];
            NSNumber *chatType = [reader objectForColumnIndex:5];
            if (added == NO && msgDateTime && msgDateTime.longLongValue < pMaxLastTime.longLongValue) {
                added = YES;
                [result addObject:dic];
            } else {
                NSMutableDictionary *sessionDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:sessionDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:userId forKey:@"UserId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:lastMsgId forKey:@"LastMsgId"];
                [IMDataManager safeSaveForDic:sessionDic setObject:msgDateTime forKey:@"MsgDateTime"];
                [IMDataManager safeSaveForDic:sessionDic setObject:chatType forKey:@"ChatType"];
                [IMDataManager safeSaveForDic:sessionDic setObject:realJid forKey:@"RealJid"];
                [result addObject:sessionDic];
                [sessionDic release];
            }
        }
        long long endTime = [[NSDate date] timeIntervalSince1970] * 1000;
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        QIMVerboseLog(@"生成%ld条会话列表 耗时 = %f s", result.count, end - start); //s
        */
//        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_User where IM_User.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction,CASE b.LastUpdateTime  When NULL THEN a.LastUpdateTime ELSE b.LastUpdateTime END as orderTime, a.ChatType, case a.ChatType When %d THEN '' ELSE b.[From] END as NickName, 0 as NotReadCount,a.RealJid from IM_SessionList as a left join IM_Message as b on a.XmppId = b.XmppId and b.MsgId = (SELECT MsgId FROM IM_Message WHERE XmppId = a.XmppId  AND (case When a.ChatType = %d or a.ChatType = %d THEN RealJid = a.RealJid ELSE RealJid is null END) Order by LastUpdateTime DESC LIMIT 1) order by OrderTime desc;", singleChatType, singleChatType,singleChatType, ConsultChat, ConsultServerChat];
        
        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_User where IM_User.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction, a.ChatType, a.RealJid, a.LastUpdateTime, (case when (select count(*) from IM_Client_Config where DeleteFlag =0 and ConfigKey ='kStickJidDic' and ConfigSubKey=(a.XmppId ||'<>'||a.RealJid))=1 Then 1 ELSE 0 END) as StickState, (case when (select count(*) from IM_Client_Config where ConfigKey='kNoticeStickJidDic'and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then 1 ELSE 0 END) as Reminded, (case when (select count(*) from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId)=1 Then (select ConfigValue from IM_Client_Config where ConfigKey='kMarkupNames' and DeleteFlag=0 and ConfigSubKey=a.XmppId) ELSE NULL END) as MarkupName, b.'From' from IM_SessionList as a left join IM_Message as b on a.LastMessageId = b.MsgId order by StickState desc, a.LastUpdateTime desc;", singleChatType, singleChatType];
//        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_User where IM_User.XmppId = a.XmppId) ELSE (select Name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_User WHERE IM_User.XmppId = a.XmppId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, a.LastMessageId, a.ChatType, a.RealJid, a.LastUpdateTime from IM_SessionList as a Order by LastUpdateTime DESC;", singleChatType, singleChatType];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        result = [[NSMutableArray alloc] init];
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
                [result addObject:sessionDic];
                [sessionDic release];
            }
        }
        long long endTime = [[NSDate date] timeIntervalSince1970] * 1000;
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        QIMVerboseLog(@"生成%ld条会话列表 耗时 = %f s", result.count, end - start); //s
    }];
    return [result autorelease];
}

- (NSArray *)getSessionListXMPPIDWithSingleChatType:(int)singleChatType {
    
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT XmppId FROM IM_SessionList WHERE ChatType = %d", SingleChat];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        result = [[NSMutableArray alloc] init];
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
    return [result autorelease];
}

- (NSArray *)getPSessionListWithSingleChatType:(int)singleChatType{
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select a.XmppId, a.UserId, case a.ChatType WHEN %d THEN (select name from IM_User where IM_User.XmppId = a.XmppId) ELSE (select name from IM_Group where IM_Group.GroupId = a.XmppId) end as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, b.MsgId, b.Content, b.Type, b.State, b.Direction,CASE When b.LastUpdateTime is NULL THEN a.LastUpdateTime ELSE b.LastUpdateTime END as orderTime, a.ChatType, case a.ChatType When %d THEN '' ELSE b.[From] END as NickName, (Select count(*) From IM_Message Where XmppId = a.XmppId And ReadedTag = 0) as NotReadCount from IM_SessionList as a left join IM_Message as b on a.XmppId = b.XmppId and b.MsgId = (SELECT MsgId FROM IM_Message WHERE XmppId = a.XmppId Order by LastUpdateTime DESC LIMIT 1) order by OrderTime desc;", singleChatType, singleChatType+1, singleChatType + 3];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        result = [[NSMutableArray alloc] init];
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
            [result addObject:sessionDic];
            [sessionDic release];
        }
        
    }];
    return [result autorelease];
}

- (long long)getReadedTimeStampForUserId:(NSString *)userId WihtMsgDirection:(int)msgDirection WithReadedState:(int)readedState{
    __block long long timeStamp = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select Max(LastUpdateTime) From IM_Message Where  XmppId = :XmppId And State = :State And Direction = :MsgDirection And Type <> 101;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        [param addObject:@(readedState)];
        [param addObject:@(msgDirection)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        if ([reader read]) {
            timeStamp = [[reader objectForColumnIndex:0] longLongValue];
            if (timeStamp <= 0) {
                timeStamp = -1;
            }
        }
        
    }];
    return timeStamp;
}

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId ForRealJid:(NSString *)realJid {
    
    if (userId.length <=0 || realJid.length <= 0) {
        return nil;
    }
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select MsgId From IM_Message Where XmppId = :XmppId And RealJid = :RealJid And State <= :State And Direction = :MsgDirection;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        [param addObject:realJid];
        [param addObject:@(15)];
        [param addObject:@(1)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        while ([reader read]) {
            
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            
            NSString *msgId = [reader objectForColumnIndex:0];
            if (msgId.length > 0) {
                [result addObject:msgId];
            }
        }
    }];
    return [result autorelease];
}

- (NSArray *)qimDB_getNotReadMsgListForUserId:(NSString *)userId {
    __block NSMutableArray *result = nil;
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select MsgId From IM_Message Where XmppId = :XmppId And State <= :State And Direction = :MsgDirection;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        [param addObject:@(15)];
        [param addObject:@(1)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        while ([reader read]) {
            
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            
            NSString *msgId = [reader objectForColumnIndex:0];
            if (msgId.length > 0) {
                [result addObject:msgId];
            }
        }
    }];
    QIMVerboseLog(@"查未读消息MsgIds耗时: %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return [result autorelease];
}


- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId{
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime, ExtendInfo From IM_Message Where XmppId = :XmppId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:sesId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
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
            [msgDic release];
        }
        
    }];
    return [result autorelease];
}

- (void)updateMsgsContent:(NSString *)content ByMsgId:(NSString *)msgId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set Content=:Content Where msgId = :msgId";
        [database executeNonQuery:sql withParameters:@[content,msgId]];
    }];
}

- (NSDictionary *)getMsgsByMsgId:(NSString *)msgId {
    if (!msgId) {
        return nil;
    }
    __block NSMutableDictionary *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql =@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, MessageRaw, ExtendInfo From IM_Message Where MsgId=:MsgId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:msgId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        if (!result) {
            result = [[NSMutableDictionary alloc] init];
        }
        if ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSString *xmppId = [reader objectForColumnIndex:9];
            id msgRaw = [reader objectForColumnIndex:10];
            NSString *extendInfo = [reader objectForColumnIndex:11];
            [IMDataManager safeSaveForDic:result setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:result setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:result setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:result setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:result setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:result setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:result setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:result setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:result setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:msgRaw forKey:@"MsgRaw"];
            [IMDataManager safeSaveForDic:result setObject:extendInfo forKey:@"ExtendInfo"];
        }
    }];
    return [result autorelease];
}

- (void)updateIMMessageChatType {
    [[self dbInstance] usingTransaction:^(Database *database) {
        NSString *sql = @"Update ChatType";
        
    }];
}

- (NSDictionary *)getLastMessage {
    __block NSMutableArray *tempList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql =[NSString stringWithFormat:@"Select XmppId, UserId, LastMessageId, ChatType, LastUpdateTime From IM_SessionList Order By LastUpdateTime DESC Limit 1;"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        while ([reader read]) {
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *userId = [reader objectForColumnIndex:1];
            NSString *lastMessageId = [reader objectForColumnIndex:2];
            NSNumber *chatType = [reader objectForColumnIndex:3];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:4];
            NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"xmppId"];
            [IMDataManager safeSaveForDic:msgDic setObject:userId forKey:@"userId"];
            [IMDataManager safeSaveForDic:msgDic setObject:lastMessageId forKey:@"lastMessageId"];
            [IMDataManager safeSaveForDic:msgDic setObject:chatType forKey:@"chatType"];
            [IMDataManager safeSaveForDic:msgDic setObject:lastUpdateTime forKey:@"lastUpdateTime"];
            [tempList addObject:msgDic];
            [msgDic release];
        }
    }];
    return [tempList firstObject];
    
}

- (NSArray *)qimDB_getMgsListBySessionId:(NSString *)sesId WithRealJid:(NSString *)realJid WithLimit:(int)limit WihtOffset:(int)offset{
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    if (sesId == nil) {
        return nil;
    }
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = nil;
        NSMutableArray *param = [[NSMutableArray alloc] init];
        if (realJid) {
            if (limit) {
                sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,MessageRaw,RealJid, ExtendInfo From IM_Message Where XmppId = :XmppId And RealJid = :RealJid Order By LastUpdateTime DESC Limit %d OFFSET %d;",limit,offset];
            } else {
                sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,MessageRaw,RealJid, ExtendInfo From IM_Message Where XmppId = :XmppId And RealJid = :RealJid Order By LastUpdateTime DESC;"];
            }
            [param addObject:sesId];
            [param addObject:realJid?realJid:@":NULL"];
        } else {
            if (limit) {
                sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,MessageRaw,RealJid, ExtendInfo From IM_Message Where XmppId = :XmppId Order By LastUpdateTime DESC Limit %d OFFSET %d;",limit,offset];
            } else {
                sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag,MessageRaw,RealJid, ExtendInfo From IM_Message Where XmppId = :XmppId Order By LastUpdateTime DESC;"];
            }
            [param addObject:sesId];
        }
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        
        NSMutableArray *tempList = nil;
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
            tempList = [[NSMutableArray alloc] init];
        }
        
        while ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSNumber *notReadTag = [reader objectForColumnIndex:9];
            NSString *msgraw = [reader objectForColumnIndex:10];
            NSString *realJid = [reader objectForColumnIndex:11];
            NSString *extendInfo = [reader objectForColumnIndex:12];
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
//            [IMDataManager safeSaveForDic:msgDic setObject:[replyMsgDic objectForKey:msgId] forKey:@"ReplyMsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:notReadTag forKey:@"ReadTag"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgraw forKey:@"msgRaw"];
            [IMDataManager safeSaveForDic:msgDic setObject:realJid forKey:@"RealJid"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [tempList addObject:msgDic];
            [msgDic release];
        }
        for (int i = (int)tempList.count - 1;i>= 0;i--) {
            [result addObject:[tempList objectAtIndex:i]];
        }
        [tempList release];
//        [replyMsgDic release];
    }];
    QIMVerboseLog(@"sql取消息耗时。: %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return [result autorelease];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp{
    if (xmppId == nil) {
        return nil;
    }
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableDictionary *replyMsgDic = [[NSMutableDictionary alloc] init];
        {
            NSString *sql = @"Select MsgId, ReplyMsgId From IM_Friendster_Message Where XmppId=:XmppId;";
            DataReader *reader = [database executeReader:sql withParameters:@[xmppId]];
            while ([reader read]) {
                NSString *msgId = [reader objectForColumnIndex:0];
                NSString *replyMsgId = [reader objectForColumnIndex:1];
                [replyMsgDic setObject:replyMsgId forKey:msgId];
                [replyMsgDic setObject:replyMsgId forKey:replyMsgId];
            }
        }
        NSString *sql = nil;
        NSMutableArray *param = nil;
        if (realJid) {
            sql =[NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime, ReadedTag, ExtendInfo From IM_Message Where XmppId = :XmppId And RealJid = :RealJid And LastUpdateTime >= :LastUpdateTime Order By LastUpdateTime DESC;"];
            param = [[NSMutableArray alloc] init];
            [param addObject:xmppId];
            [param addObject:realJid];
            [param addObject:@(timeStamp)];
        } else {
            sql =[NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag, ExtendInfo From IM_Message Where XmppId = :XmppId And RealJid is null And LastUpdateTime >= :LastUpdateTime Order By LastUpdateTime DESC;"];
            param = [[NSMutableArray alloc] init];
            [param addObject:xmppId];
            [param addObject:@(timeStamp)];
        }
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        
        NSMutableArray *tempList = nil;
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
            tempList = [[NSMutableArray alloc] init];
        }
        
        while ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSNumber *notReadTag = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
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
            [IMDataManager safeSaveForDic:msgDic setObject:[replyMsgDic objectForKey:msgId] forKey:@"ReplyMsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:notReadTag forKey:@"ReadTag"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [tempList addObject:msgDic];
            [msgDic release];
        }
        for (int i = (int)tempList.count - 1; i>= 0;i--) {
            [result addObject:[tempList objectAtIndex:i]];
        }
        [tempList release];
        [replyMsgDic release];
    }];
    return [result autorelease];
}

- (NSArray *)getMsgListByXmppId:(NSString *)xmppId FromTimeStamp:(long long)timeStamp{
    if (xmppId == nil) {
        return nil;
    }
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableDictionary *replyMsgDic = [[NSMutableDictionary alloc] init];
        {
            NSString *sql = @"Select MsgId, ReplyMsgId From IM_Friendster_Message Where XmppId=:XmppId;";
            DataReader *reader = [database executeReader:sql withParameters:@[xmppId]];
            while ([reader read]) {
                NSString *msgId = [reader objectForColumnIndex:0];
                NSString *replyMsgId = [reader objectForColumnIndex:1];
                [replyMsgDic setObject:replyMsgId forKey:msgId];
                [replyMsgDic setObject:replyMsgId forKey:replyMsgId];
            }
        }
        
        NSString *sql =[NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,ReadedTag, ExtendInfo From IM_Message Where XmppId = :XmppId And LastUpdateTime >= :LastUpdateTime Order By LastUpdateTime DESC;"];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:xmppId];
        [param addObject:@(timeStamp)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        
        NSMutableArray *tempList = nil;
        if (result == nil) {
            result = [[NSMutableArray alloc] init];
            tempList = [[NSMutableArray alloc] init];
        }
        
        while ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSNumber *notReadTag = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
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
            [IMDataManager safeSaveForDic:msgDic setObject:[replyMsgDic objectForKey:msgId] forKey:@"ReplyMsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:notReadTag forKey:@"ReadTag"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [tempList addObject:msgDic];
            [msgDic release];
        }
        for (int i = (int)tempList.count - 1;i>= 0;i--) {
            [result addObject:[tempList objectAtIndex:i]];
        }
        [tempList release];
        [replyMsgDic release];
    }];
    return [result autorelease];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId chatType:(int)chatType{
    
    __block NSMutableDictionary *chatSession = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select a.XmppId, a.UserId, case a.ChatType When %d THEN (Select Name From IM_User WHERE UserId = a.UserId) ELSE (SELECT Name From IM_Group WHERE GroupId = a.XmppId) END as Name, case a.ChatType When %d THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, a.LastMessageId, b.Content, b.Type, b.State, b.Direction, b.LastUpdateTime, a.ChatType, case a.ChatType When %d THEN '' ELSE b.\"From\" END as NickName,(Select count(*) From IM_Message Where XmppId = a.XmppId And ReadedTag = 0) as NotReadCount From IM_SessionList as a left join IM_Message as b on (a.LastMessageId = b.MsgId ) Where a.XmppId=:XmppId Order by b.LastUpdateTime DESC;",chatType,chatType+1,chatType];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
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
    }];
    
    return [chatSession autorelease];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    __block NSMutableDictionary *chatSession = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"select XmppId, UserId, LastMessageId, LastUpdateTime, ChatType, RealJid from IM_SessionList where XmppId=:XmppId And RealJid=:RealJid;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
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
    }];
    
    return [chatSession autorelease];
}

- (NSDictionary *)getChatSessionWithUserId:(NSString *)userId{
    
    __block NSMutableDictionary *chatSession = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select a.XmppId, a.UserId, case a.ChatType When 0 THEN (Select Name From IM_User WHERE UserId = a.UserId) ELSE (SELECT Name From IM_Group WHERE GroupId = a.XmppId) END as Name, case a.ChatType When 0 THEN (Select HeaderSrc From IM_User WHERE UserId = a.UserId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc, a.LastMessageId, b.Content, b.Type, b.State, b.Direction, b.LastUpdateTime, a.ChatType,(Select count(*) From IM_Message Where XmppId = a.XmppId And ReadedTag = 0) as NotReadCount From IM_SessionList as a left join IM_Message as b on (a.LastMessageId = b.MsgId ) Where a.XmppId=:XmppId Order by b.LastUpdateTime DESC;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
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
    }];
    
    return [chatSession autorelease];
}

- (NSInteger)getNotReaderMsgCountByDidReadState:(int)didReadState WidthReceiveDirection:(int)receiveDirection{
    __block NSInteger count = 0;
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT COUNT(*) FROM IM_Message Where State < :State And Direction = :Direction And Type != 101;";
        DataReader *reader = [database executeReader:sql withParameters:@[@(didReadState),@(receiveDirection)]];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    QIMVerboseLog(@"获取未读数耗时 :%lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return count;
}

- (NSInteger)getNotReaderMsgCountByJid:(NSString *)jid ByDidReadState:(int)didReadState WidthReceiveDirection:(int)receiveDirection{
    __block NSInteger count = 0;
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT COUNT(*) FROM IM_Message Where XmppId = :XmppId And State < :State And Direction=:Direction;";
        DataReader *reader = [database executeReader:sql withParameters:@[jid ? jid : @"",@(didReadState),@(receiveDirection)]];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    QIMVerboseLog(@"获取不提醒未读数耗时 :%lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return count;
}

- (NSInteger)getNotReaderMsgCountByJid:(NSString *)jid ByRealJid:(NSString *)realJid ByDidReadState:(int)didReadState WidthReceiveDirection:(int)receiveDirection{
    __block NSInteger count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT COUNT(*) FROM IM_Message Where XmppId = :XmppId And RealJid = :RealJid And State < :State And Direction=:Direction;";
        DataReader *reader = [database executeReader:sql withParameters:@[jid ? jid : @"",realJid ? realJid : @":NULL",@(didReadState),@(receiveDirection)]];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    return count;
}

- (void)updateMessageFromState:(int)fState ToState:(int)tState{
    [[self dbInstance] usingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set State=:tMsgState Where State=:fMsgState;";
        [database executeNonQuery:sql withParameters:@[@(tState),@(fState)]];
    }];
}

- (NSInteger)getMessageStateWithMsgId:(NSString *)msgId {
    __block NSInteger msgState = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select State from IM_Message where MsgId='%@';", msgId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            msgState = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    return msgState;
}

- (NSArray *)getMsgIdsForDirection:(int)msgDirection WithMsgState:(int)msgState{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select MsgId From IM_Message Where State = :State And Direction=:Direction;";
        DataReader *reader = [database executeReader:sql withParameters:@[@(msgState),@(msgDirection)]];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *msgId = [reader objectForColumnIndex:0];
            [resultList addObject:msgId];
        }
    }];
    return [resultList autorelease];
}

- (NSArray *)getMsgIdsByMsgState:(int)notReadMsgState WithDirection:(int)receiveDirection{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select XmppId,MsgId From IM_Message Where State <:State And Direction=:Direction;";
        DataReader *reader = [database executeReader:sql withParameters:@[@(notReadMsgState),@(receiveDirection)]];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *msgId = [reader objectForColumnIndex:1];
            if ([[xmppId componentsSeparatedByString:@"@"].lastObject hasPrefix:_domain] && msgId) {
                [resultList addObject:msgId];
            }
        }
    }];
    return [resultList autorelease];
}

- (void)updateMsgIdToDidreadForNotReadMsgIdList:(NSArray *)notReadList AndSourceMsgIdList:(NSArray *)sourceMsgIdList WithDidReadState:(int)didReadState{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *updateToDidRead = [NSMutableString stringWithString:@"Update IM_Message Set State=:State Where MsgId in ("];
        NSMutableString *updateToNotRead = [NSMutableString stringWithString:@"Update IM_Message Set State=:State Where MsgId in ("];
        for (NSString *msgId in notReadList) {
            if ([msgId isEqual:notReadList.lastObject]) {
                [updateToNotRead appendFormat:@"'%@');",msgId];
            } else {
                [updateToNotRead appendFormat:@"'%@',",msgId];
            }
        }
        for (NSString *msgId in sourceMsgIdList) {
            if ([msgId isEqual:sourceMsgIdList.lastObject]) {
                [updateToDidRead appendFormat:@"'%@');",msgId];
            } else {
                [updateToDidRead appendFormat:@"'%@',",msgId];
            }
        }
        [database executeNonQuery:updateToDidRead  withParameters:@[@(didReadState)]];
        if (notReadList.count > 0) {
            [database executeNonQuery:updateToNotRead withParameters:@[@(0)]];
        }
    }];
    
}

- (NSArray *)searchMsgHistoryWithKey:(NSString *)key{
    __block NSMutableArray *contactList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select XmppId from IM_Message WHERE Content like :key and Type = 1 group by XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[[NSString stringWithFormat:@"%%%@%%",key]]];
        while ([reader read]) {
            if (contactList == nil) {
                contactList = [[NSMutableArray alloc] init];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            [contactList addObject:@{@"XmppId":xmppId}];
        }
    }];
    return contactList;
    
}

- (NSArray *)searchMsgIdWithKey:(NSString *)key ByXmppId:(NSString *)xmppId{
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select MsgId,Content from IM_Message WHERE Content like :key and Type = 1 and XmppId = :XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[[NSString stringWithFormat:@"%%%@%%",key],xmppId]];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *content = [reader objectForColumnIndex:1];
            [result addObject:@{@"MsgId":msgId,@"Content":content}];
        }
    }];
    return result;
}

// ******************** 最近联系人 **************************** //
- (NSArray *)getRecentContacts{
    __block NSMutableArray *contactList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT a.XmppId, a.Type, case a.Type When 0 THEN (Select Name From IM_User WHERE XmppId = a.XmppId) ELSE (SELECT Name From IM_Group WHERE GroupId = a.XmppId) END as Name, case a.Type When 0 THEN (Select HeaderSrc From IM_User WHERE XmppId = a.XmppId) ELSE (SELECT HeaderSrc From IM_Group WHERE GroupId=a.XmppId) END as HeaderSrc FROM IM_Recent_Contacts a ORDER BY LastUpdateTime DESC;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (contactList == nil) {
                contactList = [[NSMutableArray alloc] init];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSNumber *type = [reader objectForColumnIndex:1];
            NSString *Name = [reader objectForColumnIndex:2];
            NSString *HeaderSrc = [reader objectForColumnIndex:3];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:type forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:dic setObject:Name forKey:@"Name"];
            [IMDataManager safeSaveForDic:dic setObject:HeaderSrc forKey:@"HeaderSrc"];
            [contactList addObject:dic];
            [dic release];
        }
    }];
    return [contactList autorelease];
}

- (void)insertRecentContact:(NSDictionary *)contact{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"INSERT OR REPLACE INTO IM_RECENT_CONTACTS(XmppId,Type,LastUpdateTime) VALUES(:XmppId,:Type,:LastUpdateTime); ";
        NSString *xmppId = [contact objectForKey:@"XmppId"];
        NSNumber *type = [contact objectForKey:@"ChatType"];
        NSNumber *lastUpdateTime = @([[NSDate date] timeIntervalSince1970]);
        NSMutableArray *param = [NSMutableArray array];
        [param addObject:xmppId];
        [param addObject:type];
        [param addObject:lastUpdateTime];
        [database executeNonQuery:sql withParameters:param];
    }];
}

- (void)removeRecentContact:(NSString *)xmppId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_RECENT_CONTACTS Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[xmppId]];
    }];
}


#pragma mark - 消息数据方法

- (long long) lastestMessageTimeWithNotMessageState:(long long) messageState {
    
    __block long long result = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select min(LastUpdateTime) from IM_Message where State & :p0 <> :p0 and Type <> 101;";
        DataReader *reader = [database executeReader:sql
                                      withParameters:[NSArray arrayWithObject:@(messageState)]];
        if ([reader read]) {
            result = [[reader objectForColumnIndex:0] longLongValue];
        } else {
            result = -1;
        }
    }];
    return result;
}

- (NSString *) getLastMsgIdByJid:(NSString *)jid{
    __block NSString *lastMsgId = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select MsgId from IM_Message Where XmppId=:XmppId And Type != 101 order by LastUpdateTime desc limit 1";
        DataReader *reader = [database executeReader:sql withParameters:@[jid]];
        if ([reader read]) {
            lastMsgId = [[reader objectForColumnIndex:0] retain];
        }
    }];
    return [lastMsgId autorelease];
}

- (NSString *)getLastMsgIdByJid:(NSString *)jid ByRealJid:(NSString *)realJid {
    __block NSString *lastMsgId = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select MsgId from IM_Message Where XmppId=:XmppId And RealJid=:RealJid And Type != 101 order by LastUpdateTime desc limit 1";
        DataReader *reader = [database executeReader:sql withParameters:@[jid, realJid]];
        if ([reader read]) {
            lastMsgId = [[reader objectForColumnIndex:0] retain];
        }
    }];
    return [lastMsgId autorelease];
}

- (long long)getMsgTimeWithMsgId:(NSString *)msgId {
    if (!msgId) {
        return 0;
    }
    __block long long maxRemoteTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select LastUpdateTime from IM_Message Where MsgId=:MsgId";
        DataReader *reader = [database executeReader:sql withParameters:@[msgId]];
        if ([reader read]) {
            maxRemoteTime = [[reader objectForColumnIndex:0] longLongValue];
        }
    }];
    return maxRemoteTime;
}

- (long long)getLastMsgTimeIdByJid:(NSString *)jid {
    __block long long maxRemoteTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select LastUpdateTime from IM_Message Where XmppId=:XmppId order by LastUpdateTime desc limit 1";
        DataReader *reader = [database executeReader:sql withParameters:@[jid]];
        if ([reader read]) {
            maxRemoteTime = [[reader objectForColumnIndex:0] longLongValue];
        }
    }];
    return maxRemoteTime;
}

- (long long) lastestMessageTime {
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    __block long long maxRemoteTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *newSql = @"select LastUpdateTime from IM_Message Where ChatType=0 And (State == 2 OR State == 16 Or State == 15) ORDER by LastUpdateTime desc limit(1);";
        DataReader *newReader = [database executeReader:newSql withParameters:nil];
        if ([newReader read]) {
            maxRemoteTime = [[newReader objectForColumnIndex:0] longLongValue];
        }
        if (maxRemoteTime <= 0) {
            QIMVerboseLog(@"取个时间戳老逻辑");
            NSString *sql = @"Select max(LastUpdateTime) from IM_Message where XmppId not like '%@conference.%' AND XmppId not like 'System%' And (State == 2 OR State == 16 Or State == 15);";
            DataReader *reader = [database executeReader:sql withParameters:nil];
            if ([reader read]) {
                maxRemoteTime = [[reader objectForColumnIndex:0] longLongValue];
            }
        }
    }];
    QIMVerboseLog(@"取个时间戳这么长时间 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
    return maxRemoteTime;
}

- (long long) lastestSystemMessageTime {
    
    __block long long maxRemoteTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *newSql = @"select max(LastUpdateTime) from IM_Message Where ChatType=2;";
        DataReader *newReader = [database executeReader:newSql withParameters:nil];
        if ([newReader read]) {
            maxRemoteTime = [[newReader objectForColumnIndex:0] longLongValue];
        } else {
            NSString *sql = @"select max(LastUpdateTime) from IM_Message where XmppId like 'System.%';";
            DataReader *reader = [database executeReader:sql withParameters:nil];
            if ([reader read]) {
                maxRemoteTime = [[reader objectForColumnIndex:0] longLongValue];
            }
        }
    }];
    return maxRemoteTime;
}

- (NSArray *) existsMessageUsers {
    __block NSMutableArray *contactList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"select DISTINCT(xmppId) from IM_Message where XmppId not like '%conference%' and XmppId <> 'SystemMessage';";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        while ([reader read]) {
            if (contactList == nil) {
                contactList = [[NSMutableArray alloc] init];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"xmppId"];
            [contactList addObject:dic];
            [dic release];
        }
    }];
    return [contactList autorelease];
}

//select DISTINCT(xmppId) from IM_Message where XmppId not like '%conference%' and XmppId <> 'SystemMessage'

#pragma mark - 公众账号
// ******************** 公众账号 ***************************** //

- (BOOL)checkPublicNumberMsgById:(NSString *)msgId{
    __block BOOL flag = NO;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select 1 From IM_Public_Number_Message Where MsgId = :MsgId;";
        DataReader *reader = [database executeReader:sql withParameters:@[msgId]];
        if ([reader read]) {
            flag = YES;
        }
    }];
    return flag;
}

- (void)checkPublicNumbers:(NSArray *)publicNumberIds{
    [[self dbInstance] usingTransaction:^(Database *database) {
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        if (publicNumberIds.count > 0) {
            NSString *sql = @"INSERT OR IGNORE INTO IM_Public_Number(XmppId,PublicNumberId,LastUpdateTime) VALUES(:XmppId,:PublicNumberId,:LastUpdateTime);";
            NSMutableArray *paramList = [NSMutableArray array];
            for(NSString *publicId in publicNumberIds ) {
                NSString *xmppId = [NSString stringWithFormat:@"%@@%@",publicId,_domain];

                NSMutableArray *params = [NSMutableArray array];
                [params addObject:xmppId];
                [params addObject:publicId];
                [params addObject:@(-1)];
                [paramList addObject:params];
            }
            [database executeBulkInsert:sql withParameters:paramList];
        }
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        QIMVerboseLog(@"检查公众号列表%ld条数据, 耗时 = %f s", publicNumberIds.count, end - start); //s
    }];
}

- (void)bulkInsertPublicNumbers:(NSArray *)publicNumberList{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"INSERT OR REPLACE INTO IM_Public_Number(XmppId,PublicNumberId,PublicNumberType,Name,DescInfo,HeaderSrc,SearchIndex,PublicNumberInfo,LastUpdateTime) VALUES(:XmppId,:PublicNumberId,:PublicNumberType,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:PublicNumberInfo,:LastUpdateTime);";
        
        NSMutableArray *paramList = [NSMutableArray array];
        for(NSDictionary *dic in publicNumberList ) {
            long long version = [[dic objectForKey:@"rbt_ver"] intValue];
            
            NSDictionary *rbtBodyDict = [NSDictionary dictionary];
            if ([dic objectForKey:@"rbt_body"]) {
                rbtBodyDict = [dic objectForKey:@"rbt_body"];
            } else {
                rbtBodyDict = dic;
            }
            NSString *publicNumberId = [rbtBodyDict objectForKey:@"robotEnName"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@",publicNumberId,_domain];
            NSString *nickName = [rbtBodyDict objectForKey:@"robotCnName"];
            NSString *headerurl = [rbtBodyDict objectForKey:@"headerurl"];
            NSString *robotDesc = [rbtBodyDict objectForKey:@"robotDesc"];
            NSData *userInfo = [NSKeyedArchiver archivedDataWithRootObject:rbtBodyDict];
            NSString *searchIndex = [rbtBodyDict objectForKey:@"searchIndex"];
            
            NSMutableArray *params = [NSMutableArray array];
            [params addObject:xmppId];
            [params addObject:publicNumberId];
            [params addObject:@(0)];
            [params addObject:nickName?nickName:@":NULL"];
            [params addObject:robotDesc?robotDesc:@":NULL"];
            [params addObject:headerurl?headerurl:@":NULL"];
            [params addObject:searchIndex?searchIndex:@":NULL"];
            [params addObject:userInfo?userInfo:@":NULL"];
            [params addObject:@(version)];
            [paramList addObject:params];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
}

- (void)insertPublicNumberXmppId:(NSString *)xmppId
              WithPublicNumberId:(NSString *)publicNumberId
            WithPublicNumberType:(int)publicNumberType
                        WithName:(NSString *)name
                   WithHeaderSrc:(NSString *)headerSrc
                    WithDescInfo:(NSString *)descInfo
                 WithSearchIndex:(NSString *)searchIndex
                  WithPublicInfo:(NSString *)publicInfo
                     WithVersion:(int)version{
    if (xmppId == nil) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"INSERT OR REPLACE INTO IM_Public_Number(XmppId,PublicNumberId,PublicNumberType,Name,DescInfo,HeaderSrc,SearchIndex,PublicNumberInfo,LastUpdateTime) VALUES(:XmppId,:PublicNumberId,:PublicNumberType,:Name,:DescInfo,:HeaderSrc,:SearchIndex,:PublicNumberInfo,:LastUpdateTime);";
        NSMutableArray *params = [NSMutableArray array];
        [params addObject:xmppId];
        [params addObject:publicNumberId];
        [params addObject:@(publicNumberType)];
        [params addObject:name?name:@":NULL"];
        [params addObject:headerSrc?headerSrc:@":NULL"];
        [params addObject:searchIndex?searchIndex:@":NULL"];
        [params addObject:descInfo?descInfo:@":NULL"];
        [params addObject:publicInfo?publicInfo:@":NULL"];
        [params addObject:@(version)];
        [database executeNonQuery:sql withParameters:params];
    }];
    
}

- (void)deletePublicNumberId:(NSString *)publicNumberId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Public_Number Where PublicNumberId=:PublicNumberId;";
        [database executeNonQuery:sql withParameters:@[publicNumberId]];
    }];
}

- (NSArray *)getPublicNumberVersionList{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT PublicNumberId,LastUpdateTime FROM IM_Public_Number;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:1];
            
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:xmppId forKey:@"robot_name"];
            [IMDataManager safeSaveForDic:value setObject:lastUpdateTime forKey:@"version"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
        
    }];
    return [resultList autorelease];
}

- (NSArray *)getPublicNumberList{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT a.XmppId,a.PublicNumberId,a.PublicNumberType,a.Name,a.DescInfo,a.HeaderSrc,a.SearchIndex,a.PublicNumberInfo,b.LastUpdateTime,b.Content,b.Type FROM IM_Public_Number as a Left Join (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b On a.XmppId=b.XmppId Order By b.LastUpdateTime Desc;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *publicNumberId = [reader objectForColumnIndex:1];
            NSNumber *publicNumberType = [reader objectForColumnIndex:2];
            NSString *name = [reader objectForColumnIndex:3];
            NSString *descInfo = [reader objectForColumnIndex:4];
            NSString *headerSrc = [reader objectForColumnIndex:5];
            NSString *searchIndex = [reader objectForColumnIndex:6];
            NSData   *publicData = [reader objectForColumnIndex:7];
            NSDictionary *pInfo = [NSKeyedUnarchiver unarchiveObjectWithData:publicData];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSNumber *msgType = [reader objectForColumnIndex:10];
            
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:value setObject:publicNumberId forKey:@"PublicNumberId"];
            [IMDataManager safeSaveForDic:value setObject:publicNumberType forKey:@"PublicNumberType"];
            [IMDataManager safeSaveForDic:value setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:value setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:value setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:value setObject:searchIndex forKey:@"SearchIndex"];
            [IMDataManager safeSaveForDic:value setObject:pInfo forKey:@"PublicNumberInfo"];
            [IMDataManager safeSaveForDic:value setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:value setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:value setObject:msgType forKey:@"MsgType"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
        
    }];
    return [resultList autorelease];
}

- (NSArray *)searchPublicNumberListByKeyStr:(NSString *)keyStr{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT a.XmppId,a.PublicNumberId,a.PublicNumberType,a.Name,a.DescInfo,a.HeaderSrc,a.SearchIndex,a.PublicNumberInfo,b.LastUpdateTime,b.Content,b.Type FROM IM_Public_Number as a Left Join (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b On a.XmppId=b.XmppId Where a.PublicNumberId Like '%%%@%%' Or a.Name Like '%%%@%%' Or a.SearchIndex Like '%%%@%%' Order By b.LastUpdateTime Desc;",keyStr,keyStr,keyStr];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *publicNumberId = [reader objectForColumnIndex:1];
            NSNumber *publicNumberType = [reader objectForColumnIndex:2];
            NSString *name = [reader objectForColumnIndex:3];
            NSString *descInfo = [reader objectForColumnIndex:4];
            NSString *headerSrc = [reader objectForColumnIndex:5];
            NSString *searchIndex = [reader objectForColumnIndex:6];
            NSData   *publicData = [reader objectForColumnIndex:7];
            NSDictionary *pInfo = [NSKeyedUnarchiver unarchiveObjectWithData:publicData];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:8];
            NSString *content = [reader objectForColumnIndex:9];
            NSNumber *msgType = [reader objectForColumnIndex:10];
            
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:value setObject:publicNumberId forKey:@"PublicNumberId"];
            [IMDataManager safeSaveForDic:value setObject:publicNumberType forKey:@"PublicNumberType"];
            [IMDataManager safeSaveForDic:value setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:value setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:value setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:value setObject:searchIndex forKey:@"SearchIndex"];
            [IMDataManager safeSaveForDic:value setObject:pInfo forKey:@"PublicNumberInfo"];
            [IMDataManager safeSaveForDic:value setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [IMDataManager safeSaveForDic:value setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:value setObject:msgType forKey:@"MsgType"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
        
    }];
    return [resultList autorelease];
}

- (NSInteger)getRnSearchPublicNumberListByKeyStr:(NSString *)keyStr {
    __block NSInteger count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) a.XmppId,a.PublicNumberId,a.PublicNumberType,a.Name,a.DescInfo,a.HeaderSrc,a.SearchIndex,a.PublicNumberInfo,b.LastUpdateTime,b.Content,b.Type FROM IM_Public_Number as a Left Join (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b On a.XmppId=b.XmppId Where a.PublicNumberId Like '%%%@%%' Or a.Name Like '%%%@%%' Or a.SearchIndex Like '%%%@%%' Order By b.LastUpdateTime Desc;",keyStr,keyStr,keyStr];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] intValue];
        }
    }];
    return count;
}

- (NSArray *)rnSearchPublicNumberListByKeyStr:(NSString *)keyStr limit:(NSInteger)limit offset:(NSInteger)offset {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT a.XmppId,a.PublicNumberId,a.PublicNumberType,a.Name,a.DescInfo,a.HeaderSrc,a.SearchIndex,a.PublicNumberInfo,b.LastUpdateTime,b.Content,b.Type FROM IM_Public_Number as a Left Join (Select XmppId,Content,Type,LastUpdateTime From IM_Public_Number_Message Order By LastUpdateTime Desc Limit 1) as b On a.XmppId=b.XmppId Where a.PublicNumberId Like '%%%@%%' Or a.Name Like '%%%@%%' Or a.SearchIndex Like '%%%@%%' Order By b.LastUpdateTime Desc LIMIT %ld OFFSET %ld;",keyStr,keyStr,keyStr, (long)limit, (long)offset];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *uri = [reader objectForColumnIndex:0];
            NSString *publicNumberId = [reader objectForColumnIndex:1];
            NSString *name = [reader objectForColumnIndex:3];
            NSString *content = [reader objectForColumnIndex:4];
            NSString *icon = [reader objectForColumnIndex:5];
            if (!icon) {
                icon = @"";
            }
            NSString *label = [NSString stringWithFormat:@"%@(%@)", name, publicNumberId];
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:uri forKey:@"uri"];
            [IMDataManager safeSaveForDic:value setObject:label forKey:@"label"];
            [IMDataManager safeSaveForDic:value setObject:content forKey:@"content"];
            [IMDataManager safeSaveForDic:value setObject:icon forKey:@"icon"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
    }];
    return [resultList autorelease];
}

- (NSDictionary *)getPublicNumberCardByJId:(NSString *)jid{
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"SELECT XmppId,PublicNumberId,PublicNumberType,Name,DescInfo,HeaderSrc,SearchIndex,PublicNumberInfo,LastUpdateTime FROM IM_Public_Number Where XmppId=:XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[jid]];
        if ([reader read]) {
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *publicNumberId = [reader objectForColumnIndex:1];
            NSNumber *publicNumberType = [reader objectForColumnIndex:2];
            NSString *name = [reader objectForColumnIndex:3];
            NSString *descInfo = [reader objectForColumnIndex:4];
            NSString *headerSrc = [reader objectForColumnIndex:5];
            NSString *searchIndex = [reader objectForColumnIndex:6];
            NSData   *publicNumberInfoData = [reader objectForColumnIndex:7];
            NSDictionary *pInfo = [NSKeyedUnarchiver unarchiveObjectWithData:publicNumberInfoData];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:8];
            
            resultDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:resultDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:resultDic setObject:publicNumberId forKey:@"PublicNumberId"];
            [IMDataManager safeSaveForDic:resultDic setObject:publicNumberType forKey:@"PublicNumberType"];
            [IMDataManager safeSaveForDic:resultDic setObject:name forKey:@"Name"];
            [IMDataManager safeSaveForDic:resultDic setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:resultDic setObject:headerSrc forKey:@"HeaderSrc"];
            [IMDataManager safeSaveForDic:resultDic setObject:searchIndex forKey:@"SearchIndex"];
            [IMDataManager safeSaveForDic:resultDic setObject:pInfo forKey:@"PublicNumberInfo"];
            [IMDataManager safeSaveForDic:resultDic setObject:lastUpdateTime forKey:@"LastUpdateTime"];
        }
        
    }];
    return [resultDic autorelease];
    
}

- (void)insetPublicNumberMsgWihtMsgId:(NSString *)msgId
                        WithSessionId:(NSString *)sessionId
                             WithFrom:(NSString *)from
                               WithTo:(NSString *)to
                          WithContent:(NSString *)content
                         WithPlatform:(int)platform
                          WithMsgType:(int)msgType
                         WithMsgState:(int)msgState
                     WithMsgDirection:(int)msgDirection
                          WihtMsgDate:(long long)msgDate
                        WithReadedTag:(int)readedTag{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"INSERT OR IGNORE INTO IM_Public_Number_Message(MsgId,XmppId,'From','To',Content,Type,State,Direction,ReadedTag,LastUpdateTime) VALUES(:MsgId,:XmppId,:From,:To,:Content,:Type,:State,:Direction,:ReadedTag,:LastUpdateTime);";
        
        NSMutableArray *params = [[NSMutableArray alloc] init];
        [params addObject:msgId?msgId:@":NULL"];
        [params addObject:sessionId?sessionId:@":NULL"];
        [params addObject:from?from:@":NULL"];
        [params addObject:to?to:@":NULL"];
        [params addObject:content?content:@":NULL"];
        [params addObject:@(msgType)];
        [params addObject:@(msgState)];
        [params addObject:@(msgDirection)];
        [params addObject:@(readedTag)];
        [params addObject:@(msgDate)];
        [database executeNonQuery:sql withParameters:params];
        [params release];
        params = nil;
        
    }];
}

- (NSArray *)getMsgListByPublicNumberId:(NSString *)publicNumberId
                              WithLimit:(int)limit
                             WihtOffset:(int)offset
                         WithFilterType:(NSArray *)actionTypes{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *sql = [NSMutableString stringWithString:@"SELECT MsgId,XmppId,\"From\",\"To\",Content,Type,State,Direction,ReadedTag,LastUpdateTime From IM_Public_Number_Message Where XmppId=:XmppId and Type not in ("];
        for (NSNumber *type in actionTypes) {
            if ([type isEqual:actionTypes.lastObject]) {
                [sql appendFormat:@"%d) ",type.intValue];
            } else {
                [sql appendFormat:@"%d,",type.intValue];
            }
        }
        [sql appendFormat:@" Order By LastUpdateTime Desc Limit %d offset %d;",limit,offset];
        DataReader *reader = [database executeReader:sql withParameters:@[publicNumberId]];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *from = [reader objectForColumnIndex:2];
            NSString *to = [reader objectForColumnIndex:3];
            NSString *content = [reader objectForColumnIndex:4];
            NSNumber *type = [reader objectForColumnIndex:5];
            NSNumber *state = [reader objectForColumnIndex:6];
            NSNumber *direction = [reader objectForColumnIndex:7];
            NSNumber *readedTag = [reader objectForColumnIndex:8];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:9];
            NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:value setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:value setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:value setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:value setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:value setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:value setObject:type forKey:@"Type"];
            [IMDataManager safeSaveForDic:value setObject:state forKey:@"State"];
            [IMDataManager safeSaveForDic:value setObject:direction forKey:@"Direction"];
            [IMDataManager safeSaveForDic:value setObject:readedTag forKey:@"ReadedTag"];
            [IMDataManager safeSaveForDic:value setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
    }];
    return [resultList autorelease];
}

/****************** Collection Msg *******************/

- (NSArray *)getCollectionAccountList {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
            //            [IMDataManager safeSaveForDic:value setObject:bindHost forKey:@"BindHost"];
            //            [IMDataManager safeSaveForDic:value setObject:descInfo forKey:@"DescInfo"];
            [IMDataManager safeSaveForDic:value setObject:headerSrc forKey:@"HeaderSrc"];
            //            [IMDataManager safeSaveForDic:value setObject:searchIndex forKey:@"SearchIndex"];
            //            [IMDataManager safeSaveForDic:value setObject:bindFlag forKey:@"BindFlag"];
            //            [IMDataManager safeSaveForDic:value setObject:lastUpdateTime forKey:@"LastUpdateTime"];
            [resultList addObject:value];
            [value release];
            value = nil;
        }
    }];
    return [resultList autorelease];
}

- (void)bulkinsertCollectionAccountList:(NSArray *)accounts {
    [[self dbInstance] usingTransaction:^(Database *database) {
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
}

- (NSDictionary *)selectCollectionUserByJID:(NSString *)jid{
    if (jid == nil) {
        return nil;
    }
    __block NSMutableDictionary *user = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select UserId, XmppId, Name, DescInfo, HeaderSrc, UserInfo,LastUpdateTime,SearchIndex from IM_Collection_User_Card Where XmppId = :XmppId;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:jid];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
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
        
    }];
    return [user autorelease];
}

- (void)bulkInsertCollectionUserCards:(NSArray *)userCards {
    [[self dbInstance] usingTransaction:^(Database *database) {
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
}

- (NSDictionary *)getCollectionGroupCardByGroupId:(NSString *)groupId{
    __block NSMutableDictionary *groupCardDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select GroupId, Name, Introduce, HeaderSrc, Topic, LastUpdateTime From IM_Collection_Group_Card Where GroupId = :GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
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
    }];
    return [groupCardDic autorelease];
}

- (void)bulkInsertCollectionGroupCards:(NSArray *)array{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Insert or replace Into IM_Collection_Group_Card(GroupId,Name,Introduce,HeaderSrc,Topic,LastUpdateTime,ExtendedFlag) values(:GroupId,:Name,:Introduce,:HeaderSrc,:Topic,:LastUpdateTime,:ExtendedFlag);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
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
        [paramList release];
        paramList = nil;
    }];
}

- (NSDictionary *)getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId {
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select c.Originfrom, s.ChatType, m.content FROM IM_SessionList AS s, IM_Message AS m, IM_Message_Collection AS c WHERE m.MsgId='%@' AND c.MsgId='%@' AND s.ChatType=%@;", lastMsgId, lastMsgId, @(CollectionChat)];
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
    }];
    return [resultDic autorelease];
}

- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
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
            [IMDataManager safeSaveForDic:sessionDic setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:sessionDic setObject:@(2) forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:sessionDic setObject:LastUpdateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:sessionDic setObject:chatType forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:sessionDic setObject:nickName forKey:@"NickName"];
            [resultList addObject:sessionDic];
            [sessionDic release];
        }
    }];
    return [resultList autorelease];
}

- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId {
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime, ExtendInfo From IM_Message Where \"To\" = :to;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:bindId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        result = [[NSMutableArray alloc] init];
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
            [msgDic release];
        }
    }];
    return [result autorelease];
}

- (NSArray *)getLastCollectionSession {
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = [NSString stringWithFormat:@"Select *from IM_Message_Collection Order By LastUpdateTime Desc"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        result = [[NSMutableArray alloc] init];
        while ([reader read]) {
            
            NSString *MsgId = [reader objectForColumnIndex:0];
            NSString *XmppId = [reader objectForColumnIndex:1];
            NSString *From = [reader objectForColumnIndex:2];
            //            NSString *To = [reader objectForColumnIndex:3];
            NSString *Content = [reader objectForColumnIndex:4];
            NSString *Platform = [reader objectForColumnIndex:5];
            NSString *Type = [reader objectForColumnIndex:6];
            NSNumber *State = [reader objectForColumnIndex:7];
            NSNumber *Direction = [reader objectForColumnIndex:8];
            NSNumber *ReadedTag = [reader objectForColumnIndex:9];
            NSNumber *LastUpdateTime = [reader objectForColumnIndex:10];
            NSString *extendInfo = [reader objectForColumnIndex:11];
            NSMutableDictionary *sessionDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:sessionDic setObject:XmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:sessionDic setObject:From forKey:@"UserId"];
            [IMDataManager safeSaveForDic:sessionDic setObject:MsgId forKey:@"LastMsgId"];
            [IMDataManager safeSaveForDic:sessionDic setObject:Content forKey:@"Content"];
            [IMDataManager safeSaveForDic:sessionDic setObject:Platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:sessionDic setObject:Type forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:sessionDic setObject:State forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:sessionDic setObject:Direction forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:sessionDic setObject:ReadedTag forKey:@"ReadedTag"];
            [IMDataManager safeSaveForDic:sessionDic setObject:LastUpdateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:sessionDic setObject:@(CollectionChat) forKey:@"ChatType"];
            [IMDataManager safeSaveForDic:sessionDic setObject:extendInfo forKey:@"ExtendInfo"];
            [result addObject:sessionDic];
            [sessionDic release];
        }
    }];
    return [result autorelease];
}

- (BOOL)checkCollectionMsgById:(NSString *)msgId {
    __block BOOL flag = NO;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select 1 From IM_Message_Collection Where MsgId = :MsgId;";
        DataReader *reader = [database executeReader:sql withParameters:@[msgId]];
        if ([reader read]) {
            flag = YES;
        }
    }];
    return flag;
}

- (void)bulkInsertCollectionMsgWihtMsgDics:(NSArray *)msgs {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState {
    __block int count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT Count(*) from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where State < :State ORDER by LastUpdateTime;"];
        DataReader *reader = [database executeReader:sql withParameters:@[@(readState)]];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    return count;
}

- (NSInteger)getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId {
    __block int count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT Count(*) from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (Originto = '%@' and State < :State) ORDER by LastUpdateTime;", bindId];
        DataReader *reader = [database executeReader:sql withParameters:@[@(readState)]];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    return count;
}

- (NSInteger)getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId {
    __block int count = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT Count(*) from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (Originto = '%@' and State < :State and Originfrom Like '%%%@%%') ORDER by LastUpdateTime;", bindId, originUserId];
        DataReader *reader = [database executeReader:sql withParameters:@[@(readState)]];
        if ([reader read]) {
            count = [[reader objectForColumnIndex:0] integerValue];
        }
    }];
    return count;
}

- (void)updateCollectionMsgNotReadStateByJid:(NSString *)jid WithMsgState:(NSInteger)msgState {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Update IM_Message Set ReadedTag = 1, State = :State Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[@(msgState), jid]];
    }];
}

- (void)updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithMsgState:(NSInteger)msgState{
    NSArray *msgList = [self getCollectionMsgListWithUserId:bindId originUserId:originUserId];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableString *sql = [NSMutableString stringWithString:@"Update IM_Message Set ReadedTag = 1, State = :State Where MsgId = :MsgId;"];
        NSMutableArray *params = nil;
        for (NSDictionary *msgDic in msgList) {
            NSString *msgId = [msgDic objectForKey:@"MsgId"];
            if (!params) {
                params = [NSMutableArray array];
            }
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:@(msgState)];
            [param addObject:msgId];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

- (NSDictionary *)getCollectionMsgListForMsgId:(NSString *)msgId {
    __block NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT *from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (a.MsgId = '%@') ORDER by LastUpdateTime", msgId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:7];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:9];
            NSNumber *platform = [reader objectForColumnIndex:6];
            NSNumber *msgType = [reader objectForColumnIndex:10];
            NSNumber *msgState = [reader objectForColumnIndex:11];
            NSNumber *msgDirection = [reader objectForColumnIndex:12];
            NSNumber *msgDateTime = [reader objectForColumnIndex:15];
            NSNumber *originType = [reader objectForColumnIndex:4];
            NSString * nickName = from;
            NSString * realJid = [reader objectForColumnIndex:19];
            NSString *extendInfo = [reader objectForColumnIndex:20];
            [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:msgDic setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:msgDic setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:msgDic setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:msgDic setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:msgDic setObject:originType forKey:@"originType"];
            [IMDataManager safeSaveForDic:msgDic setObject:nickName forKey:@"nickName"];
            [IMDataManager safeSaveForDic:msgDic setObject:realJid forKey:@"realJid"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
        }
    }];
    return [msgDic autorelease];
}

- (NSArray *)getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId{
    __block NSMutableArray *result = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT *from IM_Message_Collection as a left join IM_Message as b on a.MsgId = b.MsgId where (Originto = '%@' and Originfrom Like '%%%@%%') ORDER by LastUpdateTime", userId, originUserId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (result == nil) {
                result = [[NSMutableArray alloc] init];
            }
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:7];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:9];
            NSNumber *platform = [reader objectForColumnIndex:6];
            NSNumber *msgType = [reader objectForColumnIndex:10];
            NSNumber *msgState = [reader objectForColumnIndex:11];
            NSNumber *msgDirection = [reader objectForColumnIndex:12];
            NSNumber *msgDateTime = [reader objectForColumnIndex:15];
            NSNumber *originType = [reader objectForColumnIndex:4];
            NSString * nickName = from;
            NSString * realJid = [reader objectForColumnIndex:19];
            NSString * extendInfo = [reader objectForColumnIndex:20];
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
            [IMDataManager safeSaveForDic:msgDic setObject:originType forKey:@"originType"];
            [IMDataManager safeSaveForDic:msgDic setObject:nickName forKey:@"nickName"];
            [IMDataManager safeSaveForDic:msgDic setObject:realJid forKey:@"realJid"];
            [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
            [result addObject:msgDic];
            [msgDic release];
        }
        
    }];
    return [result autorelease];
}

/****************** FriendSter Msg *******************/
- (void)insertFSMsgWithMsgId:(NSString *)msgId
                  WithXmppId:(NSString *)xmppId
                WithFromUser:(NSString *)fromUser
              WithReplyMsgId:(NSString *)replyMsgId
               WithReplyUser:(NSString *)replyUser
                 WithContent:(NSString *)content
                 WihtMsgDate:(long long)msgDate
            WithExtendedFlag:(NSData *)etxtenedFlag{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or IGNORE into IM_Friendster_Message(MsgId, XmppId, FromUser,ReplyMsgId,ReplyUser,Content,LastUpdateTime,ExtendedFlag) values(:MsgId,:XmppId,:FromUser,:ReplyMsgId,:ReplyUser,:Content,:LastUpdateTime,:ExtendedFlag);";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:msgId?msgId:@":NULL"];
        [param addObject:xmppId?xmppId:@":NULL"];
        [param addObject:fromUser?fromUser:@":NULL"];
        [param addObject:replyMsgId?replyMsgId:@":NULL"];
        [param addObject:replyUser?replyUser:@":NULL"];
        [param addObject:content?content:@":NULL"];
        [param addObject:[NSNumber numberWithLongLong:msgDate]];
        [param addObject:etxtenedFlag?etxtenedFlag:@":NULL"];
        [database executeNonQuery:sql withParameters:param];
        [param release];
        param = nil;
    }];
}

- (void)bulkInsertFSMsgWithMsgList:(NSArray *)msgList{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"insert or IGNORE into IM_Friendster_Message(MsgId, XmppId,FromUser, ReplyMsgId,ReplyUser,Content,LastUpdateTime,ExtendedFlag) values(:MsgId, :XmppId, :FromUser,:ReplyMsgId, :ReplyUser, :Content, :LastUpdateTime, :ExtendedFlag);";
        NSMutableArray *paramList = [[NSMutableArray alloc] init];
        for (NSDictionary *msgDic in msgList) {
            NSString *msgId = [msgDic objectForKey:@"MsgId"];
            NSString *xmppId = [msgDic objectForKey:@"XmppId"];
            NSString *fromUser = [msgDic objectForKey:@"FromUser"];
            NSString *replyMsgId = [msgDic objectForKey:@"ReplyMsgId"];
            NSString *replyUser = [msgDic objectForKey:@"ReplyUser"];
            NSString *content = [msgDic objectForKey:@"Content"];
            NSNumber *msgDate = [msgDic objectForKey:@"MsgDate"];
            NSMutableArray *param = [[NSMutableArray alloc] init];
            [param addObject:msgId?msgId:@":NULL"];
            [param addObject:xmppId?xmppId:@":NULL"];
            [param addObject:fromUser?fromUser:@":NULL"];
            [param addObject:replyMsgId?replyMsgId:@":NULL"];
            [param addObject:replyUser?replyUser:@":NULL"];
            [param addObject:content?content:@":NULL"];
            [param addObject:msgDate];
            [param addObject:@":NULL"];
            [paramList addObject:param];
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:paramList];
        [paramList release];
        paramList = nil;
    }];
}

- (NSArray *)getFSMsgListByXmppId:(NSString *)xmppId{
    if (xmppId == nil) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSMutableDictionary *mainMsgDic = [[NSMutableDictionary alloc] init];
        NSString *sql = [NSString stringWithFormat:@"Select  b.MsgId,b.XmppId,b.'From',b.'To',b.Content,b.Type,b.State,b.Direction,b.ReadedTag,b.LastUpdateTime from  (Select ReplyMsgId From IM_Friendster_Message Where XmppId='%@' Group By ReplyMsgId) as a Left Join IM_Message as b on a.ReplyMsgId = b.MsgId;",xmppId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *from = [reader objectForColumnIndex:2];
            NSString *to = [reader objectForColumnIndex:3];
            NSString *content = [reader objectForColumnIndex:4];
            NSNumber *type = [reader objectForColumnIndex:5];
            NSNumber *state = [reader objectForColumnIndex:6];
            NSNumber *direction = [reader objectForColumnIndex:7];
            NSNumber *readerTag = [reader objectForColumnIndex:8];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:9];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:dic setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:dic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dic setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:dic setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:dic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:dic setObject:type forKey:@"Type"];
            [IMDataManager safeSaveForDic:dic setObject:state forKey:@"State"];
            [IMDataManager safeSaveForDic:dic setObject:direction forKey:@"Direction"];
            [IMDataManager safeSaveForDic:dic setObject:readerTag forKey:@"ReaderTag"];
            [IMDataManager safeSaveForDic:dic setObject:lastUpdateTime forKey:@"MsgDate"];
            [IMDataManager safeSaveForDic:dic setObject:[NSMutableArray array] forKey:@"ReplyMsgList"];
            [mainMsgDic setObject:dic forKey:msgId ? msgId : @""];
        }
        {
            NSString *sql = @"Select MsgId, XmppId, FromUser,ReplyMsgId,ReplyUser,Content,LastUpdateTime From IM_Friendster_Message Where XmppId=:XmppId Order By LastUpdateTime Desc;";
            DataReader *reader = [database executeReader:sql withParameters:@[xmppId]];
            while ([reader read]) {
                if (resultList == nil) {
                    resultList = [[NSMutableArray alloc] init];
                }
                NSString *msgId = [reader objectForColumnIndex:0];
                NSString *xmppId = [reader objectForColumnIndex:1];
                NSString *fromUser = [reader objectForColumnIndex:2];
                NSString *replyMsgId = [reader objectForColumnIndex:3];
                NSString *replyUser = [reader objectForColumnIndex:4];
                NSString *content = [reader objectForColumnIndex:5];
                NSNumber *lastUpdateTeim = [reader objectForColumnIndex:6];
                NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
                [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"xmppId"];
                [IMDataManager safeSaveForDic:msgDic setObject:fromUser forKey:@"fromUser"];
                [IMDataManager safeSaveForDic:msgDic setObject:replyMsgId forKey:@"replyMsgId"];
                [IMDataManager safeSaveForDic:msgDic setObject:replyUser forKey:@"replyUser"];
                [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"content"];
                [IMDataManager safeSaveForDic:msgDic setObject:lastUpdateTeim forKey:@"MsgDate"];
                NSMutableDictionary *dic = [mainMsgDic objectForKey:replyMsgId];
                if (dic) {
                    if ([resultList containsObject:dic] == NO) {
                        [resultList addObject:dic];
                    }
                    NSMutableArray *array = [dic objectForKey:@"ReplyMsgList"];
                    [array insertObject:msgDic atIndex:0];
                }
                [msgDic release];
                msgDic = nil;
            }
        }
    }];
    return  [resultList autorelease];
}

- (NSDictionary *)getFSMsgListByReplyMsgId:(NSString *)replyMsgId{
    if (replyMsgId == nil) {
        return nil;
    }
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql = @"Select MsgId,XmppId,\"From\",\"To\",Content,Type,State,Direction,ReadedTag,LastUpdateTime, ExtendInfo from IM_Message Where MsgId = :MsgId;";
        DataReader *reader = [database executeReader:sql withParameters:@[replyMsgId]];
        if ([reader read]) {
            resultDic = [[NSMutableDictionary alloc] init];
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *xmppId = [reader objectForColumnIndex:1];
            NSString *from = [reader objectForColumnIndex:2];
            NSString *to = [reader objectForColumnIndex:3];
            NSString *content = [reader objectForColumnIndex:4];
            NSNumber *type = [reader objectForColumnIndex:5];
            NSNumber *state = [reader objectForColumnIndex:6];
            NSNumber *direction = [reader objectForColumnIndex:7];
            NSNumber *readerTag = [reader objectForColumnIndex:8];
            NSNumber *lastUpdateTime = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
            [IMDataManager safeSaveForDic:resultDic setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:resultDic setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:resultDic setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:resultDic setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:resultDic setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:resultDic setObject:type forKey:@"Type"];
            [IMDataManager safeSaveForDic:resultDic setObject:state forKey:@"State"];
            [IMDataManager safeSaveForDic:resultDic setObject:direction forKey:@"Direction"];
            [IMDataManager safeSaveForDic:resultDic setObject:readerTag forKey:@"ReaderTag"];
            [IMDataManager safeSaveForDic:resultDic setObject:lastUpdateTime forKey:@"MsgDate"];
            [IMDataManager safeSaveForDic:resultDic setObject:extendInfo forKey:@"ExtendInfo"];
            [IMDataManager safeSaveForDic:resultDic setObject:[NSMutableArray array] forKey:@"ReplyMsgList"];
        }
        if (resultDic) {
            NSMutableArray *replyMsgList = [resultDic objectForKey:@"ReplyMsgList"];
            NSString *sql = @"Select MsgId, XmppId, FromUser, ReplyMsgId,ReplyUser,Content,LastUpdateTime From IM_Friendster_Message Where ReplyMsgId=:ReplyMsgId;";
            DataReader *reader = [database executeReader:sql withParameters:@[replyMsgId]];
            while ([reader read]) {
                NSString *msgId = [reader objectForColumnIndex:0];
                NSString *xmppId = [reader objectForColumnIndex:1];
                NSString *fromUser = [reader objectForColumnIndex:2];
                NSString *replyMsgId = [reader objectForColumnIndex:3];
                NSString *replyUser = [reader objectForColumnIndex:4];
                NSString *content = [reader objectForColumnIndex:5];
                NSNumber *lastUpdateTeim = [reader objectForColumnIndex:6];
                NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
                [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"xmppId"];
                [IMDataManager safeSaveForDic:msgDic setObject:fromUser forKey:@"fromUser"];
                [IMDataManager safeSaveForDic:msgDic setObject:replyMsgId forKey:@"replyMsgId"];
                [IMDataManager safeSaveForDic:msgDic setObject:replyUser forKey:@"replyUser"];
                [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"content"];
                [IMDataManager safeSaveForDic:msgDic setObject:lastUpdateTeim forKey:@"MsgDate"];
                [replyMsgList addObject:msgDic];
                [msgDic release];
                msgDic = nil;
            }
        }
        
    }];
    return [resultDic autorelease];
}

- (long long)qimDB_updateGroupMsgWihtMsgState:(int)msgState ByGroupMsgList:(NSArray *)groupMsgList{
    __block long long maxReadMarkTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set State = :State1 Where LastUpdateTime <= :LastUpdateTime And XmppId=:XmppId And State < :State2 And Direction = 1 And State != 1 And State != 3;";
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *msgInfo in groupMsgList) {
            NSString *groupName = [msgInfo objectForKey:@"id"];
            NSString *domain = [msgInfo objectForKey:@"domain"];
            if (domain == nil) {
                domain = [NSString stringWithFormat:@"conference.%@", _domain];
            }
            NSString *groupId = [NSString stringWithFormat:@"%@@%@",groupName,domain];
            long long time = [[msgInfo objectForKey:@"t"] longLongValue];
            if (maxReadMarkTime < time) {
                maxReadMarkTime = time;
            }
            [paramList addObject:@[@(msgState), @(time), groupId, @(msgState)]];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    return maxReadMarkTime;
}

- (void)updateUserMsgWihtMsgState:(int)msgState ByMsgList:(NSArray *)userMsgList{
    
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set State = :State1 Where LastUpdateTime <= :LastUpdateTime And XmppId=:XmppId And State <> :State2;";
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *msgInfo in userMsgList) {
            NSString *xmppId = [msgInfo objectForKey:@"u"];
            if (xmppId) {
                [paramList addObject:@[@(msgState),@([[msgInfo objectForKey:@"t"] longLongValue]),[[msgInfo objectForKey:@"u"] stringByAppendingFormat:@"@%@",_domain],@(msgState)]];
            }
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    
}

- (void)bulkUpdateChatMsgWithMsgState:(int)msgState ByMsgIdList:(NSArray *)msgIdList{
    
    if (!msgIdList.count) {
        return;
    }
    QIMVerboseLog(@"新状态 : %ld, msgIdList : %@", msgState, msgIdList);
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set State = :State1 Where MsgId=:MsgId And State < :State2;";
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *msgInfo in msgIdList) {
            [paramList addObject:@[@(msgState),[msgInfo objectForKey:@"id"], @(msgState)]];
        }

        BOOL success = [database executeBulkInsert:sql withParameters:paramList];
        if (success) {
            QIMVerboseLog(@"更新消息状态的参数成功 : %@", paramList);
        }
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"更新%ld条消息的MsgState状态 耗时 = %f s", msgIdList.count, end - start); //
}

- (NSArray *)getReceiveMsgIdListWithMsgState:(int)msgState WithReceiveDirection:(int)receiveDirection {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"SELECT a.'XmppId', GROUP_CONCAT(MsgId) as msgIdList FROM IM_Message as a WHERE a.state = %d AND a.Direction = %d And a.XmppId NOT LIKE '%%conference.%%' GROUP By a.'XmppId';", msgState, receiveDirection];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            NSString *msgIds = [reader objectForColumnIndex:1];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:dict setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:dict setObject:msgIds forKey:@"MsgIds"];
            [resultList addObject:dict];
            [dict release];
            dict = nil;
        }
    }];
    return [resultList autorelease];
}

- (NSArray *)getNotReadMsgListWithMsgState:(int)msgState WithReceiveDirection:(int)receiveDirection{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql =[NSString stringWithFormat:@"Select XmppId, NotReadCount From (Select XmppId,Count(*) as NotReadCount From IM_Message Where State <> %d And Direction= %d Group By XmppId Order By LastUpdateTime Desc) Where NotReadCount > 0;",msgState,receiveDirection];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        NSMutableArray *xmppIdList = nil;
        while ([reader read]) {
            if (xmppIdList == nil) {
                xmppIdList = [NSMutableArray array];
            }
            NSString *xmppId = [reader objectForColumnIndex:0];
            [xmppIdList addObject:xmppId];
        }
        for (NSString *xmppId in xmppIdList) {
            NSString *sql = @"Select MsgId,a.XmppId,\"From\",Type,Content,Direction,a.LastUpdateTime,b.Name, extendInfo From IM_Message as a Left Join IM_User as b on a.XmppId = b.XmppId Where a.XmppId =:XmppId And Type <> 101 Order By a.LastUpdateTime Desc Limit 1;";
            reader = [database executeReader:sql withParameters:@[xmppId]];
            if ([reader read]) {
                if (resultList == nil) {
                    resultList = [[NSMutableArray alloc] init];
                }
                NSString *msgId = [reader objectForColumnIndex:0];
                NSString *xmppId = [reader objectForColumnIndex:1];
                NSString *from = [reader objectForColumnIndex:2];
                NSNumber *type = [reader objectForColumnIndex:3];
                NSString *content = [reader objectForColumnIndex:4];
                NSNumber *direction = [reader objectForColumnIndex:5];
                NSNumber *msgDateTime = [reader objectForColumnIndex:6];
                NSString *name = [reader objectForColumnIndex:7];
                NSString *extendInfo = [reader objectForColumnIndex:8];
                NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
                [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
                [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"XmppId"];
                [IMDataManager safeSaveForDic:msgDic setObject:from forKey:@"NickName"];
                [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"Content"];
                [IMDataManager safeSaveForDic:msgDic setObject:type forKey:@"MsgType"];
                [IMDataManager safeSaveForDic:msgDic setObject:direction forKey:@"MsgDirection"];
                [IMDataManager safeSaveForDic:msgDic setObject:msgDateTime forKey:@"MsgDateTime"];
                [IMDataManager safeSaveForDic:msgDic setObject:name forKey:@"Name"];
                [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
                [resultList addObject:msgDic];
                [msgDic release];
                msgDic = nil;
            }
        }
    }];
    return [resultList autorelease];
}

- (void)clearHistoryMsg{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Message;";
        [database executeNonQuery:sql withParameters:nil];
    }];
}

- (void)updateSystemMsgState:(int)msgState WithXmppId:(NSString *)xmppId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set State=:State Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[@(msgState),xmppId]];
    }];
}


- (void)updateAllMsgWithMsgState:(int)msgState ByMsgDirection:(int)msgDirection ByReadMarkT:(long long)readMarkT{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Message Set State=:State Where Direction = :Direction And LastUpdateTime <= :LastUpdateTime;";
        [database executeNonQuery:sql withParameters:@[@(msgState),@(msgDirection),@(readMarkT)]];
    }];
}

- (void)closeDataBase{
    __global_data_manager = nil;
    BOOL result = [DatabaseManager CloseByFullPath:_dbPath];
    if (result) {
        __global_data_manager = nil;
    }
}

+ (void)clearDataBaseCache{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"dbVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)qimDB_dbCheckpoint {
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        [database dbCheckpoint];
    }];
}

/*************** Friend List *************/
- (int)getFriendListMaxIncrementVersion{
    __block int maxIncrementVersion = 0;
    return maxIncrementVersion;
}

- (void)bulkInsertFriendList:(NSArray *)friendList{
    if (friendList.count <= 0) {
        return;
    }
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
            [param release];
            param = nil;
        }
        [database executeNonQuery:deleteSql withParameters:nil];
        [database executeBulkInsert:sql withParameters:params];
        [params release];
        params = nil;
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"插入好友列表%ld条数据 耗时 = %f s", friendList.count, end - start); //s
}

- (void)insertFriendWithUserId:(NSString *)userId
                    WithXmppId:(NSString *)xmppId
                      WithName:(NSString *)name
               WithSearchIndex:(NSString *)searchIndex
                  WithDescInfo:(NSString *)descInfo
                   WithHeadSrc:(NSString *)headerSrc
                  WithUserInfo:(NSData *)userInfo
            WithLastUpdateTime:(long long)lastUpdateTime
          WithIncrementVersion:(int)incrementVersion{
    if (userId.length <= 0) {
        return;
    }
    [[self dbInstance] usingTransaction:^(Database *database) {
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
}

- (void)deleteFriendListWithXmppId:(NSString *)xmppId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Friend_List Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[xmppId]];
    }];
}

- (void)deleteFriendListWithUserId:(NSString *)userId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Friend_List Where UserId=:UserId;";
        [database executeNonQuery:sql withParameters:@[userId]];
    }];
}

- (void)deleteFriendList{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *deleteSql = @"Delete From IM_Friend_List;";
        [database executeNonQuery:deleteSql withParameters:nil];
    }];
}

- (void)deleteSessionList{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *deleteSql = @"Delete From IM_SessionList;";
        [database executeNonQuery:deleteSql withParameters:nil];
    }];
}

- (NSMutableArray *)selectFriendList{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
            [paramDic release];
            paramDic = nil;
        }
    }];
    return [resultList autorelease];
}

- (NSMutableArray *)qimDB_selectFriendListInGroupId:(NSString *)groupId {
    if (groupId.length <= 0) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = [NSString stringWithFormat:@"select a.UserId,a.XmppId,b.Name,b.HeaderSrc,b.SearchIndex from IM_Friend_List as a join IM_User as b where a.XmppId = b.XmppId and a.XmppId NOT IN(select MemberJid from IM_Group_Member where GroupId = '%@');", groupId];
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
            [paramDic release];
            paramDic = nil;
        }
    }];
    return [resultList autorelease];
}

- (NSDictionary *)selectFriendInfoWithUserId:(NSString *)userId{
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo From IM_Friend_List Where XmppId=:XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[userId]];
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
    }];
    return [resultDic autorelease];
}

- (NSDictionary *)selectFriendInfoWithXmppId:(NSString *)xmppId{
    __block NSMutableDictionary *resultDic = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo From IM_Friend_List Where XmppId=:XmppId;";
        DataReader *reader = [database executeReader:sql withParameters:@[xmppId]];
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
    }];
    return [resultDic autorelease];
}

- (void)bulkInsertNotifyList:(NSArray *)notifyList{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
        params = nil;
    }];
}

- (void)bulkInsertFriendNotifyList:(NSArray *)notifyList{
    [[self dbInstance] usingTransaction:^(Database *database) {
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
            [param release];
            param = nil;
        }
        [database executeBulkInsert:sql withParameters:params];
        [params release];
    }];
}
- (void)insertFriendNotifyWihtUserId:(NSString *)userId
                          WithXmppId:(NSString *)xmppId
                            WithName:(NSString *)name
                        WithDescInfo:(NSString *)descInfo
                         WithHeadSrc:(NSString *)headerSrc
                     WithSearchIndex:(NSString *)searchIndex
                        WihtUserInfo:(NSString *)userInfo
                         WithVersion:(int)version
                           WihtState:(int)state
                  WithLastUpdateTime:(long long)lastUpdateTime{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
}

- (void)deleteFriendNotifyWithUserId:(NSString *)userId{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Delete From IM_Friend_Notify Where UserId=:UserId;";
        [database executeNonQuery:sql withParameters:@[userId]];
    }];
}

- (NSMutableArray *)selectFriendNotifys{
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
            [paramDic release];
            paramDic = nil;
        }
    }];
    return [resultList autorelease];
}


- (NSDictionary *)getLastFriendNotify;{
    __block NSMutableDictionary *friendNotify = nil;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
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
    }];
    return [friendNotify autorelease];
}

- (int)getFriendNotifyCount {
    
    __block int FriendNotifyCount = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select UserId,XmppId,Name,DescInfo,HeaderSrc,UserInfo,State,LastUpdateTime From IM_Friend_Notify Order By LastUpdateTime Desc;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSNumber *state = [reader objectForColumnIndex:6];
            if ([state isEqualToNumber:@(0)]) {
                FriendNotifyCount++;
            }
        }
    }];
    return FriendNotifyCount;
}

- (void)updateFriendNotifyWithXmppId:(NSString *)xmppId WihtState:(int)state{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Friend_Notify Set State = :State Where XmppId=:XmppId;";
        [database executeNonQuery:sql withParameters:@[@(state),xmppId]];
    }];
}

- (void)updateFriendNotifyWithUserId:(NSString *)userId WihtState:(int)state{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Friend_Notify Set State = :State Where UserId=:UserId;";
        [database executeNonQuery:sql withParameters:@[@(state),userId]];
    }];
}

- (long long)getMaxTimeFriendNotify{
    __block long long maxTime = 0;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select Max(LastUpdateTime) From IM_Friend_Notify;";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        if ([reader read]) {
            maxTime = [[reader objectForColumnIndex:0] longLongValue];
        }
    }];
    return maxTime;
}

/*********************** Group Message State **************************/
- (void)qimDB_bulkUpdateGroupPushState:(NSArray *)stateList{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set PushState = :PushState Where GroupId = :GroupId;";
        NSMutableArray *params = nil;
        for (NSDictionary *stateDic in stateList) {
            NSString *groupName = [stateDic objectForKey:@"muc_name"];
            NSString *domain = [stateDic objectForKey:@"domain"];
            NSString *groupId = [NSString stringWithFormat:@"%@@%@",groupName,domain];
            int state = [[stateDic objectForKey:@"subscribe_flag"] intValue];
            if (params == nil) {
                params = [NSMutableArray array];
            }
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:@(state)];
            [param addObject:groupId];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"更新群勿扰模式列表%ld条数据 耗时 = %f s", stateList.count, end - start); //s
}

- (long long)qimDB_bulkUpdateGroupMessageReadFlag:(NSArray *)mucArray {

    if (mucArray.count <= 0) {
        return 0;
    }
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSString *sql = [NSString stringWithFormat:@"Update IM_Message Set ReadedTag = 1, State = 16 Where XmppId = :XmppId And LastUpdateTime <= :LastUpdateTime And ReadedTag = 0 And State < 16;"];
    __block long long maxRemarkUpdateTime = 0;
    [[self dbInstance] usingTransaction:^(Database *database) {
        NSMutableArray *params = nil;
        for (NSDictionary *mucDic in mucArray) {
            NSString *domain = [mucDic objectForKey:@"domain"];
            NSString *mucName = [mucDic objectForKey:@"muc_name"];
            NSString *groupId = [mucName stringByAppendingFormat:@"@%@", domain];
            long long mucLastReadFlagTime = [[mucDic objectForKey:@"date"] longLongValue];
            if (maxRemarkUpdateTime < mucLastReadFlagTime) {
                maxRemarkUpdateTime = mucLastReadFlagTime;
            }
            if (params == nil) {
                params = [NSMutableArray array];
            }
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:groupId?groupId:@""];
            [param addObject:@(mucLastReadFlagTime)];
            [params addObject:param];
        }
        QIMVerboseLog(@"更新群阅读指针参数 ：%@", params);
        [database executeBulkInsert:sql withParameters:params];
    }];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"更新群阅读指针%ld条数据 耗时 = %f s", mucArray.count, end - start); //s
    return maxRemarkUpdateTime;
}

- (int)getGroupPushStateWithGroupId:(NSString *)groupId{
    if (groupId == nil) {
        return 1;
    }
    __block int state = 1;
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Select PushState From IM_Group Where GroupId = :GroupId;";
        DataReader *reader = [database executeReader:sql withParameters:@[groupId]];
        if ([reader read]) {
            NSNumber *stateNum = [reader objectForColumnIndex:0];
            if (stateNum) {
                state = [stateNum intValue];
            }
        }
    }];
    return state;
}

- (void)updateGroup:(NSString *)groupId WithPushState:(int)pushState{
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"Update IM_Group Set PushState = :PushState Where GroupId = :GroupId;";
        [database executeNonQuery:sql withParameters:@[@(pushState),groupId]];
    }];
}


#pragma mark - 本地消息搜索

- (NSArray *)qimDB_getLocalMediaByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    __block NSMutableArray * msgs = [NSMutableArray arrayWithCapacity:1];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"";
        if (realJid.length > 0) {
            sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where XmppId = '%@' And RealJid = '%@' And (Type = 32 Or Content Like '%%%@%%') Order By LastUpdateTime DESC;", xmppId, realJid, [NSString stringWithFormat:@"obj type=\"image"]];
        } else {
            sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where XmppId = '%@' And (Type = 32 Or Content Like '%%%@%%') Order By LastUpdateTime DESC;", xmppId, [NSString stringWithFormat:@"obj type=\"image"]];
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSString *xmppId = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
            [IMDataManager safeSaveForDic:result setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:result setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:result setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:result setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:result setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:result setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:result setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:result setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:result setObject:extendInfo forKey:@"ExtendInfo"];
            [msgs addObject:result];
        }
    }];
    return msgs;
}

- (NSArray *)qimDB_getMsgsByKeyWord:(NSString *)keywords ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    
    __block NSMutableArray * msgs = [NSMutableArray arrayWithCapacity:1];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"";
        if (realJid.length > 0) {
            sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where XmppId = '%@' And RealJid = '%@' And Content like '%%%@%%'  Order By LastUpdateTime DESC limit(1000);", xmppId, realJid, keywords];
        } else {
            sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where XmppId = '%@' And Content like '%%%@%%' Order By LastUpdateTime DESC limit(1000);", xmppId, keywords];
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        while ([reader read]) {
            NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSString *xmppId = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
            [IMDataManager safeSaveForDic:result setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:result setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:result setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:result setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:result setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:result setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:result setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:result setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:result setObject:extendInfo forKey:@"ExtendInfo"];
            [msgs addObject:result];
        }
    }];
    return msgs;
}

- (NSArray *)qimDB_getMsgsByMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    
    __block NSMutableArray * msgs = [NSMutableArray arrayWithCapacity:1];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        NSString *sql = @"";
        if (realJid.length > 0) {
            sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where XmppId = '%@' And RealJid = '%@' And (", xmppId, realJid];
            for (NSInteger i = 0; i < msgTypes.count; i++) {
                NSInteger msgType = [[msgTypes objectAtIndex:i] integerValue];
                if (i == 0) {
                   sql = [sql stringByAppendingFormat:[NSString stringWithFormat:@"Type = %d", msgType]];
                } else {
                   sql = [sql stringByAppendingFormat:[NSString stringWithFormat:@" Or Type = %d", msgType]];
                }
            }
            sql = [sql stringByAppendingFormat:@") Order By LastUpdateTime DESC;"];
        } else {
            sql = [NSString stringWithFormat:@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where XmppId = '%@' And (", xmppId];
            for (NSInteger i = 0; i < msgTypes.count; i++) {
                NSInteger msgType = [[msgTypes objectAtIndex:i] integerValue];
                if (i == 0) {
                    sql = [sql stringByAppendingFormat:[NSString stringWithFormat:@"Type = %d", msgType]];
                } else {
                    sql = [sql stringByAppendingFormat:[NSString stringWithFormat:@" Or Type = %d", msgType]];
                }
            }
            sql = [sql stringByAppendingFormat:@") Order By LastUpdateTime DESC;"];
        }
        DataReader *reader = [database executeReader:sql withParameters:nil];
        
        while ([reader read]) {
            NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSString *xmppId = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
            [IMDataManager safeSaveForDic:result setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:result setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:result setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:result setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:result setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:result setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:result setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:result setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:result setObject:extendInfo forKey:@"ExtendInfo"];
            [msgs addObject:result];
        }
    }];
    return msgs;
}

- (NSArray *)qimDB_getMsgsByMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId {
    return [self qimDB_getMsgsByMsgType:msgTypes ByXmppId:xmppId ByReadJid:nil];
}

- (NSArray *)qimDB_getMsgsByMsgType:(int)msgType{
    __block NSMutableArray * msgs = [NSMutableArray arrayWithCapacity:1];
    [[self dbInstance] syncUsingTransaction:^(Database *database) {
        
        NSString *sql =@"Select MsgId, \"From\", \"To\", Content, Platform, Type, State, Direction,LastUpdateTime,XmppId, ExtendInfo From IM_Message Where Type=:Type Order By LastUpdateTime DESC;";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:[NSNumber numberWithInt:msgType]];
        DataReader *reader = [database executeReader:sql withParameters:param];
        [param release];
        param = nil;
        
        while ([reader read]) {
            NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
            NSString *msgId = [reader objectForColumnIndex:0];
            NSString *from = [reader objectForColumnIndex:1];
            NSString *to = [reader objectForColumnIndex:2];
            NSString *content = [reader objectForColumnIndex:3];
            NSNumber *platform = [reader objectForColumnIndex:4];
            NSNumber *msgType = [reader objectForColumnIndex:5];
            NSNumber *msgState = [reader objectForColumnIndex:6];
            NSNumber *msgDirection = [reader objectForColumnIndex:7];
            NSNumber *msgDateTime = [reader objectForColumnIndex:8];
            NSString *xmppId = [reader objectForColumnIndex:9];
            NSString *extendInfo = [reader objectForColumnIndex:10];
            [IMDataManager safeSaveForDic:result setObject:xmppId forKey:@"XmppId"];
            [IMDataManager safeSaveForDic:result setObject:msgId forKey:@"MsgId"];
            [IMDataManager safeSaveForDic:result setObject:from forKey:@"From"];
            [IMDataManager safeSaveForDic:result setObject:to forKey:@"To"];
            [IMDataManager safeSaveForDic:result setObject:content forKey:@"Content"];
            [IMDataManager safeSaveForDic:result setObject:platform forKey:@"Platform"];
            [IMDataManager safeSaveForDic:result setObject:msgType forKey:@"MsgType"];
            [IMDataManager safeSaveForDic:result setObject:msgState forKey:@"MsgState"];
            [IMDataManager safeSaveForDic:result setObject:msgDirection forKey:@"MsgDirection"];
            [IMDataManager safeSaveForDic:result setObject:msgDateTime forKey:@"MsgDateTime"];
            [IMDataManager safeSaveForDic:result setObject:extendInfo forKey:@"ExtendInfo"];
            [msgs addObject:result];
        }
    }];
    return msgs;
}


@end
