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
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];

    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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

- (void)sendTPPOSTRequestWithUrl:(NSString *)url qcookie:(NSString *)_q vcookie:(NSString *)_v tcookie:(NSString *)_t withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback{
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:bodyData];
    [request setShouldASynchronous:YES];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@;_q=%@;_v=%@;_t=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue],_q,_v,_t];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    [request setHTTPRequestHeaders:cookieProperties];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
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
    [request setShouldASynchronous:YES];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
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

- (void)sendTPGetRequestWithUrl:(NSString *)url
           withProgressCallBack:(QIMKitSendTPRequesProgressBlock)pCallback
            withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback
             withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodGET];
    [request setShouldASynchronous:YES];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    [request setHTTPRequestHeaders:cookieProperties];
    [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            if (sCallback) {
                sCallback(nil);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback{

    [self sendTPGetRequestWithUrl:url withProgressCallBack:nil withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)uploadFileRequest:(NSString *)uploadUrl withFileData:(NSData *)fileData withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    QIMHTTPUploadComponent *uploadComponent = [[QIMHTTPUploadComponent alloc] initWithDataKey:@"file" fileData:fileData];
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHttpRequestType:QIMHTTPRequestTypeUpload];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setTimeoutInterval:600];
    [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            if (sCallback) {
                sCallback(nil);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)uploadFileRequest:(NSString *)uploadUrl withFileData:(NSData *)fileData withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    QIMHTTPUploadComponent *uploadComponent = [[QIMHTTPUploadComponent alloc] initWithDataKey:@"file" fileData:fileData];
    uploadComponent.bodyDic = bodyDic;
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHttpRequestType:QIMHTTPRequestTypeUpload];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setTimeoutInterval:600];
    [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            if (sCallback) {
                sCallback(nil);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)uploadFileRequest:(NSString *)uploadUrl withFilePath:(NSString *)filePath withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    QIMHTTPUploadComponent *uploadComponent = [[QIMHTTPUploadComponent alloc] initWithDataKey:@"file" filePath:filePath];
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHttpRequestType:QIMHTTPRequestTypeUpload];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setTimeoutInterval:600];
    [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            if (sCallback) {
                sCallback(nil);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)uploadFileRequest:(NSString *)uploadUrl withFilePath:(NSString *)filePath withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:uploadUrl]];
    [request setShouldASynchronous:YES];

    QIMHTTPUploadComponent *uploadComponent = [[QIMHTTPUploadComponent alloc] initWithDataKey:@"file" filePath:filePath];
    uploadComponent.bodyDic = bodyDic;
    request.uploadComponents = @[uploadComponent];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHttpRequestType:QIMHTTPRequestTypeUpload];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setTimeoutInterval:600];
    [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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

- (void)downloadFileRequest:(NSString *)downloadFileUrl withTargetFilePath:(NSString *)targetFilePath withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:downloadFileUrl]];
    [request setShouldASynchronous:YES];
    [request setDownloadDestinationPath:targetFilePath];

    [request setHTTPMethod:QIMHTTPMethodGET];
    [request setHttpRequestType:QIMHTTPRequestTypeDownload];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setTimeoutInterval:600];
     [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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

- (void)sendFormatRequest:(NSString *)destUrl withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:destUrl]];
    [request setShouldASynchronous:YES];

    QIMHTTPUploadComponent *uploadComponent = [[QIMHTTPUploadComponent alloc] init];
    uploadComponent.bodyDic = bodyDic;
    request.uploadComponents = @[uploadComponent];
    [request setHttpRequestType:QIMHTTPRequestTypeUpload];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
//    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:cookieProperties];
    [request setTimeoutInterval:600];
    [QIMHTTPClient sendRequest:request progressBlock:^(NSProgress *progress) {
        if (pCallback) {
            pCallback(progress.fractionCompleted);
        }
    } complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
            if (sCallback) {
                sCallback(nil);
            }
        }
    } failure:^(NSError *error) {
        if (fCallback) {
            fCallback(error);
        }
    }];
}

- (void)sendTPPOSTFormUrlEncodedRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {

    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:bodyData];
    [request setShouldASynchronous:YES];
    [request setTimeoutInterval:10];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/x-www-form-urlencoded" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];

    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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

- (void)sendTPGETFormUrlEncodedRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {

    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:QIMHTTPMethodPOST];
//    [request setHTTPBody:bodyData];
    [request setShouldASynchronous:YES];
    [request setTimeoutInterval:10];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMManager getLastUserName], [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/x-www-form-urlencoded" forKey:@"Content-type"];

    [request setHTTPRequestHeaders:cookieProperties];

    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSData *responseData = [response data];
            if (sCallback) {
                sCallback(responseData);
            }
        } else {
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
