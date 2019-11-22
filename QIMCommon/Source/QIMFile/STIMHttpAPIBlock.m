//
//  STIMHttpAPIBlock.m
//  STIMCommon
//
//  Created by 李露 on 10/16/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMHttpAPIBlock.h"
#import "ASIHttpRequest.h"
#import "STIMPublicRedefineHeader.h"

#define KNotifyUploadProgress               @"KNotifyUploadProgress"

@interface STIMHttpAPIBlock () <ASIProgressDelegate>

@end

@implementation STIMHttpAPIBlock

- (void)setProgress:(float)newProgress {
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotifyUploadProgress object:@(newProgress)];
    STIMVerboseLog(@"上传进度 : %lf", newProgress);
}

@end
