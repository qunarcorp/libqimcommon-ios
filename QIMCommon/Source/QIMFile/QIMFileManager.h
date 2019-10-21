//
//  QIMFileManager.h
//  qunarChatIphone
//
//  Created by chenjie on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "QIMPrivateHeader.h"

typedef void(^QIMFileManagerUploadCompletionBlock)(UIImage *image, NSError *error, QIMFileCacheType cacheType, NSString *imageURL);

@interface QIMFileManager : NSObject

+ (QIMFileManager *)sharedInstance;

+ (NSString *) documentsofPath:(QIMFileCacheType) type;

- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(QIMFileCacheType)type;

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
