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
    
#pragma mark - 在线接收消息
    //在线接收单人消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveMsg:) withXmppEvent:XmppEvent_MessageIn];
    //在线接收群消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveGroupMsg:) withXmppEvent:XmppeventGroupMessageIn];
    //在线接收系统消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveSystemMsg:) withXmppEvent:XmppEvent_SystemMessageIn];
    //在线接收位置共享消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveShareLocationMsg:) withXmppEvent:XmppEvent_ShareLocation];
    //在线接收单人窗口抖动消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveShock:) withXmppEvent:XmppEvent_ShockIn];
    //在线接收“正在输入中消息”
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onTyping:) withXmppEvent:XmppEvent_Typing];
    //在线接收撤销消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onRevoke:) withXmppEvent:XmppEvent_Revoke];
    //在线接收Consult消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveConsultMessage:) withXmppEvent:XmppEvent_ReceiveConsultMessage];
    //在线接收代收消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveCollectionMessage:) withXmppEvent:XmppEvent_CollectionMessageIn];
    //在线接收代收原始消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveCollectionOriginMessage:) withXmppEvent:XmppEvent_CollectionOriginMessageIn];
    //接收到加密消息
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveEncryptMessage:) withXmppEvent:XmppEvent_ReceiveEncryptMessage];
    //在线接收到发送消息错误
    [[XmppImManager sharedInstance] addTarget:self method:@selector(receiveErrorMessage:) withXmppEvent:XmppEvent_MessageError];
    //在线接收消息阅读状态
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onReadState:) withXmppEvent:XmppEvent_ReadState];
    //在线接收消息发送状态
    [[XmppImManager sharedInstance] addTarget:self method:@selector(onMessageStateUpdate:) withXmppEvent:XmppEvent_MStateUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppStackConnectedTimesNotify:) name:XmppstackConnectedTimes object:nil];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(userMucListUpdate:) withXmppEvent:XmppEvent_User_Muc_List];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(friendPresence:) withXmppEvent:XmppEvent_Friend_Presence];
    
    [[XmppImManager sharedInstance] addTarget:self method:@selector(friendValidation:) withXmppEvent:XmppEvent_Friend_Validation];
    
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
    
//    [[XmppImManager sharedInstance] addTarget:self method:@selector(userResourceNotify:) withXmppEvent:XmppEvent_UserResource];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(callVideoAudio:) withXmppEvent:XmppEvent_CallVideoAudio];
    [[XmppImManager sharedInstance] addTarget:self method:@selector(meetingAudioVideoConference:) withXmppEvent:XmppEvent_CallMeetingAudioVideoConference];
    
    //登录之前同步一下消息时间戳
    [[XmppImManager sharedInstance] addTarget:self method:@selector(updateOfflineTime:) withXmppEvent:XmppEvent_UpdateOfflineTime];
}

