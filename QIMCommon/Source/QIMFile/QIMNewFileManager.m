//
//  QIMNewFileManager.m
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMNewFileManager.h"
#import "QIMStringTransformTools.h"
#import "ASIFormDataRequest.h"

@implementation QIMNewFileManager

static QIMNewFileManager *_newfileManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _newfileManager = [[QIMNewFileManager alloc] init];
    });
    return _newfileManager;
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
                    callback(resultUrl);
                }
            }
//        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message {
    NSString *localImagePath = [[QIMImageManager sharedInstance] defaultCachePathForKey:localImageKey];
    NSData *imageData = [NSData dataWithContentsOfFile:localImagePath];
    if (imageData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [[imageData mutableCopy] qim_md5String];
    NSString *fileExt = [localImagePath pathExtension];
    long long size = ceil(imageData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    [self checkImageWithImageKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull imageUrl) {
        if (imageUrl.length > 0) {
            [self qim_sendImageMessageWithImageUrl:imageUrl forMessage:message withImageWidth:width withImageHeight:height];
        } else {
            NSString *method = @"file/v2/upload/img";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:localImagePath withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSString *resultUrl = [result objectForKey:@"data"];
                    if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                        [self qim_sendImageMessageWithImageUrl:resultUrl forMessage:message withImageWidth:width withImageHeight:height];
                    } else {
                        
                    }
                }
            } withFailedCallBack:^(NSError *error) {
                
            }];
        }
    }];
}

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message {
    NSData *imageData = [NSData dataWithContentsOfFile:localImagePath];
    if (imageData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [[imageData mutableCopy] qim_md5String];
    NSString *fileExt = [localImagePath pathExtension];
    long long size = ceil(imageData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    [self checkImageWithImageKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull imageUrl) {
        if (imageUrl.length > 0) {
            [self qim_sendImageMessageWithImageUrl:imageUrl forMessage:message withImageWidth:width withImageHeight:height];
        } else {
            NSString *method = @"file/v2/upload/img";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:localImagePath withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSString *resultUrl = [result objectForKey:@"data"];
                    if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                        [self qim_sendImageMessageWithImageUrl:resultUrl forMessage:message withImageWidth:width withImageHeight:height];
                    } else {
                        
                    }
                }
            } withFailedCallBack:^(NSError *error) {
                
            }];
        }
    }];
}

- (void)qim_uploadImageWithImageData:(NSData *)imageData withCallback:(QIMKitUploadImageNewRequesSuccessedBlock)callback {
    if (imageData.length <= 0) {
        return;
    }
    
    NSString *localImagePath = [[QIMNewFileManager sharedInstance] qim_saveImageData:imageData];
    
    NSString *fileKey = [[imageData mutableCopy] qim_md5String];
    NSString *fileExt = [UIImage qim_contentTypeForImageData:imageData];
    long long size = ceil(imageData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    [self checkImageWithImageKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull imageUrl) {
        if (imageUrl.length > 0) {
            if (callback) {
                callback(imageUrl);
            }
        } else {
            NSString *method = @"file/v2/upload/img";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:localImagePath withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
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
                }
            } withFailedCallBack:^(NSError *error) {
                if (callback) {
                    callback(nil);
                }
            }];
        }
    }];
}

- (void)qim_uploadImage:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequesSuccessedBlock)callback {
    NSData *imageData = [NSData dataWithContentsOfFile:localImagePath];
    if (imageData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [[imageData mutableCopy] qim_md5String];
    NSString *fileExt = [localImagePath pathExtension];
    long long size = ceil(imageData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    UIImage *image = [UIImage imageWithData:imageData];
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    [self checkImageWithImageKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull imageUrl) {
        if (imageUrl.length > 0) {
            if (callback) {
                callback(imageUrl);
            }
        } else {
            NSString *method = @"file/v2/upload/img";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:localImagePath withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
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
                }
            } withFailedCallBack:^(NSError *error) {
                if (callback) {
                    callback(nil);
                }
            }];
        }
    }];
}

#pragma mark - sync Check
- (NSString *)qim_syncCheckFileKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension{
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
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                return resultUrl;
            }
        }
    }
    return nil;
}

- (NSString *)qim_syncUploadImage:(NSData *)fileData withFileKey:(NSString *)fileKey withFileName:(NSString *)fileName {
    NSString *method = @"file/v2/upload/img";
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
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

- (NSString *)qim_syncUploadImage:(NSData *)fileData {
    NSString *fileKey = [[fileData mutableCopy] qim_md5String];
    NSString *fileExt = [UIImage qim_contentTypeForImageData:fileData];
    NSString *httpUrl = [self qim_syncCheckFileKey:fileKey WithFileLength:fileData.length WithPathExtension:fileExt];
    if (httpUrl == nil) {
        NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
        return [self qim_syncUploadImage:fileData withFileKey:fileKey withFileName:fileName];
    }
    return httpUrl;
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
        [[QIMManager sharedInstance] sendMessage:message ToUserId:message.to];
    }
}

