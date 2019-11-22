//
//  STIMKit+STIMHttpApi.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMHttpApi.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMHttpApi)


+ (NSDictionary *)checkUserToken:(NSString *)verifCode {
    return [STIMHttpApi checkUserToken:verifCode];
}

+ (NSDictionary *)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode {
    return [STIMHttpApi getUserTokenWithUserName:userName WithVerifyCode:verifCode];
}

+ (NSDictionary *)getVerifyCodeWithUserName:(NSString *)userName {
    return [STIMHttpApi getVerifyCodeWithUserName:userName];
}

+ (NSDictionary *)getUserList {
    return [STIMHttpApi getUserList];
}

+ (NSString *) updateLoadMomentFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension {
    return [STIMHttpApi updateLoadMomentFile:fileData WithMsgId:key WithMsgType:type WithPathExtension:extension];
}

+ (NSString *)updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension {
    return [STIMHttpApi updateLoadFile:fileData WithMsgId:key WithMsgType:type WithPathExtension:extension];
}

+ (void)uploadVideo:(NSData *)fileData withCallBack:(STIMKitUploadVideoRequestSuccessedBlock)callback {
    [STIMHttpApi uploadVideo:fileData withCallBack:callback];
}

+ (void)uploadVideoPath:(NSString *)filePath withCallBack:(STIMKitUploadVideoRequestSuccessedBlock)callback {
    [STIMHttpApi uploadVideoPath:filePath withCallBack:callback];
}

+ (NSString *)updateLoadVoiceFile:(NSData *)voiceFileData WithFilePath:(NSString *)filePath {
    return [STIMHttpApi updateLoadVoiceFile:voiceFileData WithFilePath:filePath];
}

+ (NSString *)getFileDataMD5WithFileData:(NSData *)fileData {
    return [STIMHttpApi getFileDataMD5WithFileData:fileData];
}

+ (NSString*)getFileMD5WithPath:(NSString*)path {
    return [STIMHttpApi getFileMD5WithPath:path];
}

- (NSString *)getFileMD5WithData:(NSData *)data {
    return [STIMHttpApi getFileDataMD5WithFileData:data];
}

- (NSString*)getFileMD5WithPath:(NSString*)path{
    return [STIMHttpApi getFileMD5WithPath:path];
}

- (NSString *)HTTPUUID {
    return [STIMHttpApi UUID];
}

- (NSString *)updateLoadVoiceFile:(NSData *)data FilePath:(NSString *)filePath {
    return [STIMHttpApi updateLoadVoiceFile:data WithFilePath:filePath];
}

@end
