//
//  QIMUserCacheManager.h
//  qunarChatIphone
//
//  Created by admin on 16/3/10.
//
//

#import <Foundation/Foundation.h>

@interface QIMUserCacheManager : NSObject

@property (nonatomic, strong) NSString * _Nonnull cacheName;

@property (nonatomic, strong) NSMutableDictionary * _Nonnull writeObjectCount;
@property (nonatomic, strong) NSMutableDictionary * _Nonnull readObjectCount;
@property (nonatomic, strong) NSMutableDictionary * _Nullable memoryObjectCount;

+ (nonnull QIMUserCacheManager *)sharedInstance;
- (void)chooseNewData:(BOOL)flag;

- (void)setCacheName:(NSString *)cacheName;

- (BOOL)containsObjectForKey:(NSString *)key;

- (void)setUserObject:(nullable id)object forKey:(nonnull NSString *)aKey;
- (nullable id)userObjectForKey:(nonnull NSString *)aKey;
- (void)removeUserObjectForKey:(nonnull NSString *)aKey;
- (void)clearUserCache;
- (void)saveUserDefault;

- (void)removeUserDefaultFilePath;

@end
