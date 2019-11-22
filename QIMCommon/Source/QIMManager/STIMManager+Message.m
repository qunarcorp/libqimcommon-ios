//
//  STIMManager+Message.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "STIMManager+Message.h"
#import "NSDate+STIMCategory.h"

#import <objc/runtime.h>
#import "STIMPrivateHeader.h"

@implementation STIMManager (Message)

#pragma mark - setter and getter

//各业务线或部门追加信息
- (void)setAppendInfoDic:(NSMutableDictionary *)appendInfoDic {
    objc_setAssociatedObject(self, "appendInfoDic", appendInfoDic, OBJC_ASSOCIATION_COPY);
}

- (NSMutableDictionary *)appendInfoDic {
    NSMutableDictionary *appendInfoDic = objc_getAssociatedObject(self, "appendInfoDic");
    if (!appendInfoDic) {
        appendInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return appendInfoDic;
}

//渠道信息
- (void)setChannelInfoDic:(NSMutableDictionary *)channelInfoDic {
    objc_setAssociatedObject(self, "channelInfoDic", channelInfoDic, OBJC_ASSOCIATION_COPY);
}

- (NSMutableDictionary *)channelInfoDic {
    NSMutableDictionary *channelInfoDic = objc_getAssociatedObject(self, "channelInfoDic");
    if (!channelInfoDic) {
        channelInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return channelInfoDic;
}

//会话参数
- (void)setConversationParamDic:(NSMutableDictionary *)conversationParamDic {
    objc_setAssociatedObject(self, "conversationParamDic", conversationParamDic, OBJC_ASSOCIATION_COPY);
}

- (NSMutableDictionary *)conversationParamDic {
    NSMutableDictionary *conversationParamDic = objc_getAssociatedObject(self, "conversationParamDic");
    if (!conversationParamDic) {
        conversationParamDic = [NSMutableDictionary dictionaryWithDictionary:[[STIMUserCacheManager sharedInstance] userObjectForKey:kConversationParamDic]];
    }
    return conversationParamDic;
}

//会话ChatId
- (void)setChatIdInfoDic:(NSMutableDictionary *)chatIdInfoDic {
    objc_setAssociatedObject(self, "chatIdInfoDic", chatIdInfoDic, OBJC_ASSOCIATION_COPY);
}

- (NSMutableDictionary *)chatIdInfoDic {
    NSMutableDictionary *chatIdInfoDic = objc_getAssociatedObject(self, "chatIdInfoDic");
    if (!chatIdInfoDic) {
        chatIdInfoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return chatIdInfoDic;
}

/**
 根据用户Id设置Message附加属性 {'cctext', 'bu'}
 
 @param appendInfoDict 附加字典
 @param userId 用户Id
 */
- (void)setAppendInfo:(NSDictionary *)appendInfoDict ForUserId:(NSString *)userId {
    if (appendInfoDict.count > 0 && userId) {
        NSMutableDictionary *userAppendInfoDict = [NSMutableDictionary dictionaryWithDictionary:[self getAppendInfoForUserId:userId]];
        if (!userAppendInfoDict) {
            userAppendInfoDict = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        for (NSString *appendInfoKey in appendInfoDict) {
            id appendInfoObject = [appendInfoDict objectForKey:appendInfoKey];
            [userAppendInfoDict setObject:appendInfoObject forKey:appendInfoKey];
        }
        [self.appendInfoDic setObject:userAppendInfoDict forKey:userId];
        [[STIMUserCacheManager sharedInstance] setUserObject:self.appendInfoDic forKey:kAppendInfoDic];
    }
}

/**
 根据用户Id获取Message附加属性  {'cctext', 'bu'}
 
 @param userId 用户Id
 */
- (NSDictionary *)getAppendInfoForUserId:(NSString *)userId {
    
    return [self.appendInfoDic objectForKey:userId];
}


/**
 根据用户Id设置ChannelId
 
 @param channelId channelId
 @param userId 用户Id
 */
- (void)setChannelInfo:(NSString *)channelId ForUserId:(NSString *)userId {
    if (channelId && userId) {
        [self.channelInfoDic setObject:channelId forKey:userId];
        [[STIMUserCacheManager sharedInstance] setUserObject:self.channelInfoDic forKey:kChannelInfoDic];
    }
}

/**
 根据用户Id获取ChannelId
 
 @param userId 用户Id
 */
- (NSString *)getChancelInfoForUserId:(NSString *)userId {
    NSString *chanelId = [self.channelInfoDic objectForKey:userId];
    if (chanelId.length > 0) {
        NSMutableDictionary *channelInfoDic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [[STIMJSONSerializer sharedInstance] deserializeObject:chanelId error:nil];
        if (dic) {
            [channelInfoDic setDictionary:dic];
        }
        [channelInfoDic setObject:@"sent" forKey:@"d"];
        NSString *channelInfo = [[STIMJSONSerializer sharedInstance] serializeObject:channelInfoDic];
        return channelInfo;
    }
    return nil;
}

/**
 根据用户Id获取ChannelId
 
 @param userId 用户Id
 */
- (void)setConversationParam:(NSDictionary *)param WithJid:(NSString *)jid {
    if (!self.conversationParamDic) {
        self.conversationParamDic = [NSMutableDictionary dictionaryWithDictionary:[[STIMUserCacheManager sharedInstance] userObjectForKey:kConversationParamDic]];
    }
    if (!jid || !param.count) {
        return;
    } else {
        [self.conversationParamDic setObject:param forKey:jid];
        NSString *key = kConversationParamDic;
        NSString *value = [[STIMJSONSerializer sharedInstance] serializeObject:self.conversationParamDic];
        if (key && value) {
            /* 暂时注释 18.8.03
            BOOL success = [self setConfigForKeyValues:@[@{@"key": key, @"value": value, @"d":[[XmppImManager sharedInstance] domain]}]];
            if (success) {
                [[STIMUserCacheManager sharedInstance] setUserObject:self.conversationParamDic forKey:kConversationParamDic];
                STIMVerboseLog(@"抛出通知 setConversationParam:  kNotificationSessionListUpdate");
            }
            */
        }
    }
}


/**
 根据用户Id设置ChatId

 @param chatId chatId区分Consult类型
 @param userId 用户Id
 */
- (void)saveChatId:(NSString *)chatId ForUserId:(NSString *)userId {
    
    if (chatId.length > 0 && userId.length > 0) {
        
        NSString *key = [userId componentsSeparatedByString:@"@"].firstObject;
        NSString *oldChatId = [self.chatIdInfoDic objectForKey:key];
        if ([oldChatId isEqualToString:chatId] == NO) {
            
            [self.chatIdInfoDic setObject:chatId forKey:key];
            [[STIMUserCacheManager sharedInstance] setUserObject:self.chatIdInfoDic forKey:kChatIdInfoDic];
        }
    }
}

/**
 根据用户Id获取ChatId

 @param userId 用户Id
 */
- (NSString *)getChatIdByUserId:(NSString *)userId {
    
    return [self.chatIdInfoDic objectForKey:[userId componentsSeparatedByString:@"@"].firstObject];
}

/**
 根据用户Id获取 点击聊天内容中的URL务必拼接的参数 （众包需求）
 
 @param param param
 @param jid 用户Id
 */
- (NSDictionary *)conversationParamWithJid:(NSString *)jid {
    if (!self.conversationParamDic) {
        self.conversationParamDic = [NSMutableDictionary dictionaryWithDictionary:[[STIMUserCacheManager sharedInstance] userObjectForKey:@"kConversationParamDic"]];
    }
    NSDictionary *dict = [self.conversationParamDic objectForKey:jid];
    return dict;
}

#pragma mark - CreateMsg

/**
 创建消息字典
 
 @param messageId 消息Id
 @param message 消息Body
 @param toJid 接收方
 @param msgType 消息Type
 @return 消息字典
 */
- (NSDictionary *)createMessageDictWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)toJid messageType:(STIMMessageType)msgType {
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [msgDict setObject:messageId?messageId:[STIMUUIDTools UUID] forKey:@"MessageId"];
    [msgDict setObject:message forKey:@"MessageBody"];
    [msgDict setObject:@(msgType) forKey:@"MessageType"];
    [msgDict setObject:toJid forKey:@"ToJid"];
    return msgDict;
}

- (NSString *)getChatTypeStr:(ChatType)chatType {
    switch (chatType) {
        case ChatType_SingleChat: {
            return @"chat";
        }
            break;
        case ChatType_GroupChat: {
            return @"groupchat";
        }
            break;
        case ChatType_Consult:
        case ChatType_ConsultServer: {
            return @"consult";
        }
        default: {
            return nil;
        }
            break;
    }
}

/**
 创建消息字典
 
 @param message 消息Message
 @return Model Message转出来的字典
 */
- (NSDictionary *)createMessageDictWithMessage:(STIMMessageModel *)message {
    
    NSDictionary *msgDict = [message yy_modelToJSONObject];
    return msgDict;
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType {
    
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:nil];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType backinfo:(NSString *)backInfo {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setBackupInfo:backInfo];
    [mesg setFrom:[[STIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:nil];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:userId];
    }
    [mesg setMessageDate:msgDate];
    [mesg setMessageSendState:STIMMessageSendState_Waiting];
    [mesg setExtendInformation:extendInfo];
    [self saveMsg:mesg ByJid:userId];
    return mesg;
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId {
    
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId willSave:YES];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:nil userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId msgState:(STIMMessageSendState)msgState willSave:(BOOL)willSave {
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:mId.length ? mId : [STIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setFrom:[[STIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:realJid];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:realJid?realJid:userId];
    }
//    if (userType == ChatType_GroupChat) {
//        [mesg setNickName:[[STIMManager sharedInstance] getLastJid]];
//    }
    [mesg setMessageDate:msgDate];
    if (msgState) {
        [mesg setMessageSendState:msgState];
    } else {
        [mesg setMessageSendState:STIMMessageSendState_Waiting];
    }
    [mesg setExtendInformation:extendInfo];
    if (willSave) {
        [self saveMsg:mesg ByJid:userId];
    }
    return mesg;
}

- (STIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(STIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:mId.length ? mId : [STIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setXmppId:userId];
    [mesg setFrom:[[STIMManager sharedInstance] getLastJid]];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:realJid?realJid:userId];
    }
    [mesg setMessageDate:msgDate];
    [mesg setMessageSendState:STIMMessageSendState_Waiting];
    [mesg setExtendInformation:extendInfo];
    if (willSave) {
        [self saveMsg:mesg ByJid:userId];
    }
    return mesg;
}

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [sharedHTTPCookieStorage cookies]) {
        [sharedHTTPCookieStorage deleteCookie:cookie];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/nck/send_wlan_msg.qunar", [self getWlanRequestURL]]];
    [self loadWlanCookie];
    
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *key = [self getWlanKeyByTime:time];
    NSString *params = nil;
    BOOL isGroup = [targetID rangeOfString:@"conference."].location != NSNotFound;
    NSMutableDictionary *resultParams = [NSMutableDictionary dictionary];
    
    [resultParams setSTIMSafeObject:content forKey:@"body"];
    [resultParams setSTIMSafeObject:[[STIMManager sharedInstance] getLastJid] forKey:@"from"];
    NSDictionary *channelId = @{@"cn":@"consult", @"d":@"send", @"usrType":@"usr"};
    [resultParams setSTIMSafeObject:@[@{@"user" : targetID}] forKey:@"to"];
    [resultParams setSTIMSafeObject:[NSString stringWithFormat:@"%d", msgType] forKey:@"msg_type"];
    //    [resultParams setSTIMSafeObject:@"groupchat" forKey:@"type"];
    [resultParams setSTIMSafeObject:key forKey:@"key"];
    [resultParams setSTIMSafeObject:[NSString stringWithFormat:@"%d", time] forKey:@"count"];
    [resultParams setSTIMSafeObject:extendInfo?extendInfo:@"" forKey:@"extend_info"];
    
    if (isGroup) {
        //群聊
        [resultParams setSTIMSafeObject:@"groupchat" forKey:@"type"];
        
    } else {
        [resultParams setSTIMSafeObject:@"chat" forKey:@"type"];
    }
    
    NSString *paramsStr = [[STIMJSONSerializer sharedInstance] serializeObject:@[resultParams]];
    STIMVerboseLog(@"快捷回复 URL : %@, 参数 : %@", url, paramsStr);
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[resultParams] options:NSJSONWritingPrettyPrinted error:&error];
    params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *cookieProperties = [[NSMutableDictionary alloc] init];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    [request setHTTPRequestHeaders:cookieProperties];
    
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        STIMInfoLog(@"快捷回复返回结果： %@", response);
    } failure:^(NSError *error) {
        STIMErrorLog(@"快捷回复错误 : %@", error);
    }];
}
 
