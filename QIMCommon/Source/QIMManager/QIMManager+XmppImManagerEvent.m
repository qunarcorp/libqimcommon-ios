//
//  QIMManager+XmppImManagerEvent.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "QIMManager+XmppImManagerEvent.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (XmppImManagerEvent)

- (void)registerEvent {
    
    //连接中
    [[XmppImManager sharedInstance] addTarget:self method:@selector(beginToConnect) withXmppEvent:XmppEventConnecting];
    
    //已连接
    [[XmppImManager sharedInstance] addTarget:self method:@selector(beenConnected) withXmppEvent:XmppEventConnected];
    
    //连接完成
    [[XmppImManager sharedInstance] addTarget:self method:@selector(loginComplate) withXmppEvent:XmppEvent_LoginComplate];
    
    //连接超时
    [[XmppImManager sharedInstance] addTarget:self method:@selector(connectTimeOut) withXmppEvent:XmppEvent_ConnectTimeOut];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(configForRemoteKeyAndSystemTime:) withXmppEvent:XmppEvent_Config_Key_Time];
    
    //登录失败
    [[XmppImManager sharedInstance] addTarget:self method:@selector(loginFaild:) withXmppEvent:XmppEvent_LoginFaild];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(registerComplate) withXmppEvent:XmppEvent_RegisterSuccess];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveMsg:) withXmppEvent:XmppEvent_MessageIn];
    //QChat 会话开始
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveQChatNoteMsg:) withXmppEvent:XmppEvent_QChatNote];
    //QChat 会话结束
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveQChatEndMsg:) withXmppEvent:XmppEvent_QChatEnd];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveGroupMsg:) withXmppEvent:XmppeventGroupMessageIn];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveSystemMsg:) withXmppEvent:XmppEvent_SystemMessageIn];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveShareLocationMsg:) withXmppEvent:XmppEvent_ShareLocation];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveGroupImage:) withXmppEvent:XmppEvent_GroupImageIn];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveFile:) withXmppEvent:XmppEvent_FileIn];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveGroupFile:) withXmppEvent:XmppEvent_GroupFileIn];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveShock:) withXmppEvent:XmppEvent_ShockIn];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveGroupShock:) withXmppEvent:XmppEvent_GroupShockIn];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onUserPresenceChange:) withXmppEvent:XmppEvent_UserStatusChange];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onTyping:) withXmppEvent:XmppEvent_Typing];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onReadState:) withXmppEvent:XmppEvent_ReadState];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onConsultReadState:) withXmppEvent:XmppEvent_ConsultReadState];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onRevoke:) withXmppEvent:XmppEvent_Revoke];
    
    //消息发送成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageSendSuccess:) name:kXmppStreamDidSendMessage object:nil];
    //消息发送失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageSendFaild:) name:kXmppStreamSendMessageFailed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppStackConnectedTimesNotify:) name:XmppstackConnectedTimes object:nil];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(userMucListUpdate:) withXmppEvent:XmppEvent_User_Muc_List];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(friendPresence:) withXmppEvent:XmppEvent_Friend_Presence];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(friendValidation:) withXmppEvent:XmppEvent_Friend_Validation];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onTransferChat:) withXmppEvent:XmppEvent_TransferChat];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(updateUserChannelInfo:) withXmppEvent:XmppEvent_UpdateChannelInfo];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(updateUserAppendInfo:) withXmppEvent:XmppEvent_UpdateAppendInfo];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receivePublicNumberMsg:) withXmppEvent:XmppEvent_PublicNumberMsg];
        
    //自己被人邀请进群/ 有人被提升为管理员 / 有人被降为普通用户
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbChatRoomAddMember:) withXmppEvent:XmppEvent_PBPresence_ChatRoomAddMember];
    
    //有其他新人被邀请进群
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbChatRoomInviteMember:) withXmppEvent:XmppEvent_PBPresence_ChatRoomInviteMember];
    
    //删除群成员
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbChatRoomDeleteMember:) withXmppEvent:XmppEvent_PBPresence_ChatRoomDeleteMember];
    
    //销毁群组PBPresence
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbChatRoomDestory:) withXmppEvent:XmppEvent_PBPresence_ChatRoomDestory];
    
    //群名片变更PBPresence, 群里只要有人数变更，群名称变更，群公告变更，群简介变更，version都会改变（）
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbChatRoomCardUpdate:) withXmppEvent:XmppEvent_PBPresence_ChatRoomCardUpdate];
    //有人被踢出群组
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbChatRoomRegisterDelMember:) withXmppEvent:XmppEvent_PBPresence_ChatRoomRegisterDelMember];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(pbUserStatusChanage:) withXmppEvent:XmppEvent_PBPresence_UserStatusChanage];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveCategoryNotifyMessage:) withXmppEvent:XmppEvent_PBPresence_CategoryNotify];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(deleteFriend:) withXmppEvent:XmppEvent_DelFriend];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(serviceStreamEnd:) withXmppEvent:XmppEvent_StreamEnd];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(socketDisconnect) withXmppEvent:XmppEvent_Disconnect];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(messageLogEvent:) withXmppEvent:XmppEvent_MessageLog];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(userResourceNotify:) withXmppEvent:XmppEvent_UserResource];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(callVideoAudio:) withXmppEvent:XmppEvent_CallVideoAudio];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(meetingAudioVideoConference:) withXmppEvent:XmppEvent_CallMeetingAudioVideoConference];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveConsultMessage:) withXmppEvent:XmppEvent_ReceiveConsultMessage];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveCollectionMessage:) withXmppEvent:XmppEvent_CollectionMessageIn];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveCollectionOriginMessage:) withXmppEvent:XmppEvent_CollectionOriginMessageIn];
    //接收到加密消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveEncryptMessage:) withXmppEvent:XmppEvent_ReceiveEncryptMessage];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveErrorMessage:) withXmppEvent:XmppEvent_MessageError];
    
    //登录之前同步一下消息时间戳
    [[XmppImManager sharedInstance] addTarget:self method:@selector(updateOfflineTime:) withXmppEvent:XmppEvent_UpdateOfflineTime];
}

- (void)updateOfflineTime:(NSDictionary *)infoDic {
    QIMVerboseLog(@"登录之前初始化数据库文件之后更新各种时间戳开始 : %@", infoDic);
    [self updateLastMsgTime];
    [self updateLastGroupMsgTime];
    [self updateLastSystemMsgTime];
    [self updateLastMaxMucReadMarkTime];
    [self updateLastWorkFeedMsgTime];
    QIMVerboseLog(@"登录之前初始化数据库文件之后更新各种时间戳完成");
}

- (void)receiveErrorMessage:(NSDictionary *)infoDic {
    QIMVerboseLog(@"收到消息的错误回执 : %@", infoDic);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *from = [infoDic objectForKey:@"From"];
        NSString *msgId = [infoDic objectForKey:@"MsgId"];
        NSInteger errCode = [[infoDic objectForKey:@"ErrorCode"] integerValue];
        switch (errCode) {
            case QIMMessageErrCodeRefused: {
                if ([from containsString:@"conference."]) {
                    
                } else {
                    Message *msg = [[QIMManager sharedInstance] createMessageWithMsg:@"消息已发出，但被对方拒收了。" extenddInfo:nil userId:from realJid:from userType:ChatType_SingleChat msgType:QIMMessageType_Time forMsgId:[QIMUUIDTools UUID] willSave:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamSendMessageFailed object:@{@"messageId":msgId}];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:from userInfo:@{@"message": msg}];
                    });
                }
            }
                break;
            default:
                break;
        }
    });
}

- (void)receiveEncryptMessage:(NSDictionary *)infoDic {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReceiveEncryptMessage object:infoDic];
    });
}

