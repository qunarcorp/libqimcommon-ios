//
//  QIMHttpApi.h
//  qunarChatMac
//
//  Created by ping.xue on 14-3-13.
//  Copyright (c) 2014年 May. All rights reserved.
//

//extern NSString *kIMInnerFileServer;

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"

CFStringRef QIMFileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData);
CFStringRef QIMFileMD5HashCreateWithData(const void *data,long long dataLenght);

@interface QIMHttpApi : NSObject

+ (void)qim_uploadImage:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadImageCallBack)callback;

+ (void)qim_uploadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadFileCallBack)callback;

+ (void)qim_uploadNewVideoPath:(NSString *)filePath withCallBack:(QIMKitUploadVideoRequestSuccessedBlock)callback;

+ (void)qim_updateLoadVoiceFile:(NSData *)voiceFileData withFilePath:(NSString *)filePath withCallBack:(QIMKitUpdateLoadVoiceFileCallBack)callback;

+ (void)qim_uploadMyPhotoData:(NSData *)headerData withCallBack:(QIMKitUploadMyPhotoCallBack)callback;

+(NSString *)getFileDataMD5WithFileData:(NSData *)fileData;

+(NSString*)getFileMD5WithPath:(NSString*)path;

@end
