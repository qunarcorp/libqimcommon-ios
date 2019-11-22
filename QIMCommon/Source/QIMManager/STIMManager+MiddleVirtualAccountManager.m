//
//  STIMManager+MiddleVirtualAccountManager.m
//  STIMCommon
//
//  Created by 李露 on 10/30/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMManager+MiddleVirtualAccountManager.h"

@implementation STIMManager (MiddleVirtualAccountManager)

- (NSArray *)getMiddleVirtualAccounts {
    NSString *fileTransId = [NSString stringWithFormat:@"%@@%@", @"file-transfer", [[STIMManager sharedInstance] getDomain]];
    NSString *dujiaId = [NSString stringWithFormat:@"%@@%@", @"dujia_warning", [[STIMManager sharedInstance] getDomain]];
    NSString *qtalktips = [NSString stringWithFormat:@"%@@%@", @"qtalktips", [[STIMManager sharedInstance] getDomain]];
    NSString *icrobot = [NSString stringWithFormat:@"%@@%@", @"ic-robot", [[STIMManager sharedInstance] getDomain]];
    NSString *worknotice = [NSString stringWithFormat:@"%@@%@", @"worknotice", [[STIMManager sharedInstance] getDomain]];
//    NSString *myId = [[STIMManager sharedInstance] getLastJid];
    return @[fileTransId, dujiaId, qtalktips, icrobot, worknotice];
}

- (BOOL)isMiddleVirtualAccountWithJid:(NSString *)jid {
    if (jid.length <= 0) {
        return NO;
    }
    if ([[self getMiddleVirtualAccounts] containsObject:jid]) {
        return YES;
    }
    return NO;
}

@end
