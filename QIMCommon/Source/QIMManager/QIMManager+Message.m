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
- (NSDictionary *)createMessageDictWithMessage:(QIMMessageModel *)message {
    
    NSDictionary *msgDict = [message yy_modelToJSONObject];
    return msgDict;
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType {
    
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:nil];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType backinfo:(NSString *)backInfo {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO withFrontInsert:YES];
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setBackupInfo:backInfo];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:nil];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:userId];
    }
    [mesg setMessageDate:msgDate];
    [mesg setMessageSendState:QIMMessageSendState_Waiting];
    [mesg setExtendInformation:extendInfo];
    [self saveMsg:mesg ByJid:userId];
    return mesg;
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId {
    
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId userType:userType msgType:msgType forMsgId:mId willSave:YES];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    return [self createMessageWithMsg:msg extenddInfo:extendInfo userId:userId realJid:nil userType:userType msgType:msgType forMsgId:mId willSave:willSave];
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId msgState:(QIMMessageSendState)msgState willSave:(BOOL)willSave {
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO withFrontInsert:YES];
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:mId.length ? mId : [QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setRealJid:realJid];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:realJid?realJid:userId];
    }
//    if (userType == ChatType_GroupChat) {
//        [mesg setNickName:[[QIMManager sharedInstance] getLastJid]];
//    }
    [mesg setMessageDate:msgDate];
    if (msgState) {
        [mesg setMessageSendState:msgState];
    } else {
        [mesg setMessageSendState:QIMMessageSendState_Waiting];
    }
    [mesg setExtendInformation:extendInfo];
    if (willSave) {
        [self saveMsg:mesg ByJid:userId];
    }
    return mesg;
}

- (QIMMessageModel *)createMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo userId:(NSString *)userId realJid:(NSString *)realJid userType:(ChatType)userType msgType:(QIMMessageType)msgType forMsgId:(NSString *)mId willSave:(BOOL)willSave {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:YES withFrontInsert:YES];
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:mId.length ? mId : [QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:userType];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setXmppId:userId];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    if (userType == ChatType_Consult) {
        [mesg setRealJid:userId];
    } else {
        [mesg setRealJid:realJid?realJid:userId];
    }
    [mesg setMessageDate:msgDate];
    [mesg setMessageSendState:QIMMessageSendState_Waiting];
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
    
    [resultParams setQIMSafeObject:content forKey:@"body"];
    [resultParams setQIMSafeObject:[[QIMManager sharedInstance] getLastJid] forKey:@"from"];
    NSDictionary *channelId = @{@"cn":@"consult", @"d":@"send", @"usrType":@"usr"};
    [resultParams setQIMSafeObject:@[@{@"user" : targetID}] forKey:@"to"];
    [resultParams setQIMSafeObject:[NSString stringWithFormat:@"%d", msgType] forKey:@"msg_type"];
    //    [resultParams setQIMSafeObject:@"groupchat" forKey:@"type"];
    [resultParams setQIMSafeObject:key forKey:@"key"];
    [resultParams setQIMSafeObject:[NSString stringWithFormat:@"%d", time] forKey:@"count"];
    [resultParams setQIMSafeObject:extendInfo?extendInfo:@"" forKey:@"extend_info"];
    
    if (isGroup) {
        //群聊
        [resultParams setQIMSafeObject:@"groupchat" forKey:@"type"];
        
    } else {
        [resultParams setQIMSafeObject:@"chat" forKey:@"type"];
    }
    
    NSString *paramsStr = [[QIMJSONSerializer sharedInstance] serializeObject:@[resultParams]];
    QIMVerboseLog(@"快捷回复 URL : %@, 参数 : %@", url, paramsStr);
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[resultParams] options:NSJSONWritingPrettyPrinted error:&error];
    params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSMutableDictionary *cookieProperties = [[NSMutableDictionary alloc] init];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    [request setHTTPRequestHeaders:cookieProperties];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        QIMInfoLog(@"快捷回复返回结果： %@", response);
    } failure:^(NSError *error) {
        QIMErrorLog(@"快捷回复错误 : %@", error);
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
- (QIMMessageModel *)sendShockToUserId:(NSString *)userId {
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
    
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:QIMMessageType_Shock];
    [mesg setTo:userId];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
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

- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg ToUserId:(NSString *)userId {
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
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRaw];
    } else {
        NSDictionary *msgRawDict = @{@"content":msg.message?msg.message:@"", @"extendInfo":msg.extendInformation.length > 0?msg.extendInformation:@"", @"localConvert":@(YES)};
        NSString *msgRawStr = [[QIMJSONSerializer sharedInstance] serializeObject:msgRawDict];
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRawStr];
    }
    return msg;
}

