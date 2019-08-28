//
//  QIMNewFileManager.h
//  QIMCommon
//
//  Created by lilu on 2019/8/28.
//

#import "QIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMNewFileManager : NSObject

+ (instancetype)sharedInstance;

- (void)uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback;

- (void)uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
