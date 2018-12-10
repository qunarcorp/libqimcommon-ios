//
//  Message.m
//  qunarChatMac
//
//  Created by ping.xue on 14-2-28.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "QIMMessage.h"
#import "QIMPrivateHeader.h"

#define kMessageData            @"kMessageData"
#define kLastLoginUserName      @"kLastLoginUserName"
#define kLastLoginPwd           @"kLastLoginPwd"
#define kLastIMLoginUserName    @"kLastIMLoginUserName"
#define kLastIMLoginPwdToken    @"kLastIMLoginPwdToken"

static UIFont *__global_font = nil;

@implementation ChatSession

- (NSString *)userName{
    if (_userName == nil) {
        [self setUserName:self.userId];
    }
    return _userName;
}

- (void)dealloc{
    [self setSessionId:nil];
    [self setLastMsgId:nil];
    [self setMsgContent:nil];
}

@end

@implementation Message

- (NSDictionary *)getMsgInfoDic{
    NSData *data = [self.message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
    return infoDic;
}

- (NSString *)messageId{
    if (_messageId == nil) {
        [self setMessageId:[QIMHttpApi UUID]];
    }
    return _messageId;
}

- (NSString *)description{
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

- (void)dealloc{
    
    [self setMessageId:nil];
    [self setTo:nil];
    [self setFrom:nil];
    [self setMessage:nil];
    [self setResolveStr:nil];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Message class]]) {
        if ([self.messageId isEqualToString:[object messageId]]) {
            return YES;
        } else if([object isKindOfClass:[NSString class]]) {
            if ([self.messageId isEqualToString:object]) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"message" : @"MessageBody",
             @"to" : @"ToJid",
             @"messageId" : @"MessageId",
             @"messageType" : @"MessageType",
             @"extendInformation" : @"MessageExtendInfo",
             @"backupInfo" : @"MessageBackUpInfo",
             @"channelInfo" : @"MessageChannelInfo",
             @"chatId" : @"MessageChatId",
             @"appendInfoDict" : @"MessageAppendInfoDict"
             };
}

@end