- (QIMMessageModel *)sendMessage:(QIMMessageModel *)msg withChatType:(ChatType)chatType channelInfo:(NSString *)channelInfo realFrom:(NSString *)realFrom realTo:(NSString *)realTo ochatJson:(NSString *)ochatJson {
    [self updateMsg:msg ByJid:msg.to];
    NSString *msgRaw = nil;
    
    msg.channelInfo = channelInfo;
    msg.chatId = [self getChatIdByUserId:msg.to];
    msg.appendInfoDict = [self getAppendInfoForUserId:msg.to];
    NSDictionary *msgDict = [self createMessageDictWithMessage:msg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:msgDict];
    
    [self addSessionByType:msg.chatType ById:msg.to ByMsgId:msg.messageId WithMsgTime:msg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:msg.messageId WithMsgRaw:msgRaw];
    }
    return msg;
}

- (QIMMessageModel *)sendMessage:(NSString *)msg ToGroupId:(NSString *)groupId {
    
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setXmppId:groupId];
    [mesg setRealJid:groupId];
    [mesg setMessageType:QIMMessageType_Text];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    
    NSString *msgRaw = nil;
    NSDictionary *msgDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:msgDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType {
    
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setXmppId:groupId];
    [mesg setRealJid:groupId];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToGroupId:(NSString *)groupId WithMsgType:(int)msgType WithMsgId:(NSString *)msgId {
    
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:msgId];
    [mesg setXmppId:groupId];
    [mesg setRealJid:groupId];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    [mesg setChatType:ChatType_GroupChat];
    [mesg setTo:groupId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendGroupMessageWithMessageDict:messageDict];
    
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    
    return mesg;
}

- (QIMMessageModel *)sendMessage:(NSString *)msg WithInfo:(NSString *)info ToUserId:(NSString *)userId WithMsgType:(int)msgType {
    
    long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
    [self checkMsgTimeWithJid:userId WithMsgDate:msgDate WithGroup:NO withFrontInsert:YES];
    
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setXmppId:userId];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setChatType:ChatType_SingleChat];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setTo:userId];
    [mesg setRealJid:userId];
    [mesg setMessageDate:msgDate];
    [mesg setFrom:[[QIMManager sharedInstance] getLastJid]];
    [mesg setMessageDate:msgDate];
    [mesg setExtendInformation:info];
    [mesg setMessageSendState:QIMMessageSendState_Waiting];
    [mesg setChatId:[self getChatIdByUserId:userId]];
    [mesg setChannelInfo:[self getChancelInfoForUserId:userId]];
    [mesg setAppendInfoDict:[self getAppendInfoForUserId:userId]];
    [self saveMsg:mesg ByJid:userId];
    NSString *msgRaw = nil;
    
    NSDictionary *messageDict = [self createMessageDictWithMessage:mesg];
    [[XmppImManager sharedInstance] sendChatMessageWithMsgDict:messageDict];
    [self addSessionByType:ChatType_SingleChat ById:userId ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

// 发送音视频消息
- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid{
    QIMVerboseLog(@"===========音视频信息=========\r sendAudioVideoWithType ExtentInfo %@ ",extentInfo);
    [[XmppImManager sharedInstance] sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

#pragma mark - Share Location

- (QIMMessageModel *)sendShareLocationMessage:(NSString *)msg WithInfo:(NSString *)info ToJid:(NSString *)jid WithMsgType:(int)msgType {
    QIMMessageModel *mesg = [QIMMessageModel new];
    [mesg setMessageId:[QIMUUIDTools UUID]];
    [mesg setMessageType:msgType];
    [mesg setMessageDirection:QIMMessageDirection_Sent];
    [mesg setMessage:msg];
    [mesg setExtendInformation:info];
    NSString *msgRaw = nil;
    [[XmppImManager sharedInstance] sendShareLocationMessage:msg WithInfo:info toJid:jid WithMsgId:mesg.messageId WithMsgType:msgType WithChatId:nil OutMsgRaw:&msgRaw];
    if (msgRaw.length > 0) {
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:mesg.messageId WithMsgRaw:msgRaw];
    }
    return mesg;
}

- (QIMMessageModel *)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId {
    if (shareLocationId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:shareLocationId forKey:@"shareId"];
        [dic setObject:[self getLastJid] forKey:@"fromId"];
        NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
        return [self sendMessage:@"发起了位置共享,请升级最新App客户端查看。" WithInfo:extendInfo ToUserId:userId WithMsgType:QIMMessageType_shareLocation];
    }
    return nil;
}

- (QIMMessageModel *)beginShareLocationToGroupId:(NSString *)GroupId WithShareLocationId:(NSString *)shareLocationId {
    if (shareLocationId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:shareLocationId forKey:@"shareId"];
        [dic setObject:[self getLastJid] forKey:@"fromId"];
        NSString *extendInfo = [[QIMJSONSerializer sharedInstance] serializeObject:dic];
        return [self sendMessage:@"发起了位置共享,请升级最新App客户端查看。" WithInfo:extendInfo ToGroupId:GroupId WithMsgType:QIMMessageType_shareLocation];
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

- (NSArray *)getMsgsForMsgType:(QIMMessageType)msgType {
    NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgsByMsgType:msgType];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *infoDic in array) {
        QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSDictionary *)getMsgDictByMsgId:(NSString *)msgId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getMsgsByMsgId:msgId];
}

