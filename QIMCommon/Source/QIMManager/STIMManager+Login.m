//
//  STIMManager+Login.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMManager+Login.h"
#import <objc/runtime.h>
#import "STIMPrivateHeader.h"
#import "STIMRSACoder.h"

@implementation STIMManager (Login)
 
#pragma mark - 登录

- (void)cancelLogin {
    
    self.needTryRelogin = NO;
    
    self.willCancelLogin = YES;
    [[XmppImManager sharedInstance] cancelLogin];
    STIMErrorLog(@"<Method: cancelLogin>取消登录");
}

- (void)sendHeartBeat {
    [[XmppImManager sharedInstance] sendHeartBeat];
}

- (BOOL)isLogin {
    return [[XmppImManager sharedInstance] loginState];
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[STIMUUIDTools deviceUUID] isEqualToString:[STIMUUIDTools getUUIDFromKeyChain]] || ![STIMUUIDTools getUUIDFromKeyChain]) {
            [STIMUUIDTools setUUID:[STIMUUIDTools deviceUUID]];
        }
        [STIMUUIDTools setUserName:[userName lowercaseString]];
        
        [STIMUUIDTools setRequestDomain:[[[STIMNavConfigManager sharedInstance] domain] dataUsingEncoding:NSUTF8StringEncoding]];
    });
    
    NSString *userFullJid = [userName stringByAppendingFormat:@"@%@", [[XmppImManager sharedInstance] domain]];
    //初始化数据库文件
    [self initDBWithUserXmppId:userFullJid];
    
    [[STIMUserCacheManager sharedInstance] setCacheName:userFullJid];
    
    [[STIMUserCacheManager sharedInstance] setUserObject:[userName lowercaseString] forKey:kLastUserId];
    [[STIMUserCacheManager sharedInstance] setUserObject:pwd forKey:kTempPassword];
    STIMVerboseLog(@"登陆之前当前CacheName : %@", [[STIMUserCacheManager sharedInstance] cacheName]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:@"ForceRefresh"];
    });
    
    //初始化用户数据
    [self initUserDicts];

    NSDictionary *navConfig = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfig"];
    
    [self updateAppWorkState:AppWorkState_Logining];
    self.willCancelLogin = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [[XmppImManager sharedInstance] loginwithName:userName password:pwd];
    });
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd WithLoginNavDict:(NSDictionary *)navDict {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[STIMUUIDTools deviceUUID] isEqualToString:[STIMUUIDTools getUUIDFromKeyChain]] || ![STIMUUIDTools getUUIDFromKeyChain]) {
            [STIMUUIDTools setUUID:[STIMUUIDTools deviceUUID]];
        }
    });

    NSString *lastUserName = userName;
    NSString *token = pwd;
    if ([[lastUserName lowercaseString] isEqualToString:@"appstore"] || [[lastUserName lowercaseString] isEqualToString:@"ctrip"]) {
        token = lastUserName;
        STIMVerboseLog(@"token : %@", token);
        [self updateLastTempUserToken:token];
    } else if ([[lastUserName lowercaseString] isEqualToString:@"qtalktest"]) {
        token = pwd;
        STIMVerboseLog(@"token : %@", token);
        [self updateLastTempUserToken:token];
    } else {
        if ([lastUserName length] > 0 && [token length] > 0 && [[STIMNavConfigManager sharedInstance] loginType] == QTLoginTypeSms) {
            STIMVerboseLog(@"token : %@", token);
            [self updateLastTempUserToken:token];
            token = [NSString stringWithFormat:@"%@@%@",[STIMUUIDTools deviceUUID],token];
        } else {
            [self updateLastTempUserToken:token];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[STIMManager sharedInstance] loginWithUserName:lastUserName WithPassWord:token];
    });
}

- (void)addUserCacheWithUserId:(NSString *)userId WithUserFullJid:(NSString *)userFullJid WithNavDict:(NSDictionary *)navDict {
    NSString *token = [self getLastUserToken];
    NSDictionary *userDict = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"Users"];
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
            [[STIMUserCacheManager sharedInstance] setUserObject:dict forKey:@"Users"];
        }
        STIMVerboseLog(@"已登录用户 : %@",[[STIMUserCacheManager sharedInstance] userObjectForKey:@"Users"]);
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
            [[STIMUserCacheManager sharedInstance] setUserObject:dict forKey:@"Users"];
        }
        STIMVerboseLog(@"已登录用户 : %@",[[STIMUserCacheManager sharedInstance] userObjectForKey:@"Users"]);
    }
}

- (NSArray *)getLoginUsers {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[STIMUserCacheManager sharedInstance] userObjectForKey:@"Users"]];
    [dict removeObjectForKey:[[STIMManager sharedInstance] getLastJid]];
    NSArray *users = [NSArray arrayWithArray:[dict allValues]];
    return users;
}

