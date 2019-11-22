//
//  STIMKit+STIMShareExtension.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMShareExtension.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMShareExtension)

+ (BOOL) setUserName:(NSString *) username {
    return [STIMUUIDTools setUserName:username];
}

#pragma mark - 联系人列表

+ (NSString *) loginUserName {
    return [STIMUUIDTools loginUserName];
}

+ (NSData *)getHeadImageForUserId:(NSString *)userId {
    return [STIMUUIDTools getHeadImageForUserId:userId];
}

+ (BOOL) setHeadImage:(NSData *)headImage forUserId:(NSString *)userId {
    return [STIMUUIDTools setHeadImage:headImage forUserId:userId];
}

+ (BOOL) setSessionList:(NSData *)sessionList {
    return [STIMUUIDTools setUUIDToolsSessionList:sessionList];
}

+ (BOOL) setGroupSessionList:(NSData *)sessionList {
    return [STIMUUIDTools setUUIDToolsMyGroupList:sessionList];
}

+ (BOOL) setPeopleSessionList:(NSData *)sessionList {
    return [STIMUUIDTools setUUIDToolsFriendList:sessionList];
}

+ (BOOL) setRecentSharedList:(NSData *)recentSharedList {
    return [STIMUUIDTools setRecentSharedList:recentSharedList];
}

+ (NSData *)getSessionList {
    return [STIMUUIDTools getSessionList];
}

+ (NSData *)getGroupSessionList {
    return [STIMUUIDTools getMyGroupList];
}

+ (NSData *)getPeopleSessionList {
    return [STIMUUIDTools getFriendList];
}


+ (NSData *)getRecentSharedList {
    return [STIMUUIDTools getRecentSharedList];
}

+ (NSString *)stringFromKeyChainForKey:(NSString *)key {
    return nil;//qimsdktodo[STIMUUIDTools stringForKey:key];
}

@end
