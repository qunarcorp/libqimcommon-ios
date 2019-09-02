//
//  QIMFileManager.m
//  qunarChatIphone
//
//  Created by chenjie on 16/6/20.
//
//

typedef enum {
    FileRequest_Upload,
    FileRequest_Download,
}FileRequestType;

#define kResourceCachePath                          @"Resource"
#define kCollectionResourceCachePath                @"collectionResource"
#define kThumbMaxWidth              [UIScreen mainScreen].bounds.size.width / 3
#define kThumbMaxHeight             [UIScreen mainScreen].bounds.size.width / 3

#import "QIMFileManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "QIMHttpApi.h"
#import "QIMPrivateHeader.h"
#import "ASIFormDataRequest.h"
#import "ASIDataDecompressor.h"
#import "QIMUserCacheManager.h"
#import "QIMHttpRequestMonitor.h"
#import "QIMJSONSerializer.h"

@interface QIMFileManagerSizeManager :NSObject

@end

@implementation QIMFileManagerSizeManager

+ (NSString *)qim_CapacityTransformStrWithSize:(long long)size{
    return [self qim_CapacityTransformStrWithSize:size WithStrLenght:0];
}


+ (NSString *)qim_CapacityTransformStrWithSize:(long long)size WithStrLenght:(NSUInteger)length{
    double lengths = size;
    NSString *lenStr = nil;
    NSString *unitStr = nil;
    int unit = 0;
    while ( lengths > 1000 && unit < 5) {
        unit++;
        lengths = lengths / 1024.0;
    }
    if (length == 0) {
        if (unit == 0) {
            lenStr = [NSString stringWithFormat:@"%.2fB",lengths];
        } else if (unit == 1) {
            lenStr = [NSString stringWithFormat:@"%.2fKB",lengths];
        } else if (unit == 2) {
            lenStr = [NSString stringWithFormat:@"%.2fMB",lengths];
        } else if (unit == 3) {
            lenStr = [NSString stringWithFormat:@"%.2fG",lengths];
        } else {
            lenStr = [NSString stringWithFormat:@"%.2fTB",lengths];
        }
    } else {
        if (unit == 0) {
            unitStr = @"B";
        } else if (unit == 1) {
            unitStr = @"KB";
        } else if (unit == 2) {
            unitStr = @"MB";
        } else if (unit == 3) {
            unitStr = @"G";
        } else {
            unitStr = @"TB";
        }
        if (length > 2) {
            NSInteger strl = length - [unitStr length];
            NSString *ls = [[NSString stringWithFormat:@"%.2f",lengths] substringToIndex:strl];
            if ([[ls substringWithRange:NSMakeRange(ls.length - 1, 1)] isEqualToString:@"."]) {
                ls = [ls substringToIndex:ls.length - 1];
            }
            lenStr = [NSString stringWithFormat:@"%@%@",ls,unitStr];
        } else {
            lenStr = [NSString stringWithFormat:@"%.2f%@",lengths,unitStr];
        }
    }
    
    return lenStr;
}

@end

@interface QIMFileManager () {
    
}
- (void)removeFileId:(NSString *)fileId;

@end

@interface QIMFileRequest : NSObject <ASIHTTPRequestDelegate,ASIProgressDelegate>
@property (nonatomic, assign) ASIHTTPRequest *fileRequest;
@property (nonatomic, assign) FileRequestType fileReuqestType;
@property (nonatomic, assign) QIMFileCacheType fileCacheType;
@property (nonatomic, assign) BOOL newVideoInterface;
@property (nonatomic, assign) BOOL transVideo;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSString *fileSizeStr;
@property (nonatomic, strong) NSString *fileUrl;
@property (nonatomic, strong) QIMMessageModel *message;
@property (nonatomic, strong) NSString *md5;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, copy) NSString    * toJid;

- (void)appendToJid:(NSString *)jid;
- (void)setReceiveData:(NSMutableData *)data;
@end

@implementation QIMFileRequest{
    
    long long _requestLength;
    long long _currentOffset;
    double _maxValue;
    double _progressValue;
    NSMutableSet *_sendToJid;
    NSMutableData *_receiveData;
    NSFileHandle *_fileHandle;
    int _fileOffset;
}

- (void)setReceiveData:(NSMutableData *)data{
    _receiveData = data;
}

- (void)dealloc{
    QIMErrorLog(@"QIMFileRequest Dealloc : %p", self);
    [self setFileRequest:nil];
    [self setFilePath:nil];
    [self setFileId:nil];
    [self setFileSizeStr:nil];
    [self setFileUrl:nil];
    [self setMessage:nil];
    [self setImageData:nil];
    [self setToJid:nil];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _requestLength = 0;
        _currentOffset = 0;
        _sendToJid = [NSMutableSet set];
        _receiveData = [NSMutableData data];
        _fileOffset = 0;
    }
    return self;
}

- (void)appendToJid:(NSString *)jid{
    if (jid) {
        [_sendToJid addObject:jid];
        self.toJid = jid;
    }
}

- (void)cancelToJid:(NSString *)jid{
    if (jid) {
        [_sendToJid removeObject:jid];
        if (_sendToJid.count <= 0) {
            [[QIMFileManager sharedInstance] removeFileId:self.fileId];
        }
    }
}

#pragma mark - asi http request delegate

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    if (self.fileReuqestType == FileRequest_Upload) {
        [_receiveData appendData:data];
    } else {
        [_receiveData appendData:data];
        /*if (_fileHandle == nil) {
            [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
            _fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
        }
        [_fileHandle truncateFileAtOffset:_fileOffset];
        [_fileHandle writeData:data];
        _fileOffset += data.length;
         */
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    NSString *fileId = self.fileId;
    if (self.fileReuqestType == FileRequest_Upload) {
        NSString *httpUrl = nil;
        NSDictionary *resultVideoData = nil;
        QIMVerboseLog(@"上传真正的文件结果 : %@ ForMessage: %@", [request responseString], self.message);
        if ([request responseStatusCode] == 200) {
            NSData * data = nil;
            if ([request isResponseCompressed] && [request shouldWaitToInflateCompressedResponses]) {
                data = [ASIDataDecompressor uncompressData:_receiveData error:NULL];
            } else {
                data = _receiveData;
            }
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
            
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                if (self.newVideoInterface == YES) {
                    resultVideoData = [result objectForKey:@"data"];
                } else {
                    NSString *resultUrl = [result objectForKey:@"data"];
                    if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl.length > 0) {
                        httpUrl = resultUrl;
                        /*
                         NSURL *url = [NSURL URLWithString:resultUrl];
                         resultUrl = [url path];
                         NSString *innerFileUrlPath = [[NSURL URLWithString:[[QIMNavConfigManager sharedInstance] innerFileHttpHost]] path];
                         if ([resultUrl containsString:innerFileUrlPath]) {
                         resultUrl = [resultUrl substringFromIndex:innerFileUrlPath.length];
                         }
                         NSUInteger loc = [resultUrl rangeOfString:@"/"].location + 1;
                         NSDictionary *queryDic = [[url query] qim_dictionaryFromQueryComponents];
                         if (loc < resultUrl.length) {
                         NSString *fileName = url.pathComponents.lastObject;
                         httpUrl = [[resultUrl substringFromIndex:1] stringByAppendingFormat:@"?file=file/%@&FileName=file/%@&name=%@",fileName,fileName,[queryDic objectForKey:@"name"]];
                         } */
                    }
                }
            }
            if (self.newVideoInterface == YES) {
                if (resultVideoData == nil) {
                    [self requestFailed:request];
                    [[QIMFileManager sharedInstance] removeFileId:self.fileId];
                    return;
                }
            } else {
                if (httpUrl == nil) {
                    [self requestFailed:request];
                    [[QIMFileManager sharedInstance] removeFileId:self.fileId];
                    return;
                }
                //image url 拼上msgID
                httpUrl = [httpUrl stringByAppendingFormat:@"&msgid=%@",self.message.messageId];
            }

            //更新消息时间
            long long msgDate = ([[NSDate date] timeIntervalSince1970] - [[QIMManager sharedInstance] getServerTimeDiff])*1000;
            self.message.messageDate = msgDate;
            NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil];
            //获取加密状态
            //QIMSDKTODO
