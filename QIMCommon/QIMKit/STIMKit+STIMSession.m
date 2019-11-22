//
//  STIMKit+STIMSession.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMKit+STIMSession.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMSession)

- (void)setCurrentSessionUserId:(NSString *)userId {
    [[STIMManager sharedInstance] setCurrentSessionUserId:userId];
}

- (NSString *)getCurrentSessionUserId {
    return [[STIMManager sharedInstance] getCurrentSessionUserId];
}

- (NSDictionary *)getLastedSingleChatSession {
    return nil;
}

- (NSArray *)getSessionList {
    
    return [[STIMManager sharedInstance] getSessionList];
}

- (NSArray *)getNotReadSessionList {
    return [[STIMManager sharedInstance] getNotReadSessionList];
}

- (void)deleteSessionList {
    [[STIMManager sharedInstance] deleteSessionList];
}

- (void)removeSessionById:(NSString *)sid {
    [[STIMManager sharedInstance] removeSessionById:sid];
}

- (void)removeConsultSessionById:(NSString *)sid RealId:(NSString *)realJid {
    [[STIMManager sharedInstance] removeConsultSessionById:sid RealId:realJid];
}

- (ChatType)getChatSessionTypeByXmppId:(NSString *)xmppId {
    return [[STIMManager sharedInstance] getChatSessionTypeByXmppId:xmppId];
}

- (ChatType)openChatSessionByUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] openChatSessionByUserId:userId];
}

- (void)openGroupSessionByGroupId:(NSString *)groupId ByName:(NSString *)name {
    [[STIMManager sharedInstance] openGroupSessionByGroupId:groupId ByName:name];
}

- (void)openChatSessionByUserId:(NSString *)userId ByRealJid:(NSString *)realJid WithChatType:(ChatType)chatType{
    [[STIMManager sharedInstance] openChatSessionByUserId:userId ByRealJid:realJid WithChatType:chatType];
}

- (void)addConsultSessionById:(NSString *)sessionId ByRealJid:(NSString *)realJid WithUserId:(NSString *)userId ByMsgId:(NSString *)msgId WithOpen:(BOOL)open WithLastUpdateTime:(long long)lastUpdateTime WithChatType:(ChatType)chatType{
    [[STIMManager sharedInstance] addConsultSessionById:sessionId ByRealJid:realJid WithUserId:userId ByMsgId:msgId WithOpen:open WithLastUpdateTime:lastUpdateTime WithChatType:chatType];
}

- (void)addSessionByType:(ChatType)type ById:(NSString *)jid ByMsgId:(NSString *)msgId WithMsgTime:(long long)msgTime WithNeedUpdate:(BOOL)needUpdate {
    [[STIMManager sharedInstance] addSessionByType:type ById:jid ByMsgId:msgId WithMsgTime:msgTime WithNeedUpdate:needUpdate];
}

@end