#pragma mark - SendMsg

/**
 发送单人Typing消息
 
 @param userId 接收方Id
 */
- (void)sendTypingToUserId:(NSString *)userId {
    
    [[XmppImManager sharedInstance] sendTypingToUserId:userId];
}

/**
 发送单人窗口抖动消息
 
 @param userId 接收方Id
 */
- (STIMMessageModel *)sendShockToUserId:(NSString *)userId {
    [self shockWindow];
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    NSString *userName = nil;
    NSDictionary *userInfo = [self getUserInfoByUserId:userId];
    if (userInfo) {
        userName = [userInfo objectForKey:@"Name"];
    }
    if (userName == nil) {
        userName = [[userId componentsSeparatedByString:@"@"] objectAtIndex:0];
    }
    
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setMessageType:STIMMessageType_Shock];
    [mesg setTo:userId];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:[NSString stringWithFormat:@"%@给您发送了一个窗口抖动。", [self getMyNickName]]];
    [mesg setMessageDate:msgDate];
    [mesg setChatId:[self getChatIdByUserId:userId]];
    [mesg setChannelInfo:[self getChancelInfoForUserId:userId]];
    [mesg setAppendInfoDict:[self getAppendInfoForUserId:userId]];
    [self saveMsg:mesg ByJid:userId];
    
    NSDictionary *mesgDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:mesgDict];
    return mesg;
}

