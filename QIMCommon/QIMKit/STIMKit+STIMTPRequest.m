//
//  STIMKit+STIMTPRequest.m
//  STIMCommon
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMKit+STIMTPRequest.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMTPRequest)

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    [[STIMManager sharedInstance] sendTPPOSTRequestWithUrl:url withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    [[STIMManager sharedInstance] sendTPPOSTRequestWithUrl:url withRequestBodyData:bodyData withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPPOSTRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    [[STIMManager sharedInstance] sendTPPOSTRequestWithUrl:url withChatId:chatId withRealJid:realJid withChatType:chatType];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url
           withProgressCallBack:(STIMKitSendTPRequesProgressBlock)pCallback
            withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    [[STIMManager sharedInstance] sendTPGetRequestWithUrl:url withProgressCallBack:pCallback withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPGetRequestWithUrl:(NSString *)url withSuccessCallBack:(STIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(STIMKitSendTPRequesFailedBlock)fCallback {
    [[STIMManager sharedInstance] sendTPGetRequestWithUrl:url withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid {
    [[STIMManager sharedInstance] synchronizeDujiaWarningWithJid:dujiaJid];
}

@end
