//
//  QIMUserCacheManager.m
//  qunarChatIphone
//
//  Created by admin on 16/3/10.
//
//

#import "QIMUserCacheManager.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>
#import "YYMemoryCache.h"
#import "YYCache.h"

static NSString *const QTalkDiskCacheException = @"QTalkDiskCacheException";

#define kUserCacheKey   @"kUserCacheKey"
#define kAppCacheKey    @"kAppCacheKey"

@interface QTalkUserCacheFileManager : NSObject {
    NSString *_rootPath;
}

@property (nonatomic, readonly) NSOperationQueue *calculationQueue;
#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
#else
@property (nonatomic, assign) dispatch_semaphore_t semaphore;
#endif

@property (nonatomic, readonly) NSString *rootPath;
@property (nonatomic, copy) NSString *userCachePath;
@property (nonatomic, assign) BOOL isAPPCache;
@property (nonatomic) NSInteger limitOfSize; // bytes
@property (nonatomic, assign) BOOL newData;

@end

@implementation QTalkUserCacheFileManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _calculationQueue = [[NSOperationQueue alloc] init];
        _semaphore = dispatch_semaphore_create(1);
        _limitOfSize = 1 * 1024 * 1024; //1M
//        [self performSelectorInBackground:@selector(calculateCurrentSize) withObject:nil];
    }
    return self;
}

- (void)dealloc {
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_semaphore);
#endif
}

#pragma mark - paths

- (NSString *)rootPath
{
    //老数据
    if (self.newData != YES && !self.userCachePath && !self.isAPPCache) {
        if (_rootPath) {
            return _rootPath;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _rootPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"UserCaches/"];
    } else {
        //新数据
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (self.userCachePath) {
            NSString *str = [NSString stringWithFormat:@"UserCaches/%@/", self.userCachePath];
            _rootPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:str];
        } else {
            NSString *str = [NSString stringWithFormat:@"AppCaches/"];
            _rootPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:str];
        }
        return _rootPath;
    }
    return _rootPath;
}

- (NSString *)filePathForKey:(id<NSCoding>)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:key];
    if ([data length] == 0) {
        return nil;
    }
    
    unsigned char result[16];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    NSString *cacheKey = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    
    NSString *prefix = [cacheKey substringToIndex:2];
    NSString *directoryPath = [self.rootPath stringByAppendingPathComponent:prefix];
    return [directoryPath stringByAppendingPathComponent:cacheKey];
}

- (NSArray *)validFilePathsUnderPath:(NSString *)parentPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *paths = [@[] mutableCopy];
    for (NSString *subpath in [fileManager subpathsAtPath:parentPath]) {
        if (subpath.length > 0) {
            NSString *path = [parentPath stringByAppendingPathComponent:subpath];
            [paths addObject:path];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *path = (NSString *)evaluatedObject;
        BOOL isHidden = [[path lastPathComponent] hasPrefix:@"."];
        BOOL isDirectory;
        BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
        return !isHidden && !isDirectory && exists;
    }];
    
    return [paths filteredArrayUsingPredicate:predicate];
}

- (BOOL)hasObjectForKey:(id<NSCoding>)key
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSString *path = [self filePathForKey:key];
    BOOL hasObject = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL];
    dispatch_semaphore_signal(self.semaphore);
    return hasObject;
}

- (id)objectForKey:(id <NSCoding>)key
{
    if (![self hasObjectForKey:key]) {
        return nil;
    }
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSString *path = [self filePathForKey:key];
    NSMutableDictionary *attributes = [[self attributesForFilePath:path] mutableCopy];
    if (attributes) {
        [attributes setObject:[NSDate date] forKey:NSFileModificationDate];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager setAttributes:[attributes copy] ofItemAtPath:path error:&error]) {
            [NSException raise:QTalkDiskCacheException format:@"%@", error];
        }
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    id object = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
    dispatch_semaphore_signal(self.semaphore);
    
    return object;
}

- (void)setObject:(id <NSCoding>)object forKey:(id <NSCoding>)key;
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSString *path = [self filePathForKey:key];
    NSString *directoryPath = [path stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:NULL]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            [NSException raise:QTalkDiskCacheException format:@"%@", error];
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    [data writeToFile:path atomically:YES];
//    [self calculateCurrentSize];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)removeObjectForKey:(id)key
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSString *filePath = [self filePathForKey:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath isDirectory:NULL]) {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:filePath error:&error]) {
            [NSException raise:NSInvalidArgumentException format:@"%@", error];
        }
    }
    
    NSString *directoryPath = [filePath stringByDeletingLastPathComponent];
    [self removeDirectoryIfEmpty:directoryPath];
    dispatch_semaphore_signal(self.semaphore);
}