- (void)updateOfflineTime:(NSDictionary *)infoDic {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //这里并发进行checkPoint会导致后面的sql wait，所以将checkpoint的逻辑移到app进入后台。
//        QIMVerboseLog(@"登录之前数据库进行checkPoint");
//        [[IMDataManager qimDB_SharedInstance] qimDB_dbCheckpoint];
//        QIMVerboseLog(@"登录之前数据库完成checkPoint");
        
        QIMVerboseLog(@"登录之前初始化数据库文件之后更新各种时间戳开始 : %@", infoDic);
        [self updateLastMsgTime];
        [self updateLastGroupMsgTime];
        [self updateLastSystemMsgTime];
        [self updateLastMaxMucReadMarkTime];
        [self updateLastWorkFeedMsgTime];
        QIMVerboseLog(@"登录之前初始化数据库文件之后更新各种时间戳完成");
    });
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
                   QIMMessageModel *msg = [[QIMManager sharedInstance] createMessageWithMsg:@"消息已发出，但被对方拒收了。" extenddInfo:nil userId:from realJid:from userType:ChatType_SingleChat msgType:QIMMessageType_Time forMsgId:[QIMUUIDTools UUID] willSave:YES];
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
//TCP通知类型消息
- (void)receiveCategoryNotifyMessage:(NSDictionary *)msgDic {
    dispatch_async(self.receive_notify_queue, ^{
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
                    [self updateOrganizationalStructure];
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
//                NSNumber *forceOldSearch = [notifyMsg objectForKey:@"forceOldSearch"];
                BOOL forceOldSearch = [[notifyMsg allKeys] containsObject:@"forceOldSearch"];
                if ([[IMDataManager qimDB_SharedInstance] qimDB_getConfigVersion] < version && ![resource isEqualToString:[[XmppImManager sharedInstance] resource]]) {
                    [self getRemoteClientConfig];
                } else if (forceUpdate) {
                    QIMVerboseLog(@"强制更新个人配置信息");
                    [[IMDataManager qimDB_SharedInstance] qimDB_clearClientConfig];
                    [self getRemoteClientConfig];
                } else if (forceQuickReplyUpdate) {
                    QIMVerboseLog(@"强制更新快捷回复");
                    [[IMDataManager qimDB_SharedInstance] qimDB_clearQuickReplyGroup];
                    [[IMDataManager qimDB_SharedInstance] qimDB_clearQuickReplyContents];
                    [self getRemoteQuickReply];
                } else if (forceRNUpdate) {
                    QIMVerboseLog(@"收到RN包清除通知");
                    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    //内置包版本
                    NSString *latestJSCodeURLString = [path stringByAppendingPathComponent:@"rnRes"];
                    BOOL removeSussess = [[NSFileManager defaultManager] removeItemAtPath:latestJSCodeURLString error:nil];
                    if (removeSussess) {
                        QIMVerboseLog(@"清空RN包缓存成功 : %@", latestJSCodeURLString);
                    } else {
                        QIMVerboseLog(@"清空RN包缓存失败 : %@", latestJSCodeURLString);
                    }
                } else if (forceOldSearch) {
                    QIMVerboseLog(@"强制切换老版本搜索");
                    NSNumber *forceOldSearchNumber = [notifyMsg objectForKey:@"forceOldSearch"];
                    [[QIMUserCacheManager sharedInstance] setUserObject:forceOldSearchNumber forKey:@"forceOldSearch"];
                } else {
                    
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
                long long oldVersion = [[[IMDataManager qimDB_SharedInstance] qimDB_getConfigInfoWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalTripUpdateTime] WithSubKey:[[QIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
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
            case QIMCategoryNotifyMsgTypeHotLineSync:{
                [[QIMManager sharedInstance] getRemoteHotlineShopList];
            }
                break;
            case QIMCategoryNotifyMsgTypeTickUserWorkWorldNotice: {
                NSString *onlineListStr = [msgDic objectForKey:@"bodyValue"];
                NSDictionary *onlineDict = [[QIMJSONSerializer sharedInstance] deserializeObject:onlineListStr error:nil];
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkinsertNoticeMessage:@[onlineDict]];
                NSInteger eventType = [[onlineDict objectForKey:@"eventType"] integerValue];
                if (eventType == QIMWorkFeedNotifyTypeComment) {
                    QIMVerboseLog(@"online Comment 通知 : %@", onlineDict);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
                        NSInteger notReadMessageCount = [[QIMManager sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(QIMWorkFeedNotifyTypeComment), @(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
                        QIMVerboseLog(@"发送驼圈在线消息小红点通知数: %ld", notReadMessageCount);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkNoticeCount":@(notReadMessageCount)}];
                    });
                } else if (eventType == QIMWorkFeedNotifyTypePOST) {
                    QIMVerboseLog(@"online 新帖子 通知 : %@", onlineDict);
                    NSString *owner = [onlineDict objectForKey:@"owner"];
                    NSString *ownerHost = [onlineDict objectForKey:@"ownerHost"];
                    NSString *ownerId = [NSString stringWithFormat:@"%@@%@", owner, ownerHost];
                    if (![ownerId isEqualToString:[[QIMManager sharedInstance] getLastJid]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkMoment":@(YES)}];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SUGGEST_WorkFeed_UPDATE object:[self getLastWorkOnlineMomentWithDic:onlineDict]];
                        });
                    }
                } else if (eventType == QIMWorkFeedNotifyTypePOSTAt) {
                  //帖子艾特
                    QIMVerboseLog(@"online 新帖子艾特 通知 : %@", onlineDict);
                    QIMVerboseLog(@"online Comment 通知 : %@", onlineDict);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
                        NSInteger notReadMessageCount = [[QIMManager sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(QIMWorkFeedNotifyTypeComment), @(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
                        QIMVerboseLog(@"发送驼圈在线消息小红点通知数: %ld", notReadMessageCount);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkNoticeCount":@(notReadMessageCount)}];
                    });
                } else if (eventType == QIMWorkFeedNotifyTypeCommentAt) {
                  //评论艾特
                    QIMVerboseLog(@"online 新评论艾特 通知 : %@", onlineDict);
                    QIMVerboseLog(@"online Comment 通知 : %@", onlineDict);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
                        NSInteger notReadMessageCount = [[QIMManager sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(QIMWorkFeedNotifyTypeComment), @(QIMWorkFeedNotifyTypePOSTAt), @(QIMWorkFeedNotifyTypeCommentAt)]];
                        QIMVerboseLog(@"发送驼圈在线消息小红点通知数: %ld", notReadMessageCount);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkNoticeCount":@(notReadMessageCount)}];
                    });
                } else {
                    QIMVerboseLog(@"online 驼圈其他通知 : %@", onlineDict);
                }
            }
                break;
            case QIMCategoryNotifyMsgTypeMedalListUpdateNotice: {
                QIMVerboseLog(@"online 更新勋章列表");
                NSInteger version = [[notifyMsg objectForKey:@"medalVersion"] integerValue];
                [[QIMManager sharedInstance] getRemoteMedalList];
            }
                break;
            case QIMCategoryNotifyMsgTypeUserMedalUpdateNotice: {
                QIMVerboseLog(@"online 更新用户的勋章");
                NSInteger version = [[notifyMsg objectForKey:@"userMedalVersion"] integerValue];
                [[QIMManager sharedInstance] getRemoteUserMedalListWithUserId:nil];
            }
                break;
            default: {
                QIMVerboseLog(@"遇到不认识的categoryType : %@", msgDic);
            }
                break;
        }
        QIMVerboseLog(@"%s", __func__);
    });
}

#pragma mark - Receive Msgs接收消息

- (void)onRevoke:(NSDictionary *)infoDic {
    NSString *jid = [infoDic objectForKey:@"fromId"];
    NSString *msgId = [infoDic objectForKey:@"messageId"];
    NSString *msg = [infoDic objectForKey:@"message"];
    if (msg.length <= 0) {
        msg = @"该消息被撤回";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[IMDataManager qimDB_SharedInstance] qimDB_revokeMessageByMsgId:msgId WithContent:msg WithMsgType:QIMMessageType_Revoke];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRevokeMsg object:jid userInfo:@{@"MsgId": msgId, @"Content": msg}];
    });
}

