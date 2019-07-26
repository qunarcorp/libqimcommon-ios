//
//  QIMManager+Request.m
//  QIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMManager+Request.h"

@implementation QIMManager (Request)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback{

    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback{
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:bodyData];
    [request setShouldASynchronous:YES];
    [request setTimeoutInterval:10];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];
    
    __weak __typeof(self) weakSelf = self;
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:cookieProperties];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setQIMSafeObject:[[QIMManager sharedInstance] getLastJid] forKey:@"from"];
    [bodyProperties setQIMSafeObject:chatId forKey:@"to"];
    [bodyProperties setQIMSafeObject:realJid forKey:@"realjid"];
    [bodyProperties setQIMSafeObject:[NSString stringWithFormat:@"%lld", chatType] forKey:@"chatType"];
    
    [request setHTTPBody:[[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid {
    NSString *destUrl = [NSString stringWithFormat:@"%@/warning/nck/sendtips", [[QIMNavConfigManager sharedInstance] javaurl]];
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:cookieProperties];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setQIMSafeObject:dujiaJid forKey:@"tag"];
    [bodyProperties setQIMSafeObject:@"prod" forKey:@"conf"];
    [bodyProperties setQIMSafeObject:[QIMManager getLastUserName] forKey:@"to"];
    [bodyProperties setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"tohost"];
    
    [request setHTTPBody:[[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback{
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodGET];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

@end
