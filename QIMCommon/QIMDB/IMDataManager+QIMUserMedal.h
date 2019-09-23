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

/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectMedalListVersion;

/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectUserMedalStatusVersion;

/// 插入勋章列表
/// @param medalList 勋章列表List
- (void)qimDB_bulkInsertMedalList:(NSArray *)medalList;

/**
 * 查询勋章列表版本号
 *
 * @return
 */
- (NSArray *)qimDB_selectUserHaveMedalStatus:(NSString *)userId;

- (NSArray *)qimDB_selectUserWearMedalStatusByUserid:(NSString *)userId;

- (void)qimDB_updateMedalListVersion:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