- (void)receiveMsg:(NSDictionary *)msgDic {
    if (msgDic == nil) {
        return;
    }
    dispatch_async(self.receive_msg_queue, ^{
        
        //如果为空，则是message文件
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        IMPlatform platFormType = [[msgDic objectForKey:@"payformType"] integerValue];
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
        
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId]) {
            return;
        }
        
        [self saveChatId:chatId ForUserId:sid];
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        
        QIMMessageModel *mesg = [QIMMessageModel new];
        [mesg setXmppId:sid];
        [mesg setFrom:sid];
        [mesg setRealJid:sid];
        [mesg setPlatform:platFormType];
        [mesg setMessageId:msgId];
        [mesg setMessageType:msgType];
        [mesg setChatType:ChatType_SingleChat];
        [mesg setMessageDirection:direction == 2 ? QIMMessageDirection_Sent : QIMMessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageSendState:QIMMessageSendState_Success];
        [mesg setMessageReadState:QIMMessageRemoteReadStateDidSent];
        [mesg setMessageDate:msgDate];
        [mesg setExtendInformation:extendInfo];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        [mesg setMsgRaw:msgRaw];
        // 消息落地
        [self addSessionByType:ChatType_SingleChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
        if (![autoReply isEqualToString:@"true"]) {
            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            if (![sid isEqualToString:self.currentSessionUserId] && mesg.messageDirection == QIMMessageDirection_Received) {
                if (mesg.messageType == QIMMessageType_RedPack) {
                    [self playHongBaoSound];
                } else {
                    [self playSound];
                }
            }
        });
    });
}

