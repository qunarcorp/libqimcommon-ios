//
//  QIMKit+QIMFileManager.h
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMKit (QIMFileManager)

#pragma mark - Public
- (NSString * _Nonnull)qim_cachedFileNameForKey:(NSString * _Nullable) key;

- (NSString *)qim_getFileMD5WithPath:(NSString *)filePath;

#pragma mark - 图片

- (NSString *)qim_imageKey:(NSData *)imageData;

- (NSString *)qim_saveImageData:(NSData *)imageData;

- (NSString *)getFileExtFromUrl:(NSString *)url;

- (NSString *)md5fromUrl:(NSString *)url;

- (NSString *)getFileNameFromUrl:(NSString *)url;

/**
 上传图片成功之后会，发送图片消息
 
 @param localImageKey 图片key
 @param message 要发送的消息Model
 */
- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message;

/**
 上传图片成功之后，发送图片消息
 
 @param localImagePath 本地图片路径
 @param message 要发送的消息Model
 */
- (void)qim_uploadImageWithImagePath:(NSString *)localImagePath forMessage:(QIMMessageModel *)message;

/**
 上传图片
 
 @param localImagePath 本地图片路径
 @param callback 返回图片地址
 */
- (void)qim_uploadImageWithImagePath:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequestSuccessedBlock)callback;

/**
 上传图片
 
 @param fileData 图片二进制
 @param key fileKey
 @param type type
 @param extension 文件后缀
 @return 返回图片地址
 */
- (void)qim_uploadImageWithImageData:(NSData *)fileData WithMsgId:(NSString *)key WithMsgType:(int)type WithPathExtension:(NSString *)extension withCallBack:(QIMKitUploadImageCallBack)callback;

/**
 上传我的头像
 
 @param headerData 头像二进制
 @param callback 返回头像地址
 */
- (void)qim_uploadMyPhotoData:(NSData *)headerData withCallBack:(QIMKitUploadMyPhotoCallBack)callback;

#pragma mark - 视频

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequestSuccessedBlock)callback;

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message;

#pragma mark - 文件

- (void)qim_uploadFileWithFilePath:(NSString *)localFilePath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithPathExtension:(NSString *)extension forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFileWithFilePath:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback;

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithPathExtension:(NSString *)extension WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback;


- (NSString *)qim_getLocalFileDataWithFileName:(NSString *)fileName;

- (NSString *)qim_saveLocalFileData:(NSData *)fileData withFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
