//
//  QIMKit+QIMNewFileManager.h
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMKit (QIMNewFileManager)

- (NSString *)qim_saveImageData:(NSData *)imageData;

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequestSuccessedBlock)callback;

- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message;

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadImage:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequestSuccessedBlock)callback;

- (void)qim_uploadImageWithImageData:(NSData *)imageData withProgressCallBack:(QIMKitUploadImageNewRequestProgessSuccessedBlock)proCallback withCallback:(QIMKitUploadImageNewRequestSuccessedBlock)callback;

#pragma mark - sync Check
- (NSString *)qim_syncCheckFileKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension;

- (NSString *)qim_syncUploadImage:(NSData *)fileData withFileKey:(NSString *)fileKey withFileName:(NSString *)fileName;

- (NSString *)qim_syncUploadImage:(NSData *)fileData;

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message;

- (NSString *)qim_specialMd5fromUrl:(NSString *) url;

- (NSString *)qim_specialGetFileExtFromUrl:(NSString *)url;

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFile:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback;

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithCallback:(QIMKitUploadFileNewRequestSuccessedBlock)callback;

- (NSString *)qim_getLocalFileDataWithFileName:(NSString *)fileName;

- (NSString *)qim_saveLocalFileData:(NSData *)fileData withFileName:(NSString *)fileName;

- (NSString *)qim_saveRemoteFileData:(NSData *)fileData withFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