- (void)receiveCategoryNotifyMessage:(NSDictionary *)msgDic {
    SInt32 categoryType = [[msgDic objectForKey:@"categoryType"] intValue];
    /*
     CategoryTypeCategoryOrganizational = 1,
     CategoryTypeCategorySessionList = 2,
     CategoryTypeCategoryNavigation = 3,
     CategoryTypeCategoryAskLog = 10,
     CategoryTypeCategoryTickUser = 100,
     */
    NSDictionary *notifyMsg = [[QIMJSONSerializer sharedInstance] deserializeObject:[msgDic objectForKey:@"bodyValue"] error:nil];
    QIMVerboseLog(@"收到通知类Presence : %@", msgDic);
    switch (categoryType) {
        case QIMCategoryNotifyMsgTypeOrganizational: {
            QIMVerboseLog(@"重新获取组织架构");
            dispatch_async(self.cacheQueue, ^{
                [[IMDataManager sharedInstance] clearUserList];
                [[IMDataManager sharedInstance] qimDB_deleteConfigWithConfigKey:@"kLocalIncrementUpdateTime"];
                [self checkRosterListWithForceUpdate:YES];
            });
        }
            break;
        case QIMCategoryNotifyMsgTypeSession: {
            QIMVerboseLog(@"打开了一个会话，本客户端暂不支持同步该类型");
        }
            break;
        case QIMCategoryNotifyMsgTypeNavigation: {
            long long navVersion = [[notifyMsg objectForKey:@"navversion"] longLongValue];
            if (navVersion > [[QIMNavConfigManager sharedInstance] navVersion]) {
                [[QIMUserCacheManager sharedInstance] setUserObject:[QIMManager getLastUserName] forKey:@"currentLoginUserName"];
                [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
            }
            QIMVerboseLog(@"下发导航版本通知");
        }
            break;
        case QIMCategoryNotifyMsgTypeOPSUnreadCount: {
            QIMVerboseLog(@"收到OPS 骆驼帮未读数更新通知");
            BOOL hasUnread = [[notifyMsg objectForKey:@"hasUnread"] boolValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreNotReadCountChange object:@(hasUnread)];
        }
            break;
        case QIMCategoryNotifyMsgTypePersonalConfig: {
            QIMVerboseLog(@"收到个人配置更新通知");
            NSInteger version = [[notifyMsg objectForKey:@"version"] integerValue];
            NSString *resource = [notifyMsg objectForKey:@"resource"];
            BOOL forceUpdate = [[notifyMsg objectForKey:@"force"] boolValue];
            BOOL forceQuickReplyUpdate = [[notifyMsg objectForKey:@"forcequickreply"] boolValue];
            BOOL forceRNUpdate = [[notifyMsg objectForKey:@"forceRN"] boolValue];
            if ([[IMDataManager sharedInstance] qimDB_getConfigVersion] < version && ![resource isEqualToString:[[XmppImManager sharedInstance] resource]]) {
                [self getRemoteClientConfig];
            } else if (forceUpdate) {
                QIMVerboseLog(@"强制更新个人配置信息");
                [[IMDataManager sharedInstance] qimDB_clearClientConfig];
                [self getRemoteClientConfig];
            } else if (forceQuickReplyUpdate) {
                QIMVerboseLog(@"强制更新快捷回复");
                [[IMDataManager sharedInstance] qimDB_clearQuickReplyGroup];
                [[IMDataManager sharedInstance] qimDB_clearQuickReplyContents];
                [self getRemoteQuickReply];
            } else if (forceRNUpdate) {
                QIMVerboseLog(@"收到RN包清除通知");
                NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
                //内置包版本
                NSString *latestJSCodeURLString = [path stringByAppendingPathComponent:@"rnRes"];
                BOOL removeSussess = [[NSFileManager defaultManager] removeItemAtPath:latestJSCodeURLString error:nil];
                if (removeSussess) {
                    QIMVerboseLog(@"清空RN包缓存成功 : %@", latestJSCodeURLString);
                } else {
                    QIMVerboseLog(@"清空RN包缓存失败 : %@", latestJSCodeURLString);
                }
            }
        }
            break;
        case QIMCategoryNotifyMsgTypeBigIM: {
            QIMVerboseLog(@"大客户端通知，可忽略");
        }
            break;
        case QIMCategoryNotifyMsgTypeCalendar: {
            QIMVerboseLog(@"收到日历同步通知");
            long long newVersion = [[notifyMsg objectForKey:@"updateTime"] longLongValue];
            long long oldVersion = [[[IMDataManager sharedInstance] qimDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalTripUpdateTime] WithSubKey:[[QIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
            if (newVersion > oldVersion) {
                QIMVerboseLog(@"本次服务器下发的版本号 大于本地版本号 %lld，更新远程数据", oldVersion);
                [self getRemoteUserTripList];
            } else {
                QIMVerboseLog(@"本次服务器下发的版本号 小于本地版本号 %lld，不同步数据", oldVersion);
            }
        }
            break;
        case QIMCategoryNotifyMsgTypeOnline: {
            QIMVerboseLog(@"收到其他客户端上线下线通知");
            NSString *onlineListStr = [msgDic objectForKey:@"bodyValue"];
            BOOL flag = NO;
            if ([[onlineListStr lowercaseString] containsString:@"mac"] || [[onlineListStr lowercaseString] containsString:@"pc"] || [[onlineListStr lowercaseString] containsString:@"linux"]) {
                flag = YES;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyOnline object:@(flag)];
        }
            break;
        case QIMCategoryNotifyMsgTypeAskLog: {
            QIMVerboseLog(@"自动收集日志");
            [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifySubmitLog object:nil];
        }
            break;
        case QIMCategoryNotifyMsgTypeTickUser: {
            NSString *reason = [notifyMsg objectForKey:@"reason"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationStreamEnd" object:reason];
            QIMVerboseLog(@"踢人");
        }
            break;
        case QIMCategoryNotifyMsgTypeGlobalNotification: {
            /*
             
             {
             
             "noticeStr":[
             {
             "str":"你好",
             "type":"link",
             "url":"www.baidu.com",
             "strColor":"#ffffff"
             },
             {
             "str":",本段是文本",
             "type":"text",
             "strColor":"#ffffff"
             },
             {
             "str":"这一段是跳转",
             "type":"newChat",
             "from":"shop323",
             "to":"hubin.hu",
             "realFrom":"wz.wang",
             "realTo":"hubin.hu",
             "consult":"4",
             "strColor":"#ffffff",
             "isConsult":true
             }
             ]
             }
             */
            QIMVerboseLog(@"下发全局通知");
            [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyGlobalChat object:nil];
//            [[QTalkNotifyManager shareNotifyManager] showGlobalNotifyWithMessage:notifyMsg];
        }
            break;
        case QIMCategoryNotifyMsgTypeDesignatedNotification:{
            /*
             {
             "from":"shop323",
             "to":"hubin.hu",
             "isConsult":true,
             "realFrom":"xxxx",
             "realTo":"xxxxx",
             "consult":"4",
             "noticeStr":[
             {
             "str":"你好",
             "type":"link",
             "url":"www.baidu.com",
             "strColor":"#ffffff"
             },
             {
             "str":",本段是文本",
             "type":"text",
             "strColor":"#ffffff"
             },
             {
             "str":"这一段是跳转",
             "type":"newChat",
             "from":"shop323",
             "to":"hubin.hu",
             "realFrom":"wz.wang",
             "realTo":"hubin.hu",
             "consult":"4",
             "strColor":"#ffffff",
             "isConsult":true
             }
             ]
             }
             */
            QIMVerboseLog(@"下发指定通知,故需要相关会话信息");
            [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifySpecifiedChat object:nil];
//            [[QTalkNotifyManager shareNotifyManager] showChatNotifyWithMessage:notifyMsg];
        }
            break;
        case QIMCategoryNotifyMsgTypeTickUserWorkWorldNotice: {
            NSString *onlineListStr = [msgDic objectForKey:@"bodyValue"];
            NSDictionary *onlineDict = [[QIMJSONSerializer sharedInstance] deserializeObject:onlineListStr error:nil];
            [[IMDataManager sharedInstance] qimDB_bulkinsertNoticeMessage:@[onlineDict]];
            NSInteger eventType = [[onlineDict objectForKey:@"eventType"] integerValue];
            if (eventType == QIMWorkFeedNotifyTypeComment) {
                QIMVerboseLog(@"online Comment 通知 : %@", onlineDict);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
                    NSInteger notReadMessageCount = [[QIMManager sharedInstance] getWorkNoticeMessagesCount];
                    QIMVerboseLog(@"发送驼圈在线消息小红点通知数: %ld", notReadMessageCount);
                    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreNotReadCountChange object:@(notReadMessageCount)];
                });
            } else if (eventType == QIMWorkFeedNotifyTypePOST) {
                QIMVerboseLog(@"online 新帖子 通知 : %@", onlineDict);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SUGGEST_WorkFeed_UPDATE object:[self getLastWorkOnlineMomentWithDic:onlineDict]];
                });
            } else {
                
            }
        }
            break;
        default: {
            QIMVerboseLog(@"遇到不认识的categoryType : %@", msgDic);
        }
            break;
    }
    QIMVerboseLog(@"%s", __func__);
}

- (void)receiveCollectionMessage:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    QIMVerboseLog(@"receiveCollectionMessage msgDic : %@", msgDic);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *fromId = [msgDic objectForKey:@"fromId"];
        NSString *domain = [msgDic objectForKey:@"domain"];
        NSString *sid = [NSString stringWithFormat:@"%@@%@", fromId, domain];
        NSString *realfrom = [msgDic objectForKey:@"realfrom"];
        NSString *msg = [msgDic objectForKey:@"msg"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        int direction = [[msgDic objectForKey:@"direction"] intValue];
        int msgType = [[msgDic objectForKey:@"msgType"] intValue];
        NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *nickName = [msgDic objectForKey:@"nickName"];
        
        
        if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
            return;
        }
        
        [[QIMManager sharedInstance] checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        
        Message *mesg = [Message new];
        [mesg setFrom:realfrom];
        [mesg setMessageId:msgId];
        [mesg setMessageType:msgType];
        [mesg setChatType:ChatType_SingleChat];
        [mesg setMessageDirection:direction == 2 ? MessageDirection_Sent : MessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageDate:msgDate];
        if (nickName.length > 0) {
            [mesg setNickName:nickName];
        }
        [mesg setExtendInformation:extendInfo];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        [mesg setMsgRaw:msgRaw];
        // 消息落地
        [self saveMsg:mesg ByJid:sid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            [self addSessionByType:ChatType_CollectionChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:NO];
            [self increasedNotReadMsgCountByJid:sid];
            [self updateNotReadCountCacheByJid:sid];
        });
    });
}

- (void)receiveCollectionOriginMessage:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    QIMVerboseLog(@"receiveCollectionOriginMessage : %@", msgDic);
    dispatch_async(self.receive_msg_queue, ^{
        NSString *msgId = [msgDic objectForKey:@"MsgId"];
        NSString *originFrom = [msgDic objectForKey:@"Originfrom"];
        originFrom = [[originFrom componentsSeparatedByString:@"/"] firstObject];
        NSString *originTo = [msgDic objectForKey:@"Originto"];
        NSString *originType = [msgDic objectForKey:@"Origintype"];
        QIMVerboseLog(@"msgId : %@, originFrom : %@, originTo: %@, originType: %@", msgId, originFrom, originTo, originType);
        BOOL isExistCollectionMsg = [[IMDataManager sharedInstance] checkCollectionMsgById:msgId];
        if (!isExistCollectionMsg) {
            [self saveCollectionMessage:msgDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playSound];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationCollectionMessageUpdate" object:msgDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCollectionMsgList" object:nil];
                QIMVerboseLog(@"抛出通知 QIMmanger receiveCollectionOriginMessage  kNotificationSessionListUpdate");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationSessionListUpdate" object:nil];
            });
        }
    });
}