- (void)receiveGroupMsg:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msg_queue, ^{
        QIMVerboseLog(@"在线接收群消息 : %@", msgDic);
        NSString *sid = [NSString stringWithFormat:@"%@@%@", [msgDic objectForKey:@"fromId"], [msgDic objectForKey:@"domain"]];
        NSString *sendJid = [msgDic objectForKey:@"sendJid"];
        NSString *msg = [msgDic objectForKey:@"msg"];
        int msgType = [[msgDic objectForKey:@"msgType"] intValue];
        NSString *extendInfo = [msgDic objectForKey:@"extendInfo"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        NSString *messageId = [msgDic objectForKey:@"msgId"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        NSString *backupInfo = [msgDic objectForKey:@"backupInfo"];
        BOOL carbonMessage = [[msgDic objectForKey:@"carbonMessage"] boolValue];
        BOOL autoReply = [[msgDic objectForKey:@"autoReply"] boolValue];
        if (msgType == QIMMessageType_shareLocation && [self getGroupMsgDirectionWithSendJid:sendJid] == QIMMessageDirection_Received) {
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
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:messageId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:YES];
        
        QIMMessageModel *mesg = [QIMMessageModel new];
        [mesg setXmppId:sid];
        [mesg setFrom:sendJid];
        [mesg setRealJid:sid];
        [mesg setMessageId:messageId];
        
        [mesg setChatType:ChatType_GroupChat];
        [mesg setMessageType:msgType];
        [mesg setMessageDirection:[self getGroupMsgDirectionWithSendJid:sendJid]];
        [mesg setMessage:msg];
        [mesg setMessageSendState:QIMMessageSendState_Success];
        [mesg setMessageReadState:QIMMessageRemoteReadStateDidSent];
        [mesg setMessageDate:msgDate];
        [mesg setExtendInformation:extendInfo];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        [mesg setBackupInfo:backupInfo];
        [mesg setMsgRaw:msgRaw];
        [self addSessionByType:ChatType_GroupChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
        if (autoReply == NO) {
            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            BOOL isRemind = [self groupPushState:sid];
            if (mesg.messageDirection == QIMMessageDirection_Received && (![self.currentSessionUserId isEqualToString:sid])) {
                if (mesg.messageType == QIMMessageType_NewAt) {
                    //新版艾特消息
                    NSArray *array = [[QIMJSONSerializer sharedInstance] deserializeObject:backupInfo error:nil];
                    BOOL atMe = NO;
                    if ([array isKindOfClass:[NSArray class]]) {
                        NSDictionary *groupAtDic = [array firstObject];
                        for (NSDictionary *someOneAtDic in [groupAtDic objectForKey:@"data"]) {
                            NSString *someOneJid = [someOneAtDic objectForKey:@"jid"];
                            if ([someOneJid isEqualToString:[[QIMManager sharedInstance] getLastJid]]) {
                                atMe = YES;
                            }
                        }
                    }
                    if (atMe == YES) {
                        [self addAtMeMessageByJid:sid withType:QIMAtTypeSP withMsgId:mesg.messageId withMsgTime:[mesg messageDate]];
                    }
                } else {
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
                            [self addAtMeMessageByJid:sid withType:QIMAtTypeALL withMsgId:mesg.messageId withMsgTime:[mesg messageDate]];
                        }
                        if (hasAt) {
                            [self addAtMeMessageByJid:sid withType:QIMAtTypeSP withMsgId:mesg.messageId withMsgTime:[mesg messageDate]];
                        }
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
                    [self updateNotReadCountCacheByJid:sid];
                }
            }
        });
    });
}