/**
 撤销单人消息

 @param messageId 原始消息Id
 @param message 消息Body
 @param jid 群id
 */
- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[XmppImManager sharedInstance] revokeMessageId:messageId WithMessage:message ToJid:jid];
}


/**
 撤销consult消息
 @param messageId messageId
 @param message message
 @param jid jid
 
 */

- (void)revokeConsultMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(int)chatType{
    [[XmppImManager sharedInstance] revokeConsultMessageId:messageId WithMessage:message ToJid:jid realToJid:realToJid chatType:chatType];
}

/**
 撤销群消息
 
 @param messageId 原始消息Id
 @param message 消息Body
 @param jid 群id
 */
- (void)revokeGroupMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    
    [[XmppImManager sharedInstance] revokeGroupMessageId:messageId WithMessage:message ToJid:jid];
}

- (STIMMessageModel *)sendMessage:(STIMMessageModel *)msg ToUserId:(NSString *)userId {
    [self updateMsg:msg ByJid:msg.to];
    NSString *msgRaw = nil;
    msg.chatId = [self getChatIdByUserId:userId];
    if (msg.chatType == ChatType_GroupChat) {
        
        NSDictionary *msgDict = [self createMessageDictWithMessage:msg];
        [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
    } else {
        
        msg.appendInfoDict = [self getAppendInfoForUserId:userId];
        msg.channelInfo = [self getChancelInfoForUserId:userId];
        
        NSDictionary *msgDict = [self createMessageDictWithMessage:msg];
        [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:msgDict];
    }
    [self addSessionByType:msg.chatType ById:userId ByMsgId:msg.messageId WithMsgTime:msg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRaw];
    } else {
        NSDictionary *msgRawDict = @{@"content":msg.message?msg.message:@"", @"extendInfo":msg.extendInformation.length > 0?msg.extendInformation:@"", @"localConvert":@(YES)};
        NSString *msgRawStr = [[STIMJSONSerializer sharedInstance] serializeObject:msgRawDict];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRawStr];
    }
    return msg;
}

- (STIMMessageModel *)sendMessage:(STIMMessageModel *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson {
    [self updateMsg:msg ByJid:msg.to];
    NSString *msgRaw = nil;
    
    msg.channelInfo = channelInfo;
    msg.chatId = [self getChatIdByUserId:msg.to];
    msg.appendInfoDict = [self getAppendInfoForUserId:msg.to];
    NSDictionary *msgDict = [self createMessageDictWithMessage:msg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:msgDict];
    
    [self addSessionByType:msg.chatType ById:msg.to ByMsgId:msg.messageId WithMsgTime:msg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRaw];
    }
    return msg;
}

- (STIMMessageModel *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setXmppId:groupId];
    [mesg setRealJid:groupId];
    [mesg setMessageType:STIMMessageType_Text];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    
    NSString *msgRaw = nil;
    NSDictionary *msgDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

