//
//  STIMManager+Session.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMManager+Session.h"
#import "STIMPrivateHeader.h"

@implementation STIMManager (Session)

- (NSString *)getCurrentSessionUserId {
    return self.currentSessionUserId;
}

- (NSArray *)getSessionList {
    
    NSArray *sessionList = [[IMDataManager stIMDB_SharedInstance] stIMDB_getSessionListWithSingleChatType:ChatType_SingleChat];
    return sessionList;
}

- (NSArray *)getNotReadSessionList {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReadSessionList];
}

- (NSArray *)getFullSessionList {
    NSArray *sessionList = [[IMDataManager stIMDB_SharedInstance] stIMDB_getFullSessionListWithSingleChatType:ChatType_SingleChat];
    return sessionList;
}

- (void)deleteSessionList {
    
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSessionList];
    [[IMDataManager stIMDB_SharedInstance] stIMDB_clearHistoryMsg];
    NSMutableDictionary *stickList = [NSMutableDictionary dictionaryWithDictionary:[[STIMManager sharedInstance] stickList]];
    NSMutableArray *deleteStickList = [NSMutableArray arrayWithCapacity:3];
    for (NSDictionary *tempStickDic in [stickList allValues]) {
        NSString *combineXmppId = [tempStickDic objectForKey:@"ConfigSubKey"];
        NSString *stickValue = [tempStickDic objectForKey:@"ConfigValue"];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setSTIMSafeObject:[self transformClientConfigKeyWithType:STIMClientConfigTypeKStickJidDic] forKey:@"key"];
        [dict setSTIMSafeObject:stickValue forKey:@"value"];
        [dict setSTIMSafeObject:combineXmppId forKey:@"subkey"];
        [deleteStickList addObject:dict];
    }
    [self updateRemoteClientConfigWithType:STIMClientConfigTypeKStickJidDic BatchProcessConfigInfo:deleteStickList WithDel:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListRemove object:nil];
}

- (void)removeSessionById:(NSString *)sid {
    
//    [self clearNotReadMsgByGroupId:sid];
//    [self clearNotReadMsgByJid:sid];
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSession:sid];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListRemove object:sid];
}

- (void)removeConsultSessionById:(NSString *)sid RealId:(NSString *)realJid {
    [self clearNotReadMsgByGroupId:sid];
    [self clearNotReadMsgByJid:sid];
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteSession:sid RealJid:realJid];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListRemove object:sid];
}

- (ChatType)getChatSessionTypeByXmppId:(NSString *)xmppId {
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        
    } else {
        NSArray *allhotlines = [self getAllHotLines];
        BOOL isConsult = [allhotlines containsObject:xmppId];
        if (isConsult == YES) {
            [self addConsultSessionById:xmppId ByRealJid:xmppId WithUserId:xmppId ByMsgId:nil WithOpen:YES WithLastUpdateTime:[[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] WithChatType:ChatType_Consult];
            return ChatType_Consult;
        } else {
            NSDictionary *chatInfo = [[IMDataManager stIMDB_SharedInstance] stIMDB_getChatSessionWithUserId:xmppId WithRealJid:xmppId];
            if (chatInfo) {
                return [[chatInfo objectForKey:@"ChatType"] integerValue];
            } else {
                [self addSessionByType:ChatType_SingleChat ById:xmppId ByMsgId:nil WithMsgTime:([NSDate date].timeIntervalSince1970 - self.serverTimeDiff) * 1000 WithNeedUpdate:YES];
                return ChatType_SingleChat;
            }
        }
    }
    return ChatType_SingleChat;
}

