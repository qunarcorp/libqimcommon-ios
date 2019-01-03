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

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid {
    [[QIMManager sharedInstance] synchronizeDujiaWarningWithJid:dujiaJid];
}

@end
