//
//  STIMKit+STIMMiddleVirtualAccountManager.m
//  STIMCommon
//
//  Created by 李露 on 10/30/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMKit+STIMMiddleVirtualAccountManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMMiddleVirtualAccountManager)

- (NSArray *)getMiddleVirtualAccounts {
    return [[STIMManager sharedInstance] getMiddleVirtualAccounts];
}

- (BOOL)isMiddleVirtualAccountWithJid:(NSString *)jid {
    return [[STIMManager sharedInstance] isMiddleVirtualAccountWithJid:jid];
}

@end
