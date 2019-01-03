
//
//  XmppImManager.m
//  qunarChatCommon
//
//  Created by May on 14/11/20.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "XmppImManager.h"
#import "QIMCommonEnum.h"
#import "QIMPBStack.h"
#import "Message.pb.h"
#import "IQMessage+Utility.h"
#import "QIMPublicRedefineHeader.h"

@interface XmppImManager () {
    
    int _protocolType;
    QIMPBStack *_pbXmppStack;
    BOOL _isLogin;
    
    NSMutableDictionary *_eventMapping;
    
    NSString *_userName;
    NSString *_pwd;
}
- (void)safeSaveDic:(NSMutableDictionary *)dic setObject:(id)object ForKey:(id<NSCopying>)key;
@end

@interface XmppImManager (xmppstackdelegate) <QIMPBStackDelegate,PBChatRoomDelegate>

@end

@implementation XmppImManager (xmppstackdelegate)

// Message Log
- (void)messageLog:(NSString *)messageLog WithDirection:(int)direction {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_MessageLog)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"log":messageLog,
                                   @"direction":@(direction)}
                   waitUntilDone:NO];
        }
    }
}

// PB Presence
- (void)pbUserStatusChange:(NSString *)jid
                  WithShow:(NSString *)show
              WithPriority:(NSString *)priority{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_UserStatusChanage)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"jid":jid?jid:@"",
                                   @"show":show?show:@"",
                                   @"priority":priority?priority:@""}
                   waitUntilDone:NO];
        }
    }
}

// PB Chat Room Presence
- (void)pbChatRoom:(NSString *)groupId
        WithAddJid:(NSString *)memberJid
   WithAffiliation:(NSString *)affiliation
        WithDomain:(NSString *)domain
          WithName:(NSString *)name{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_ChatRoomAddMember)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"groupId":groupId?groupId:@"",
                                   @"jid":memberJid?memberJid:@"",
                                   @"affiliation":affiliation?affiliation:@"",
                                   @"domain":domain?domain:@"",
                                   @"name":name?name:@""}
                   waitUntilDone:NO];
        }
    }
}

- (void)pbChatRoom:(NSString *)groupId
    WithInviteUser:(NSString *)jid
        WithStatus:(NSString *)status {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_ChatRoomInviteMember)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"groupId":groupId?groupId:@"",
                                   @"jid":jid?jid:@"",
                                   @"status":status?status:@""}
                   waitUntilDone:NO];
        }
    }
}

- (void)pbChatRoomDestory:(NSString *)groupId{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_ChatRoomDestory)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"groupId":groupId?groupId:@""}
                   waitUntilDone:NO];
        }
    }
}

- (void)pbChatRoom:(NSString *)groupId
  WithDelMemberJid:(NSString *)memberJid
   WithAffiliation:(NSString *)affiliation
          WithRole:(NSString *)role
          WithCode:(NSString *)code{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_ChatRoomDeleteMember)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"groupId":groupId?groupId:@"",
                                   @"jid":memberJid?memberJid:@"",
                                   @"affiliation":affiliation?affiliation:@"",
                                   @"role":role?role:@"",
                                   @"code":code?code:@""}
                   waitUntilDone:NO];
        }
    }
}

- (void)pbChatRommUpdateCard:(NSString *)groupId
                WithNickName:(NSString *)nickName
                   WithTitle:(NSString *)title
                  WithPicUrl:(NSString *)picUrl
                 WithVersion:(NSString *)version{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_ChatRoomCardUpdate)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"groupId":groupId?groupId:@"",
                                   @"nickname":nickName?nickName:@"",
                                   @"title":title?title:@"",
                                   @"pic":picUrl?picUrl:@"",
                                   @"version":version?version:@""}
                   waitUntilDone:NO];
        }
    }
}

- (void)pbChatRomm:(NSString *)groupId
     WithDelRegJid:(NSString *)delJid {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_ChatRoomRegisterDelMember)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:@{@"groupId":groupId?groupId:@"",
                                   @"jid":delJid?delJid:@""}
                   waitUntilDone:NO];
        }
    }
}

- (void)loginFaildWithErrCode:(NSString *)errCode WithErrMsg:(NSString *)errMsg{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_LoginFaild)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:@{@"errCode": errCode, @"errMsg": errMsg} waitUntilDone:NO];
        }
    }
}

- (void)serviceEndStream{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_StreamEnd)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)delFriend:(NSString *)userID {
    if (userID) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_DelFriend)];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                [obj performSelector:sel onThread:[NSThread mainThread] withObject:@{@"jid": userID} waitUntilDone:NO];
            }
        }
    }
}

- (void)registerSuccess {
    QIMVerboseLog(@"registerSuccess");
    _isLogin = YES;
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_RegisterSuccess)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)registerFaild:(NSError *)error {
    _isLogin = NO;
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_RegisterFaild)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)serviceStreamEndWithErrorCode:(NSInteger)errorCode WithReason:(NSString *)reason {
    _isLogin = NO;
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_StreamEnd)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:@{@"ErrorCode":@(errorCode), @"Reason":reason} waitUntilDone:NO];
        }
    }
}

- (void)beginToConnect {
    
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEventConnecting)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)logout {
    QIMVerboseLog(@"抛出通知 : ONXMPPConnecting");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ONXMPPConnecting" object:nil];
}

- (void)onDisconnect {
    _isLogin = NO;
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_Disconnect)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)connectTimeOut {
    _isLogin = NO;
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ConnectTimeOut)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)beenConnected {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEventConnected)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)loginComplate {
    
    if (!_isLogin) {
        _isLogin = YES;
        
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_LoginComplate)];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
            }
        }
    }
}

- (void)verifyFriendPresenceWithFrom:(NSString *)from WithTo:(NSString *)to WihtDirection:(int)direction WithResult:(NSString *)result WithReason:(NSString *)reason {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_Friend_Presence)];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:from ? from : @"" forKey:@"from"];
    [dic setObject:to ? to : @"" forKey:@"to"];
    [dic setObject:@(direction) forKey:@"direction"];
    [dic setObject:result ? result : @"" forKey:@"result"];
    [dic setObject:reason ? reason : @"" forKey:@"reason"];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:dic
                   waitUntilDone:NO];
        }
    }
}

