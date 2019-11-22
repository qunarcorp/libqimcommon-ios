//
//  STIMKit+STIMHelper.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMKit.h"

@interface STIMKit (STIMHelper)

/**
 红包提示音
 */
- (void)playHongBaoSound;

/**
 新消息提示音
 */
- (void)playSound;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

/**
 窗口抖动
 */
- (void)shockWindow;

@end