- (void)receiveSystemMsg:(NSDictionary *)msgDic {
    QIMVerboseLog(@"在线收到系统消息: %@", msgDic);
    dispatch_async(self.receive_msg_queue, ^{
        
        NSString *msgId = [msgDic objectForKey:@"msgId"];
        NSString *msg = [msgDic objectForKey:@"msg"];
        NSString *msgRaw = [msgDic objectForKey:@"msgRaw"];
        long long msgDate = [[msgDic objectForKey:@"stamp"] timeIntervalSince1970] * 1000;
        NSString *sid = [NSString stringWithFormat:@"SystemMessage@%@", [[QIMNavConfigManager sharedInstance] domain]];
        NSString *autoReply = [msgDic objectForKey:@"autoReply"];
        
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId]) {
            return;
        }
        [self checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        
        QIMMessageModel *mesg = [QIMMessageModel new];
        [mesg setXmppId:sid];
        [mesg setRealJid:sid];
        [mesg setMessageId:msgId];
        [mesg setFrom:sid];
        [mesg setChatType:ChatType_System];
        [mesg setMessageType:QIMMessageType_Text];
        [mesg setMessageDirection:QIMMessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        [mesg setMessageSendState:QIMMessageSendState_Success];
        [self addSessionByType:ChatType_System ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];

        if (![autoReply isEqualToString:@"true"]) {
            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
            if (![sid isEqualToString:self.currentSessionUserId]) {
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
                QIMMessageModel *mesg = [QIMMessageModel new];
                [mesg setFrom:sid];
                [mesg setMessageType:msgType];
                [mesg setChatType:ChatType_SingleChat];
                [mesg setMessageDirection:direction == 2 ? QIMMessageDirection_Sent : QIMMessageDirection_Received];
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
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId]) {
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
        QIMMessageModel *mesg = [QIMMessageModel new];
        [mesg setMessageId:[msgDic objectForKey:@"msgId"]];
        [mesg setFrom:sid];
        [mesg setChatType:ChatType_SingleChat];
        [mesg setMessageType:QIMMessageType_Shock];
        [mesg setMessageDirection:direction == 2 ? QIMMessageDirection_Sent : QIMMessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        [mesg setMessageSendState:QIMMessageSendState_Success];
        [self addSessionByType:ChatType_SingleChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:YES];
        // 消息落地
        if (![autoReply isEqualToString:@"true"]) {
            
            [self saveMsg:mesg ByJid:sid];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shockWindow];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
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
    if ([[IMDataManager qimDB_SharedInstance] qimDB_checkPublicNumberMsgById:msgId]) {
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
        [self updatePublicNumberCardByIds:@[@{@"robot_name": enName, @"version": @(0)}] WithNeedUpdate:YES withCallBack:^(NSArray *cardList) {
            if (cardList.count <= 0) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setObject:@(0) forKey:@"rbt_ver"];
                [dic setObject:enName forKey:@"robotEnName"];
                [dic setObject:enName forKey:@"robotCnName"];
                [dic setObject:enName forKey:@"searchIndex"];
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPublicNumbers:@[dic]];
            }
        }];
        /*
        NSArray *cardList = [self updatePublicNumberCardByIds:@[@{@"robot_name": enName, @"version": @(0)}] WithNeedUpdate:YES];
        if (cardList.count <= 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@(0) forKey:@"rbt_ver"];
            [dic setObject:enName forKey:@"robotEnName"];
            [dic setObject:enName forKey:@"robotCnName"];
            [dic setObject:enName forKey:@"searchIndex"];
            [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertPublicNumbers:@[dic]];
        }
        */
    }
    QIMMessageModel *c2bFeedBackMessage = [QIMMessageModel new];
    QIMMessageModel *message = [QIMMessageModel new];
    [message setMessageId:msgId];
    [message setFrom:publicNumberId];
    [message setRealJid:publicNumberId];
    [message setMessageDirection:QIMMessageDirection_Received];
    if (isSystemMsg) {
        [message setChatType:ChatType_System];
    } else {
        [message setChatType:ChatType_PublicNumber];
    }
    [message setMessageType:msgType];
    [message setMessage:msg];
    [message setExtendInformation:extendInfo];
    [message setMessageSendState:QIMMessageSendState_Success];
    [message setMessageDate:msgDate];
    if (msgType != PublicNumberMsgType_Action && msgType != PublicNumberMsgType_ClientCookie && msgType != PublicNumberMsgType_PostBackCookie && msgType != QIMMessageType_ConsultResult) {
        [self saveMsg:message ByJid:publicNumberId];
    } else if (msgType == QIMMessageType_ConsultResult) {
        // 保存渠道信息
        if (message.extendInformation.length > 0) {
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
        [[IMDataManager qimDB_SharedInstance] qimDB_InsertOrUpdateUserInfos:@[userDic]];
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
            if (![publicNumberId isEqualToString:[self getCurrentSessionUserId]] && message.messageDirection == QIMMessageDirection_Received) {
                if (isSystemMsg == NO) {
                    [self setNotReaderMsgCount:[self getNotReaderMsgCountByPublicNumberId:publicNumberId] + 1 ForPublicNumberId:publicNumberId];
                } else {
                    [self updateNotReadCountCacheByJid:publicNumberId];
                }
                
                [self playSound];
            }
        }
    });
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
        
        
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId]) {
            return;
        }
        [[QIMManager sharedInstance] checkMsgTimeWithJid:sid WithMsgDate:msgDate WithGroup:NO];
        
        QIMMessageModel *mesg = [QIMMessageModel new];
        [mesg setXmppId:sid];
        [mesg setFrom:realfrom];
        [mesg setRealJid:sid];
        [mesg setChatType:ChatType_CollectionChat];
        [mesg setMessageId:msgId];
        [mesg setMessageType:msgType];
        [mesg setMessageDirection:direction == 2 ? QIMMessageDirection_Sent : QIMMessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setMessageDate:msgDate];
        [mesg setMessageReadState:QIMMessageRemoteReadStateDidSent];
        [mesg setExtendInformation:extendInfo];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        [mesg setMsgRaw:msgRaw];
        [mesg setMessageSendState:QIMMessageSendState_Success];
        [self addSessionByType:ChatType_CollectionChat ById:sid ByMsgId:mesg.messageId WithMsgTime:mesg.messageDate WithNeedUpdate:NO];
        
        // 消息落地
        [self saveMsg:mesg ByJid:sid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message": mesg}];
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
        BOOL isExistCollectionMsg = [[IMDataManager qimDB_SharedInstance] qimDB_checkCollectionMsgById:msgId];
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
        BOOL flag = [[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId];
        if (flag) {
            return;
        }
        [self checkMsgTimeWithJid:fromJid WithRealJid:realFrom WithMsgDate:msgDate WithGroup:NO];
        QIMMessageModel *mesg = [QIMMessageModel new];
        [mesg setMessageId:msgId];
        [mesg setFrom:[msgDic objectForKey:@"realfrom"]];
        [mesg setTo:[[QIMManager sharedInstance] getLastJid]];
        [mesg setMessageType:messageType];
        [mesg setMessageDirection:(isCarbon == YES) ? QIMMessageDirection_Sent : QIMMessageDirection_Received];
        [mesg setMessage:msg];
        [mesg setExtendInformation:extendInfo];
        [mesg setMessageDate:msgDate];
        [mesg setMsgRaw:msgRaw];
        [mesg setRealJid:realFrom];
        [mesg setMessageSendState:QIMMessageSendState_Success];
        [mesg setChatType:chatType];
        // 消息落地
        
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

        
        [self saveMsg:mesg ByJid:fromJid];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageUpdate object:sid userInfo:@{@"message":mesg}];
            
            if (![sid isEqualToString:self.currentSessionUserId] && mesg.messageDirection == QIMMessageDirection_Received) {
                [self updateNotReadCountCacheByJid:fromJid];
                if (mesg.messageType == QIMMessageType_RedPack) {
                    [self playHongBaoSound];
                } else {
                    [self playSound];
                }
            }
        });
    });
}