- (void)validationFriendFromUserId:(NSString *)from WithBody:(NSString *)body {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_Friend_Validation)];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:from ? from : @"" forKey:@"from"];
    [dic setObject:body ? body : @"" forKey:@"body"];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:dic
                   waitUntilDone:NO];
        }
    }
}

- (void)configWithRemoteKey:(NSString *)remoteKey WithSystemTime:(long long)systemTime {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_Config_Key_Time)];
    NSDictionary *messageDic = @{@"RemoteKey": remoteKey ? remoteKey : @"",
                                 @"SystemTime": @(systemTime)};
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:messageDic
                   waitUntilDone:NO];
        }
    }
}

- (void)userMucListUpdate:(NSString *)mucListStr WithSuccess:(BOOL)success{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_User_Muc_List)];
    NSDictionary *messageDic = @{@"MucListStr":mucListStr?mucListStr:@"",@"RequestFlag":@(success)};
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:messageDic
                   waitUntilDone:NO];
        }
    }
}

- (void)userMucListUpdate:(NSString *)mucListStr{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_User_Muc_List)];
    NSDictionary *messageDic = @{@"MucListStr": mucListStr ? mucListStr : @""};
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:messageDic
                   waitUntilDone:NO];
        }
    }
}

- (void)onSystemMsgReceived:(NSString *)message
                  messageId:(NSString *)msgId
                      stamp:(NSDate *)date
                     msgRaw:(NSString *)msgRaw {
    
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_SystemMessageIn)];
    NSDictionary *messageDic = @{@"msg": message ? message : @"",
                                 @"stamp": date ? date : [NSDate date],
                                 @"msgId": msgId,
                                 @"msgRaw": msgRaw ? msgRaw : @""
                                 };
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:messageDic
                   waitUntilDone:NO];
        }
    }
}

- (void)onShareLocationMessageReceived:(NSString *)destId
                                domain:(NSString *)domain
                               shareId:(NSString *)shareId
                           messageType:(int)msgType
                          platformType:(int)payformType
                               message:(NSString *)msg
                                 stamp:(NSDate *)date
                            extendInfo:(NSString *)extendInfo {
    //位置共享信息
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ShareLocation)];
    
    NSDictionary *message = @{@"fromId": destId,
                              @"domain": domain,
                              @"msg": msg ? msg : @"",
                              @"stamp": date ? date : [NSDate date],
                              @"shareId": shareId ? shareId : @"",
                              @"payformType": @(payformType),
                              @"msgType": @(msgType),
                              @"extendInfo": extendInfo ? extendInfo : @"",
                              };
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}


- (void)receiveCallAudioVideFromJid:(NSString *)jid
                       WithResource:(NSString *)resource
                        WithMsgType:(int)msgType{
    
    //音视频消息
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_CallVideoAudio)];
    
    NSDictionary *message = @{@"from":jid,
                              @"resource":resource,
                              @"type":@(msgType)};
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)receiveMeetingAudioVideoConferenceFromJid:(NSString *)jid
                                     WithResource:(NSString *)resource
                                      WithMsgType:(int)msgType{
    
    //视频会议消息
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_CallMeetingAudioVideoConference)];
    
    NSDictionary *message = @{@"from":jid,
                              @"resource":resource,
                              @"type":@(msgType)};
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)receiveKeyNotiyPresenceFromCatrgoryType:(SInt32)categoryType WithPresenceBodyValue:(NSString *)bodyValue {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PBPresence_CategoryNotify)];
    NSDictionary *message = @{@"categoryType" : @(categoryType), @"bodyValue":bodyValue?bodyValue:@""};
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelectorOnMainThread:sel withObject:message waitUntilDone:NO];
        }
    }
}

- (void)onMessageReceived:(NSString *)destId
                   domain:(NSString *)domain
              messageType:(int)msgType
             platformType:(int)payformType
                  message:(NSString *)msg
              originalMsg:(NSString *)originalMsg
                messageId:(NSString *)msgId
                direction:(NSUInteger)direction
                    stamp:(NSDate *)date
               extendInfo:(NSString *)extendInfo
                autoReply:(NSString *)autoReply
                   chatId:(NSString *)chatId
                   msgRaw:(NSString *)msgRaw {
    if (destId == nil || domain == nil) {
        return;
    }
    if (msgType == QIMMessageType_Image) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ImageIn)];
        NSDictionary *message = @{@"fromId": destId,
                                  @"domain": domain,
                                  @"msg": msg ? msg : @"",
                                  @"stamp": date ? date : [NSDate date],
                                  @"direction": @(direction),
                                  @"msgId": msgId,
                                  @"payformType": @(payformType),
                                  @"msgType": @(msgType),
                                  @"extendInfo": extendInfo ? extendInfo : @"",
                                  @"chatId": chatId ? chatId : @"",
                                  @"msgRaw": msgRaw ? msgRaw : @""
                                  };
        
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            }
        }
    } else if (msgType == QIMMessageType_Voice) {
        //add by dan.zheng 15/4/28  changed 15/4/30 changed 15/4/30 增加@"msgtype"  : @"msgVoice"字段来分辨是否voice格式
        //        NSXMLElement *body = (NSXMLElement *) originalMsg;
        NSDictionary *message = @{@"fromId": destId,
                                  @"domain": domain,
                                  @"msg": msg ? msg : @"",
                                  @"stamp": date ? date : [NSDate date],
                                  @"direction": @(direction),
                                  @"msgId": msgId,
                                  @"msgtype": @"msgVoice",
                                  @"payformType": @(payformType),
                                  @"msgType": @(msgType),
                                  @"extendInfo": extendInfo ? extendInfo : @"",
                                  @"chatId": chatId ? chatId : @"",
                                  @"msgRaw": msgRaw ? msgRaw : @""
                                  };
        
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_MessageIn)];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            }
        }
    } else if (msgType == QIMMessageType_File) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_FileIn)];
        
        if (msg != nil) {
            
            NSDictionary *message = @{@"fromId": destId,
                                      @"domain": domain,
                                      @"msg": msg ? msg : @"",
                                      @"stamp": date ? date : [NSDate date],
                                      @"direction": @(direction),
                                      @"msgId": msgId,
                                      @"payformType": @(payformType),
                                      @"msgType": @(msgType),
                                      @"extendInfo": extendInfo ? extendInfo : @"",
                                      @"chatId": chatId ? chatId : @"",
                                      @"msgRaw": msgRaw ? msgRaw : @""
                                      };
            
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
    } else if (msgType == QIMMessageType_Shock) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ShockIn)];
        
        if (msg != nil) {
            
            NSDictionary *message = @{@"fromId": destId,
                                      @"domain": domain,
                                      @"msg": msg ? msg : @"",
                                      @"stamp": date ? date : [NSDate date],
                                      @"direction": @(direction),
                                      @"msgId": msgId,
                                      @"payformType": @(payformType),
                                      @"msgType": @(msgType),
                                      @"extendInfo": extendInfo ? extendInfo : @"",
                                      @"chatId": chatId ? chatId : @"",
                                      @"msgRaw": msgRaw ? msgRaw : @""
                                      };
            
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
    } else {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_MessageIn)];
        
        NSDictionary *message = @{@"fromId": destId,
                                  @"domain": domain,
                                  @"msg": msg ? msg : @"",
                                  @"stamp": date ? date : [NSDate date],
                                  @"direction": @(direction),
                                  @"msgId": msgId,
                                  @"payformType": @(payformType),
                                  @"msgType": @(msgType),
                                  @"extendInfo": extendInfo ? extendInfo : @"",
                                  @"autoReply": autoReply ? autoReply : @"false",
                                  @"chatId": chatId ? chatId : @"",
                                  @"msgRaw": msgRaw ? msgRaw : @""
                                  };
        
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            }
        }
    }
    
}

