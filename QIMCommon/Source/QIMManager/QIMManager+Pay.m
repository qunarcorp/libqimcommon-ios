//
//  QIMManager+Pay.m
//  QIMCommon
//
//  Created by lihaibin on 2019/10/16.
//

#import "QIMManager+Pay.h"

@implementation QIMManager (Pay)
//获取绑定的支付宝账户信息
- (void)getBindPayAccount:(NSString *)userid withCallBack:(QIMKitPayCheckAccountBlock)callBack{
    NSString *destUrl = [NSString stringWithFormat:@"%@/red_envelope/get_bind_pay_account?user_id=%@&d=%@", [[QIMNavConfigManager sharedInstance] payurl], userid,[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *user_info = [[result objectForKey:@"data"] objectForKey:@"user_info"];
                if ([user_info isKindOfClass:[NSDictionary class]]) {
                    NSString *accountInfo = [user_info objectForKey:@"alipay_login_account"];
                    if(accountInfo){
                      callBack(YES);
                    }else{
                        [self getAlipayLoginParams];
                    }
                }else{
                    [self getAlipayLoginParams];
                }
            }else{
                [self getAlipayLoginParams];
            }
        }
    } withFailedCallBack:^(NSError *error) {
        callBack(FALSE);
    }];
}

//绑定支付宝账户
- (void)bindAlipayAccount:(NSString *)aliOpenid withAliUid:(NSString*)aliUid userId:(NSString *)userid;{
    NSString *destUrl = [NSString stringWithFormat:@"%@/red_envelope/bind_alipay_account?user_id=%@&d=%@",[[QIMNavConfigManager sharedInstance] payurl],userid,[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    NSDictionary *params = @{@"account": aliUid ,@"openId": aliOpenid};
    NSData *versionData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:versionData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([responseDic isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
            if (ret) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kSendRedPackRNView object:nil];
            } else {
                
            }
        }
    } withFailedCallBack:^(NSError *error) {
        QIMVerboseLog(@"bindAlipayAccount : error");
    }];
}

//获取支付宝登录认证信息
- (void)getAlipayLoginParams{
    NSString *destUrl = [NSString stringWithFormat:@"%@/red_envelope/alipay_app_login?d=%@",[[QIMNavConfigManager sharedInstance] payurl],[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSString *data = [result objectForKey:@"data"];
                if (data && data.length > 0) {
                   [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayAuth object:@{@"authInfo":data}];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayAuth object:@{@"authInfo":@""}];
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayAuth object:@{@"authInfo":@""}];
            }
        }
    } withFailedCallBack:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAlipayAuth object:@{@"authInfo":@""}];
    }];
}

//发送红包
- (void)sendRedEnvelop:(NSDictionary *)params withCallBack:(nonnull QIMKitPayCreateRedEnvelopBlock)callBack{
    NSString *destUrl = [NSString stringWithFormat:@"%@/red_envelope/create?d=%@", [[QIMNavConfigManager sharedInstance] payurl],[[QIMManager sharedInstance] getDomain]];
    NSData *versionData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:versionData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([responseDic isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *dataDic = [responseDic objectForKey:@"data"];
                NSString *payParams = [dataDic objectForKey:@"pay_parmas"];
                if(payParams && payParams.length > 0){
                    callBack(YES,payParams);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSendRedPack object:@{@"payParams":payParams}];
                }else{
                    callBack(FALSE,@"");
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSendRedPack object:@{@"payParams":@""}];
                }
            } else {
                callBack(FALSE,@"");
                [[NSNotificationCenter defaultCenter] postNotificationName:kSendRedPack object:@{@"payParams":@""}];
            }
        }
    } withFailedCallBack:^(NSError *error) {
        callBack(FALSE,@"");
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendRedPack object:@{@"payParams":@""}];
    }];
}

//红包详情
- (void)getRedEnvelopDetail:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger)isRoom withCallBack:(nonnull QIMKitPayRedEnvelopDetailBlock)callBack{
    NSString* destUrl = [NSString stringWithFormat:@"%@/red_envelope/get?%@%@&rid=%@&d=%@",[[QIMNavConfigManager sharedInstance] payurl],isRoom ? @"group_id=" : @"user_id=",xmppid,rid,[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            callBack(result);
        }
    } withFailedCallBack:^(NSError *error) {
        callBack(nil);
    }];
}

//打开红包第一步 查看红包状态
- (void)openRedEnvelop:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger)isRoom withCallBack:(nonnull QIMkitPayRedEnvelopOpenBlock)callBack{
    NSString* destUrl = [NSString stringWithFormat:@"%@/red_envelope/open?%@%@&rid=%@&action=open_red_envelope&d=%@",[[QIMNavConfigManager sharedInstance] payurl],isRoom ? @"group_id=" : @"user_id=",xmppid,rid,[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if(ret){
                callBack([[result objectForKey:@"data"] objectForKey:@"status"],0);
            }else{
                callBack(nil,[[result objectForKey:@"error_code"] integerValue]);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        callBack(nil,1);
    }];
}

//d打开红包第二步 拆红包（红包状态为可拆前提下）
- (void)grapRedEnvelop:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger)isRoom withCallBack:(nonnull QIMKitPayRedEnvelopGrapBlock)callBack{
    NSString* destUrl = [NSString stringWithFormat:@"%@/red_envelope/grab?%@%@&rid=%@&action=grab_red_envelope&d=%@",[[QIMNavConfigManager sharedInstance] payurl],isRoom ? @"group_id=" : @"user_id=",xmppid,rid,[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSInteger errCode = [[result objectForKey:@"error_code"] integerValue];
            if(errCode == 200){
                if (callBack) {
                    callBack(rid);
                }
            } else{
                if (callBack) {
                    callBack(@"");
                }
            }
        } else {
            if (callBack) {
                callBack(@"");
            }
        }
    } withFailedCallBack:^(NSError *error) {
        callBack(@"");
    }];
}

//我收到的红包
- (void)redEnvelopReceive:(NSInteger)page PageSize:(NSInteger)pageSize WithYear:(NSInteger)year withCallBack:(nonnull QIMKitPayRedEnvelopReceiveBlock)callBack{
    NSString* destUrl = [NSString stringWithFormat:@"%@/red_envelope/my_receive?page=%@&get_count=1&pagesize=%@&year=%@&d=%@",[[QIMNavConfigManager sharedInstance] payurl],@(page),@(pageSize),@(year),[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            if (callBack) {
                callBack(result);
            }
        } else {
            if (callBack) {
                callBack(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callBack) {
            callBack(nil);
        }
    }];
}

//我发出的红包
- (void)redEnvelopSend:(NSInteger)page PageSize:(NSInteger)pageSize WithYear:(NSInteger)year withCallBack:(nonnull QIMKitPayRedEnvelopSendBlock)callBack{
    NSString* destUrl = [NSString stringWithFormat:@"%@/red_envelope/my_send?page=%@&get_count=1&pagesize=%@&year=%@&d=%@",[[QIMNavConfigManager sharedInstance] payurl],@(page),@(pageSize),@(year),[[QIMManager sharedInstance] getDomain]];
    QIMVerboseLog(@"destUrl : %@", destUrl);
    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            if (callBack) {
                callBack(result);
            }
        } else {
            if (callBack) {
                callBack(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callBack) {
            callBack(nil);
        }
    }];
}

@end