#pragma mark - 视频
- (NSDictionary *)qim_newCheckVideo:(NSString *)fileMd5 {
    NSString *destUrl = [NSString stringWithFormat:@"%@/video/check", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"videoMd5":fileMd5};
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request addRequestHeader:@"Content-type" value:@"application/json;"];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [request addRequestHeader:@"Cookie" value:requestHeaders];
    NSMutableData *postData = [NSMutableData dataWithData:[[QIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil]];
    [request setPostBody:postData];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSDictionary *resultDic = [result objectForKey:@"data"];
            if ([resultDic isEqual:[NSNull null]] == NO && resultDic.count > 0) {
                BOOL ready = [[resultDic objectForKey:@"ready"] boolValue];
                if (ready == YES) {
                    return resultDic;
                } else {
                    return nil;
                }
            }
        }
    }
    return nil;
}

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback {
    BOOL videoConfigUseAble = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"VideoConfigUseAble"] boolValue];
    if (videoConfigUseAble == YES) {
        
        //新接口上传视频
        NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
        NSString *videoMd5 = [[videoData mutableCopy] qim_md5String];
        NSDictionary *remoteVideoDic = [self qim_newCheckVideo:videoMd5];
        if (remoteVideoDic.count) {
            //check成功
            
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
    } else {
        
        //老版本上传视频
    }
}

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
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
                NSMutableDictionary *videoContentDic = [NSMutableDictionary dictionaryWithCapacity:1];
                
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
        
    }
}

#pragma mark - 文件

- (NSString *)qim_specialMd5fromUrl:(NSString *) url {
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

- (NSString *)qim_specialGetFileExtFromUrl:(NSString *) url {
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

- (void)checkFileKeyWithKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension withCallBack:(QIMKitCheckFileCallBack)callback {
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
                if (callback) {
                    callback(resultUrl);
                }
            } else {
                if (callback) {
                    callback(nil);
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message {
    
    NSData *fileData = [NSData dataWithContentsOfFile:localFilePath];
    if (fileData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [[fileData mutableCopy] qim_md5String];
    NSString *fileExt = [localFilePath pathExtension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    [self checkFileKeyWithKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull fileUrl) {
        if (fileUrl) {
            
        } else {
            NSString *method = @"file/v2/upload/file";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:localFilePath withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSString *resultUrl = [result objectForKey:@"data"];
                    if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                        [self qim_sendFileMessageWithFileUrl:resultUrl forMessage:message];
                    } else {
                        
                    }
                }
            } withFailedCallBack:^(NSError *error) {
                
            }];
        }
    }];
}

- (void)qim_uploadFile:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequesSuccessedBlock)callback {
    NSData *fileData = [NSData dataWithContentsOfFile:localFilePath];
    if (fileData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [[fileData mutableCopy] qim_md5String];
    NSString *fileExt = [localFilePath pathExtension];
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    [self checkFileKeyWithKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull fileUrl) {
        if (fileUrl) {
            if (callback) {
                callback(fileUrl);
            }
        } else {
            NSString *method = @"file/v2/upload/file";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:localFilePath withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
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
                }
            } withFailedCallBack:^(NSError *error) {
                if (callback) {
                    callback(nil);
                }
            }];
        }
    }];
}

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithCallback:(QIMKitUploadFileNewRequesSuccessedBlock)callback {
    if (fileData.length <= 0) {
        return;
    }
    
    NSString *fileKey = [[fileData mutableCopy] qim_md5String];
    NSString *fileExt = @"zip";
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    [self checkFileKeyWithKey:fileKey WithFileLength:size WithPathExtension:fileExt withCallBack:^(NSString * _Nonnull fileUrl) {
        if (fileUrl) {
            if (callback) {
                callback(fileUrl);
            }
        } else {
            NSString *method = @"file/v2/upload/file";
            NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=ios&u=%@&k=%@&v=%@&key=%@&size=%lld",
                                 [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                                 [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                 [[QIMManager sharedInstance] myRemotelogginKey],
                                 [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFileData:fileData withProgressBlock:^(float progressValue) {
                
            } withSuccessCallBack:^(NSData *responseData) {
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
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
                }
            } withFailedCallBack:^(NSError *error) {
                if (callback) {
                    callback(nil);
                }
            }];
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
        NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
        //QIMSDKTODO
        //    if (encryptState == QTEncryptChatStateEncrypting) {
        //        NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_File WithOriginBody:msgContent WithOriginExtendInfo:msgContent WithUserId:self.message.to];
        //        self.message.message = @"加密消息记录消息iOS";
        //        self.message.extendInformation = encryptContent;
        //        self.message.messageType = QIMMessageType_Encrypt;
        //    } else {
        message.extendInformation = msgContent;
        message.message = msgContent;//@"您收到了一个文件，请升级客户端查看。";
        //    }
        
        if (message.messageType == ChatType_ConsultServer || message.messageType == ChatType_Consult) {
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
        
        if (message.messageType == ChatType_ConsultServer || message.messageType == ChatType_Consult) {
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
        //QIMSDKTODO
//        if (encryptState == QTEncryptChatStateEncrypting) {
//            NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_CommonTrdInfo WithOriginBody:@"您收到了一个消息记录文件文件，请升级客户端查看。" WithOriginExtendInfo:msgExtendInfoStr WithUserId:self.message.to];
//            self.message.message = @"加密消息记录消息iOS";
//            self.message.extendInformation = encryptContent;
//            self.message.messageType = QIMMessageType_Encrypt;
//        } else {
            message.extendInformation = msgExtendInfoStr;
            message.message = @"您收到了一个消息记录文件文件，请升级客户端查看。";
//        }
    
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
        //QIMSDKTODO
//        if (encryptState == QTEncryptChatStateEncrypting) {
//            NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_LocalShare WithOriginBody:[[self message] originalMessage] WithOriginExtendInfo:msgExtendInfo WithUserId:self.message.to];
//            self.message.message = @"加密地理位置共享消息iOS";
//            self.message.extendInformation = encryptContent;
//            self.message.messageType = QIMMessageType_Encrypt;
//        } else {
            message.extendInformation = msgExtendInfo;
            message.message = [message originalMessage];
//        }
    
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

@end
