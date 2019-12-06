//
//  QIMFileManager.m
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMFileManager.h"
#import "QIMStringTransformTools.h"

#define QIM_MAX_FILE_EXTENSION_LENGTH (NAME_MAX - CC_MD5_DIGEST_LENGTH * 2 - 1)
#define kNewFileHashSalt    @"kNewFileHashSalt"

@interface QIMFileManager ()

@property (nonatomic, copy) NSString *localCachePath;
@property (nonatomic, copy) NSString *remoteCachePath;

@end

@implementation QIMFileManager

static QIMFileManager *_newfileManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _newfileManager = [[QIMFileManager alloc] init];
        [_newfileManager initCachePath];
    });
    return _newfileManager;
}

- (void)initCachePath {
    //本地文件缓存
    NSString *localCachePath = [UserCachesPath stringByAppendingPathComponent:QIMLocalFileCache];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:localCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    self.localCachePath = localCachePath;
    
    //远程文件缓存
    NSString *remoteCachePath = [UserCachesPath stringByAppendingPathComponent:QIMRemoteFileCache];
    if (![[NSFileManager defaultManager] fileExistsAtPath:remoteCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:remoteCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    self.remoteCachePath = remoteCachePath;
}

#pragma mark - Public
- (NSString * _Nonnull)qim_cachedFileNameForKey:(NSString * _Nullable) key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSURL *keyURL = [NSURL URLWithString:key];
    NSString *ext = keyURL ? keyURL.pathExtension : key.pathExtension;
    // File system has file name length limit, we need to check if ext is too long, we don't add it to the filename
    if (ext.length > QIM_MAX_FILE_EXTENSION_LENGTH) {
        ext = nil;
    }
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], ext.length == 0 ? @"" : [NSString stringWithFormat:@".%@", ext]];
    return filename;
}

- (NSString *)qim_getFileMD5WithPath:(NSString *)filePath {
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    return [fileData qim_md5String];
}

- (NSString *)getFileNameFromUrl:(NSString *)url {
    if ([url isKindOfClass:[NSString class]]) {
        NSURL *tempUrl = [NSURL URLWithString:url];
        NSString *tempKey = nil;
        NSString *query = [tempUrl query];
        NSString *path = [tempUrl path];
        if (path.length > 0) {
            NSString *lastPathComponent = [path lastPathComponent];
            NSString *firstComponent = [[lastPathComponent componentsSeparatedByString:@"="] lastObject];
            NSString *lastComponent = [firstComponent stringByDeletingPathExtension];
            if (lastComponent.length > 0) {
                tempKey = lastComponent;
            }
            tempKey = [tempKey stringByDeletingPathExtension];
            return tempKey;
        }
    }
    return nil;
}

#pragma mark - 图片

- (NSString *)qim_imageKey:(NSData *)imageData {
    NSString *imageKey = [[imageData mutableCopy] qim_md5String];
    NSString *imageExt = [UIImage qim_contentTypeForImageData:imageData];
    NSString *fileKey = [NSString stringWithFormat:@"%@.%@", imageKey, imageExt];
    return fileKey;
}

- (NSString *)qim_saveImageData:(NSData *)imageData {
    
    NSString *fileKey = [self qim_imageKey:imageData];
    [[SDImageCache sharedImageCache] storeImageDataToDisk:imageData forKey:fileKey];
    
    return fileKey;
}

- (NSString *)getFileExtFromUrl:(NSString *)url {
    NSURL *tempUrl = [NSURL URLWithString:url];
    NSString *extent = [[[tempUrl pathExtension] componentsSeparatedByString:@"&"] firstObject];
    return extent;
    
    NSString *query = [tempUrl query];
    if (query) {
        NSArray *parameters = [query componentsSeparatedByString:@"&"];
        for (NSString *item in parameters) {
            NSArray *value = [item componentsSeparatedByString:@"="];
            if ([value count] == 2) {
                NSString *key = [value objectAtIndex:0];
                if ([key isEqualToString:@"file"] ||
                    [key isEqualToString:@"fileurl"] ||
                    [key isEqualToString:@"md5"]||
                    [key isEqualToString:@"FileName"]||
                    [key isEqualToString:@"name"]) {
                    return [[[value objectAtIndex:1] componentsSeparatedByString:@"/"].lastObject pathExtension];
                }
            }
        }
    }
    
    NSString * urlStr = [tempUrl.absoluteString componentsSeparatedByString:@"?"].firstObject;
    if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
        NSArray *pathComponents = [urlStr pathComponents];
        NSString * tempKey = [pathComponents.lastObject componentsSeparatedByString:@"."].firstObject;
        return (tempKey.length  == 32 ) ? [pathComponents.lastObject pathExtension]:nil;
    }
    return nil;
}

