//
//  QIMKit+QIMSession.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit+QIMSession.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMSession)

- (void)setCurrentSessionUserId:(NSString *)userId {
    [[QIMManager sharedInstance] setCurrentSessionUserId:userId];
}

- (NSString *)getCurrentSessionUserId {
    return [[QIMManager sharedInstance] getCurrentSessionUserId];
}

- (NSDictionary *)getLastedSingleChatSession {
    return nil;
}

- (NSArray *)getSessionList {
    
    return [[QIMManager sharedInstance] getSessionList];
}

- (NSArray *)getNotReadSessionList {
    return [[QIMManager sharedInstance] getNotReadSessionList];
}

- (void)deleteSessionList {
    [[QIMManager sharedInstance] deleteSessionList];
}

- (void)removeSessionById:(NSString *)sid {
    [[QIMManager sharedInstance] removeSessionById:sid];
}

- (void)removeConsultSessionById:(NSString *)sid RealId:(NSString *)realJid {
    [[QIMManager sharedInstance] removeConsultSessionById:sid RealId:realJid];
}

- (ChatType)getChatSessionTypeByXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getChatSessionTypeByXmppId:xmppId];
}

- (ChatType)openChatSessionByUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] openChatSessionByUserId:userId];
}

- (void)openGroupSessionByGroupId:(NSString *)groupId ByName:(NSString *)name {
    [[QIMManager sharedInstance] openGroupSessionByGroupId:groupId ByName:name];
}

- (void)openChatSessionByUserId:(NSString *)userId ByRealJid:(NSString *)realJid WithChatType:(ChatType)chatType{
    [[QIMManager sharedInstance] openChatSessionByUserId:userId ByRealJid:realJid WithChatType:chatType];
}

- (void)addConsultSessionById:(NSString *)sessionId ByRealJid:(NSString *)realJid WithUserId:(NSString *)userId ByMsgId:(NSString *)msgId WithOpen:(BOOL)open WithLastUpdateTime:(long long)lastUpdateTime WithChatType:(ChatType)chatType{
    [[QIMManager sharedInstance] addConsultSessionById:sessionId ByRealJid:realJid WithUserId:userId ByMsgId:msgId WithOpen:open WithLastUpdateTime:lastUpdateTime WithChatType:chatType];
}

- (void)addSessionByType:(ChatType)type ById:(NSString *)jid ByMsgId:(NSString *)msgId WithMsgTime:(long long)msgTime WithNeedUpdate:(BOOL)needUpdate {
    [[QIMManager sharedInstance] addSessionByType:type ById:jid ByMsgId:msgId WithMsgTime:msgTime WithNeedUpdate:needUpdate];
}

@end
