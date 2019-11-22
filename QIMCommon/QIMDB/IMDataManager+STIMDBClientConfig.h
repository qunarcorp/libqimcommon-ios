//
//  IMDataManager+STIMDBClientConfig.h
//  STIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

@interface IMDataManager (STIMDBClientConfig)

- (void)stIMDB_clearClientConfig;

- (NSInteger)stIMDB_getConfigVersion;

- (void)stIMDB_deleteConfigWithConfigKey:(NSString *)configKey;

- (NSInteger)stIMDB_getConfigDeleteFlagWithConfigKey:(NSString *)configKey WithSubKey:(NSString *)subKey;

- (NSString *)stIMDB_getConfigInfoWithConfigKey:(NSString *)configKey WithSubKey:(NSString *)subKey WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)stIMDB_getConfigDicWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)stIMDB_getConfigInfoArrayWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)stIMDB_getConfigValueArrayWithConfigKey:(NSString *)configKey WithDeleteFlag:(BOOL)deleteFlag;

- (void)stIMDB_bulkInsertConfigArrayWithConfigKey:(NSString *)configKey WithConfigVersion:(NSInteger)configVersion ConfigArray:(NSArray *)configArray;

- (NSMutableArray *)stIMDB_getConfigArrayStarOrBlackContacts:(NSString *)pkey;

- (NSMutableArray *)stIMDB_getConfigArrayFriendsNotInStarContacts;

- (NSMutableArray *)stIMDB_getConfigArrayUserNotInStartContacts:(NSString *)key;

@end
