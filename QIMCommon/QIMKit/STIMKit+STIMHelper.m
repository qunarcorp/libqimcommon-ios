//
//  STIMKit+STIMHelper.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMKit+STIMHelper.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMHelper)

- (void)playHongBaoSound {
    [[STIMManager sharedInstance] playHongBaoSound];
}

- (void)playSound {
    
    [[STIMManager sharedInstance] playSound];
}

- (void)shockWindow {
    [[STIMManager sharedInstance] shockWindow];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    return [[STIMManager sharedInstance] addSkipBackupAttributeToItemAtURL:URL];
}

@end