//            QTEncryptChatState encryptState = [[QTEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.message.to];
            if (self.message.messageType == QIMMessageType_SmallVideo) {
                if (self.newVideoInterface == YES) {
                    NSString *firstThumbUrl = [resultVideoData objectForKey:@"firstThumbUrl"];
                    NSString *ThumbName = [resultVideoData objectForKey:@"firstThumb"];
                    NSString *videoUrl = [resultVideoData objectForKey:@"transUrl"];
                    NSDictionary *transFileInfo = [resultVideoData objectForKey:@"transFileInfo"];
                    NSString *videoName = [transFileInfo objectForKey:@"videoName"];
                    long long videoSize = [[transFileInfo objectForKey:@"videoSize"] longLongValue];
                    NSString *height = [transFileInfo objectForKey:@"height"];
                    NSString *width = [transFileInfo objectForKey:@"width"];
                    NSInteger Duration = [[transFileInfo objectForKey:@"duration"] integerValue] / 1000;
                    NSString *fileSizeStr = [QIMFileManagerSizeManager qim_CapacityTransformStrWithSize:videoSize];

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
                    if (self.transVideo == YES) {
                        [newVideoDic setQIMSafeObject:@(YES) forKey:@"newVideo"];
                    } else {
                        [newVideoDic setQIMSafeObject:@(NO) forKey:@"newVideo"];
                    }
                    
                    NSString *msg = [[QIMJSONSerializer sharedInstance] serializeObject:newVideoDic];
                    NSString *msgContent = [NSString stringWithFormat:@"发送了一段视频. [obj type=\"url\" value=\"%@\"]", onlineUrl];
                    self.message.message = msgContent;
                    self.message.extendInformation = msg;
                    self.message.messageType = QIMMessageType_SmallVideo;
                    if (self.message.chatType == ChatType_PublicNumber) {
                        [[QIMManager sharedInstance] sendMessage:msg ToPublicNumberId:self.toJid WithMsgId:self.message.messageId WithMsgType:self.message.messageType];
                    } else if (self.message.chatType == ChatType_Consult || self.message.chatType == ChatType_ConsultServer) {
                        [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                    } else {
                        [[QIMManager sharedInstance] sendMessage:self.message ToUserId:self.message.to];
                    }
                } else {
                    if ([[infoDic objectForKey:@"msgType"] integerValue] == QIMMessageType_SmallVideo && self.message.extendInformation.length > 0) {
                        self.message.message = [[[QIMJSONSerializer sharedInstance] deserializeObject:self.message.extendInformation error:nil] objectForKey:@"message"];
                    }
                    NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.message error:nil];
                    if (dic) {
                        NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                        [infoDic setObject:httpUrl forKey:@"FileUrl"];
                        NSString *msg = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
                        
                        if (![httpUrl qim_hasPrefixHttpHeader]){
                            httpUrl = [[QIMNavConfigManager sharedInstance].innerFileHttpHost stringByAppendingFormat:@"/%@", httpUrl];
                        }
                        NSString *messageContent = [NSString stringWithFormat:@"发送了一段视频. [obj type=\"url\" value=\"%@\"]", httpUrl];
                        //QIMSDKTODO
//                        if (encryptState == QTEncryptChatStateEncrypting) {
//                            NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_SmallVideo WithOriginBody:messageContent WithOriginExtendInfo:msg WithUserId:self.message.to];
//                            self.message.message = @"加密视频消息iOS";
//                            self.message.extendInformation = encryptContent;
//                            self.message.messageType = QIMMessageType_Encrypt;
//                        } else {
                            self.message.message = messageContent;
                            self.message.extendInformation = msg;
                            self.message.messageType = QIMMessageType_SmallVideo;
//                        }
                        if (self.message.chatType == ChatType_PublicNumber) {
                            [[QIMManager sharedInstance] sendMessage:msg ToPublicNumberId:self.toJid WithMsgId:self.message.messageId WithMsgType:self.message.messageType];
                        } else if (self.message.chatType == ChatType_Consult || self.message.chatType == ChatType_ConsultServer) {
                            [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                        } else {
                            [[QIMManager sharedInstance] sendMessage:self.message ToUserId:self.toJid];
                        }
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:[NSDictionary dictionaryWithObjectsAndKeys:self.message,@"message",@"1.1",@"propress",@"uploading",@"status", nil]];
            } else if (self.message.messageType == QIMMessageType_LocalShare){
                NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.originalExtendedInfo error:nil];
                NSMutableDictionary * mulDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [mulDic setQIMSafeObject:httpUrl forKey:@"fileUrl"];
                NSString *msgExtendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
                //QIMSDKTODO
//                if (encryptState == QTEncryptChatStateEncrypting) {
//                    NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_LocalShare WithOriginBody:[[self message] originalMessage] WithOriginExtendInfo:msgExtendInfo WithUserId:self.message.to];
//                    self.message.message = @"加密地理位置共享消息iOS";
//                    self.message.extendInformation = encryptContent;
//                    self.message.messageType = QIMMessageType_Encrypt;
//                }else {
                    self.message.extendInformation = msgExtendInfo;
                    self.message.message = [[self message] originalMessage];
//                }
                
                if (self.message.chatType == ChatType_Consult) {
                    [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                } else if (self.message.chatType == ChatType_ConsultServer) {
                    [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                } else{
                    [[QIMManager sharedInstance] sendMessage:self.message ToUserId:self.toJid];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:[NSDictionary dictionaryWithObjectsAndKeys:self.message,@"message",@"1.1",@"propress",@"uploading",@"status", nil]];
            }else if (self.message.messageType == QIMMessageType_CommonTrdInfo) {
                NSMutableDictionary * mulDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
                if (![httpUrl qim_hasPrefixHttpHeader]) {
                    httpUrl = [NSString stringWithFormat:@"%@/%@", [QIMNavConfigManager sharedInstance].innerFileHttpHost, httpUrl];
                }
                NSString * jDataStr = [[httpUrl dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                
                NSString *shareurl = [NSString stringWithFormat:@"%@?jdata=%@", [[QIMNavConfigManager sharedInstance] shareUrl], [jDataStr qim_URLEncodedString]];
                [mulDic setQIMSafeObject:shareurl forKey:@"linkurl"];
                NSString *msgExtendInfoStr = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
                //QIMSDKTODO
//                if (encryptState == QTEncryptChatStateEncrypting) {
//                    NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_CommonTrdInfo WithOriginBody:@"您收到了一个消息记录文件文件，请升级客户端查看。" WithOriginExtendInfo:msgExtendInfoStr WithUserId:self.message.to];
//                    self.message.message = @"加密消息记录消息iOS";
//                    self.message.extendInformation = encryptContent;
//                    self.message.messageType = QIMMessageType_Encrypt;
//                } else {
                    self.message.extendInformation = msgExtendInfoStr;
                    self.message.message = @"您收到了一个消息记录文件文件，请升级客户端查看。";
//                }

                if (self.message.chatType == ChatType_Consult || self.message.chatType == ChatType_ConsultServer) {
                    [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                } else {
                    [[QIMManager sharedInstance] sendMessage:self.message ToUserId:self.toJid];
                }
//                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFileDidUpload object:self.message];
                
            }else if (self.message.messageType == QIMMessageType_File) {
                NSMutableDictionary * mulDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
                [mulDic setQIMSafeObject:httpUrl forKey:@"HttpUrl"];
                NSString *msgContent = [[QIMJSONSerializer sharedInstance] serializeObject:mulDic];
                //QIMSDKTODO
//                if (encryptState == QTEncryptChatStateEncrypting) {
//                    NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:QIMMessageType_File WithOriginBody:msgContent WithOriginExtendInfo:msgContent WithUserId:self.message.to];
//                    self.message.message = @"加密消息记录消息iOS";
//                    self.message.extendInformation = encryptContent;
//                    self.message.messageType = QIMMessageType_Encrypt;
//                } else {
                    self.message.extendInformation = msgContent;
                    self.message.message = msgContent;//@"您收到了一个文件，请升级客户端查看。";
//                }

                if (self.message.messageType == ChatType_ConsultServer || self.message.messageType == ChatType_Consult) {
                    [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                } else {
                    [[QIMManager sharedInstance] sendMessage:self.message ToUserId:self.toJid];
                }
            } else {
                UIImage * image = [UIImage imageWithData:self.imageData];
                float maxWidth = kThumbMaxWidth;
                float maxHeight = kThumbMaxHeight;
                float width = image.size.width;
                float height = image.size.height;
                float scale = MIN(maxWidth/width, maxHeight/height);
                width = width * scale;
                height = height * scale;
                NSString * string = [NSString stringWithFormat:@"[obj type=\"%@\" value=\"%@\" width=%d height=%d ]", @"image",httpUrl,(int)image.size.width,(int)image.size.height];
                NSDictionary *extendInfoDic = @{@"height":@(height), @"width":@(width), @"pkgid":@"", @"url":httpUrl?httpUrl:@"", @"shortcut":@""};
                NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:extendInfoDic];
                if ([httpUrl length] > 0) {
                    self.message.message = string;
                    self.message.extendInformation = extendInfo;
                    NSString *tempHttpUrl = httpUrl;
                    if (![tempHttpUrl qim_hasPrefixHttpHeader]){
                        tempHttpUrl = [[QIMNavConfigManager sharedInstance].innerFileHttpHost stringByAppendingFormat:@"/%@", tempHttpUrl];
                    }
                        //QIMSDKTODO
//                        if (encryptState == QTEncryptChatStateEncrypting) {
//                            NSString *encryptContent = [[QTEncryptChat sharedInstance] encryptMessageWithMsgType:self.message.messageType WithOriginBody:string WithOriginExtendInfo:nil WithUserId:self.message.to];
//                            self.message.message = @"加密消息iOS";
//                            self.message.extendInformation = encryptContent;
//                            self.message.messageType = QIMMessageType_Encrypt;
//                        }
//                    self.message.messageSendState = MessageState_Success;
                    if (self.message.chatType == ChatType_PublicNumber) {
                        [[QIMManager sharedInstance] sendMessage:self.message.message ToPublicNumberId:self.toJid WithMsgId:self.message.messageId WithMsgType:self.message.messageType];
                    } else if (self.message.chatType == ChatType_Consult) {
                        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:self.message.ochatJson error:nil];
                        NSMutableDictionary * ochatDic = [NSMutableDictionary dictionaryWithDictionary:infoDic];
                        NSMutableDictionary * cctntDic = [NSMutableDictionary dictionaryWithCapacity:1];
                        [cctntDic setObject:@((int)image.size.width / 5) forKey:@"ow"];
                        [cctntDic setObject:@((int)image.size.height / 5) forKey:@"oh"];
                        [cctntDic setObject:tempHttpUrl forKey:@"url"];
                        NSString * cctntJsonStr = [[QIMJSONSerializer sharedInstance] serializeObject:cctntDic];
                        [ochatDic setObject:cctntJsonStr?cctntJsonStr:@"" forKey:@"ctnt"];
                        [ochatDic setObject:cctntJsonStr?cctntJsonStr:@"" forKey:@"cctnt"];
                        [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                    } else if (self.message.chatType == ChatType_ConsultServer) {
                         [[QIMManager sharedInstance] sendConsultMessageId:self.message.messageId WithMessage:self.message.message WithInfo:self.message.extendInformation toJid:self.message.to realToJid:self.message.realJid WithChatType:self.message.chatType WithMsgType:self.message.messageType];
                    } else {
                        [[QIMManager sharedInstance] sendMessage:self.message ToUserId:self.toJid];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:[NSDictionary dictionaryWithObjectsAndKeys:self.message,@"message",@"1.1",@"propress",@"uploading",@"status", nil]];
                }
            }
        }
        [[QIMFileManager sharedInstance] removeFileId:self.fileId];
        return;
        
    } else if (self.fileReuqestType == FileRequest_Download) {
        NSError *error = [request error];
        QIMFileCacheType fileCacheType = self.fileCacheType;
        NSString *url = request.url.absoluteString;
        if (!error && [request responseStatusCode] == 200) {
            NSData *responseData = [request responseData].length > 0 ? [request responseData] : _receiveData ;
            if ([responseData length] > 0) {
                
                NSString * fileName = [[QIMFileManager sharedInstance] saveFileData:responseData url:self.message.messageId forCacheType:fileCacheType];
                [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFinishedNotificationName object:nil userInfo:@{@"url":url ? url:@"",@"md5":fileName ? fileName:@"",@"type":@(fileCacheType)}];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFailedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":@"",@"type":@(fileCacheType)}];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFailedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":@"",@"type":@(fileCacheType)}];
            });
        }
        /*
        if ([request responseStatusCode] == 200) {
            NSData * data = nil;
            if ([request isResponseCompressed] && [request shouldWaitToInflateCompressedResponses]) {
                data = [ASIDataDecompressor uncompressData:_receiveData error:NULL];
            } else {
                data = _receiveData;
            }
//            [[QIMDataController getInstance] saveResourceWithFileName:self.fileUrl data:[_fileHandle readDataToEndOfFile]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:[NSDictionary dictionaryWithObjectsAndKeys:self.message,@"message",@"1.1",@"propress",@"success",@"status", nil]];
            
        } */
    }
    if (fileId) {
        [[QIMFileManager sharedInstance] removeFileId:fileId];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    
    if (self.fileReuqestType == FileRequest_Upload) {
        self.message.messageSendState = QIMMessageSendState_Faild;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:[NSDictionary dictionaryWithObjectsAndKeys:self.message,@"message",@"1.1",@"propress", @"failed",@"status",nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kXmppStreamSendMessageFailed" object:@{@"messageId":self.message.messageId}];
    } else if (self.fileReuqestType == FileRequest_Download) {
    }
    if (self.fileId) {
        [[QIMFileManager sharedInstance] removeFileId:self.fileId];
    }
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = (asize.width - rect.size.width)/2;
            
            rect.origin.y = 0;
            
        }
        
        else{
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark - asi http request progress delegate

-(void)setProgress:(float)newProgress
{
    NSMutableDictionary *object = [NSMutableDictionary dictionaryWithCapacity:2];
    if (self.message) {
        [object setObject:self.message forKey:@"message"];
    }
    [object setObject:@(newProgress) forKey:@"propress"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFileManagerUpdate object:object userInfo:nil];
    });
}

- (void)setMaxValue:(double)newMax{
    _maxValue = newMax;
}

// Called when the request receives some data - bytes is the length of that data
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    _currentOffset = bytes;
}