- (STIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType {
    
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setXmppId:groupId];
    [mesg setRealJid:groupId];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

- (STIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType WithMsgId:(NSString *)msgId {
    
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:msgId];
    [mesg setXmppId:groupId];
    [mesg setRealJid:groupId];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

- (STIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WithMsgType:(int)msgType {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setXmppId:userId];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setRealJid:userId];
    [mesg setMessageDate:msgDate];
    [mesg setFrom:[[STIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setExtendInformation:info];
    [mesg setMessageSendState:STIMMessageSendState_Waiting];
    [mesg setChatId:[self getChatIdByUserId:userId]];
    [mesg setChannelInfo:[self getChancelInfoForUserId:userId]];
    [mesg setAppendInfoDict:[self getAppendInfoForUserId:userId]];
    [self saveMsg:mesg ByJid:userId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:messageDict];
    [self addSessionByType:ChatType_SingleChat ById:userId ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid{
    STIMVerboseLog(@"===========音视频信息=========\r sendAudioVideoWithType ExtentInfo %@ ",extentInfo);
    [[XmppImManager sharedInstance] sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

#pragma mark - Share Location

- (STIMMessageModel *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WithMsgType:(int)msgType {
    STIMMessageModel *mesg = [STIMMessageModel new];
    [mesg setMessageId:[STIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:STIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    NSString *msgRaw = nil;
    [[XmppImManager sharedInstance] sendShareLocationMessage:msg WithInfo:info toJid:jid WithMsgId:mesg.messageId WithMsgType:msgType WithChatId:nil OutMsgRaw:&msgRaw];
    if (msgRaw.length > 0) {
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

- (STIMMessageModel *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId {
    if (shareLocationId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:shareLocationId forKey:@"shareId"];
        [dic setObject:[self getLastJid] forKey:@"fromId"];
        NSString *extendInfo = [[STIMJSONSerializer sharedInstance] serializeObject:dic];
        return [self sendMessage:@"发起了位置共享,请升级最新App客户端查看。" WithInfo:extendInfo ToUserId:userId WithMsgType:STIMMessageType_shareLocation];
    }
    return nil;
}

- (STIMMessageModel *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId {
    if (shareLocationId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:shareLocationId forKey:@"shareId"];
        [dic setObject:[self getLastJid] forKey:@"fromId"];
        NSString *extendInfo = [[STIMJSONSerializer sharedInstance] serializeObject:dic];
        return [self sendMessage:@"发起了位置共享,请升级最新App客户端查看。" WithInfo:extendInfo ToGroupId:GroupId WithMsgType:STIMMessageType_shareLocation];
    }
    return nil;
}

- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId {
    return [[XmppImManager sharedInstance] joinShareLocationToUsers:users WithShareLocationId:shareLocationId WithMsgType:ShareLocationType_Join];
}

- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId {
    return [[XmppImManager sharedInstance] sendMyLocationToUsers:users WithLocationInfo:locationInfo ByShareLocationId:shareLocationId WithMsgType:ShareLocationType_Info];
}

- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId {
    return [[XmppImManager sharedInstance] quitShareLocationToUsers:users WithShareLocationId:shareLocationId WithMsgType:ShareLocationType_Quit];
}

- (NSString *)getShareLocationIdByJid:(NSString *)jid {
    return [self.shareLocationDic objectForKey:jid];
}

- (NSString *)getShareLocationFromIdByShareLocationId:(NSString *)shareLocationId {
    return [self.shareLocationFromIdDic objectForKey:shareLocationId];
}

- (NSArray *)getShareLocationUsersByShareLocationId:(NSString *)shareLocationId {
    return [self.shareLocationUserDic objectForKey:shareLocationId];
}

#pragma mark - MsgReadCount

- (NSArray *)getMsgsForMsgType:(STIMMessageType)msgType {
    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgsByMsgType:msgType];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *infoDic in array) {
        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgsByMsgId:msgId];
}

- (STIMMessageModel *)getMsgByMsgId:(NSString *)msgId {
    NSDictionary *infoDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgsByMsgId:msgId];
    if (infoDic.count > 0) {
        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
        return msg;
    }
    return nil;
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag{
    NSString *key = [NSString stringWithFormat:@"%@-%@",jid,realJid];
    NSNumber *globalMsgDate = [self.timeStempDic objectForKey:key];
    if (msgDate - globalMsgDate.longLongValue >= 2 * 60 * 1000) {
        [self.timeStempDic setObject:@(msgDate) forKey:jid];
        NSDate*date = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        STIMMessageModel *msg = [STIMMessageModel new];
        [msg setFrom:jid];
        [msg setXmppId:jid];
        [msg setMessageId:[[IMDataManager stIMDB_SharedInstance] stIMDB_getTimeSmtapMsgIdForDate:date WithUserId:key]];
        [msg setMessageType:STIMMessageType_Time];
        [msg setMessageDate:msgDate-1];
        [msg setRealJid:realJid];
        [msg setMessageSendState:STIMMessageSendState_Success];
        [msg setMessageReadState:STIMMessageRemoteReadStateGroupReaded|STIMMessageRemoteReadStateDidReaded];
        if ([[IMDataManager stIMDB_SharedInstance] stIMDB_checkMsgId:msg.messageId]) {
            return;
        }
        [self saveMsg:msg ByJid:jid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                object:key
                                                              userInfo:@{@"message":msg}];
        });
    }
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    
    if (!jid || msgDate < 0) {
        return;
    }
    NSNumber *globalMsgDate = [self.timeStempDic objectForKey:jid];
    if (msgDate - globalMsgDate.longLongValue >= 2 * 60 * 1000) {
        
        [self.timeStempDic setObject:@(msgDate) forKey:jid];
        STIMMessageModel *msg = [STIMMessageModel new];
        NSDate *date = [NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        [msg setMessageId:[[IMDataManager stIMDB_SharedInstance] stIMDB_getTimeSmtapMsgIdForDate:date WithUserId:jid]];
        [msg setRealJid:jid];
        [msg setXmppId:jid];
        [msg setFrom:jid];
        [msg setMessageType:STIMMessageType_Time];
        [msg setMessageDate:msgDate - 1];
        [msg setMessageSendState:STIMMessageSendState_Success];
        [msg setMessageReadState:STIMMessageRemoteReadStateGroupReaded|STIMMessageRemoteReadStateDidReaded];
        if ([[IMDataManager stIMDB_SharedInstance] stIMDB_checkMsgId:msg.messageId]) {
            
            return;
        }
        [self saveMsg:msg ByJid:jid];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                            object:jid
                                                          userInfo:@{@"message": msg}];
    }
}

#pragma mark - 未读消息

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(STIMMessageSendState)state {
    if (msgId.length <= 0) {
        return;
    }
    if (!self.msgCompensateReadSet) {
        self.msgCompensateReadSet = [[NSMutableSet alloc] initWithCapacity:3];
    }
    if (flag) {
        NSDictionary *dic = @{@"MsgId": msgId, @"State":@(state)};
        [self.msgCompensateReadSet addObject:dic];
    } else {
        NSDictionary *dic = @{@"MsgId": msgId, @"State":@(state)};
        [self.msgCompensateReadSet removeObject:dic];
    }
}

- (NSMutableSet *)getLastMsgCompensateReadSet {
    return self.msgCompensateReadSet;
}

- (void)updateMessageControlStateWithNewState:(STIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageControlStateUpdate" object:@{@"State":@(state), @"MsgIds":MsgIdList?MsgIdList:@[]}];
    });
}

- (void)updateMessageStateWithNewState:(STIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageStateUpdate" object:@{@"State":@(state), @"MsgIds":MsgIdList?MsgIdList:@[]}];
    });
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid {
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMVerboseLog(@"updateNotReadCountCacheByJid: 抛出通知 kMsgNotReadCountChange");
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"XmppId":jid, @"RealJid":jid}];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
    });
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    if (jid.length > 0 && realJid.length > 0) {
        NSInteger notReadCount = [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReaderMsgCountByJid:jid ByRealJid:realJid withChatType:chatType];
        return notReadCount;
    }
    return 0;
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    if (jid.length > 0 && realJid.length > 0) {
        NSInteger notReadCount = [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReaderMsgCountByJid:jid ByRealJid:realJid];
        return notReadCount;
    }
    return 0;
}

- (void)updateAppNotReadCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger notReadCount = [[IMDataManager stIMDB_SharedInstance] stIMDB_getAppNotReadCount];
        NSInteger notRemindCount = [[STIMManager sharedInstance] getNotRemindNotReaderCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notReadCount-notRemindCount];
        });
    });
}

- (NSInteger)getAppNotReaderCount {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getAppNotReadCount];
}

- (NSInteger)getNotRemindNotReaderCount {
    NSInteger count = 0;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    //防止有些cell没有刷新到，字典中未包含GroupId，将未读数计算进去
    
    NSMutableArray *groupIdList = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *array = [[STIMManager sharedInstance] getClientConfigInfoArrayWithType:STIMClientConfigTypeKNoticeStickJidDic];
    for (NSDictionary *groupInfoDic in array) {
        NSString *groupId = [groupInfoDic objectForKey:@"ConfigSubKey"];
        if (groupId.length > 0) {
            NSInteger reminded = [[groupInfoDic objectForKey:@"DeleteFlag"] integerValue];
            if (reminded == 0) {
                [groupIdList addObject:groupId];
            }
        }
    }
    if (groupIdList.count > 0) {
        count = [[IMDataManager stIMDB_SharedInstance] stIMDB_getSumNotReaderMsgCountByXmppIds:groupIdList];
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    STIMVerboseLog(@"耗时 = %f s", end - start); //
    return count;
}

- (void)getExploreNotReaderCount {
    
    int value = [[NSDate date] timeIntervalSince1970];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ops/opsapp/role/count?c=%@&p=iphone&v=%@&t=%d", [[STIMNavConfigManager sharedInstance] opsHost],[self thirdpartKeywithValue], [[STIMAppInfo sharedInstance] AppBuildVersion], value]];
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:url];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setSTIMSafeObject:@"application/x-www-form-urlencoded;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:requestHeader];
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *errol = nil;
                NSDictionary *resDic = [[STIMJSONSerializer sharedInstance] deserializeObject:response.data error:&errol];
                BOOL count = [[[resDic objectForKey:@"data"] objectForKey:@"hasUnread"] boolValue];
                if (count == YES) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreNotReadCountChange object:@(count)];
                    });
                }
            });
        }
    } failure:^(NSError *error) {
        
    }];
}

