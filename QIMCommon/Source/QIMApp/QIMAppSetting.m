//
//  QIMAppSetting.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMAppSetting.h"
#import "QIMPrivateHeader.h"

@interface QIMAppSetting ()

@property (nonatomic, assign) QIMAppConfigurationMode appConfigurationMode;

@end

@implementation QIMAppSetting

static QIMAppSetting *_appSetting = nil;
static NSString *MAPAPIKEY = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appSetting = [[QIMAppSetting alloc] init];
    });
    return _appSetting;
}

/**
 判断是否为第一次安装
 */
- (BOOL)isFirstLauched {
    NSString *AppBuildVersion = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"AppBuildVersion"];
    NSString *newAppBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (!AppBuildVersion || [AppBuildVersion compare:newAppBuildVersion options:NSNumericSearch] == NSOrderedAscending || ![AppBuildVersion isEqualToString:newAppBuildVersion]) {  //版本号对应不上，做强制数据兼容
        [[QIMUserCacheManager sharedInstance] clearUserCache];
//        [[QTalkUserCacheManager shareInstance] removeUserObjectForKey:@"NavConfig"];
    }
    QIMVerboseLog(@"App版本号 : %@", newAppBuildVersion);
    if (![[QIMUserCacheManager sharedInstance] userObjectForKey:@"everLaunched"] || !AppBuildVersion || [AppBuildVersion compare:newAppBuildVersion options:NSNumericSearch] == NSOrderedAscending || ![AppBuildVersion isEqualToString:newAppBuildVersion]) {
        QIMVerboseLog(@"用户第一次安装");
        
        [self moveUserCache];
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        path = [path stringByAppendingPathComponent:@"rnRes"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            QIMVerboseLog(@"RN包缓存存在");
        } else {
            QIMVerboseLog(@"RN包缓存不存在");
        }
        /*
        BOOL removeRNCache = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        if (removeRNCache) {
            QIMVerboseLog(@"清除RN包缓存成功");
        } else {
            QIMVerboseLog(@"清除RN包缓存失败");
        }
        */
        
        NSArray *oldLogPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *oldLogDirectory = [[oldLogPaths objectAtIndex:0] stringByAppendingPathComponent:@"Logs"];
        BOOL removeOldLog = [[NSFileManager defaultManager] removeItemAtPath:oldLogDirectory error:nil];
        if (removeOldLog) {
            QIMVerboseLog(@"清除旧日志缓存成功");
        } else {
            QIMVerboseLog(@"清除旧日志缓存失败");
        }
        
        //清空本地缓存的广告配置
        [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"AdvertConfig"];
        [[QIMUserCacheManager sharedInstance] clearUserCache];
        NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:@"emotionResource"];
        // 获取emotionDispPackageIdList文件路径
        NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",@"kEmotionDispPkIdListFileName"]];
        NSMutableArray *emotionDispPkIdList = [NSMutableArray arrayWithContentsOfFile:resourcePath];
        if (emotionDispPkIdList.count > 1) {
            //Comment by lilulucas.li
//            [self updateEmotionConfig];
        }
        //
        NSString *imageCachePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
        [[NSFileManager defaultManager] removeItemAtPath:imageCachePath error:nil];
        [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"NavConfig"];
//        [[QTalkUserCacheManager shareInstance] removeUserObjectForKey:@"QC_CurrentNavDict"];
        [[QIMUserCacheManager sharedInstance] setUserObject:@(YES) forKey:@"everLaunched"];
        [[QIMUserCacheManager sharedInstance] setUserObject:newAppBuildVersion forKey:@"AppBuildVersion"];
        [[QIMUserCacheManager sharedInstance] setUserObject:@(YES) forKey:@"firstLaunch"];
        if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
            [[QIMUserCacheManager sharedInstance] setUserObject:@(YES) forKey:@"notesFirstNotice"];
        }
        return YES;
    } else {
        QIMVerboseLog(@"用户非第一次安装");
        if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
            [[QIMUserCacheManager sharedInstance] setUserObject:@(NO) forKey:@"notesFirstNotice"];
        }
        [[QIMUserCacheManager sharedInstance] setUserObject:@(NO) forKey:@"firstLaunch"];
        return NO;
    }
    return NO;
}

- (void)moveUserCache {
    /*
     iOS系统在iOS11之后，如果App选择了Document目录共享，那么App的Document可以被用户肉眼可见，并分享到外部
     但如果我们的用户缓存放在Cache目录下，当手机存储空间不足时，iOS系统会自动清理一些App的Cache目录，这样可能会导致我们App出现很多问题。
     所以我们只能挨个将用户缓存从Cache目录move到Document目录，再对原文件进行remove操作
     可能会影响到App的缓存包括：
     1. 用户数据库文件
     2. 用户下载/更新的rn缓存包
     3. 用户的YYCache缓存文件(因为YYCache源码中缓存的路径就是Cache目录，因为我们这版本暂时不做处理)
     4. 用户缓存的证书文件（略）
     */
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    //RN包缓存文件
    NSString *rnOldPath = [cachePath stringByAppendingPathComponent:@"rnRes"];
    NSString *rnNewPath = [documentPath stringByAppendingPathComponent:@"rnRes"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:rnOldPath]) {
        NSError *error = nil;
        BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtPath:rnOldPath toPath:rnNewPath error:&error];
        if (moveSuccess == YES && error == nil) {
            [[NSFileManager defaultManager] removeItemAtURL:rnOldPath error:nil];
        } else {
            QIMVerboseLog(@"move RN缓存文件报错 : %@", error);
        }
    }
    
    //数据库文件缓存
    NSString *dbOldPath = [cachePath stringByAppendingPathComponent:@"QIMNewDataBase"];
    NSString *dbNewPath = [documentPath stringByAppendingPathComponent:@"QIMNewDataBase"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbOldPath]) {
        NSError *error = nil;
        BOOL moveSuccess = [[NSFileManager defaultManager] moveItemAtPath:dbOldPath toPath:dbNewPath error:&error];
        if (moveSuccess == YES && error == nil) {
            [[NSFileManager defaultManager] removeItemAtURL:dbOldPath error:nil];
        } else {
            QIMVerboseLog(@"move 数据库文件报错 : %@", error);
        }
    }    
}

/**
 判断是否为Debug模式
 */
- (BOOL)debugMode {
    BOOL debug = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_Debug"] boolValue];
    if (debug) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

- (void)setAppConfigurationMode:(QIMAppConfigurationMode)mode {
    _appConfigurationMode = mode;
}

- (QIMAppConfigurationMode)getCurrentAppConfigurationMode {
    return self.appConfigurationMode;
}

/**
 获取当前系统语言
 */
- (NSString *)currentLanguage {
    NSString *pfLanguageCode = [NSLocale preferredLanguages][0];
    return pfLanguageCode;
}

/**
 设置高德地图的Key
 */
- (void)setGAODE_APIKEY:(NSString *)key {
    MAPAPIKEY = key ? key : @"";
}

/**
 获取高德地图的Key
 */
- (NSString *)GAODE_APIKEY {
    return MAPAPIKEY;
}

@end