// Called when the request sends some data
// The first 32KB (128KB on older platforms) of data sent is not included in this amount because of limitations with the CFNetwork API
// bytes may be less than zero if a request needs to remove upload progress (probably because the request needs to run again)
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
    _currentOffset = bytes;
}

// Called when a request needs to change the length of the content to download
- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength{
    _requestLength += newLength;
}

// Called when a request needs to change the length of the content to upload
// newLength may be less than zero when a request needs to remove the size of the internal buffer from progress tracking
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength{
    _requestLength += newLength;
}

@end

@interface QIMFileManager () <ASIProgressDelegate>

@property (nonatomic, strong) NSMutableDictionary *file_dic;

@end

@implementation QIMFileManager {
    NSMutableArray *_fileDicQueue;
    dispatch_queue_t _file_queue;
}

+ (QIMFileManager *)sharedInstance {
    
    static QIMFileManager *monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monitor = [[QIMFileManager alloc] init];
    });
    return monitor;
}
+ (NSString *) urlpathExtension:(NSString *) url {
    return [[NSURL URLWithString:url] pathExtension];
}

+ (NSString *) documentsofPath:(QIMFileCacheType) type {
    
    NSString * resourceDir = kResourceCachePath;
    if (type == QIMFileCacheTypeColoction) {
        resourceDir = kCollectionCacheKey;
    }
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:resourceDir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return cachePath;
}

