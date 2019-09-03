//
//  QIMNewFileManager.h
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QIMKitCheckImageCallBack)(NSString *imageUrl);
typedef void(^QIMKitCheckFileCallBack)(NSString *fileUrl);


@interface QIMNewFileManager : NSObject

+ (instancetype)sharedInstance;

- (NSString *)qim_imageKey:(NSData *)imageData;

- (NSString *)qim_saveImageData:(NSData *)imageData;

- (void)qim_uploadImageWithImageKey:(NSString *)localImageKey forMessage:(QIMMessageModel *)message;

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadImage:(NSString *)localImagePath withCallback:(QIMKitUploadImageNewRequesSuccessedBlock)callback;

- (void)qim_uploadImageWithImageData:(NSData *)imageData withCallback:(QIMKitUploadImageNewRequesSuccessedBlock)callback;

#pragma mark - sync Check
- (NSString *)qim_syncCheckFileKey:(NSString *)fileKey WithFileLength:(long long)fileLength WithPathExtension:(NSString *)extension;

- (NSString *)qim_syncUploadImage:(NSData *)fileData withFileKey:(NSString *)fileKey withFileName:(NSString *)fileName;

- (NSString *)qim_syncUploadImage:(NSData *)fileData;

- (void)qim_uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback;

- (void)qim_uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFile:(NSString *)localFilePath WithCallback:(QIMKitUploadFileNewRequesSuccessedBlock)callback;

- (void)qim_uploadFileWithFileData:(NSData *)fileData WithCallback:(QIMKitUploadFileNewRequesSuccessedBlock)callback;

@end

NS_ASSUME_NONNULL_END