- (QIMMessageModel *)getMsgByMsgId:(NSString *)msgId {
    NSDictionary *infoDic = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgsByMsgId:msgId];
    if (infoDic.count > 0) {
        QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
        return msg;
    }
    return nil;
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag{
    [self checkMsgTimeWithJid:jid WithRealJid:realJid WithMsgDate:msgDate WithGroup:flag withFrontInsert:NO];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag {
    [self checkMsgTimeWithJid:jid WithMsgDate:msgDate WithGroup:flag withFrontInsert:NO];
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag withFrontInsert:(BOOL)frontInsert {
    NSString *key = [NSString stringWithFormat:@"%@-%@",jid,realJid];
    NSNumber *globalMsgDate = [self.timeStempDic objectForKey:key];
    if (msgDate - globalMsgDate.longLongValue >= 2 * 60 * 1000) {
        [self.timeStempDic setObject:@(msgDate) forKey:jid];
        NSDate*date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        QIMMessageModel *msg = [QIMMessageModel new];
        [msg setFrom:jid];
        [msg setXmppId:jid];
        [msg setMessageId:[[IMDataManager qimDB_SharedInstance] qimDB_getTimeSmtapMsgIdForDate:date WithUserId:key]];
        [msg setMessageType:QIMMessageType_Time];
        [msg setMessageDate:msgDate-1];
        [msg setRealJid:realJid];
        [msg setMessageSendState:QIMMessageSendState_Success];
        [msg setMessageReadState:QIMMessageRemoteReadStateGroupReaded|QIMMessageRemoteReadStateDidReaded];
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msg.messageId]) {
            return;
        }
        [self saveMsg:msg ByJid:jid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                object:key
                                                              userInfo:@{@"message":msg, @"frontInsert":@(frontInsert)}];
        });
    }
}

- (void)checkMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate WithGroup:(BOOL)flag withFrontInsert:(BOOL)frontInsert {
    if (!jid || msgDate < 0) {
        return;
    }
    NSNumber *globalMsgDate = [self.timeStempDic objectForKey:jid];
    if (msgDate - globalMsgDate.longLongValue >= 2 * 60 * 1000) {
        
        [self.timeStempDic setObject:@(msgDate) forKey:jid];
        QIMMessageModel *msg = [QIMMessageModel new];
        NSDate *date = [NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate];
        [msg setMessageId:[[IMDataManager qimDB_SharedInstance] qimDB_getTimeSmtapMsgIdForDate:date WithUserId:jid]];
        [msg setRealJid:jid];
        [msg setXmppId:jid];
        [msg setFrom:jid];
        [msg setMessageType:QIMMessageType_Time];
        [msg setMessageDate:msgDate - 1];
        [msg setMessageSendState:QIMMessageSendState_Success];
        [msg setMessageReadState:QIMMessageRemoteReadStateGroupReaded|QIMMessageRemoteReadStateDidReaded];
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msg.messageId]) {
            
            return;
        }
        [self saveMsg:msg ByJid:jid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate
                                                                object:jid
                                                              userInfo:@{@"message": msg, @"frontInsert":@(frontInsert)}];
        });
    }
}

#pragma mark - 未读消息