- (NSString *)md5fromUrl:(NSString *)url {
    if ([url isKindOfClass:[NSString class]]) {
        NSURL *tempUrl = [NSURL URLWithString:url];
        NSString *tempKey = nil;
        NSString *query = [tempUrl query];
        NSString *path = [tempUrl path];
        if (path.length > 0) {
            NSString *lastPathComponent = [path lastPathComponent];
            NSString *firstComponent = [[lastPathComponent componentsSeparatedByString:@"="] lastObject];
            NSString *lastComponent = [firstComponent stringByDeletingPathExtension];
            if (lastComponent.length > 0) {
                tempKey = lastComponent;
            }
            tempKey = [tempKey stringByDeletingPathExtension];
            return tempKey;
        }
    }
    return nil;
}

/**
 上传图片成功之后会，发送图片消息

 @param localImageKey 图片key
 @param message 要发送的消息Model
 */
- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message {
    
    if (localImageKey.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localImageKey]) {
        //兼容以前传进来全路径的问题
        [self qim_uploadImageWithImagePath:localImageKey forMessage:message];
    } else {
        //新版本使用半路径
        NSString *localImagePath = [[QIMImageManager sharedInstance] defaultCachePathForKey:localImageKey];
        [self qim_uploadImageWithImagePath:localImagePath forMessage:message];
    }
}


/**
 上传图片成功之后，发送图片消息

 @param localImagePath 本地图片路径
 @param message 要发送的消息Model
 */
- (void)qim_uploadImageWithImagePath:(NSString *)localImagePath forMessage:(QIMMessageModel *)message {
    NSData *imageData = [NSData dataWithContentsOfFile:localImagePath];
    if (imageData.length <= 0) {
        return;
    }
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    [self qim_uploadImageWithImagePath:localImagePath withCallback:^(NSString *imageUrl) {
        if ([imageUrl isEqual:[NSNull null]] == NO && imageUrl.length > 0) {
            [self qim_sendImageMessageWithImageUrl:imageUrl forMessage:message withImageWidth:width withImageHeight:height];
        } else {
            
        }
    }];
}


/**
 上传图片

 @param localImagePath 本地图片路径
 @param callback 返回图片地址
 */
- (void)qim_uploadImageWithImagePath:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequestSuccessedBlock)callback {
    NSData *imageData = [NSData dataWithContentsOfFile:localImagePath];
    if (imageData.length <= 0) {
        return;
    }
    NSString *fileExt = [localImagePath pathExtension];
    [self qim_uploadImageWithImageData:imageData WithMsgId:[QIMUUIDTools UUID] WithMsgType:30 WithPathExtension:fileExt withCallBack:callback];
}

/**
 上传图片
 
 @param fileData 图片二进制
 @param key fileKey
 @param type type
 @param extension 文件后缀
 @return 返回图片地址
 */
