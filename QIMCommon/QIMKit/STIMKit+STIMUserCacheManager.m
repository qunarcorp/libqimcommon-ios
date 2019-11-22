//
//  STIMKit+STIMUserCacheManager.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMUserCacheManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMUserCacheManager)

- (void)chooseNewData:(BOOL)flag {
    [[STIMUserCacheManager sharedInstance] chooseNewData:flag];
}

- (void)setCacheName:(NSString *)cacheName {
    [[STIMUserCacheManager sharedInstance] setCacheName:cacheName];
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return [[STIMUserCacheManager sharedInstance] containsObjectForKey:key];
}
- (void)setUserObject:(nullable id)object forKey:(nonnull NSString *)aKey {
    [[STIMUserCacheManager sharedInstance] setUserObject:object forKey:aKey];
}

- (nullable id)userObjectForKey:(nonnull NSString *)aKey {
    return [[STIMUserCacheManager sharedInstance] userObjectForKey:aKey];
}

- (void)removeUserObjectForKey:(nonnull NSString *)aKey {
    [[STIMUserCacheManager sharedInstance] removeUserObjectForKey:aKey];
}

- (void)clearUserCache {
    [[STIMUserCacheManager sharedInstance] clearUserCache];
}

- (void)saveUserDefault {
    [[STIMUserCacheManager sharedInstance] saveUserDefault];
}

- (void)removeUserDefaultFilePath {
    [[STIMUserCacheManager sharedInstance] removeUserDefaultFilePath];
}

@end