- (void)updateMsgReadCompensateSetWithMsgId:(NSString *)msgId WithAddFlag:(BOOL)flag WithState:(QIMMessageSendState)state {
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

- (void)updateMessageControlStateWithNewState:(QIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageControlStateUpdate" object:@{@"State":@(state), @"MsgIds":MsgIdList?MsgIdList:@[]}];
    });
}

- (void)updateMessageStateWithNewState:(QIMMessageSendState)state ByMsgIdList:(NSArray *)MsgIdList {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageStateUpdate" object:@{@"State":@(state), @"MsgIds":MsgIdList?MsgIdList:@[]}];
    });
}

- (void)updateNotReadCountCacheByJid:(NSString *)jid {
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMVerboseLog(@"updateNotReadCountCacheByJid: 抛出通知 kMsgNotReadCountChange");
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"XmppId":jid, @"RealJid":jid}];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
    });
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid withChatType:(ChatType)chatType {
    if (jid.length > 0 && realJid.length > 0) {
        NSInteger notReadCount = [[IMDataManager qimDB_SharedInstance] qimDB_getNotReaderMsgCountByJid:jid ByRealJid:realJid withChatType:chatType];
        return notReadCount;
    }
    return 0;
}

- (NSInteger)getNotReadMsgCountByJid:(NSString *)jid WithRealJid:(NSString *)realJid {
    if (jid.length > 0 && realJid.length > 0) {
        NSInteger notReadCount = [[IMDataManager qimDB_SharedInstance] qimDB_getNotReaderMsgCountByJid:jid ByRealJid:realJid];
        return notReadCount;
    }
    return 0;
}

- (void)updateAppNotReadCount {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger notReadCount = [[IMDataManager qimDB_SharedInstance] qimDB_getAppNotReadCount];
        NSInteger notRemindCount = [[QIMManager sharedInstance] getNotRemindNotReaderCount];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notReadCount-notRemindCount];
        });
    });
}

- (NSInteger)getAppNotReaderCount {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getAppNotReadCount];
}

- (NSInteger)getNotRemindNotReaderCount {
    NSInteger count = 0;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    //防止有些cell没有刷新到，字典中未包含GroupId，将未读数计算进去
    
    NSMutableArray *groupIdList = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *array = [[QIMManager sharedInstance] getClientConfigInfoArrayWithType:QIMClientConfigTypeKNoticeStickJidDic];
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
        count = [[IMDataManager qimDB_SharedInstance] qimDB_getSumNotReaderMsgCountByXmppIds:groupIdList];
    }
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    QIMVerboseLog(@"耗时 = %f s", end - start); //
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

- (void)getLeaveMsgNotReaderCountWithCallBack:(QIMKitGetLeaveMsgNotReaderCountBlock)callback {
    
    NSString *url = @"http://u.package.qunar.com/user/message/countUnreply.json";
    [self sendTPGETFormUrlEncodedRequestWithUrl:url withSuccessCallBack:^(NSData *responseData) {
        NSError *errol = nil;
        NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
        if ([resDic objectForKey:@"data"] != [NSNull null]) {
            int count = [[[resDic objectForKey:@"data"] objectForKey:@"count"] boolValue];
            if (callback) {
                callback(count);
            }
        } else {
            if (callback) {
                callback(0);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(0);
        }
    }];
}

- (void)clearSystemMsgNotReadWithJid:(NSString *)jid {
    
    if (jid.length <= 0) {
        
        return;
    }
    [[IMDataManager qimDB_SharedInstance] qimDB_updateSystemMsgState:QIMMessageSendState_Success withReadState:QIMMessageRemoteReadStateDidReaded WithXmppId:jid];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateNotReadCountCacheByJid:jid];
        QIMVerboseLog(@"clearSystemMsgNotReadWithJid: 抛出通知 kMsgNotReadCountChange");
    });
}

- (void)clearAllNoRead {
    long long readMarkT = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
    BOOL isSuccess = [[XmppImManager sharedInstance] sendClearAllMsgStateByReadMarkT:readMarkT * 1000];
    if (isSuccess) {
        NSDictionary *clearAllOnReadStateDic = [self getLocalAllOnReadStateInfoWithReadType:QIMMessageReadFlagClearAllUnRead ByReadMarkT:readMarkT * 1000];
        QIMVerboseLog(@"发送本地清除所有未读OnReadState : %@", clearAllOnReadStateDic);
        [self onReadState:clearAllOnReadStateDic];
    }
}

