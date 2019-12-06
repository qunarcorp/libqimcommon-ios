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
#import "QIMManager.h"
#import "QIMManager+Helper.h"
#import "QIMNotificationKeys.h"
#define kResourceCachePath                          @"Resource"
#define kImageCahce                                 @"QIMImageCache"
#define kHashSalt                                   @"iqunar"
#define kResourceEmptyValue                             "\0"

#define UserDocumentsPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define UserCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define UserPath @"_Release"

static QIMDataController *__globalDataController = nil;
@implementation QIMDataController

+ (QIMDataController *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalDataController = [[QIMDataController alloc] init];
    });
    return __globalDataController;
}

// 保存
- (void)save {

}

// 销毁
- (void)destroy {

}

- (UIImage *)getResourceImage:(NSString *)key {
    if (![key qim_isStringSafe])
    {
        return nil;
    }
    
    UIImage *resource = nil;
    NSString *fileName = [NSString qim_hashString:key withSalt:kHashSalt];
    NSData *data = [self getResourceWithFileName:fileName];
    if ([data isEqualToData:[NSData dataWithBytes:kResourceEmptyValue length:2]])
    {
        // 无效数据
    }
    else
    {
        UIImage *image = [UIImage imageWithData:data];
        if (nil == image)
        {
            // 非图片数据
        }
        else
        {
            resource = image;
        }
    }
    return resource;
}

- (long long) sizeofImagePath {
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
    NSString *logDirectory = [UserCachesPath stringByAppendingPathComponent:@"Logs"];

    return [QIMUtility sizeofPath:cachePath] + [QIMUtility sizeofPath:logDirectory];
}

- (long long)sizeOfDBPath {
    NSString *dbPath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/QIMNewDataBase/%@%@/", [[QIMManager sharedInstance] getLastJid], UserPath]];
    [[QIMManager sharedInstance] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[dbPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    dbPath = [dbPath stringByAppendingPathComponent:@"data.dat"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:dbPath error:nil] fileSize];
        
    }
    return 0;
}
    
- (long long)sizeOfDBWALPath {
    NSString *dbWalPath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/QIMNewDataBase/%@%@/", [[QIMManager sharedInstance] getLastJid], UserPath]];
    [[QIMManager sharedInstance] addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[dbWalPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

    dbWalPath = [dbWalPath stringByAppendingPathComponent:@"data.dat-wal"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbWalPath]) {
        
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:dbWalPath error:nil] fileSize];
        
    }
    return 0;
}

- (NSString *)transfromTotalSize:(long long)totalSize {
    NSString *str = nil;
    if (totalSize < 1048576) {
        // 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1024.0;
        str = [NSString stringWithFormat:@"%.2fKB", result];
    } else if (totalSize < 1073741824) {
        // 1024 * 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1048576.0;
        str = [NSString stringWithFormat:@"%.2fMB", result];
    } else if (totalSize < 1099511627776) {
        // 1024 * 1024 * 1024
        double total = (double)totalSize;
        float result = total / 1073741824.0;
        str = [NSString stringWithFormat:@"%.2fGB", result];
    }
    return str;
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
    NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:@"imageCache"];
    [self deleteAllFilesAtPath:cachePath];
    [self deleteAllFilesAtPath:imageCachePath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kQCRemoveImageCachePathSuccess object:nil];
    });
}

- (void)clearLogFiles {
    NSString *logDirectory = [UserCachesPath stringByAppendingPathComponent:@"Logs"];
    [[NSFileManager defaultManager] removeItemAtPath:logDirectory error:nil];
}

- (NSData *)getResourceWithFileName:(NSString *)fileName {
    NSData *data = nil;
    if (nil == fileName || [fileName length] == 0)
    {
        return nil;
    }
    // cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kImageCahce];
    
    // 获取resource文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
    {
        data = [[NSFileManager defaultManager] contentsAtPath:resourcePath];
    }
    return data;
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

// 添加资源
- (void)addResource:(id)resource withKey:(NSString *)key {
    if (![key qim_isStringSafe])
    {
        return;
    }
    if (resource == [NSNull null])
    {
        resource = [NSData dataWithBytes:kResourceEmptyValue length:2];
    }
    dispatch_block_t block = ^{
        NSString *fileName = [NSString qim_hashString:key withSalt:kHashSalt];
        [self saveResourceWithFileName:fileName data:resource];
    };
    [QIMUtility performInBackground:block];
}

@end
