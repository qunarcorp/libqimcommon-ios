//
//  IQMessage+Utitly.m
//  qunarChatCommon
//
//  Created by admin on 10/14/16.
//  Copyright © 2016 May. All rights reserved.
//

#import "IQMessage+Utility.h"
#import "QIMPublicRedefineHeader.h"

NSString *getKeyForDefineKey(StringHeaderType type) {
    NSString *key = nil;
    switch (type) {
        case StringHeaderTypeStringHeaderTypeChatId:
            key = @"chatid";
            break;
        case StringHeaderTypeStringHeaderTypeChannelId:
            key = @"channelid";
            break;
        case StringHeaderTypeStringHeaderTypeExtendInfo:
            key = @"extendInfo";
            break;
        case StringHeaderTypeStringHeaderTypeBackupInfo:
            key = @"backupinfo";
            break;
        case StringHeaderTypeStringHeaderTypeReadType:
            key = @"read_type";
            break;
        case StringHeaderTypeStringHeaderTypeJid:
            key = @"jid";
            break;
        case StringHeaderTypeStringHeaderTypeRealJid:
            key = @"real_jid";
            break;
        case StringHeaderTypeStringHeaderTypeInviteJid:
            key = @"invite_jid";
            break;
        case StringHeaderTypeStringHeaderTypeDeleleJid:
            key = @"del_jid";
            break;
        case StringHeaderTypeStringHeaderTypeNick:
            key = @"nick";
            break;
        case StringHeaderTypeStringHeaderTypeTitle:
            key = @"title";
            break;
        case StringHeaderTypeStringHeaderTypePic:
            key = @"pic";
            break;
        case StringHeaderTypeStringHeaderTypeVersion:
            key = @"version";
            break;
        case StringHeaderTypeStringHeaderTypeMethod:
            key = @"method";
            break;
        case StringHeaderTypeStringHeaderTypeBody:
            key = @"body";
            break;
        case StringHeaderTypeStringHeaderTypeAffiliation:
            key = @"affiliation";
            break;
        case StringHeaderTypeStringHeaderTypeType:
            key = @"type";
            break;
        case StringHeaderTypeStringHeaderTypeResult:
            key = @"result";
            break;
        case StringHeaderTypeStringHeaderTypeReason:
            key = @"reason";
            break;
        case StringHeaderTypeStringHeaderTypeRole:
            key = @"role";
            break;
        case StringHeaderTypeStringHeaderTypeDomain:
            key = @"domain";
            break;
        case StringHeaderTypeStringHeaderTypeStatus:
            key = @"status";
            break;
        case StringHeaderTypeStringHeaderTypeCode:
            key = @"code";
            break;
        case StringHeaderTypeStringHeaderTypeCdata:
            key = @"cdata";
            break;
        case StringHeaderTypeStringHeaderTypeTimeValue:
            key = @"time_value";
            break;
        case StringHeaderTypeStringHeaderTypeKeyValue:
            key = @"key_value";
            break;
        case StringHeaderTypeStringHeaderTypeName:
            key = @"name";
            break;
        case StringHeaderTypeStringHeaderTypeHost:
            key = @"host";
            break;
        case StringHeaderTypeStringHeaderTypeQuestion:
            key = @"question";
            break;
        case StringHeaderTypeStringHeaderTypeAnswer:
            key = @"answer";
            break;
        case StringHeaderTypeStringHeaderTypeFriends:
            key = @"friends";
            break;
        case StringHeaderTypeStringHeaderTypeValue:
            key = @"value";
            break;
        case StringHeaderTypeStringHeaderTypeMaskedUuser:
            key = @"masked_user";
            break;
        case StringHeaderTypeStringHeaderTypeKey:
            key = @"key";
            break;
        case StringHeaderTypeStringHeaderTypeMode:
            key = @"mode";
            break;
        case StringHeaderTypeStringHeaderTypeCarbon:
            key = @"carbon_message";
            break;
        default:
            QIMVerboseLog(@"<========== 不认识的StringHeader DefineKey [%d] ==========>", type);
            break;
    }
    return key;
}

NSDictionary *getHeadersDicForHeaders(NSArray<StringHeader *> *headers) {
    if (headers.count > 0) {
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        for (StringHeader *header in headers) {
            NSString *key = nil;
            if (header.hasDefinedKey) {
                key = getKeyForDefineKey(header.definedKey);
            }
            if (key == nil) {
                key = header.key;
            }
            if (key) {
                [resultDic setObject:header.value forKey:key];
            }
        }
        return resultDic;
    }
    return nil;
}

static PBProtocol *__global_pbprotocol = nil;

@implementation PBProtocol