- (void)clearNotReadMsgByJid:(NSString *)jid ByRealJid:(NSString *)realJid{
    if (jid.length <= 0 && realJid.length <= 0) {
        return;
    }
    
    NSArray *notReadMsgList = [[IMDataManager qimDB_SharedInstance] qimDB_getNotReadMsgListForUserId:jid ForRealJid:realJid];
    if (notReadMsgList.count <= 0) {
        
        return;
    }
    [self sendReadStateWithMessagesIdArray:notReadMsgList WithMessageReadFlag:QIMMessageReadFlagDidRead WithXmppId:jid WithRealJid:realJid];
}

- (void)clearNotReadMsgByJid:(NSString *)jid {
    
    if (jid.length <= 0) {
        return;
    }
    
    NSArray *msgList = [[IMDataManager qimDB_SharedInstance] qimDB_getNotReadMsgListForUserId:jid];
    if (msgList.count > 0) {
        [self sendReadStateWithMessagesIdArray:msgList WithMessageReadFlag:QIMMessageReadFlagDidRead WithXmppId:jid];
    }
}

- (void)clearNotReadMsgByGroupId:(NSString *)groupId {
    
    long long groupLastTime = [[IMDataManager qimDB_SharedInstance] qimDB_getMaxMsgTimeStampByXmppId:groupId ByRealJid:groupId];
    [self sendReadstateWithGroupLastMessageTime:groupLastTime withGroupId:groupId];
}

#pragma mark - 阅读状态

- (NSDictionary *)getLocalAllOnReadStateInfoWithReadType:(QIMMessageReadFlag)readType ByReadMarkT:(long long)readMarkT {
    NSMutableDictionary *readInfoDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSDictionary *readMarkTDic = @{@"T":@(readMarkT)};
    NSString *readMarkTStr = [[QIMJSONSerializer sharedInstance] serializeObject:readMarkTDic];
    [readInfoDic setObject:readMarkTStr forKey:@"infoStr"];
    [readInfoDic setQIMSafeObject:@(readType) forKey:@"readType"];
    return readInfoDic;
}

- (NSDictionary *)getLocalOnReadStateInfoWithReadType:(QIMMessageReadFlag)readType withReadMsgList:(NSArray *)msgList withXmppId:(NSString *)xmppId {
    
    NSMutableDictionary *readInfoDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSString *readMsgListStr = [[QIMJSONSerializer sharedInstance] serializeObject:msgList];
    [readInfoDic setQIMSafeObject:readMsgListStr forKey:@"infoStr"];
    [readInfoDic setQIMSafeObject:xmppId forKey:@"jid"];
    [readInfoDic setQIMSafeObject:@(readType) forKey:@"readType"];
    return readInfoDic;
}

- (NSDictionary *)getLocalOnGroupReadStateInfoWithReadType:(QIMMessageReadFlag)readType withGroupId:(NSString *)groupId withReadMarkTime:(long long)readMarkTime {
    
    NSMutableDictionary *readInfoDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithCapacity:3];
    [infoDic setQIMSafeObject:[[groupId componentsSeparatedByString:@"@"] firstObject] forKey:@"id"];
    [infoDic setQIMSafeObject:[[groupId componentsSeparatedByString:@"@"] lastObject] forKey:@"domain"];
    [infoDic setQIMSafeObject:@(readMarkTime) forKey:@"t"];
    NSString *infoStr = [[QIMJSONSerializer sharedInstance] serializeObject:@[infoDic]];
    
    [readInfoDic setQIMSafeObject:infoStr forKey:@"infoStr"];
    [readInfoDic setQIMSafeObject:groupId forKey:@"jid"];
    [readInfoDic setQIMSafeObject:@(readType) forKey:@"readType"];
    return readInfoDic;
}

//更新所有消息阅读状态
- (void)updateAllLocalMsgWithMsgRemoteState:(NSInteger)remoteState ByReadMarkT:(long long)readMarkT {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateAllMsgWithMsgRemoteState:remoteState ByMsgDirection:1 ByReadMarkT:readMarkT];
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
    [[IMDataManager qimDB_SharedInstance] qimDB_clearAtMessageWithGroupId:xmppId];
    [[IMDataManager qimDB_SharedInstance] qimDB_updateGroupMessageRemoteState:remoteState ByGroupReadList:readList];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"XmppId":xmppId, @"RealJid":xmppId}];
    });
}