- (void)qim_uploadImageWithImageData:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadImageCallBack)callback {
    NSString *fileKey = [[fileData mutableCopy] qim_md5String];
    NSString *fileExt = [UIImage qim_contentTypeForImageData:fileData];
    if (fileExt.length > 0) {
        extension = fileExt;
    }
    [self checkImageWithImageKey:fileKey WithFileLength:fileData.length WithPathExtension:extension withCallBack:^(NSString * _Nonnull httpUrl) {
        if (httpUrl == nil) {
            [self privateUpLoadImage:fileData WithMsgId:fileKey WithMsgType:type WithPathExtension:extension withCallBack:^(NSString *result) {
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


/**
 上传我的头像

 @param headerData 头像二进制
 @param callback 返回头像地址
 */
- (void)qim_uploadMyPhotoData:(NSData *)headerData withCallBack:(QIMKitUploadMyPhotoCallBack)callback {
    NSString *method = @"file/v2/upload/avatar";
    
    NSString *fileKey = [[headerData mutableCopy] qim_md5String];
    NSString *fileExt = [UIImage qim_contentTypeForImageData:headerData];
    long long size = ceil(headerData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    
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

#pragma mark - Private Method

- (void)checkImageWithImageKey:(NSString *)imageKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension withCallBack:(QIMKitCheckImageCallBack)callback {
    NSString *method = @"file/v2/inspection/img";
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&platform=iphone&u=%@&k=%@&version=%@",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, imageKey, (long long)ceil(fileLength / 1024.0 / 1024.0), [NSString stringWithFormat:@"%@.%@",imageKey, extension],
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        //        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        //        if (ret) {
        NSString *resultUrl = [result objectForKey:@"data"];
        if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
            if (callback) {
                callback(resultUrl);
            }
        } else {
            if (callback) {
                callback(nil);
            }
        }
        //        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)privateUpLoadImage:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadImageCallBack)callback {
    NSString *method = @"file/v2/upload/img";
    NSString *fileName =  [NSString stringWithFormat:@"%@.%@",key,extension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],key,size];
    NSLog(@"上传图片destUrl : %@", destUrl);
    //这里上报一下上传图片的进度，渲染图片进度
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kQIMUploadImageProgress object:@{@"ImageUploadKey":fileName, @"ImageUploadProgress":@(0)}];
    });
    [[QIMManager sharedInstance] uploadFileRequest:destUrl withFileData:fileData withProgressBlock:^(float progressValue) {
        NSLog(@"privateUpLoadImage : %lf", progressValue);
        //这里上报一下上传图片的进度，渲染图片进度
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMUploadImageProgress object:@{@"ImageUploadKey":fileName, @"ImageUploadProgress":@(progressValue)}];
        });
    } withSuccessCallBack:^(NSData *responseData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMUploadImageProgress object:@{@"ImageUploadKey":fileName, @"ImageUploadProgress":@(1.0)}];
        });
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
}

- (void)qim_sendImageMessageWithImageUrl:(NSString *)imageUrl forMessage:(QIMMessageModel *)message withImageWidth:(CGFloat)width withImageHeight:(CGFloat)height {
    QIMMessageType msgType = message.messageType;
    if (QIMMessageType_Text == msgType || QIMMessageType_Image == msgType || QIMMessageType_ImageNew == msgType) {
        NSString *messageNewBody = message.message;
        if ([imageUrl qim_hasPrefixHttpHeader]) {
            messageNewBody = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@\" width=%f height=%f]", imageUrl, width, height];
        } else {
            messageNewBody = [NSString stringWithFormat:@"[obj type=\"image\" value=\"%@/%@\" width=%f height=%f]", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], imageUrl, width, height];
        }
        message.message = messageNewBody;
#if __has_include("QIMNoteManager.h")
        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:message.messageType WithOriginBody:messageNewBody WithOriginExtendInfo:nil WithUserId:message.to];
            message.message = @"iOS加密消息";
            message.extendInformation = encrypeMsg;
            message.messageType = QIMMessageType_Encrypt;
        }
#endif
        if (message.chatType == ChatType_ConsultServer || message.chatType == ChatType_Consult) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else {
            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
        }
    } else if (QIMMessageType_LocalShare == msgType) {
        NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.originalExtendedInfo error:nil];
        NSMutableDictionary * mulDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [mulDic setQIMSafeObject:imageUrl forKey:@"fileUrl"];
        NSString *msgExtendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
        message.extendInformation = msgExtendInfo;
        message.message = [message originalMessage];
#if __has_include("QIMNoteManager.h")
        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:message.messageType WithOriginBody:message.message WithOriginExtendInfo:nil WithUserId:message.to];
            message.message = @"iOS加密地理位置消息";
            message.extendInformation = encrypeMsg;
            message.messageType = QIMMessageType_Encrypt;
        }
#endif
        if (message.chatType == ChatType_Consult || message.chatType == ChatType_ConsultServer) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else{
            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
        }
    } else {
        
    }
}