#pragma mark - remove

- (void)removeDirectoryIfEmpty:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath]) {
        return;
    }
    
    if (![[self validFilePathsUnderPath:directoryPath] count]) {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:directoryPath error:&error]) {
            [NSException raise:QTalkDiskCacheException format:@"%@", error];
        }
    }
}

- (void)removeObjectsByAccessedDate:(NSDate *)borderDate
{
    [self removeObjectsUsingBlock:^BOOL(NSString *filePath) {
        NSDictionary *attributes = [self attributesForFilePath:filePath];
        NSDate *modificationDate = [attributes objectForKey:NSFileModificationDate];
        return [modificationDate timeIntervalSinceDate:borderDate] < 0.0;
    }];
}

- (void)removeObjectsUsingBlock:(BOOL (^)(NSString *))block
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *path in [fileManager subpathsAtPath:self.rootPath]) {
        NSString *filePath = [self.rootPath stringByAppendingPathComponent:path];
        if ([[filePath lastPathComponent] hasPrefix:@"."]) {
            continue;
        }
        
        BOOL isDirectory;
        if ([fileManager fileExistsAtPath:filePath isDirectory:&isDirectory] && !isDirectory) {
            if (block(filePath)) {
                NSError *error = nil;
                if (![fileManager removeItemAtPath:filePath error:&error]) {
                    [NSException raise:QTalkDiskCacheException format:@"%@", error];
                }
                
                NSString *directoryPath = [filePath stringByDeletingLastPathComponent];
                [self removeDirectoryIfEmpty:directoryPath];
            }
        }
    }
    dispatch_semaphore_signal(self.semaphore);
}

- (void)removeOldObjects
{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    static NSString *QTalkDiskCacheFilePathKey = @"QTalkDiskCacheFilePathKey";
    
    NSMutableArray *attributesArray = [@[] mutableCopy];
    for (NSString *filePath in [self validFilePathsUnderPath:self.rootPath]) {
        NSMutableDictionary *attributes = [[self attributesForFilePath:filePath] mutableCopy];
        [attributes setObject:filePath forKey:QTalkDiskCacheFilePathKey];
        [attributesArray addObject:attributes];
    }
    
    [attributesArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *date1 = [obj1 objectForKey:NSFileModificationDate];
        NSDate *date2 = [obj2 objectForKey:NSFileModificationDate];
        return [date2 compare:date1];
    }];
    
    NSInteger sum = 0;
    for (NSDictionary *attributes in [attributesArray copy]) {
        sum += [[attributes objectForKey:NSFileSize] integerValue];
        if (sum >= self.limitOfSize / 2) {
            break;
        }
        [attributesArray removeObject:attributes];
    }
    dispatch_semaphore_signal(self.semaphore);
    
    NSArray *filePathsToRemove = [attributesArray valueForKey:QTalkDiskCacheFilePathKey];
    [self removeObjectsUsingBlock:^BOOL(NSString *filePath) {
        return [filePathsToRemove containsObject:filePath];
    }];
}

- (NSDictionary *)attributesForFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSMutableDictionary *attributes = [[fileManager attributesOfItemAtPath:filePath error:&error] mutableCopy];
    if (error) {
        if (error.code == NSFileReadNoSuchFileError) {
            return nil;
        } else {
            [NSException raise:QTalkDiskCacheException format:@"%@", error];
        }
    }
    return attributes;
}

- (void)calculateCurrentSize
{
    [self.calculationQueue cancelAllOperations];
    [self.calculationQueue addOperationWithBlock:^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSInteger sum = 0;
        for (NSString *filePath in [self validFilePathsUnderPath:self.rootPath]) {
            NSDictionary *attributes = [self attributesForFilePath:filePath];
            sum += [[attributes objectForKey:NSFileSize] integerValue];
        }
        dispatch_semaphore_signal(self.semaphore);
        
        if (sum >= self.limitOfSize) {
            [self removeOldObjects];
        }
    }];
}

@end

@interface QIMUserCacheManager () <NSCacheDelegate>

@property (nonatomic, strong) YYMemoryCache *memoryCache;

@property (nonatomic, strong) YYCache *yyCacheManager;

@property (nonatomic, strong) QTalkUserCacheFileManager *userCacheFileManager;
@property (nonatomic, strong) NSMutableDictionary *appSettingCache;
@property (nonatomic, strong) NSArray *needSaveUserDefaultKeys;

@end

@implementation QIMUserCacheManager {

    NSUserDefaults *_appUserDefaults;
    dispatch_queue_t _save_cache_queue;
    void *_save_cache_queue_tag;
}

