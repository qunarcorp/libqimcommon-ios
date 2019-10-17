//
//  QIMKit+QIMUserMedal.m
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMKit+QIMUserMedal.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMUserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getLocalUserMedalWithXmppJid:xmppId];
}

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId {
    [[QIMManager sharedInstance] getRemoteUserMedalWithXmppJid:xmppId];
}

/**
 修改勋章佩戴状态
 
 @param status 勋章佩戴状态
 @param medalId 勋章Id
 */
- (void)userMedalStatusModifyWithStatus:(NSInteger)status withMedalId:(NSInteger)medalId withCallBack:(QIMKitUpdateMedalStatusCallBack)callback {
    [[QIMManager sharedInstance] userMedalStatusModifyWithStatus:status withMedalId:medalId withCallBack:callback];
}

#pragma mark - Local UserMedal

- (NSDictionary *)getUserMedalWithMedalId:(NSInteger)medalId withUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] getUserMedalWithMedalId:medalId withUserId:userId];
}

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId {
    return [[QIMManager sharedInstance] getUserWearMedalStatusByUserid:userId];
}

- (NSArray *)getUsersInMedal:(NSInteger)medalId withLimit:(NSInteger)limit withOffset:(NSInteger)offset {
    return [[QIMManager sharedInstance] getUsersInMedal:medalId withLimit:limit withOffset:offset];
}

- (NSArray *)getUserWearMedalSmallIconListByUserid:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getUserWearMedalSmallIconListByUserid:xmppId];
}

- (NSArray *)getUserHaveMedalSmallIconListByUserid:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getUserHaveMedalSmallIconListByUserid:xmppId];
}

@end