#pragma mark - 视频
- (void)qim_newCheckVideo:(NSString *)fileMd5 withCallBack:(QIMKitCheckNewVideoCallBack)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/video/check", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"videoMd5":fileMd5};
    NSMutableData *postData = [NSMutableData dataWithData:[[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil]];
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:postData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
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
}

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequestSuccessedBlock)callback {
    BOOL videoConfigUseAble = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"VideoConfigUseAble"] boolValue];
    NSInteger videoMaxTimeLen = [[[QIMKit sharedInstance] userObjectForKey:@"videoMaxTimeLen"] integerValue];
    NSInteger videoDuration = [[videoExt objectForKey:@"Duration"] integerValue];
    if ((videoConfigUseAble == YES) && (videoDuration < videoMaxTimeLen)) {
        //当服务端返回的VideoConfigUseAble == true 或者 视频时长小于 服务器下发的videoMaxTimeLen时长
        //新接口上传视频
        NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
        NSString *videoMd5 = [[videoData mutableCopy] qim_md5String];
        [self qim_newCheckVideo:videoMd5 withCallBack:^(NSDictionary *remoteVideoDic) {
            if (remoteVideoDic.count) {
                //check成功
                NSLog(@"remoteVideo: %@", remoteVideoDic);
                if (callback) {
                    callback(remoteVideoDic, YES);
                }
            } else {
                //限制视频时长
                NSInteger videoTimeLen = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"videoTimeLen"] integerValue] / 1000;
                NSInteger videoDuration = [[videoExt objectForKey:@"Duration"] integerValue];
                
                NSString *needTransStr = @"true";
                __block BOOL needTrans = YES;
                if (videoDuration < videoTimeLen) {
                    //小于限制时长，需要转码
                    needTransStr = @"true";
                    needTrans = YES;
                } else {
                    //大于限制时长，不需要转码
                    needTransStr = @"false";
                    needTrans = NO;
                }
                
                NSString *destUrl = [NSString stringWithFormat:@"%@/video/upload", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
                NSDictionary *bodyDic = @{@"needTrans":needTransStr};
                [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:videoPath withPOSTBody:bodyDic withProgressBlock:^(float progressValue) {
                    
                } withSuccessCallBack:^(NSData *responseData) {
                    NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                    NSLog(@"resultDic : %@", resultDic);
                    BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
                    if (ret) {
                        NSDictionary *data = [resultDic objectForKey:@"data"];
                        if (callback) {
                            callback(data, needTrans);
                        }
                    } else {
                        if (callback) {
                            callback(nil, needTrans);
                        }
                    }
                } withFailedCallBack:^(NSError *error) {
                    if (callback) {
                        callback(nil, needTrans);
                    }
                }];
            }
        }];
    } else {
        //老版本上传视频
        [self qim_uploadFileWithFilePath:videoPath WithCallback:^(NSString *fileUrl) {
            if (callback) {
                callback(fileUrl, NO);
            }
        }];
    }
}

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *videoMsg = message.message;
        NSDictionary *localVideoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:videoMsg error:nil];
        BOOL videoConfigUseAble = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"VideoConfigUseAble"] boolValue];
        if (videoConfigUseAble == YES) {
            NSDictionary *videoExt = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            [self qim_uploadVideo:LocalVideoOutPath videoDic:videoExt withCallBack:^(NSDictionary *resultVideoData, BOOL needTrans) {
                if (resultVideoData.count) {
                    NSString *firstThumbUrl = [resultVideoData objectForKey:@"firstThumbUrl"];
                    NSString *ThumbName = [resultVideoData objectForKey:@"firstThumb"];
                    NSString *videoUrl = [resultVideoData objectForKey:@"transUrl"];
                    NSDictionary *transFileInfo = [resultVideoData objectForKey:@"transFileInfo"];
                    NSString *videoName = [transFileInfo objectForKey:@"videoName"];
                    long long videoSize = [[transFileInfo objectForKey:@"videoSize"] longLongValue];
                    NSString *height = [transFileInfo objectForKey:@"height"];
                    NSString *width = [transFileInfo objectForKey:@"width"];
                    NSInteger Duration = [[transFileInfo objectForKey:@"duration"] integerValue] / 1000;
                    NSString *fileSizeStr = [QIMStringTransformTools qim_CapacityTransformStrWithSize:videoSize];
                    
                    NSString *onlineUrl = [resultVideoData objectForKey:@"onlineUrl"];
                    
                    NSMutableDictionary *newVideoDic = [NSMutableDictionary dictionaryWithCapacity:1];
                    [newVideoDic setQIMSafeObject:@(Duration) forKey:@"Duration"];
                    [newVideoDic setQIMSafeObject:videoName forKey:@"FileName"];
                    [newVideoDic setQIMSafeObject:fileSizeStr forKey:@"FileSize"];
                    [newVideoDic setQIMSafeObject:videoUrl forKey:@"FileUrl"];
                    [newVideoDic setQIMSafeObject:height forKey:@"Height"];
                    [newVideoDic setQIMSafeObject:ThumbName forKey:@"ThumbName"];
                    [newVideoDic setQIMSafeObject:firstThumbUrl forKey:@"ThumbUrl"];
                    [newVideoDic setQIMSafeObject:width forKey:@"Width"];
                    [newVideoDic setQIMSafeObject:@(needTrans) forKey:@"newVideo"];
                    
                    NSString *msg = [[QIMJSONSerializer sharedInstance] serializeObject:newVideoDic];
                    NSString *msgContent = [NSString stringWithFormat:@"发送了一段视频. [obj type=\"url\" value=\"%@\"]", onlineUrl];
                    message.message = msgContent;
                    message.extendInformation = msg;
                    message.messageType = QIMMessageType_SmallVideo;
                    
#if __has_include("QIMNoteManager.h")
                    if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
                        NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_SmallVideo WithOriginBody:msgContent WithOriginExtendInfo:msg WithUserId:message.to];
                        message.message = @"iOS加密视频消息";
                        message.extendInformation = encrypeMsg;
                        message.messageType = QIMMessageType_Encrypt;
                    }
#endif
                    
                    if (message.chatType == ChatType_PublicNumber) {
                        [[QIMManager sharedInstance] sendMessage:msg ToPublicNumberId:message.to WithMsgId:message.messageId WithMsgType:message.messageType];
                    } else if (message.chatType == ChatType_Consult || message.chatType == ChatType_ConsultServer) {
                        [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
                    } else {
                        [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
                    }
                }
            }];
        } else {
            //老版本上传视频
            NSDictionary *videoExt = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
            NSString *pathExtension = [[LocalVideoOutPath lastPathComponent] pathExtension];
            NSString *fileName = [[LocalVideoOutPath lastPathComponent] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
            NSString *thumbFilePath = [LocalVideoOutPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", pathExtension] withString:@"_thumb.jpg"];
            [self qim_uploadImageWithImagePath:thumbFilePath withCallback:^(NSString *imageUrl) {
                NSString *thumbImageUrl = imageUrl;
                [self qim_uploadFileWithFilePath:LocalVideoOutPath WithCallback:^(NSString *fileUrl) {
                    if (fileUrl.length > 0) {
                        NSMutableDictionary *newVideoDic = [NSMutableDictionary dictionaryWithDictionary:videoExt];
                        [newVideoDic setQIMSafeObject:fileUrl forKey:@"FileUrl"];
                        [newVideoDic setQIMSafeObject:@(NO) forKey:@"newVideo"];
                        [newVideoDic setQIMSafeObject:(thumbImageUrl.length > 0) ? thumbImageUrl : @"" forKey:@"ThumbUrl"];
                        
                        NSString *msg = [[QIMJSONSerializer sharedInstance] serializeObject:newVideoDic];
                        NSString *msgContent = [NSString stringWithFormat:@"发送了一段视频. [obj type=\"url\" value=\"%@\"]", fileUrl];
                        message.message = msgContent;
                        message.extendInformation = msg;
                        message.messageType = QIMMessageType_SmallVideo;
                        
#if __has_include("QIMNoteManager.h")
                        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
                            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_SmallVideo WithOriginBody:msgContent WithOriginExtendInfo:msg WithUserId:message.to];
                            message.message = @"iOS加密视频消息S";
                            message.extendInformation = encrypeMsg;
                            message.messageType = QIMMessageType_Encrypt;
                        }
#endif
                        
                        if (message.chatType == ChatType_PublicNumber) {
                            [[QIMManager sharedInstance] sendMessage:msg ToPublicNumberId:message.to WithMsgId:message.messageId WithMsgType:message.messageType];
                        } else if (message.chatType == ChatType_Consult || message.chatType == ChatType_ConsultServer) {
                            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
                        } else {
                            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
                        }
                    }
                }];
            }];
        }
    });
}

