//
//  QIMHttpApi.m
//  qunarChatMac
//
//  Created by ping.xue on 14-3-13.
//  Copyright (c) 2014年 May. All rights reserved.

#import "QIMHttpApi.h"
#import "QIMAppInfo.h"
#import "QIMJSONSerializer.h"
#import "zlib.h"
#import "QIMManager.h"
#import "QIMManager+Request.h"
#import "QIMHttpAPIBlock.h"
#import "QIMNavConfigManager.h"
#import "NSString+QIMUtility.h"
#import <CommonCrypto/CommonCrypto.h>
#import "QIMCommonCategories.h"

// Request
#define REQ_LOGIN                    @"userN/login.htm"
#define REQ_GET_USER_CARD            @"userN/getQunarUserInfoByUid.htm"
#define REQ_GET_QUNAR_USER           @"userN/getQunarUserInfoByUid.htm"
#define REQ_LOAD_MESSAGE             @"im/loadMessage.htm"
#define REQ_GET_BUDDIES              @"im/getBuddies.htm"
#define REQ_SYNC_BUDDIES             @"im/syncBuddies.htm"
#define REQ_UPLOAD_FILE              @"im/uploadFile.htm"


#ifndef kMinPackageDataSize
#define kMinPackageDataSize (9)
#endif

#define kNetworkTaskDIV								@"80011168"
#define	kNetworkTaskDIP								@"10010"
#define kNetworkTaskDIC								@"C1001"

#define FileHashDefaultChunkSizeForReadingData 1024*8

@implementation QIMHttpApi

+(NSString *)getFileDataMD5WithFileData:(NSData *)fileData{
    return (__bridge_transfer NSString *)QIMFileMD5HashCreateWithData([fileData bytes], fileData.length);
}