- (int)getLeaveMsgNotReaderCount {
    NSURL *url = [NSURL URLWithString:@"http://u.package.qunar.com/user/message/countUnreply.json"];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
    [request setRequestMethod:@"GET"];
    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *resDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if ([resDic objectForKey:@"data"] != [NSNull null]) {
            int count = [[[resDic objectForKey:@"data"] objectForKey:@"count"] boolValue];
            return count;
        }
    }
    return 0;
}

- (void)clearSystemMsgNotReadWithJid:(NSString *)jid {
    
    if (jid.length <= 0) {
        
        return;
    }
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateSystemMsgState:STIMMessageSendState_Success withReadState:STIMMessageRemoteReadStateDidReaded WithXmppId:jid];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateNotReadCountCacheByJid:jid];
        STIMVerboseLog(@"clearSystemMsgNotReadWithJid: 抛出通知 kMsgNotReadCountChange");
    });
}

- (void)clearAllNoRead {
    long long readMarkT = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
    BOOL isSuccess = [[XmppImManager sharedInstance] sendClearAllMsgStateByReadMarkT:readMarkT * 1000];
    if (isSuccess) {
        NSDictionary *clearAllOnReadStateDic = [self getLocalAllOnReadStateInfoWithReadType:STIMMessageReadFlagClearAllUnRead ByReadMarkT:readMarkT * 1000];
        STIMVerboseLog(@"发送本地清除所有未读OnReadState : %@", clearAllOnReadStateDic);
        [self onReadState:clearAllOnReadStateDic];
    }
}

- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid{
    if (jid.length <= 0 && realJid.length <= 0) {
        return;
    }
    
    NSArray *notReadMsgList = [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReadMsgListForUserId:jid ForRealJid:realJid];
    if (notReadMsgList.count <= 0) {
        
        return;
    }
    [self sendReadStateWithMessagesIdArray:notReadMsgList WithMessageReadFlag:STIMMessageReadFlagDidRead WithXmppId:jid WithRealJid:realJid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid {
    
    if (jid.length <= 0) {
        return;
    }
    
    NSArray *msgList = [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReadMsgListForUserId:jid];
    if (msgList.count > 0) {
        [self sendReadStateWithMessagesIdArray:msgList WithMessageReadFlag:STIMMessageReadFlagDidRead WithXmppId:jid];
    }
}

- (void)clearNotReadMsgByGroupId:(NSString *)groupId {
    
    long long groupLastTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMaxMsgTimeStampByXmppId:groupId ByRealJid:groupId];
    [self sendReadstateWithGroupLastMessageTime:groupLastTime withGroupId:groupId];
}

#pragma mark - 阅读状态

- (NSDictionary *)getLocalAllOnReadStateInfoWithReadType:(STIMMessageReadFlag)readType ByReadMarkT:(long long)readMarkT {
    NSMutableDictionary *readInfoDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSDictionary *readMarkTDic = @{@"T":@(readMarkT)};
    NSString *readMarkTStr = [[STIMJSONSerializer sharedInstance] serializeObject:readMarkTDic];
    [readInfoDic setObject:readMarkTStr forKey:@"infoStr"];
    [readInfoDic setSTIMSafeObject:@(readType) forKey:@"readType"];
    return readInfoDic;
}

- (NSDictionary *)getLocalOnReadStateInfoWithReadType:(STIMMessageReadFlag)readType withReadMsgList:(NSArray *)msgList withXmppId:(NSString *)xmppId {
    
    NSMutableDictionary *readInfoDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSString *readMsgListStr = [[STIMJSONSerializer sharedInstance] serializeObject:msgList];
    [readInfoDic setSTIMSafeObject:readMsgListStr forKey:@"infoStr"];
    [readInfoDic setSTIMSafeObject:xmppId forKey:@"jid"];
    [readInfoDic setSTIMSafeObject:@(readType) forKey:@"readType"];
    return readInfoDic;
}

- (NSDictionary *)getLocalOnGroupReadStateInfoWithReadType:(STIMMessageReadFlag)readType withGroupId:(NSString *)groupId withReadMarkTime:(long long)readMarkTime {
    
    NSMutableDictionary *readInfoDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [infoDic setSTIMSafeObject:[[groupId componentsSeparatedByString:@"@"] firstObject] forKey:@"id"];
    [infoDic setSTIMSafeObject:[[groupId componentsSeparatedByString:@"@"] lastObject] forKey:@"domain"];
    [infoDic setSTIMSafeObject:@(readMarkTime) forKey:@"t"];
    NSString *infoStr = [[STIMJSONSerializer sharedInstance] serializeObject:@[infoDic]];
    
    [readInfoDic setSTIMSafeObject:infoStr forKey:@"infoStr"];
    [readInfoDic setSTIMSafeObject:groupId forKey:@"jid"];
    [readInfoDic setSTIMSafeObject:@(readType) forKey:@"readType"];
    return readInfoDic;
}

//更新所有消息阅读状态
- (void)updateAllLocalMsgWithMsgRemoteState:(NSInteger)remoteState ByReadMarkT:(long long)readMarkT {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateAllMsgWithMsgRemoteState:remoteState ByMsgDirection:1 ByReadMarkT:readMarkT];
}

//更新群消息阅读状态
- (void)updateLocalGroupMessageRemoteState:(NSInteger)remoteState withXmppId:(NSString *)xmppId ByReadList:(NSArray *)readList {
    
    //TODO 清除未读时候，清除一下艾特消息
    dispatch_block_t block = ^{

        [self.hasAtMeDic removeObjectForKey:xmppId];
    };
    if (dispatch_get_specific(self.atMeCacheTag)) {
        block();
    } else {
        dispatch_sync(self.atMeCacheQueue, block);
    }
    [[IMDataManager stIMDB_SharedInstance] stIMDB_clearAtMessageWithGroupId:xmppId];
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateGroupMessageRemoteState:remoteState ByGroupReadList:readList];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"XmppId":xmppId, @"RealJid":xmppId}];
    });
}

//更新单人消息阅读状态
- (void)updateLocalMessageRemoteState:(NSInteger)remoteState withXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid ByMsgIdList:(NSArray *)msgIdList {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMsgWithMsgRemoteState:remoteState ByMsgIdList:msgIdList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        STIMVerboseLog(@"发送消息RemoteState阅读状态变化通知 : %ld, %@", remoteState, msgIdList);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageReadStateUpdate object:@{@"State":@(remoteState), @"MsgIds":msgIdList?msgIdList:@[]}];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"XmppId":xmppId, @"RealJid":realJid}];
    });
}