#pragma mark - Receive Msgs接收消息已读未读状态

- (void)onReadState:(NSDictionary *)infoDic {
    QIMVerboseLog(@"onReadState : %@", infoDic);
    dispatch_async(self.receive_msgReadState_queue, ^{
        if (!self.msgCompensateReadSet) {
            self.msgCompensateReadSet = [[NSMutableSet alloc] initWithCapacity:3];
        }
        NSInteger readType = [[infoDic objectForKey:@"readType"] integerValue];
        NSString *infoStr = [infoDic objectForKey:@"infoStr"];
        NSString *jid = [infoDic objectForKey:@"jid"];
        NSArray *readStateMsgList = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
        NSInteger remoteState = QIMMessageRemoteReadStateNotSent;
        if (readType == QIMMessageReadFlagClearAllUnRead) {
            remoteState = QIMMessageRemoteReadStateDidReaded;
            
            NSDictionary *readMarkTDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
            long long readMarkT = [[readMarkTDic objectForKey:@"T"] longLongValue];
            [[IMDataManager qimDB_SharedInstance] qimDB_updateAllMsgWithMsgRemoteState:remoteState ByMsgDirection:QIMMessageDirection_Received ByReadMarkT:readMarkT / 1000];
            [[IMDataManager qimDB_SharedInstance] qimDB_clearAtMessage];
            [self.hasAtAllDic removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                QIMVerboseLog(@"clearAllNoRead: 抛出通知 kMsgNotReadCountChange");
                [[NSNotificationCenter defaultCenter] postNotificationName:kMsgNotReadCountChange object:@{@"ForceRefresh":@(YES)}];
                QIMVerboseLog(@"抛出通知 clearAllNoRead: kAtALLChange");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
            });
        } else if (readType == QIMMessageReadFlagGroupReaded) {
            //群已读
            long long maxMucReadMarkTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff) * 1000;
            QIMVerboseLog(@"收到onReadState之后设置群阅读指针时间戳 : %lld", maxMucReadMarkTime);
            [[IMDataManager qimDB_SharedInstance] qimDB_UpdateUserCacheDataWithKey:kGetGroupReadMarkVersion withType:8 withValue:@"群阅读指针时间戳V2" withValueInt:maxMucReadMarkTime];
            
            remoteState = QIMMessageRemoteReadStateDidReaded | QIMMessageRemoteReadStateGroupReaded;
            [self updateLocalGroupMessageRemoteState:remoteState withXmppId:jid ByReadList:readStateMsgList];
        } else {
            if (readType == QIMMessageReadFlagDidSend) {
                //已送到
                remoteState = QIMMessageRemoteReadStateDidSent;
            } else if (readType == QIMMessageReadFlagDidRead) {
                //已读
                remoteState = QIMMessageRemoteReadStateDidReaded;
            } else if (readType == QIMMessageReadFlagDidControl) {
                //已操作
                remoteState = QIMMessageRemoteReadStateDidOperated | QIMMessageRemoteReadStateDidReaded;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationMessageControlStateUpdate" object:@{@"State":@(QIMMessageRemoteReadStateDidOperated), @"MsgIds":readStateMsgList?readStateMsgList:@[]}];
                });
            } else {
                //已发送
                remoteState = QIMMessageRemoteReadStateNotSent;
            }
            [self updateLocalMessageRemoteState:remoteState withXmppId:jid withRealJid:jid ByMsgIdList:readStateMsgList];
        }
    });
}

