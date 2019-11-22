//
//  STIMKit+STIMTPRequest.h
//  STIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMTPRequest)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType;

- (void)sendTPGetRequestWithUrl:(NSString *)url
           withProgressCallBack:(STIMKitSendTPRequesProgressBlock)pCallback
            withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback;

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid;

@end
