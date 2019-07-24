//
//  QIMKit+QIMShareExtension.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMShareExtension.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMShareExtension)

+ (BOOL) setUserName:(NSString *) username {
    return [QIMUUIDTools setUserName:username];
}

#pragma mark - 联系人列表

+ (NSString *) loginUserName {
    return [QIMUUIDTools loginUserName];
}

+ (NSData *)getHeadImageForUserId:(NSString *)userId {
    return [QIMUUIDTools getHeadImageForUserId:userId];
}

+ (BOOL) setHeadImage:(NSData *)headImage forUserId:(NSString *)userId {
    return [QIMUUIDTools setHeadImage:headImage forUserId:userId];
}

+ (BOOL) setSessionList:(NSData *)sessionList {
    return [QIMUUIDTools setUUIDToolsSessionList:sessionList];
}

+ (BOOL) setGroupSessionList:(NSData *)sessionList {
    return [QIMUUIDTools setUUIDToolsMyGroupList:sessionList];
}

+ (BOOL) setPeopleSessionList:(NSData *)sessionList {
    return [QIMUUIDTools setUUIDToolsFriendList:sessionList];
}

+ (BOOL) setRecentSharedList:(NSData *)recentSharedList {
    return [QIMUUIDTools setRecentSharedList:recentSharedList];
}

+ (NSData *)getSessionList {
    return [QIMUUIDTools getSessionList];
}

+ (NSData *)getGroupSessionList {
    return [QIMUUIDTools getMyGroupList];
}

+ (NSData *)getPeopleSessionList {
    return [QIMUUIDTools getFriendList];
}


+ (NSData *)getRecentSharedList {
    return [QIMUUIDTools getRecentSharedList];
}

+ (NSString *)stringFromKeyChainForKey:(NSString *)key {
    return nil;//qimsdktodo[QIMUUIDTools stringForKey:key];
}

@end
