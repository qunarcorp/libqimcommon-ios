//
//  QIMNewFileManager.m
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMNewFileManager.h"
#import "QIMStringTransformTools.h"

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

#pragma mark - 文件


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

- (void)uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback {
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
            [[QIMManager sharedInstance] uploadFileRequest:destUrl withFilePath:videoPath withPOSTBody:bodyDic withSuccessCallBack:^(NSData *responseData) {
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

- (void)uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
    NSString *videoMsg = message.message;
    NSDictionary *localVideoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:videoMsg error:nil];
    BOOL videoConfigUseAble = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"VideoConfigUseAble"] boolValue];
    if (videoConfigUseAble == YES) {
        NSDictionary *videoExt = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        [self uploadVideo:LocalVideoOutPath videoDic:videoExt withCallBack:^(NSDictionary *resultVideoData, BOOL needTrans) {
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

@end
