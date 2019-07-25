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

- (void)registerWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd {
    [[QIMManager sharedInstance] registerWithUserName:userName WithPassWord:pwd];
}

- (void)registerFaild {
    
    [[QIMManager sharedInstance] registerFaild];
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

- (void)saveUserInfoWithName:(NSString *)userName passWord:(NSString *)pwd {
    [[QIMManager sharedInstance] saveUserInfoWithName:userName passWord:pwd];
}

- (void)quitLogin {
    
    [[QIMManager sharedInstance] quitLogin];
}

- (NSDictionary *)QChatLoginWithUserId:(NSString *)userId rsaPassword:(NSString *)password type:(NSString *)type {
    return [[QIMManager sharedInstance] QChatLoginWithUserId:userId rsaPassword:password type:type];
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

- (BOOL)isAutoLogin {
    return [[QIMManager sharedInstance] isAutoLogin];
}

- (void)setAutoLogin:(BOOL)flag {
    [[QIMManager sharedInstance] setAutoLogin:flag];
}

@end
