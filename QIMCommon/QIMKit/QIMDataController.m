//
//  DataController.m
//  qunarChatIphone
//
//  Created by wangshihai on 15/2/6.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMDataController.h"
#import "NSString+QIMUtility.h"
#import "QIMUtility.h"
#import "QIMFileManager.h"
#import "QIMNewFileManager.h"
#import "QIMManager.h"
#define kImageCahce                                 @"QIMImageCache"
#define kHashSalt                                   @"iqunar"

static QIMDataController *__globalDataController = nil;
@implementation QIMDataController

+ (QIMDataController *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalDataController = [[QIMDataController alloc] init];
        [__globalDataController initCachePath];
    });
    return __globalDataController;
}

- (void)initCachePath {
    //本地文件缓存
    NSString *localCachePath = [UserCachesPath stringByAppendingPathComponent:QIMLocalFileCache];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:localCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    //远程文件缓存
    NSString *remoteCachePath = [UserCachesPath stringByAppendingPathComponent:QIMRemoteFileCache];
    if (![[NSFileManager defaultManager] fileExistsAtPath:remoteCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:remoteCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (long long) sizeofImagePath {
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
    NSString *newcachePath = [QIMFileManager documentsofPath:QIMFileCacheTypeColoction];
    NSString *logDirectory = [UserCachesPath stringByAppendingPathComponent:@"Logs"];

    return [QIMUtility sizeofPath:cachePath] + [QIMUtility sizeofPath:newcachePath] + [QIMUtility sizeofPath:logDirectory];
}

- (long long)sizeOfDBPath {
    NSString *dbPath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/QIMNewDataBase/"]];
    return [QIMUtility sizeofPath:dbPath];
}

- (void) deleteAllFilesAtPath:(NSString *) cachePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:filename] error:NULL];
    }
}

- (void) removeAllImage {
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    NSString *newcachePath = [QIMFileManager documentsofPath:QIMFileCacheTypeColoction];
    NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
    [self deleteAllFilesAtPath:cachePath];
    [self deleteAllFilesAtPath:newcachePath];
    [self deleteAllFilesAtPath:imageCachePath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kQCRemoveImageCachePathSuccess object:nil];
    });
}

- (void)clearLogFiles {
    NSString *logDirectory = [UserCachesPath stringByAppendingPathComponent:@"Logs"];
    [[NSFileManager defaultManager] removeItemAtPath:logDirectory error:nil];
}

-(NSString *)getSourcePath:(NSString *)fileName {
    fileName  = [NSString qim_hashString:fileName withSalt:kHashSalt];
    
    if (nil == fileName || [fileName length] == 0)
    {
        return nil;
    }
    // cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
   
    return resourcePath;
}

-(void)deleteResourceWithFileName:(NSString *)fileName {
    fileName = [NSString qim_hashString:fileName withSalt:kHashSalt];
    
    if (nil == fileName || [fileName length] == 0) {
        return;
    }
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
}

- (void)saveResourceWithFileName:(NSString *)fileName data:(NSData *)data {
    
//    [QIMNewFileManager sharedInstance]
     fileName = [NSString qim_hashString:fileName withSalt:kHashSalt];
    
    if (nil == fileName || [fileName length] == 0) {
        return;
    }
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    [data writeToFile:resourcePath atomically:YES];
    
}

@end
