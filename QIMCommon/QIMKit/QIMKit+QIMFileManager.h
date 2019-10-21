//
//  QIMKit+QIMFileManager.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@class QIMMessageModel;
typedef void(^QIMFileManagerUploadCompletionBlock)(UIImage *image, NSError *error, QIMFileCacheType cacheType, NSString *imageURL);

@interface QIMKit (QIMFileManager)

+ (NSString *) documentsofPath:(QIMFileCacheType) type;

/**
 文件上传
 
 @param filePath 文件路径
 @param message 消息
 @param jid user id
 @param flag 是文件还是图片
 @return 文件url
 */
- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

/**
 文件上传

 @param fileData 文件二进制
 @param message 消息
 @param jid 用户Id
 @param flag 是文件还是图片
 @return 文件URL
 */
- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

/**
 缓存文件
 
 @param data 文件data
 @param fileName 文件名称
 @param type 缓存类型
 @return 返回path
 */
- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(QIMFileCacheType)type;

/**
 缓存文件
 
 @param data 文件data
 @param httpUrl 远程链接
 @param width 宽
 @param height 高
 @param type 缓存类型
 @return 返回path
 */
- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(QIMFileCacheType)type;

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height;

- (CGSize)getImageSizeFromUrl:(NSString *)url;

//拷贝文件
- (void)uploadFileForData:(NSData *)fileData
             forCacheType:(QIMFileCacheType)type
                  fileExt:(NSString *)fileExt
                   isFile:(BOOL)flag
   uploadProgressDelegate:(id)delegate
          completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock progressBlock:(void(^)(CGFloat progress))progressBlock;

@end
