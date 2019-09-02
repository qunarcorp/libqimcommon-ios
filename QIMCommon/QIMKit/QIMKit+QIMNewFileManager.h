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

- (void)uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback;

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message;

- (void)uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