+ (PBProtocol *)sharedInstance {
    if (__global_pbprotocol == nil) {
        __global_pbprotocol = [[PBProtocol alloc] init];
#warning 切换 是否需要替换 DefineKey 节约内存
        [__global_pbprotocol setNeedReplaceDefineKey:YES];
    }
    return __global_pbprotocol;
}

@end

@implementation IQMessage (Utility)
- (NSDictionary *)getHeadersDicForHeaders:(NSArray<StringHeader *> *)headers {
    return getHeadersDicForHeaders(headers);
}

- (NSString *)key {
    NSString *newKey = nil;
    if (self.hasDefinedKey) {
        switch (self.definedKey) {
            case IQMessageKeyTypeIqkeyBind:
                newKey = @"BIND";
                break;
            case IQMessageKeyTypeIqkeyMucCreate:
                newKey = @"CREATE_MUC";
                break;
            case IQMessageKeyTypeIqkeyMucCreateV2:
                newKey = @"MUC_CREATE";
                break;
            case IQMessageKeyTypeIqkeyMucInviteV2:
                newKey = @"MUC_INVITE_V2";
                break;
            case IQMessageKeyTypeIqkeyGetMucUser:
                newKey = @"GET_MUC_USER";
                break;
            case IQMessageKeyTypeIqkeySetMucUser:
                newKey = @"SET_MUC_USER";
                break;
            case IQMessageKeyTypeIqkeyDelMucUser:
                newKey = @"DEL_MUC_USER";
                break;
            case IQMessageKeyTypeIqkeyAddUserSubscribe:
                newKey = @"ADD_USER_SUBSCRIBE";
                break;
            case IQMessageKeyTypeIqkeyDelUserSubscribe:
                newKey = @"DEL_USER_SUBSCRIBE";
                break;
            case IQMessageKeyTypeIqkeyGetVerifyFriendOpt:
                newKey = @"GET_USER_OPT";
                break;
            case IQMessageKeyTypeIqkeySetVerifyFriendOpt:
                newKey = @"SET_USER_OPT";
                break;
            case IQMessageKeyTypeIqkeyGetUserFriend:
                newKey = @"GET_USER_FRIEND";
                break;
            case IQMessageKeyTypeIqkeyGetUserKey:
                newKey = @"GET_USER_KEY";
                break;
            case IQMessageKeyTypeIqkeyGetUserMask:
                newKey = @"GET_USER_MASK";
                break;
            case IQMessageKeyTypeIqkeySetUserMask:
                newKey = @"SET_USER_MASK";
                break;
            case IQMessageKeyTypeIqkeyCancelUserMask:
                newKey = @"CANCEL_USER_MASK";
                break;
            case IQMessageKeyTypeIqkeySetAdmin:
                newKey = @"SET_ADMIN";
                break;
            case IQMessageKeyTypeIqkeySetMember:
                newKey = @"SET_MEMBER";
                break;
            case IQMessageKeyTypeIqkeyCancelMember:
                newKey = @"CANCEL_MEMBER";
                break;
            case IQMessageKeyTypeIqkeyGetUserMucs:
                newKey = @"USER_MUCS";
                break;
            case IQMessageKeyTypeIqkeyDestroyMuc:
                newKey = @"DESTROY_MUC";
                break;
            case IQMessageKeyTypeIqkeyPing:
                newKey = @"PING";
                break;
            case IQMessageKeyTypeIqkeyAddPush:
                newKey = @"ADD_PUSH";
                break;
            case IQMessageKeyTypeIqkeyCancelPush:
                newKey = @"CANCEL_PUSH";
                break;
            case IQMessageKeyTypeIqkeyResult:
                newKey = @"result";
                break;
            case IQMessageKeyTypeIqkeyError:
                newKey = @"error";
                break;
            case IQMessageKeyTypeIqkeyGetVuser:
                newKey = @"GET_VIRTUAL_USER";
                break;
            case IQMessageKeyTypeIqkeyGetVuserRole:
                newKey = @"GET_VIRTUAL_USER_ROLE";
                break;
            case IQMessageKeyTypeIqkeyStartSession:
                newKey = @"REAL_USER_START_SESSION";
                break;
            case IQMessageKeyTypeIqkeyEndSession:
                newKey = @"REAL_USER_END_SESSION";
                break;
            default:
                QIMVerboseLog(@"<========== 不认识的IQMessage DefineKey [%d] ==========>", self.definedKey);
                break;
        }
    }
    if (newKey) {
        return newKey;
    } else {
        return key;
    }
}
@end

@implementation XmppMessage (Utility)
- (NSDictionary *)getHeadersDicForHeaders:(NSArray<StringHeader *> *)headers {
    return getHeadersDicForHeaders(headers);
}
@end

@implementation PresenceMessage (Utility)
- (NSDictionary *)getHeadersDicForHeaders:(NSArray<StringHeader *> *)headers {
    return getHeadersDicForHeaders(headers);
}

