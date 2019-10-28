//
//  QIMManager+UserMedal.h
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMManager (UserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId;

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId;


/**************************************新版勋章********************************/

/**
 修改勋章佩戴状态
 
 @param status 勋章佩戴状态
 @param medalId 勋章Id
 */
- (void)userMedalStatusModifyWithStatus:(NSInteger)status withMedalId:(NSInteger)medalId withCallBack:(QIMKitUpdateMedalStatusCallBack)callback;

/**
 获取这个勋章下的所有用户
 */
- (void)getAllMedalUser;

/**
 * 获取用户勋章列表
 *  @param
 * @param callback
 */
- (void)getRemoteUserMedalListWithUserId:(NSString *)userId;

/**
 获取远程勋章列表
 */
- (void)getRemoteMedalList;

#pragma mark - Local UserMedal

- (NSDictionary *)getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId;

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId;

- (NSArray *)getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset;

- (NSArray *)getUserWearMedalSmallIconListByUserid:(NSString *)xmppId;

- (NSArray *)getUserHaveMedalSmallIconListByUserid:(NSString *)xmppId;

@end

NS_ASSUME_NONNULL_END
