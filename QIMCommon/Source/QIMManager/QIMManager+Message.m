//
//  QIMManager+Message.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMManager+Message.h"
#import "NSDate+QIMCategory.h"

#import <objc/runtime.h>
#import "QIMPrivateHeader.h"

@implementation QIMManager (Message)

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
        conversationParamDic = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:kConversationParamDic]];
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
        [[QIMUserCacheManager sharedInstance] setUserObject:self.appendInfoDic forKey:kAppendInfoDic];
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
        [[QIMUserCacheManager sharedInstance] setUserObject:self.channelInfoDic forKey:kChannelInfoDic];
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
        NSDictionary *dic = [[QIMJSONSerializer sharedInstance] deserializeObject:chanelId error:nil];
        if (dic) {
            [channelInfoDic setDictionary:dic];
        }
        [channelInfoDic setObject:@"sent" forKey:@"d"];
        NSString *channelInfo = [[QIMJSONSerializer sharedInstance] serializeObject:channelInfoDic];
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
        self.conversationParamDic = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:kConversationParamDic]];
    }
    if (!jid || !param.count) {
        return;
    } else {
        [self.conversationParamDic setObject:param forKey:jid];
        NSString *key = kConversationParamDic;
        NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:self.conversationParamDic];
        if (key && value) {
            /* 暂时注释 18.8.03
            BOOL success = [self setConfigForKeyValues:@[@{@"key": key, @"value": value, @"d":[[XmppImManager sharedInstance] domain]}]];
            if (success) {
                [[QIMUserCacheManager sharedInstance] setUserObject:self.conversationParamDic forKey:kConversationParamDic];
                QIMVerboseLog(@"抛出通知 setConversationParam:  kNotificationSessionListUpdate");
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
            [[QIMUserCacheManager sharedInstance] setUserObject:self.chatIdInfoDic forKey:kChatIdInfoDic];
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
        self.conversationParamDic = [NSMutableDictionary dictionaryWithDictionary:[[QIMUserCacheManager sharedInstance] userObjectForKey:@"kConversationParamDic"]];
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
- (NSDictionary *)createMessageDictWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)toJid messageType:(QIMMessageType)msgType {
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [msgDict setObject:messageId?messageId:[QIMUUIDTools UUID] forKey:@"MessageId"];
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
- (NSDictionary *)createMessageDictWithMessage:(Message *)message {
    
    NSDictionary *msgDict = [message yy_modelToJSONObject];
    return msgDict;
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType {
    
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:nil];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setBackupInfo:backInfo];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:nil];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:nil];
    }
    if (userType == ChatType_GroupChat) {
        [mesg setNickName:[[QIMManager sharedInstance] getLastJid]];
//        [mesg setNickName:[[[QIMManager sharedInstance] getUserInfoBsyUserId:[[QIMManager sharedInstance] getLastJid]] objectForKey:@"Name"]];
    }
    [mesg setMessageDate:msgDate];
    [mesg setMessageState:MessageState_Waiting];
    [mesg setExtendInformation:extendInfo];
    [self saveMsg:mesg ByJid:userId];
    return mesg;
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId {
    
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId willSave:YES];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:nil userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(MessageState)msgState willSave:(BOOL)willSave {
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    Message *mesg = [Message new];
    [mesg setMessageId:mId.length ? mId : [QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:realJid];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:realJid];
    }
    if (userType == ChatType_GroupChat) {
        [mesg setNickName:[[QIMManager sharedInstance] getLastJid]];
//        [mesg setNickName:[[[QIMManager sharedInstance] getUserInfoByUserId:[[QIMManager sharedInstance] getLastJid]] objectForKey:@"Name"]];
    }
    [mesg setMessageDate:msgDate];
    if (msgState) {
        [mesg setMessageState:msgState];
    } else {
        [mesg setMessageState:MessageState_Waiting];
    }
    [mesg setExtendInformation:extendInfo];
    if (willSave) {
        [self saveMsg:mesg ByJid:userId];
    }
    return mesg;
}

- (Message *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    Message *mesg = [Message new];
    [mesg setMessageId:mId.length ? mId : [QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:realJid];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:realJid];
    }
    if (userType == ChatType_GroupChat) {
        [mesg setNickName:[[QIMManager sharedInstance] getLastJid]];
    }
    [mesg setMessageDate:msgDate];
    [mesg setMessageState:MessageState_Waiting];
    [mesg setExtendInformation:extendInfo];
    if (willSave) {
        [self saveMsg:mesg ByJid:userId];
    }
    return mesg;
}

/**
 创建 “您好，我是在线客服xxx，很高兴为您服务消息”
 
 @param msg 消息Body
 @param groupId 群Id
 */
- (Message *)createNoteReplyMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:groupId WithMsgDate:msgDate WithGroup:NO];
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageDate:msgDate];
    [mesg setMessageType:QIMMessageType_Text];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setMessageState:MessageState_Waiting];
    [self saveMsg:mesg ByJid:groupId];
    [self updateMsg:mesg ByJid:groupId];
    return mesg;
}

- (void)sendWlanMessage:(NSString *)content to:(NSString *)targetID extendInfo:(NSString *)extendInfo msgType:(int)msgType completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/send_wlan_msg", [self getWlanRequestURL]]];
    [self loadWlanCookie];
    
    int time = [[NSDate date] timeIntervalSince1970];
    NSString *key = [self getWlanKeyByTime:time];
    NSString *params = nil;
    BOOL isGroup = [targetID rangeOfString:@"conference."].location != NSNotFound;
    NSString *domain = [targetID componentsSeparatedByString:@"@"].lastObject;
    domain = domain.length ? domain:[[QIMManager sharedInstance] getDomain];
    targetID = [targetID componentsSeparatedByString:@"@"].firstObject;
    
    NSMutableDictionary *resultParams = [NSMutableDictionary dictionary];
    
    [resultParams setQIMSafeObject:content forKey:@"body"];
    NSString *username = [NSString stringWithFormat:@"%@@%@", [QIMManager getLastUserName], [self getWlanRequestDomain]];
    if ([[self getWlanRequestDomain] isEqualToString:@"ejabhost1"] || [[self getWlanRequestDomain] isEqualToString:@"ejabhost2"]) {
        username = [QIMManager getLastUserName];
    }
    [resultParams setQIMSafeObject:username forKey:@"from"];
    [resultParams setQIMSafeObject:@[@{@"user" : targetID }] forKey:@"to"];
    [resultParams setQIMSafeObject:[NSString stringWithFormat:@"%d", msgType] forKey:@"msg_type"];
    [resultParams setQIMSafeObject:@"groupchat" forKey:@"type"];
    [resultParams setQIMSafeObject:key forKey:@"key"];
    [resultParams setQIMSafeObject:[NSString stringWithFormat:@"%d", time] forKey:@"count"];
    [resultParams setQIMSafeObject:extendInfo?extendInfo:@"" forKey:@"extend_info"];
    
    if (isGroup) {
        //群聊
        [resultParams setQIMSafeObject:@"groupchat" forKey:@"type"];
        [resultParams setQIMSafeObject:[NSString stringWithFormat:@"%@", domain] forKey:@"domain"];
        
    }else{
        [resultParams setQIMSafeObject:@"chat" forKey:@"type"];
        [resultParams setQIMSafeObject:domain forKey:@"host"];
    }
    
    NSString *paramsStr = [[QIMJSONSerializer sharedInstance] serializeObject:resultParams];
    QIMVerboseLog(@"快捷回复 URL : %@, 参数 : %@", url, paramsStr);
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultParams options:NSJSONWritingPrettyPrinted error:&error];
    params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        QIMInfoLog(@"快捷回复返回结果： %@", response);
    } failure:^(NSError *error) {
        QIMErrorLog(@"快捷回复错误 : %@", error);
    }];
}

