//
//  QIMHttpApi.m
//  qunarChatMac
//
//  Created by ping.xue on 14-3-13.
//  Copyright (c) 2014年 May. All rights reserved.
//  211.151.112.140

#import "QIMHttpApi.h"
#import "QIMAppInfo.h"
#import "QIMJSONSerializer.h"
#import "ASIHTTPRequest.h"
#import "zlib.h" 
#import "ASIFormDataRequest.h"
#import "QIMManager.h"
#import "QIMHttpAPIBlock.h"
#import "QIMNavConfigManager.h"
#import "NSString+QIMUtility.h"
#import <CommonCrypto/CommonCrypto.h>
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

@interface QIMHttpApi(PrivateCommonMethod)

+ (NSData *)uncompress:(NSData *)data withUncompressedDataLength:(NSUInteger)length;

@end


@implementation QIMHttpApi
+ (NSString *)checkFileKeyForFile:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension{
    NSString *method = @"file/v2/inspection/file";

    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&platform=iphone&u=%@&k=%@&version=%@",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileKey, (long long)ceil(fileLength / 1024.0 / 1024.0), [NSString stringWithFormat:@"%@.%@",fileKey,extension],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
                NSURL *url = [NSURL URLWithString:resultUrl];
                resultUrl = [url path];
                NSUInteger loc = [resultUrl rangeOfString:@"/"].location + 1;
                if (loc < resultUrl.length) {
                    NSString *fileName = url.pathComponents.lastObject;
                    resultUrl = [[resultUrl substringFromIndex:1] stringByAppendingFormat:@"?file=file/%@&FileName=file/%@",fileName,fileName];
                    return resultUrl;
                }
            }
        }
    }
    return nil;
}

+ (NSString *)checkFileKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension{
    NSString *method = @"file/v2/inspection/img";
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&platform=iphone&u=%@&k=%@&version=%@",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileKey, (long long)ceil(fileLength / 1024.0 / 1024.0), [NSString stringWithFormat:@"%@.%@",fileKey,extension],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
                NSURL *url = [NSURL URLWithString:resultUrl];
                resultUrl = [url path];
                NSUInteger loc = [resultUrl rangeOfString:@"/"].location + 1;
                if (loc < resultUrl.length) {
                    NSString *fileName = url.pathComponents.lastObject;
                    resultUrl = [[resultUrl substringFromIndex:1] stringByAppendingFormat:@"?file=file/%@&FileName=file/%@",fileName,fileName];
                    return resultUrl;
                }
            }
        }
    }
    return nil;
}

+(NSString *)getFileDataMD5WithPath:(NSData *)fileData{
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

+ (NSDictionary *)checkUserToken:(NSString *)token{
    NSDictionary *result = nil;
    NSString *destUrl = [[QIMNavConfigManager sharedInstance] checkSmsUrl];//@"https://smsauth.qunar.com/api/1.0/token/auth";
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [request addPostValue:token forKey:@"token"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
    }
    
    return result;
}

+ (NSDictionary *)getUserTokenWithUserName:(NSString *)userName WithVerifyCode:(NSString *)verifCode{
    NSDictionary *result = nil;
    NSString *destUrl = [[QIMNavConfigManager sharedInstance] tokenSmsUrl];//@"https://smsauth.qunar.com/api/2.0/token";
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [request addPostValue:userName forKey:@"rtx_id"];
    [request addPostValue:verifCode forKey:@"verify_code"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
    }
    return result;
}

+ (NSDictionary *)getVerifyCodeWithUserName:(NSString *)userName{
    NSDictionary *result = nil;
    NSString *destUrl = [[QIMNavConfigManager sharedInstance] takeSmsUrl]; //  @"https://smsauth.qunar.com/api/1.0/verify_code";
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [request addPostValue:userName forKey:@"rtx_id"];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
    }
    
    return result;
}

+ (NSString *)updateLoadMomentImage:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension{
    NSString *method = @"file/v2/upload/img";
    NSString *fileName =  [NSString stringWithFormat:@"%@.%@",key,extension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],key,size];
    NSLog(@"上传图片destUrl : %@", destUrl);
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
    [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [formRequest addData:fileData withFileName:fileName andContentType:nil forKey:@"file"];
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
}

+ (NSString *)updateLoadImage:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension{
    NSString *method = @"file/v2/upload/img";
    NSString *fileName =  [NSString stringWithFormat:@"%@.%@",key,extension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);

    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],key,size];
    NSLog(@"上传图片destUrl : %@", destUrl);
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
}

