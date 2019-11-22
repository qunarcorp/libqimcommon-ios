//
//  QIMHttpAPIBlock.m
//  QIMCommon
//
//  Created by 李露 on 10/16/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMHttpAPIBlock.h"
#import "QIMPublicRedefineHeader.h"

#define KNotifyUploadProgress               @"KNotifyUploadProgress"

@interface QIMHttpAPIBlock () 

@end

@implementation QIMHttpAPIBlock

- (void)setProgress:(float)newProgress {
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotifyUploadProgress object:@(newProgress)];
    QIMVerboseLog(@"上传进度 : %lf", newProgress);
}

@end