/**
 创建 “您好，我是在线客服xxx，很高兴为您服务消息”
 
 @param msg 消息Body
 @param groupId 群Id
 */
- (Message *)createNoteReplyMessage:(NSString *)msg ToUserId:(NSString *)user {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:user WithMsgDate:msgDate WithGroup:NO];
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:QIMMessageType_Text];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:user];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setMessageState:MessageState_Waiting];
    [self saveMsg:mesg ByJid:user];
    return mesg;
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
- (Message *)sendShockToUserId:(NSString *)userId {
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
    
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:QIMMessageType_Shock];
    [mesg setTo:userId];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:MessageDirection_Sent];
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

//群组窗口抖动
- (Message *)sendGroupShockToGroupId:(NSString *)groupId {
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setTo:groupId];
    [mesg setMessageType:QIMMessageType_Shock];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:[NSString stringWithFormat:@"%@发送了一个窗口抖动。", [self getMyNickName]]];
    
    NSDictionary *msgDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
    return mesg;
}

- (void)revokeMessageWithMessageId:(NSString *)messageId message:(NSString *)message ToJid:(NSString *)jid {
    [[XmppImManager sharedInstance] revokeMessageId:messageId WithMessage:message ToJid:jid];
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

- (BOOL)sendReplyMessageId:(NSString *)replyMsgId WithReplyUser:(NSString *)replyUser WithMessageId:(NSString *)msgId WithMessage:(NSString *)message ToGroupId:(NSString *)groupId {
    
    return [[XmppImManager sharedInstance] sendReplyMessageId:replyMsgId WithReplyUser:replyUser WithMessageId:msgId WithMessage:message ToGroupId:groupId];
}


/**
 发送单人文件消息
 
 @param fileJson 文件消息JSON串
 @param userId 接收方Id
 @param msgId msgId
 */
- (void)sendFileJson:(NSString *)fileJson ToUserId:(NSString *)userId WithMsgId:(NSString *)msgId {
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [messageDict setQIMSafeObject:fileJson forKey:@"MessageBody"];
    [messageDict setQIMSafeObject:msgId forKey:@"MessageId"];
    [messageDict setQIMSafeObject:@(QIMMessageType_File) forKey:@"MessageType"];
    [messageDict setQIMSafeObject:[self getChatIdByUserId:userId] forKey:@"MessageChatId"];
    [messageDict setQIMSafeObject:[self getChancelInfoForUserId:userId] forKey:@"MessageChannelInfo"];
    [messageDict setQIMSafeObject:[self getAppendInfoForUserId:userId] forKey:@"MessageAppendInfoDict"];
    [messageDict setQIMSafeObject:userId forKey:@"ToJid"];
    
    
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:messageDict];
}

/**
 发送群文件消息
 
 @param fileJson 文件消息JSON串
 @param groupId 群Id
 @param msgId msgId
 */
- (void)sendFileJson:(NSString *)fileJson ToGroupId:(NSString *)groupId WihtMsgId:(NSString *)msgId {
    
    NSDictionary *msgDict = [self createMessageDictWithMessageId:msgId message:fileJson ToJid:groupId messageType:QIMMessageType_File];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
}

- (Message *)sendMessage:(Message *)msg ToUserId:(NSString *)userId {
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
        [[IMDataManager sharedInstance] updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRaw];
    } else {
        NSDictionary *msgRawDict = @{@"content":msg.message?msg.message:@"", @"extendInfo":msg.extendInformation?msg.extendInformation:@"", @"localConvert":@(YES)};
        NSString *msgRawStr = [[QIMJSONSerializer sharedInstance] serializeObject:msgRawDict];
        [[IMDataManager sharedInstance] updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRawStr];
    }
    return msg;
}

- (Message *)sendMessage:(Message *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson {
    [self updateMsg:msg ByJid:msg.to];
    NSString *msgRaw = nil;
    
    msg.channelInfo = channelInfo;
    msg.chatId = [self getChatIdByUserId:msg.to];
    msg.appendInfoDict = [self getAppendInfoForUserId:msg.to];
    NSDictionary *msgDict = [self createMessageDictWithMessage:msg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:msgDict];
    
    [self addSessionByType:msg.chatType ById:msg.to ByMsgId:msg.messageId WithMsgTime:msg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRaw];
    }
    return msg;
}

