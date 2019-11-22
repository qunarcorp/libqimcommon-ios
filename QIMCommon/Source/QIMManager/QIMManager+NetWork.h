//
//  QIMManager+NetWork.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMManager.h"

@interface QIMManager (NetWork)

@property (nonatomic, assign) AppWorkState appWorkState; // 应用的登陆状态

- (void)checkNetWorkWithCallBack:(QIMKitCheckNetWorkBlock)callback;

- (void)checkNetworkStatus;

- (void)onNetworkChange:(NSNotification *)notify;

- (void)updateAppWorkState:(AppWorkState)appWorkState;

- (void)onDisconnect;

@end
