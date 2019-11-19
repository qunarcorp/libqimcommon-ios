//
//  QIMPBStack.h
//  qunarChatCommon
//
//  Created by admin on 16/10/9.
//  Copyright © 2016年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMPBStream.h"

@protocol QIMPBStackDelegate <NSObject>
@required
- (void) beginToConnect;
- (void) beenConnected;
- (void) loginComplate;
- (void) loginFaildWithErrCode:(NSString *)errCode WithErrMsg:(NSString *)errMsg;
- (void) logout;
- (void) onDisconnect;

- (void) configWithRemoteKey:(NSString *)remoteKey WithSystemTime:(long long)systemTime;

- (void) registerSuccess;
- (void) registerFaild:(NSString *) error;

- (void) delFriend:(NSString *)userID;

- (void) onSystemMsgReceived:(NSString *)message
                   messageId:(NSString *) msgId
                       stamp:(NSDate *)date
                      msgRaw:(NSString *)msgRaw;

- (void)onShareLocationMessageReceived:(NSString *)destId
                                domain:(NSString *)domain
                               shareId:(NSString *)shareId
                           messageType:(int)msgType
                          platformType:(int)payformType
                               message:(NSString *)msg
                                 stamp:(NSDate *)date
                            extendInfo:(NSString *)extendInfo;

- (void) onMessageReceived:(NSString *) destId
                    domain:(NSString *) domain
               messageType:(int) msgType
              platformType:(int) payformType
                   message:(NSString *) message
               originalMsg:(NSString *) orininalMsg
                 messageId:(NSString *) msgId
                 direction:(NSUInteger) direction
                     stamp:(NSDate *)date
                extendInfo:(NSString *)extendInfo
                 autoReply:(NSString *)autoReply
                    chatId:(NSString *)chatId
                    msgRaw:(NSString *)msgRaw;

- (void) onGroupMessageReceived:(NSString *) destId
                         domain:(NSString *) domain
                        sendJid:(NSString *) sendJid
                    messageType:(int) msgType
                   platformType:(int) payformType
                        message:(NSString *) message
                      messageId:(NSString *) msgId
                          stamp:(NSDate *)date
                     extendInfo:(NSString *)extendInfo
                     backupInfo:(NSString *)backupInfo
                  carbonMessage:(BOOL)carbonMessage
                      autoReply:(BOOL)autoReply
                         msgRaw:(NSString *)msgRaw;

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
                                      msgRaw:(NSString *)msgRaw;

- (void)onTypingReceived:(NSString *)destId;

//标记已读消息
- (void)onReadStateReceived:(NSString *)readType ForJid:(NSString *)jid infoStr:(NSString *)infoStr;

- (void)onRevokeReceived:(NSString *)destId
               messageId:(NSString *)messageId
                 message:(NSString *)message;

- (void)onReceivePublicNumberMsg:(NSDictionary *)msgDic;

@optional
- (void) onMessageReceived:(NSString *) destId
                withDomain:(NSString*) destDomain
           withMessageType:(int) msgType
          withPlatformType:(int)platformType
                andMessage:(NSString *) msg
              andMessageId:(NSString *)msgId
             andExtendInfo:(NSString *)extendInfo;

// 好友
- (void)verifyFriendPresenceWithFrom:(NSString *)from
                              WithTo:(NSString *)to
                       WithDirection:(int)direction
                          WithResult:(NSString *)result
                          WithReason:(NSString *)reason;

- (void)validationFriendFromUserId:(NSString *)from
                          WithBody:(NSString *)body;

- (void)onTransferChatWithFrom:(NSString *)from
                   WithMsgType:(int)msgType
                    WithChatId:(NSString *)chatId
                     WithMsgId:(NSString *)msgId
                      WithJson:(NSString *)json;
//加密会话
- (void)receiveEncryptMessageWithFrom:(NSString *)from
                          WithMsgType:(int)msgType
                          WithContent:(NSString *)content
                           WithCarbon:(BOOL)carbon;

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
                        msgRaw:(NSString *)msgRaw;

- (void)onReceiveCollectionMsg:(NSString *)msgId
                WithOriginFrom:(NSString *)originFrom
                  WithOriginTo:(NSString *)originTo
                WithOriginType:(NSString *)originType;