- (Message *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:QIMMessageType_Text];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    
    NSString *msgRaw = nil;
    NSDictionary *msgDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WihtMsgType:(int)msgType {
    
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WihtMsgType:(int)msgType WithMsgId:(NSString *)msgId {
    
    Message *mesg = [Message new];
    [mesg setMessageId:msgId];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

- (Message *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WihtMsgType:(int)msgType {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO];
    
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setMessageDate:msgDate];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setExtendInformation:info];
    [mesg setMessageState:MessageState_Waiting];
    [mesg setChatId:[self getChatIdByUserId:userId]];
    [mesg setChannelInfo:[self getChancelInfoForUserId:userId]];
    [mesg setAppendInfoDict:[self getAppendInfoForUserId:userId]];
    [self saveMsg:mesg ByJid:userId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:messageDict];
    [self addSessionByType:ChatType_SingleChat ById:userId ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

/**
 发送群语音消息
 
 @param voiceUrl 语音文件地址
 @param voiceName 语音文件名称
 @param seconds 语音时长
 @param groupId 群Id
 */
- (Message *)sendGroupVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToGroupId:(NSString *)groupId {
    
    Message *mesg = [Message new];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    [mesg setMessageType:QIMMessageType_Voice];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageDirection:MessageDirection_Sent];
    NSString *msgStr = [NSString stringWithFormat:@"{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@}", @"HttpUrl", voiceUrl, @"FileName", voiceName, @"Seconds", [NSNumber numberWithInt:seconds]];
    [mesg setMessage:msgStr];
    long long date = [[NSDate date] timeIntervalSince1970];
    [mesg setMessageDate:date];
    NSString *msgRaw = nil;
    
    NSDictionary *msgDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

/**
 单人发送语音消息
 
 @param voiceUrl 语音文件线上地址
 @param voiceName 语音文件名称
 @param seconds 语音时长
 @param userId 接收方
 */
- (Message *)sendVoiceUrl:(NSString *)voiceUrl withVoiceName:(NSString *)voiceName withSeconds:(int)seconds ToUserId:(NSString *)userId {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    
    Message *mesg = [Message new];
    [mesg setTo:userId];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:QIMMessageType_Voice];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setChatId:[self getChatIdByUserId:userId]];
    [mesg setChannelInfo:[self getChancelInfoForUserId:userId]];
    [mesg setAppendInfoDict:[self getAppendInfoForUserId:userId]];
    NSString *msgStr = [NSString stringWithFormat:@"{\"%@\":\"%@\", \"%@\":\"%@\", \"%@\":%@}", @"HttpUrl", voiceUrl, @"FileName", voiceName, @"Seconds", [NSNumber numberWithInt:seconds]];
    [mesg setMessage:msgStr];
    [mesg setMessageDate:msgDate];
    [self saveMsg:mesg ByJid:userId];
    
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid{
    QIMVerboseLog(@"===========音视频信息=========\r sendAudioVideoWithType ExtentInfo %@ ",extentInfo);
    [[XmppImManager sharedInstance] sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

#pragma mark - MsgReadCount

- (NSArray *)getMsgsForMsgType:(QIMMessageType)msgType {
    NSArray *array = [[IMDataManager sharedInstance] qimDB_getMsgsByMsgType:msgType];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *infoDic in array) {
        Message *msg = [Message new];
        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
        [msg setFrom:[infoDic objectForKey:@"From"]];
        [msg setTo:[infoDic objectForKey:@"To"]];
        [msg setMessage:[infoDic objectForKey:@"Content"]];
        NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
        [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msg setXmppId:[infoDic objectForKey:@"XmppId"]];
        [list addObject:msg];
    }
    return list;
}

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId {
    return [[IMDataManager sharedInstance] getMsgsByMsgId:msgId];
}

- (Message *)getMsgByMsgId:(NSString *)msgId {
    NSDictionary *infoDic = [[IMDataManager sharedInstance] getMsgsByMsgId:msgId];
    if (infoDic.count > 0) {
        Message *msg = [Message new];
        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
        [msg setFrom:[infoDic objectForKey:@"From"]];
        [msg setNickName:[infoDic objectForKey:@"From"]];
        [msg setTo:[infoDic objectForKey:@"To"]];
        [msg setMessage:[infoDic objectForKey:@"Content"]];
        NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
        [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
        [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
        [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
        [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
        return msg;
    }
    return nil;
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag{
    NSString *key = [NSString stringWithFormat:@"%@-%@",jid,realJid];
    NSNumber *globalMsgDate = [self.timeStempDic objectForKey:key];
    if (msgDate - globalMsgDate.longLongValue >= 2 * 60 * 1000) {
        [self.timeStempDic setObject:@(msgDate) forKey:jid];
        NSDate*date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        Message *msg = [Message new];
        [msg setFrom:jid];
        [msg setMessageId:[[IMDataManager sharedInstance] getTimeSmtapMsgIdForDate:date WithUserId:key]];
        [msg setMessageType:QIMMessageType_Time];
        [msg setMessageDate:msgDate-1];
        [msg setRealJid:realJid];
        [msg setMessageState:MessageState_didRead];
        if ([[IMDataManager sharedInstance] checkMsgId:msg.messageId]) {
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
        Message *msg = [Message new];
        NSDate *date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        [msg setMessageId:[[IMDataManager sharedInstance] getTimeSmtapMsgIdForDate:date WithUserId:jid]];
        [msg setMessageType:QIMMessageType_Time];
        [msg setMessageDate:msgDate - 1];
        [msg setMessageState:MessageState_didRead];
        if ([[IMDataManager sharedInstance] checkMsgId:msg.messageId]) {
            
            return;
        }
        [self saveMsg:msg ByJid:jid];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                            object:jid
                                                          userInfo:@{@"message": msg}];
    }
}

#pragma mark - 未读消息

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(MessageState)state {
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

/**
 *  返回未读消息数组
 */
- (NSArray *)getNotReaderMsgList {
    
    NSArray *sessionlist = [[IMDataManager sharedInstance] getNotReadMsgListWithMsgState:MessageState_didRead WithReceiveDirection:MessageDirection_Received];
    for (NSMutableDictionary *dic in sessionlist) {
        
        NSString *xmppId = [dic objectForKey:@"XmppId"];
        NSArray *xmppAry = [xmppId componentsSeparatedByString:@"@"];
        if ([xmppId isEqualToString:@"SystemMessage"]) {
            
            [dic setObject:@(ChatType_System) forKey:@"ChatType"];
            [dic setObject:@"系统消息" forKey:@"Name"];
        } else if ([xmppAry.lastObject hasPrefix:@"conference"]) {
            
            [dic setObject:@(ChatType_GroupChat) forKey:@"ChatType"];
            NSDictionary *cardDic = [[QIMManager sharedInstance] getGroupCardByGroupId:xmppId];
            if (cardDic) {
                
                [dic setObject:[cardDic objectForKey:@"Name"] forKey:@"Name"];
            } else {
                
                [dic setObject:xmppAry.firstObject forKey:@"Name"];
            }
        } else {
            
            [dic setObject:@(ChatType_SingleChat) forKey:@"ChatType"];
        }
    }
    return sessionlist;
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid WithRealJid:(NSString *)realJid{
    if (jid.length > 0) {
        NSString *userId = [NSString stringWithFormat:@"%@-%@", jid, realJid];
        [self updateNotReadCountCacheByJid:userId];
    }
}

- (void)updateMessageControlStateWithNewState:(MessageState)state ByMsgIdList:(NSArray *)MsgIdList {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageControlStateUpdate" object:@{@"State":@(state), @"MsgIds":MsgIdList?MsgIdList:@[]}];
    });
}

- (void)updateMessageStateWithNewState:(MessageState)state ByMsgIdList:(NSArray *)MsgIdList {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageStateUpdate" object:@{@"State":@(state), @"MsgIds":MsgIdList?MsgIdList:@[]}];
    });
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid {
    if (jid.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"updateNotReadCountCacheByJid: 抛出通知 kMsgNotReadCountChange");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kMsgNotReadCountChange" object:jid];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kMsgNotReadCountChange" object:@"ForceRefresh"];
        });
    }
}

//自增未读数
- (void)increasedNotReadMsgCountByJid:(NSString *)jid WithReadJid:(NSString *)realJid {
    return;
    NSString *userId = jid;
    if (realJid.length > 0) {
        userId = [NSString stringWithFormat:@"%@-%@", jid, realJid];
    } else {
        userId = jid;
    }
    [self increasedNotReadMsgCountByJid:userId];
}

- (void)increasedNotReadMsgCountByJid:(NSString *)jid {
    return;
    NSInteger count = [self getNotReadMsgCountByJid:jid];
    count += 1;
    [self.notReadMsgDic setObject:@(count) forKey:jid];
}

//内存中清除未读数
- (void)decrementNotReadMsgCountByJid:(NSString *)jid WithReadJid:(NSString *)realJid {
    return;
    NSString *userId = jid;
    if (realJid.length > 0) {
        userId = [NSString stringWithFormat:@"%@-%@", jid, realJid];
    } else {
        userId = jid;
    }
    [self decrementNotReadMsgCountByJid:userId];
}

- (void)decrementNotReadMsgCountByJid:(NSString *)jid {
    return;
    [self.notReadMsgDic setObject:@(0) forKey:jid];
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    if (jid.length > 0 && realJid.length > 0) {
        NSInteger notReadCount = [[IMDataManager sharedInstance] getNotReaderMsgCountByJid:jid ByRealJid:realJid ByDidReadState:MessageState_didRead WidthReceiveDirection:MessageDirection_Received];
        return notReadCount;
    }
    return 0;
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid {
    if (!jid.length) {
        return 0;
    }
    NSInteger notReadCount = [[IMDataManager sharedInstance] getNotReaderMsgCountByJid:jid ByDidReadState:MessageState_didRead WidthReceiveDirection:MessageDirection_Received];
    return notReadCount;
}

- (void)updateAppNotReadCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger notReadCount = [[IMDataManager sharedInstance] getNotReaderMsgCountByDidReadState:MessageState_didRead WidthReceiveDirection:MessageDirection_Received];
        NSInteger notRemindCount = [[QIMManager sharedInstance] getNotRemindNotReaderCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notReadCount-notRemindCount];
        });
    });
}