/**
 此消息 当是二人会话的时候，messageId会被拼在一起
 当是群消息的时候，会取数组中最后一条消息的id进行time查询
 @param messages messages
 @param xmppId xmppId
 */
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(STIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (NSString *msgId in messages) {
        if (msgId.length > 0) {
            [resultArray addObject:@{@"id": msgId}];
        }
    }
    
    NSString *jsonString = [[STIMJSONSerializer sharedInstance] serializeObject:resultArray];
    BOOL isSuccess = [[XmppImManager sharedInstance] sendReadStateWithMessagesIdArray:jsonString WithMessageReadFlag:msgReadFlag WithXmppid:[NSString stringWithFormat:@"%@",xmppId] WithTo:xmppId withRealTo:realJid];
    if (isSuccess) {
        NSDictionary *readDic = [self getLocalOnReadStateInfoWithReadType:msgReadFlag withReadMsgList:resultArray withXmppId:xmppId];
        STIMVerboseLog(@"发送本地OnReadState : %@", readDic);
        [self onReadState:readDic];
    }
    return isSuccess;
}

/**
 此消息 当是二人会话的时候，messageId会被拼在一起
 当是群消息的时候，会取数组中最后一条消息的id进行time查询
 @param messages messages
 @param xmppId xmppId
 */
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(STIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId {
    
    return [self sendReadStateWithMessagesIdArray:messages WithMessageReadFlag:msgReadFlag WithXmppId:xmppId WithRealJid:nil];
}

/**
 发送群阅读状态
 
 @param lastTime 群里最后一条消息时间戳
 @param groupId 群Id
 @return 是否成功
 */
- (BOOL)sendReadstateWithGroupLastMessageTime:(long long)lastTime withGroupId:(NSString *)groupId {
    NSArray *coms = [groupId componentsSeparatedByString:@"@"];
    NSString *groupName = coms.firstObject;
    NSString *domain = coms.lastObject;
    BOOL isSuccess = [[XmppImManager sharedInstance] sendReadStateWithMessageTime:lastTime groupName:groupName WithDomain:domain];
    if (isSuccess) {
        NSDictionary *groupOnReadStateDic = [self getLocalOnGroupReadStateInfoWithReadType:STIMMessageReadFlagGroupReaded withGroupId:groupId withReadMarkTime:lastTime];
        STIMVerboseLog(@"发送本地groupOnReadStateDic : %@", groupOnReadStateDic);
        [self onReadState:groupOnReadStateDic];
    }
    return isSuccess;
}

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableDictionary *msgDict = [NSMutableDictionary dictionaryWithCapacity:5];
        [msgDict setSTIMSafeObject:userId forKey:@"id"];
        [msgDict setSTIMSafeObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"timestamp"];
        [msgDict setSTIMSafeObject:realJid forKey:@"realjid"];
        [msgDict setSTIMSafeObject:[self getChatTypeStr:chatType] forKey:@"type"];
        if (chatType == ChatType_Consult) {
            [msgDict setSTIMSafeObject:@"4" forKey:@"qchatid"];
        } else if (chatType == ChatType_ConsultServer) {
            [msgDict setSTIMSafeObject:@"5" forKey:@"qchatid"];
        } else {

        }
        NSString *msg = [[STIMJSONSerializer sharedInstance] serializeObject:msgDict];
        NSMutableDictionary *presenceMsgDict = [NSMutableDictionary dictionaryWithCapacity:5];
        [presenceMsgDict setSTIMSafeObject:@(STIMCategoryNotifyMsgTypeSession) forKey:@"PresenceMsgType"];
        [presenceMsgDict setSTIMSafeObject:msg forKey:@"PresenceMsg"];
        [[XmppImManager sharedInstance] sendNotifyPresenceMsg:presenceMsgDict ToJid:[[STIMManager sharedInstance] getLastJid]];
    });
}

#pragma mark - 数据库更新 或者 保存消息

//存储消息
- (void)saveMsg:(STIMMessageModel *)msg ByJid:(NSString *)xmppId {
    
    //时间消息 不存
    if ([msg isKindOfClass:[NSString class]]) {
        
        return;
    }
    //存储 消息
    if ([msg isKindOfClass:[NSString class]] == NO) {

        NSString *messageId = msg.messageId;
        
        NSString *from = msg.from;
        
        NSString *to = msg.to;
        
        NSString *content = nil;
        
        content = msg.message;
        
        NSString *extendInfo = msg.extendInformation;
        int msgType = msg.messageType;
        
        int msgState = msg.messageSendState;
        
        int msgDirection = msg.messageDirection;
        
        long long msgDate = msg.messageDate;
        if (!msg.xmppId.length) {
            msg.xmppId = xmppId;
        }
        
        if (msg.chatType == ChatType_PublicNumber) {
            if (msg.messageType == STIMMessageType_Consult || msg.messageType == STIMMessageType_ConsultResult || msg.messageType == STIMMessageType_MicroTourGuide) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            [[IMDataManager stIMDB_SharedInstance] stIMDB_insetPublicNumberMsgWithMsgId:messageId WithSessionId:xmppId WithFrom:from WithTo:to WithContent:content WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WithMsgDate:msgDate WithReadedTag:STIMMessageSendState_Success];
        } else if (msg.chatType == ChatType_CollectionChat) {
            if (msg.messageType == STIMMessageType_Consult || msg.messageType == STIMMessageType_ConsultResult || msg.messageType == STIMMessageType_MicroTourGuide) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            NSDictionary *msgDic = [msg yy_modelToJSONObject];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_insertMessageWithMsgDic:msgDic];
        } else if (msg.chatType == ChatType_System) {
            if (msg.messageType == MessageType_C2BGrabSingle || msg.messageType == MessageType_C2BGrabSingleFeedBack || msg.messageType == MessageType_QCZhongbao) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            NSDictionary *msgDic = [msg yy_modelToJSONObject];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_insertMessageWithMsgDic:msgDic];
        } else {
            if (!msg.msgRaw) {
                NSDictionary *msgRawDict = @{@"content":msg.message?msg.message:@"", @"extendInfo":msg.extendInformation.length > 0?msg.extendInformation:@"", @"localConvert":@(YES)};
                msg.msgRaw = [[STIMJSONSerializer sharedInstance] serializeObject:msgRawDict];
            }
            NSDictionary *msgDic = [msg yy_modelToJSONObject];
            [[IMDataManager stIMDB_SharedInstance] stIMDB_insertMessageWithMsgDic:msgDic];
        }
    }
}