- (NSMutableDictionary *)file_dic {
    if (!_file_dic) {
        _file_dic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return _file_dic;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _file_queue = dispatch_queue_create("File Queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        _fileDicQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)checkUploadFile{
    NSString *nextFileId = [_fileDicQueue firstObject];
    if (nextFileId) {
        QIMFileRequest *nextRequest = [self.file_dic objectForKey:nextFileId];
        [nextRequest.fileRequest startAsynchronous];
    }
}

/**
 *  根据文件名称删除文件
 *
 *  @param fileId 文件id
 */
- (void)removeFileId:(NSString *)fileId{
    if (fileId == nil) {
        return;
    }
    QIMFileRequest *request = [self.file_dic objectForKey:fileId];
    [request.fileRequest setDelegate:nil];
    [request.fileRequest setUploadProgressDelegate:nil];
    [request.fileRequest setDownloadProgressDelegate:nil];
    [self.file_dic removeObjectForKey:fileId];
    [_fileDicQueue removeObject:fileId];
    [self performSelector:@selector(checkUploadFile) withObject:nil afterDelay:1];
}

- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData * data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        if (data) {
            return [self uploadFileForData:data forMessage:message withJid:jid isFile:flag];
        }
    }
    return nil;
}

/**
 *
 *
 *  @param fileData
 *  @param message
 *  @param jid
 *  @param flag     flag 1 为文件， 0为图片
 *
 *  @return
 */
- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    
    if (fileData == nil) {
        return nil;
    }
    
    
    NSString * fileKey = [self getMD5FromFileData:fileData];
    NSString * fileExt = flag?nil:[self getImageFileExt:fileData];
    NSDictionary *msgInfoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
    if ([msgInfoDic[@"FileName"] length]) {
        fileExt = [msgInfoDic[@"FileName"] pathExtension];
    }
    BOOL isGif = NO;
    if ([fileExt.uppercaseString isEqualToString:@"GIF"]) {
        isGif = YES;
    }
    
    BOOL isVideo = (message.messageType == QIMMessageType_SmallVideo);
    BOOL videoConfigUseAble = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"VideoConfigUseAble"] boolValue];
    __block NSString * fileName = fileExt.length ? [fileKey stringByAppendingPathExtension:fileExt] : fileKey;
    if (isVideo && videoConfigUseAble) {
        
        //限制视频时长
        NSInteger videoTimeLen = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"videoTimeLen"] integerValue] / 1000;
        NSDictionary *videoExt = [[QIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
        NSInteger videoDuration = [[videoExt objectForKey:@"Duration"] integerValue];

        
        NSString *destUrl = [NSString stringWithFormat:@"%@/video/upload", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
        NSLog(@"上传视频destUrl : %@", destUrl);
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
       
        ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
        [formRequest setRequestMethod:@"POST"];
        
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
        [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
        [formRequest setRequestHeaders:cookieProperties];
        [formRequest setTimeOutSeconds:600];
        [formRequest setUseCookiePersistence:NO];

        QIMFileRequest *fileRequest = [[QIMFileRequest alloc] init];
        [fileRequest setFileRequest:formRequest];
        [fileRequest setNewVideoInterface:YES];
        [fileRequest setFileReuqestType:FileRequest_Upload];
        [fileRequest setImageData:fileData];
        [fileRequest setMessage:message];
        [fileRequest appendToJid:jid];
        [formRequest setDelegate:fileRequest];
        formRequest.showAccurateProgress = YES;
        [formRequest setUploadProgressDelegate:fileRequest];
        
        NSString *needTrans = @"true";
        if (videoDuration < videoTimeLen) {
            //小于限制时长，需要转码
            needTrans = @"true";
            [fileRequest setTransVideo:YES];
        } else {
            //大于限制时长，不需要转码
            needTrans = @"false";
            [fileRequest setTransVideo:NO];
        }
        [formRequest addPostValue:needTrans forKey:@"needTrans"];
        [formRequest addData:fileData withFileName:fileName andContentType:@"multipart/form-data" forKey:@"file"];
        [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
        [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
        [formRequest startAsynchronous];
        [self.file_dic setObject:fileRequest forKey:message.messageId];
    
        return fileName;
    } else {
        
    }
    
    CGSize size = [self getFitSizeForImgSize:[UIImage imageWithData:fileData].size];
    //存小图
    [self saveImageData:fileData withFileName:fileName width:size.width height:size.height forCacheType:QIMFileCacheTypeColoction];
    [[QIMHttpRequestMonitor sharedInstance] syncRunBlock:^{
        //存原图
        [self saveFileData:fileData withFileName:fileName forCacheType:QIMFileCacheTypeColoction];
        long long fileLength = fileData.length;
        NSString *method = [NSString  stringWithFormat:@"file/v2/inspection/%@",flag?@"file":@"img"];
        NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&p=iphone&u=%@&k=%@&version=%@",
                             [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileKey, fileLength, fileName,
                             [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             [[QIMManager sharedInstance] myRemotelogginKey],
                             [[QIMAppInfo sharedInstance] AppBuildVersion]];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        QIMFileRequest *fileRequest = [[QIMFileRequest alloc] init];
        [fileRequest setFileRequest:request];
        [fileRequest setFileReuqestType:FileRequest_Upload];
        [fileRequest setMessage:message];
        [fileRequest appendToJid:jid];
        [request startSynchronous];
        QIMVerboseLog(@"上传文件 : %@ ForMessage: %@", destUrl, message);
        if ([request responseStatusCode] == 200) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
            QIMVerboseLog(@"上传文件结果 : %@ ForMessage: %@", result, message);
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (!ret) {
                NSString *resultUrl = [result objectForKey:@"data"];
                if (resultUrl) {
                    fileName = resultUrl;
                }
                if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:result];
                        [resultDic setObject:@(YES) forKey:@"ret"];
                        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:resultDic error:nil];
                        [fileRequest setReceiveData:[NSMutableData dataWithData:data]];
                        [request setShouldWaitToInflateCompressedResponses:NO];
                        fileRequest.imageData = fileData;
                        [fileRequest requestFinished:request];
                    });
                    return;
                }
            }
        }
        [self uploadFileForData:fileData fileKey:fileKey fileExt:fileExt forMessage:message withJid:jid isFile:flag];
    } url:fileKey];
    return fileName;
}

