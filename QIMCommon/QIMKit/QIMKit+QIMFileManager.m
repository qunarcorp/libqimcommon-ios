//
//  QIMKit+QIMFileManager.m
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMKit+QIMFileManager.h"
#import "QIMPrivateHeader.h"
#import "QIMFileManager.h"

@implementation QIMKit (QIMFileManager)

#pragma mark - Public
- (NSString * _Nonnull)qim_cachedFileNameForKey:(NSString * _Nullable) key {
    return [[QIMFileManager sharedInstance] qim_cachedFileNameForKey:key];
}

- (NSString *)qim_getFileMD5WithPath:(NSString *)filePath {
    return [[QIMFileManager sharedInstance] qim_getFileMD5WithPath:filePath];
}

#pragma mark - 图片

- (NSString *)qim_imageKey:(NSData *)imageData {
    return [[QIMFileManager sharedInstance] qim_imageKey:imageData];
}

- (NSString *)qim_saveImageData:(NSData *)imageData {
    return [[QIMFileManager sharedInstance] qim_saveImageData:imageData];
}

- (NSString *)getFileExtFromUrl:(NSString *)url {
    return [[QIMFileManager sharedInstance] getFileExtFromUrl:url];
}

- (NSString *)md5fromUrl:(NSString *)url {
    return [[QIMFileManager sharedInstance] md5fromUrl:url];
}

- (NSString *)getFileNameFromUrl:(NSString *)url {
    return [[QIMFileManager sharedInstance] getFileNameFromUrl:url];
}

/**
 上传图片成功之后会，发送图片消息
 
 @param localImageKey 图片key
 @param message 要发送的消息Model
 */
- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message {
    [[QIMFileManager sharedInstance] qim_uploadImageWithImageKey:localImageKey forMessage:message];
}

/**
 上传图片成功之后，发送图片消息
 
 @param localImagePath 本地图片路径
 @param message 要发送的消息Model
 */
- (void)qim_uploadImageWithImagePath:(NSString *)localImagePath forMessage:(QIMMessageModel *)message {
    [[QIMFileManager sharedInstance] qim_uploadImageWithImagePath:localImagePath forMessage:message];
}

/**
 上传图片
 
 @param localImagePath 本地图片路径
 @param callback 返回图片地址
 */
- (void)qim_uploadImageWithImagePath:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequestSuccessedBlock)callback {
    [[QIMFileManager sharedInstance] qim_uploadImageWithImagePath:localImagePath withCallback:callback];
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
    [[QIMFileManager sharedInstance] qim_uploadImageWithImageData:fileData WithMsgId:key WithMsgType:type WithPathExtension:extension withCallBack:callback];
}

/**
 上传我的头像
 
 @param headerData 头像二进制
 @param callback 返回头像地址
 */
- (void)qim_uploadMyPhotoData:(NSData *)headerData withCallBack:(QIMKitUploadMyPhotoCallBack)callback {
    [[QIMFileManager sharedInstance] qim_uploadMyPhotoData:headerData withCallBack:callback];
}

#pragma mark - 视频

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequestSuccessedBlock)callback {
    [[QIMFileManager sharedInstance] qim_uploadVideo:videoPath videoDic:videoExt withCallBack:callback];
}

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
    [[QIMFileManager sharedInstance] qim_uploadVideoPath:LocalVideoOutPath forMessage:message];
}

#pragma mark - 文件

- (void)qim_uploadFileWithFilePath:(NSString *)localFilePath forMessage:(QIMMessageModel *)message {
    [[QIMFileManager sharedInstance] qim_uploadFileWithFilePath:localFilePath forMessage:message];
}

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithPathExtension:(NSString *)extension forMessage:(QIMMessageModel *)message {
    [[QIMFileManager sharedInstance] qim_uploadFileWithFileData:fileData WithPathExtension:extension forMessage:message];
}

- (void)qim_uploadFileWithFilePath:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback {
    [[QIMFileManager sharedInstance] qim_uploadFileWithFilePath:localFilePath WithCallback:callback];
}

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithPathExtension:(NSString *)extension WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback {
    [[QIMFileManager sharedInstance] qim_uploadFileWithFileData:fileData WithPathExtension:extension WithCallback:callback];
}

- (NSString *)qim_getLocalFileDataWithFileName:(NSString *)fileName {
    return [[QIMFileManager sharedInstance] qim_getLocalFileDataWithFileName:fileName];
}

- (NSString *)qim_saveLocalFileData:(NSData *)fileData withFileName:(NSString *)fileName {
    return [[QIMFileManager sharedInstance] qim_saveLocalFileData:fileData withFileName:fileName];
}
@end
