//
//  QIMKit+QIMLogin.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit+QIMLogin.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMLogin)

#pragma mark - setter and getter

- (void)setIsBackgroundLogin:(BOOL)isBackgroundLogin {
    [[QIMManager sharedInstance] setIsBackgroundLogin:isBackgroundLogin];
}

- (BOOL)isBackgroundLogin {
    return [[QIMManager sharedInstance] isBackgroundLogin];
}

- (void)setWillCancelLogin:(BOOL)willCancelLogin {
    [[QIMManager sharedInstance] setWillCancelLogin:willCancelLogin];
}

- (BOOL)willCancelLogin {
    return [[QIMManager sharedInstance] willCancelLogin];
}

- (void)setNeedTryRelogin:(BOOL)needTryRelogin {
    [[QIMManager sharedInstance] setNeedTryRelogin:needTryRelogin];
}

- (BOOL)needTryRelogin {
    return [[QIMManager sharedInstance] needTryRelogin];
}

#pragma mark - 登录

- (void)cancelLogin {
    
    [[QIMManager sharedInstance] cancelLogin];
}

- (void)sendHeartBeat {
    [[QIMManager sharedInstance] sendHeartBeat];
}

- (BOOL)isLogin {
    return [[QIMManager sharedInstance] isLogin];
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd {
    [[QIMManager sharedInstance] loginWithUserName:userName WithPassWord:pwd];
}

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd WithLoginNavDict:(NSDictionary *)navDict {
    [[QIMManager sharedInstance] loginWithUserName:userName WithPassWord:pwd WithLoginNavDict:navDict];
}

- (void)addUserCacheWithUserId:(NSString *)userId WithUserFullJid:(NSString *)userFullJid WithNavDict:(NSDictionary *)navDict {
    [[QIMManager sharedInstance] addUserCacheWithUserId:userId WithUserFullJid:userFullJid WithNavDict:navDict];
}

- (NSArray *)getLoginUsers {
    return [[QIMManager sharedInstance] getLoginUsers];
}

- (void)clearLogginUser {
    [[QIMManager sharedInstance] clearLogginUser];
}

- (void)clearUserToken {
    [[QIMManager sharedInstance] clearUserToken];
}

- (void)saveUserInfoWithName:(NSString *)userName passWord:(NSString *)pwd {
    [[QIMManager sharedInstance] saveUserInfoWithName:userName passWord:pwd];
}

- (void)quitLogin {
    
    [[QIMManager sharedInstance] quitLogin];
}

- (void)QChatLoginWithUserId:(NSString *)userId rsaPassword:(NSString *)password type:(NSString *)type withCallback:(QIMKitGetQChatBetaLoginTokenDic)callback {
    [[QIMManager sharedInstance] QChatLoginWithUserId:userId rsaPassword:password type:type withCallback:callback];
}

- (NSString *)getFormStringByDiction:(NSDictionary *)diction {
    
    return [[QIMManager sharedInstance] getFormStringByDiction:diction];
}

- (void)relogin {
    [[QIMManager sharedInstance] relogin];
}

- (BOOL)forgelogin {
    return [[QIMManager sharedInstance] forgelogin];
}

#pragma mark - 验证码

- (void)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode withCallback:(QIMKitGetUserTokenSuccessBlock)callback {
    [[QIMManager sharedInstance] getUserTokenWithUserName:userName WithVerifyCode:verifCode withCallback:callback];
}

- (void)getVerifyCodeWithUserName:(NSString *)userName withCallback:(QIMKitGetVerifyCodeSuccessBlock)callback {
    [[QIMManager sharedInstance] getVerifyCodeWithUserName:userName withCallback:callback];
}

- (void)getNewUserTokenWithUserName:(NSString *)userName WithPassword:(NSString *)password withCallback:(QIMKitGetUserNewTokenSuccessBlock)callback {
    [[QIMManager sharedInstance] getNewUserTokenWithUserName:userName WithPassword:password withCallback:callback];
}

@end
