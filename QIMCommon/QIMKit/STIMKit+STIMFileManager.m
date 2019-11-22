//
//  STIMKit+STIMFileManager.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMFileManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMFileManager)

+ (NSString *) urlpathExtension:(NSString *) url {
    return [STIMFileManager urlpathExtension:url];
}

+ (NSString *) documentsofPath:(STIMFileCacheType) type {
    return [STIMFileManager documentsofPath:type];
}

- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(STIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    return [[STIMFileManager sharedInstance] uploadFileForPath:filePath forMessage:message withJid:jid isFile:flag];
}

- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(STIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag {
    return [[STIMFileManager sharedInstance] uploadFileForData:fileData forMessage:message withJid:jid isFile:flag];
}

- (void)uploadFileForData:(NSData *)fileData forCacheType:(STIMFileCacheType)type isFile:(BOOL)flag completionBlock:(STIMFileManagerUploadCompletionBlock)completionBlock {
    [[STIMFileManager sharedInstance] uploadFileForData:fileData forCacheType:type isFile:flag completionBlock:completionBlock];
}

- (void)uploadFileForData:(NSData *)fileData forCacheType:(STIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(STIMFileManagerUploadCompletionBlock)completionBlock {
    [[STIMFileManager sharedInstance] uploadFileForData:fileData forCacheType:type isFile:flag fileExt:fileExt completionBlock:completionBlock];
}

- (void )downloadFileWithUrl:(NSString *)url isFile:(BOOL)flag forCacheType:(STIMFileCacheType)type {
    [[STIMFileManager sharedInstance] downloadFileWithUrl:url isFile:flag forCacheType:type];
}

-(void)downloadImage:(NSString *)url width:(CGFloat) width height:(CGFloat) height  forCacheType:(STIMFileCacheType)type {
    [[STIMFileManager sharedInstance] downloadImage:url width:width height:height forCacheType:type];
}

-(void)downloadImage:(NSString *)url
               width:(CGFloat) width
              height:(CGFloat) height
        forCacheType:(STIMFileCacheType)type
          complation:(void(^)(NSData *)) complation {
    [[STIMFileManager sharedInstance] downloadImage:url width:width height:height forCacheType:type complation:complation];
}

-(void)downloadCollectionEmoji:(NSString *)url
                         width:(CGFloat) width
                        height:(CGFloat) height
                  forCacheType:(STIMFileCacheType)type
                    complation:(void(^)(NSData *)) complation {
    [[STIMFileManager sharedInstance] downloadCollectionEmoji:url width:width height:height forCacheType:type complation:complation];
}

- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] saveFileData:data withFileName:fileName forCacheType:type];
}

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] saveFileData:data url:httpUrl forCacheType:type];
}

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] saveFileData:data url:httpUrl width:width height:height forCacheType:type];
}

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] getFilePathForFileName:fileName forCacheType:type];
}

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type careExist:(BOOL) careExist {
    return [[STIMFileManager sharedInstance] getFilePathForFileName:fileName forCacheType:type careExist:careExist];
}

- (void )getPermUrlWithTempUrl:(NSString *)tempUrl PermHttpUrl:(void(^)(NSString *))callBackPermUrl {
    [[STIMFileManager sharedInstance] getPermUrlWithTempUrl:tempUrl PermHttpUrl:callBackPermUrl];
}

- (BOOL)isFileExistForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] isFileExistForUrl:url width:width height:height forCacheType:type];
}

- (NSString *)fileExistLocalPathForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] fileExistLocalPathForUrl:url width:width height:height forCacheType:type];
}

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height {
    return [[STIMFileManager sharedInstance] getNewMd5ForMd5:oldMd5 withWidth:width height:height];
}

- (NSData *) getFileDataForFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] getFileDataForFileName:fileName forCacheType:type];
}

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] getFileDataFromUrl:url forCacheType:type];
}

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(STIMFileCacheType)type needUpdate:(BOOL)update {
    return [[STIMFileManager sharedInstance] getFileDataFromUrl:url forCacheType:type needUpdate:update];
}

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(STIMFileCacheType)type {
    return [[STIMFileManager sharedInstance] getFileDataFromUrl:url width:width height:height forCacheType:type];
}

- (CGSize)getImageSizeFromUrl:(NSString *)url {
    return [[STIMFileManager sharedInstance] getImageSizeFromUrl:url];
}

- (NSString *) getFileNameFromKey:(NSString *)url {
    return [[STIMFileManager sharedInstance] getFileNameFromKey:url];
}

- (NSString *) getFileNameFromUrl:(NSString *)url {
    return [[STIMFileManager sharedInstance] getFileNameFromUrl:url];
}

- (NSString *) getFileExtFromUrl:(NSString *) url {
    return [[STIMFileManager sharedInstance] getFileExtFromUrl:url];
}

- (NSString *) md5fromUrl:(NSString *) url {
    return [[STIMFileManager sharedInstance] md5fromUrl:url];
}

- (NSString *) getFileNameFromUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height {
    return [[STIMFileManager sharedInstance] getFileNameFromUrl:url width:width height:height];
}

- (NSString *)getImageFileExt:(NSData *)data {
    return [[STIMFileManager sharedInstance] getImageFileExt:data];
}

- (NSString *)getMD5FromFileData:(NSData *)fileData {
    return [[STIMFileManager sharedInstance] getMD5FromFileData:fileData];
}

- (CGSize)getFitSizeForImgSize:(CGSize)imgSize {
    return [[STIMFileManager sharedInstance] getFitSizeForImgSize:imgSize];
}

- (NSString *)stimDB_cachedFileNameForKey:(NSString *)key {
    return [[STIMFileManager sharedInstance] stimDB_cachedFileNameForKey:key];
}

//拷贝文件
- (void)uploadFileForData:(NSData *)fileData
             forCacheType:(STIMFileCacheType)type
                  fileExt:(NSString *)fileExt
                   isFile:(BOOL)flag
   uploadProgressDelegate:(id)delegate
          completionBlock:(STIMFileManagerUploadCompletionBlock)completionBlock progressBlock:(void(^)(CGFloat progress))progressBlock{
    [[STIMFileManager sharedInstance] uploadFileForData:fileData forCacheType:type fileExt:fileExt isFile:flag uploadProgressDelegate:delegate completionBlock:completionBlock progressBlock:progressBlock];
}

@end
