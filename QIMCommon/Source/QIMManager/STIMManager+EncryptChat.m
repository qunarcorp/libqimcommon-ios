//
//  STIMManager+EncryptChat.m
//  STIMCommon
//
//  Created by 李露 on 2018/6/11.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMManager+EncryptChat.h"
#import "XmppImManager.h"

@implementation STIMManager (EncryptChat)

- (void)sendEncryptionChatWithType:(int)type WithBody:(NSString *)body ToJid:(NSString *)jid {
    [[XmppImManager sharedInstance] sendEncryptionChatWithType:type WithBody:body ToJid:jid];
}

@end