#pragma mark - 文件

- (void)qim_uploadFileWithFilePath:(NSString *)localFilePath forMessage:(QIMMessageModel *)message {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSData *fileData = [NSData dataWithContentsOfFile:localFilePath];
        if (fileData.length <= 0) {
            return;
        }
        [self qim_uploadFileWithFileData:fileData withMsgId:message.messageId WithPathExtension:[localFilePath pathExtension] WithCallback:^(NSString *resultUrl) {
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                [self qim_sendFileMessageWithFileUrl:resultUrl forMessage:message];
            } else {
                
            }
        }];
    });
}


- (void)qim_uploadFileWithFileData:(NSData *)fileData WithPathExtension:(NSString *)extension forMessage:(QIMMessageModel *)message {
    if (fileData.length <= 0) {
        return;
    }
    [self qim_uploadFileWithFileData:fileData withMsgId:message.messageId WithPathExtension:extension WithCallback:^(NSString *resultUrl) {
        if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
            [self qim_sendFileMessageWithFileUrl:resultUrl forMessage:message];
        } else {
            
        }
    }];
}

- (void)qim_uploadFileWithFilePath:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback {
    NSData *fileData = [NSData dataWithContentsOfFile:localFilePath];
    if (fileData.length <= 0) {
        return;
    }
    
    [self qim_uploadFileWithFileData:fileData WithPathExtension:[localFilePath pathExtension] WithCallback:callback];
}