//更新单人消息阅读状态
- (void)updateLocalMessageRemoteState:(NSInteger)remoteState withXmppId:(NSString *)xmppId withRealJid:(NSString *)realJid ByMsgIdList:(NSArray *)msgIdList {
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgWithMsgRemoteState:remoteState ByMsgIdList:msgIdList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        QIMVerboseLog(@"发送消息RemoteState阅读状态变化通知 : %ld, %@", remoteState, msgIdList);
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
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(QIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId WithRealJid:(NSString *)realJid{
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:[messages count]];
    
    for (NSString *msgId in messages) {
        if (msgId.length > 0) {
            [resultArray addObject:@{@"id": msgId}];
        }
    }
    
    NSString *jsonString = [[QIMJSONSerializer sharedInstance] serializeObject:resultArray];
    BOOL isSuccess = [[XmppImManager sharedInstance] sendReadStateWithMessagesIdArray:jsonString WithMessageReadFlag:msgReadFlag WithXmppid:[NSString stringWithFormat:@"%@",xmppId] WithTo:xmppId withRealTo:realJid];
    if (isSuccess) {
        NSDictionary *readDic = [self getLocalOnReadStateInfoWithReadType:msgReadFlag withReadMsgList:resultArray withXmppId:xmppId];
        QIMVerboseLog(@"发送本地OnReadState : %@", readDic);
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
- (BOOL)sendReadStateWithMessagesIdArray:(NSArray *)messages WithMessageReadFlag:(QIMMessageReadFlag)msgReadFlag WithXmppId:(NSString *)xmppId {
    
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
        NSDictionary *groupOnReadStateDic = [self getLocalOnGroupReadStateInfoWithReadType:QIMMessageReadFlagGroupReaded withGroupId:groupId withReadMarkTime:lastTime];
        QIMVerboseLog(@"发送本地groupOnReadStateDic : %@", groupOnReadStateDic);
        [self onReadState:groupOnReadStateDic];
    }
    return isSuccess;
}

- (void)synchronizeChatSessionWithUserId:(NSString *)userId WithChatType:(ChatType)chatType WithRealJid:(NSString *)realJid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableDictionary *msgDict = [NSMutableDictionary dictionaryWithCapacity:5];
        [msgDict setQIMSafeObject:userId forKey:@"id"];
        [msgDict setQIMSafeObject:@([NSDate timeIntervalSinceReferenceDate]) forKey:@"timestamp"];
        [msgDict setQIMSafeObject:realJid forKey:@"realjid"];
        [msgDict setQIMSafeObject:[self getChatTypeStr:chatType] forKey:@"type"];
        if (chatType == ChatType_Consult) {
            [msgDict setQIMSafeObject:@"4" forKey:@"qchatid"];
        } else if (chatType == ChatType_ConsultServer) {
            [msgDict setQIMSafeObject:@"5" forKey:@"qchatid"];
        } else {

        }
        NSString *msg = [[QIMJSONSerializer sharedInstance] serializeObject:msgDict];
        NSMutableDictionary *presenceMsgDict = [NSMutableDictionary dictionaryWithCapacity:5];
        [presenceMsgDict setQIMSafeObject:@(QIMCategoryNotifyMsgTypeSession) forKey:@"PresenceMsgType"];
        [presenceMsgDict setQIMSafeObject:msg forKey:@"PresenceMsg"];
        [[XmppImManager sharedInstance] sendNotifyPresenceMsg:presenceMsgDict ToJid:[[QIMManager sharedInstance] getLastJid]];
    });
}

#pragma mark - 数据库更新 或者 保存消息

//存储消息
- (void)saveMsg:(QIMMessageModel *)msg ByJid:(NSString *)xmppId {
    
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
            if (msg.messageType == QIMMessageType_Consult || msg.messageType == QIMMessageType_ConsultResult || msg.messageType == QIMMessageType_MicroTourGuide) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            [[IMDataManager qimDB_SharedInstance] qimDB_insetPublicNumberMsgWithMsgId:messageId WithSessionId:xmppId WithFrom:from WithTo:to WithContent:content WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WithMsgDate:msgDate WithReadedTag:QIMMessageSendState_Success];
        } else if (msg.chatType == ChatType_CollectionChat) {
            if (msg.messageType == QIMMessageType_Consult || msg.messageType == QIMMessageType_ConsultResult || msg.messageType == QIMMessageType_MicroTourGuide) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            NSDictionary *msgDic = [msg yy_modelToJSONObject];
            [[IMDataManager qimDB_SharedInstance] qimDB_insertMessageWithMsgDic:msgDic];
        } else if (msg.chatType == ChatType_System) {
            if (msg.messageType == MessageType_C2BGrabSingle || msg.messageType == MessageType_C2BGrabSingleFeedBack || msg.messageType == MessageType_QCZhongbao) {
                content = msg.extendInformation.length > 0 ? msg.extendInformation : msg.message;
            }
            NSDictionary *msgDic = [msg yy_modelToJSONObject];
            [[IMDataManager qimDB_SharedInstance] qimDB_insertMessageWithMsgDic:msgDic];
        } else {
            if (!msg.msgRaw) {
                NSDictionary *msgRawDict = @{@"content":msg.message?msg.message:@"", @"extendInfo":msg.extendInformation.length > 0?msg.extendInformation:@"", @"localConvert":@(YES)};
                msg.msgRaw = [[QIMJSONSerializer sharedInstance] serializeObject:msgRawDict];
            }
            NSDictionary *msgDic = [msg yy_modelToJSONObject];
            [[IMDataManager qimDB_SharedInstance] qimDB_insertMessageWithMsgDic:msgDic];
        }
    }
}

