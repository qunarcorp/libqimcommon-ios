//
//  STIMKit+STIMLogin.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMKit+STIMLogin.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMLogin)

#pragma mark - setter and getter

- (void)setIsBackgroundLogin:(BOOL)isBackgroundLogin {
    [[STIMManager sharedInstance] setIsBackgroundLogin:isBackgroundLogin];
}

- (BOOL)isBackgroundLogin {
    return [[STIMManager sharedInstance] isBackgroundLogin];
}

- (void)setWillCancelLogin:(BOOL)willCancelLogin {
    [[STIMManager sharedInstance] setWillCancelLogin:willCancelLogin];
}

- (BOOL)willCancelLogin {
    return [[STIMManager sharedInstance] willCancelLogin];
}

- (void)setNeedTryRelogin:(BOOL)needTryRelogin {
    [[STIMManager sharedInstance] setNeedTryRelogin:needTryRelogin];
}

- (BOOL)needTryRelogin {
    return [[STIMManager sharedInstance] needTryRelogin];
}

#pragma mark - 登录

- (void)cancelLogin {
    
    [[STIMManager sharedInstance] cancelLogin];
}

- (void)sendHeartBeat {
    [[STIMManager sharedInstance] sendHeartBeat];
}

- (BOOL)isLogin {
    return [[STIMManager sharedInstance] isLogin];
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd {
    [[STIMManager sharedInstance] loginWithUserName:userName WithPassWord:pwd];
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd WithLoginNavDict:(NSDictionary *)navDict {
    [[STIMManager sharedInstance] loginWithUserName:userName WithPassWord:pwd WithLoginNavDict:navDict];
}

- (void)addUserCacheWithUserId:(NSString *)userId WithUserFullJid:(NSString *)userFullJid WithNavDict:(NSDictionary *)navDict {
    [[STIMManager sharedInstance] addUserCacheWithUserId:userId WithUserFullJid:userFullJid WithNavDict:navDict];
}

- (NSArray *)getLoginUsers {
    return [[STIMManager sharedInstance] getLoginUsers];
}

- (void)clearLogginUser {
    [[STIMManager sharedInstance] clearLogginUser];
}

- (void)clearUserToken {
    [[STIMManager sharedInstance] clearUserToken];
}

- (void)saveUserInfoWithName:(NSString *)userName passWord:(NSString *)pwd {
    [[STIMManager sharedInstance] saveUserInfoWithName:userName passWord:pwd];
}

- (void)quitLogin {
    
    [[STIMManager sharedInstance] quitLogin];
}

- (NSDictionary *)QChatLoginWithUserId:(NSString *)userId rsaPassword:(NSString *)password type:(NSString *)type {
    return [[STIMManager sharedInstance] QChatLoginWithUserId:userId rsaPassword:password type:type];
}

- (NSString *)getFormStringByDiction:(NSDictionary *)diction {
    
    return [[STIMManager sharedInstance] getFormStringByDiction:diction];
}

- (void)relogin {
    [[STIMManager sharedInstance] relogin];
}

- (BOOL)forgelogin {
    return [[STIMManager sharedInstance] forgelogin];
}

#pragma mark - 验证码

- (void)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode withCallback:(STIMKitGetUserTokenSuccessBlock)callback {
    [[STIMManager sharedInstance] getUserTokenWithUserName:userName WithVerifyCode:verifCode withCallback:callback];
}

- (void)getVerifyCodeWithUserName:(NSString *)userName withCallback:(STIMKitGetVerifyCodeSuccessBlock)callback {
    [[STIMManager sharedInstance] getVerifyCodeWithUserName:userName withCallback:callback];
}

- (void)getNewUserTokenWithUserName:(NSString *)userName WithPassword:(NSString *)password withCallback:(STIMKitGetUserNewTokenSuccessBlock)callback {
    [[STIMManager sharedInstance] getNewUserTokenWithUserName:userName WithPassword:password withCallback:callback];
}

@end
