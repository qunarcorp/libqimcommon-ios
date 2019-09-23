//
//  QIMKit+QIMUserMedal.h
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMUserMedal)

- (NSArray *)getLocalUserMedalWithXmppJid:(NSString *)xmppId;

- (void)getRemoteUserMedalWithXmppJid:(NSString *)xmppId;

#pragma mark - Local UserMedal

- (NSArray *)getUserWearMedalStatusByUserid:(NSString *)userId;

@end
