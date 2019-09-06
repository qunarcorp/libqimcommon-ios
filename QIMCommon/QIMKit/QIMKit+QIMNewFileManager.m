//
//  QIMKit+QIMNewFileManager.m
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMKit+QIMNewFileManager.h"
#import "QIMPrivateHeader.h"
#import "QIMNewFileManager.h"

@implementation QIMKit (QIMNewFileManager)

- (NSString *)qim_saveImageData:(NSData *)imageData {
    return [[QIMNewFileManager sharedInstance] qim_saveImageData:imageData];
}

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] qim_uploadVideo:videoPath videoDic:videoExt withCallBack:callback];
}

- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] qim_uploadImageWithImageKey:localImageKey forMessage:message];
}

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] qim_uploadImage:localImagePath forMessage:message];
}

- (void)qim_uploadImage:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] qim_uploadImage:localImagePath withCallback:callback];
}

- (void)qim_uploadImageWithImageData:(NSData *)imageData withCallback:(QIMKitUploadImageNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] qim_uploadImageWithImageData:imageData withCallback:callback];
}

#pragma mark - sync Check
- (NSString *)qim_syncCheckFileKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension {
    return [[QIMNewFileManager sharedInstance] qim_syncCheckFileKey:fileKey WithFileLength:fileLength WithPathExtension:extension];
}

- (NSString *)qim_syncUploadImage:(NSData *)fileData withFileKey:(NSString *)fileKey withFileName:(NSString *)fileName {
    return [[QIMNewFileManager sharedInstance] qim_syncUploadImage:fileData withFileKey:fileKey withFileName:fileName];
}

- (NSString *)qim_syncUploadImage:(NSData *)fileData {
    return [[QIMNewFileManager sharedInstance] qim_syncUploadImage:fileData];
}

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] qim_uploadVideoPath:LocalVideoOutPath forMessage:message];
}

- (NSString *)qim_specialMd5fromUrl:(NSString *) url {
    return [[QIMNewFileManager sharedInstance] qim_specialMd5fromUrl:url];
}

- (NSString *)qim_specialGetFileExtFromUrl:(NSString *)url {
    return [[QIMNewFileManager sharedInstance] qim_specialGetFileExtFromUrl:url];
}

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] qim_uploadFile:localFilePath forMessage:message];
}

- (void)qim_uploadFile:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] qim_uploadFile:localFilePath WithCallback:callback];
}

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithCallback:(QIMKitUploadFileNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] qim_uploadFileWithFileData:fileData WithCallback:callback];
}

- (NSString *)qim_getLocalFileDataWithFileName:(NSString *)fileName {
    return [[QIMNewFileManager sharedInstance] qim_getLocalFileDataWithFileName:fileName];
}

- (NSString *)qim_saveLocalFileData:(NSData *)fileData withFileName:(NSString *)fileName {
   return [[QIMNewFileManager sharedInstance] qim_saveLocalFileData:fileData withFileName:fileName];
}

- (NSString *)qim_saveRemoteFileData:(NSData *)fileData withFileName:(NSString *)fileName {
   return [[QIMNewFileManager sharedInstance] qim_saveRemoteFileData:fileData withFileName:fileName];
}

@end