- (NSInteger)getAppNotReaderCount {
    return [[IMDataManager sharedInstance] getNotReaderMsgCountByDidReadState:MessageState_didRead WidthReceiveDirection:MessageDirection_Received];
}

- (NSInteger)getNotRemindNotReaderCount {
    NSInteger count = 0;
    //防止有些cell没有刷新到，字典中未包含GroupId，将未读数计算进去

    NSArray *array = [[QIMManager sharedInstance] getClientConfigInfoArrayWithType:QIMClientConfigTypeKNoticeStickJidDic];
    for (NSDictionary *groupInfoDic in array) {
        NSString *groupId = [groupInfoDic objectForKey:@"ConfigSubKey"];
        if (groupId.length > 0) {
            NSInteger reminded = [[groupInfoDic objectForKey:@"DeleteFlag"] integerValue];
            if (reminded == 0) {
                count += [[QIMManager sharedInstance] getNotReadMsgCountByJid:groupId];
            }
        }
    }
    return count;
}

- (void)getExploreNotReaderCount {
    
    int value = [[NSDate date] timeIntervalSince1970];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/ops/opsapp/role/count?c=%@&p=iphone&v=%@&t=%d", [[QIMNavConfigManager sharedInstance] opsHost],[self thirdpartKeywithValue], [[QIMAppInfo sharedInstance] AppBuildVersion], value]];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithCapacity:1];
    [requestHeader setQIMSafeObject:@"application/x-www-form-urlencoded;" forKey:@"Content-type"];
    [request setHTTPRequestHeaders:requestHeader];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *errol = nil;
                NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:&errol];
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

- (int)getLeaveMsgNotReaderCount {//    prod:http://u.package.qunar.com/user/message/countUnreply.json
    //    dev：http://l-djb2c8.vc.dev.cn0.qunar.com:8972/user/message/countUnreply.json
    NSURL *url = [NSURL URLWithString:@"http://u.package.qunar.com/user/message/countUnreply.json"];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
    [request setRequestMethod:@"GET"];
    //    [request setPostBody:tempPostData];
    [request setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSError *errol = nil;
        NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
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
    [[IMDataManager sharedInstance] updateSystemMsgState:MessageState_didRead WithXmppId:jid];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self decrementNotReadMsgCountByJid:jid];
        [self updateNotReadCountCacheByJid:jid];
        QIMVerboseLog(@"clearSystemMsgNotReadWithJid: 抛出通知 kMsgNotReadCountChange");
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:jid];
    });
}

- (void)clearAllNoRead {
    long long readMarkT = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
    BOOL isSuccess = [[XmppImManager sharedInstance] sendClearAllMsgStateByReadMarkT:readMarkT * 1000];
    if (isSuccess) {
        [[IMDataManager sharedInstance] updateAllMsgWithMsgState:MessageState_didRead ByMsgDirection:MessageDirection_Received ByReadMarkT:readMarkT * 1000];
        [self.notReadMsgDic removeAllObjects];
        //去 at all
        [self.hasAtAllDic removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"clearAllNoRead: 抛出通知 kMsgNotReadCountChange");
            [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@"ForceRefresh"];
            QIMVerboseLog(@"抛出通知 clearAllNoRead: kAtALLChange");
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtALLChange object:@"allIds"];
        });
    }
}

- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid{
    if (jid.length <= 0 && realJid.length <= 0) {
        return;
    }
    
    NSArray *notReadMsgList = [[IMDataManager sharedInstance] qimDB_getNotReadMsgListForUserId:jid ForRealJid:realJid];
    if (notReadMsgList.count <= 0) {
        
        return;
    }
    /*
    NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *infoDic in msgDicList) {
        
        //过滤阅后即焚消息
        if ([[infoDic objectForKey:@"MsgType"] intValue] == QIMMessageType_BurnAfterRead && [[infoDic objectForKey:@"MsgState"] intValue] >= MessageState_didRead) {
            continue;
        }
        Message *msg = [Message new];
        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
        [msg setFrom:[infoDic objectForKey:@"From"]];
        [msg setTo:[infoDic objectForKey:@"To"]];
        [msg setMessage:[infoDic objectForKey:@"Content"]];
        [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msgList addObject:msg];
    }
    */
    [self sendReadStateWithMessagesIdArray:notReadMsgList WithXmppId:jid WithRealJid:realJid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid {
    
    if (jid.length <= 0) {
        return;
    }

    NSArray *msgList = [[IMDataManager sharedInstance] qimDB_getNotReadMsgListForUserId:jid];
    /*
    if (msgDicList.count <= 0) {
        
        return;
    }
    NSMutableArray *msgList = [NSMutableArray arrayWithCapacity:1];
    
    for (NSDictionary *infoDic in msgDicList) {
        
        //过滤阅后即焚消息
        if ([[infoDic objectForKey:@"MsgType"] intValue] == QIMMessageType_BurnAfterRead && [[infoDic objectForKey:@"MsgState"] intValue] >= MessageState_didRead) {
            continue;
        }
        Message *msg = [Message new];
        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
        [msg setFrom:[infoDic objectForKey:@"From"]];
        [msg setTo:[infoDic objectForKey:@"To"]];
        [msg setMessage:[infoDic objectForKey:@"Content"]];
        [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msgList addObject:msg];
    } */
    [self sendReadStateWithMessagesIdArray:msgList WithXmppId:jid];
}

- (void)clearNotReadMsgByGroupId:(NSString *)groupId {
    
    [self removeAtMeByJid:groupId];
    [self getMsgListByUserId:groupId WithRealJid:nil WihtLimit:1 WithOffset:0 WihtComplete:^(NSArray *list) {
        
        if (list.count) {
            
            Message *message = list.lastObject;
            [self sendReadstateWithGroupLastMessageTime:[message messageDate] + 1 withGroupId:groupId];
        }
    }];
}

//更新消息
- (void)updateMsg:(Message *)msg ByJid:(NSString *)sid {
    
    //时间消息 不存
    if ([msg isKindOfClass:[NSString class]]) {
        
        return;
    }
    
    //存储 消息
    if ([msg isKindOfClass:[NSString class]] == FALSE) {
        
        NSString *messageId = msg.messageId;
        
        NSString *from = (msg.chatType == ChatType_GroupChat) ? msg.nickName : msg.from;
        
        NSString *to = msg.to;
        
        NSString *content = nil;
        content = msg.message;
        /*
        if ([[QIMMessageManager sharedInstance] getRegisterMsgCellClassForMessageType:msg.messageType]) {
            
            content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
        }
        */
        
        NSString *extendInfo = msg.extendInformation;
        int msgType = msg.messageType;
        
        long long msgState = msg.messageState;
        
        int msgDirection = msg.messageDirection;
        
        long long msgDate = msg.messageDate;
        int propress = msg.propress;
        
        [[IMDataManager sharedInstance] updateMessageWihtMsgId:messageId WithSessionId:sid WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:0 ExtendedFlag:propress WithMsgRaw:msg.msgRaw];
    }
}

- (void)deleteMsg:(Message *)msg ByJid:(NSString *)sid {
    
    [[IMDataManager sharedInstance] deleteMessageByMessageId:msg.messageId ByJid:sid];
}

/**
 此消息 当是二人会话的时候，messageId会被拼在一起
 当是群消息的时候，会取数组中最后一条消息的id进行time查询
 @param messages messages
 @param xmppId xmppId
 */
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (NSString *msgId in messages) {
        if (msgId.length > 0) {
            [resultArray addObject:@{@"id": msgId}];
        }
    }
    NSString *jsonString = [[QIMJSONSerializer sharedInstance] serializeObject:resultArray];
    BOOL isSuccess = [[XmppImManager sharedInstance] sendReadStateWithMessagesIdArray:jsonString WihtXmppId:[NSString stringWithFormat:@"%@;%@",xmppId,realJid]];
    if (isSuccess) {
        [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_didRead ByMsgIdList:resultArray];
        [self decrementNotReadMsgCountByJid:xmppId WithReadJid:realJid];
        [self updateNotReadCountCacheByJid:xmppId WithRealJid:realJid];
    }
    return isSuccess;
}

- (BOOL)sendControlStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId {

    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (NSString *msgId in messages) {
        if (msgId.length > 0) {
            [resultArray addObject:@{@"id": msgId}];
        }
    }
    NSString *jsonString = [[QIMJSONSerializer sharedInstance] serializeObject:resultArray];
//    BOOL isSuccess = [[XmppImManager sharedInstance] sendControlStateWithMessagesIdArray:jsonString WihtXmppId:xmppId];
    BOOL isSuccess = [[XmppImManager sharedInstance] sendControlStateWithMessagesIdArray:jsonString WithXmppid:xmppId];
    if (isSuccess) {
        [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_didControl ByMsgIdList:resultArray];
        [self decrementNotReadMsgCountByJid:xmppId];
        [self updateNotReadCountCacheByJid:xmppId];
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"抛出通知 removeAtAllByJid: kAtALLChange");
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtALLChange object:xmppId];
        });
    }
    return isSuccess;
}

