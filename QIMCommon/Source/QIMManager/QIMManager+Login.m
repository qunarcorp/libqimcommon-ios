//
//  QIMManager+Login.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMManager+Login.h"
#import <objc/runtime.h>
#import "QIMPrivateHeader.h"

@implementation QIMManager (Login)
 
#pragma mark - 登录

- (void)cancelLogin {
    
    self.needTryRelogin = NO;
    
    self.willCancelLogin = YES;
    [[XmppImManager sharedInstance] cancelLogin];
    QIMErrorLog(@"<Method: cancelLogin>取消登录");
}

- (void)sendHeartBeat {
    [[XmppImManager sharedInstance] sendHeartBeat];
}

- (BOOL)isLogin {
    return [[XmppImManager sharedInstance] loginState];
}

- (void)registerWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd {
    [QIMUUIDTools setUserName:[userName lowercaseString]];
    [[QIMUserCacheManager sharedInstance] setUserObject:[userName lowercaseString] forKey:kLastUserId];
    [[QIMUserCacheManager sharedInstance] setUserObject:pwd forKey:kLastPassword];
}

- (void)registerFaild {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterState object:[NSNumber numberWithBool:NO]];
    });
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[QIMUUIDTools deviceUUID] isEqualToString:[QIMUUIDTools getUUIDFromKeyChain]] || ![QIMUUIDTools getUUIDFromKeyChain]) {
            [QIMUUIDTools setUUID:[QIMUUIDTools deviceUUID]];
        }
        [QIMUUIDTools setUserName:[userName lowercaseString]];
        
        [QIMUUIDTools setRequestDomain:[[[QIMNavConfigManager sharedInstance] domain] dataUsingEncoding:NSUTF8StringEncoding]];
    });
    
    NSString *userFullJid = [userName stringByAppendingFormat:@"@%@", [[XmppImManager sharedInstance] domain]];
    //初始化数据库文件
    [self initDBWithUserXmppId:userFullJid];
    
    [[QIMUserCacheManager sharedInstance] setCacheName:userFullJid];
    
    [[QIMUserCacheManager sharedInstance] setUserObject:[userName lowercaseString] forKey:kLastUserId];
    [[QIMUserCacheManager sharedInstance] setUserObject:pwd forKey:kTempPassword];
    QIMVerboseLog(@"登陆之前当前CacheName : %@", [[QIMUserCacheManager sharedInstance] cacheName]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:@"ForceRefresh"];
    });
    
    //初始化用户数据
    [self initUserDicts];

    NSDictionary *navConfig = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfig"];
    
    [self updateAppWorkState:AppWorkState_Logining];
    self.willCancelLogin = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [[XmppImManager sharedInstance] loginwithName:userName password:pwd];
    });
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd WithLoginNavDict:(NSDictionary *)navDict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[QIMUUIDTools deviceUUID] isEqualToString:[QIMUUIDTools getUUIDFromKeyChain]] || ![QIMUUIDTools getUUIDFromKeyChain]) {
            [QIMUUIDTools setUUID:[QIMUUIDTools deviceUUID]];
        }
    });

    NSString *lastUserName = userName;
    NSString *token = pwd;
    if ([[lastUserName lowercaseString] isEqualToString:@"appstore"] || [[lastUserName lowercaseString] isEqualToString:@"ctrip"]) {
        token = lastUserName;
        QIMVerboseLog(@"token : %@", token);
        [[QIMUserCacheManager sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
    } else if ([[lastUserName lowercaseString] isEqualToString:@"qtalktest"]) {
        token = pwd;
        QIMVerboseLog(@"token : %@", token);
        [[QIMUserCacheManager sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
    } else {
        if ([lastUserName length] > 0 && [token length] > 0 && [[QIMNavConfigManager sharedInstance] loginType] == QTLoginTypeSms) {
            QIMVerboseLog(@"token : %@", token);
            [[QIMUserCacheManager sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
            token = [NSString stringWithFormat:@"%@@%@",[QIMUUIDTools deviceUUID],token];
        } else {
            [[QIMUserCacheManager sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[QIMManager sharedInstance] loginWithUserName:lastUserName WithPassWord:token];
    });
}

- (void)addUserCacheWithUserId:(NSString *)userId WithUserFullJid:(NSString *)userFullJid WithNavDict:(NSDictionary *)navDict {
    NSString *token = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"userToken"];
    NSDictionary *userDict = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"Users"];
    if ([userDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userDict];
        if ([userId isEqualToString:@"appstore"] || [userId isEqualToString:@"ctrip"]) {
            token = userId;
        } else if ([userId isEqualToString:@"qtalktest"]) {
            token = @"qtalktest123";
        }
        NSDictionary *user = @{@"userFullJid":userFullJid, @"LoginToken":token?token:@"", @"NavDict":navDict?navDict:@{}};
        if (user) {
            if (!dict) {
                dict = [NSMutableDictionary dictionary];
            }
            [dict setObject:user forKey:userFullJid];
            [[QIMUserCacheManager sharedInstance] setUserObject:dict forKey:@"Users"];
        }
        QIMVerboseLog(@"已登录用户 : %@",[[QIMUserCacheManager sharedInstance] userObjectForKey:@"Users"]);
    } else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        if ([userId isEqualToString:@"appstore"] || [userId isEqualToString:@"ctrip"]) {
            token = userId;
        }
        NSDictionary *user = @{@"userFullJid":userFullJid, @"LoginToken":token?token:@"", @"NavDict":navDict?navDict:@{}};
        if (user) {
            if (!dict) {
                dict = [NSMutableDictionary dictionary];
            }
            [dict setObject:user forKey:userFullJid];
            [[QIMUserCacheManager sharedInstance] setUserObject:dict forKey:@"Users"];
        }
        QIMVerboseLog(@"已登录用户 : %@",[[QIMUserCacheManager sharedInstance] userObjectForKey:@"Users"]);
    }
}

- (NSArray *)getLoginUsers {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:@"Users"]];
    [dict removeObjectForKey:[[QIMManager sharedInstance] getLastJid]];
    NSArray *users = [NSArray arrayWithArray:[dict allValues]];
    return users;
}

- (void)clearLogginUser {
    //
    // 清掉保存的发消息的用户信息
    QIMWarnLog(@"清除保存的发消息的用户信息");
    [[QIMUserCacheManager sharedInstance] clearUserCache];
    [self.friendDescDic removeAllObjects];
    self.friendDescDic = nil;
    [QIMUUIDTools setRequestFileURL:nil];
    [QIMUUIDTools setRequestURL:nil];
    [QIMUUIDTools setNewHttpRequestURL:nil];
    [QIMUUIDTools setRequestDomain:nil];
    [QIMUUIDTools setUserName:nil];
    [QIMUUIDTools setUUIDToolsFriendList:nil];
    [QIMUUIDTools setUUIDToolsMyGroupList:nil];
    [QIMUUIDTools setUUIDToolsSessionList:nil];
    [QIMUUIDTools setRecentSharedList:nil];
}

- (void)saveUserInfoWithName:(NSString *)userName passWord:(NSString *)pwd {
    [QIMUUIDTools setUserName:[userName lowercaseString]];
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [[QIMUserCacheManager sharedInstance] setUserObject:[userName lowercaseString] forKey:kLastUserId];
    [[QIMUserCacheManager sharedInstance] setUserObject:pwd forKey:kLastPassword];
}

- (void)quitLogin {
    
    QIMWarnLog(@"退出登录");
    dispatch_block_t block = ^{
        [self.friendDescDic removeAllObjects];
        [self.friendInfoDic removeAllObjects];
        [self cancelLogin];
    };
    
    if (dispatch_get_specific(self.cacheTag))
        block();
    else
        dispatch_sync(self.cacheQueue, block);
    
    [[XmppImManager sharedInstance] quitLogin];
    //关闭数据库
    [[QIMManager sharedInstance] closeDataBase];
    
    self.needTryRelogin = NO;
    [self clearQIMManager];
    //广播退出登录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogout object:nil];
    [[QIMUserCacheManager sharedInstance] setCacheName:@""];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        //退出登录将3D Touch选项置空
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(setShortcutItems:)]) {
            [UIApplication sharedApplication].shortcutItems = nil;
        }
    });
}