- (void)onGroupMessageReceived:(NSString *)destId
                        domain:(NSString *)domain
                       sendJid:(NSString *)nickName
                   messageType:(int)msgType
                  platformType:(int)payformType
                       message:(NSString *)msg
                   originalMsg:(NSString *)originalMsg
                     messageId:(NSString *)msgId
                         stamp:(NSDate *)date
                    extendInfo:(NSString *)extendInfo
                    replyMsgId:(NSString *)replyMsgId
                     replyUser:(NSString *)replyUser
                        chatId:(NSString *)chatId
                    backupInfo:(NSString *)backupInfo
                        msgRaw:(NSString *)msgRaw {
    if (msgType == 3) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_GroupImageIn)];
        
        if (msg != nil) {
            
            NSDictionary *message = @{@"fromId": destId,
                                      @"domain": domain,
                                      @"nickName": nickName,
                                      @"msg": msg,
                                      @"stamp": date,
                                      @"msgId": msgId,
                                      @"payformType": @(payformType),
                                      @"msgType": @(msgType),
                                      @"extendInfo": extendInfo ? extendInfo : @"",
                                      @"chatId": chatId ? chatId : @"",
                                      @"backupInfo": backupInfo ? backupInfo : @"",
                                      @"msgRaw": msgRaw ? msgRaw : @""
                                      };
            
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
    } else if (msgType == QIMMessageType_Shock) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_GroupShockIn)];
        
        if (msg != nil) {
            
            NSDictionary *message = @{@"fromId": destId,
                                      @"domain": domain,
                                      @"nickName": nickName,
                                      @"msg": msg,
                                      @"stamp": date,
                                      @"msgId": msgId,
                                      @"payformType": @(payformType),
                                      @"msgType": @(msgType),
                                      @"extendInfo": extendInfo ? extendInfo : @"",
                                      @"chatId": chatId ? chatId : @"",
                                      @"backupInfo": backupInfo ? backupInfo : @"",
                                      @"msgRaw": msgRaw ? msgRaw : @""
                                      };
            
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
        
    } else if (msgType == QIMMessageType_Voice) {
        //add by dan.zheng 15/4/28
        //        NSXMLElement *body = (NSXMLElement *) originalMsg;
#pragma mark - 语音消息
        NSDictionary *message = @{@"fromId": destId,
                                  @"domain": domain,
                                  @"nickName": nickName,
                                  @"msg": msg ? msg : @"",
                                  @"stamp": date ? date : [NSDate date],
                                  @"msgId": msgId,
                                  @"msgtype": @"msgVoice",
                                  @"payformType": @(payformType),
                                  @"msgType": @(msgType),
                                  @"extendInfo": extendInfo ? extendInfo : @"",
                                  @"chatId": chatId ? chatId : @"",
                                  @"backupInfo": backupInfo ? backupInfo : @"",
                                  @"msgRaw": msgRaw ? msgRaw : @""
                                  };
        
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppeventGroupMessageIn)];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            }
        }
    } else if (msgType == QIMMessageType_File) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_GroupFileIn)];
        
        if (msg != nil) {
            
            NSDictionary *message = @{@"fromId": destId,
                                      @"domain": domain,
                                      @"nickName": nickName,
                                      @"msg": msg,
                                      @"stamp": date,
                                      @"msgId": msgId,
                                      @"payformType": @(payformType),
                                      @"msgType": @(msgType),
                                      @"extendInfo": extendInfo ? extendInfo : @"",
                                      @"chatId": chatId ? chatId : @"",
                                      @"backupInfo": backupInfo ? backupInfo : @"",
                                      @"msgRaw": msgRaw ? msgRaw : @""
                                      };
            
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
    } else if (msgType == QIMMessageTypeWebRtcMsgTypeVideoMeeting) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_CallMeetingAudioVideoConference)];
        if (msg != nil) {
            NSDictionary *message = @{@"fromId": destId,
                                      @"domain": domain,
                                      @"nickName": nickName,
                                      @"msg": msg,
                                      @"stamp": date,
                                      @"msgId": msgId,
                                      @"payformType": @(payformType),
                                      @"msgType": @(msgType),
                                      @"extendInfo": extendInfo ? extendInfo : @"",
                                      @"chatId": chatId ? chatId : @"",
                                      @"backupInfo": backupInfo ? backupInfo : @"",
                                      @"msgRaw": msgRaw ? msgRaw : @""
                                      };
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
    } else {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppeventGroupMessageIn)];
        
        if (msg != nil) {
            NSMutableDictionary *message = [NSMutableDictionary dictionary];
            [self safeSaveDic:message setObject:destId ForKey:@"fromId"];
            [self safeSaveDic:message setObject:domain ForKey:@"domain"];
            [self safeSaveDic:message setObject:nickName ForKey:@"nickName"];
            [self safeSaveDic:message setObject:msg ForKey:@"msg"];
            [self safeSaveDic:message setObject:date ForKey:@"stamp"];
            [self safeSaveDic:message setObject:msgId ForKey:@"msgId"];
            [self safeSaveDic:message setObject:@(payformType) ForKey:@"payformType"];
            [self safeSaveDic:message setObject:@(msgType) ForKey:@"msgType"];
            [self safeSaveDic:message setObject:extendInfo ForKey:@"extendInfo"];
            [self safeSaveDic:message setObject:replyMsgId ForKey:@"replyMsgId"];
            [self safeSaveDic:message setObject:replyUser ForKey:@"replyUser"];
            [self safeSaveDic:message setObject:chatId ForKey:@"chatId"];
            [self safeSaveDic:message setObject:backupInfo ForKey:@"backupInfo"];
            [self safeSaveDic:message setObject:msgRaw ForKey:@"msgRaw"];
            
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    
                    [obj performSelector:sel
                                onThread:[NSThread mainThread]
                              withObject:message
                           waitUntilDone:NO];
                }
            }
        }
    }
    
}

