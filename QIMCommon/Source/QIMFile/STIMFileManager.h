//
//  STIMFileManager.h
//  qunarChatIphone
//
//  Created by chenjie on 16/6/20.
//
//

#import <Foundation/Foundation.h>
#import "STIMPrivateHeader.h"

typedef void(^STIMFileManagerUploadCompletionBlock)(UIImage *image, NSError *error, STIMFileCacheType cacheType, NSString *imageURL);

@interface STIMFileManager : NSObject

+ (STIMFileManager *)sharedInstance;

+ (NSString *) urlpathExtension:(NSString *) url;

+ (NSString *) documentsofPath:(STIMFileCacheType) type;

- (NSString *)uploadFileForPath:(NSString *)filePath forMessage:(STIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (NSString *)uploadFileForData:(NSData *)fileData forMessage:(STIMMessageModel *)message withJid:(NSString *)jid isFile:(BOOL)flag;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(STIMFileCacheType)type isFile:(BOOL)flag completionBlock:(STIMFileManagerUploadCompletionBlock)completionBlock;

- (void)uploadFileForData:(NSData *)fileData forCacheType:(STIMFileCacheType)type isFile:(BOOL)flag fileExt:(NSString *)fileExt completionBlock:(STIMFileManagerUploadCompletionBlock)completionBlock;

- (void )downloadFileWithUrl:(NSString *)url isFile:(BOOL)flag forCacheType:(STIMFileCacheType)type;

-(void)downloadImage:(NSString *)url width:(CGFloat) width height:(CGFloat) height  forCacheType:(STIMFileCacheType)type;

-(void)downloadCollectionEmoji:(NSString *)url
                         width:(CGFloat) width
                        height:(CGFloat) height
                  forCacheType:(STIMFileCacheType)type
                    complation:(void(^)(NSData *)) complation;

-(void)downloadImage:(NSString *)url
               width:(CGFloat) width
              height:(CGFloat) height
        forCacheType:(STIMFileCacheType)type
          complation:(void(^)(NSData *)) complation;

//- (NSData *) getSmallFileDataFromUrl:(NSString *)url forCacheType:(STIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data withFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl forCacheType:(STIMFileCacheType)type;

- (NSString *) saveFileData:(NSData *)data url:(NSString *)httpUrl  width:(CGFloat) width height:(CGFloat) height forCacheType:(STIMFileCacheType)type;

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type;

- (NSString *) getFilePathForFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type careExist:(BOOL) careExist;

- (void )getPermUrlWithTempUrl:(NSString *)tempUrl PermHttpUrl:(void(^)(NSString *))callBackPermUrl;

- (BOOL)isFileExistForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(STIMFileCacheType)type;

- (NSString *)fileExistLocalPathForUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(STIMFileCacheType)type;

- (NSString *)getNewMd5ForMd5:(NSString *)oldMd5 withWidth:(float)width height:(float)height;

- (NSData *) getFileDataForFileName:(NSString *)fileName forCacheType:(STIMFileCacheType)type;

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(STIMFileCacheType)type;

- (NSData *) getFileDataFromUrl:(NSString *)url forCacheType:(STIMFileCacheType)type needUpdate:(BOOL)update;

- (NSData *) getFileDataFromUrl:(NSString *)url width:(float)width height:(float)height forCacheType:(STIMFileCacheType)type;

- (CGSize)getImageSizeFromUrl:(NSString *)url;

- (NSString *) getFileNameFromKey:(NSString *)url;

- (NSString *) getFileNameFromUrl:(NSString *)url;

- (NSString *) getFileExtFromUrl:(NSString *) url;

- (NSString *) md5fromUrl:(NSString *) url;

- (NSString *) getFileNameFromUrl:(NSString *)url width:(CGFloat) width height:(CGFloat) height;

- (NSString *)getImageFileExt:(NSData *)data;

- (NSString *)getMD5FromFileData:(NSData *)fileData;

- (CGSize)getFitSizeForImgSize:(CGSize)imgSize;

- (NSString *)stimDB_cachedFileNameForKey:(NSString *)key;


//拷贝文件
- (void)uploadFileForData:(NSData *)fileData
             forCacheType:(STIMFileCacheType)type
                  fileExt:(NSString *)fileExt
                   isFile:(BOOL)flag
   uploadProgressDelegate:(id)delegate
          completionBlock:(STIMFileManagerUploadCompletionBlock)completionBlock progressBlock:(void(^)(CGFloat progress))progressBlock;
@end