//更新消息
- (void)updateMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid {
    
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
        
        [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageWithMsgId:messageId WithSessionId:sid WithFrom:from WithTo:to WithContent:content WithExtendInfo:extendInfo WithPlatform:0 WithMsgType:msgType WithMsgState:msgState WithMsgDirection:msgDirection WithMsgDate:msgDate WithReadedTag:0 ExtendedFlag:0 WithMsgRaw:msg.msgRaw];
    }
}

- (void)deleteMsg:(QIMMessageModel *)msg ByJid:(NSString *)sid {
    
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteMessageByMessageId:msg.messageId ByJid:sid];
}

- (void)setMsgSentFaild{
    NSArray *msgIds = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgIdsForDirection:QIMMessageDirection_Sent WithMsgState:QIMMessageSendState_Waiting];
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
        
        NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgListByXmppId:userId WithRealJid:realJid FromTimeStamp:timeStamp];
        
        NSMutableArray *list = [NSMutableArray array];
        for (NSDictionary *infoDic in array) {
            QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
            [list addObject:msg];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete((list.count > 0) ? list : @[]);
        });
    });
}

- (NSArray *)getNotReadMsgIdListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid {
    NSArray *msgIdList = [[IMDataManager qimDB_SharedInstance] qimDB_getNotReadMsgListForUserId:userId ForRealJid:realJid];
    return msgIdList;
}

- (QIMMessageModel *)getMessageModelWithByDBMsgDic:(NSDictionary *)dbMsgDic {
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
    QIMMessageType msgType = [[dbMsgDic objectForKey:@"MsgType"] integerValue];
    ChatType chatType = [[dbMsgDic objectForKey:@"ChatType"] integerValue];
    QIMMessageSendState sendState = [[dbMsgDic objectForKey:@"MsgState"] integerValue];
    QIMMessageDirection msgDirection = [[dbMsgDic objectForKey:@"MsgDirection"] integerValue];
    NSString *contentResolve = [dbMsgDic objectForKey:@"ContentResolve"];
    QIMMessageRemoteReadState readState = [[dbMsgDic objectForKey:@"ReadState"] integerValue];
    long long msgDateTime = [[dbMsgDic objectForKey:@"MsgDateTime"] longLongValue];
    id msgRaw = [dbMsgDic objectForKey:@"MsgRaw"];
    NSString *realJid = [dbMsgDic objectForKey:@"RealJid"];
    
    QIMMessageModel *msgModel = [QIMMessageModel new];
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
- (void)getRemoteSearchMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid withVersion:(long long)lastUpdateTime withDirection:(QIMGetMsgDirection)direction WithLimit:(int)limit WithOffset:(int)offset WithComplete:(void (^)(NSArray *))complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (self.load_history_msg == nil) {
            
            self.load_history_msg = dispatch_queue_create("Load History", 0);
        }
        dispatch_async(self.load_history_msg, ^{
            
            if ([userId rangeOfString:@"@conference."].location != NSNotFound) {
                [self getMucMsgListWithGroupId:userId WithDirection:direction WithLimit:(lastUpdateTime < 0) ? (direction == 0 ? 20 : limit) : limit WithVersion:(lastUpdateTime < 0) ? (direction == 0 ? INT64_MAX : 0) : lastUpdateTime include:YES withCallBack:^(NSArray *resultList) {
                    if (resultList.count > 0) {
                        NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertIphoneMucPageJSONMsg:resultList withInsertDBFlag:NO];
                        NSMutableArray *list = [NSMutableArray array];
                        for (NSDictionary *infoDic in datas) {
                            QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                            [list addObject:msg];
                        }
                        complete(list);
                    } else {
                        complete(@[]);
                    }
                }];
            } else {
                [self getUserChatlogWithFrom:userId to:[self getLastJid] version:lastUpdateTime count:limit direction:direction include:YES withCallBack:^(NSArray *result) {
                    if (result.count > 0) {
                        NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPageHistoryChatJSONMsg:result WithXmppId:userId withInsertDBFlag:NO];
                        NSMutableArray *list = [NSMutableArray array];
                        NSString *channelInfo = nil;
                        NSString *buInfo = nil;
                        NSString *cctextInfo = nil;
                        for (NSDictionary *infoDic in datas) {
                            QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
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
                }];
            }
        });
    });
}

