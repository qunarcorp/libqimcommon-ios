//
//  STIMKit+STIMClientConfig.m
//  STIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMClientConfig.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMClientConfig)

- (NSString *)transformClientConfigKeyWithType:(STIMClientConfigType)type {
    return [[STIMManager sharedInstance] transformClientConfigKeyWithType:type];
}

- (NSString *)getClientConfigInfoWithType:(STIMClientConfigType)type WithSubKey:(NSString *)subKey {
    return [[STIMManager sharedInstance] getClientConfigInfoWithType:type WithSubKey:subKey];
}

- (NSArray *)getClientConfigInfoArrayWithType:(STIMClientConfigType)type {
    return [[STIMManager sharedInstance] getClientConfigInfoArrayWithType:type];
}

- (NSArray *)getClientConfigInfoArrayWithType:(STIMClientConfigType *)type WithDeleteFlag:(BOOL)deleteFlag {
    return [[STIMManager sharedInstance] getClientConfigInfoArrayWithType:type WithDeleteFlag:deleteFlag];
}

- (NSArray *)getClientConfigValueArrayWithType:(STIMClientConfigType)type {
    return [[STIMManager sharedInstance] getClientConfigValueArrayWithType:type];
}

- (NSArray *)getClientConfigValueArrayWithType:(STIMClientConfigType)type WithDeleteFlag:(BOOL)deleteFlag {
    return [[STIMManager sharedInstance] getClientConfigValueArrayWithType:type WithDeleteFlag:deleteFlag];
}

- (void)insertNewClientConfigInfoWithData:(NSDictionary *)result {
    [[STIMManager sharedInstance] insertNewClientConfigInfoWithData:result];
}

- (BOOL)updateRemoteClientConfigWithType:(STIMClientConfigType)type BatchProcessConfigInfo:(NSArray *)configInfoArray WithDel:(BOOL)delFlag {
    return [[STIMManager sharedInstance] updateRemoteClientConfigWithType:type BatchProcessConfigInfo:configInfoArray WithDel:delFlag];
}

- (BOOL)updateRemoteClientConfigWithType:(STIMClientConfigType)type WithSubKey:(NSString *)subKey WithConfigValue:(NSString *)configValue WithDel:(BOOL)delFlag {
    return [[STIMManager sharedInstance] updateRemoteClientConfigWithType:type WithSubKey:subKey WithConfigValue:configValue WithDel:delFlag];
}

- (void)getRemoteClientConfig {
    [[STIMManager sharedInstance] getRemoteClientConfig];
}

//返回星标联系人或者黑名单用户
- (NSMutableArray *)selectStarOrBlackContacts:(NSString *)pkey {
    return [[STIMManager sharedInstance] selectStarOrBlackContacts:pkey];
}

//查询不在星标用户的好友
- (NSMutableArray *)selectFriendsNotInStarContacts {
    return [[STIMManager sharedInstance] selectFriendsNotInStarContacts];
}

//搜索不在星标里面的用户
- (NSMutableArray *)selectUserNotInStartContacts:(NSString *)key {
    return [[STIMManager sharedInstance] selectUserNotInStartContacts:key];
}

- (BOOL)isStarOrBlackContact:(NSString *)subkey ConfigKey:(NSString *)pkey{
    return [[STIMManager sharedInstance] isStarOrBlackContact:subkey ConfigKey:pkey];
}

- (BOOL)setStarOrblackContact:(NSString *)subkey ConfigKey:(NSString *)pkey Flag:(BOOL)value {
    return [[STIMManager sharedInstance] setStarOrblackContact:subkey ConfigKey:pkey Flag:value];
}

- (BOOL)setStarOrblackContacts:(NSDictionary *)map ConfigKey:(NSString *)pkey Flag:(BOOL)value{
    return [[STIMManager sharedInstance] setStarOrblackContacts:map ConfigKey:pkey Flag:value];
}

/**
 客户端消息提示音

 @return 提示音soundName
 */
- (NSString *)getClientNotificationSoundName {
    return [[STIMManager sharedInstance] getClientNotificationSoundName];
}

/**
 设置客户端消息提示音

 @param soundName 提示音文件名
 @return 是否设置成功
 */
- (BOOL)setClientNotificationSound:(NSString *)soundName {
    return [[STIMManager sharedInstance] setClientNotificationSound:soundName];
}

@end
