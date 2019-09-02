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

- (void)uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] uploadVideo:videoPath videoDic:videoExt withCallBack:callback];
}

- (void)qim_uploadImage:(NSString *)localImagePath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] qim_uploadImage:localImagePath forMessage:message];
}

- (void)uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] uploadVideoPath:LocalVideoOutPath forMessage:message];
}

- (void)qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] qim_uploadFile:(NSString *)localFilePath forMessage:(QIMMessageModel *)message];
}

@end