- (void)uploadFileForData:(NSData *)fileData fileKey:(NSString *)fileKey fileExt:(NSString *)fileExt forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    NSString *method = [NSString  stringWithFormat:@"file/v2/upload/%@",flag?@"file":@"img"];
    NSString *fileName = fileKey;
    if (fileExt.length > 0) {
        fileName = [fileName stringByAppendingPathExtension:fileExt];
    }
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=iphone&u=%@&k=%@&v=%@&key=%@&size=%lld",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    QIMVerboseLog(@"上传真正的文件 : %@ ForMessage: %@", destUrl, message);

    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    ASIFormDataRequest *formRequest = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
    
    QIMFileRequest *fileRequest = [[QIMFileRequest alloc] init];
    [fileRequest setFileRequest:formRequest];
    [fileRequest setFileReuqestType:FileRequest_Upload];
    [fileRequest setImageData:fileData];
    [fileRequest setMessage:message];
    [fileRequest appendToJid:jid];
    [formRequest setDelegate:fileRequest];
    formRequest.showAccurateProgress = YES;
    [formRequest setUploadProgressDelegate:fileRequest];
    [formRequest addData:fileData withFileName:fileName andContentType:nil forKey:@"file"];
    [formRequest setResponseEncoding:NSISOLatin1StringEncoding];
    [formRequest setPostFormat:ASIMultipartFormDataPostFormat];
    [formRequest startAsynchronous];
    [self.file_dic setObject:fileRequest forKey:message.messageId];
}

- (NSString *)checkForFileData:(NSData *)fileData fileKey:(NSString *)fileKey fileName:(NSString *)fileName isFile:(BOOL)flag {
    long long fileLength = fileData.length;
    NSString *method = [NSString  stringWithFormat:@"file/v2/inspection/%@",flag?@"file":@"img"];
    NSString *destUrl = [NSString stringWithFormat:@"%@/%@?key=%@&size=%lld&name=%@&p=iphone&u=%@&k=%@&version=%@",
                         [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileKey, fileLength, fileName,
                         [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [[QIMManager sharedInstance] myRemotelogginKey],
                         [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestUrl];
    [request setRequestMethod:@"POST"];
    [request setData:fileData withFileName:fileName andContentType:nil forKey:fileKey];
    [request buildRequestHeaders];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (!ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            if ([resultUrl isEqual:[NSNull null]] == NO && resultUrl) {
                return resultUrl;
            }
        }
    }
    return nil;
}

- (NSString *)uploadSynchronousForFileData:(NSData *)fileData fileKey:(NSString *)fileKey fileName:(NSString *)fileName isFile:(BOOL)flag {
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString * method = [NSString  stringWithFormat:@"file/v2/upload/%@",flag?@"file":@"img"];
    NSString * destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=iphone&u=%@&k=%@&v=%@&key=%@&size=%lld",
                          [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                          [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [[QIMManager sharedInstance] myRemotelogginKey],
                          [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    NSURL * requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestUrl];
    [request setRequestMethod:@"POST"];
    [request setData:fileData withFileName:fileName andContentType:nil forKey:fileKey];
    [request buildRequestHeaders];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSString *resultUrl = [result objectForKey:@"data"];
            return resultUrl;
        }
    }
    return nil;
}

- (void)uploadAsynchronousForFileData:(NSData *)fileData fileKey:(NSString *)fileKey fileName:(NSString *)fileName progressDelegate:(id)delegate isFile:(BOOL)flag completeblock:(void(^)(NSString * resultUrl))completeblock progressBlock:(void(^)(CGFloat progress))progressBlock{
    long long size = ceil(fileData.length / 1024.0 / 1024.0);
    NSString * method = [NSString  stringWithFormat:@"file/v2/upload/%@",flag?@"file":@"img"];
    NSString * destUrl = [NSString stringWithFormat:@"%@/%@?name=%@&p=iphone&u=%@&k=%@&v=%@&key=%@&size=%lld",
                          [QIMNavConfigManager sharedInstance].innerFileHttpHost, method, fileName,
                          [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [[QIMManager sharedInstance] myRemotelogginKey],
                          [[QIMAppInfo sharedInstance] AppBuildVersion],fileKey,size];
    NSURL * requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestUrl];
    [request setRequestMethod:@"POST"];
    request.showAccurateProgress = YES;
    [request setData:fileData withFileName:fileName andContentType:nil forKey:fileKey];
    [request buildRequestHeaders];
    [request startAsynchronous];
    if (delegate) {
        [request setUploadProgressDelegate:delegate];
    }
    __weak typeof (request) weakRequest = request;
    [request setCompletionBlock:^{
        if ([weakRequest responseStatusCode] == 200) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:weakRequest.responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSString *resultUrl = [result objectForKey:@"data"];
                if (completeblock) {
                    completeblock(resultUrl);
                }
            }
        }
    }];
    
    __block float newProgress;
    
    __block float totalSize = 0;
    
    __block float theSize = 0;
    
    
    [request setUploadSizeIncrementedBlock:^(long long size) {
        totalSize = totalSize + size;
    }];
    [request setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
        theSize += size;
        newProgress = theSize/totalSize;
        if (progressBlock) {
            progressBlock(newProgress);
        }
    }];
}
- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock {
    [self uploadFileForData:fileData forCacheType:type isFile:flag fileExt:flag?nil:[self getImageFileExt:fileData] completionBlock:completionBlock];
}

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock {
    
    dispatch_async(_file_queue, ^{
        NSString * fileKey = [self getMD5FromFileData:fileData];
        NSString *fileName = fileExt ? [fileKey stringByAppendingFormat:@".%@", fileExt] : fileKey;
        NSString * resultUrl = [self checkForFileData:fileData fileKey:fileKey fileName:fileName isFile:flag];
        if (resultUrl) {
            [[QIMFileManager sharedInstance] saveFileData:fileData url:resultUrl forCacheType:QIMFileCacheTypeColoction];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([UIImage imageWithData:fileData],nil,type,resultUrl);
            });
        }else{
            resultUrl = [self uploadSynchronousForFileData:fileData fileKey:fileKey fileName:fileName isFile:flag];
            //
            // 保存图片
            [[QIMFileManager sharedInstance] saveFileData:fileData url:resultUrl forCacheType:QIMFileCacheTypeColoction];
            
            completionBlock([UIImage imageWithData:fileData],nil,type,resultUrl);
        }
    });
}