- (void)receiveConsultMessage:(NSDictionary *)msgDic{
    if (msgDic == nil) {
        return;
    }
    QIMVerboseLog(@"receiveConsultMessage : %@", msgDic);
    dispatch_async(self.receive_msg_queue, ^{
        NSString *fromJid = [msgDic objectForKey:@"fromId"];
        NSString *realFrom = [msgDic objectForKey:@"realfrom"];
        NSString *toJid = [msgDic objectForKey:@"toId"];
        NSString *realTo = [msgDic objectForKey:@"realto"];
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *msg = [msgDic objectForKey:@"msg"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] qim_timeIntervalSince1970InMilliSecond];
        NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        int messageType = [[msgDic objectForKey:@"msgType"] intValue];
        int chatType = [[msgDic objectForKey:@"chatId"] intValue];
        BOOL isCarbon = [[msgDic objectForKey:@"isCarbon"] boolValue];
        BOOL convertType = NO;
        BOOL needAutoReply = YES;
        /*
        if (messageType == QIMMessageType_TransChatToCustomerService) {
            chatType = 5;
            if (isCarbon == NO) {
                // 创建会话 需要处理
                NSString *content = extendInfo.length>0?extendInfo:msg;
                [self sendConsultMessageId:[QIMUUIDTools UUID] WithMessage:content WithInfo:nil toJid:fromJid realToJid:[msgDic objectForKey:@"realfrom"] WithChatType:ChatType_Consult WithMsgType:QIMMessageType_TransChatToCustomerService_Feedback];
            }
            needAutoReply = NO;
        } else if (messageType == QIMMessageType_TransChatToCustomer) {
            if (isCarbon == NO) {
                needAutoReply = NO;
                // 创建会话
                NSString *content = extendInfo.length>0?extendInfo:msg;
                NSDictionary *contentDic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
                if(contentDic) {
                    if (self.virtualRealJidDic == nil) {
                        self.virtualRealJidDic = [NSMutableDictionary dictionary];
                    }
                    NSString *virtualJid =[[contentDic objectForKey:@"toId"] stringByAppendingFormat:@"@%@",[self getDomain]];
                    NSString *realJid =[[contentDic objectForKey:@"toId"] stringByAppendingFormat:@"@%@",[self getDomain]];
                    [self.virtualRealJidDic setQIMSafeObject:realJid forKey:virtualJid];
                }
                [self sendConsultMessageId:[QIMUUIDTools UUID] WithMessage:content WithInfo:nil toJid:fromJid realToJid:[msgDic objectForKey:@"realfrom"] WithChatType:ChatType_Consult WithMsgType:QIMMessageType_TransChatToCustomer_Feedback];
            }
        } else if (messageType == QIMMessageType_TransChatToCustomerService_Feedback) {
            if (isCarbon == NO) {
                needAutoReply = NO;
            }
            chatType = ChatType_Consult;
            NSString *content = extendInfo.length>0?extendInfo:msg;
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
            realFrom = [infoDic objectForKey:@"u"];
            msgId = [infoDic objectForKey:@"retid"];
            if (msgId == nil) {
                msgId = [NSString stringWithFormat:@"%lld",msgDate / 1000 % 10];
            }
        } else if (messageType == QIMMessageType_TransChatToCustomer_Feedback) {
            if (isCarbon == NO) {
                needAutoReply = NO;
            }
            chatType = ChatType_Consult;
            NSString *content = extendInfo.length>0?extendInfo:msg;
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
            msgId = [infoDic objectForKey:@"retid"];
            if (msgId == nil) {
                msgId = [NSString stringWithFormat:@"%lld",msgDate / 1000 % 10];
            }
        } else if (messageType == QIMMessageType_CNote) {
//            if (isCarbon == NO) {
//                [self customerConsultServicesayHelloWithUser:[realFrom componentsSeparatedByString:@"@"].firstObject WithVirtualId:[fromJid componentsSeparatedByString:@"@"].firstObject WithFromUser:[QIMManager getLastUserName]];
//            }
        }
        */
        
        NSString *sid = nil;
        if (isCarbon == YES) {
            if (chatType == ChatType_ConsultServer) {
                sid = [NSString stringWithFormat:@"%@-%@",fromJid,realTo];
                realFrom = realTo;
            } else {
                sid = [NSString stringWithFormat:@"%@-%@",fromJid,fromJid];
                realFrom = fromJid;
            }
        } else {
            if (chatType == ChatType_Consult) {
                sid = [NSString stringWithFormat:@"%@-%@",fromJid,realFrom];
            } else {
                sid = [NSString stringWithFormat:@"%@-%@",fromJid,fromJid];
                realFrom = fromJid;
            }
        }
        if (messageType == QIMMessageType_SmallVideo) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
            NSString *videoUrl = [infoDic objectForKey:@"FileUrl"];
            NSString *videoName = [infoDic objectForKey:@"FileName"];
            videoUrl = [[[QIMNavConfigManager sharedInstance] innerFileHttpHost] stringByAppendingFormat:@"/%@", videoUrl];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
            [data writeToFile:[[self getDownloadFilePath] stringByAppendingPathComponent:videoName] atomically:YES];
        }
        BOOL flag = [[IMDataManager sharedInstance] checkMsgId:msgId];
        if (flag) {
            return;
        }
        [self checkMsgTimeWithJid:fromJid WithRealJid:realFrom WithMsgDate:msgDate WithGroup:NO];
        Message *mesg = [Message new];
        [mesg setMessageId:msgId];
        [mesg setFrom:[msgDic objectForKey:@"realfrom"]];
        [mesg setMessageType:messageType];
        [mesg setMessageDirection:(isCarbon == YES) ? MessageDirection_Sent : MessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setExtendInformation:extendInfo];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        [mesg setRealJid:realFrom];
        [mesg setChatType:chatType];
        // 消息落地
        [self saveMsg:mesg ByJid:fromJid];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message":mesg}];
            
            NSString *realJid = realFrom;
            ChatType cType;
            if (chatType == ChatType_Consult) {
                cType = ChatType_ConsultServer;
                if (isCarbon == YES) {
                    realJid = fromJid;
                    cType = ChatType_Consult;
                }
            } else {
                cType = ChatType_Consult;
                if (isCarbon == NO) {
                    realJid = fromJid;
                } else {
                    realJid = realTo;
                    cType = ChatType_ConsultServer;
                }
            }
            [self addConsultSessionById:fromJid ByRealJid:realJid WithUserId:realJid ByMsgId:msgId WithOpen:NO WithLastUpdateTime:mesg.messageDate WithChatType:cType];
            if (![sid isEqualToString:self.currentSessionUserId] && mesg.messageDirection == MessageDirection_Received) {
                [self increasedNotReadMsgCountByJid:fromJid WithReadJid:mesg.realJid];
                [self updateNotReadCountCacheByJid:fromJid WithRealJid:mesg.realJid];
                if (mesg.messageType == QIMMessageType_RedPack) {
                    [self playHongBaoSound];
                } else {
                    [self playSound];
                }
            }
        });
    });
}

//单人视频
- (void)callVideoAudio:(NSDictionary *)infoDic {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWebRTCCallVideoAudio object:infoDic];
}

//群视频会议
- (void)meetingAudioVideoConference:(NSDictionary *)infoDic {
    [[NSNotificationCenter defaultCenter] postNotificationName:kWbeRTCCallMeetingAudioVideoConference object:infoDic];
}

- (NSString *)userResourceForJid:(NSString *)jid{
    return [self.userResourceDic objectForKey:jid];
}

- (void)userResourceNotify:(NSDictionary *)infoDic{
    NSString *userJid = [infoDic objectForKey:@"jid"];
    NSString *resource = [infoDic objectForKey:@"resource"];
    [self.userResourceDic setObject:resource forKey:userJid];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyUserResourceChange object:userJid];
    });
}

- (void)messageLogEvent:(NSDictionary *)logDic{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *log = [logDic objectForKey:@"log"];
        int direction = [[logDic objectForKey:@"direction"] intValue];
        switch (direction) {
            case MsgDirection_Send:
            {
                log = [NSString stringWithFormat:@"<=========== 发送了消息 ==========>\n%@",log];
                QIMVerboseLog(@"<Method: messageLogEvent, MsgDirection_Send :%@>", log);
            }
                break;
            case MsgDirection_Receive:
            {
                log = [NSString stringWithFormat:@"<=========== 接收了消息 ==========>\n%@",log];
                QIMVerboseLog(@"<Method: messageLogEvent, MsgDirection_Receive ：%@", log);
            }
                break;
            default:
                break;
        }
    });
}

- (void)connectTimeOut{
    [self socketDisconnect];
}

- (void)socketDisconnect{
    
    QIMErrorLog(@"Socket已经断开通知");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
    [self checkNetworkStatus];
    [self onDisconnect];
    [self.loginComplateQueue cancelAllOperations];
}

- (void)serviceStreamEnd:(NSDictionary *)infoDic{
    QIMErrorLog(@"serviceStreamEnd : %@", infoDic);
    NSInteger errcode = [[infoDic objectForKey:@"ErrorCode"] integerValue];
    NSString *reason = [infoDic objectForKey:@"Reason"];
    if (errcode >= 100 && errcode < 200) {
        if (errcode == 101) {
            QIMErrorLog(@"清除导航缓存");
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"NavConfig"];
            QIMErrorLog(@"重新获取导航");
            [[QIMUserCacheManager sharedInstance] setUserObject:[QIMManager getLastUserName] forKey:@"currentLoginName"];
            BOOL getNavSuccess = [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithCheck:YES];
            if (getNavSuccess == NO) {
                QIMErrorLog(@"获取导航失败，请稍后再试");
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationStreamEnd" object:@"请检查当前网络状态后重试"];
                return;
            }
            QIMWarnLog(@"再次重新登录");
            self.needTryRelogin = YES;
            [self socketDisconnect];
        } else {
            QIMWarnLog(@"被踢下线后重新登录");
            [self relogin];
        }
    } else if (errcode >= 200) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationStreamEnd" object:@"你的账号由于某些原因被迫下线"];
        self.willCancelLogin = YES;
        self.notNeedCheckNetwotk = YES;
    } else {
        QIMWarnLog(@"遇到了新的StreamEnd");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationStreamEnd" object:reason];
    }
    NSString *reasonContent = [NSString stringWithFormat:@"我被踢了, 原因是%@", reason];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifySubmitLog object:reasonContent];
}

- (void)deleteFriend:(NSDictionary *)infoDic{
    NSString *xmppId = [infoDic objectForKey:@"jid"];
    if (xmppId) {
        [[IMDataManager sharedInstance] deleteFriendListWithXmppId:xmppId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendListUpdate object:xmppId userInfo:nil];
    }
}

