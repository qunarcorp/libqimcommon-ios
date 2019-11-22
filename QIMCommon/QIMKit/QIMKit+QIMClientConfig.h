//
//  QIMKit+QIMClientConfig.h
//  QIMCommon
//
//  Created by 李露 on 2018/7/10.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit.h"

@interface QIMKit (QIMClientConfig)

- (NSString *)transformClientConfigKeyWithType:(QIMClientConfigType)type;

- (NSString *)getClientConfigInfoWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey;

- (NSArray *)getClientConfigInfoArrayWithType:(QIMClientConfigType)type;

- (NSArray *)getClientConfigInfoArrayWithType:(QIMClientConfigType *)type WithDeleteFlag:(BOOL)deleteFlag;

- (NSArray *)getClientConfigValueArrayWithType:(QIMClientConfigType)type;

- (NSArray *)getClientConfigValueArrayWithType:(QIMClientConfigType)type WithDeleteFlag:(BOOL)deleteFlag;

- (void)insertNewClientConfigInfoWithData:(NSDictionary *)result;

- (void)updateRemoteClientConfigWithType:(QIMClientConfigType)type BatchProcessConfigInfo:(NSArray *)configInfoArray WithDel:(BOOL)delFlag withCallback:(QIMKitUpdateRemoteClientConfig)callback;

- (void)updateRemoteClientConfigWithType:(QIMClientConfigType)type WithSubKey:(NSString *)subKey WithConfigValue:(NSString *)configValue WithDel:(BOOL)delFlag withCallback:(QIMKitUpdateRemoteClientConfig)callback;

- (void)getRemoteClientConfig;

// ******************** 黑名单&星标联系人 ***************************//

//返回星标联系人或者黑名单用户
- (NSMutableArray *)selectStarOrBlackContacts:(NSString *)pkey;

//查询不在星标用户的好友
- (NSMutableArray *)selectFriendsNotInStarContacts;

//搜索不在星标里面的用户
- (NSMutableArray *)selectUserNotInStartContacts:(NSString *)key;

-(BOOL)isStarOrBlackContact:(NSString *)subkey ConfigKey:(NSString *)pkey;

- (void)setStarOrblackContact:(NSString *)subkey ConfigKey:(NSString *)pkey Flag:(BOOL)value withCallback:(QIMKitUpdateRemoteClientConfig)callback;

- (void)setStarOrblackContacts:(NSDictionary *)map ConfigKey:(NSString *)pkey Flag:(BOOL)value withCallback:(QIMKitUpdateRemoteClientConfig)callback;

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
- (void)setClientNotificationSound:(NSString *)soundName withCallback:(QIMKitUpdateRemoteClientConfig)callback;

@end
