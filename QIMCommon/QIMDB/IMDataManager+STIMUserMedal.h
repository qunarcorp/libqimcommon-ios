//
//  IMDataManager+STIMUserMedal.h
//  STIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMUserMedal)

- (NSArray *)stIMDB_getUserMedalsWithXmppId:(NSString *)xmppId;

- (void)stIMDB_bulkInsertUserMedalsWithData:(NSArray *)userMedals;


/**************************************新版勋章********************************/

/// 插入勋章列表增量更新版本号
/// @param medalListVersion 版本号
- (void)stIMDB_updateMedalListVersion:(NSInteger)value;

/**
 查询勋章列表版本号
 */
- (NSInteger)stIMDB_selectMedalListVersion;

/// 插入用户勋章更新增量版本号
/// @param medalListVersion 版本号
- (void)stIMDB_updateUserMedalStatusVersion:(NSInteger)userMedalStatusVersion;

/**
 查询勋章列表版本号
 */
- (NSInteger)stIMDB_selectUserMedalStatusVersion;

/// 插入勋章列表
/// @param medalList 勋章列表List
- (void)stIMDB_bulkInsertMedalList:(NSArray *)medalList;


/// 插入用户勋章
/// @param medalList 用户勋章列表List
- (void)stIMDB_bulkInsertUserMedalList:(NSArray *)medalList;

- (void)stIMDB_updateUserMedalStatus:(NSDictionary *)userMedalDic;


- (NSArray *)stIMDB_selectUserHaveMedalStatus:(NSString *)userId;

/// 获取某用户下的某勋章
/// @param medalId 勋章Id
/// @param userId 用户Id
/// @param host 用户Host
- (NSDictionary *)stIMDB_getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId;

- (NSArray *)stIMDB_selectUserWearMedalStatusByUserid:(NSString *)userId;

- (NSArray *)stIMDB_getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