/**
 此消息 当是二人会话的时候，messageId会被拼在一起
 当是群消息的时候，会取数组中最后一条消息的id进行time查询
 @param messages messages
 @param xmppId xmppId
 */
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithXmppId:(NSString *)xmppId {
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (NSString *msgId in messages) {
        if (msgId.length > 0) {
            [resultArray addObject:@{@"id": msgId}];
        }
    }
    NSString *jsonString = [[QIMJSONSerializer sharedInstance] serializeObject:resultArray];
    BOOL isSuccess = [[XmppImManager sharedInstance] sendReadStateWithMessagesIdArray:jsonString WihtXmppId:xmppId];
    if (isSuccess) {
        [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_didRead ByMsgIdList:resultArray];
        [self decrementNotReadMsgCountByJid:xmppId];
        [self updateNotReadCountCacheByJid:xmppId];
        [self.hasAtAllDic removeObjectForKey:xmppId];
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"抛出通知 removeAtAllByJid: kAtALLChange");
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtALLChange object:xmppId];
        });
    }
    return isSuccess;
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
        [[IMDataManager sharedInstance] qimDB_updateGroupMsgWihtMsgState:MessageState_didRead ByGroupMsgList:@[@{@"id": groupName, @"domain": domain, @"t": @(lastTime)}]];
        [self decrementNotReadMsgCountByJid:groupId];
        [self updateNotReadCountCacheByJid:groupId];
        [self.hasAtMeDic removeObjectForKey:groupId];
        [self.hasAtAllDic removeObjectForKey:groupId];
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"抛出通知 removeAtAllByJid: kAtALLChange");
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtALLChange object:groupId];
        });
        
    }
    return isSuccess;
}

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid {
    
    
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [msgDict setQIMSafeObject:userId forKey:@"id"];
    [msgDict setQIMSafeObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"timestamp"];
    [msgDict setQIMSafeObject:realJid forKey:@"realjid"];
    [msgDict setQIMSafeObject:[self getChatTypeStr:chatType] forKey:@"type"];
    if (chatType == ConsultChat) {
        [msgDict setQIMSafeObject:@"4" forKey:@"qchatid"];
    } else if (chatType == ConsultServerChat) {
        [msgDict setQIMSafeObject:@"5" forKey:@"qchatid"];
    } else {
        
    }
    NSString *msg = [[QIMJSONSerializer sharedInstance] serializeObject:msgDict];
    NSMutableDictionary *presenceMsgDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [presenceMsgDict setQIMSafeObject:@(QIMCategoryNotifyMsgTypeSession) forKey:@"PresenceMsgType"];
    [presenceMsgDict setQIMSafeObject:msg forKey:@"PresenceMsg"];
    [[XmppImManager sharedInstance] sendNotifyPresenceMsg:presenceMsgDict ToJid:[[QIMManager sharedInstance] getLastJid]];
}

#pragma mark - Share Location