- (void)getMsgListByUserId:(NSString *)userId WithRealJid:(NSString *)realJid WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMgsListBySessionId:userId WithRealJid:realJid WithLimit:limit WithOffset:offset];
        if (array.count > 0) {
            NSMutableArray *list = [NSMutableArray array];
            for (NSDictionary *infoDic in array) {
                QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
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
                            [self getMucMsgListWithGroupId:userId WithDirection:0 WithLimit:limit WithVersion:[[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:userId] include:NO withCallBack:^(NSArray *resultList) {
                                if (resultList.count > 0) {
                                    
                                    [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertIphoneMucPageJSONMsg:resultList];
                                }
                            }];
                        } else {
#pragma mark - 这里开始拉取单人翻页消息
                            [self getUserChatlogWithFrom:userId to:[self getLastJid] version:[[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:userId] count:limit direction:0 include:NO withCallBack:^(NSArray *result) {
                                if (result.count > 0) {
                                    NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPageHistoryChatJSONMsg:result WithXmppId:userId];
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
                            }];
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
                        long long version = [[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:userId] - timeChange;
                        int direction = 0;
                        NSNumber *readMarkT = nil;
                        [self getMucMsgListWithGroupId:userId WithDirection:direction WithLimit:version < 0 ? (direction == 0 ? 20 : limit) : limit WithVersion:version < 0 ? (direction == 0 ? INT64_MAX : 0) : version include:NO withCallBack:^(NSArray *resultList) {
                            if (resultList.count > 0) {
                                NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertIphoneMucPageJSONMsg:resultList];
                                NSMutableArray *list = [NSMutableArray array];
                                for (NSDictionary *infoDic in datas) {
                                    QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
                                    [list addObject:msg];
                                }
                                complete(list);
                            } else {
                                complete(@[]);
                            }
                        }];
      
                    } else {
                        [self getUserChatlogWithFrom:userId to:[self getLastJid] version:[[IMDataManager qimDB_SharedInstance] qimDB_getMinMsgTimeStampByXmppId:userId] count:limit direction:0 include:NO withCallBack:^(NSArray *result) {
                            if (result.count > 0) {
                                NSArray *datas = [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPageHistoryChatJSONMsg:result WithXmppId:userId];
                                NSMutableArray *list = [NSMutableArray array];
                                NSString *channelInfo = nil;
                                NSString *buInfo = nil;
                                NSString *cctextInfo = nil;
                                for (NSDictionary *infoDic in datas) {
                                    QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:infoDic];
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
                        }];
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
    return [[IMDataManager qimDB_SharedInstance] qimDB_searchLocalMessageByKeyword:keyWord XmppId:xmppid RealJid:realJid];
}

- (NSArray *)getLocalMediasByXmppId:(NSString *)xmppId ByRealJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getLocalMediaByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:2];
    for (NSDictionary *msgInfoDic in array) {
        QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:msgInfoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgsByMsgType:msgTypes ByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *msgInfoDic in array) {
        QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:msgInfoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsByKeyWord:(NSString *)keyWork ByXmppId:(NSString *)xmppId ByReadJid:(NSString *)realJid {
    NSArray *array = [[IMDataManager qimDB_SharedInstance] qimDB_getMsgsByKeyWord:keyWork ByXmppId:xmppId ByReadJid:realJid];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *msgInfoDic in array) {
        QIMMessageModel *msg = [self getMessageModelWithByDBMsgDic:msgInfoDic];
        [list addObject:msg];
    }
    return list;
}

- (NSArray *)getMsgsForMsgType:(NSArray *)msgTypes ByXmppId:(NSString *)xmppId {
    return [self getMsgsForMsgType:msgTypes ByXmppId:xmppId ByReadJid:nil];
}

@end
