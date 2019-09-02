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

- (NSString *)qim_saveImageData:(NSData *)imageData;

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message;

- (void)uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback;

- (void)uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message;

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
