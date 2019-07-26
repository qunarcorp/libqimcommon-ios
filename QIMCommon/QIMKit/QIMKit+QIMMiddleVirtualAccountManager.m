//
//  QIMKit+QIMMiddleVirtualAccountManager.m
//  QIMCommon
//
//  Created by 李露 on 10/30/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMKit+QIMMiddleVirtualAccountManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMMiddleVirtualAccountManager)

- (NSArray *)getMiddleVirtualAccounts {
    return [[QIMManager sharedInstance] getMiddleVirtualAccounts];
}

- (BOOL)isMiddleVirtualAccountWithJid:(NSString *)jid {
    return [[QIMManager sharedInstance] isMiddleVirtualAccountWithJid:jid];
}

@end