- (void)pbChatRoomAddMember:(NSDictionary *)infoDic{
    dispatch_async(self.update_group_member_queue, ^{
        NSString *groupId = [infoDic objectForKey:@"groupId"];
        if ([[IMDataManager sharedInstance] checkGroup:groupId] == NO) {
            [[IMDataManager sharedInstance] insertGroup:groupId];
            [self updateGroupCardByGroupId:groupId];
            [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:[[NSDate date] qim_timeIntervalSince1970InMilliSecond] WithNeedUpdate:YES];
            //[_joinedGroupSet addObject:groupId];
            // 获取群成员列表
            NSArray *members = [[XmppImManager sharedInstance] getChatRoomMembersForGroupId:groupId];
            if (members.count > 0) {
                [[IMDataManager sharedInstance] bulkInsertGroupMember:members WithGroupId:groupId];
            }
        }
        NSString *memberJid = [infoDic objectForKey:@"jid"];
        NSString *affiliation = [infoDic objectForKey:@"affiliation"];
        NSString *name = [infoDic objectForKey:@"name"];
        if (name.length <= 0) {
            name = [memberJid componentsSeparatedByString:@"@"].firstObject;
        }
        NSMutableDictionary *memberInfoDic = [NSMutableDictionary dictionary];
        [memberInfoDic setObject:memberJid forKey:@"jid"];
        [memberInfoDic setObject:[memberJid componentsSeparatedByString:@"@"].firstObject forKey:@"name"];
        [memberInfoDic setQIMSafeObject:affiliation forKey:@"affiliation"];
        if (memberJid) {
            dispatch_async(self.load_user_state_queue, ^{
                [self.onlineTables setObject:@"online" forKey:memberJid];
            });
            [[IMDataManager sharedInstance] insertGroupMember:memberInfoDic WithGroupId:groupId];
        }
    });
}

- (void)pbChatRoomInviteMember:(NSDictionary *)infoDic{
    dispatch_async(self.update_group_member_queue, ^{
        NSString *groupId = [infoDic objectForKey:@"groupId"];
        NSString *memberJid = [infoDic objectForKey:@"jid"];
        NSString *affiliation = @"none";
        NSString *name = [infoDic objectForKey:@"name"];
        if (name.length <= 0) {
            name = [memberJid componentsSeparatedByString:@"@"].firstObject;
        }
        //NSString *domain = [infoDic objectForKey:@"domain"];
        NSMutableDictionary *memberInfoDic = [NSMutableDictionary dictionary];
        [memberInfoDic setObject:memberJid forKey:@"jid"];
        [memberInfoDic setObject:[memberJid componentsSeparatedByString:@"@"].firstObject forKey:@"name"];
        [memberInfoDic setQIMSafeObject:affiliation forKey:@"affiliation"];
        if (memberJid) {
            dispatch_async(self.load_user_state_queue, ^{
                [self.onlineTables setObject:@"online" forKey:memberJid];
            });
            [[IMDataManager sharedInstance] insertGroupMember:memberInfoDic WithGroupId:groupId];
        }
    });
}

- (void)pbChatRoomDeleteMember:(NSDictionary *)infoDic{
    QIMVerboseLog(@"删除群成员 : %@", infoDic);
}

- (void)pbChatRoomDestory:(NSDictionary *)infoDic{
    dispatch_async(self.receive_msg_queue, ^{
        NSString *groupId = [infoDic objectForKey:@"groupId"];
        NSString *reason = [infoDic objectForKey:@"Reason"];
        NSString *fromNickName = [infoDic objectForKey:@"FromNickName"];
        NSDictionary *groupCardDic = [self getGroupCardByGroupId:groupId];
        NSString *groupName = [groupCardDic objectForKey:@"Name"];
        NSInteger LastUpdateTime = [[groupCardDic objectForKey:@"LastUpdateTime"] integerValue];
        if (LastUpdateTime <= 0) {
            return;
        } else {
            if (fromNickName.length > 0) {
                NSDictionary *userInfoDic = [self getUserInfoByGroupName:fromNickName];
                fromNickName = [userInfoDic objectForKey:@"Name"];
            }
            [self removeSessionById:groupId];
            [[IMDataManager sharedInstance] deleteGroup:groupId];
            [[IMDataManager sharedInstance] deleteMessageWithXmppId:groupId];
            NSMutableDictionary *userInfoDic = [NSMutableDictionary dictionary];
            if (reason.length > 0) {
                [userInfoDic setObject:reason forKey:@"Reason"];
            }
            if (groupName.length > 0) {
                [userInfoDic setObject:groupName forKey:@"GroupName"];
            }
            if (fromNickName.length > 0) {
                [userInfoDic setObject:fromNickName forKey:@"FromNickName"];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDestroy object:groupId userInfo:userInfoDic];
                });
            });
        }
    });
}

- (void)pbChatRoomCardUpdate:(NSDictionary *)infoDic{
    NSString *groupId = [infoDic objectForKey:@"groupId"];
    NSString *nickName = [infoDic objectForKey:@"nickname"];
    NSString *title = [infoDic objectForKey:@"title"];
    NSString *pic = [infoDic objectForKey:@"pic"];
    NSString *desc = [infoDic objectForKey:@"desc"];
    NSString *version = [infoDic objectForKey:@"version"];
    NSMutableDictionary *groupInfoDic = [NSMutableDictionary dictionary];
    [groupInfoDic setQIMSafeObject:groupId forKey:@"MN"];
    [groupInfoDic setQIMSafeObject:nickName forKey:@"SN"];
    [groupInfoDic setQIMSafeObject:desc forKey:@"MD"];
    [groupInfoDic setQIMSafeObject:title forKey:@"MT"];
    [groupInfoDic setQIMSafeObject:pic forKey:@"MP"];
    [groupInfoDic setQIMSafeObject:version forKey:@"VS"];
    if (groupInfoDic) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_block_t block = ^{
                [self.groupVCardDict removeObjectForKey:groupId];
            };
            
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
            [[IMDataManager sharedInstance] bulkUpdateGroupCards:@[groupInfoDic]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName: kGroupNickNameChanged object:@[groupId]];
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self updateGroupCardByGroupId:groupId];
        });
    }
}

- (void)pbChatRoomRegisterDelMember:(NSDictionary *)infoDic{
    NSString *groupId = [infoDic objectForKey:@"groupId"];
    NSString *memberJid = [infoDic objectForKey:@"jid"];
    [[IMDataManager sharedInstance] deleteGroupMemberJid:memberJid WithGroupId:groupId];
    if ([memberJid isEqualToString:[self getLastJid]]) {
        [[IMDataManager sharedInstance] deleteGroup:groupId];
        [self removeSessionById:groupId];
        [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupId];
        [[IMDataManager sharedInstance] deleteMessageWithXmppId:groupId];
    }
}

- (void)pbUserStatusChanage:(NSDictionary *)infoDic{
    
}

#pragma mark - Transfer Chat

- (void)updateUserChannelInfo:(NSDictionary *)channelInfoDic {
    NSString *userId = [channelInfoDic objectForKey:@"userId"];
    NSString *channelInfo = [channelInfoDic objectForKey:@"channelid"];
    [self setChannelInfo:channelInfo ForUserId:userId];
}

- (void)updateUserAppendInfo:(NSDictionary *)appendInfoDict {
    NSString *userId = [appendInfoDict objectForKey:@"userId"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:appendInfoDict];
    [dict removeObjectForKey:@"userId"];
    [self setAppendInfo:dict ForUserId:userId];
}

- (void)onTransferChat:(NSDictionary *)infoDic {
    NSString *transFrom = [infoDic objectForKey:@"From"];
    int msgType = [[infoDic objectForKey:@"MsgType"] intValue];
    //    NSString *chatId = [infoDic objectForKey:@"ChatId"];
    NSString *json = [infoDic objectForKey:@"Json"];
    switch (msgType) {
        case 1001: { //用户端接收
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:json error:nil];
            if (infoDic) {
                NSString *transId = [infoDic objectForKey:@"TransId"];
                NSString *domain = [infoDic objectForKey:@"Domain"];
                NSString *transJid = [NSString stringWithFormat:@"%@@%@", transId, domain];
                NSDictionary *userInfo = [self getUserInfoByUserId:transJid];
                if (userInfo == nil) {
                    [self updateUserCard:@[transJid]];
                    userInfo = [self getUserInfoByUserId:transJid];
                }
                NSString *transName = [userInfo objectForKey:@"Name"];
                if (transName) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTransToUser object:transFrom userInfo:@{@"TransJid": transJid, @"TransName": transName}];
                    });
                }
            }
        }
            break;
        case 1002: { //商家端接收
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:json error:nil];
            if (infoDic) {
//                NSString *from = [infoDic objectForKey:@"f"];
//                NSString *domain = [infoDic objectForKey:@"d"];
//                NSString *transReason = [infoDic objectForKey:@"r"];
//                NSString *user = [infoDic objectForKey:@"u"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTransToBusiness object:transFrom userInfo:infoDic];
                });
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - App Config

- (void)friendValidation:(NSDictionary *)validationDic {
    NSString *from = [validationDic objectForKey:@"from"];
    NSString *body = [validationDic objectForKey:@"body"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
            NSDictionary *infoDic = [self getUserInfoByUserId:from];
            NSString *userId = [infoDic objectForKey:@"UserId"];
            NSString *xmppId = [infoDic objectForKey:@"XmppId"];
            NSString *name = [infoDic objectForKey:@"Name"];
            NSString *descInfo = [infoDic objectForKey:@"DescInfo"];
            NSString *headerSrc = [infoDic objectForKey:@"HeaderSrc"];
            NSString *searchIndex = [infoDic objectForKey:@"SearchIndex"];
            long long lastUpdateTime = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
            int state = 0;
            [[IMDataManager sharedInstance] insertFriendNotifyWihtUserId:userId
                                                              WithXmppId:xmppId
                                                                WithName:name
                                                            WithDescInfo:descInfo
                                                             WithHeadSrc:headerSrc
                                                         WithSearchIndex:searchIndex
                                                            WihtUserInfo:body
                                                             WithVersion:0
                                                               WihtState:state
                                                      WithLastUpdateTime:lastUpdateTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                QIMVerboseLog(@"抛出通知 QIMmanger friendValidation1  kNotificationSessionListUpdate");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        } else if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
            NSDictionary *infoDic = [self getQChatUserInfoForUser:from];
            NSString *userId = [infoDic objectForKey:@"username"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@", [infoDic objectForKey:@"username"], [self getDomain]];
            NSString *name = [infoDic objectForKey:@"nickname"];
            NSString *descInfo = @"";
            NSString *headerSrc = [[IMDataManager sharedInstance] getUserHeaderSrcByUserId:from];
            NSString *searchIndex = @"";
            long long lastUpdateTime = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
            int state = 0;
            [[IMDataManager sharedInstance] insertFriendNotifyWihtUserId:userId
                                                              WithXmppId:xmppId
                                                                WithName:name
                                                            WithDescInfo:descInfo
                                                             WithHeadSrc:headerSrc
                                                         WithSearchIndex:searchIndex
                                                            WihtUserInfo:body
                                                             WithVersion:0
                                                               WihtState:state
                                                      WithLastUpdateTime:lastUpdateTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                QIMVerboseLog(@"抛出通知 QIMmanger friendValidation2  kNotificationSessionListUpdate");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        }
    });
}