+(NSString*)getFileMD5WithPath:(NSString*)path{
    return (__bridge_transfer NSString *)QIMFileMD5HashCreateWithPath((__bridge CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
}

CFStringRef QIMFileMD5HashCreateWithData(const void *data,long long dataLenght){
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    CC_MD5_Update(&hashObject,(const void *)data,(CC_LONG)dataLenght);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    CFStringRef result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    return result;
}

CFStringRef QIMFileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,(CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

+ (void)checkFileKeyForFile:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension withCallBack:(QIMKitCheckFileKeyForFileCallBack)callback{
    NSString *method = @"file/v2/inspection/file";
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&platform=iphone&u=%@&k=%@&version=%@",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileKey, (long long)ceil(fileLength / 1024.0 / 1024.0), [NSString stringWithFormat:@"%@.%@",fileKey,extension],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                //Callback resultUrl
                if (callback) {
                    callback(resultUrl);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

+ (NSString *)checkImageKeyForImage:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension withCallBack:(QIMKitCheckImageKeyForImageCallBack)callback {
    NSString *method = @"file/v2/inspection/img";
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&platform=iphone&u=%@&k=%@&version=%@",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileKey, (long long)ceil(fileLength / 1024.0 / 1024.0), [NSString stringWithFormat:@"%@.%@",fileKey,extension],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                if (callback) {
                    callback(resultUrl);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

+ (NSString *)privateUpLoadImage:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadImageCallBack)callback {
    NSString *method = @"file/v2/upload/img";
    NSString *fileName =  [NSString stringWithFormat:@"%@.%@",key,extension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);

    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],key,size];
    NSLog(@"上传图片destUrl : %@", destUrl);
    [[QIMManager sharedInstance] uploadFileRequest:destUrl withFileData:fileData withProgressBlock:^(float progressValue) {
        NSLog(@"privateUpLoadImage : %lf", progressValue);
    } withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSLog(@"上传图片返回结果 : %@", result);
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
//                return resultUrl;
                if (callback) {
                    callback(resultUrl);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        } else {
            if (callback) {
                callback(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
    
    /*
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
    [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [formRequest addData:fileData withFileName:fileName andContentType:nil forKey:@"file"];
    QIMHttpAPIBlock *progressBlock = [[QIMHttpAPIBlock alloc] init];
    [formRequest setUploadProgressDelegate:progressBlock];
    [formRequest startSynchronous];
    if ([formRequest responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:formRequest.responseData error:nil];
        NSLog(@"上传图片返回结果 : %@", result);
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
                return resultUrl;
            }
        }
    }
    return nil;
    */
}

/**
 上传图片

 @param fileData 图片二进制
 @param key fileKey
 @param type type
 @param extension 文件后缀
 @return 返回图片地址
 */
+ (void)qim_uploadImage:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadImageCallBack)callback {
    NSString *fileKey = [self getFileDataMD5WithFileData:fileData];
    NSString *fileExt = [self getFileExt:fileData];
    if (fileExt.length > 0) {
        extension = fileExt;
    }
    [self checkImageKeyForImage:fileKey WithFileLength:fileData.length WithPathExtension:extension withCallBack:^(NSString *httpUrl) {
        if (httpUrl == nil) {
            [QIMHttpApi privateUpLoadImage:fileData
                                 WithMsgId:fileKey
                               WithMsgType:type
                         WithPathExtension:extension
                              withCallBack:^(NSString *result) {
                                  if (callback) {
                                      callback(nil);
                                  }
                              }];
        } else {
            if (callback) {
                callback(httpUrl);
            }
        }
    }];
    /*
    if (httpUrl == nil) {
        return [QIMHttpApi privateUpLoadImage:fileData
                                    WithMsgId:fileKey
                                  WithMsgType:type
                            WithPathExtension:extension];
    }
    return httpUrl;
    */
}

+ (void)privateUpLoadFile:(NSData *)fileData WithMsgId:(NSString *)fileKey WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadFileCallBack)callBack {
    NSString *method = @"file/v2/upload/file";
    NSString *fileName =  [NSString stringWithFormat:@"%@.%@",fileKey, extension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    [[QIMManager sharedInstance] uploadFileRequest:destUrl withFileData:fileData withProgressBlock:^(float progressValue) {
        NSLog(@"privateUpLoadFile : %lf", progressValue);
    } withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                if (callBack) {
                    callBack(resultUrl);
                }
            } else {
                if (callBack) {
                    callBack(nil);
                }
            }
        } else {
            if (callBack) {
                callBack(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callBack) {
            callBack(nil);
        }
    }];
    /*
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
    [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [formRequest addData:fileData withFileName:fileName andContentType:nil forKey:@"file"];
    [formRequest startSynchronous];
    if ([formRequest responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:formRequest.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                return resultUrl;
            }
        }
    }
    return nil;
    */
//    return nil;
}


/**
 上传文件

 @param fileData 文件二进制
 @param key 文件key
 @param type 类型
 @param extension 文件后缀
 @return 文件url
 */
+ (void)qim_uploadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadFileCallBack)callback {
    NSString *fileKey = [self getFileDataMD5WithFileData:fileData];
    NSString *fileExt = [self getFileExt:fileData];
    if (fileExt.length > 0) {
        extension = fileExt;
    }
    [self checkFileKeyForFile:fileKey WithFileLength:fileData.length WithPathExtension:extension withCallBack:^(NSString *result) {
        if (result.length > 0) {
            if (callback) {
                callback(result);
            }
        } else {
            [QIMHttpApi privateUpLoadFile:fileData WithMsgId:key WithMsgType:type WithPathExtension:extension withCallBack:^(NSString *result) {
                if (callback) {
                    callback(result);
                }
            }];
        }
    }];
}

+ (void)checkVideo:(NSString *)fileMd5 withCallBack:(QIMKitCheckVideoCallBack)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/video/check", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"videoMd5":fileMd5};
    NSData *postData = [[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:postData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:postData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSDictionary *resultDic = [result objectForKey:@"data"];
            if ([resultDic isEqual:[NSNull null]] == NO && resultDic.count > 0) {
                BOOL ready = [[resultDic objectForKey:@"ready"] boolValue];
                if (ready == YES) {
                    if (callback) {
                        callback(resultDic);
                    }
                } else {
                    if (callback) {
                        callback(nil);
                    }
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

+ (void)qim_uploadNewVideoPath:(NSString *)filePath withCallBack:(QIMKitUploadVideoRequestSuccessedBlock)callback {
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileMd5 = [[fileData mutableCopy] qim_md5String];
    if (fileMd5.length > 0) {
        [self checkVideo:fileMd5 withCallBack:^(NSDictionary *checkResultDic) {
            if (checkResultDic) {
                if (callback) {
                    callback(checkResultDic);
                }
            } else {
                NSString *destUrl = [NSString stringWithFormat:@"%@/video/upload", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
                [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:filePath withProgressBlock:nil withSuccessCallBack:^(NSData *responseData) {
                    NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                    NSLog(@"resultDic : %@", resultDic);
                    BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
                    if (ret) {
                        NSDictionary *data = [resultDic objectForKey:@"data"];
                        if (callback) {
                            callback(data);
                        }
                    } else {
                        if (callback) {
                            callback(nil);
                        }
                    }
                } withFailedCallBack:^(NSError *error) {
                    if (callback) {
                        callback(nil);
                    }
                }];
            }
        }];
        //Mark by AFN
        /*
        if (checkResultDic) {
            if (callback) {
                callback(checkResultDic);
            }
        } else {
            NSString *destUrl = [NSString stringWithFormat:@"%@/video/upload", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:filePath withProgressBlock:nil withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                NSLog(@"resultDic : %@", resultDic);
                BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSDictionary *data = [resultDic objectForKey:@"data"];
                    if (callback) {
                        callback(data);
                    }
                } else {
                    if (callback) {
                        callback(nil);
                    }
                }
            } withFailedCallBack:^(NSError *error) {
                if (callback) {
                    callback(nil);
                }
            }];
        }
        */
    }
}

+ (void)qim_updateLoadVoiceFile:(NSData *)voiceFileData withFilePath:(NSString *)filePath withCallBack:(QIMKitUpdateLoadVoiceFileCallBack)callback {
    NSString *fileKey = [self getFileDataMD5WithFileData:voiceFileData];
    [self checkFileKeyForFile:fileKey WithFileLength:voiceFileData.length WithPathExtension:@"amr" withCallBack:^(NSString *httpUrl) {
        if (httpUrl == nil) {
            [QIMHttpApi privateUpLoadFile:voiceFileData WithMsgId:filePath WithMsgType:QIMMessageType_Voice WithPathExtension:@"amr" withCallBack:^(NSString *result) {
                if (callback) {
                    callback(result);
                }
            }];
        } else {
            if (callback) {
                callback(httpUrl);
            }
        }
    }];
}

+ (NSString *)getFileExt:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
        case 0x4D:
            return @"tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"webp";
            }
            return nil;
    }
    return nil;
}

+ (void)qim_uploadMyPhotoData:(NSData *)headerData withCallBack:(QIMKitUploadMyPhotoCallBack)callback {
    NSString *fileKey = [self getFileDataMD5WithFileData:headerData];
    NSString *method = @"file/v2/upload/avatar";
    NSString *fileName = [fileKey stringByAppendingPathExtension:[self getFileExt:headerData]];
    long long size = ceil(headerData.length / 1024.0 / 1024.0);
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost,
                         method,
                         fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    [[QIMManager sharedInstance] uploadFileRequest:destUrl withFileData:headerData withProgressBlock:^(float progressValue) {
        NSLog(@"progressValue : %lf", progressValue);
    } withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                if (callback) {
                    callback(resultUrl);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

@end