- (NSString *)key {
    NSString *newKey = nil;
    if (self.hasDefinedKey) {
        switch (self.definedKey) {
            case PresenceKeyTypePresenceKeyPriority:
                newKey = @"priority";
                break;
            case PresenceKeyTypePresenceKeyVerifyFriend:
                newKey = @"verify_friend";
                break;
            case PresenceKeyTypePresenceKeyManualAuthenticationConfirm:
                newKey = @"manual_authentication_confirm";
                break;
            case PresenceKeyTypePresenceKeyResult:
                newKey = @"result";
                break;
            case PresenceKeyTypePresenceKeyNotify:
                newKey = @"notify";
                break;
            case PresenceKeyTypePresenceKeyError:
                newKey = @"error";
                break;
            default:
                QIMVerboseLog(@"<========== 不认识的PresenceMessage DefinedKey Key [%d] ==========>", (int)self.definedKey);
                break;
        }
    }
    if (newKey) {
        return newKey;
    } else {
        return key;
    }
}
@end

@implementation StringHeaderBuilder (Utility)
- (BOOL)updateDefineKeyForKey:(NSString *)key {
    if ([[PBProtocol sharedInstance] needReplaceDefineKey] == NO) {
        return NO;
    }
    if ([key isEqualToString:@"chatid"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeChatId];
        return YES;
    } else if ([key isEqualToString:@"channelid"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeChannelId];
        return YES;
    } else if ([key isEqualToString:@"extendInfo"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeExtendInfo];
        return YES;
    } else if ([key isEqualToString:@"backupinfo"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeBackupInfo];
        return YES;
    } else if ([key isEqualToString:@"read_type"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeReadType];
        return YES;
    } else if ([key isEqualToString:@"jid"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeJid];
        return YES;
    } else if ([key isEqualToString:@"real_jid"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeRealJid];
        return YES;
    } else if ([key isEqualToString:@"invite_jid"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeInviteJid];
        return YES;
    } else if ([key isEqualToString:@"del_jid"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeDeleleJid];
        return YES;
    } else if ([key isEqualToString:@"nick"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeNick];
        return YES;
    } else if ([key isEqualToString:@"title"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeTitle];
        return YES;
    } else if ([key isEqualToString:@"pic"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypePic];
        return YES;
    } else if ([key isEqualToString:@"version"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeVersion];
        return YES;
    } else if ([key isEqualToString:@"method"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeMethod];
        return YES;
    } else if ([key isEqualToString:@"body"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeBody];
        return YES;
    } else if ([key isEqualToString:@"affiliation"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeAffiliation];
        return YES;
    } else if ([key isEqualToString:@"type"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeType];
        return YES;
    } else if ([key isEqualToString:@"result"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeResult];
        return YES;
    } else if ([key isEqualToString:@"reason"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeReason];
        return YES;
    } else if ([key isEqualToString:@"role"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeRole];
        return YES;
    } else if ([key isEqualToString:@"domain"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeDomain];
        return YES;
    } else if ([key isEqualToString:@"status"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeStatus];
        return YES;
    } else if ([key isEqualToString:@"code"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeCode];
        return YES;
    } else if ([key isEqualToString:@"cdata"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeCdata];
        return YES;
    } else if ([key isEqualToString:@"time_value"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeTimeValue];
        return YES;
    } else if ([key isEqualToString:@"key_value"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeKeyValue];
        return YES;
    } else if ([key isEqualToString:@"name"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeName];
        return YES;
    } else if ([key isEqualToString:@"host"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeHost];
        return YES;
    } else if ([key isEqualToString:@"question"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeQuestion];
        return YES;
    } else if ([key isEqualToString:@"answer"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeAnswer];
        return YES;
    } else if ([key isEqualToString:@"friends"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeFriends];
        return YES;
    } else if ([key isEqualToString:@"value"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeValue];
        return YES;
    } else if ([key isEqualToString:@"masked_user"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeMaskedUuser];
        return YES;
    } else if ([key isEqualToString:@"key"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeKey];
        return YES;
    } else if ([key isEqualToString:@"mode"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeMode];
    } else if ([key isEqualToString:@"carbon_message"]) {
        [self setDefinedKey:StringHeaderTypeStringHeaderTypeCarbon];
    } else {
        QIMVerboseLog(@"<========== 不认识的StringHeader Key [%@] ==========>", key);
    }
    return NO;
}
@end

@implementation IQMessageBuilder (Utility)

