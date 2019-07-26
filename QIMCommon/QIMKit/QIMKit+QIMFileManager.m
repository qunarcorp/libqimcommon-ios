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

+ (NSString *) urlpathExtension:(NSString *) url {
    return [QIMFileManager urlpathExtension:url];
}

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

- (void )downloadFileWithUrl:(NSString *)url isFile:(BOOL)flag forCacheType:(QIMFileCacheType)type {
    [[QIMFileManager sharedInstance] downloadFileWithUrl:url isFile:flag forCacheType:type];
}

-(void)downloadImage:(NSString *)url width:(CGFloat) width height:(CGFloat) height  forCacheType:(QIMFileCacheType)type {
    [[QIMFileManager sharedInstance] downloadImage:url width:width height:height forCacheType:type];
}

-(void)downloadImage:(NSString *)url
               width:(CGFloat) width
              height:(CGFloat) height
        forCacheType:(QIMFileCacheType)type
          complation:(void(^)(NSData *)) complation {
    [[QIMFileManager sharedInstance] downloadImage:url width:width height:height forCacheType:type complation:complation];
}

-(void)downloadCollectionEmoji:(NSString *)url
                         width:(CGFloat) width
                        height:(CGFloat) height
                  forCacheType:(QIMFileCacheType)type
                    complation:(void(^)(NSData *)) complation {
    [[QIMFileManager sharedInstance] downloadCollectionEmoji:url width:width height:height forCacheType:type complation:complation];
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

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] getFilePathForFileName:fileName forCacheType:type];
}

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type careExist:(BOOL) careExist {
    return [[QIMFileManager sharedInstance] getFilePathForFileName:fileName forCacheType:type careExist:careExist];
}

- (void )getPermUrlWithTempUrl:(NSString *)tempUrl PermHttpUrl:(void(^)(NSString *))callBackPermUrl {
    [[QIMFileManager sharedInstance] getPermUrlWithTempUrl:tempUrl PermHttpUrl:callBackPermUrl];
}

- (BOOL)isFileExistForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] isFileExistForUrl:url width:width height:height forCacheType:type];
}

- (NSString *)fileExistLocalPathForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] fileExistLocalPathForUrl:url width:width height:height forCacheType:type];
}

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height {
    return [[QIMFileManager sharedInstance] getNewMd5ForMd5:oldMd5 withWidth:width height:height];
}

- (NSData *) getFileDataForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] getFileDataForFileName:fileName forCacheType:type];
}

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] getFileDataFromUrl:url forCacheType:type];
}

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type needUpdate:(BOOL)update {
    return [[QIMFileManager sharedInstance] getFileDataFromUrl:url forCacheType:type needUpdate:update];
}

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type {
    return [[QIMFileManager sharedInstance] getFileDataFromUrl:url width:width height:height forCacheType:type];
}

- (CGSize)getImageSizeFromUrl:(NSString *)url {
    return [[QIMFileManager sharedInstance] getImageSizeFromUrl:url];
}

- (NSString *) getFileNameFromKey:(NSString *)url {
    return [[QIMFileManager sharedInstance] getFileNameFromKey:url];
}

- (NSString *) getFileNameFromUrl:(NSString *)url {
    return [[QIMFileManager sharedInstance] getFileNameFromUrl:url];
}

- (NSString *) getFileExtFromUrl:(NSString *) url {
    return [[QIMFileManager sharedInstance] getFileExtFromUrl:url];
}

- (NSString *) md5fromUrl:(NSString *) url {
    return [[QIMFileManager sharedInstance] md5fromUrl:url];
}

- (NSString *) getFileNameFromUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height {
    return [[QIMFileManager sharedInstance] getFileNameFromUrl:url width:width height:height];
}

- (NSString *)getImageFileExt:(NSData *)data {
    return [[QIMFileManager sharedInstance] getImageFileExt:data];
}

- (NSString *)getMD5FromFileData:(NSData *)fileData {
    return [[QIMFileManager sharedInstance] getMD5FromFileData:fileData];
}

- (CGSize)getFitSizeForImgSize:(CGSize)imgSize {
    return [[QIMFileManager sharedInstance] getFitSizeForImgSize:imgSize];
}

- (NSString *)qim_cachedFileNameForKey:(NSString *)key {
    return [[QIMFileManager sharedInstance] qim_cachedFileNameForKey:key];
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
