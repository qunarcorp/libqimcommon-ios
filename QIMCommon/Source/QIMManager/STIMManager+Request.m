//
//  STIMManager+Request.m
//  STIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMManager+Request.h"

@implementation STIMManager (Request)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback{

    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
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

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback{
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:bodyData];
    [request setShouldASynchronous:YES];
    [request setTimeoutInterval:10];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];
    
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
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
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:cookieProperties];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setSTIMSafeObject:[[STIMManager sharedInstance] getLastJid] forKey:@"from"];
    [bodyProperties setSTIMSafeObject:chatId forKey:@"to"];
    [bodyProperties setSTIMSafeObject:realJid forKey:@"realjid"];
    [bodyProperties setSTIMSafeObject:[NSString stringWithFormat:@"%lld", chatType] forKey:@"chatType"];
    
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid {
    NSString *destUrl = [NSString stringWithFormat:@"%@/warning/nck/sendtips", [[STIMNavConfigManager sharedInstance] javaurl]];
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setShouldASynchronous:YES];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:cookieProperties];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setSTIMSafeObject:dujiaJid forKey:@"tag"];
    [bodyProperties setSTIMSafeObject:@"prod" forKey:@"conf"];
    [bodyProperties setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"to"];
    [bodyProperties setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"tohost"];
    
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url
           withProgressCallBack:(STIMKitSendTPRequesProgressBlock)pCallback
            withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:STIMHTTPMethodGET];
    [request setShouldASynchronous:YES];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [STIMHTTPClient sendRequest:request progressBlock:^(float progressValue) {
        if (pCallback) {
            pCallback(progressValue);
        }
    } complete:^(STIMHTTPResponse *response) {
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

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback{
    
    [self sendTPGetRequestWithUrl:url withProgressCallBack:nil withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)uploadFileRequest:(NSString *)uploadUrl withFileData:(NSData *)fileData withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    STIMHTTPUploadComponent *uploadComponent = [[STIMHTTPUploadComponent alloc] initWithDataKey:@"file" fileData:fileData];
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:STIMHTTPMethodPOST];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [request setTimeoutInterval:600];
    [STIMHTTPClient sendRequest:request progressBlock:^(float progressValue) {
        if (pCallback) {
            pCallback(progressValue);
        }
    } complete:^(STIMHTTPResponse *response) {
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

- (void)uploadFileRequest:(NSString *)uploadUrl withFileData:(NSData *)fileData withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    STIMHTTPUploadComponent *uploadComponent = [[STIMHTTPUploadComponent alloc] initWithDataKey:@"file" fileData:fileData];
    uploadComponent.bodyDic = bodyDic;
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:STIMHTTPMethodPOST];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [request setTimeoutInterval:600];
    [STIMHTTPClient sendRequest:request progressBlock:^(float progressValue) {
        if (pCallback) {
            pCallback(progressValue);
        }
    } complete:^(STIMHTTPResponse *response) {
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

- (void)uploadFileRequest:(NSString *)uploadUrl withFilePath:(NSString *)filePath withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    STIMHTTPUploadComponent *uploadComponent = [[STIMHTTPUploadComponent alloc] initWithDataKey:@"file" filePath:filePath];
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:STIMHTTPMethodPOST];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [request setTimeoutInterval:600];
    [STIMHTTPClient sendRequest:request progressBlock:^(float progressValue) {
        if (pCallback) {
            pCallback(progressValue);
        }
    } complete:^(STIMHTTPResponse *response) {
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

- (void)uploadFileRequest:(NSString *)uploadUrl withFilePath:(NSString *)filePath withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    STIMHTTPUploadComponent *uploadComponent = [[STIMHTTPUploadComponent alloc] initWithDataKey:@"file" filePath:filePath];
    uploadComponent.bodyDic = bodyDic;
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:STIMHTTPMethodPOST];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [request setTimeoutInterval:600];
    [STIMHTTPClient sendRequest:request progressBlock:^(float progressValue) {
        if (pCallback) {
            pCallback(progressValue);
        }
    } complete:^(STIMHTTPResponse *response) {
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

- (void)sendFormatRequest:(NSString *)destUrl withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setShouldASynchronous:YES];

    STIMHTTPUploadComponent *uploadComponent = [[STIMHTTPUploadComponent alloc] init];
    uploadComponent.bodyDic = bodyDic;
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:STIMHTTPMethodPOST];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    __weak __typeof(self) weakSelf = self;
    [request setTimeoutInterval:600];
    [STIMHTTPClient sendRequest:request progressBlock:^(float progressValue) {
        if (pCallback) {
            pCallback(progressValue);
        }
    } complete:^(STIMHTTPResponse *response) {
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