- (void) onConsultMessageReceivedWithFromJid:(NSString *)fromJid
                                    realFrom:(NSString *)readFromJid
                                       toJid:(NSString *)toJid
                                   realToJid:(NSString *)realToJid
                                    isCarbon:(BOOL)isCarbon
                                 messageType:(int)msgType
                                platformType:(int)payformType
                                     message:(NSString *)msg
                                   messageId:(NSString *)msgId
                                       stamp:(NSDate *)date
                                  extendInfo:(NSString *)extendInfo
                                      chatId:(NSString *)chatId
                                      msgRaw:(NSString *)msgRaw {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ReceiveConsultMessage)];
    
    if (msg != nil) {
        NSMutableDictionary *message = [NSMutableDictionary dictionary];
        [self safeSaveDic:message setObject:fromJid ForKey:@"fromId"];
        [self safeSaveDic:message setObject:readFromJid ForKey:@"realfrom"];
        [self safeSaveDic:message setObject:toJid ForKey:@"toId"];
        [self safeSaveDic:message setObject:realToJid ForKey:@"realto"];
        [self safeSaveDic:message setObject:msg ForKey:@"msg"];
        [self safeSaveDic:message setObject:date ForKey:@"stamp"];
        [self safeSaveDic:message setObject:msgId ForKey:@"msgId"];
        [self safeSaveDic:message setObject:@(payformType) ForKey:@"payformType"];
        [self safeSaveDic:message setObject:@(msgType) ForKey:@"msgType"];
        [self safeSaveDic:message setObject:@(isCarbon) ForKey:@"isCarbon"];
        [self safeSaveDic:message setObject:extendInfo ForKey:@"extendInfo"];
        [self safeSaveDic:message setObject:chatId ForKey:@"chatId"];
        [self safeSaveDic:message setObject:msgRaw ForKey:@"msgRaw"];
        
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            }
        }
    }
}

- (void)userResource:(NSString *)resource forJid:(NSString *)jid{
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_UserResource)];
    if (resource && jid) {
        NSDictionary *message = @{@"jid"     : jid,
                                  @"resource"     : resource
                                  };
        
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:message
                       waitUntilDone:NO];
            }
        }
    }
}

//QChat 通话开始
- (void)onQChatNoteReceived:(NSString *)infoStr from:(NSString *)jid stamp:(NSDate *)stamp {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_QChatNote)];
    
    NSDictionary *message = @{@"fromId": jid, @"infoStr": infoStr, @"stamp": stamp};
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

//QChat 通话结束
- (void)onQChatEndReceivedFrom:(NSString *)jid stamp:(NSDate *)stamp {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_QChatEnd)];
    
    NSDictionary *message = @{@"fromId": jid, @"stamp": stamp};
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)onReadStateReceivedForJid:(NSString *)jid ForRealJid:(NSString *)realJid infoStr:(NSString *)infoStr{
    NSDictionary *message = @{@"realjid": realJid, @"jid": jid ? jid : @"", @"infoStr": infoStr};
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ConsultReadState)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)onReadStateReceived:(NSString *)readType
                     ForJid:(NSString *)jid
                    infoStr:(NSString *)infoStr {
    NSDictionary *message = @{@"readType": readType, @"jid": jid ? jid : @"", @"infoStr": infoStr};
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ReadState)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)onTypingReceived:(NSString *)destId {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_Typing)];
    
    NSDictionary *message = @{@"fromId": destId};
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)onRevokeReceived:(NSString *)destId
               messageId:(NSString *)messageId
                 message:(NSString *)message {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_Revoke)];
    if (message && destId) {
        NSDictionary *messageDic = @{@"fromId": destId, @"messageId": messageId, @"message": message ? message : @""};
        
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:messageDic
                       waitUntilDone:NO];
            }
        }
    }
}

- (void)onReceivePublicNumberMsg:(NSDictionary *)msgDic {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_PublicNumberMsg)];
    if (msgDic) {
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:msgDic
                       waitUntilDone:NO];
            }
        }
    }
}

- (void)onReceiveCollectionMsg:(NSString *) destId
                        domain:(NSString *) domain
                      realfrom:(NSString *)realfrom
                      nickName:(NSString *)nickName
                   messageType:(int) msgType
                  platformType:(int) payformType
                       message:(NSString *) message
                   originalMsg:(NSString *) orininalMsg
                     messageId:(NSString *) msgId
                     direction:(NSUInteger) direction
                         stamp:(NSDate *)date
                    extendInfo:(NSString *)extendInfo
                        chatId:(NSString *)chatId
                        msgRaw:(NSString *)msgRaw {
    if (!destId || !domain) {
        return;
    }
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_CollectionMessageIn)];
    NSDictionary *msg = @{@"fromId": destId,
                          @"domain": domain,
                          @"realfrom":realfrom,
                          @"nickName": nickName?nickName:@"",
                          @"msg": message ? message : @"",
                          @"stamp": date ? date : [NSDate date],
                          @"direction": @(direction),
                          @"msgId": msgId,
                          @"payformType": @(payformType),
                          @"msgType": @(msgType),
                          @"extendInfo": extendInfo ? extendInfo : @"",
                          @"chatId": chatId ? chatId : @"",
                          @"msgRaw": msgRaw ? msgRaw : @""
                          };
    for (NSDictionary * info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelectorOnMainThread:sel withObject:msg waitUntilDone:NO];
        }
    }
}

