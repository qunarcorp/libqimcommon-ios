//
//  IMDataManager.h
//  qunarChatIphone
//
//  Created by ping.xue on 14-3-19.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"
#import "QIMPublicRedefineHeader.h"
#import <QIMCommonCategories/QIMCommonCategories.h>
#import "QIMDataBasePool.h"
#import "QIMDataBaseQueue.h"
#import "QIMDataBase.h"

@class UserInfo;

@interface IMDataManager : NSObject

@property (nonatomic, copy) NSString *dbPath;
@property (nonatomic, copy) NSString *dbOwnerDomain;
@property (nonatomic, copy) NSString *dbOwnerFullJid;

//@property (nonatomic, strong) NSString *dbOwnerId;  //数据库所有者Id
//
//@property (nonatomic, copy) NSString *dbOwnerDomain;  //数据库z所有者Domain
//
//@property (nonatomic, copy) NSString *dbOwnerFullJid;   //数据库所有者XmppId

@property (nonatomic, strong) NSDateFormatter *timeSmtapFormatter;

@property (nonatomic, strong) QIMDataBasePool *databasePool;

@property (nonatomic, strong) QIMDataBaseQueue *dataBaseQueue;

+ (IMDataManager *) qimDB_SharedInstance;
+ (IMDataManager *) qimDB_sharedInstanceWithDBPath:(NSString *)dbPath withDBFullJid:(NSString *)dbOwnerFullJid;

- (NSString *)getDbOwnerFullJid;

- (NSString *)getDBOwnerDomain;

+ (void)safeSaveForDic:(NSMutableDictionary *)dic setObject:(id)value forKey:(id)key;

- (NSString *) OriginalUUID;

- (NSString *)UUID;

- (id)initWithDBPath:(NSString *)dbPath;

- (id)dbInstance;

- (void)qimDB_closeDataBase;

+ (void)qimDB_clearDataBaseCache;
- (void)qimDB_dbCheckpoint;

- (NSInteger)qimDB_parserplatForm:(NSString *)platFormStr;

- (NSArray *)qimDB_getAllTables;

- (void)qimDB_InsertUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type withValue:(NSString *)value withValueInt:(long long)valueInt;

- (void)qimDB_UpdateUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type withValue:(NSString *)value withValueInt:(long long)valueInt;

- (long long)qimDB_getUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type;

- (BOOL)qimDB_checkExistUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type;

@end
