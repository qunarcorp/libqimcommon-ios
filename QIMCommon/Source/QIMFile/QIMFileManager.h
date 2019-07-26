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

+ (NSString *) urlpathExtension:(NSString *) url;

+ (NSString *) documentsofPath:(QIMFileCacheType) type;

- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(QIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(QIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock;

- (void )downloadFileWithUrl:(NSString *)url isFile:(BOOL)flag forCacheType:(QIMFileCacheType)type;

-(void)downloadImage:(NSString *)url width:(CGFloat) width height:(CGFloat) height  forCacheType:(QIMFileCacheType)type;

-(void)downloadCollectionEmoji:(NSString *)url
                         width:(CGFloat) width
                        height:(CGFloat) height
                  forCacheType:(QIMFileCacheType)type
                    complation:(void(^)(NSData *)) complation;

-(void)downloadImage:(NSString *)url
               width:(CGFloat) width
              height:(CGFloat) height
        forCacheType:(QIMFileCacheType)type
          complation:(void(^)(NSData *)) complation;

//- (NSData *) getSmallFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(QIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(QIMFileCacheType)type;

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type careExist:(BOOL) careExist;

- (void )getPermUrlWithTempUrl:(NSString *)tempUrl PermHttpUrl:(void(^)(NSString *))callBackPermUrl;

- (BOOL)isFileExistForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type;

- (NSString *)fileExistLocalPathForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type;

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height;

- (NSData *) getFileDataForFileName:(NSString *)fileName forCacheType:(QIMFileCacheType)type;

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type;

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(QIMFileCacheType)type needUpdate:(BOOL)update;

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(QIMFileCacheType)type;

- (CGSize)getImageSizeFromUrl:(NSString *)url;

- (NSString *) getFileNameFromKey:(NSString *)url;

- (NSString *) getFileNameFromUrl:(NSString *)url;

- (NSString *) getFileExtFromUrl:(NSString *) url;

- (NSString *) md5fromUrl:(NSString *) url;

- (NSString *) getFileNameFromUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height;

- (NSString *)getImageFileExt:(NSData *)data;

- (NSString *)getMD5FromFileData:(NSData *)fileData;

- (CGSize)getFitSizeForImgSize:(CGSize)imgSize;

- (NSString *)qim_cachedFileNameForKey:(NSString *)key;


//拷贝文件
- (void)uploadFileForData:(NSData *)fileData
             forCacheType:(QIMFileCacheType)type
                  fileExt:(NSString *)fileExt
                   isFile:(BOOL)flag
   uploadProgressDelegate:(id)delegate
          completionBlock:(QIMFileManagerUploadCompletionBlock)completionBlock progressBlock:(void(^)(CGFloat progress))progressBlock;
@end