//更新消息
- (void)updateMsg:(STIMMessageModel *)msg ByJid:(NSString *)sid {
    
    //时间消息 不存
    if ([msg isKindOfClass:[NSString class]]) {
        
        return;
    }
    
    //存储 消息
    if ([msg isKindOfClass:[NSString class]] == FALSE) {
        
        NSString *messageId = msg.messageId;
        
        NSString *from = msg.from;
        
        NSString *to = msg.to;
        
        NSString *content = nil;
        content = msg.message;
        NSString *extendInfo = msg.extendInformation;
        int msgType = msg.messageType;
        
        long long msgState = msg.messageSendState;
        
        int msgDirection = msg.messageDirection;
        
        long long msgDate = msg.messageDate;
        
        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageWithMsgId:messageId WithSessionId:sid WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WithMsgDate:msgDate WithReadedTag:0 ExtendedFlag:0 WithMsgRaw:msg.msgRaw];
    }
}

- (void)deleteMsg:(STIMMessageModel *)msg ByJid:(NSString *)sid {
    
    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteMessageByMessageId:msg.messageId ByJid:sid];
}

- (void)setMsgSentFaild{
    NSArray *msgIds = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgIdsForDirection:STIMMessageDirection_Sent WithMsgState:STIMMessageSendState_Waiting];
    for (NSString *msgId in msgIds) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamSendMessageFailed object:@{@"messageId":msgId}];
    }
}

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw {
    return [[XmppImManager sharedInstance] parseMessageByMsgRaw:msgRaw];
}

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw {
    return [[XmppImManager sharedInstance] parseOriginMessageByMsgRaw:msgRaw];
}

#pragma mark - 加载本地消息
- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WithComplete:(void (^)(NSArray *))complete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgListByXmppId:userId WithRealJid:realJid FromTimeStamp:timeStamp];
        
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *infoDic in array) {
            STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
            [list addObject:msg];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete((list.count > 0) ? list : @[]);
        });
    });
}

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    NSArray *msgIdList = [[IMDataManager stIMDB_SharedInstance] stIMDB_getNotReadMsgListForUserId:userId ForRealJid:realJid];
    return msgIdList;
}

- (STIMMessageModel *)getMessageModelWithByDBMsgDic:(NSDictionary *)dbMsgDic {
    /*
     [IMDataManager safeSaveForDic:msgDic setObject:msgId forKey:@"MsgId"];
     [IMDataManager safeSaveForDic:msgDic setObject:xmppId forKey:@"XmppId"];
     [IMDataManager safeSaveForDic:msgDic setObject:platform forKey:@"Platform"];
     [IMDataManager safeSaveForDic:msgDic setObject:from forKey:@"From"];
     [IMDataManager safeSaveForDic:msgDic setObject:to forKey:@"To"];
     [IMDataManager safeSaveForDic:msgDic setObject:content forKey:@"Content"];
     [IMDataManager safeSaveForDic:msgDic setObject:extendInfo forKey:@"ExtendInfo"];
     [IMDataManager safeSaveForDic:msgDic setObject:msgType forKey:@"MsgType"];
     [IMDataManager safeSaveForDic:msgDic setObject:chatType forKey:@"ChatType"];
     [IMDataManager safeSaveForDic:msgDic setObject:msgState forKey:@"MsgState"];
     [IMDataManager safeSaveForDic:msgDic setObject:msgDirection forKey:@"MsgDirection"];
     [IMDataManager safeSaveForDic:msgDic setObject:contentResolve forKey:@"ContentResolve"];
     [IMDataManager safeSaveForDic:msgDic setObject:readState forKey:@"ReadState"];
     [IMDataManager safeSaveForDic:msgDic setObject:msgDateTime forKey:@"MsgDateTime"];
     [IMDataManager safeSaveForDic:msgDic setObject:msgRaw forKey:@"MsgRaw"];
     [IMDataManager safeSaveForDic:msgDic setObject:realJid forKey:@"RealJid"];
     */
    NSString *msgId = [dbMsgDic objectForKey:@"MsgId"];
    NSString *xmppId = [dbMsgDic objectForKey:@"XmppId"];
    IMPlatform platform = [[dbMsgDic objectForKey:@"Platform"] integerValue];
    NSString *from = [dbMsgDic objectForKey:@"From"];
    NSString *to = [dbMsgDic objectForKey:@"To"];
    NSString *content = [dbMsgDic objectForKey:@"Content"];
    NSString *extendInfo = [dbMsgDic objectForKey:@"ExtendInfo"];
    STIMMessageType msgType = [[dbMsgDic objectForKey:@"MsgType"] integerValue];
    ChatType chatType = [[dbMsgDic objectForKey:@"ChatType"] integerValue];
    STIMMessageSendState sendState = [[dbMsgDic objectForKey:@"MsgState"] integerValue];
    STIMMessageDirection msgDirection = [[dbMsgDic objectForKey:@"MsgDirection"] integerValue];
    NSString *contentResolve = [dbMsgDic objectForKey:@"ContentResolve"];
    STIMMessageRemoteReadState readState = [[dbMsgDic objectForKey:@"ReadState"] integerValue];
    long long msgDateTime = [[dbMsgDic objectForKey:@"MsgDateTime"] longLongValue];
    id msgRaw = [dbMsgDic objectForKey:@"MsgRaw"];
    NSString *realJid = [dbMsgDic objectForKey:@"RealJid"];
    
    STIMMessageModel *msgModel = [STIMMessageModel new];
    msgModel.messageId = msgId;
    msgModel.xmppId = xmppId;
    msgModel.platform = platform;
    msgModel.from = from;
    msgModel.to = to;
    msgModel.message = content;
    msgModel.extendInformation = extendInfo;
    msgModel.messageType = msgType;
    msgModel.chatType = chatType;
    msgModel.messageSendState = sendState;
    msgModel.messageDirection = msgDirection;
    msgModel.messageReadState = readState;
    msgModel.messageDate = msgDateTime;
    msgModel.msgRaw = msgRaw;
    msgModel.realJid = realJid;
    return msgModel;
}

