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

@end
