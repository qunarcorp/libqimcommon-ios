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

- (void)sendTPRequestWithUrl:(NSString *)url withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPRequestWithUrl:url withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPRequestWithUrl:(NSString *)url withRequestBodyData:(NSData *)bodyData withSuccessCallBack:(QIMKitSendTPRequesSuccessedBlock)sCallback withFailedCallBack:(QIMKitSendTPRequesFailedBlock)fCallback {
    [[QIMManager sharedInstance] sendTPRequestWithUrl:url withRequestBodyData:bodyData withSuccessCallBack:sCallback withFailedCallBack:fCallback];
}

- (void)sendTPRequestWithUrl:(NSString *)url withChatId:(NSString *)chatId withRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    [[QIMManager sharedInstance] sendTPRequestWithUrl:url withChatId:chatId withRealJid:realJid withChatType:chatType];
}

- (void)synchronizeDujiaWarningWithJid:(NSString *)dujiaJid {
    [[QIMManager sharedInstance] synchronizeDujiaWarningWithJid:dujiaJid];
}

@end