#pragma mark - Receive Msgs接收消息发送状态

//更新消息发送状态
- (void)onMessageStateUpdate:(NSDictionary *)msgDic {
    dispatch_async(self.receive_msgSendState_queue, ^{
        QIMVerboseLog(@"更新消息发送状态 : %@", msgDic);
        NSString *msgId = [msgDic objectForKey:@"messageId"];
        BOOL check = [[IMDataManager qimDB_SharedInstance] qimDB_checkMsgId:msgId];
        if (check == YES) {
            BOOL msgSuccess = [[msgDic objectForKey:@"msgSuccess"] boolValue];
            if (msgSuccess) {
                //发送消息成功
                long long receivedTime = [[msgDic objectForKey:@"receivedTime"] longLongValue];
                [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgState:QIMMessageSendState_Success WithMsgId:msgId];
                
                [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgDate:receivedTime WithMsgId:msgId];
                [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgWithMsgRemoteState:QIMMessageRemoteReadStateNotSent ByMsgIdList:@[@{@"id":msgId}]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSendStateUpdate object:@{@"MsgSendState":@(QIMMessageSendState_Success), @"messageId":msgId}];
                });
            } else {
                //发送消息失败
                
                [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgState:QIMMessageSendState_Faild WithMsgId:msgId];
                [[IMDataManager qimDB_SharedInstance] qimDB_updateMsgWithMsgRemoteState:QIMMessageRemoteReadStateNotSent ByMsgIdList:@[@{@"id":msgId}]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSendStateUpdate object:@{@"MsgSendState":@(QIMMessageSendState_Faild), @"messageId":msgId}];
                });
            }
        }
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

+ (void)qim_privateCommonLog:(NSString *)log {
    QIMVerboseLog(@"qim_privateCommonLog ：%@", log);
}

- (void)connectTimeOut{
    [self socketDisconnect];
}

- (void)socketDisconnect{
    if (self.needTryRelogin == YES) {
        QIMErrorLog(@"Socket已经断开通知");
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
        
        [self checkNetworkStatus];
        [self onDisconnect];
    }
    
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
            [[QIMNavConfigManager sharedInstance] qimNav_updateNavigationConfigWithCheck:YES withCallBack:^(BOOL success) {
                if (success == NO) {
                    QIMErrorLog(@"获取导航失败，请稍后再试");
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationStreamEnd" object:@"请检查当前网络状态后重试"];
                } else {
                    QIMWarnLog(@"再次重新登录");
                    self.needTryRelogin = YES;
                    [self socketDisconnect];
                }
            }];
        } else {
            QIMWarnLog(@"被踢下线后重新登录");
            [self relogin];
        }
    } else if (errcode >= 200) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationStreamEnd" object:@"你的账号由于某些原因被迫下线"];
        });
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
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteFriendListWithXmppId:xmppId];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendListUpdate object:xmppId userInfo:nil];
    }
}