- (NSDictionary *)QChatLoginWithUserId:(NSString *)userId rsaPassword:(NSString *)password type:(NSString *)type {
    //    NSString * postDataStr = [NSString stringWithFormat:@"strid=%@&password=%@&type=%@",userId,password,type];
    //    loginsource   1 PC  2 APP  3  TOUCH   4  WAP
    //    devicename   机器名
    //    usermac        机器位置标识
    //    port              建立连接的端口
    //    osType          操作系统：字典字段（09:WINDOWS、10:UNIX、11:LINUX、12:MAC、13:IOS、14：ANDROID）
    //    terminalType        终端类型：字典字段（01：PC、02：手机、03：PAD）
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:userId forKey:@"strid"];
    [paramDic setObject:password forKey:@"password"];
    [paramDic setObject:type forKey:@"type"];
    [paramDic setObject:@"2" forKey:@"loginsource"];
    [paramDic setObject:[[QIMAppInfo sharedInstance] deviceName] forKey:@"devicename"];
    [paramDic setObject:[[QIMAppInfo sharedInstance] appAID] forKey:@"usermac"];
    [paramDic setObject:@"5222" forKey:@"port"];
    [paramDic setObject:@"13" forKey:@"osType"];
    [paramDic setObject:@"02" forKey:@"terminalType"];
    NSString *postDataStr = [self getFormStringByDiction:paramDic];
    NSMutableData *tempPostData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/get_power?v=%@&p=iphone", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMAppInfo sharedInstance] AppBuildVersion]]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempPostData];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        return resDic;
    }
    return nil;
}

- (NSString *)getFormStringByDiction:(NSDictionary *)diction {
    
    NSMutableString *formString = [NSMutableString string];
    for (NSString *key in diction.allKeys) {
        NSString *value = [diction objectForKey:key];
        if (value == nil) {
            value = @"";
        }
        [formString appendFormat:@"%@=%@&", key, value];
    }
    [formString deleteCharactersInRange:NSMakeRange(formString.length - 1, 1)];
    return formString;
}

- (void)relogin {
    self.willCancelLogin = NO;
    self.needTryRelogin = YES;
    QIMWarnLog(@"relogin");
    [self updateAppWorkState:AppWorkState_ReLogining];
    [[XmppImManager sharedInstance] relogin];
}

- (BOOL)forgelogin {
    BOOL bValue = [[XmppImManager sharedInstance] forgelogin];
    
    return bValue;
}

- (BOOL)isAutoLogin {
    NSNumber *flagNum = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"AutoLogin"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setAutoLogin:YES];
    }
    return [flagNum boolValue];
}

- (void)setAutoLogin:(BOOL)flag {
    [[QIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"AutoLogin"];
}

@end
