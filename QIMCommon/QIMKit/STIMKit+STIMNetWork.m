//
//  STIMKit+STIMNetWork.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMKit+STIMNetWork.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMNetWork)

- (AppWorkState)appWorkState {
    return [[STIMManager sharedInstance] appWorkState];
}

#pragma mark - 网络状态监测

- (BOOL)checkNetworkCanUser{
    return [[STIMManager sharedInstance] checkNetworkCanUser];
}


- (void)checkNetworkStatus{
    [[STIMManager sharedInstance] checkNetworkStatus];
}

- (void)onNetworkChange:(NSNotification *)notify{
    
    [[STIMManager sharedInstance] onNetworkChange:notify];
}

- (void)updateAppWorkState:(AppWorkState)appWorkState {
    [[STIMManager sharedInstance] updateAppWorkState:appWorkState];
}

@end
