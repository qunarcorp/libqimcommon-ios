//
//  STIMKit+STIMUserMedal.m
//  STIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMKit+STIMUserMedal.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMUserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId {
    return [[STIMManager sharedInstance] getLocalUserMedalWithXmppJid:xmppId];
}

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId {
    [[STIMManager sharedInstance] getRemoteUserMedalWithXmppJid:xmppId];
}

/**
 修改勋章佩戴状态
 
 @param status 勋章佩戴状态
 @param medalId 勋章Id
 */
- (void)userMedalStatusModifyWithStatus:(NSInteger)status withMedalId:(NSInteger)medalId withCallBack:(STIMKitUpdateMedalStatusCallBack)callback {
    [[STIMManager sharedInstance] userMedalStatusModifyWithStatus:status withMedalId:medalId withCallBack:callback];
}

#pragma mark - Local UserMedal

- (NSDictionary *)getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] getUserMedalWithMedalId:medalId withUserId:userId];
}

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId {
    return [[STIMManager sharedInstance] getUserWearMedalStatusByUserid:userId];
}

- (NSArray *)getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset {
    return [[STIMManager sharedInstance] getUsersInMedal:medalId withLimit:limit withOffset:offset];
}

- (NSArray *)getUserWearMedalSmallIconListByUserid:(NSString *)xmppId {
    return [[STIMManager sharedInstance] getUserWearMedalSmallIconListByUserid:xmppId];
}

- (NSArray *)getUserHaveMedalSmallIconListByUserid:(NSString *)xmppId {
    return [[STIMManager sharedInstance] getUserHaveMedalSmallIconListByUserid:xmppId];
}

@end