- (void)onReceiveErrorMsgWithFrom:(NSString *)from
                        WithMsgId:(NSString *)msgId
                     WithErrorCode:(NSString *)errcode;
    
- (void)onMessageUpdateMState:(NSDictionary *)msgDic;

- (void)receTransferChatWithFrom:(NSString *)from
                       WithMsgId:(NSString *)msgId;

- (void)updateChannelInfo:(NSString *)channelInfo ForUserId:(NSString *)userId;
- (void)updateAppendInfo:(NSString *)appendInfo WithAppendKey:(NSString *)appendKey ForUserId:(NSString *)userId;

- (void)pbUserStatusChange:(NSString *)jid
                  WithShow:(NSString *)show
              WithPriority:(NSString *)priority;

- (void)serviceStreamEndWithErrorCode:(NSInteger)errorCode WithReason:(NSString *)reason;

- (void)messageLog:(NSString *)messageLog
     WithDirection:(int)direction;

- (void)userResource:(NSString *)resource
              forJid:(NSString *)jid;

- (void)connectTimeOut;

- (void)receiveCallAudioVideFromJid:(NSString *)jid
                       WithResource:(NSString *)resource
                        WithMsgType:(int)msgType;

- (void)receiveMeetingAudioVideoConferenceFromJid:(NSString *)jid
                                     WithResource:(NSString *)resource
                                      WithMsgType:(int)msgType;

- (void)receiveKeyNotiyPresenceFromCatrgoryType:(SInt32)categoryType
                          WithPresenceBodyValue:(NSString *)bodyValue;

@end

@protocol PBChatRoomDelegate <NSObject>
// PB Chat Room Presence
- (void)pbChatRoom:(NSString *)groupId
        WithAddJid:(NSString *)memberJid
   WithAffiliation:(NSString *)affiliation
        WithDomain:(NSString *)domain
          WithName:(NSString *)name;

- (void)pbChatRoom:(NSString *)groupId
    WithInviteUser:(NSString *)jid
        WithStatus:(NSString *)status;

- (void)pbChatRoomDestory:(NSString *)groupId;

- (void)pbChatRoom:(NSString *)groupId
  WithDelMemberJid:(NSString *)memberJid
   WithAffiliation:(NSString *)affiliation
          WithRole:(NSString *)role
          WithCode:(NSString *)code;

- (void)pbChatRommUpdateCard:(NSString *)groupId
                WithNickName:(NSString *)nickName
                   WithTitle:(NSString *)title
                  WithPicUrl:(NSString *)picUrl
                 WithVersion:(NSString *)version;

- (void)pbChatRomm:(NSString *)groupId
     WithDelRegJid:(NSString *)delJid;

@end

@interface QIMPBStack : NSObject

@property (nonatomic, assign)   BOOL isRegister;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSString *domain;
@property (nonatomic, unsafe_unretained) int port;
@property (nonatomic, weak) id<QIMPBStackDelegate> delegate;
@property (nonatomic, weak) id<PBChatRoomDelegate> chatRoomDelegate;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *systemVersion;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) int productType;
@property (nonatomic, assign) BOOL isFromMac;
@property (nonatomic, strong) NSString *deviceUUID;

- (NSString *)resource;

- (QIMPBStream *) innerStream;

- (void)setLoginType:(int)type;

- (id) initWithUserId:(NSString *) userId andDomain:(NSString *) domain;

- (BOOL) connectWithTimeout:(NSTimeInterval) timeoutInterval withError:(NSError **) error;

- (BOOL) connectToHost:(NSString *) host withPort:(int) serverPort withTimeout:(NSTimeInterval) timeoutInterval withError:(NSError **) error;

- (void) logout;

- (void) cancelLogin;

- (void)sendHeartBeat;

- (void)receiveChatTransferToUser:(NSString *)user ForMsgId:(NSString *)msgId;

- (NSString *)getMyVirtualJid;

#pragma mark - Roster
//0 全部拒绝 1.人工认证  2.答案认证 3.全部接收
- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)xmppId;
- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer;
- (NSString *)getFriendsJson;
- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer;
- (void)validationFriendWithXmppId:(NSString *)xmppId WithReason:(NSString *)reason;
- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId;
- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId;
//1.删除好友,客户端请求，其中mode1为单项删除，mode为2为双项删除
- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode;
- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId;
- (BOOL)setReceiveMsgLimitWithMode:(int)mode;

