//
//  STIMKit+STIMClientConfig.h
//  STIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMClientConfig)

- (NSString *)transformClientConfigKeyWithType:(STIMClientConfigType)type;

- (NSString *)getClientConfigInfoWithType:(STIMClientConfigType)type WithSubKey:(NSString *)subKey;

- (NSArray *)getClientConfigInfoArrayWithType:(STIMClientConfigType)type;

- (NSArray *)getClientConfigInfoArrayWithType:(STIMClientConfigType *)type WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)getClientConfigValueArrayWithType:(STIMClientConfigType)type;

- (NSArray *)getClientConfigValueArrayWithType:(STIMClientConfigType)type WithDeleteFlag:(BOOL)deleteFlag;

- (void)insertNewClientConfigInfoWithData:(NSDictionary *)result;

- (BOOL)updateRemoteClientConfigWithType:(STIMClientConfigType)type BatchProcessConfigInfo:(NSArray *)configInfoArray WithDel:(BOOL)delFlag;

- (BOOL)updateRemoteClientConfigWithType:(STIMClientConfigType)type WithSubKey:(NSString *)subKey WithConfigValue:(NSString *)configValue WithDel:(BOOL)delFlag;

- (void)getRemoteClientConfig;

// ******************** 黑名单&星标联系人 ***************************//

//返回星标联系人或者黑名单用户
- (NSMutableArray *)selectStarOrBlackContacts:(NSString *)pkey;

//查询不在星标用户的好友
- (NSMutableArray *)selectFriendsNotInStarContacts;

//搜索不在星标里面的用户
- (NSMutableArray *)selectUserNotInStartContacts:(NSString *)key;

-(BOOL)isStarOrBlackContact:(NSString *)subkey ConfigKey:(NSString *)pkey;

-(BOOL)setStarOrblackContact:(NSString *)subkey ConfigKey:(NSString *)pkey Flag:(BOOL)value;

-(BOOL)setStarOrblackContacts:(NSDictionary *)map ConfigKey:(NSString *)pkey Flag:(BOOL)value;

/**
 客户端消息提示音

 @return 提示音soundName
 */
- (NSString *)getClientNotificationSoundName;

/**
 设置客户端消息提示音

 @param soundName 提示音文件名
 @return 是否设置成功
 */
- (BOOL)setClientNotificationSound:(NSString *)soundName;

@end