- (ChatType)openChatSessionByUserId:(NSString *)userId {
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        if ([userId hasPrefix:@"shop_"]) {
            NSString *realJid = @"";
            if (realJid) {
                [self addConsultSessionById:userId ByRealJid:userId WithUserId:userId ByMsgId:nil WithOpen:YES WithLastUpdateTime:[[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] WithChatType:ChatType_Consult];
                return ChatType_Consult;
            }
        }
        NSDictionary *sessionDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getChatSessionWithUserId:userId];
        if (sessionDic == nil) {
            [self addSessionByType:ChatType_SingleChat ById:userId ByMsgId:nil WithMsgTime:([NSDate date].timeIntervalSince1970 - self.serverTimeDiff) * 1000 WithNeedUpdate:YES];
            return ChatType_SingleChat;
        }
    } else {
        
        NSArray *allhotlines = [self getAllHotLines];
        BOOL isConsult = [allhotlines containsObject:userId];
        if (isConsult == YES) {
            [self addConsultSessionById:userId ByRealJid:userId WithUserId:userId ByMsgId:nil WithOpen:YES WithLastUpdateTime:[[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] WithChatType:ChatType_Consult];
            return ChatType_Consult;
        } else {
            NSDictionary *sessionDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getChatSessionWithUserId:userId];
            if (sessionDic == nil) {
                [self addSessionByType:ChatType_SingleChat ById:userId ByMsgId:nil WithMsgTime:([NSDate date].timeIntervalSince1970 - self.serverTimeDiff) * 1000 WithNeedUpdate:YES];
                return ChatType_SingleChat;
            }
        }
    }
    return ChatType_SingleChat;
}

- (void)openGroupSessionByGroupId:(NSString *)groupId ByName:(NSString *)name {
    
    NSDictionary *sessionDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getChatSessionWithUserId:groupId];
    if (sessionDic == nil) {
        
        [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:([NSDate date].timeIntervalSince1970 - self.serverTimeDiff) * 1000 WithNeedUpdate:YES];
    }
}

- (void)openChatSessionByUserId:(NSString *)userId ByRealJid:(NSString *)realJid WithChatType:(ChatType)chatType{
    if (chatType == ChatType_Consult || chatType == ChatType_ConsultServer) {
        [self addConsultSessionById:userId ByRealJid:realJid WithUserId:realJid ByMsgId:nil WithOpen:YES WithLastUpdateTime:[[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] WithChatType:chatType];
    }
}

- (void)addConsultSessionById:(NSString *)sessionId ByRealJid:(NSString *)realJid WithUserId:(NSString *)userId ByMsgId:(NSString *)msgId WithOpen:(BOOL)open WithLastUpdateTime:(long long)lastUpdateTime WithChatType:(ChatType)chatType{
    
    long long lastMsgTime = lastUpdateTime;
    if (lastMsgTime <= 0) {
        //无消息时间戳的会话插入到两天前（两天为拉历史的时间差）
        lastMsgTime = [[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] - 2 * 24 * 60 * 60 * 1000;
    }
    [[IMDataManager stIMDB_SharedInstance] stIMDB_insertSessionWithSessionId:sessionId WithUserId:userId WithLastMsgId:msgId WithLastUpdateTime:lastMsgTime ChatType:chatType WithRealJid:realJid];
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMVerboseLog(@"抛出通知 addConsultSessionById:(NSString *)sessionId ByRealJid:(NSString *)realJid WithUserId:(NSString *)userId ByMsgId:(NSString *)msgId WithOpen:(BOOL)open WithLastUpdateTime:(long long)lastUpdateTime WithChatType:(ChatType)chatType  kNotificationSessionListUpdate");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:sessionId userInfo:@{@"Open":@(open),@"RealJid":realJid?realJid:@""}];
    });
}

- (void)addSessionByType:(ChatType)type ById:(NSString *)jid ByMsgId:(NSString *)msgId WithMsgTime:(long long)msgTime WithNeedUpdate:(BOOL)needUpdate {
    if (jid.length) {
        if (msgId == nil) {
            msgId = [[IMDataManager stIMDB_SharedInstance] stIMDB_getLastMsgIdByJid:jid];
        }
        if (msgTime <= 0) {
            msgTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgTimeWithMsgId:msgId];
        }
        long long lastMsgTime = msgTime;
        if (lastMsgTime <= 0) {
            //无消息时间戳的会话插入到两天前（两天为拉历史的时间差）
            lastMsgTime = [[NSDate date] stimDB_timeIntervalSince1970InMilliSecond] - 2 * 24 * 60 * 60 * 1000;
        }
        [[IMDataManager stIMDB_SharedInstance] stIMDB_insertSessionWithSessionId:jid WithUserId:[[jid componentsSeparatedByString:@"@"] objectAtIndex:0] WithLastMsgId:msgId WithLastUpdateTime:lastMsgTime ChatType:type WithRealJid:jid];
        if (needUpdate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        }
    }
}

@end