- (void)clearLogginUser {
    //
    // 清掉保存的发消息的用户信息
    STIMWarnLog(@"清除保存的发消息的用户信息");
    [[STIMUserCacheManager sharedInstance] clearUserCache];
    [self.friendDescDic removeAllObjects];
    self.friendDescDic = nil;
    [STIMUUIDTools setRequestFileURL:nil];
    [STIMUUIDTools setRequestURL:nil];
    [STIMUUIDTools setNewHttpRequestURL:nil];
    [STIMUUIDTools setRequestDomain:nil];
    [STIMUUIDTools setUserName:nil];
    [STIMUUIDTools setUUIDToolsFriendList:nil];
    [STIMUUIDTools setUUIDToolsMyGroupList:nil];
    [STIMUUIDTools setUUIDToolsSessionList:nil];
    [STIMUUIDTools setRecentSharedList:nil];
}

- (void)clearUserToken {
    [[STIMUserCacheManager sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
    [[STIMUserCacheManager sharedInstance] removeUserObjectForKey:@"userToken"];
}

- (void)saveUserInfoWithName:(NSString *)userName passWord:(NSString *)pwd {
    [STIMUUIDTools setUserName:[userName lowercaseString]];
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    [[STIMUserCacheManager sharedInstance] setUserObject:[userName lowercaseString] forKey:kLastUserId];
    [[STIMUserCacheManager sharedInstance] setUserObject:pwd forKey:kLastPassword];
}

- (void)quitLogin {
    
    STIMWarnLog(@"退出登录");
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
    [[STIMManager sharedInstance] closeDataBase];
    
    self.needTryRelogin = NO;
    [self clearSTIMManager];
    //广播退出登录通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogout object:nil];
    [[STIMUserCacheManager sharedInstance] setCacheName:@""];
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
    [paramDic setObject:[[STIMAppInfo sharedInstance] deviceName] forKey:@"devicename"];
    [paramDic setObject:[[STIMAppInfo sharedInstance] appAID] forKey:@"usermac"];
    [paramDic setObject:@"5222" forKey:@"port"];
    [paramDic setObject:@"13" forKey:@"osType"];
    [paramDic setObject:@"02" forKey:@"terminalType"];
    NSString *postDataStr = [self getFormStringByDiction:paramDic];
    NSMutableData *tempPostData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/get_power?v=%@&p=iphone", [[STIMNavConfigManager sharedInstance] httpHost], [[STIMAppInfo sharedInstance] AppBuildVersion]]];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:tempPostData];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *resDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
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
    STIMWarnLog(@"relogin");
    [self updateAppWorkState:AppWorkState_ReLogining];
    [[XmppImManager sharedInstance] relogin];
}

- (BOOL)forgelogin {
    BOOL bValue = [[XmppImManager sharedInstance] forgelogin];
    
    return bValue;
}

#pragma mark - 验证码

- (void)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode withCallback:(STIMKitGetUserTokenSuccessBlock)callback {

    NSDictionary *result = nil;
    NSString *destUrl = [[STIMNavConfigManager sharedInstance] tokenSmsUrl];

    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:userName forKey:@"rtx_id"];
    [bodyDic setSTIMSafeObject:verifCode forKey:@"verify_code"];

    [[STIMManager sharedInstance] sendFormatRequest:destUrl withPOSTBody:bodyDic withProgressBlock:nil withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if (callback) {
            callback(result);
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)getVerifyCodeWithUserName:(NSString *)userName withCallback:(STIMKitGetVerifyCodeSuccessBlock)callback {
    NSDictionary *result = nil;
    NSString *destUrl = [[STIMNavConfigManager sharedInstance] takeSmsUrl];

    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:userName forKey:@"rtx_id"];

    [[STIMManager sharedInstance] sendFormatRequest:destUrl withPOSTBody:bodyDic withProgressBlock:nil withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if (callback) {
            callback(result);
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)getNewUserTokenWithUserName:(NSString *)userName WithPassword:(NSString *)password withCallback:(STIMKitGetUserNewTokenSuccessBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/nck/qtlogin.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];

    NSString *rsaPwd = [STIMRSACoder encryptByRsa:password];
    NSString *base64Result = rsaPwd;

    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:userName forKey:@"u"];
    [bodyDic setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"h"];
    [bodyDic setSTIMSafeObject:base64Result forKey:@"p"];
    [bodyDic setSTIMSafeObject:[STIMUUIDTools deviceUUID] forKey:@"mk"];
    [bodyDic setSTIMSafeObject:@"iOS" forKey:@"plat"];

    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];

    [[STIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if (callback) {
            callback(result);
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

@end