+ (NSString *) updateLoadMomentFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension{
    NSString *fileKey = [self getFileDataMD5WithPath:fileData];
    NSString *fileExt = [self getFileExt:fileData];
    if (fileExt.length > 0) {
        extension = fileExt;
    }
    NSString *httpUrl = [self checkFileKey:fileKey WithFileLength:fileData.length WithPathExtension:extension];
    if (httpUrl == nil) {
        return [QIMHttpApi updateLoadMomentImage:fileData WithMsgId:fileKey WithMsgType:type WithPathExtension:extension];
    }
    return httpUrl;
}

+ (NSString *) updateLoadFile:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension{
    NSString *fileKey = [self getFileDataMD5WithPath:fileData];
    NSString *fileExt = [self getFileExt:fileData];
    if (fileExt.length > 0) {
        extension = fileExt;
    }
    NSString *httpUrl = [self checkFileKey:fileKey WithFileLength:fileData.length WithPathExtension:extension];
    if (httpUrl == nil) {
        return [QIMHttpApi updateLoadImage:fileData
                                WithMsgId:fileKey
                              WithMsgType:type
                        WithPathExtension:extension];
    }
    return httpUrl;
}
 
#pragma mark -load voice file return url -add by dan.zheng 15/4/24
+ (NSString *)updateLoadVoiceFile_New:(NSData *)voiceFileData WithFilePath:(NSString *)filePath WithFileKey:(NSString *)fileKey {
    NSString *method = @"file/v2/upload/file";
    NSString *fileName =  [NSString stringWithFormat:@"%@.amr",fileKey];
    long long size = ceil(voiceFileData.length / 1024.0 / 1024.0);
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
    [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [formRequest addData:voiceFileData withFileName:fileName andContentType:nil forKey:@"file"];
    [formRequest startSynchronous];
    if ([formRequest responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:formRequest.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
                NSURL *url = [NSURL URLWithString:resultUrl];
                resultUrl = [url path];
                NSUInteger loc = [resultUrl rangeOfString:@"/"].location + 1;
                if (loc < resultUrl.length) {
                    NSString *fileName = url.pathComponents.lastObject;
                    resultUrl = [[resultUrl substringFromIndex:1] stringByAppendingFormat:@"?file=file/%@&FileName=file/%@",fileName,fileName];
                    return resultUrl;
                }
            }
        }
    }
    return nil;
}

//将voice文件提交到网络上并获取到文件存储的url
+ (NSString *)updateLoadVoiceFile:(NSData *)voiceFileData WithFilePath:(NSString *)filePath {
    NSString *fileKey = [self getFileDataMD5WithPath:voiceFileData];
    NSString *httpUrl = [self checkFileKeyForFile:fileKey WithFileLength:voiceFileData.length WithPathExtension:@"amr"];
    if (httpUrl == nil) {
        return [QIMHttpApi updateLoadVoiceFile_New:voiceFileData WithFilePath:filePath WithFileKey:fileKey];
    }
    return httpUrl;
}

+ (NSString *)getFileExt:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"jpeg";
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