- (void)friendPresence:(NSDictionary *)presenceDic {
    NSString *from = [presenceDic objectForKey:@"from"];
    //    NSString *to = [presenceDic objectForKey:@"to"];
    //    int direction = [[presenceDic objectForKey:@"direction"] intValue];
    NSString *result = [presenceDic objectForKey:@"result"];
    //    NSString *reason = [presenceDic objectForKey:@"reason"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendPresence object:from userInfo:presenceDic];
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
        if ([result isEqualToString:@"success"]) {
            NSString *destId = from;//direction==2?from:to;
            NSDictionary *infoDic = [self getUserInfoByUserId:destId];
            [[IMDataManager sharedInstance]
             insertFriendWithUserId:[infoDic objectForKey:@"UserId"]
             WithXmppId:[infoDic objectForKey:@"XmppId"]
             WithName:[infoDic objectForKey:@"Name"]
             WithSearchIndex:[infoDic objectForKey:@"SearchIndex"]
             WithDescInfo:[infoDic objectForKey:@"DescInfo"]
             WithHeadSrc:[infoDic objectForKey:@"HeaderSrc"]
             WithUserInfo:[infoDic objectForKey:@"UserInfo"]
             WithLastUpdateTime:[[NSDate date] timeIntervalSinceNow] - self.serverTimeDiff
             WithIncrementVersion:0];
        }
    } else if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        NSDictionary *infoDic = [self getQChatUserInfoForUser:from];
        [[IMDataManager sharedInstance] insertFriendWithUserId:[infoDic objectForKey:@"username"]
                                                    WithXmppId:[NSString stringWithFormat:@"%@@%@", [infoDic objectForKey:@"username"], [self getDomain]]
                                                      WithName:[infoDic objectForKey:@"nickname"]
                                               WithSearchIndex:@""
                                                  WithDescInfo:@""
                                                   WithHeadSrc:[[IMDataManager sharedInstance] getUserHeaderSrcByUserId:from]
                                                  WithUserInfo:nil
                                            WithLastUpdateTime:[[NSDate date] timeIntervalSinceNow] - self.serverTimeDiff
                                          WithIncrementVersion:0];
    }
}

- (void)userMucListUpdate:(NSDictionary *)mucListDic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *mucListStr = [mucListDic objectForKey:@"MucListStr"];
        NSNumber *requestFlag = [mucListDic objectForKey:@"RequestFlag"];
        if ((requestFlag == nil || requestFlag.boolValue) && mucListStr) {
            NSMutableArray *groups = [[NSMutableArray alloc] initWithCapacity:20];
            NSArray *newGroupIds = [mucListStr componentsSeparatedByString:@","];
            QIMVerboseLog(@"========= 开始接受群列表数据，同步本地数据 ======= : %@", newGroupIds);
            NSMutableArray *groupIds = [NSMutableArray array];
            NSArray *oldGroupList = [self getGroupIdList];

            if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
                for (NSDictionary *myGroup in oldGroupList) {
                    NSString *groupId = [myGroup objectForKey:@"GroupId"];
                    if (![newGroupIds containsObject:groupId]) {
                        [[IMDataManager sharedInstance] deleteGroup:groupId];
                        [self removeSessionById:groupId];
                        [[IMDataManager sharedInstance] deleteGroupMemberWithGroupId:groupId];
                    }
                }
            }
            
            for (NSString *groupId in newGroupIds) {
                if (groupId.length > 0) {
                    [groups addObject:@[groupId,
                                        [groupId componentsSeparatedByString:@"@"].firstObject,
                                        @(0)]];
                    [groupIds addObject:groupId];
                }
            }
            [[IMDataManager sharedInstance] bulkinsertGroups:groups];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMyGroupListUpdate object:nil];
            });
        } else {
            
        }
    });
}

- (void)configForRemoteKeyAndSystemTime:(NSDictionary *)configDic {
    NSString *remoteKey = [configDic objectForKey:@"RemoteKey"];
    long long systemTime = [[configDic objectForKey:@"SystemTime"] longLongValue];
    
    self.remoteKey = remoteKey;
    self.serverTimeDiff = [[NSDate date] timeIntervalSince1970] - systemTime;
    { //U
        if (self.ucookie) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.ucookie];
        }
        NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
        [tcookieProperties setQIMSafeObject:@"_u" forKey:NSHTTPCookieName];
        [tcookieProperties setQIMSafeObject:[QIMManager getLastUserName] forKey:NSHTTPCookieValue];
        [tcookieProperties setQIMSafeObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [tcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
        [tcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
        
        self.ucookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:self.ucookie];
    }
    { //K
        if (self.kcookie) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:self.kcookie];
        }
        NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
        [tcookieProperties setQIMSafeObject:@"_k" forKey:NSHTTPCookieName];
        [tcookieProperties setQIMSafeObject:self.remoteKey forKey:NSHTTPCookieValue];
        [tcookieProperties setQIMSafeObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [tcookieProperties setQIMSafeObject:@"/" forKey:NSHTTPCookiePath];
        [tcookieProperties setQIMSafeObject:@"0" forKey:NSHTTPCookieVersion];
        
        self.kcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:self.kcookie];
    }
}

- (void)xmppStackConnectedTimesNotify:(NSNotification *)notify {
    //    [self addLogEventWithDescription:@"ScoketConnect" eventId:10010 eventType:2 eventValue:@([notify.object intValue])];
}

- (void)onMessageSendSuccess:(NSNotification *)notify {
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        long long receivedTime = [[notify.object objectForKey:@"receivedTime"] longLongValue];
        [[IMDataManager sharedInstance] updateMsgState:MessageState_Success WithMsgId:msgID];
        [[IMDataManager sharedInstance] updateMsgDate:receivedTime WithMsgId:msgID];
    });
}

- (void)onMessageSendFaild:(NSNotification *)notify {
    NSString *msgID = [notify.object objectForKey:@"messageId"];
    [[IMDataManager sharedInstance] updateMsgState:MessageState_Faild WithMsgId:msgID];
}

- (void)onRevoke:(NSDictionary *)infoDic {
    NSString *jid = [infoDic objectForKey:@"fromId"];
    NSString *msgId = [infoDic objectForKey:@"messageId"];
    NSString *msg = [infoDic objectForKey:@"message"];
    if (msg.length <= 0) {
        msg = @"该消息被撤回";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[IMDataManager sharedInstance] revokeMessageByMsgId:msgId WihtContent:msg WithMsgType:QIMMessageType_Revoke];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRevokeMsg object:jid userInfo:@{@"MsgId": msgId, @"Content": msg}];
    });
}

- (void)onConsultReadState:(NSDictionary *)infoDic {
    NSString * infoStr = [infoDic objectForKey:@"infoStr"];
    NSString * jid = [infoDic objectForKey:@"jid"];
    NSString * realJid = [infoDic objectForKey:@"realjid"];
    NSArray * readStateMsgList = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_didRead ByMsgIdList:readStateMsgList];
    [self.notReadMsgByGroupDic removeObjectForKey:[NSString stringWithFormat:@"%@-%@",jid,realJid]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:[NSString stringWithFormat:@"%@-%@",jid,realJid]];
}

- (void)onReadState:(NSDictionary *)infoDic {
    QIMVerboseLog(@"onReadState : %@", infoDic);
    dispatch_queue_t onReadStateQueue = dispatch_queue_create("onReadStateQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(onReadStateQueue, ^{
        if (!self.msgCompensateReadSet) {
            self.msgCompensateReadSet = [[NSMutableSet alloc] initWithCapacity:3];
        }
        NSInteger readType = [[infoDic objectForKey:@"readType"] integerValue];
        NSString *infoStr = [infoDic objectForKey:@"infoStr"];
        NSString *jid = [infoDic objectForKey:@"jid"];
        NSArray *readStateMsgList = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
        if (readType == 0) {
            NSDictionary *readMarkTDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
            long long readMarkT = [[readMarkTDic objectForKey:@"T"] longLongValue];
            [[IMDataManager sharedInstance] updateAllMsgWithMsgState:MessageState_didRead ByMsgDirection:MessageDirection_Received ByReadMarkT:readMarkT / 1000];
            [self.notReadMsgByGroupDic removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        } else {
            if ([jid containsString:@"@conference."]) {
                //群
                long long maxMucReadMarkUpdateTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"MaxMucReadMarkTime"] longLongValue];
                
                long long maxRemoteTime = [[IMDataManager sharedInstance] qimDB_updateGroupMsgWihtMsgState:MessageState_didRead ByGroupMsgList:readStateMsgList];
                if (maxRemoteTime > maxMucReadMarkUpdateTime) {
                    maxMucReadMarkUpdateTime = maxRemoteTime;
                    NSString *jid = [[QIMManager sharedInstance] getLastJid];
                    NSString *updateTime = [NSString stringWithFormat:@"%lld", maxMucReadMarkUpdateTime];
                    NSArray *configArray = @[@{@"subkey":jid?jid:@"", @"configinfo":updateTime}];
                    [[IMDataManager sharedInstance] qimDB_bulkInsertConfigArrayWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalMucRemarkUpdateTime] WithConfigVersion:0 ConfigArray:configArray];
                }
                
                [self decrementNotReadMsgCountByJid:jid];
                [self updateNotReadCountCacheByJid:jid];
            } else {
                //单人
                if (readType == 1) {
                    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_NotRead ByMsgIdList:readStateMsgList];
                    [self updateMessageStateWithNewState:MessageState_NotRead ByMsgIdList:readStateMsgList];
                    [self updateNotReadCountCacheByJid:jid];
                } else if (readType == 3) {
                    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_NotRead ByMsgIdList:readStateMsgList];
                    [self updateMessageStateWithNewState:MessageState_NotRead ByMsgIdList:readStateMsgList];
                    [self updateNotReadCountCacheByJid:jid];
                } else if (readType == 4) {
                    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_didRead ByMsgIdList:readStateMsgList];
                    [self updateMessageStateWithNewState:MessageState_didRead ByMsgIdList:readStateMsgList];
                    [self updateNotReadCountCacheByJid:jid];
                } else if (readType == 7) {
                    //已操作
                    [[IMDataManager sharedInstance] bulkUpdateChatMsgWithMsgState:MessageState_didControl ByMsgIdList:readStateMsgList];
                    [self updateMessageControlStateWithNewState:MessageState_didControl ByMsgIdList:readStateMsgList];
                    [self updateNotReadCountCacheByJid:jid];
                }
            }
        }
    });
}