- (void)onReceiveCollectionMsg:(NSDictionary *)msgDic {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_CollectionMessageIn)];
    if (msgDic) {
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                [obj performSelectorOnMainThread:sel withObject:msgDic waitUntilDone:NO];
            }
        }
    }
}

- (void)onReceiveCollectionMsg:(NSString *)msgId
                WithOriginFrom:(NSString *)originFrom
                  WithOriginTo:(NSString *)originTo
                WithOriginType:(NSString *)originType {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_CollectionOriginMessageIn)];
    if (msgId && originFrom && originTo && originType) {
        NSDictionary *message = @{@"MsgId":msgId, @"Originfrom":originFrom, @"Originto":originTo, @"Origintype":originType};
        if (message) {
            for (NSDictionary *info in methods) {
                if (info) {
                    id obj = [info objectForKey:@"object"];
                    NSString *method = [info objectForKey:@"method"];
                    SEL sel = NSSelectorFromString(method);
                    [obj performSelectorOnMainThread:sel withObject:message waitUntilDone:NO];
                }
            }
        }
    }
}

- (void)onMessageReceived:(NSString *)destId
               withDomain:(NSString *)destDomain
          withMessageType:(int)msgType
         withPlatformType:(int)platformType
               andMessage:(NSString *)msg
             andMessageId:(NSString *)msgId {
    
    
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_MessageIn)];
    
    NSDictionary *message = @{@"fromId": destId,
                              @"domain": destDomain,
                              @"msg": msg
                              };
    
    
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
    
    
}

- (void)onUserPresenceChange:(NSString *)jid {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_UserStatusChange)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:jid
                   waitUntilDone:NO];
        }
    }
}

- (void)receTransferChatWithFrom:(NSString *)from WithMsgId:(NSString *)msgId {
    if (msgId && from) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ReceiveTransferChat)];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:msgId forKey:@"MsgId"];
        [infoDic setObject:from forKey:@"From"];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:infoDic
                       waitUntilDone:NO];
            }
        }
    }
}

- (void)onTransferChatWithFrom:(NSString *)from
                   WithMsgType:(int)msgType
                    WithChatId:(NSString *)chatId
                     WithMsgId:(NSString *)msgId
                      WithJson:(NSString *)json {
    if (from && json) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_TransferChat)];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:@(msgType) forKey:@"MsgType"];
        if (chatId) {
            [infoDic setObject:chatId forKey:@"ChatId"];
        }
        if (msgId) {
            [infoDic setObject:msgId forKey:@"MsgId"];
        }
        [infoDic setObject:json forKey:@"Json"];
        [infoDic setObject:from forKey:@"From"];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:infoDic
                       waitUntilDone:NO];
            }
        }
    }
}

- (void)onReceiveErrorMsgWithFrom:(NSString *)from WithMsgId:(NSString *)msgId WithErrorCode:(NSString *)errcode {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_MessageError)];
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    if (from.length > 0) {
        [infoDic setObject:from forKey:@"From"];
    }
    if (msgId.length > 0) {
        [infoDic setObject:msgId forKey:@"MsgId"];
    }
    if (errcode.length > 0) {
        [infoDic setObject:errcode forKey:@"ErrorCode"];
    }
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            [obj performSelectorOnMainThread:sel withObject:infoDic waitUntilDone:NO];
        }
    }
}

- (void)receiveEncryptMessageWithFrom:(NSString *)from WithMsgType:(int)msgType WithContent:(NSString *)content WithCarbon:(BOOL)carbon {
    if (from && content) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_ReceiveEncryptMessage)];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                [obj performSelector:sel onThread:[NSThread mainThread] withObject:@{@"from": from, @"type" : @(msgType), @"content":content, @"carbon": @(carbon)} waitUntilDone:NO];
            }
        }
    }
}

- (void)updateChannelInfo:(NSString *)channelInfo ForUserId:(NSString *)userId {
    if (channelInfo && userId) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_UpdateChannelInfo)];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:userId forKey:@"userId"];
        [infoDic setObject:channelInfo forKey:@"channelid"];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:infoDic
                       waitUntilDone:NO];
            }
        }
    }
}

- (void)updateAppendInfo:(NSString *)appendInfo WithAppendKey:(NSString *)appendKey ForUserId:(NSString *)userId  {
    if (appendInfo && appendKey && userId) {
        NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_UpdateAppendInfo)];
        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
        [infoDic setObject:userId forKey:@"userId"];
        [infoDic setObject:appendInfo forKey:appendKey];
        for (NSDictionary *info in methods) {
            if (info) {
                id obj = [info objectForKey:@"object"];
                NSString *method = [info objectForKey:@"method"];
                SEL sel = NSSelectorFromString(method);
                [obj performSelector:sel
                            onThread:[NSThread mainThread]
                          withObject:infoDic
                       waitUntilDone:NO];
            }
        }
    }
}

@end

#pragma mark - XmppImManager

@implementation XmppImManager

- (void)safeSaveDic:(NSMutableDictionary *)dic setObject:(id)object ForKey:(id<NSCopying>)key{
    if (key && object) {
        [dic setObject:object forKey:key];
    }
}

- (void) disconnect {
    if (_isLogin == NO) {
        [self logout];
    }
    _isLogin = NO;
    [_pbXmppStack goOffLine];
}

- (void)logout {

    _isLogin = NO;
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_LoginFaild)];
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel onThread:[NSThread mainThread] withObject:@{@"errCode": @"", @"errMsg": @"网络断开,登录失败。"} waitUntilDone:NO];
        }
    }
}

- (void)setProductType:(int)productType {
    [_pbXmppStack setProductType:productType];
}

- (void)setLoginType:(int)LoginType {
    _loginType = LoginType;
    [_pbXmppStack setLoginType:LoginType];
}

- (NSString *)resource{
    return [_pbXmppStack resource];
}

- (id)xmppStack{
    return _pbXmppStack;
}
- (dispatch_queue_t)getXmppQueue{
    return [_pbXmppStack getXmppQueue];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isLogin = NO;
        _eventMapping = [[NSMutableDictionary alloc] initWithCapacity:10];
        
    }
    return self;
}

- (BOOL)loginState {
    return _isLogin;
}

