//
//  QIMKit+QIMUserCacheManager.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMUserCacheManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMUserCacheManager)

- (void)chooseNewData:(BOOL)flag {
    [[QIMUserCacheManager sharedInstance] chooseNewData:flag];
}

- (void)setCacheName:(NSString *)cacheName {
    [[QIMUserCacheManager sharedInstance] setCacheName:cacheName];
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return [[QIMUserCacheManager sharedInstance] containsObjectForKey:key];
}
- (void)setUserObject:(nullable id)object forKey:(nonnull NSString *)aKey {
    [[QIMUserCacheManager sharedInstance] setUserObject:object forKey:aKey];
}

- (nullable id)userObjectForKey:(nonnull NSString *)aKey {
    return [[QIMUserCacheManager sharedInstance] userObjectForKey:aKey];
}

- (void)removeUserObjectForKey:(nonnull NSString *)aKey {
    [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:aKey];
}

- (void)clearUserCache {
    [[QIMUserCacheManager sharedInstance] clearUserCache];
}

- (void)saveUserDefault {
    [[QIMUserCacheManager sharedInstance] saveUserDefault];
}

- (void)removeUserDefaultFilePath {
    [[QIMUserCacheManager sharedInstance] removeUserDefaultFilePath];
}

@end
