//
//  QIMKit+QIMLogin.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit.h"

@interface QIMKit (QIMLogin)

/**
 设置是否为后台登录
 */
- (void)setIsBackgroundLogin:(BOOL)isBackgroundLogin;

/**
 是否为后台登录 （YES为后台重新登录，NO为前台人工登录）
 */
- (BOOL)isBackgroundLogin;

/**
 设置取消登录状态
 */
- (void)setWillCancelLogin:(BOOL)willCancelLogin;

/**
 获取取消登录状态
 */
- (BOOL)willCancelLogin;

/**
 设置登录重试
 */
- (void)setNeedTryRelogin:(BOOL)needTryRelogin;

/**
 获取登录重试
 */
- (BOOL)needTryRelogin;

/**
 获取当前登录状态
 */
- (BOOL)isLogin;

/**
 缓存用户登录

 @param userName 用户名称
 @param pwd 用户密码
 @param navDict 用户导航信息缓存
 */
- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd WithLoginNavDict:(NSDictionary *)navDict;
- (void)addUserCacheWithUserId:(NSString *)userId WithUserFullJid:(NSString *)userFullJid WithNavDict:(NSDictionary *)navDict;

/**
 用户登录

 @param userName 用户名
 @param pwd 用户密码
 */
- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)pwd;


/**
 获取本地已缓存用户列表
 */
- (NSArray *)getLoginUsers;


/**
 清空KeyChain中用户缓存信息
 */
- (void)clearLogginUser;

- (void)clearUserToken;

/**
 save 用户名 and 密码
 
 @param userName 用户名
 @param pwd 密码
 */
- (void)saveUserInfoWithName:(NSString *)userName passWord:(NSString *)pwd;

/**
 退出登录
 */
- (void)quitLogin;

/**
 前台登录
 */
- (BOOL)forgelogin;

/**
 重新登录
 */
- (void)relogin;

/**
 取消登录
 */
- (void)cancelLogin;


- (void)sendHeartBeat;

/**
 QChat rsa登录
 
 @param userId 用户id
 @param password rsa密码
 @param type 用户名的类型，值为：@"username"、@"email"、@"mobile"
 @return 返回结果
 */
- (void)QChatLoginWithUserId:(NSString *)userId rsaPassword:(NSString *)password type:(NSString *)type withCallback:(QIMKitGetQChatBetaLoginTokenDic)callback;

- (NSString *)getFormStringByDiction:(NSDictionary *)diction;

#pragma mark - 验证码

- (void)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode withCallback:(QIMKitGetUserTokenSuccessBlock)callback;

- (void)getVerifyCodeWithUserName:(NSString *)userName withCallback:(QIMKitGetVerifyCodeSuccessBlock)callback;

- (void)getNewUserTokenWithUserName:(NSString *)userName WithPassword:(NSString *)password withCallback:(QIMKitGetUserNewTokenSuccessBlock)callback;

@end