- (void)uploadFileForData:(NSData *)fileData
             forCacheType:(QIMFileCacheType)type
                  fileExt:(NSString *)fileExt
                   isFile:(BOOL)flag
   uploadProgressDelegate:(id)delegate
          completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock
            progressBlock:(void (^)(CGFloat))progressBlock{
    dispatch_async(_file_queue, ^{
        NSString * fileKey = [self getMD5FromFileData:fileData];
        NSString *fileName = fileExt ? [fileKey stringByAppendingFormat:@".%@", fileExt] : fileKey;
        NSString * resultUrl = [self checkForFileData:fileData fileKey:fileKey fileName:fileName isFile:flag];
        if (resultUrl) {
//            [[QIMFileManager sharedInstance] saveFileData:fileData url:resultUrl forCacheType:QIMFileCacheTypeColoction];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock([UIImage imageWithData:fileData],nil,type,resultUrl);
            });
        }else{
            [self uploadAsynchronousForFileData:fileData fileKey:fileKey fileName:fileName progressDelegate:delegate isFile:YES completeblock:^(NSString *resultUrl) {
                completionBlock([UIImage imageWithData:fileData],nil,type,resultUrl);
            } progressBlock:progressBlock];
        }
    });
}

-(void)downloadCollectionEmoji:(NSString *)url
                         width:(CGFloat) width
                        height:(CGFloat) height
                  forCacheType:(QIMFileCacheType)type
                    complation:(void(^)(NSData *)) complation {
    if ([url containsString:@"null"] || !url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *urlStr = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5 = [self getFileNameFromUrl:url width:width height:height];
    if (height > 0.0 && width > 0.0) {
        
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            
            urlStr = [url stringByAppendingFormat:@"&u=%@&k=%@&w=%d&h=%d",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey],
                      (int)width,
                      (int)height];
        } else {
            urlStr = [url stringByAppendingFormat:@"?u=%@&k=%@&w=%d&h=%d",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey],
                      (int)width,
                      (int)height];
        }
    } else {
        
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            urlStr = [url stringByAppendingFormat:@"&u=%@&k=%@",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey]];
        } else {
            urlStr = [url stringByAppendingFormat:@"?u=%@&k=%@",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey]];
        }
    }
    [[QIMHttpRequestMonitor sharedInstance] runblock:^{
        
        NSString *filePath = [[QIMFileManager documentsofPath:type] stringByAppendingPathComponent:md5];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (!complation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFinishedNotificationName object:nil userInfo:@{@"url":urlStr ? urlStr:@"",@"md5":md5 ? md5:@"",@"type":@(type)}];
                });
            } else {
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                complation(data);
            }
        } else {
            NSURL *requestUrl = [[NSURL alloc] initWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
            [request startSynchronous];
            NSError *error = [request error];
            
            if (!error && [request responseStatusCode] == 200) {
                NSData *responseData = [request responseData];
                if ([responseData length] > 0) {
                    
                    NSString * fileName = [self saveFileData:responseData url:request.url.absoluteString forCacheType:type];
                    if (!complation) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFinishedNotificationName object:nil userInfo:@{@"url":url ? url:@"",@"md5":fileName ? fileName:@"",@"type":@(type)}];
                        });
                    } else {
                        complation(responseData);
                    }
                }else{
                    if (!complation) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFailedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":@"",@"type":@(type)}];
                        });
                        
                    } else {
                        complation(nil);
                    }
                }
            } else {
                if (!complation) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFailedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":@"",@"type":@(type)}];
                    });
                } else {
                    complation(nil);
                }
            }
        }
    } url:urlStr];
}

-(void)downloadImage:(NSString *)url
               width:(CGFloat) width
              height:(CGFloat) height
        forCacheType:(QIMFileCacheType)type
          complation:(void(^)(NSData *)) complation {
    if ([url containsString:@"null"] || !url) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *urlStr = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *md5 = [self getFileNameFromUrl:url width:width height:height];
    if (height > 0.0 && width > 0.0) {
        
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            
            urlStr = [url stringByAppendingFormat:@"&u=%@&k=%@&w=%d&h=%d",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey],
                      (int)width,
                      (int)height];
        } else {
            urlStr = [url stringByAppendingFormat:@"?u=%@&k=%@&w=%d&h=%d",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey],
                      (int)width,
                      (int)height];
        }
    } else {
        
        if ([url rangeOfString:@"?"].location != NSNotFound) {
            urlStr = [url stringByAppendingFormat:@"&u=%@&k=%@",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey]];
        } else {
            urlStr = [url stringByAppendingFormat:@"?u=%@&k=%@",
                      [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[QIMManager sharedInstance] myRemotelogginKey]];
        }
    }
    [[QIMHttpRequestMonitor sharedInstance] runblock:^{

        NSString *filePath = [[QIMFileManager documentsofPath:type] stringByAppendingPathComponent:md5];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (!complation) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFinishedNotificationName object:nil userInfo:@{@"url":urlStr ? urlStr:@"",@"md5":md5 ? md5:@"",@"type":@(type)}];
                });
            } else {
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                complation(data);
            }
        } else {
            NSURL *requestUrl = [[NSURL alloc] initWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
           QIMMessageModel *msg = [QIMMessageModel new];
            msg.messageId = [weakSelf getFileNameFromUrl:url width:width height:height];
            QIMFileRequest *fileRequest = [weakSelf.file_dic objectForKey:msg.messageId];
            if (!fileRequest) {
                fileRequest = [[QIMFileRequest alloc] init];
                [fileRequest setFileReuqestType:FileRequest_Download];
                [fileRequest setFileCacheType:type];
                [fileRequest setMessage:msg];
                [weakSelf.file_dic setObject:fileRequest forKey:msg.messageId];
            }
            ASIHTTPRequest *formRequest = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
            [formRequest setDelegate:fileRequest];
            formRequest.showAccurateProgress = YES;
            [formRequest setDownloadProgressDelegate:fileRequest];
            [formRequest startAsynchronous];
        }
    } url:urlStr];
}

