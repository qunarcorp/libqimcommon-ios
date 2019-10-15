//
//  QIMManager+DB.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMManager+DB.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (DB)

- (NSString *)getDBPathWithUserXmppId:(NSString *)userJid {
    NSString *dbPath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/QIMNewDataBase/%@%@/", [userJid lowercaseString], UserPath]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //UrlWithString 会报CFURLSetResourcePropertyForKey failed because it was passed an URL which has no scheme 错误，使用fileURLWithPath正常
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[dbPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    dbPath = [dbPath stringByAppendingPathComponent:@"data.dat"];
    QIMVerboseLog(@"用户数据库路径为 %@", dbPath);
    return dbPath;
}

- (void)initDBWithUserXmppId:(NSString *)userJid {
    
    NSString *dbPath = [self getDBPathWithUserXmppId:userJid];
    [IMDataManager qimDB_sharedInstanceWithDBPath:dbPath withDBFullJid:userJid];
}

- (void)removeDataBase {
    //关闭数据库
    [[IMDataManager qimDB_SharedInstance] qimDB_closeDataBase];
    NSString *dbPath = [self getDBPathWithUserXmppId:[self getLastJid]];
    NSError *error = nil;
    if (dbPath && [[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
        if (removeSuccess) {
            QIMWarnLog(@"清楚用户数据库%@成功", dbPath);
        } else {
            QIMErrorLog(@"清楚用户数据库%@失败", dbPath);
        }
    } else {
        QIMErrorLog(@"用户数据库缓存文件不存在或为空 : %@", dbPath);
    }
    {
        //清理用户缓存信息
        [[QIMUserCacheManager sharedInstance] clearUserCache];
    }
}

- (void)closeDataBase {
    QIMErrorLog(@"关闭数据库");
    [[IMDataManager qimDB_SharedInstance] qimDB_closeDataBase];
}

- (void)clearDataBase {
    //清理数据库
    QIMErrorLog(@"清除数据库");
    [self removeDataBase];
    {
        //清理用户缓存信息
        QIMErrorLog(@"清理用户缓存信息");
        [[QIMUserCacheManager sharedInstance] clearUserCache];
        [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
    }
}

@end