- (void)qim_uploadFileWithFileData:(NSData *)fileData withMsgId:(NSString *)messageId WithPathExtension:(NSString *)extension WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback {
    if (fileData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [fileData qim_md5String];
    NSString *fileExt = extension;
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    [self checkFileKeyForFile:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString *fileUrl) {
        if (fileUrl.length > 0) {
            if (callback) {
                callback(fileUrl);
            }
        } else {
            [self privateUpLoadFile:fileData WithFileKey:fileKey withMsgId:messageId WithMsgType:5 WithPathExtension:fileExt withCallBack:callback];
        }
    }];
}

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithPathExtension:(NSString *)extension WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback {
    [self qim_uploadFileWithFileData:fileData withMsgId:[QIMUUIDTools UUID] WithPathExtension:extension WithCallback:callback];
}

#pragma mark - 文件Private Method

- (void)checkFileKeyForFile:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension withCallBack:(QIMKitCheckFileKeyForFileCallBack)callback{
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
}

- (void)privateUpLoadFile:(NSData *)fileData WithFileKey:(NSString *)fileKey withMsgId:(NSString *)msgId WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadFileCallBack)callBack {
    NSString *method = @"file/v2/upload/file";
    NSString *fileName =  [NSString stringWithFormat:@"%@.%@",fileKey, extension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    [[QIMManager sharedInstance] uploadFileRequest:destUrl withFileData:fileData withProgressBlock:^(float progressValue) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMUploadFileProgress object:@{@"FileUploadKey":fileKey, @"MessageId":msgId, @"ImageUploadProgress":@(progressValue)}];
        });
    } withSuccessCallBack:^(NSData *responseData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMUploadFileProgress object:@{@"FileUploadKey":fileKey, @"MessageId":msgId, @"ImageUploadProgress":@(1.0)}];
        });
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
}

- (void)qim_sendFileMessageWithFileUrl:(NSString *)fileUrl forMessage:(QIMMessageModel *)message {
    
    QIMMessageType msgType = message.messageType;
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
    if (QIMMessageType_File == msgType) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.extendInformation error:nil];
        NSMutableDictionary * mulDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
        [mulDic setQIMSafeObject:fileUrl forKey:@"HttpUrl"];
        [mulDic removeObjectForKey:@"Uploading"];

        NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
        message.extendInformation = msgContent;
        message.message = msgContent;//@"您收到了一个文件，请升级客户端查看。";
        
#if __has_include("QIMNoteManager.h")
        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_File WithOriginBody:msgContent WithOriginExtendInfo:msgContent WithUserId:message.to];
            message.message = @"加密消息记录消息iOS";
            message.extendInformation = encrypeMsg;
        }
#endif
        if (message.chatType == ChatType_ConsultServer || message.chatType == ChatType_Consult) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else {
            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
        }
    } else if (QIMMessageType_Voice == msgType) {
        
        NSDictionary *voiceMsgBodyDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:voiceMsgBodyDic];
        if (![fileUrl qim_hasPrefixHttpHeader]) {
            fileUrl = [NSString stringWithFormat:@"%@/%@", [QIMNavConfigManager sharedInstance].innerFileHttpHost, fileUrl];
        }
        [mulDic setQIMSafeObject:fileUrl forKey:@"HttpUrl"];
        NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
        message.message = msgContent;
        
