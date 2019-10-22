//
//  IMDataManager+QIMUserMedal.h
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+QIMSession.h"
#import "IMDataManager+QIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+QIMDBClientConfig.h"
#import "IMDataManager+QIMDBQuickReply.h"
#import "IMDataManager+QIMNote.h"
#import "IMDataManager+QIMDBGroup.h"
#import "IMDataManager+QIMDBFriend.h"
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMUserMedal)

- (NSArray *)qimDB_getUserMedalsWithXmppId:(NSString *)xmppId;

- (void)qimDB_bulkInsertUserMedalsWithData:(NSArray *)userMedals;


/**************************************新版勋章********************************/

/// 插入勋章列表增量更新版本号
/// @param medalListVersion 版本号
- (void)qimDB_updateMedalListVersion:(NSInteger)value;

/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectMedalListVersion;

/// 插入用户勋章更新增量版本号
/// @param medalListVersion 版本号
- (void)qimDB_updateUserMedalStatusVersion:(NSInteger)userMedalStatusVersion;

/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectUserMedalStatusVersion;

/// 插入勋章列表
/// @param medalList 勋章列表List
- (void)qimDB_bulkInsertMedalList:(NSArray *)medalList;


/// 插入用户勋章
/// @param medalList 用户勋章列表List
- (void)qimDB_bulkInsertUserMedalList:(NSArray *)medalList;

- (void)qimDB_updateUserMedalStatus:(NSDictionary *)userMedalDic;


- (NSArray *)qimDB_selectUserHaveMedalStatus:(NSString *)userId;

/// 获取某用户下的某勋章
/// @param medalId 勋章Id
/// @param userId 用户Id
/// @param host 用户Host
- (NSDictionary *)qimDB_getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId;

- (NSArray *)qimDB_selectUserWearMedalStatusByUserid:(NSString *)userId;

- (NSArray *)qimDB_getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
