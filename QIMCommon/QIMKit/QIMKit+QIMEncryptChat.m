//
//  QIMKit+QIMEncryptChat.m
//  QIMCommon
//
//  Created by 李露 on 2018/6/11.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMEncryptChat.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMEncryptChat)

- (void)sendEncryptionChatWithType:(int)type WithBody:(NSString *)body ToJid:(NSString *)jid {
    [[QIMManager sharedInstance] sendEncryptionChatWithType:type WithBody:body ToJid:jid];
}

@end