- (Message *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WihtMsgType:(int)msgType {
    Message *mesg = [Message new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:MessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    NSString *msgRaw = nil;
    [[XmppImManager sharedInstance] sendShareLocationMessage:msg WithInfo:info toJid:jid WithMsgId:mesg.messageId WithMsgType:msgType WithChatId:nil OutMsgRaw:&msgRaw];
    if (msgRaw.length > 0) {
        [[IMDataManager sharedInstance] updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

- (Message *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId {
    if (shareLocationId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:shareLocationId forKey:@"shareId"];
        [dic setObject:[self getLastJid] forKey:@"fromId"];
        NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
        return [self sendMessage:@"发起了位置共享,请升级最新App客户端查看。" WithInfo:extendInfo ToUserId:userId WihtMsgType:QIMMessageType_shareLocation];
    }
    return nil;
}

- (Message *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId {
    if (shareLocationId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:shareLocationId forKey:@"shareId"];
        [dic setObject:[self getLastJid] forKey:@"fromId"];
        NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
        return [self sendMessage:@"发起了位置共享,请升级最新App客户端查看。" WithInfo:extendInfo ToGroupId:GroupId WihtMsgType:QIMMessageType_shareLocation];
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

#pragma mark - 数据库更新 或者 保存消息

//存储消息
- (void)saveMsg:(Message *)msg ByJid:(NSString *)xmppId {
    
    //时间消息 不存
    if ([msg isKindOfClass:[NSString class]]) {
        
        return;
    }
    /*
    if ([[[QIMMessageManager sharedInstance] getSupportMsgTypeList] containsObject:@(msg.messageType)]) {
        msg.message = msg.extendInformation.length > 0? msg.extendInformation:msg.message;
    }
    */
    //存储 消息
    if ([msg isKindOfClass:[NSString class]] == FALSE) {

        NSString *messageId = msg.messageId;
        
        NSString *from = (msg.chatType == ChatType_GroupChat) ? msg.nickName : msg.from;
        
        NSString *to = msg.to;
        
        NSString *content = nil;
        
        content = msg.message;
        /*
        if ([[QIMMessageManager sharedInstance] getRegisterMsgCellClassForMessageType:msg.messageType]) {
            content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
        }
        */
        
        NSString *extendInfo = msg.extendInformation;
        int msgType = msg.messageType;
        
        int msgState = msg.messageState;
        
        int msgDirection = msg.messageDirection;
        
        long long msgDate = msg.messageDate;
        
        if (msg.chatType == ChatType_PublicNumber) {
            if (msg.messageType == QIMMessageType_Consult || msg.messageType == QIMMessageType_ConsultResult || msg.messageType == QIMMessageType_MicroTourGuide) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            [[IMDataManager sharedInstance] insetPublicNumberMsgWihtMsgId:messageId WithSessionId:xmppId WithFrom:from WithTo:to WithContent:content WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:MessageState_didRead];
        } else if (msg.chatType == ChatType_CollectionChat) {
            if (msg.messageType == QIMMessageType_Consult || msg.messageType == QIMMessageType_ConsultResult || msg.messageType == QIMMessageType_MicroTourGuide) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            [[IMDataManager sharedInstance] insertMessageWihtMsgId:messageId WithXmppId:xmppId WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:msg.platform WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:0 WithMsgRaw:msg.msgRaw WithRealJid:msg.realJid WithChatType:ChatType_CollectionChat];
            
        } else if (msg.chatType == ChatType_System) {
            if (msg.messageType == MessageType_C2BGrabSingle || msg.messageType == MessageType_C2BGrabSingleFeedBack || msg.messageType == MessageType_QCZhongbao) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            [[IMDataManager sharedInstance] insertMessageWihtMsgId:messageId WithXmppId:xmppId WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:0 WithMsgRaw:msg.msgRaw WithRealJid:msg.realJid WithChatType:ChatType_System];
        } else {
            if (msg.messageType == QIMMessageType_Reply) {
                [[IMDataManager sharedInstance] insertFSMsgWithMsgId:messageId WithXmppId:xmppId WithFromUser:from WithReplyMsgId:msg.replyMsgId WithReplyUser:msg.replyUser WithContent:content WihtMsgDate:msgDate WithExtendedFlag:nil];
            }
            if (!msg.msgRaw) {
                NSDictionary *msgRawDict = @{@"content":msg.message?msg.message:@"", @"extendInfo":msg.extendInformation?msg.extendInformation:@"", @"localConvert":@(YES)};
                msg.msgRaw = [[QIMJSONSerializer sharedInstance] serializeObject:msgRawDict];
            }
            [[IMDataManager sharedInstance] insertMessageWihtMsgId:messageId WithXmppId:xmppId WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:msg.platform WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WihtMsgDate:msgDate WithReadedTag:0 WithMsgRaw:msg.msgRaw WithRealJid:msg.realJid WithChatType:msg.chatType];
        }
    }
}

- (void)setMsgSentFaild{
    NSArray *msgIds = [[IMDataManager sharedInstance] getMsgIdsForDirection:MessageDirection_Sent WithMsgState:MessageState_Waiting];
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

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid FromTimeStamp:(long long)timeStamp WihtComplete:(void (^)(NSArray *))complete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *array = [[IMDataManager sharedInstance] getMsgListByXmppId:userId WithRealJid:realJid FromTimeStamp:timeStamp];
        if (array.count > 0) {
            
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *infoDic in array) {
                Message *msg = [Message new];
                [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                [msg setFrom:[infoDic objectForKey:@"From"]];
                [msg setNickName:[infoDic objectForKey:@"From"]];
                [msg setTo:[infoDic objectForKey:@"To"]];
                [msg setMessage:[infoDic objectForKey:@"Content"]];
                NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
                [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
                [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
        }
    });
}

- (void)getMsgListByUserId:(NSString *)userId FromTimeStamp:(long long)timeStamp WihtComplete:(void (^)(NSArray *))complete {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *array = [[IMDataManager sharedInstance] getMsgListByXmppId:userId FromTimeStamp:timeStamp];
        if (array.count > 0) {
            
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *infoDic in array) {
                Message *msg = [Message new];
                [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                [msg setFrom:[infoDic objectForKey:@"From"]];
                [msg setNickName:[infoDic objectForKey:@"From"]];
                [msg setTo:[infoDic objectForKey:@"To"]];
                [msg setMessage:[infoDic objectForKey:@"Content"]];
                NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
                [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
                [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
        }
    });
}

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    NSArray *msgIdList = nil;
    if (realJid.length > 0) {
        msgIdList = [[IMDataManager sharedInstance] qimDB_getNotReadMsgListForUserId:userId ForRealJid:realJid];
    } else {
        msgIdList = [[IMDataManager sharedInstance] qimDB_getNotReadMsgListForUserId:userId];
    }
    return msgIdList;
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WihtLimit:(int)limit WithOffset:(int)offset WihtComplete:(void (^)(NSArray *))complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *array = [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:userId WithRealJid:realJid WithLimit:limit WihtOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *infoDic in array) {
                Message *msg = [Message new];
                [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                [msg setFrom:[infoDic objectForKey:@"From"]];
                [msg setNickName:[infoDic objectForKey:@"From"]];
                [msg setTo:[infoDic objectForKey:@"To"]];
                NSString *msgContent = [infoDic objectForKey:@"Content"];
                [msg setMessage:msgContent];
                NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
                [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
                [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
            if (list.count < limit) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    if ([userId rangeOfString:@"@conference."].location != NSNotFound) {
                        NSString *groupName = [[[userId componentsSeparatedByString:@"@"] objectAtIndex:0] copy];
#pragma mark - 这里开始拉取群翻页消息
                        if (groupName) {
                            NSArray *resultList = [self getMucMsgListWihtGroupId:userId WithDirection:0 WithLimit:limit WithVersion:[[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:userId]];
                            NSString *date1Str = [resultList.lastObject objectForKey:@"time"][@"stamp"];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                            NSDate *date1 = [dateFormatter dateFromString:date1Str];
                            NSNumber *readMarkT = [NSNumber numberWithLong:[date1 timeIntervalSince1970]];
                            
                            if (resultList.count > 0) {
                                
                                NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                                [[IMDataManager sharedInstance] bulkInsertIphoneMucJSONMsg:resultList WihtMyNickName:[self getMyNickName] WithReadMarkT:[readMarkT longLongValue] WithDidReadState:MessageState_didRead WihtMyRtxId:[self getLastJid]];
                            }
                        } else {
#pragma mark - 这里开始拉取单人翻页消息
                            NSArray *result = [self getUserChatlogWithFrom:userId to:[self getLastJid] version:[[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:userId] count:limit direction:0];
                            if (result.count > 0) {
                                NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                                NSArray *datas = [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:result WithXmppId:userId WithDidReadState:MessageState_didRead];
                                
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
        }
        else {
            
            if (self.load_history_msg == nil) {
                
                self.load_history_msg = dispatch_queue_create("Load History", 0);
            }
            dispatch_async(self.load_history_msg, ^{
                
                if ([userId rangeOfString:@"@conference."].location != NSNotFound) {
                    long long version = [[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:userId] - timeChange;
                    int direction = 0;
                    NSNumber *readMarkT = nil;
                    NSArray *resultList = [self getMucMsgListWihtGroupId:userId WithDirection:direction WithLimit:version < 0 ? (direction == 0 ? 20 : limit) : limit WithVersion:version < 0 ? (direction == 0 ? INT64_MAX : 0) : version];
                        NSString *date1Str = [resultList.lastObject objectForKey:@"time"][@"stamp"];
                        //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ss"];
                        NSDate *date1 = [dateFormatter dateFromString:date1Str];
                        readMarkT = [NSNumber numberWithLong:[date1 timeIntervalSince1970]];
                    if (resultList.count > 0) {
                        NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                        NSArray *datas = [[IMDataManager sharedInstance] bulkInsertIphoneMucJSONMsg:resultList WihtMyNickName:[self getMyNickName] WithReadMarkT:[readMarkT longLongValue] WithDidReadState:MessageState_didRead WihtMyRtxId:[self getLastJid]];
                        NSMutableArray *list = [NSMutableArray array];
                        for (NSDictionary *infoDic in datas) {
                            Message *msg = [Message new];
                            
                            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                            [msg setFrom:[infoDic objectForKey:@"From"]];
                            [msg setTo:[infoDic objectForKey:@"To"]];
                            [msg setMessage:[infoDic objectForKey:@"Content"]];
                            NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                            [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                            [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                            [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                            [msg setNickName:[infoDic objectForKey:@"From"]];
                            [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
                            [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
                            [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                            [list addObject:msg];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(list);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(@[]);
                        });
                    }
                } else {
                    NSArray *result = [self getUserChatlogWithFrom:userId to:[self getLastJid] version:[[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:userId] count:limit direction:0];
                    if (result.count > 0) {
                        NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                        NSArray *datas = [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:result WithXmppId:userId WithDidReadState:MessageState_didRead];
                        NSMutableArray *list = [NSMutableArray array];
                        NSString *channelInfo = nil;
                        NSString *buInfo = nil;
                        NSString *cctextInfo = nil;
                        for (NSDictionary *infoDic in datas) {
                            Message *msg = [Message new];
                            [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                            [msg setFrom:[infoDic objectForKey:@"From"]];
                            [msg setNickName:[infoDic objectForKey:@"From"]];
                            [msg setTo:[infoDic objectForKey:@"To"]];
                            [msg setMessage:[infoDic objectForKey:@"Content"]];
                            NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                            [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                            [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                            [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                            [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                            [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                            [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                            [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                            [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
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
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(list);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            complete(@[]);
                        });
                    }
                }
            });
        }
    });
}

- (void)getConsultServerMsgLisByUserId:(NSString *)userId WithVirtualId:(NSString *)virtualId WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:virtualId WithRealJid:userId WithLimit:limit WihtOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray arrayWithCapacity:5];
            for (NSDictionary *infoDic in array) {
                Message *msg = [Message new];
                [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                [msg setFrom:[infoDic objectForKey:@"From"]];
                [msg setNickName:[infoDic objectForKey:@"From"]];
                [msg setTo:[infoDic objectForKey:@"To"]];
                [msg setMessage:[infoDic objectForKey:@"Content"]];
                NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                [msg setReplyMsgId:[infoDic objectForKey:@"ReplyMsgId"]];
                [msg setReadTag:[[infoDic objectForKey:@"ReadTag"] intValue]];
                [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                [list addObject:msg];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(list);
            });
            if (list.count < limit) {
                if (self.load_history_msg == nil) {
                    self.load_history_msg = dispatch_queue_create("Load History", 0);
                }
                dispatch_async(self.load_history_msg, ^{
                    long long version = [[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:virtualId RealJid:userId] - timeChange;
                    
                    NSArray *result = [self getConsultServerlogWithFrom:userId virtualId:virtualId to:[self getLastJid] version:version count:(int)(limit - list.count) direction:MessageDirection_Received];
                    if (result.count > 0) {
                        NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                        [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:result to:[QIMManager getLastUserName] WithDidReadState:MessageState_didRead];
                    }
                });
            }
        } else {
            if (self.load_history_msg == nil) {
                self.load_history_msg = dispatch_queue_create("Load History", 0);
            }
            dispatch_async(self.load_history_msg, ^{
                long long version = [[IMDataManager sharedInstance] getMinMsgTimeStampByXmppId:virtualId RealJid:userId] - timeChange;
                NSArray *resultList = [self getConsultServerlogWithFrom:userId virtualId:virtualId to:[self getLastJid] version:version count:limit direction:MessageDirection_Received];
                
                if (resultList.count > 0) {
                    NSArray *msgTypeList = [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
                    [[IMDataManager sharedInstance] bulkInsertHistoryChatJSONMsg:resultList to:[QIMManager getLastUserName] WithDidReadState:MessageState_didRead];
                    NSArray *datas = [[IMDataManager sharedInstance] qimDB_getMgsListBySessionId:virtualId WithRealJid:userId WithLimit:limit WihtOffset:offset];
                    NSMutableArray *list = [NSMutableArray array];
                    for (NSDictionary *infoDic in datas) {
                        Message *msg = [Message new];
                        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
                        [msg setFrom:[infoDic objectForKey:@"From"]];
                        [msg setTo:[infoDic objectForKey:@"To"]];
                        [msg setMessage:[infoDic objectForKey:@"Content"]];
                        NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
                        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
                        [msg setPlatform:[[infoDic objectForKey:@"Platform"] intValue]];
                        [msg setMessageType:[[infoDic objectForKey:@"MsgType"] intValue]];
                        [msg setMessageState:[[infoDic objectForKey:@"MsgState"] intValue]];
                        [msg setMessageDirection:[[infoDic objectForKey:@"MsgDirection"] intValue]];
                        [msg setMessageDate:[[infoDic objectForKey:@"MsgDateTime"] longLongValue]];
                        [msg setPropress:[[infoDic objectForKey:@"ExtendedFlag"] floatValue]];
                        [msg setMsgRaw:[infoDic objectForKey:@"msgRaw"]];
                        [list addObject:msg];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(list);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(@[]);
                    });
                }
            });
        }
    });
}

- (NSArray *)getFSMsgByXmppId:(NSString *)xmppId {
    NSArray *list = [[IMDataManager sharedInstance] getFSMsgListByXmppId:xmppId];
    NSMutableArray *resultList = [NSMutableArray array];
    for (NSDictionary *infoDic in list) {
        NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
        Message *msg = [Message new];
        [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
        [msg setXmppId:[infoDic objectForKey:@"XmppId"]];
        [msg setFrom:[infoDic objectForKey:@"From"]];
        [msg setNickName:[infoDic objectForKey:@"From"]];
        [msg setTo:[infoDic objectForKey:@"To"]];
        [msg setMessage:[infoDic objectForKey:@"Content"]];
        NSString *extendInfo = [infoDic objectForKey:@"ExtendInfo"];
        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
        [msg setMessageType:[[infoDic objectForKey:@"Type"] intValue]];
        [msg setMessageDate:[[infoDic objectForKey:@"MsgDate"] longLongValue]];
        [msg setMessageState:[[infoDic objectForKey:@"State"] intValue]];
        [msg setMessageDirection:[[infoDic objectForKey:@""] intValue]];
        [messageDic setObject:msg forKey:@"MainMsg"];
        NSMutableArray *replyArray = [NSMutableArray array];
        NSArray *replyList = [infoDic objectForKey:@"ReplyMsgList"];
        for (NSDictionary *dic in replyList) {
            Message *msg = [Message new];
            [msg setMessageId:[dic objectForKey:@"MsgId"]];
            [msg setMessage:[dic objectForKey:@"content"]];
            [msg setMessageType:QIMMessageType_Text];
            [msg setFrom:[dic objectForKey:@"fromUser"]];
            [msg setMessageDate:[[dic objectForKey:@"MsgDate"] longLongValue]];
            [msg setFromUser:[dic objectForKey:@"fromUser"]];
            [msg setReplyMsgId:[dic objectForKey:@"replyMsgId"]];
            [msg setReplyUser:[dic objectForKey:@"replyUser"]];
            [replyArray addObject:msg];
        }
        [messageDic setObject:replyArray forKey:@"ReplyMsgList"];
        [resultList addObject:messageDic];
    }
    
    return resultList;
}

- (NSDictionary *)getFSMsgByMsgId:(NSString *)msgId {
    NSDictionary *infoDic = [[IMDataManager sharedInstance] getFSMsgListByReplyMsgId:msgId];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    Message *msg = [Message new];
    [msg setMessageId:[infoDic objectForKey:@"MsgId"]];
    [msg setXmppId:[infoDic objectForKey:@"XmppId"]];
    [msg setFrom:[infoDic objectForKey:@"From"]];
    [msg setNickName:[infoDic objectForKey:@"From"]];
    [msg setTo:[infoDic objectForKey:@"To"]];
    [msg setMessage:[infoDic objectForKey:@"Content"]];
    [msg setExtendInformation:[infoDic objectForKey:@"ExtendInfo"]];
    [msg setMessageType:[[infoDic objectForKey:@"Type"] intValue]];
    [msg setMessageDate:[[infoDic objectForKey:@"MsgDate"] longLongValue]];
    [msg setMessageState:[[infoDic objectForKey:@"State"] intValue]];
    [msg setMessageDirection:[[infoDic objectForKey:@""] intValue]];
    [dic setObject:msg forKey:@"MainMsg"];
    
    NSMutableArray *replyArray = [NSMutableArray array];
    NSArray *replyList = [infoDic objectForKey:@"ReplyMsgList"];
    for (NSDictionary *itemDic in replyList) {
        Message *itemMsg = [Message new];
        [itemMsg setMessageId:[itemDic objectForKey:@"MsgId"]];
        [itemMsg setMessage:[itemDic objectForKey:@"content"]];
        [itemMsg setMessageType:QIMMessageType_Text];
        [itemMsg setMessageDate:[[itemDic objectForKey:@"MsgDate"] longLongValue]];
        [itemMsg setFromUser:[itemDic objectForKey:@"fromUser"]];
        [itemMsg setReplyMsgId:[itemDic objectForKey:@"replyMsgId"]];
        [itemMsg setReplyUser:[itemDic objectForKey:@"replyUser"]];
        [replyArray addObject:itemMsg];
    }
    [dic setObject:replyArray forKey:@"ReplyMsgList"];
    
    return dic;
}

#pragma mark - 历史消息监测

- (void)checkOfflineMsg {
    QIMVerboseLog(@"检查本地是否有错误时间戳");
    [self checkSingleChatMsg];
    [self checkGroupChatMsg];
    [self checkHeadlineMsg];
}

- (NSMutableArray *)searchLocalMessageByKeyword:(NSString *)keyWord XmppId:(NSString *)xmppid RealJid:(NSString *)realJid {
    return [[IMDataManager sharedInstance] qimDB_searchLocalMessageByKeyword:keyWord XmppId:xmppid RealJid:realJid];
}

#pragma mark - 本地消息搜索

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager sharedInstance] qimDB_getLocalMediaByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *msgInfoDic in array) {
        Message *msg = [Message new];
        [msg setMessageId:[msgInfoDic objectForKey:@"MsgId"]];
        [msg setFrom:[msgInfoDic objectForKey:@"From"]];
        [msg setTo:[msgInfoDic objectForKey:@"To"]];
        [msg setMessage:[msgInfoDic objectForKey:@"Content"]];
        NSString *extendInfo = [msgInfoDic objectForKey:@"ExtendInfo"];
        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
        [msg setPlatform:[[msgInfoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[msgInfoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[msgInfoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[msgInfoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[msgInfoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msg setXmppId:[msgInfoDic objectForKey:@"XmppId"]];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager sharedInstance] qimDB_getMsgsByMsgType:msgTypes ByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *msgInfoDic in array) {
        Message *msg = [Message new];
        [msg setMessageId:[msgInfoDic objectForKey:@"MsgId"]];
        [msg setFrom:[msgInfoDic objectForKey:@"From"]];
        [msg setTo:[msgInfoDic objectForKey:@"To"]];
        [msg setMessage:[msgInfoDic objectForKey:@"Content"]];
        NSString *extendInfo = [msgInfoDic objectForKey:@"ExtendInfo"];
        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
        [msg setPlatform:[[msgInfoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[msgInfoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[msgInfoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[msgInfoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[msgInfoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msg setXmppId:[msgInfoDic objectForKey:@"XmppId"]];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager sharedInstance] qimDB_getMsgsByKeyWord:keyWork ByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *msgInfoDic in array) {
        Message *msg = [Message new];
        [msg setMessageId:[msgInfoDic objectForKey:@"MsgId"]];
        [msg setFrom:[msgInfoDic objectForKey:@"From"]];
        [msg setTo:[msgInfoDic objectForKey:@"To"]];
        [msg setMessage:[msgInfoDic objectForKey:@"Content"]];
        NSString *extendInfo = [msgInfoDic objectForKey:@"ExtendInfo"];
        [msg setExtendInformation:(extendInfo.length > 0) ? extendInfo : nil];
        [msg setPlatform:[[msgInfoDic objectForKey:@"Platform"] intValue]];
        [msg setMessageType:[[msgInfoDic objectForKey:@"MsgType"] intValue]];
        [msg setMessageState:[[msgInfoDic objectForKey:@"MsgState"] intValue]];
        [msg setMessageDirection:[[msgInfoDic objectForKey:@"MsgDirection"] intValue]];
        [msg setMessageDate:[[msgInfoDic objectForKey:@"MsgDateTime"] longLongValue]];
        [msg setXmppId:[msgInfoDic objectForKey:@"XmppId"]];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId {
    return [self getMsgsForMsgType:msgTypes ByXmppId:xmppId ByReadJid:nil];
}

@end
