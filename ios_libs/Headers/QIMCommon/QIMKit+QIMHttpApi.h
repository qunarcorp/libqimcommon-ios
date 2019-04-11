//
//  QIMKit+QIMHttpApi.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMHttpApi)

+ (NSDictionary *)checkUserToken:(NSString *)verifCode;

+ (NSDictionary *)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode;

+ (NSDictionary *)getVerifyCodeWithUserName:(NSString *)userName;

+ (NSDictionary *)getUserList;

+ (NSString *)updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension;

+ (NSString *)updateLoadVoiceFile:(NSData *)voiceFileData WithFilePath:(NSString *)filePath;

+(NSString *)getFileDataMD5WithPath:(NSData *)fileData;

+(NSString*)getFileMD5WithPath:(NSString*)path;

@end