+ (int)ClientProtocolType{
    return ProtocolType_Protobuf;
}

- (void)setProtocolType:(int)protocolType{
    
    _protocolType = protocolType;
    if (!_pbXmppStack) {
        _pbXmppStack = [[QIMPBStack alloc] init];
    }
}

static XmppImManager *_xmppImManager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _xmppImManager = [[XmppImManager alloc] init];
    });
    return _xmppImManager;
}

- (NSString *)getRemoteLoginKey{
#warning 补充
    return [_pbXmppStack getRemoteLoginKey];
}

- (void)relogin {
    _isLogin = NO;
    if (_userName && _pwd) {
        [self loginwithName:_userName password:_pwd];
    }
}

- (void)resetIP:(NSString *)ip port:(int)port domain:(NSString *)domain {
    _domain = domain;
    _hostName = ip;
    [self setPort:port];
}

- (void) loginwithName:(NSString *) userName password:(NSString *) pwd{
    QIMVerboseLog(@"XMPPIMManager Login updateOfflineTime Start");
    [self updateOfflineTime];
    QIMVerboseLog(@"XMPPIMManager Login updateOfflineTime Done");

    QIMVerboseLog(@"XMPPIMManager Login : <HostName : %@, Domain : %@, Port : %d, appVersion : %@, systemVersion : %@, deviceUUID : %@, loginType : %d, UserId : %@, pwd : %@>", [self hostName], [self domain], [self port], [self appVersion], [self systemVersion], [self deviceUUID], [self loginType], userName, pwd);
    [_pbXmppStack setHostName:[self hostName]];
    [_pbXmppStack setDomain:[self domain]];
    [_pbXmppStack setPort:[self port]];
    [_pbXmppStack setAppVersion:self.appVersion];
    [_pbXmppStack setSystemVersion:self.systemVersion];
    [_pbXmppStack setPlatform:self.platform];
    [_pbXmppStack setDeviceName:self.deviceName];
    [_pbXmppStack setIsFromMac:self.isFromMac];
    [_pbXmppStack setDeviceUUID:self.deviceUUID];
    [_pbXmppStack setLoginType:[self loginType]];
    [_pbXmppStack setDelegate:self];
    [_pbXmppStack setChatRoomDelegate:self];
    [_pbXmppStack setUserId:userName];
    [_pbXmppStack setPassword:pwd];
    if (userName!=nil && pwd!=nil) {
        _userName  = userName;
        _pwd       = pwd;
    }
    NSError *error = nil;
    [_pbXmppStack connectWithTimeout:10 withError:&error];
}

- (void)updateOfflineTime {
    NSMutableArray *methods = [_eventMapping objectForKey:@(XmppEvent_UpdateOfflineTime)];
    NSString *message = @"我是登录之前来取时间戳的，nnd";
    for (NSDictionary *info in methods) {
        if (info) {
            id obj = [info objectForKey:@"object"];
            NSString *method = [info objectForKey:@"method"];
            SEL sel = NSSelectorFromString(method);
            
            [obj performSelector:sel
                        onThread:[NSThread mainThread]
                      withObject:message
                   waitUntilDone:NO];
        }
    }
}

- (void)cancelLogin{
    [_pbXmppStack cancelLogin];
}

- (void)sendHeartBeat {
    [_pbXmppStack sendHeartBeat];
}

- (void)addTarget:(id)object method:(SEL)method withXmppEvent:(enum XmppEvent)event {
    NSMutableArray *methods = [_eventMapping objectForKey:@(event)];
    
    if (methods == nil) {
        methods = [[NSMutableArray alloc] initWithCapacity:100];
    }
    NSString *sel = [NSString stringWithUTF8String:sel_getName(method)];
    [methods addObject:@{@"object": object,
                         @"method": sel}];
    [_eventMapping setObject:methods forKey:@(event)];
}

- (void)removeTargaet:(id)object {
    
}

- (void)removeEvent:(enum XmppEvent)event atObject:(id)object {
    NSMutableArray *methods = [_eventMapping objectForKey:@(event)];
    
    if (methods != nil) {
        
        NSDictionary *removedItem = nil;
        
        for (NSDictionary *info in methods) {
            id obj = [info objectForKey:@"object"];
            if (obj == object) {
                removedItem = info;
                break;
            }
        }
        [methods removeObject:removedItem];
        
        [_eventMapping setObject:methods forKey:@(event)];
    }
}

#pragma mark - friend
- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)xmppId{
    return [_pbXmppStack getVerifyFreindModeWithXmppId:xmppId];
}
- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer{
    return [_pbXmppStack setVerifyFreindMode:mode WithQuestion:question WithAnswer:answer];
}

- (NSString *)getFriendsJson{
    return [_pbXmppStack getFriendsJson];
}

- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer{
    return [_pbXmppStack addFriendPresenceWithXmppId:xmppId WithAnswer:answer];
}
- (void)validationFriendWihtXmppId:(NSString *)xmppId WithReason:(NSString *)reason{
    return [_pbXmppStack validationFriendWihtXmppId:xmppId WithReason:reason];
}
- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId{
    return [_pbXmppStack agreeFriendRequestWithXmppId:xmppId];
}
- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId{
    return [_pbXmppStack refusedFriendRequestWithXmppId:xmppId];
}

