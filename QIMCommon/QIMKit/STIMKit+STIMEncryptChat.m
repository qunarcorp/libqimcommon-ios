//
//  STIMKit+STIMEncryptChat.m
//  STIMCommon
//
//  Created by 李露 on 2018/6/11.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMEncryptChat.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMEncryptChat)

- (void)sendEncryptionChatWithType:(int)type WithBody:(NSString *)body ToJid:(NSString *)jid {
    [[STIMManager sharedInstance] sendEncryptionChatWithType:type WithBody:body ToJid:jid];
}

@end