+ (instancetype)sharedInstance {
    static QIMUserCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QIMUserCacheManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _userCacheFileManager = [[QTalkUserCacheFileManager alloc] init];
        _appUserDefaults = [NSUserDefaults standardUserDefaults];
        _save_cache_queue = dispatch_queue_create("Save UserDefault Cache Queue", 0);
        _save_cache_queue_tag = &_save_cache_queue_tag;
        dispatch_queue_set_specific(_save_cache_queue, _save_cache_queue_tag, _save_cache_queue_tag, NULL);
    }
    return self;
}

- (void)chooseNewData:(BOOL)flag {
    [self.userCacheFileManager setNewData:flag];
}

- (NSString *)getQIMCacheName {
    if (!self.cacheName) {
        self.cacheName = @"APP";
    }
    return self.cacheName;
}

- (void)setCacheName:(NSString *)cacheName {
    if (cacheName.length > 0) {
        _cacheName = [cacheName lowercaseString];
        self.yyCacheManager = nil;
//        [self.userCacheFileManager setUserCachePath:cacheName];
//        [self.memoryCache removeAllObjects];
    } else {
        _cacheName = @"APP";
        self.yyCacheManager = nil;
        /*
        [self.userCacheFileManager setIsAPPCache:YES];
        [self.userCacheFileManager setUserCachePath:nil];
        [self.memoryCache removeAllObjects];
         */
    }
}

#pragma mark - setter and getter