//1.删除好友,客户端请求，其中mode1为单项删除，mode为2为双项删除
- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode{
    return [_pbXmppStack deleteFriendWithXmppId:xmppId WithMode:mode];
}
- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId{
    return [_pbXmppStack getReceiveMsgLimitWithXmppId:xmppId];
}

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw {
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([msgRaw isKindOfClass:[NSData class]]) {
        //PB消息
        ProtoMessage *pMessage = [ProtoMessage parseFromData:msgRaw];
        NSString *pMessageStr = [pMessage description];
        
        XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
        NSString *xmppMessageStr = [xmppMessage description];
        [msgDic setObject:pMessageStr ? [pMessageStr stringByAppendingString:@"～～～～～～～～～～～"] : @"～～～～～～～～～～～" forKey:@"ProtoMessage"];
        [msgDic setObject:xmppMessageStr ? [xmppMessageStr stringByAppendingString:@"～～～～～～～～～～～"] : @"～～～～～～～～～～～" forKey:@"XmppMessage"];
    } else if ([msgRaw isKindOfClass:[NSString class]]) {
        
        //
        NSDictionary *msgRawDict = nil;
        NSData *data = [msgRaw dataUsingEncoding:NSUTF8StringEncoding];
        msgRawDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (msgRawDict.count) {
            BOOL localConvert = [[msgRawDict objectForKey:@"localConvert"] boolValue];
            if (localConvert) {
                [msgDic setDictionary:msgRawDict];
            } else {
                //JSON消息
                msgDic = [NSMutableDictionary dictionaryWithDictionary:msgRawDict];
            }
        } else {
            QIMVerboseLog(@"老版本XML消息");
            msgDic = @{@"Msg":msgRaw};
        }
    }
    
    return msgDic;
}

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw {
    NSMutableDictionary *msgDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([msgRaw isKindOfClass:[NSData class]]) {
        //PB
        ProtoMessage *pMessage = [ProtoMessage parseFromData:msgRaw];
        NSString *pMessageStr = [pMessage description];
        
        XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
#warning 这里应该注意取出所有的扩展字段
        NSString *xmppMessageStr = [xmppMessage description];
        QIMVerboseLog(@"xmppMessageStr : %@", xmppMessageStr);
        
        NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
        NSString *msg = [xmppMessage.body value];
        [msgDic setObject:keyValues.count?keyValues:@{} forKey:@"MessageHeaders"];
        [msgDic setObject:msg?msg:@"" forKey:@"content"];
    } else if ([msgRaw isKindOfClass:[NSString class]]) {
        NSDictionary *msgRawDict = nil;
        NSData *data = [msgRaw dataUsingEncoding:NSUTF8StringEncoding];
        msgRawDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (msgRawDict.count) {
            BOOL localConvert = [[msgRawDict objectForKey:@"localConvert"] boolValue];
            if (localConvert) {
                [msgDic setDictionary:msgRawDict];
            } else {
                //JSON消息
                [msgDic setObject:@(YES) forKey:@"isJSONMessage"];
                [msgDic setObject:msgRawDict forKey:@"JSONMessage"];
            }
        } else {
            QIMVerboseLog(@"老版本XML消息");
        }
    }
    return msgDic;
}

- (BOOL)setReceiveMsgLimitWithMode:(int)mode{
    return [_pbXmppStack setReceiveMsgLimitWithMode:mode];
}

/*
- (NSArray *)getVirtualList{
    return [_pbXmppStack getVirtualList];
}
*/

//- (NSString *)getRealJidForVirtual:(NSString *)virtualJid{
//    return [_pbXmppStack getRealJidForVirtual:virtualJid];
//}

#pragma mark - 好友列表

- (NSMutableArray *)chatSessionList {
    return nil;
}

- (NSMutableDictionary *)rosterList{
    return nil;
}

#pragma mark - group[

- (void)quickJoinAllGroup {
    NSArray *groupList = [_pbXmppStack getChatRoomList];
    NSMutableString *listStr = [NSMutableString string];
    for (NSString *groupId in groupList) {
        if ([groupId isEqual:groupList.lastObject]) {
            [listStr appendString:groupId];
        } else {
            [listStr appendFormat:@"%@,",groupId];
        }
    }
    [self userMucListUpdate:listStr];
}

// 获取群成员
- (NSArray *)getChatRoomMembersForGroupId:(NSString *)groupId{
    return [_pbXmppStack getChatRoomMembersForGroupId:groupId];
}

- (NSArray *)inviteGroupMembers:(NSArray *)members ToGroupId:(NSString *)groupId{
    return [_pbXmppStack inviteGroupMembers:members ToGroupId:groupId];
}

- (BOOL)createPBRoom:(NSString *)roomName{
    return [_pbXmppStack createRoom:roomName];
}

- (NSDictionary *) groupMembersByGroupId:(NSString *) groupId {
    NSArray *array = [_pbXmppStack getChatRoomMembersForGroupId:groupId];
    NSMutableDictionary *members = nil;
    if (array.count > 0) {
        members = [NSMutableDictionary dictionary];
        for (NSDictionary *memberInfo in array) {
            if (memberInfo.count) {
                NSString *nickName = [memberInfo objectForKey:@"name"];
                if (nickName) {
                    NSString *groupMemberId = [NSString stringWithFormat:@"%@/%@",groupId,nickName];
                    [members setObject:memberInfo forKey:groupMemberId];
                }
            }
        }
    }
    return members;
}

- (BOOL)pbCreateChatRomm:(NSString *)roomName{
    return [_pbXmppStack createRoom:roomName];
}

- (BOOL)registerJoinGroup:(NSString *)groupId{
    return [_pbXmppStack registerJoinGroup:groupId];
}

- (BOOL)quitGroupDelRegister:(NSString *)groupId{
    return [_pbXmppStack quitGroupDelRegister:groupId];
}

- (BOOL)setGroupId:(NSString *)groupId WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid{
    return [_pbXmppStack setGroupId:groupId WithAdminNickName:nickName ForJid:memberJid];
}

- (BOOL)setGroupId:(NSString *)groupId WithMemberNickName:(NSString *)nickName ForJid:(NSString *)memberJid{
    return [_pbXmppStack setGroupId:groupId WithMemberNickName:nickName ForJid:memberJid];
}

- (BOOL)removeGroupId:(NSString *)groupId ForMemberJid:(NSString *)memberJid WithNickName:(NSString *)nickName{
    return [_pbXmppStack removeGroupId:groupId ForMemberJid:memberJid WithNickName:nickName];
}

- (BOOL)destoryChatRoom:(NSString *)groupId{
    return [_pbXmppStack destoryChatRoom:groupId];
}

- (void)chatTransferTo:(NSString *)user message:(NSString *)message chatId:(NSString *)chatId
{
    [_pbXmppStack chatTransferTo:user message:message chatId:chatId];
}

- (void)chatTransferFrom:(NSString *)from To:(NSString *)to User:(NSString *)user Reson:(NSString *)reson chatId:(NSString *)chatId WithMsgId:(NSString *)msgId{
    [_pbXmppStack chatTransferFrom:from To:to User:user Reson:reson chatId:chatId WithMsgId:msgId];
}

- (void)receiveChatTransferToUser:(NSString *)user ForMsgId:(NSString *)msgId{
    [_pbXmppStack receiveChatTransferToUser:user ForMsgId:msgId];
}

