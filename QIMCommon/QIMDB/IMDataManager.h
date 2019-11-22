//
//  IMDataManager.h
//  qunarChatIphone
//
//  Created by ping.xue on 14-3-19.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIMCommonEnum.h"
#import "STIMPublicRedefineHeader.h"
#import <QIMCommonCategories/STIMCommonCategories.h>
#import "STIMDataBasePool.h"
#import "STIMDataBaseQueue.h"
#import "STIMDataBase.h"

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

@property (nonatomic, strong) STIMDataBasePool *databasePool;

@property (nonatomic, strong) STIMDataBaseQueue *dataBaseQueue;

+ (IMDataManager *) stIMDB_SharedInstance;
+ (IMDataManager *) stIMDB_sharedInstanceWithDBPath:(NSString *)dbPath withDBFullJid:(NSString *)dbOwnerFullJid;

- (NSString *)getDbOwnerFullJid;

- (NSString *)getDBOwnerDomain;

+ (void)safeSaveForDic:(NSMutableDictionary *)dic setObject:(id)value forKey:(id)key;

- (NSString *) OriginalUUID;

- (NSString *)UUID;

- (id)initWithDBPath:(NSString *)dbPath;

- (id)dbInstance;

- (void)stIMDB_closeDataBase;

+ (void)stIMDB_clearDataBaseCache;
- (void)stIMDB_dbCheckpoint;

- (NSInteger)stIMDB_parserplatForm:(NSString *)platFormStr;

- (void)stIMDB_InsertUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type withValue:(NSString *)value withValueInt:(long long)valueInt;

- (void)stIMDB_UpdateUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type withValue:(NSString *)value withValueInt:(long long)valueInt;

- (long long)stIMDB_getUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type;

- (BOOL)stIMDB_checkExistUserCacheDataWithKey:(NSString *)key withType:(NSInteger)type;

@end
