//
//  STIMManager+EncryptChat.h
//  STIMCommon
//
//  Created by 李露 on 2018/6/11.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMManager.h"

@interface STIMManager (EncryptChat)

- (void)sendEncryptionChatWithType:(int)type WithBody:(NSString *)body ToJid:(NSString *)jid;

@end
