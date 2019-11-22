//
//  STIMKit+STIMUserMedal.h
//  STIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMUserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId;

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId;

/**
 修改勋章佩戴状态
 
 @param status 勋章佩戴状态
 @param medalId 勋章Id
 */
- (void)userMedalStatusModifyWithStatus:(NSInteger)status withMedalId:(NSInteger)medalId withCallBack:(STIMKitUpdateMedalStatusCallBack)callback;

#pragma mark - Local UserMedal

- (NSDictionary *)getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId;

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId;

- (NSArray *)getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset;

- (NSArray *)getUserWearMedalSmallIconListByUserid:(NSString *)xmppId;

- (NSArray *)getUserHaveMedalSmallIconListByUserid:(NSString *)xmppId;

@end