- (void)onTyping:(NSDictionary *)infoDic {
    NSString *jid = [infoDic objectForKey:@"fromId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTyping object:jid];
}

- (void)onUserPresenceChange:(NSString *)userId {
    QIMVerboseLog(@"onUserPresenceChange %@", userId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserStatusChange object:userId];
        if (!self.isStartPushNotify) {
            return;
        }
    });
}

- (void)receiveQChatNoteMsg:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    dispatch_async(self.receive_msg_queue, ^{
        
        NSString *jid = [msgDic objectForKey:@"fromId"];
        NSString *infoStr = [msgDic objectForKey:@"infoStr"];
        long long msgDate = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 1) * 1000;
        int direction = MessageDirection_Received;
        int msgType = QIMMessageType_PNote;
        NSString *msgId = [QIMUUIDTools UUID];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];

        [self checkMsgTimeWithJid:jid WithMsgDate:msgDate WithGroup:NO];
        
        Message *mesg = [Message new];
        [mesg setFrom:jid];
        [mesg setMessageId:msgId];
        [mesg setMessageType:msgType];
        [mesg setChatType:ChatType_SingleChat];
        [mesg setMessageDirection:direction];
        [mesg setMessage:infoStr];
        [mesg setMessageDate:msgDate];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        
        // 消息落地
        if (![autoReply isEqualToString:@"true"]) {
            [self saveMsg:mesg ByJid:jid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:jid userInfo:@{@"message": mesg}];
            
            [self addSessionByType:ChatType_SingleChat ById:jid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
            if (![jid isEqualToString:self.currentSessionUserId]) {
                [self increasedNotReadMsgCountByJid:jid];
                [self updateNotReadCountCacheByJid:jid];
                [self playSound];
            }
            Message *mesg = [self createNoteReplyMessage:[NSString stringWithFormat:@"您好，我是在线客服%@，很高兴为您服务。", self.webName ? [NSString stringWithFormat:@"【%@】", self.webName] : @""] ToUserId:jid];
            [self sendMessage:mesg ToUserId:jid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:jid userInfo:@{@"message": mesg}];
            });
        });
        
    });
    
}

- (void)receiveQChatEndMsg:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    dispatch_async(self.receive_msg_queue, ^{
        
//        NSString * jid = [msgDic objectForKey:@"fromId"];
//        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self addSessionByType:ChatType_SingleChat ById:jid ByMsgId:nil WithMsgTime:msgDate];
//            if (![jid isEqualToString:_currentSessionUserId]) {
//                [self setNotReaderMsgCount:[self getNotReadMsgCountByJid:jid] + 1 ForJid:jid];
//                [self playSound];
//            }
//            Message * mesg = [self createNoteReplyMessage:@"通话结束！\n感谢您的咨询，欢迎再次咨询。" ToUserId:jid];
//            [self sendMessage:mesg ToUserId:jid];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:jid userInfo:@{@"message":mesg}];
        });
    });
}

- (void)receiveMsg:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    dispatch_async(self.receive_msg_queue, ^{
        
        if ([[msgDic objectForKey:@"msgtype"] isEqualToString:@"msgVoice"]) {
            //如果不为空，则是voice文件
            //#TODO 单人语音消息
            NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
            NSString *msg = [msgDic objectForKey:@"msg"];
            NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
            long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
            NSString *msgId = [msgDic objectForKey:@"msgId"];
            NSString *chatId = [msgDic objectForKey:@"chatId"];
            NSString *autoReply = [msgDic objectForKey:@"autoReply"];
            if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
                return;
            }
            [self saveChatId:chatId ForUserId:sid];
            [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
            
            int direction = [[msgDic objectForKey:@"direction"] intValue];
            
            Message *mesg = [Message new];
            [mesg setFrom:sid];
            if ([msgDic objectForKey:@"msgId"] != nil && ![[msgDic objectForKey:@"msgId"] isEqualToString:@"1"]) {
                NSString *messageId = [msgDic objectForKey:@"msgId"];
                [mesg setMessageId:messageId];
            }
            [mesg setMessageType:QIMMessageType_Voice];
            [mesg setChatType:ChatType_SingleChat];
            [mesg setMessageDirection:direction == 2 ? MessageDirection_Sent : MessageDirection_Received];
            [mesg setMessage:msg];
            [mesg setMessageDate:msgDate];
            [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
            [mesg setMsgRaw:msgRaw];
            // 消息落地
            if (![autoReply isEqualToString:@"true"]) {
                [self saveMsg:mesg ByJid:sid];
            }
            [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:mesg.messageId ChatId:sid withState:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
                [self addSessionByType:ChatType_SingleChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
                if (![sid isEqualToString:self.currentSessionUserId] && mesg.messageDirection == MessageDirection_Received) {
//                    [self setNotReaderMsgCount:[self getNotReadMsgCountByJid:sid] + 1 ForJid:sid];
                    [self increasedNotReadMsgCountByJid:sid];
                    [self updateNotReadCountCacheByJid:sid];
                    [self playSound];
                }
            });
            
        } else {
            //如果为空，则是message文件
            NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
            NSString *msg = [msgDic objectForKey:@"msg"];
            long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
            int direction = [[msgDic objectForKey:@"direction"] intValue];
            int msgType = [[msgDic objectForKey:@"msgType"] intValue];
            NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
            NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
            NSString *msgId = [msgDic objectForKey:@"msgId"];
            NSString *chatId = [msgDic objectForKey:@"chatId"];
            NSString *autoReply = [msgDic objectForKey:@"autoReply"];
            if (msgType == QIMMessageType_shareLocation && direction == 1) {
                NSDictionary *shareDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
                NSString *shareId = [shareDic objectForKey:@"shareId"];
                NSString *fromUser = [shareDic objectForKey:@"fromId"];
                [self.shareLocationDic setObject:shareId forKey:sid];
                [self.shareLocationFromIdDic setObject:fromUser forKey:shareId];
                NSMutableSet *users = [self.shareLocationUserDic objectForKey:shareId];
                if (users == nil) {
                    users = [NSMutableSet set];
                    [self.shareLocationUserDic setObject:users forKey:shareId];
                }
                [users addObject:fromUser];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kBeginShareLocation object:sid userInfo:shareDic];
                });
            }
            if (msgType == QIMMessageType_RedPackInfo || msgType == QIMMessageType_AAInfo) {
                NSDictionary *redPackInfoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
                NSString *jid = [redPackInfoDic objectForKey:@"From_User"];
                if ([jid isEqualToString:[QIMManager getLastUserName]] == NO) {
                    return;
                }
            }
            
            
            if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
                return;
            }
            
            [self saveChatId:chatId ForUserId:sid];
            [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
            
            Message *mesg = [Message new];
            [mesg setFrom:sid];
            [mesg setMessageId:msgId];
            [mesg setMessageType:msgType];
            [mesg setChatType:ChatType_SingleChat];
            [mesg setMessageDirection:direction == 2 ? MessageDirection_Sent : MessageDirection_Received];
            [mesg setMessage:msg];
            [mesg setMessageDate:msgDate];
            [mesg setExtendInformation:extendInfo];
            [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
            [mesg setMsgRaw:msgRaw];
            // 消息落地
            if (![autoReply isEqualToString:@"true"]) {
                [self saveMsg:mesg ByJid:sid];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
                [self addSessionByType:ChatType_SingleChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
                if (![sid isEqualToString:self.currentSessionUserId] && mesg.messageDirection == MessageDirection_Received) {
                    [self increasedNotReadMsgCountByJid:sid];
                    [self updateNotReadCountCacheByJid:sid];
                    if (mesg.messageType == QIMMessageType_RedPack) {
                        [self playHongBaoSound];
                    } else {
                        [self playSound];
                    }
                }
            });
        }
    });
}

