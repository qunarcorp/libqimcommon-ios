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

@end

NS_ASSUME_NONNULL_END