- (void)pbChatRoomAddMember:(NSDictionary *)infoDic{
    dispatch_async(self.update_group_member_queue, ^{
        NSString *groupId = [infoDic objectForKey:@"groupId"];
        if ([[IMDataManager qimDB_SharedInstance] qimDB_checkGroup:groupId] == NO) {
            [[IMDataManager qimDB_SharedInstance] qimDB_insertGroup:groupId];
            [self updateGroupCardByGroupId:groupId];
            [self addSessionByType:ChatType_GroupChat ById:groupId ByMsgId:nil WithMsgTime:[[NSDate date] qim_timeIntervalSince1970InMilliSecond] WithNeedUpdate:YES];
            //[_joinedGroupSet addObject:groupId];
            // 获取群成员列表
            NSArray *members = [[XmppImManager sharedInstance] getChatRoomMembersForGroupId:groupId];
            if (members.count > 0) {
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertGroupMember:members WithGroupId:groupId];
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
        [memberInfoDic setObject:name forKey:@"name"];
        [memberInfoDic setQIMSafeObject:affiliation forKey:@"affiliation"];
        if (memberJid) {
            [[IMDataManager qimDB_SharedInstance] qimDB_insertGroupMember:memberInfoDic WithGroupId:groupId];
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
        NSMutableDictionary *memberInfoDic = [NSMutableDictionary dictionary];
        [memberInfoDic setObject:memberJid forKey:@"jid"];
        [memberInfoDic setObject:name forKey:@"name"];
        [memberInfoDic setQIMSafeObject:affiliation forKey:@"affiliation"];
        if (memberJid) {
            [[IMDataManager qimDB_SharedInstance] qimDB_insertGroupMember:memberInfoDic WithGroupId:groupId];
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
        if (fromNickName.length > 0) {
            NSDictionary *userInfoDic = [self getUserInfoByGroupName:fromNickName];
            fromNickName = [userInfoDic objectForKey:@"Name"];
        }
        [self removeSessionById:groupId];
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroup:groupId];
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteMessageWithXmppId:groupId];
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
            [[IMDataManager qimDB_SharedInstance] qimDB_bulkUpdateGroupCards:@[groupInfoDic]];
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
    [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroupMemberJid:memberJid WithGroupId:groupId];
    if ([memberJid isEqualToString:[self getLastJid]]) {
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroup:groupId];
        [self removeSessionById:groupId];
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroupMemberWithGroupId:groupId];
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteMessageWithXmppId:groupId];
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

#pragma mark - App Config

- (void)friendValidation:(NSDictionary *)validationDic {
    NSString *from = [validationDic objectForKey:@"from"];
    NSString *body = [validationDic objectForKey:@"body"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *infoDic = [self getUserInfoByUserId:from];
        NSString *userId = [infoDic objectForKey:@"UserId"];
        NSString *xmppId = [infoDic objectForKey:@"XmppId"];
        NSString *name = [infoDic objectForKey:@"Name"];
        NSString *descInfo = [infoDic objectForKey:@"DescInfo"];
        NSString *headerSrc = [infoDic objectForKey:@"HeaderSrc"];
        NSString *searchIndex = [infoDic objectForKey:@"SearchIndex"];
        long long lastUpdateTime = [[NSDate date] timeIntervalSince1970] - self.serverTimeDiff;
        int state = 0;
        [[IMDataManager qimDB_SharedInstance] qimDB_insertFriendNotifyWithUserId:userId
                                                                      WithXmppId:xmppId
                                                                        WithName:name
                                                                    WithDescInfo:descInfo
                                                                     WithHeadSrc:headerSrc
                                                                 WithSearchIndex:searchIndex
                                                                    WithUserInfo:body
                                                                     WithVersion:0
                                                                       WithState:state
                                                              WithLastUpdateTime:lastUpdateTime];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"抛出通知 QIMmanger friendValidation1  kNotificationSessionListUpdate");
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:nil];
        });
    });
}

- (void)friendPresence:(NSDictionary *)presenceDic {
    NSString *from = [presenceDic objectForKey:@"from"];
    NSString *result = [presenceDic objectForKey:@"result"];
    //    NSString *reason = [presenceDic objectForKey:@"reason"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendPresence object:from userInfo:presenceDic];
    if ([result isEqualToString:@"success"]) {
        NSString *destId = from;
        NSDictionary *infoDic = [self getUserInfoByUserId:destId];
        [[IMDataManager qimDB_SharedInstance] qimDB_insertFriendWithUserId:[infoDic objectForKey:@"UserId"]
                                                                WithXmppId:[infoDic objectForKey:@"XmppId"]
                                                                  WithName:[infoDic objectForKey:@"Name"]
                                                           WithSearchIndex:[infoDic objectForKey:@"SearchIndex"]
                                                              WithDescInfo:[infoDic objectForKey:@"DescInfo"]
                                                               WithHeadSrc:[infoDic objectForKey:@"HeaderSrc"]
                                                              WithUserInfo:[infoDic objectForKey:@"UserInfo"]
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
                        [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroup:groupId];
                        [self removeSessionById:groupId];
                        [[IMDataManager qimDB_SharedInstance] qimDB_deleteGroupMemberWithGroupId:groupId];
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
            [[IMDataManager qimDB_SharedInstance] qimDB_bulkinsertGroups:groups];
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

- (void)onTyping:(NSDictionary *)infoDic {
    NSString *jid = [infoDic objectForKey:@"fromId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTyping object:jid];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetworkStatus) object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMErrorLog(@"LoginFaild: %@", errDic);
        if ([[errDic objectForKey:@"errMsg"] isEqualToString:@"out_of_date"]) {
            
            [self clearUserToken];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self updateChatRoomList];
    });

}

@end
