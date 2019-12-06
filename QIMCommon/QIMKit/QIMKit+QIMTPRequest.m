//
//  QIMKit+QIMTPRequest.m
//  QIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMKit+QIMTPRequest.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMTPRequest)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:url withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:url withRequestBodyData:bodyData withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:url withChatId:chatId withRealJid:realJid withChatType:chatType];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url
           withProgressCallBack:(QIMKitSendTPRequesProgressBlock)pCallback
            withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:url withProgressCallBack:pCallback withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:url withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid {
    [[QIMManager sharedInstance] synchronizeDujiaWarningWithJid:dujiaJid];
}

- (void)sendTPPOSTFormUrlEncodedRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPPOSTFormUrlEncodedRequestWithUrl:url withRequestBodyData:bodyData withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)downloadFileRequest:(NSString *)downloadFileUrl withTargetFilePath:(NSString *)targetFilePath withProgressBlock:(QIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] downloadFileRequest:downloadFileUrl withTargetFilePath:targetFilePath withProgressBlock:pCallback withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPGETFormUrlEncodedRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPGETFormUrlEncodedRequestWithUrl:url withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

@end