- (void)receiveGroupMsg:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        //#TODO 群消息到达
        //if add by dan.zheng 15/4/28
        if ([[msgDic objectForKey:@"msgtype"] isEqualToString:@"msgVoice"]) {
            //如果不为空，则是voice文件
            NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
            NSString *msg = [msgDic objectForKey:@"msg"];
            long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
            
            NSString *nickName = [msgDic objectForKey:@"nickName"];
            NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
            NSString *backupInfo = [msgDic objectForKey:@"backupInfo"];
            NSString *messageId = [msgDic objectForKey:@"msgId"];
            NSString *autoReply = [msgDic objectForKey:@"autoReply"];
            // 消息已存在
            if ([[IMDataManager sharedInstance] checkMsgId:messageId]) {
                return;
            }
            [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:YES];
            
            Message *mesg = [Message new];
            [mesg setFrom:sid];
            [mesg setMessageId:messageId];
            [mesg setChatType:ChatType_GroupChat];
            [mesg setMessageType:QIMMessageType_Voice];
            [mesg setMessageDirection:[self getGroupMsgDirectionWithSendJid:nickName]];
            [mesg setMessage:msg];
            [mesg setNickName:nickName];
            [mesg setMessageDate:msgDate];
            [mesg setBackupInfo:backupInfo];
            [mesg setMsgRaw:msgRaw];
            [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
            if (![autoReply isEqualToString:@"true"]) {
                [self saveMsg:mesg ByJid:sid];
            }
            [[QIMVoiceNoReadStateManager sharedVoiceNoReadStateManager] setVoiceNoReadStateWithMsgId:mesg.messageId ChatId:sid withState:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
                [self addSessionByType:ChatType_GroupChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
                BOOL isRemind = [self groupPushState:sid];
                if (mesg.messageDirection == MessageDirection_Received && (![self.currentSessionUserId isEqualToString:sid])) {
                    
                    if (![sid isEqualToString:self.currentSessionUserId]) {
                        if (isRemind) {
                            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
                            [self performSelector:@selector(playSound) withObject:nil afterDelay:0.1];
                        }
                        [self increasedNotReadMsgCountByJid:sid];
                        [self updateNotReadCountCacheByJid:sid];
                    }
                }
            });
        } else {
            
            //如果为空，则是message文件
            NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
            NSString *msg = [msgDic objectForKey:@"msg"];
            int msgType = [[msgDic objectForKey:@"msgType"] intValue];
            NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
            long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
            NSString *nickName = [msgDic objectForKey:@"nickName"];
            NSString *messageId = [msgDic objectForKey:@"msgId"];
            NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
            NSString *replyMsgId = [msgDic objectForKey:@"replyMsgId"];
            NSString *replyUser = [msgDic objectForKey:@"replyUser"];
            NSString *backupInfo = [msgDic objectForKey:@"backupInfo"];
            NSString *autoReply = [msgDic objectForKey:@"autoReply"];
            if (msgType == QIMMessageType_shareLocation && [self getGroupMsgDirectionWithSendJid:nickName] == MessageDirection_Received) {
                NSDictionary *shareDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
                NSString *shareId = [shareDic objectForKey:@"shareId"];
                NSString *fromUser = [shareDic objectForKey:@"fromId"];
                [self.shareLocationDic setObject:shareId forKey:sid];
                [self.shareLocationFromIdDic setObject:fromUser forKey:shareId];
                NSMutableSet *users = [self.shareLocationUserDic objectForKey:shareId];
                if (users == nil) {
                    users = [NSMutableSet set];
                    [self.shareLocationUserDic setObject:users forKey:shareId];
                }
                [users addObject:fromUser];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kBeginShareLocation object:sid userInfo:shareDic];
                });
            }
            if (msgType == QIMMessageType_RedPackInfo || msgType == QIMMessageType_AAInfo) {
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
                NSString *fid = [infoDic objectForKey:@"From_User"];
                if ([fid isEqualToString:[QIMManager getLastUserName]] == NO) {
                    return;
                }
            }
            // 消息已存在
            if ([[IMDataManager sharedInstance] checkMsgId:messageId]) {
                return;
            }
            
            [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:YES];
            
            Message *mesg = [Message new];
            [mesg setFrom:sid];
            [mesg setMessageId:messageId];
            
            [mesg setChatType:ChatType_GroupChat];
            [mesg setMessageType:msgType];
            [mesg setMessageDirection:[self getGroupMsgDirectionWithSendJid:nickName]];
            [mesg setMessage:msg];
            [mesg setNickName:nickName];
            [mesg setMessageDate:msgDate];
            [mesg setExtendInformation:extendInfo];
            [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
            [mesg setReplyMsgId:replyMsgId];
            [mesg setReplyUser:replyUser];
            [mesg setBackupInfo:backupInfo];
            [mesg setMsgRaw:msgRaw];
            if (![autoReply isEqualToString:@"true"]) {
                [self saveMsg:mesg ByJid:sid];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
                [self addSessionByType:ChatType_GroupChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
                BOOL isRemind = [self groupPushState:sid];
                if (mesg.messageDirection == MessageDirection_Received && (![self.currentSessionUserId isEqualToString:sid])) {
                    if ([msg rangeOfString:@"@"].location != NSNotFound) {
                        NSArray *array = [msg componentsSeparatedByString:@"@"];
                        BOOL hasAt = NO;
                        BOOL hasAtAll = NO;
                        for (NSString *str in array) {
                            if ([[str lowercaseString] hasPrefix:@"all"] || [str hasPrefix:@"全体成员"]) {
                                hasAtAll = YES;
                                break;
                            }
                            NSString *prefix = [self getMyNickName];
                            if (prefix && [str hasPrefix:prefix]) {
                                hasAt = YES;
                                break;
                            }
                        }
                        if (hasAtAll) {
                            [self addAtALLByJid:sid WithMsgId:mesg.messageId WihtMsg:mesg WithNickName:nickName];
                        }
                        if (hasAt) {
                            [self addAtMeByJid:sid WithNickName:nickName];
                        }
                    }
                    if (![sid isEqualToString:self.currentSessionUserId]) {
                        if (isRemind) {
                            if (mesg.messageType == QIMMessageType_RedPack) {
                                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playHongBaoSound) object:nil];
                                [self performSelector:@selector(playHongBaoSound) withObject:nil afterDelay:0.1];
                            } else {
                                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
                                [self performSelector:@selector(playSound) withObject:nil afterDelay:0.1];
                            }
                        }
                        [self increasedNotReadMsgCountByJid:sid];
                        [self updateNotReadCountCacheByJid:sid];
                    }
                }
            });
        }
    });
}

- (void)receiveSystemMsg:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *msg = [msgDic objectForKey:@"msg"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        NSString *sid = [NSString stringWithFormat:@"SystemMessage@%@", [[QIMNavConfigManager sharedInstance] domain]];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];

        if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        
        Message *mesg = [Message new];
        [mesg setMessageId:msgId];
        [mesg setFrom:sid];
        [mesg setChatType:ChatType_System];
        [mesg setMessageType:QIMMessageType_Text];
        [mesg setMessageDirection:MessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        if (![autoReply isEqualToString:@"true"]) {
            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            [self addSessionByType:ChatType_System ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
            
            if (![sid isEqualToString:self.currentSessionUserId]) {
                [self increasedNotReadMsgCountByJid:sid];
                [self updateNotReadCountCacheByJid:sid];
                [self playSound];
            }
        });
        
    });
}

- (void)receiveShareLocationMsg:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        //如果为空，则是message文件
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        NSString *msg = [msgDic objectForKey:@"msg"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        int direction = [[msgDic objectForKey:@"direction"] intValue];
        int msgType = [[msgDic objectForKey:@"msgType"] intValue];
        NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        NSString *shareId = [msgDic objectForKey:@"shareId"];
        if (shareId.length <= 0) {
            return;
        }
        switch (msgType) {
            case ShareLocationType_Join: {
                //                [_shareLocationDic setObject:shareId forKey:sid];
                NSMutableSet *users = [self.shareLocationUserDic objectForKey:shareId];;
                if (users == nil) {
                    users = [NSMutableSet set];
                    [self.shareLocationUserDic setObject:users forKey:shareId];
                }
                [users addObject:sid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kJoinShareLocation object:sid];
                });
            }
                break;
            case ShareLocationType_Info: {
                Message *mesg = [Message new];
                [mesg setFrom:sid];
                [mesg setMessageType:msgType];
                [mesg setChatType:ChatType_SingleChat];
                [mesg setMessageDirection:direction == 2 ? MessageDirection_Sent : MessageDirection_Received];
                [mesg setMessage:msg];
                [mesg setMessageDate:msgDate];
                [mesg setExtendInformation:extendInfo];
                [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
                [mesg setMsgRaw:msgRaw];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShareLocationInfo object:sid userInfo:@{@"message": mesg}];
                });
            }
                break;
            case ShareLocationType_Quit: {
                NSMutableSet *users = [self.shareLocationUserDic objectForKey:shareId];;
                if (users == nil) {
                    users = [NSMutableSet set];
                    [self.shareLocationUserDic setObject:users forKey:shareId];
                }
                [users removeObject:sid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kQuitShareLocation object:sid];
                    if (users.count <= 0) {
                        [self.shareLocationUserDic removeObjectForKey:shareId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kEndShareLocation object:sid];
                    }
                });
            }
                break;
            default:
                break;
        }
    });
}

- (void)receiveGroupImage:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        NSString *msg = [msgDic objectForKey:@"msg"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:YES];
        
        
        NSString *nickName = [msgDic objectForKey:@"nickName"];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];

        Message *mesg = [Message new];
        [mesg setFrom:sid];
        [mesg setMessageId:msgId];
        
        [mesg setChatType:ChatType_GroupChat];
        [mesg setMessageType:QIMMessageType_Text];
        [mesg setMessageDirection:[self getGroupMsgDirectionWithSendJid:nickName]];
        [mesg setMessage:msg];
        [mesg setNickName:nickName];
        [mesg setMessageDate:msgDate];
        [mesg setExtendInformation:nil];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        [mesg setReplyMsgId:nil];
        [mesg setReplyUser:nil];
        [mesg setMsgRaw:msgRaw];
        if (![autoReply isEqualToString:@"true"]) {
            [self saveMsg:mesg ByJid:sid];
            [self updateMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            [self addSessionByType:ChatType_GroupChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
            BOOL isRemind = [self groupPushState:sid];
            if (mesg.messageDirection == MessageDirection_Received && (![self.currentSessionUserId isEqualToString:sid])) {
                if (![sid isEqualToString:self.currentSessionUserId]) {
                    if (isRemind) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
                        [self performSelector:@selector(playSound) withObject:nil afterDelay:0.1];
                    }
                    [self increasedNotReadMsgCountByJid:sid];
                    [self updateNotReadCountCacheByJid:sid];
                }
            }
        });
        
    });
    
}

- (void)receiveFile:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    dispatch_async(self.receive_msg_queue, ^{
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        NSString *msg = [msgDic objectForKey:@"msg"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];
        if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        int direction = [[msgDic objectForKey:@"direction"] intValue];
        Message *mesg = [Message new];
        [mesg setMessageId:msgId];
        [mesg setFrom:sid];
        [mesg setMessageType:QIMMessageType_File];
        [mesg setMessageDirection:direction == 2 ? MessageDirection_Sent : MessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setChatType:ChatType_SingleChat];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        // 消息落地
        if (![autoReply isEqualToString:@"true"]) {

            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            [self addSessionByType:ChatType_SingleChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
            
            if (![sid isEqualToString:self.currentSessionUserId] && mesg.messageDirection == MessageDirection_Received) {
                //                [self setNotReaderMsgCount:[self getNotReadMsgCountByJid:sid] + 1 ForJid:sid];
                [self increasedNotReadMsgCountByJid:sid];
                [self updateNotReadCountCacheByJid:sid];
                [self playSound];
            }
        });
        
    });
}


- (void)receiveGroupFile:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        NSString *msg = [msgDic objectForKey:@"msg"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *nickName = [msgDic objectForKey:@"nickName"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];
        MessageDirection direction = [self getGroupMsgDirectionWithSendJid:nickName];
        if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:YES];
        
        Message *mesg = [Message new];
        [mesg setMessageId:msgId];
        
        [mesg setFrom:sid];
        [mesg setChatType:ChatType_GroupChat];
        [mesg setMessageType:QIMMessageType_File];
        [mesg setMessageDirection:direction];
        [mesg setMessage:msg];
        [mesg setNickName:nickName];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        if (![autoReply isEqualToString:@"true"]) {
            [self saveMsg:mesg ByJid:sid];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            [self addSessionByType:ChatType_GroupChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
            BOOL isRemind = [self groupPushState:sid];
            if (mesg.messageDirection == MessageDirection_Received && (![self.currentSessionUserId isEqualToString:sid])) {
                if (![sid isEqualToString:self.currentSessionUserId]) {
                    if (isRemind) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
                        [self performSelector:@selector(playSound) withObject:nil afterDelay:0.1];
                    }
                    [self increasedNotReadMsgCountByJid:sid];
                    [self updateNotReadCountCacheByJid:sid];
                }
            }
        });
    });
}