- (void)sendTypingToUserId:(NSString *)userId{
    [_pbXmppStack sendTypingToUserId:userId];
}

- (BOOL)sendAutoReplyWithMessage:(NSString *)message toJid:(NSString *)jid WithMsgId:(NSString *)msgId{
    return [_pbXmppStack sendAutoReplyWithMessage:message toJid:jid WithMsgId:msgId];
}

/**
 发送单人消息
 */
- (BOOL)sendChatMessageWithMsgDict:(NSDictionary *)messageDict {
    return [_pbXmppStack sendChatMessageWithMsgDict:messageDict];
}

/**
 发送群组消息
 */
- (BOOL)sendGroupMessageWithMessageDict:(NSDictionary *)messageDict {
    return [_pbXmppStack sendGroupMessageWithMessageDict:messageDict];
}

- (BOOL)sendClearAllMsgStateByReadMarkT:(long long)readMarkT{
    return [_pbXmppStack sendClearAllMsgStateByReadMarkT:readMarkT];
}

- (BOOL)sendControlStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId {
    return [_pbXmppStack sendControlStateWithMessagesIdArray:jsonString WithXmppid:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WihtXmppId:(NSString *)xmppId{
    return [_pbXmppStack sendReadStateWithMessagesIdArray:jsonString WithXmppid:xmppId];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId WithTo:(NSString *)to WithReadFlag:(NSInteger)readFlag {
    return [_pbXmppStack sendReadStateWithMessagesIdArray:jsonString WithXmppid:xmppId WithTo:to WithReadFlag:readFlag];
}

- (BOOL)sendReadStateWithMessageTime:(long long) time groupName:(NSString *)groupName WithDomain:(NSString *)domain{
    return [_pbXmppStack sendReadStateWithMessageTime:time groupName:groupName WithDomain:domain];
}

- (void)sendNotifyPresenceMsg:(NSDictionary *)msgDict ToJid:(NSString *)toJid {
    [_pbXmppStack sendNotifyPresenceMsg:msgDict ToJid:toJid];
}

- (BOOL)sendShareLocationMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType  WithChatId:(NSString *)chatId{
    return [_pbXmppStack sendShareLocationMessage:message WithInfo:info toJid:jid WithMsgId:msgId WithMsgType:msgType WithChatId:chatId];
}

- (BOOL)sendShareLocationMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType  WithChatId:(NSString *)chatId OutMsgRaw:(NSString **)msgRaw{
    return [_pbXmppStack sendShareLocationMessage:message WithInfo:info toJid:jid WithMsgId:msgId WithMsgType:msgType WithChatId:chatId OutMsgRaw:msgRaw];
}

- (BOOL)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid realFromJid:(NSString *)realFromJid channelInfo:(NSString *)channelInfo WithAppendInfoDict:(NSDictionary *)appendInfoDict chatId:(NSString *)chatId WithMsgTYpe:(int)msgType OutMsgRaw:(NSString **)msgRaw{
    return [_pbXmppStack sendConsultMessageId:msgId WithMessage:message WithInfo:info toJid:toJid realToJid:realToJid realFromJid:realFromJid channelInfo:channelInfo WithAppendInfoDict:appendInfoDict chatId:chatId WithMsgTYpe:msgType OutMsgRaw:msgRaw];
}

#pragma mark - 发送公众号消息

- (BOOL)sendPublicNumberMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType{
    return [_pbXmppStack sendPublicNumberMessage:message WithInfo:info toJid:jid WithMsgId:msgId WithMsgType:msgType];
}

#pragma mark - Share Location

- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType{
    return [_pbXmppStack joinShareLocationToUsers:users WithShareLocationId:shareLocationId WithMsgType:msgType];
}
- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType{
    return [_pbXmppStack sendMyLocationToUsers:users WithLocationInfo:locationInfo ByShareLocationId:shareLocationId WithMsgType:msgType];
}
- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType{
    return [_pbXmppStack quitShareLocationToUsers:users WithShareLocationId:shareLocationId WithMsgType:msgType];
}

- (BOOL)revokeMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid{
    return [_pbXmppStack revokeMessageId:msgId WithMessage:message ToJid:jid];
}

- (BOOL)revokeGroupMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid{
    return [_pbXmppStack revokeGroupMessageId:msgId WithMessage:message ToJid:jid];
}

- (BOOL)sendReplyMessageId:(NSString *)replyMsgId WithReplyUser:(NSString *)replyUser WithMessageId:(NSString *)msgId WithMessage:(NSString *)message ToGroupId:(NSString *)groupId{
    return [_pbXmppStack sendReplyMessageId:replyMsgId WithReplyUser:replyUser WithMessageId:msgId WithMessage:message ToGroupId:groupId];
}

#pragma mark - change status

- (void)goAway{
    [_pbXmppStack goAway];
}

- (void)goDnd{
    [_pbXmppStack goDnd];
}

- (void)goXa{
    [_pbXmppStack goXa];
}

- (void)goChat{
    [_pbXmppStack goChat];
}

- (void)deactiveReconnect {
    [_pbXmppStack deactiveReconnect];
}

- (void)activeReconnect {
    [_pbXmppStack activeReconnect];
}


#pragma marks  - quit login
- (void)quitLogin{
    _userName = nil;
    _pwd = nil;
    [_pbXmppStack logout];
}

- (BOOL)forgelogin {
    NSError *error = nil;
    
    BOOL bValue = NO;
    
    if (_userName!=nil && _pwd!=nil) {
        [_pbXmppStack setUserId:_userName];
        [_pbXmppStack setPassword:_pwd];
        bValue  =  [_pbXmppStack connectWithTimeout:15 withError:&error];
    }
    return bValue;
}

- (void)clearThePwdUserName:(NSNotification *)notification{
    _pwd = nil;
    _userName = nil;
}

#pragma mark - Audio Video

- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid{
    [_pbXmppStack sendAudioVideoWithType:msgType WithBody:body WithExtentInfo:extentInfo WithMsgId:msgId ToJid:jid];
}

- (void)sendEncryptionChatWithType:(int)encryptionChatType WithBody:(NSString *)body ToJid:(NSString *)jid {
    [_pbXmppStack sendEncryptionChatWithType:encryptionChatType WithBody:body ToJid:jid];
}

@end
