//
//  QIMKit+QIMFileManager.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMFileManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMFileManager)

+ (NSString *) documentsofPath:(QIMFileCacheType) type {
    return [QIMFileManager documentsofPath:type];
}

- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    return [[QIMFileManager sharedInstance] uploadFileForPath:filePath forMessage:message withJid:jid isFile:flag];
}

- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    return [[QIMFileManager sharedInstance] uploadFileForData:fileData forMessage:message withJid:jid isFile:flag];
}

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock {
    [[QIMFileManager sharedInstance] uploadFileForData:fileData forCacheType:type isFile:flag completionBlock:completionBlock];
}

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock {
    [[QIMFileManager sharedInstance] uploadFileForData:fileData forCacheType:type isFile:flag fileExt:fileExt completionBlock:completionBlock];
}

- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] saveFileData:data withFileName:fileName forCacheType:type];
}

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] saveFileData:data url:httpUrl forCacheType:type];
}

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] saveFileData:data url:httpUrl width:width height:height forCacheType:type];
}

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height {
    return [[QIMFileManager sharedInstance] getNewMd5ForMd5:oldMd5 withWidth:width height:height];
}

- (CGSize)getImageSizeFromUrl:(NSString *)url {
    return [[QIMFileManager sharedInstance] getImageSizeFromUrl:url];
}

//拷贝文件
- (void)uploadFileForData:(NSData *)fileData
             forCacheType:(QIMFileCacheType)type
                  fileExt:(NSString *)fileExt
                   isFile:(BOOL)flag
   uploadProgressDelegate:(id)delegate
          completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock progressBlock:(void(^)(CGFloat progress))progressBlock{
    [[QIMFileManager sharedInstance] uploadFileForData:fileData forCacheType:type fileExt:fileExt isFile:flag uploadProgressDelegate:delegate completionBlock:completionBlock progressBlock:progressBlock];
}

@end
