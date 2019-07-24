//
//  QIMManager+EncryptChat.m
//  QIMCommon
//
//  Created by 李露 on 2018/6/11.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMManager+EncryptChat.h"
#import "XmppImManager.h"

@implementation QIMManager (EncryptChat)

- (void)sendEncryptionChatWithType:(int)type WithBody:(NSString *)body ToJid:(NSString *)jid {
    [[XmppImManager sharedInstance] sendEncryptionChatWithType:type WithBody:body ToJid:jid];
}

@end