- (NSMutableDictionary *)memoryObjectCount {
    
    if (!_memoryObjectCount) {
        _memoryObjectCount = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return _memoryObjectCount;
}

- (NSMutableDictionary *)writeObjectCount {
    if (!_writeObjectCount) {
        _writeObjectCount = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return _writeObjectCount;
}

- (NSMutableDictionary *)readObjectCount {
    if (!_readObjectCount) {
        _readObjectCount = [NSMutableDictionary dictionaryWithCapacity:20];
    }
    return _readObjectCount;
}

- (YYMemoryCache *)memoryCache {
    if (!_memoryCache) {
        _memoryCache = [[YYMemoryCache alloc] init];
        [_memoryCache setCountLimit:30];//内存最大缓存数据个数
        [_memoryCache setCostLimit:1*1024];//内存最大缓存开销 目前这个毫无用处
    }
    return _memoryCache;
}

- (YYCache *)yyCacheManager {
    if (!_yyCacheManager) {
        
        _yyCacheManager = [YYCache cacheWithName:[self getQIMCacheName]];
        [_yyCacheManager.memoryCache setCountLimit:100];//內存最大緩存數據個數
        [_yyCacheManager.diskCache setCostLimit:50*1024];//磁盤最大緩存開銷
        [_yyCacheManager.diskCache setCountLimit:100];//磁盤最大緩存數據個數
        [_yyCacheManager.diskCache setAutoTrimInterval:60];//設置磁盤lru動態清理頻率 默認 60秒
    }
    return _yyCacheManager;
}

- (NSMutableDictionary *)appSettingCache {
    if (!_appSettingCache.count) {
        id originUserSettingDict = [_appUserDefaults objectForKey:kUserCacheKey];
        if ([originUserSettingDict isKindOfClass:[NSDictionary class]]) {
            _appSettingCache = [NSMutableDictionary dictionaryWithDictionary:originUserSettingDict];
        }
        
        id originAppSettingDict = [_appUserDefaults objectForKey:kAppCacheKey];
        if ([originAppSettingDict isKindOfClass:[NSDictionary class]]) {
            _appSettingCache = [NSMutableDictionary dictionaryWithDictionary:originAppSettingDict];
        }
        
        if (!_appSettingCache) {
            _appSettingCache = [NSMutableDictionary dictionaryWithCapacity:20];
        }
    }
    return _appSettingCache;
}

- (NSArray *)needSaveUserDefaultKeys {
    if (!_needSaveUserDefaultKeys) {
        _needSaveUserDefaultKeys = @[@"kLastUserId", @"kFullUserJid", @"userToken", @"LoginType", @"kLastPassword", @"IM_LastLoginTime",@"ClientProtocol",@"firstLaunch", @"QC_CurrentNavDict", @"QC_NavAllDicts", @"newData", @"Users", @"NavConfigUpdateTime", @"kTempPassword", @"kTempUserToken", @"QCNavFailed", @"NavConfig", @"QChatCookie", @"AdvertConfig", @"AdvertConfigUpdateTime", @"lastAdShowTime", @"recordLogType", @"isInstruments", @"LastestLoginUser", @"NewClientConfigUpgrade", @"kRightCardRemindNotification", @"isLocalLogging", @"kUserWorkFeedEntrance", @"waterMarkState", @"qtalkFoundRNDebugUrl", @"qtalkSearchRNDebugUrl", @"opsFoundRNDebugUrl", @"forceOldSearch", @"updateAppVersion", @"AppPushToken"];
    }
    return _needSaveUserDefaultKeys;
}

#pragma mark - UserCache

- (void)saveUserDefault {

    dispatch_block_t saveUserDefaultBlock = ^{
        NSMutableDictionary *appSettingDict = [[NSMutableDictionary alloc] initWithDictionary:self.appSettingCache copyItems:YES];
        [_appUserDefaults setObject:appSettingDict forKey:kUserCacheKey];
#warning 下一版本迁移数据
        [_appUserDefaults setObject:appSettingDict forKey:kAppCacheKey];
        [_appUserDefaults synchronize];
    };
    if (dispatch_get_specific(_save_cache_queue_tag)) {
        saveUserDefaultBlock();
    } else {
        dispatch_sync(_save_cache_queue, ^{
            saveUserDefaultBlock();
        });
    }
}

- (BOOL)isNeedSaveUserDefaultKey:(NSString *)aKey {
    return [self.needSaveUserDefaultKeys containsObject:aKey] || [[self getQIMCacheName] isEqualToString:@"APP"];
}

- (BOOL)containsObjectForKey:(NSString *)key {
    if (key) {
        if ([self isNeedSaveUserDefaultKey:key]) {
            return [self.appSettingCache.allKeys containsObject:key];
        } else {
            return [self.yyCacheManager containsObjectForKey:key];
        }
    }
    return NO;
}

- (void)setUserObject:(id)object forKey:(nonnull NSString *)aKey{
    
    if (aKey && object) {
        if ([self isNeedSaveUserDefaultKey:aKey]) {
            [self.appSettingCache setObject:object forKey:aKey];
            [self saveUserDefault];
        } else {
            [self.yyCacheManager setObject:object forKey:aKey];
            /*
            NSInteger writeCount = [[self.writeObjectCount objectForKey:aKey] integerValue];
            writeCount ++;
            [self.writeObjectCount setObject:@(writeCount) forKey:aKey];
            
            [self.memoryCache setObject:object forKey:aKey];
            [self.userCacheFileManager setObject:object forKey:aKey];
             */
        }
    }
}

- (id)userObjectForKey:(nonnull NSString *)aKey{
    
    __block id returnObject = nil;
    if (aKey) {
        if ([self isNeedSaveUserDefaultKey:aKey]) {
            return [self.appSettingCache objectForKey:aKey];
        } else {
            
            return [self.yyCacheManager objectForKey:aKey];
            /*
            if ([self.memoryCache objectForKey:aKey]) {
            
                NSInteger memoryReadCount = [[self.memoryObjectCount objectForKey:aKey] integerValue];
                memoryReadCount ++;
                [self.memoryObjectCount setObject:@(memoryReadCount) forKey:aKey];
                
                return [self.memoryCache objectForKey:aKey];
            } else {
                
                NSInteger readCount = [[self.readObjectCount objectForKey:aKey] integerValue];
                readCount++;
                [self.readObjectCount setObject:@(readCount) forKey:aKey];
                
                id object = [self.userCacheFileManager objectForKey:aKey];
                if (object) {
                    [self.memoryCache setObject:object forKey:aKey];
                }
                return [self.userCacheFileManager objectForKey:aKey];
            }
            */
        }
    }
    return returnObject;
}

- (void)removeUserObjectForKey:(NSString *)aKey{
    
    if (aKey) {
        
        if ([self isNeedSaveUserDefaultKey:aKey]) {
            [self.appSettingCache removeObjectForKey:aKey];
            [self saveUserDefault];
        } else {
            
            [self.yyCacheManager removeObjectForKey:aKey];
            /*
            [self.memoryCache removeObjectForKey:aKey];
            [self.userCacheFileManager removeObjectForKey:aKey];
             */
        }
    }
}

- (void)clearUserCache {
    
    [self saveUserDefault];
    [self.memoryCache removeAllObjects];
    [self.yyCacheManager removeAllObjects];
    /*
    [self.userCacheFileManager removeOldObjects];
    [self.userCacheFileManager removeObjectsUsingBlock:^BOOL(NSString *filePath) {
        return YES;
    }];
     */
    [self removeUserDefaultFilePath];
    /*
    [self.appSettingCache removeAllObjects];
    [self.memoryCache removeAllObjects];
     */
}

- (void)removeUserDefaultFilePath {
    NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *userDefaultPath = [NSString stringWithFormat:@"%@/Preferences/%@", NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0], bundleId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:userDefaultPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:userDefaultPath error:nil];
    }
}

- (void)exportUserCache {
    
}

@end
