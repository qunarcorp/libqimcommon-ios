//
//  STIMKit+STIMHttpApi.h
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMHttpApi)

+ (NSDictionary *)checkUserToken:(NSString *)verifCode;

+ (NSDictionary *)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode;

+ (NSDictionary *)getVerifyCodeWithUserName:(NSString *)userName;

+ (NSDictionary *)getUserList;

+ (NSString *) updateLoadMomentFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension;

+ (NSString *)updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension;

+ (void)uploadVideo:(NSData *)fileData withCallBack:(STIMKitUploadVideoRequestSuccessedBlock)callback;

+ (void)uploadVideoPath:(NSString *)filePath withCallBack:(STIMKitUploadVideoRequestSuccessedBlock)callback;

+ (NSString *)updateLoadVoiceFile:(NSData *)voiceFileData WithFilePath:(NSString *)filePath;

+(NSString *)getFileDataMD5WithFileData:(NSData *)fileData;

+(NSString*)getFileMD5WithPath:(NSString*)path;

@end