- (BOOL)updateDefineKeyForKey:(NSString *)key {
    if ([[PBProtocol sharedInstance] needReplaceDefineKey] == NO) {
        return NO;
    }
    if ([key isEqualToString:@"BIND"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyBind];
        return YES;
    } else if ([key isEqualToString:@"CREATE_MUC"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyMucCreate];
        return YES;
    } else if ([key isEqualToString:@"MUC_CREATE"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyMucCreateV2];
        return YES;
    } else if ([key isEqualToString:@"MUC_INVITE_V2"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyMucInviteV2];
        return YES;
    } else if ([key isEqualToString:@"GET_MUC_USER"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetMucUser];
        return YES;
    } else if ([key isEqualToString:@"SET_MUC_USER"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeySetMucUser];
        return YES;
    } else if ([key isEqualToString:@"DEL_MUC_USER"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyDelMucUser];
        return YES;
    } else if ([key isEqualToString:@"ADD_USER_SUBSCRIBE"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyAddUserSubscribe];
        return YES;
    } else if ([key isEqualToString:@"DEL_USER_SUBSCRIBE"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyDelUserSubscribe];
        return YES;
    } else if ([key isEqualToString:@"GET_USER_SUBSCRIBE"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetUserSubScribe];
        return YES;
    } else if ([key isEqualToString:@"GET_USER_OPT"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetVerifyFriendOpt];
        return YES;
    } else if ([key isEqualToString:@"SET_USER_OPT"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeySetVerifyFriendOpt];
        return YES;
    } else if ([key isEqualToString:@"GET_USER_FRIEND"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetUserFriend];
        return YES;
    } else if ([key isEqualToString:@"DEL_USER_FRIEND"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyDelUserFriend];
        return YES;
    } else if ([key isEqualToString:@"GET_USER_KEY"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetUserKey];
        return YES;
    } else if ([key isEqualToString:@"GET_USER_MASK"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetUserMask];
        return YES;
    } else if ([key isEqualToString:@"SET_USER_MASK"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeySetUserMask];
        return YES;
    } else if ([key isEqualToString:@"CANCEL_USER_MASK"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyCancelUserMask];
        return YES;
    } else if ([key isEqualToString:@"SET_ADMIN"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeySetAdmin];
        return YES;
    } else if ([key isEqualToString:@"SET_MEMBER"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeySetMember];
        return YES;
    } else if ([key isEqualToString:@"CANCEL_MEMBER"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyCancelMember];
        return YES;
    } else if ([key isEqualToString:@"USER_MUCS"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetUserMucs];
        return YES;
    } else if ([key isEqualToString:@"DESTROY_MUC"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyDestroyMuc];
        return YES;
    } else if ([key isEqualToString:@"PING"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyPing];
        return YES;
    } else if ([key isEqualToString:@"ADD_PUSH"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyAddPush];
        return YES;
    } else if ([key isEqualToString:@"CANCEL_PUSH"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyCancelPush];
        return YES;
    } else if ([key isEqualToString:@"result"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyResult];
        return YES;
    } else if ([key isEqualToString:@"error"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyError];
        return YES;
    } else if ([key isEqualToString:@"GET_VIRTUAL_USER"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetVuser];
        return YES;
    } else if ([key isEqualToString:@"GET_VIRTUAL_USER_ROLE"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyGetVuserRole];
        return YES;
    } else if ([key isEqualToString:@"REAL_USER_START_SESSION"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyStartSession];
        return YES;
    } else if ([key isEqualToString:@"REAL_USER_END_SESSION"]) {
        [self setDefinedKey:IQMessageKeyTypeIqkeyEndSession];
        return YES;
    } else {
        QIMVerboseLog(@"<========== 不认识的IQMessage Key [%@] ==========>", key);
    }
    return NO;
}

@end

@implementation PresenceMessageBuilder (Utility)

- (BOOL)updateDefineKeyForKey:(NSString *)key {
    if ([[PBProtocol sharedInstance] needReplaceDefineKey] == NO) {
        return NO;
    }
    if ([key isEqualToString:@"priority"]) {
        [self setDefinedKey:PresenceKeyTypePresenceKeyPriority];
        return YES;
    } else if ([key isEqualToString:@"verify_friend"]) {
        [self setDefinedKey:PresenceKeyTypePresenceKeyVerifyFriend];
        return YES;
    } else if ([key isEqualToString:@"manual_authentication_confirm"]) {
        [self setDefinedKey:PresenceKeyTypePresenceKeyManualAuthenticationConfirm];
        return YES;
    } else if ([key isEqualToString:@"result"]) {
        [self setDefinedKey:PresenceKeyTypePresenceKeyResult];
        return YES;
    } else if ([key isEqualToString:@"error"]) {
        [self setDefinedKey:PresenceKeyTypePresenceKeyError];
        return YES;
    } else {
        QIMVerboseLog(@"<========== 不认识的PresenceMessage Key [%@] ==========>", key);
    }
    return NO;
}

@end