//接受窗口抖动
- (void)receiveShock:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    dispatch_async(self.receive_msg_queue, ^{
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        if ([[IMDataManager sharedInstance] checkMsgId:msgId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        NSString *userName = nil;
        NSDictionary *userInfo = [self getUserInfoByUserId:sid];
        if (userInfo) {
            userName = [userInfo objectForKey:@"N"];
        }
        if (userName == nil) {
            userName = [[sid componentsSeparatedByString:@"@"] objectAtIndex:0];
        }
        NSString *msg = [NSString stringWithFormat:@"%@给您发送了一个窗口抖动。", userName];
        int direction = [[msgDic objectForKey:@"direction"] intValue];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];
        Message *mesg = [Message new];
        [mesg setMessageId:[msgDic objectForKey:@"msgId"]];
        [mesg setFrom:sid];
        [mesg setChatType:ChatType_SingleChat];
        [mesg setMessageType:QIMMessageType_Shock];
        [mesg setMessageDirection:direction == 2 ? MessageDirection_Sent : MessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        // 消息落地
        if (![autoReply isEqualToString:@"true"]) {

            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shockWindow];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            [self addSessionByType:ChatType_SingleChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
        });
    });
}

//接收群组窗口抖动
- (void)receiveGroupShock:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        NSString *nickName = [msgDic objectForKey:@"nickName"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        NSString *msg = [NSString stringWithFormat:@"%@给您发送了一个窗口抖动。", nickName];
        
        Message *mesg = [Message new];
        [mesg setMessageId:[msgDic objectForKey:@"msgId"]];
        [mesg setFrom:sid];
        [mesg setMessageType:QIMMessageType_Shock];
        [mesg setMessageDirection:[self getGroupMsgDirectionWithSendJid:nickName]];
        [mesg setMessage:msg];
        [mesg setNickName:nickName];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isRemind = [self groupPushState:sid];
            if (mesg.messageDirection == MessageDirection_Received && (![self.currentSessionUserId isEqualToString:sid])) {
                
                if (![sid isEqualToString:self.currentSessionUserId]) {
                    if (isRemind) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playSound) object:nil];
                        [self performSelector:@selector(playSound) withObject:nil afterDelay:0.1];
                    }
                    [self increasedNotReadMsgCountByJid:sid];
                    [self updateNotReadCountCacheByJid:sid];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            });
            [self addSessionByType:ChatType_GroupChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
        });
    });
}

- (void)receivePublicNumberMsg:(NSDictionary *)msgDic {
    // 消息ID
    NSString *msgId = [msgDic objectForKey:@"MsgId"];
    // 消息类型
    int msgType = [[msgDic objectForKey:@"MsgType"] intValue];
    // 消息
    NSString *msg = [msgDic objectForKey:@"Message"];
    // from
    NSString *publicNumberId = [msgDic objectForKey:@"PublicNumberId"];
    // Date
    long long msgDate = [[msgDic objectForKey:@"MsgDate"] timeIntervalSince1970] * 1000;
    
    NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
    if ([[IMDataManager sharedInstance] checkPublicNumberMsgById:msgId]) {
        return;
    }
    BOOL isSystemMsg = NO;
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        if ([publicNumberId hasPrefix:@"rbt-system"]) {
            isSystemMsg = YES;
        } else if ([publicNumberId hasPrefix:@"rbt-notice"]) {
            isSystemMsg = YES;
        } else if ([publicNumberId hasPrefix:@"rbt-qiangdan"]) {
            isSystemMsg = YES;
        } else if ([publicNumberId hasPrefix:@"rbt-zhongbao"]) {
            isSystemMsg = YES;
        }
    }
    
    if (msgType != PublicNumberMsgType_Action && msgType != PublicNumberMsgType_ClientCookie && msgType != PublicNumberMsgType_PostBackCookie && msgType != QIMMessageType_ConsultResult && msgType != MessageType_C2BGrabSingleFeedBack) {
        if (isSystemMsg) {
            [self checkMsgTimeWithJid:publicNumberId WithMsgDate:msgDate WithGroup:NO];
        } else {
            [self checkPNMsgTimeWithJid:publicNumberId WithMsgDate:msgDate];
        }
    }
    
    NSDictionary *dic = [self getPublicNumberCardByJid:publicNumberId];
    if (dic == nil) {
        NSString *enName = [publicNumberId componentsSeparatedByString:@"@"].firstObject;
        NSArray *cardList = [self updatePublicNumberCardByIds:@[@{@"robot_name": enName, @"version": @(0)}] WithNeedUpdate:YES];
        if (cardList.count <= 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@(0) forKey:@"rbt_ver"];
            [dic setObject:enName forKey:@"robotEnName"];
            [dic setObject:enName forKey:@"robotCnName"];
            [dic setObject:enName forKey:@"searchIndex"];
            [[IMDataManager sharedInstance] bulkInsertPublicNumbers:@[dic]];
        }
    }
    Message *c2bFeedBackMessage = [Message new];
    Message *message = [Message new];
    [message setMessageId:msgId];
    [message setFrom:publicNumberId];
    [message setMessageDirection:MessageDirection_Received];
    if (isSystemMsg) {
        [message setChatType:ChatType_System];
    } else {
        [message setChatType:ChatType_PublicNumber];
    }
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setExtendInformation:extendInfo];
    [message setMessageState:MessageState_none];
    [message setMessageDate:msgDate];
    if (msgType != PublicNumberMsgType_Action && msgType != PublicNumberMsgType_ClientCookie && msgType != PublicNumberMsgType_PostBackCookie && msgType != QIMMessageType_ConsultResult) {
        [self saveMsg:message ByJid:publicNumberId];
    } else if (msgType == QIMMessageType_ConsultResult) {
        // 保存渠道信息
        if (message.extendInformation) {
            [message setMessage:message.extendInformation];
        }
        NSDictionary *resultContent = [[QIMJSONSerializer sharedInstance] deserializeObject:extendInfo error:nil];
        BOOL result = [[resultContent objectForKey:@"result"] boolValue];
        NSString *sessionId = [resultContent objectForKey:@"sessionid"];
        if ([sessionId rangeOfString:@"@"].location == NSNotFound) {
            sessionId = [sessionId stringByAppendingFormat:@"@%@", [self getDomain]];
        }
        NSString *name = [resultContent objectForKey:@"nickname"];
        NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
        [userDic setObject:[sessionId componentsSeparatedByString:@"@"].firstObject forKey:@"U"];
        [userDic setObject:name forKey:@"N"];
        [[IMDataManager sharedInstance] InsertOrUpdateUserInfos:@[userDic]];
        if (result) {
            NSString *channelid = [msgDic objectForKey:@"channelid"];
            [self setChannelInfo:channelid ForUserId:sessionId];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSessionByType:ChatType_SingleChat ById:sessionId ByMsgId:message.messageId WithMsgTime:message.messageDate WithNeedUpdate:YES];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (message.messageType == MessageType_C2BGrabSingleFeedBack) {
            NSString *c2BExtendInfo = message.extendInformation;
            NSDictionary *c2BMsgDict = [[QIMJSONSerializer sharedInstance] deserializeObject:c2BExtendInfo error:nil];
            NSString *c2BMsgId = nil;
            NSString *btnDisplay = nil;
            BOOL c2BStatus = YES;
            NSString *dealId = nil;
            if (c2BMsgDict.count > 0) {
                c2BMsgId = [c2BMsgDict objectForKey:@"msgId"];
                btnDisplay = [c2BMsgDict objectForKey:@"btnDisplay"];
                c2BStatus = [[c2BMsgDict objectForKey:@"status"] boolValue];
                dealId = [c2BMsgDict objectForKey:@"dealId"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationC2BMessageFeedBackUpdate object:c2BMsgId userInfo:@{@"message": c2bFeedBackMessage}];
            return ;
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:publicNumberId userInfo:@{@"message": message}];
            QIMVerboseLog(@"抛出通知 QIMmanger receivePublicNumberMsg  kNotificationSessionListUpdate");
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            if (isSystemMsg) {
                [self addSessionByType:ChatType_System ById:publicNumberId ByMsgId:message.messageId WithMsgTime:message.messageDate WithNeedUpdate:YES];
            }
            if (![publicNumberId isEqualToString:[self getCurrentSessionUserId]] && message.messageDirection == MessageDirection_Received) {
                if (isSystemMsg == NO) {
                    [self setNotReaderMsgCount:[self getNotReaderMsgCountByPublicNumberId:publicNumberId] + 1 ForPublicNumberId:publicNumberId];
                } else {
                    [self increasedNotReadMsgCountByJid:publicNumberId];
                    [self updateNotReadCountCacheByJid:publicNumberId];
                }
                
                [self playSound];
            }
        }
    });
}

- (void)beginToConnect {
    QIMVerboseLog(@"准备开始连接");
    [self updateAppWorkState:AppWorkState_Logining];
}

- (void)beenConnected {
    QIMVerboseLog(@"已经连接上了");
    [self updateAppWorkState:AppWorkState_Login];
}

- (void)loginFaild:(NSDictionary *)errDic {
    
    self.willCancelLogin = YES;
    self.needTryRelogin = NO;
    self.notNeedCheckNetwotk = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMErrorLog(@"LoginFaild: %@", errDic);
        if ([[errDic objectForKey:@"errMsg"] isEqualToString:@"out_of_date"]) {
            
            [self sendNoPush];
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"kTempUserToken"];
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"userToken"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationOutOfDate" object:nil];
            });
        }
        
        [self updateAppWorkState:AppWorkState_Logout];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginState object:[NSNumber numberWithBool:NO] userInfo:errDic];
    });
}

- (void)registerComplate {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterState object:[NSNumber numberWithBool:YES]];
    });
    dispatch_async(self.cacheQueue, ^{
        
        [self updateRosterList];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self updateChatRoomList];
    });
    
}

@end
