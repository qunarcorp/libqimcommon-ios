//
//  QIMKit+QIMHttpApi.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMHttpApi.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMHttpApi)


+ (NSDictionary *)checkUserToken:(NSString *)verifCode {
    return [QIMHttpApi checkUserToken:verifCode];
}

+ (NSDictionary *)getUserTokenWithUserName:(NSString *)userName WihtVerifyCode:(NSString *)verifCode {
    return [QIMHttpApi getUserTokenWithUserName:userName WihtVerifyCode:verifCode];
}

+ (NSDictionary *)getVerifyCodeWithUserName:(NSString *)userName {
    return [QIMHttpApi getVerifyCodeWithUserName:userName];
}

+ (NSDictionary *)getUserList {
    return [QIMHttpApi getUserList];
}

+ (NSString *)updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WihtPathExtension:(NSString *)extension {
    return [QIMHttpApi updateLoadFile:fileData WithMsgId:key WithMsgType:type WihtPathExtension:extension];
}

+ (NSString *)updateLoadVoiceFile:(NSData *)voiceFileData WithFilePath:(NSString *)filePath {
    return [QIMHttpApi updateLoadVoiceFile:voiceFileData WithFilePath:filePath];
}

+ (NSString *)getFileDataMD5WithPath:(NSData *)fileData {
    return [QIMHttpApi getFileDataMD5WithPath:fileData];
}

+ (NSString*)getFileMD5WithPath:(NSString*)path {
    return [QIMHttpApi getFileMD5WithPath:path];
}


- (NSString *)getFileMD5WithData:(NSData *)data {
    return [QIMHttpApi getFileDataMD5WithPath:data];
}

- (NSString*)getFileMD5WithPath:(NSString*)path{
    return [QIMHttpApi getFileMD5WithPath:path];
}

- (NSString *)HTTPUUID {
    return [QIMHttpApi UUID];
}

- (NSString *)updateLoadVoiceFile:(NSData *)data FilePath:(NSString *)filePath {
    return [QIMHttpApi updateLoadVoiceFile:data WithFilePath:filePath];
}

@end