#if __has_include("QIMNoteManager.h")
        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Voice WithOriginBody:msgContent WithOriginExtendInfo:nil WithUserId:message.to];
            message.message = @"iOS加密语音消息";
            message.extendInformation = encrypeMsg;
            message.messageType = QIMMessageType_Encrypt;
        }
#endif

        if (message.chatType == ChatType_ConsultServer || message.chatType == ChatType_Consult) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else {
            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
        }
    } else if (QIMMessageType_CommonTrdInfo == msgType || QIMMessageType_CommonTrdInfoPer == msgType) {
        NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
        if (![fileUrl qim_hasPrefixHttpHeader]) {
            fileUrl = [NSString stringWithFormat:@"%@/%@", [QIMNavConfigManager sharedInstance].innerFileHttpHost, fileUrl];
        }
        NSString * jDataStr = [[fileUrl dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        NSString *shareurl = [NSString stringWithFormat:@"%@?jdata=%@", [[QIMNavConfigManager sharedInstance] shareUrl], [jDataStr qim_URLEncodedString]];
        [mulDic setQIMSafeObject:shareurl forKey:@"linkurl"];
        NSString *msgExtendInfoStr = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
        message.extendInformation = msgExtendInfoStr;
        message.message = @"您收到了一个消息记录文件文件，请升级客户端查看。";
#if __has_include("QIMNoteManager.h")
        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_Voice WithOriginBody:@"您收到了一个消息记录文件文件，请升级客户端查看。" WithOriginExtendInfo:msgExtendInfoStr WithUserId:message.to];
            message.message = @"iOS加密消息记录";
            message.extendInformation = encrypeMsg;
            message.messageType = QIMMessageType_Encrypt;
        }
#endif
        if (message.chatType == ChatType_Consult || message.chatType == ChatType_ConsultServer) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else {
            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
        }
    } else if (QIMMessageType_LocalShare == msgType) {
        NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.originalExtendedInfo error:nil];
        NSMutableDictionary *mulDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [mulDic setQIMSafeObject:fileUrl forKey:@"fileUrl"];
        NSString *msgExtendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
        message.extendInformation = msgExtendInfo;
        message.message = [message originalMessage];
        
#if __has_include("QIMNoteManager.h")
        if (message.encryptChatState == QIMEncryptChatStateEncrypting) {
            NSString *encrypeMsg = [[QIMEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_LocalShare WithOriginBody:[message originalMessage] WithOriginExtendInfo:msgExtendInfo WithUserId:message.to];
            message.message = @"iOS加密地理位置共享消息";
            message.extendInformation = encrypeMsg;
            message.messageType = QIMMessageType_Encrypt;
        }
#endif
        if (message.chatType == ChatType_Consult) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else if (message.chatType == ChatType_ConsultServer) {
            [[QIMManager sharedInstance] sendConsultMessageId:message.messageId WithMessage:message.message WithInfo:message.extendInformation toJid:message.to realToJid:message.realJid WithChatType:message.chatType WithMsgType:message.messageType];
        } else{
            [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:[NSDictionary dictionaryWithObjectsAndKeys:message,@"message",@"1.1",@"propress",@"uploading",@"status", nil]];
    } else {
        
    }
}

- (NSString *)qim_getLocalFileDataWithFileName:(NSString *)fileName {
    if (nil == fileName || [fileName length] == 0) {
        return nil;
    }
    // 获取resource文件路径
    NSString *resourcePath = [self.localCachePath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
        return resourcePath;
    }
    return nil;
}

- (NSString *)qim_saveLocalFileData:(NSData *)fileData withFileName:(NSString *)fileName {
        
    if (nil == fileName || [fileName length] == 0) {
        return nil;
    }
    // 获取resource文件路径
    NSString *resourcePath = [self.localCachePath stringByAppendingPathComponent:fileName];
    BOOL suc = [fileData writeToFile:resourcePath atomically:YES];
    if (suc == YES) {
        NSLog(@"write YES");
    } else {
        NSLog(@"write Faild");
    }
    return fileName;
}

@end
