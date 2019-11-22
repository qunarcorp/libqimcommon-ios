//
//  STIMManager+Request.h
//  STIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMManager.h"
#import "STIMPrivateHeader.h"

@interface STIMManager (Request)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (void)sendTPGetRequestWithUrl:(NSString *)url
           withProgressCallBack:(STIMKitSendTPRequesProgressBlock)pCallback
            withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid;

- (void)uploadFileRequest:(NSString *)uploadUrl withFileData:(NSData *)fileData withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)uploadFileRequest:(NSString *)uploadUrl withFileData:(NSData *)fileData withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)uploadFileRequest:(NSString *)uploadUrl withFilePath:(NSString *)filePath withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)uploadFileRequest:(NSString *)uploadUrl withFilePath:(NSString *)filePath withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendFormatRequest:(NSString *)destUrl withPOSTBody:(NSDictionary *)bodyDic withProgressBlock:(STIMKitSendTPRequesProgressBlock)pCallback withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

@end