-(void)downloadImage:(NSString *)url width:(CGFloat) width height:(CGFloat) height forCacheType:(QIMFileCacheType)type {
    
    [self downloadImage:url width:width height:height forCacheType:type complation:nil];
}

/**
 *  根据URL下载文件
 *
 *  @param url  文件URL
 *  @param flag
 */

-(void)downloadFileWithUrl:(NSString *)url isFile:(BOOL)flag forCacheType:(QIMFileCacheType)type {

    NSString *urlStr = [url stringByAppendingFormat:@"&u=%@&k=%@",
                     [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                     [[QIMManager sharedInstance] myRemotelogginKey]];
    __weak typeof(self) weakSelf = self;

    [[QIMHttpRequestMonitor sharedInstance] runblock:^{

        NSURL *requestUrl = [[NSURL alloc] initWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request startAsynchronous];
        NSError *error = [request error];
        if (!error && [request responseStatusCode] == 200) {
            NSData *responseData = [request responseData];
            if (responseData != nil) {

                NSString *fileName = nil;
                if (flag == NO) {
                    float width = 0;
                    float height = 0;
                    NSURL *tempUrl = [NSURL URLWithString:urlStr];
                    NSString *query = [tempUrl query];
                    if (query) {
                        NSArray *parameters = [query componentsSeparatedByString:@"&"];
                        for (NSString *item in parameters) {
                            NSArray *value = [item componentsSeparatedByString:@"="];
                            if ([value count] == 2) {
                                NSString *key = [value objectAtIndex:0];
                                if ([key isEqualToString:@"w"]) {
                                    width = [[value objectAtIndex:1] floatValue];
                                }else if ([key isEqualToString:@"h"]) {
                                    height = [[value objectAtIndex:1] floatValue];
                                }
                            }
                        }
                    }
                    fileName = [weakSelf saveImageData:responseData withFileName:[weakSelf getFileNameFromUrl:urlStr] width:width height:height forCacheType:type];
                }else{
                    fileName = [weakSelf saveFileData:responseData withFileName:[weakSelf getFileNameFromUrl:urlStr] forCacheType:type];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFinishedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":fileName?fileName:@"",@"type":@(type)}];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFailedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":@"",@"type":@(type)}];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KDownloadFileFailedNotificationName object:nil userInfo:@{@"url":url?url:@"",@"md5":@"",@"type":@(type)}];
            });
        }
    } url:urlStr];
}

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height {
    NSUInteger intWidth = (NSUInteger)(width + 0.5);
    NSUInteger intHeight = (NSUInteger)(height + 0.5);
    NSString * newMd5 = oldMd5;
    if (intWidth && intHeight) {
        newMd5 = [[NSString stringWithFormat:@"%@_w%@_h%@", oldMd5, @(intWidth), @(intHeight)] qim_getMD5];
    }
    return newMd5;
}

/**
 *  根据MD5获取Data
 *
 *  @param md5  md5
 *  @param type 图片来源类型
 */
- (NSData *) getFileDataForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type {
    if (![fileName qim_isStringSafe])
    {
        return nil;
    }
    NSData *data = [self getResourceWithFileName:fileName forCacheType:type];
    if ([data isEqualToData:[NSData dataWithBytes:"\0" length:2]])
    {
        data = nil;
    }
    
    return data;
}

/**
 *  根据文件Url获取文件data
 *
 *  @param url  文件URL
 *  @param type 文件来源路径
 */
- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type {
    CGSize size = [self getImageSizeFromUrl:url];
    return [self getFileDataFromUrl:url width:size.width height:size.height forCacheType:type];
}

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type needUpdate:(BOOL)update {
    CGSize size = [self getImageSizeFromUrl:url];
    return [self getFileDataFromUrl:url width:size.width height:size.height forCacheType:type needUpdate:update];
}

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type {
    return [self getFileDataFromUrl:url width:width height:height forCacheType:type needUpdate:YES];
}

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type needUpdate:(BOOL)needUpdate {
    NSString * fileName = [self getFileNameFromUrl:url width:width height:height];
    //1.根据fileName取本地image
    __block NSData *data = [self getFileDataForFileName:fileName forCacheType:type];
    __weak typeof(self) weakSelf = self;
    if (!data.length && needUpdate) {
        //2.下载image
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [weakSelf downloadImage:url width:width height:height forCacheType:type complation:^(NSData *imageData) {
                data = imageData;
            }];
        });
    }
    //3.返回imageData
    return data;
}


/**
 *  根据文件名获取文件data
 *
 *  @param fileName 文件名
 *  @param type     文件来源类型
 */
- (NSData *)getResourceWithFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type
{
    NSData *data = nil;
    if (nil == fileName || [fileName length] == 0)
    {
        return nil;
    }
    
    // cache文件夹
    
    NSString * resourceDir = kResourceCachePath;
    if (type == QIMFileCacheTypeColoction) {
        resourceDir = kCollectionCacheKey;
    }
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:resourceDir];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
    {
        data = [[NSFileManager defaultManager] contentsAtPath:resourcePath];
    }
    return data;
}

- (BOOL)isFileExistForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type {
    NSString *localFilePath = [self fileExistLocalPathForUrl:url width:width height:height forCacheType:type];
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
}

