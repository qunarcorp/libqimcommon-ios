//
//  QIMKit+QIMNetWork.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit+QIMNetWork.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMNetWork)

- (AppWorkState)appWorkState {
    return [[QIMManager sharedInstance] appWorkState];
}

#pragma mark - 网络状态监测

- (void)checkNetWorkWithCallBack:(QIMKitCheckNetWorkBlock)callback {
    [[QIMManager sharedInstance] checkNetWorkWithCallBack:callback];
}


- (void)checkNetworkStatus{
    [[QIMManager sharedInstance] checkNetworkStatus];
}

- (void)onNetworkChange:(NSNotification *)notify{
    
    [[QIMManager sharedInstance] onNetworkChange:notify];
}

- (void)updateAppWorkState:(AppWorkState)appWorkState {
    [[QIMManager sharedInstance] updateAppWorkState:appWorkState];
}

@end