+ (NSString *)updateMyPhoto:(NSData *)headerData{
    NSString *fileKey = [self getFileDataMD5WithPath:headerData];
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
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
    [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [formRequest addData:headerData withFileName:fileName andContentType:nil forKey:@"file"];
    [formRequest startSynchronous];
    if (formRequest.responseStatusCode == 200) {
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
}

@end

@implementation QIMHttpApi(CommonMethod)


+ (NSString *) OriginalUUID {
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDString = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    NSString *result = [[NSString alloc] initWithString:(__bridge NSString*)UUIDString];
    if (UUID)
        CFRelease(UUID);
    if (UUIDString)
        CFRelease(UUIDString);
    return result;
}

+ (NSString *)UUID {
    return [[self OriginalUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}



+ (NSDictionary *)deserializeAsDictionary:(NSData *)data
{
    NSDictionary* dictionary = nil;
    
    if((data == nil) || ([data length] < kMinPackageDataSize))
    {
        return nil;
    }
    
    NSUInteger dataLen = [data length];
    NSUInteger curIndex = 0;
    
    int dataValid;
    [data getBytes:&dataValid range:NSMakeRange(curIndex, sizeof(int))];
    curIndex += sizeof(int);
    
    if(dataValid != 0)
    {
        return nil;
    }
    
    int serviceType;
    [data getBytes:&serviceType range:NSMakeRange(curIndex, sizeof(int))];
    curIndex += sizeof(int);
    
    int errorCode;
    [data getBytes:&errorCode range:NSMakeRange(curIndex, sizeof(int))];
    curIndex += sizeof(int);
    
    //    if(errorCode != 0)
    //    {
    //        return nil;
    //    }
    
    if(curIndex >= dataLen)
    {
        return nil;
    }
    
    int dataCompressed;
    [data getBytes:&dataCompressed range:NSMakeRange(curIndex, sizeof(int))];
    curIndex += sizeof(int);
    
    int jsonLen = 0;
    NSData *infoData = nil;
    if(dataCompressed == 2)
    {
        int decompressedDataSize;
        if(curIndex >= dataLen)
        {
            return nil;
        }
        
        [data getBytes:&decompressedDataSize range:NSMakeRange(curIndex, sizeof(int))];
        curIndex += sizeof(int);
        
        int compressedDataSize;
        if(curIndex >= dataLen)
        {
            return nil;
        }
        
        [data getBytes:&compressedDataSize range:NSMakeRange(curIndex, sizeof(int))];
        curIndex += sizeof(int);
        
        NSData *compressedData = [data subdataWithRange:NSMakeRange(curIndex, compressedDataSize)];
        infoData = [self uncompress:compressedData withUncompressedDataLength:decompressedDataSize];
        curIndex = 0;
        jsonLen = decompressedDataSize;
    }
    else
    {
        infoData = data;
        if(curIndex >= dataLen)
        {
            return nil;
        }
        
        [infoData getBytes:&jsonLen range:NSMakeRange(curIndex, sizeof(int))];
        curIndex += sizeof(int);
    }
    
    NSData *jsonData = [infoData subdataWithRange:NSMakeRange(curIndex, jsonLen)];
    dictionary = [[QIMJSONSerializer sharedInstance] deserializeObject:jsonData error:nil];
    
    return dictionary;
}

@end

@implementation QIMHttpApi(PrivateCommonMethod)

+ (NSData *)uncompress:(NSData *)data withUncompressedDataLength:(NSUInteger)length
{
    if([data length] == 0)
    {
        return data;
    }
    else
    {
        // 分配解压空间
        NSMutableData *decompressedData = [NSMutableData dataWithLength:length];
        
        // 设置解压参数
        z_stream stream;
        stream.next_in = (Bytef *)[data bytes];
        stream.avail_in = (uInt)[data length];
        stream.total_in = 0;
        stream.next_out = (Bytef *)[decompressedData mutableBytes];
        stream.avail_out = (uInt)[decompressedData length];
        stream.total_out = 0;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.opaque = Z_NULL;
        
        // 初始化
        if(inflateInit(&stream) == Z_OK)
        {
            // 解压缩
            int status = inflate(&stream, Z_SYNC_FLUSH);
            if(status == Z_STREAM_END)
            {
                // 清除
                if(inflateEnd(&stream) == Z_OK)
                {
                    return decompressedData;
                }
            }
        }
    }
    
    return nil;
}

+ (NSString *)encrypt:(NSString *)text withKey:(NSString *)key
{
    // 加密字
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger keyLength = [keyData length];
    Byte *keyBytes = (Byte *)[keyData bytes];
    
    // 旧的数据
    NSData *srcData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger srcLength = [srcData length];
    Byte* srcBytes = (Byte *)[srcData bytes];
    
    // 新的数据
    int headSize = sizeof(uint32_t);
    NSUInteger destLength = headSize + srcLength;
    Byte* destBytes = (Byte *)malloc(sizeof(Byte) * destLength);
    memcpy(destBytes + headSize, srcBytes, sizeof(Byte) * srcLength);
    
    // 加密
    for(NSUInteger i = 0; i < srcLength; i++)
    {
        destBytes[i + headSize] ^= 91;
        destBytes[i + headSize] += keyBytes[i % keyLength];
    }
    
    // 计算CRC32
    uLong crc32Value = crc32(0L, Z_NULL, 0);
    crc32Value = crc32(crc32Value, destBytes + headSize, sizeof(Byte) * srcLength);
    
    // 加密CRC32
    destBytes[0] = (Byte)crc32Value;
    destBytes[1] = (Byte)(crc32Value >> 24);
    destBytes[2] = (Byte)(crc32Value >> 8);
    destBytes[3] = (Byte)(crc32Value >> 16);
    
    // 通过字节数组得到字符串
    NSMutableString *destString = [[NSMutableString alloc] initWithString:@""];
    for(NSUInteger i = 0; i < destLength; i++)
    {
        Byte destByte = destBytes[i] & 0xFF;
        Byte destHexFirst = destByte / 16;
        Byte destHexSecond = destByte % 16;
        
        [destString appendFormat:@"%x%x", destHexFirst, destHexSecond];
    }
    free(destBytes);
    
    return destString;
}

@end