- (NSString *)fileExistLocalPathForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type {
    NSString * fileName = [self getFileNameFromUrl:url width:width height:height];
    NSString *filePath = [[QIMFileManager documentsofPath:type] stringByAppendingPathComponent:fileName];
    return filePath;
}

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type careExist:(BOOL) careExist {
    // cache文件夹
    NSString * resourceDir = kResourceCachePath;
    if (type == QIMFileCacheTypeColoction) {
        resourceDir = kCollectionCacheKey;
    }
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:resourceDir];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    if (!careExist || [[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
    {
        return resourcePath;
    }
    return nil;
}

/**
 *  根据文件名获取文件路径
 *
 *  @param fileName 文件名
 *  @param type     文件来源类型
 */
- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type {
    return [self getFilePathForFileName:fileName forCacheType:type careExist:YES];
}

/**
 *  保存文件并获取文件名
 *
 *  @param data     文件data
 *  @param fileName 文件名
 *  @param type     文件类型
 *
 *  @return 文件名
 */

- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type{
    return [self saveFileData:data withFileName:fileName forCacheType:type update:NO];
}


- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(QIMFileCacheType)type {
    CGSize size = [self getImageSizeFromUrl:httpUrl];
    return [self saveFileData:data url:httpUrl width:size.width height:size.height forCacheType:type];
}

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(QIMFileCacheType)type {
    
    NSString *md5 = [self getFileNameFromUrl:httpUrl width:width height:height];
    
    return [self saveFileData:data withFileName:md5 forCacheType:type];
}

- (NSString *) saveImageData:(NSData *)data withFileName:(NSString *)fileName width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type{
    
    //注意 fileName 中的md5 必须是没有加入宽高的，否则直接
    NSString * oldMd5 = [fileName stringByDeletingPathExtension];
    NSString * ext = [fileName pathExtension];
    NSString *newFileName = fileName;
    if ([[ext lowercaseString] isEqualToString:@"gif"]) {
        newFileName = fileName;
    }else{
        NSString *newMd5 = [self getNewMd5ForMd5:oldMd5 withWidth:width height:height];
        newFileName = ext.length ? [newMd5 stringByAppendingPathExtension:ext] :newMd5;
    }
    return [self saveFileData:data withFileName:newFileName forCacheType:type update:NO];
}

/**
 *  保存文件
 *
 *  @param data     文件data
 *  @param fileName 文件名称
 *  @param type     文件来源类型
 */
- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type update:(BOOL) update{
    if (fileName == nil) {
        fileName = [self getMD5FromFileData:data];
    }
    
    NSString *cachePath = [QIMFileManager documentsofPath:type];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    if (update || ![[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
        [data writeToFile:resourcePath atomically:YES];
    }
    return fileName;
}

- (NSString *) getFileExtFromUrl:(NSString *) url {
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

- (NSString *) md5fromUrl:(NSString *) url {
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
        /*
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
                        tempKey = [[[value objectAtIndex:1] componentsSeparatedByString:@"/"].lastObject componentsSeparatedByString:@"."].firstObject;
                        return tempKey;
                    }
                }
            }
        }
        NSString * urlStr = [tempUrl.absoluteString componentsSeparatedByString:@"?"].firstObject;
        if ([urlStr rangeOfString:@"?"].location == NSNotFound) {
            NSArray *pathComponents = [urlStr pathComponents];
            tempKey = [pathComponents.lastObject componentsSeparatedByString:@"."].firstObject;
            return (tempKey.length  == 32) ? tempKey:nil;
        } */
    }
    
    return nil;
}

- (CGSize)getImageSizeFromUrl:(NSString *)url {
    float width = 0;
    float height = 0;
    NSURL *tempUrl = [NSURL URLWithString:url];
    NSString *query = [tempUrl query];
    if (query) {
        NSArray *parameters = [query componentsSeparatedByString:@"&"];
        for (NSString *item in parameters) {
            NSArray *value = [item componentsSeparatedByString:@"="];
            if ([value count] == 2) {
                NSString *key = [value objectAtIndex:0];
                if ([key isEqualToString:@"w"]) {
                    width = [[value objectAtIndex:1] floatValue];
                }else if ([key isEqualToString:@"h"]) {
                    height = [[value objectAtIndex:1] floatValue];
                }
            }
        }
    }
    return CGSizeMake(width, height);
}

/**
 *  根据URL获得文件名
 *
 *  @param url URL
 */

- (NSString *) getFileNameFromKey:(NSString *)url {
    CGSize size = [self getImageSizeFromUrl:url];
    return [self getFileNameFromUrl:url width:size.width height:size.height];
}

- (NSString *)getFileNameFromUrl:(NSString *)key {
    return [self getFileNameFromKey:key];
}

/**
 *  根据URL获得文件名
 *
 *  @param url URL
 */
- (NSString *) getFileNameFromUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height {
    NSString * oldMd5 = [self md5fromUrl:url];
    NSString * newMd5 = [self getNewMd5ForMd5:oldMd5 withWidth:width height:height];
    NSString * fileExt = [self getFileExtFromUrl:url];
    NSString * fileName = newMd5;
    if (fileExt.length) {
        if ([[fileExt lowercaseString] isEqualToString:@"gif"]) {
            fileName = [oldMd5 stringByAppendingPathExtension:fileExt];
        }else{
            fileName = [newMd5 stringByAppendingPathExtension:fileExt];
        }
    }
    return fileName;
}

/**
 *  根据文件data获取md5
 *
 *  @param fileData 文件data
 */
- (NSString *)getMD5FromFileData:(NSData *)fileData{
    return (__bridge_transfer NSString *)QIMFileMD5HashCreateWithData([fileData bytes], fileData.length);
}

/**
 *  根据文件data获取文件格式
 *
 *  @param data 文件data
 */
- (NSString *)getImageFileExt:(NSData *)data{
    const uint8_t *p = [data bytes];
    if ([data length] > 8) {
        if (p[0] == 0xff && p[1] == 0xd8) {
            
            /* JPEG */
            
            return @"jpg";
            
        } else if (p[0] == 'G' && p[1] == 'I' && p[2] == 'F' && p[3] == '8'
                   && p[5] == 'a')
        {
            if (p[4] == '9' || p[4] == '7') {
                /* GIF */
                return @"gif";
            }
            
        } else if (p[0] == 0x89 && p[1] == 'P' && p[2] == 'N' && p[3] == 'G'
                   && p[4] == 0x0d && p[5] == 0x0a && p[6] == 0x1a && p[7] == 0x0a)
        {
            /* PNG */
            
            return @"png";
        }
    }
    return nil;
}

- (BOOL) isImageOrGifWithData:(NSData *)data {
    
    BOOL isImage = NO;
    NSString *imageFileExt = [self getImageFileExt:data];
    if ([imageFileExt isEqualToString:@"gif"] || [imageFileExt isEqualToString:@"png"] || [imageFileExt isEqualToString:@"jpg"]) {
        
        isImage = YES;
    }
    return isImage;
}

/**
 *  临时文件URL调明星接口换取持久化URL
 *
 *  @param tempUrl 临时URL
 */

- (void )getPermUrlWithTempUrl:(NSString *)tempUrl PermHttpUrl:(void(^)(NSString *))callBackPermUrl{
    /*
    __block NSString *httpPermUrl = @"";
    [[QIMHttpRequestMonitor sharedInstance] syncRunBlock:^{
        
        NSString *compnentString = [tempUrl componentsSeparatedByString:@"?"].firstObject;
        NSString *PerString = [NSString stringWithFormat:@"%@/file/v2/stp?url=%@",
                               [[QIMNavConfigManager sharedInstance] innerFileHttpHost],
                               compnentString];
        NSURL *requestUrl = [[NSURL alloc] initWithString:[PerString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            NSError *error = nil;
            NSDictionary *dict = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:&error];
            httpPermUrl = [NSString stringWithFormat:@"%@", dict[@"data"]];
        }
        
    } url:tempUrl];
    NSString *md5 = [[QIMFileManager sharedInstance] getFileNameFromUrl:httpPermUrl];
    httpPermUrl = [NSString stringWithFormat:@"%@?filename=%@&md5=%@", httpPermUrl, md5, md5];
    */
    callBackPermUrl(tempUrl);
}

- (CGSize)getFitSizeForImgSize:(CGSize)imgSize {
    CGSize fitSize = imgSize;
    if (imgSize.width > kThumbMaxWidth || imgSize.height > kThumbMaxHeight) {
        float scale = MIN(kThumbMaxWidth/imgSize.width, kThumbMaxHeight/imgSize.height);
        fitSize.width = imgSize.width * scale;
        fitSize.height = imgSize.height * scale;
    }
    return fitSize;
}

- (NSString *)qim_cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}

@end
