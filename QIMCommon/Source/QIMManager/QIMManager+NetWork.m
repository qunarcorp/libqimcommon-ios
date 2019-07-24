//
//  QIMManager+NetWork.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMManager+NetWork.h"
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <objc/runtime.h>
#import "QIMPrivateHeader.h"

@implementation QIMManager (NetWork)

- (void)setAppWorkState:(AppWorkState)appWorkState {
    NSNumber *appWorkStateNumber = [NSNumber numberWithInteger:appWorkState];
    objc_setAssociatedObject(self, "appWorkState", appWorkStateNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AppWorkState)appWorkState {
    NSNumber *appWorkStateNumber = objc_getAssociatedObject(self, "appWorkState");
    return [appWorkStateNumber unsignedIntegerValue];
}

#pragma mark - 网络状态监测

- (BOOL)checkNetworkCanUser{
    NSString *checkUrl = [[QIMNavConfigManager sharedInstance] healthcheckUrl];
    QIMVerboseLog(@"网络检测，检测地址:%@...", checkUrl);
    if (checkUrl.length > 0) {
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:checkUrl]];
        [request setTimeOutSeconds:2];
        [request startSynchronous];
        if ([request responseStatusCode] == 200) {
            QIMWarnLog(@"<Method: checkNetworkCanUser> 网络检测，已连接到互联网...");
            return YES;
        } else {
            QIMWarnLog(@"网络检测，Request Url %@, Respone Code : %d , Error %@",checkUrl,request.responseStatusCode,request.error);
            return NO;
        }
    } else {
        return YES;
    }
}


- (void)checkNetworkStatus{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
    QIMWarnLog(@" _needTryRelogin = %d", self.needTryRelogin);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self checkNetworkCanUser] && self.notNeedCheckNetwotk == NO) {
            if ([self isLogin] == NO) {
                [self relogin];
            }
        }  else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(checkNetworkStatus) withObject:nil afterDelay:3];
            });
        }
    });
}

- (void)onNetworkChange:(NSNotification *)notify{
    
    switch ([notify.object intValue]) {
        case NotReachable:
        {
            QIMErrorLog(@"<手机未连接网络");
        }
            break;
        case ReachableViaWiFi:
        {
            id info = nil;
            NSString *wifiName = nil;
            NSString *wifiSignalStrength = nil;
            NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
            for (NSString *ifnam in ifs) {
                info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
                wifiName = info[@"SSID"];
                wifiSignalStrength = info[@"BSSID"];
            }
            self.needTryRelogin = YES;
            QIMVerboseLog(@"<手机连接到了Wi-Fi %@, 信号强度 = %@>", wifiName, wifiSignalStrength);
        }
            break;
        case ReachableViaWWAN: {
            QIMVerboseLog(@"<手机连接到了ViaWWAN网络>...");
            self.needTryRelogin = YES;
        }
            break;
        default:
        {
            QIMWarnLog(@"手机已连接到网络，但不一定能上网...");
            self.needTryRelogin = YES;
        }
            break;
    }
    if ([notify.object intValue] == NotReachable) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
        [self cancelLogin];
        [self updateAppWorkState:AppWorkState_NotNetwork];
        [self setMsgSentFaild];
    } else {
        [self checkNetworkStatus];
    }
}

- (void)updateAppWorkState:(AppWorkState)appWorkState {
    AppWorkState oldAppWorkState = self.appWorkState;
    AppWorkState newAppWorkState = appWorkState;
    if (oldAppWorkState != newAppWorkState) {
        newAppWorkState = appWorkState;
        self.appWorkState = appWorkState;
        QIMWarnLog(@"App工作状态即将变为 : %u", appWorkState);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppWorkStateChange object:@(appWorkState)];
        });
    }
}

- (void)onDisconnect {
    
    [self updateAppWorkState:AppWorkState_Logout];
}

- (void)onConnecting {
    [self updateAppWorkState:AppWorkState_Logining];
}

@end
