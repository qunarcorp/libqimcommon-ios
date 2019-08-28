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

- (void)uploadVideo:(NSString *)videoPath videoDic:(NSDictionary *)videoExt withCallBack:(QIMKitUploadVideoNewRequesSuccessedBlock)callback {
    [[QIMNewFileManager sharedInstance] uploadVideo:videoPath videoDic:videoExt withCallBack:callback];
}

- (void)uploadVideoPath:(NSString *)LocalVideoOutPath forMessage:(QIMMessageModel *)message {
    [[QIMNewFileManager sharedInstance] uploadVideoPath:LocalVideoOutPath forMessage:message];
}

@end
