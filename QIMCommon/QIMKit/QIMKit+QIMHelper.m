//
//  QIMKit+QIMHelper.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit+QIMHelper.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMHelper)

- (void)playHongBaoSound {
    [[QIMManager sharedInstance] playHongBaoSound];
}

- (void)playSound {
    
    [[QIMManager sharedInstance] playSound];
}

- (void)shockWindow {
    [[QIMManager sharedInstance] shockWindow];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    return [[QIMManager sharedInstance] addSkipBackupAttributeToItemAtURL:URL];
}

@end
