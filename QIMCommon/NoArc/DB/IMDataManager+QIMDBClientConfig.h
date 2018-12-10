//
//  IMDataManager+QIMDBClientConfig.h
//  QIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "IMDataManager.h"

@interface IMDataManager (QIMDBClientConfig)

- (void)qimDB_clearClientConfig;

- (NSInteger)qimDB_getConfigVersion;

- (void)qimDB_deleteConfigWithConfigKey:(NSString *)configKey;

- (NSInteger)qimDB_getConfigDeleteFlagWithConfigKey:(NSString *)configKey WithSubKey:(NSString *)subKey;

- (NSString *)qimDB_getConfigInfoWithConfigKey:(NSString *)configKey WithSubKey:(NSString *)subKey WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)qimDB_getConfigDicWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)qimDB_getConfigInfoArrayWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)qimDB_getConfigValueArrayWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag;

- (void)qimDB_bulkInsertConfigArrayWithConfigKey:(NSString *)configKey WithConfigVersion:(NSInteger)configVersion ConfigArray:(NSArray *)configArray;

- (NSMutableArray *)qimDB_getConfigArrayStarOrBlackContacts:(NSString *)pkey;

- (NSMutableArray *)qimDB_getConfigArrayFriendsNotInStarContacts;

- (NSMutableArray *)qimDB_getConfigArrayUserNotInStartContacts:(NSString *)key;

@end