#pragma mark - 发送阅读状态消息

- (BOOL)sendClearAllMsgStateByReadMarkT:(long long)readMarkT;
- (BOOL)sendControlStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId;
- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithMessageReadFlag:(NSInteger)msgReadFlag WithXmppid:(NSString *)xmppId;
- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithMessageReadFlag:(NSInteger)msgReadFlag WithXmppid:(NSString *)xmppId WithTo:(NSString *)to;
- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithMessageReadFlag:(NSInteger)msgReadFlag WithXmppid:(NSString *)xmppId WithTo:(NSString *)to withRealTo:(NSString *)realTo;
- (BOOL) sendReadStateWithMessageTime:(long long)time groupName:(NSString *) groupName WithDomain:(NSString *)domain;

//发送通知类Presence
- (void)sendNotifyPresenceMsg:(NSDictionary *)msgDict ToJid:(NSString *)tojid;

- (void)sendTypingToUserId:(NSString *)userId;

#pragma mark - 发送自动回复消息

- (BOOL)sendAutoReplyWithMessage:(NSString *)message toJid:(NSString *)jid WithMsgId:(NSString *)msgId;

#pragma mark - 发送位置共享消息

- (BOOL)sendShareLocationMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType WithChatId:(NSString *)chatId;
- (BOOL)sendShareLocationMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType WithChatId:(NSString *)chatId OutMsgRaw:(NSString **)msgRaw;

#pragma mark - 发送单人消息

/**
 发送单人消息
 
 @param messageDict 消息体字典，具体需要什么在下层解析
 */
- (BOOL)sendChatMessageWithMsgDict:(NSDictionary *)messageDict;


#pragma mark - 发送群组消息

/**
 发送群组消息
 
 @param messageDict 消息体字典，具体需要什么在内层解析
 */
- (BOOL)sendGroupMessageWithMessageDict:(NSDictionary *)messageDict;

- (BOOL)revokeMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid;

- (BOOL)revokeGroupMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid;

#pragma mark - 发送公众号消息

- (BOOL)sendPublicNumberMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType;

#pragma mark - 发送Consult消息

- (BOOL)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid realFromJid:(NSString *)realFromJid channelInfo:(NSString *)channelInfo WithAppendInfoDict:(NSDictionary *)appendInfoDict chatId:(NSString *)chatId WithMsgTYpe:(int)msgType OutMsgRaw:(NSString **)msgRaw;

- (BOOL)revokeConsultMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(int)chatType;


#pragma mark - Share Location
//开启一个共享位置
- (BOOL)beginShareLocationToUserId:(NSString *)userId WithShareLocationId:(NSString *)shareLocationId;
- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;
- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId;
- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId;

#pragma mark - Share Location
- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType;
- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType;
- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType;

#pragma mark - group method
- (BOOL)createRoom:(NSString *)roomName;
- (NSArray *)getChatRoomList;

// 获取群成员
- (NSArray *)getChatRoomMembersForGroupId:(NSString *)groupId;
// 用户邀请入群v2
- (NSArray *)inviteGroupMembers:(NSArray *)members ToGroupId:(NSString *)groupId;
// 用户入群注册
- (BOOL)registerJoinGroup:(NSString *)groupId;
// 退群取消注册
- (BOOL)quitGroupDelRegister:(NSString *)groupId;
- (BOOL)setGroupId:(NSString *)groupId WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid;
- (BOOL)setGroupId:(NSString *)groupId WithMemberNickName:(NSString *)nickName ForJid:(NSString *)memberJid;
- (BOOL)removeGroupId:(NSString *)groupId ForMemberJid:(NSString *)memberJid WithNickName:(NSString *)nickName;
- (BOOL)destoryChatRoom:(NSString *)groupId;

// 变更状态
- (void)goAway;
- (void)goDnd;
- (void)goXa;
- (void)goChat;
- (void)goOffLine;
- (void) deactiveReconnect;
- (void) activeReconnect;

- (NSString *)getRemoteLoginKey;

- (dispatch_queue_t)getXmppQueue;

#pragma mark - Audio Video

- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid;

#pragma mark - EncryptionMessage

- (void)sendEncryptionChatWithType:(int)encryptionChatType WithBody:(NSString *)body ToJid:(NSString *)jid;

@end