//远程搜索，进会话拉历史
- (void)getRemoteSearchMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid withVersion:(long long)lastUpdateTime withDirection:(STIMGetMsgDirection)direction WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (self.load_history_msg == nil) {
            
            self.load_history_msg = dispatch_queue_create("Load History", 0);
        }
        dispatch_async(self.load_history_msg, ^{
            
            if ([userId rangeOfString:@"@conference."].location != NSNotFound) {
                NSNumber *readMarkT = nil;
                NSArray *resultList = [self getMucMsgListWithGroupId:userId WithDirection:direction WithLimit:(lastUpdateTime < 0) ? (direction == 0 ? 20 : limit) : limit WithVersion:(lastUpdateTime < 0) ? (direction == 0 ? INT64_MAX : 0) : lastUpdateTime include:YES];
                NSString *date1Str = [resultList.lastObject objectForKey:@"time"][@"stamp"];
                //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                NSDate *date1 = [dateFormatter dateFromString:date1Str];
                readMarkT = [NSNumber numberWithLong:[date1 timeIntervalSince1970]];
                if (resultList.count > 0) {
                    NSArray *datas = [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertIphoneMucPageJSONMsg:resultList withInsertDBFlag:NO];
                    NSMutableArray *list = [NSMutableArray array];
                    for (NSDictionary *infoDic in datas) {
                        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                        [list addObject:msg];
                    }
                    complete(list);
                } else {
                    complete(@[]);
                }
            } else {
                NSArray *result = [self getUserChatlogWithFrom:userId to:[self getLastJid] version:lastUpdateTime count:limit direction:direction include:YES];
                if (result.count > 0) {
                    NSArray *datas = [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertPageHistoryChatJSONMsg:result WithXmppId:userId withInsertDBFlag:NO];
                    NSMutableArray *list = [NSMutableArray array];
                    NSString *channelInfo = nil;
                    NSString *buInfo = nil;
                    NSString *cctextInfo = nil;
                    for (NSDictionary *infoDic in datas) {
                        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                        [list addObject:msg];
                        // channelid
                        channelInfo = [infoDic objectForKey:@"channelid"];
                        buInfo = [infoDic objectForKey:@"bu"];
                        cctextInfo = [infoDic objectForKey:@"cctext"];
                    }
                    [self setChannelInfo:channelInfo ForUserId:userId];
                    if (buInfo.length > 0) {
                        [self setAppendInfo:@{@"bu":buInfo} ForUserId:userId];
                    }
                    if (cctextInfo.length > 0) {
                        [self setAppendInfo:@{@"cctext":cctextInfo} ForUserId:userId];
                    }
                    complete(list);
                } else {
                    complete(@[]);
                }
            }
        });
    });
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMgsListBySessionId:userId WithRealJid:realJid WithLimit:limit WithOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *infoDic in array) {
                STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                [list addObject:msg];
            }
            complete(list);
            if (list.count < limit && loadMore == YES) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    if ([userId rangeOfString:@"@conference."].location != NSNotFound) {
                        NSString *groupName = [[[userId componentsSeparatedByString:@"@"] objectAtIndex:0] copy];
#pragma mark - 这里开始拉取群翻页消息
                        if (groupName) {
                            NSArray *resultList = [self getMucMsgListWithGroupId:userId WithDirection:0 WithLimit:limit WithVersion:[[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:userId] include:NO];
                            NSString *date1Str = [resultList.lastObject objectForKey:@"time"][@"stamp"];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                            NSDate *date1 = [dateFormatter dateFromString:date1Str];
                            NSNumber *readMarkT = [NSNumber numberWithLong:[date1 timeIntervalSince1970]];
                            
                            if (resultList.count > 0) {
                                
                                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertIphoneMucPageJSONMsg:resultList];
                            }
                        } else {
#pragma mark - 这里开始拉取单人翻页消息
                            NSArray *result = [self getUserChatlogWithFrom:userId to:[self getLastJid] version:[[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:userId] count:limit direction:0 include:NO];
                            if (result.count > 0) {
                                NSArray *datas = [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertPageHistoryChatJSONMsg:result WithXmppId:userId];
                                NSDictionary *infoDic = datas.lastObject;
                                if (infoDic) {
                                    NSString *channelInfo = [infoDic objectForKey:@"channelid"];
                                    NSString *buInfo = [infoDic objectForKey:@"bu"];
                                    NSString *cctextInfo = [infoDic objectForKey:@"cctext"];
                                    [self setChannelInfo:channelInfo ForUserId:userId];
                                    if (buInfo.length > 0) {
                                        [self setAppendInfo:@{@"bu":buInfo} ForUserId:userId];
                                    }
                                    if (cctextInfo.length > 0) {
                                        [self setAppendInfo:@{@"cctext":cctextInfo} ForUserId:userId];
                                    }
                                }
                            }
                        }
                    }
                });
            }
        } else {
            
            if (loadMore == YES) {
                if (self.load_history_msg == nil) {
                    
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    
                    if ([userId rangeOfString:@"@conference."].location != NSNotFound) {
                        long long version = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:userId] - timeChange;
                        int direction = 0;
                        NSNumber *readMarkT = nil;
                        NSArray *resultList = [self getMucMsgListWithGroupId:userId WithDirection:direction WithLimit:version < 0 ? (direction == 0 ? 20 : limit) : limit WithVersion:version < 0 ? (direction == 0 ? INT64_MAX : 0) : version include:NO];
                        NSString *date1Str = [resultList.lastObject objectForKey:@"time"][@"stamp"];
                        //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                        NSDate *date1 = [dateFormatter dateFromString:date1Str];
                        readMarkT = [NSNumber numberWithLong:[date1 timeIntervalSince1970]];
                        if (resultList.count > 0) {
                            NSArray *datas = [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertIphoneMucPageJSONMsg:resultList];
                            NSMutableArray *list = [NSMutableArray array];
                            for (NSDictionary *infoDic in datas) {
                                STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                                [list addObject:msg];
                            }
                            complete(list);
                        } else {
                            complete(@[]);
                        }
                    } else {
                        NSArray *result = [self getUserChatlogWithFrom:userId to:[self getLastJid] version:[[IMDataManager stIMDB_SharedInstance] stIMDB_getMinMsgTimeStampByXmppId:userId] count:limit direction:0 include:NO];
                        if (result.count > 0) {
                            NSArray *datas = [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertPageHistoryChatJSONMsg:result WithXmppId:userId];
                            NSMutableArray *list = [NSMutableArray array];
                            NSString *channelInfo = nil;
                            NSString *buInfo = nil;
                            NSString *cctextInfo = nil;
                            for (NSDictionary *infoDic in datas) {
                                STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                                [list addObject:msg];
                                // channelid
                                channelInfo = [infoDic objectForKey:@"channelid"];
                                buInfo = [infoDic objectForKey:@"bu"];
                                cctextInfo = [infoDic objectForKey:@"cctext"];
                            }
                            
                            [self setChannelInfo:channelInfo ForUserId:userId];
                            if (buInfo.length > 0) {
                                [self setAppendInfo:@{@"bu":buInfo} ForUserId:userId];
                            }
                            if (cctextInfo.length > 0) {
                                [self setAppendInfo:@{@"cctext":cctextInfo} ForUserId:userId];
                            }
                            complete(list);
                        } else {
                            complete(@[]);
                        }
                    }
                });
            } else {
                complete(@[]);

            }
        }
    });
}

#pragma mark - 本地消息搜索

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord XmppId:(NSString *)xmppid RealJid:(NSString *)realJid {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_searchLocalMessageByKeyword:keyWord XmppId:xmppid RealJid:realJid];
}

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getLocalMediaByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *msgInfoDic in array) {
        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:msgInfoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgsByMsgType:msgTypes ByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *msgInfoDic in array) {
        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:msgInfoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getMsgsByKeyWord:keyWork ByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *msgInfoDic in array) {
        STIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:msgInfoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId {
    return [self getMsgsForMsgType:msgTypes ByXmppId:xmppId ByReadJid:nil];
}

@end
