//
//  XmppImManager.h
//  qunarChatCommon
//
//  Created by May on 14/11/20.
//  Copyright (c) 2014年 May. All rights reserved.
//


#import <Foundation/Foundation.h>

enum XmppEvent {
    XmppEventConnected = 10,
    XmppEventConnecting = 11,
    XmppEvent_LoginComplate = 200,
    
    XmppEvent_LoginFaild,
    
    XmppEvent_RegisterSuccess,
    XmppEvent_RegisterFaild,
    
    XmppEvent_PublicNumberMsg,
    XmppEvent_CollectionMessageIn,
    XmppEvent_CollectionOriginMessageIn,
    XmppEvent_SystemMessageIn,
    XmppEvent_Typing,
    XmppEvent_Revoke,
    XmppEvent_ReadState,
    XmppEvent_ConsultReadState,
    XmppEvent_ShareLocation,
    
    XmppEvent_MessageIn,
    XmppeventGroupMessageIn,
    
    XmppEvent_GroupImageIn,
    
    XmppEvent_FileIn,
    XmppEvent_GroupFileIn,
    
    XmppEvent_ShockIn,
    XmppEvent_GroupShockIn,
    
    XmppEvent_AddFriend,
    XmppEvent_DelFriend,
    
    XmppEvent_UserStatusChange,
    
    XmppEvent_NewGroup,
    XmppEvent_JoinChatRoom,
    XmppEvent_LeaveChatRoom,
    XmppEvent_MyJoinChatRoom,
    XmppEvent_MyLeaveChatRoom,
    XmppEvent_ChatRoomFaild,
    XmppEvent_InvateChatRoom,
    XmppEvent_ChatRoomTopicUpdate,
    XmppEvent_ChatRoomDestroy,
    XmppEvent_ChatRoomRemoveMember,
    
    XmppEvent_ChatRoomResgister_DelUser,
    XmppEvent_ChatRoomResgister_InviteUser,
    
    XmppEvent_PBPresence_ChatRoomAddMember,
    XmppEvent_PBPresence_ChatRoomInviteMember,
    XmppEvent_PBPresence_ChatRoomDeleteMember,
    XmppEvent_PBPresence_ChatRoomDestory,
    XmppEvent_PBPresence_ChatRoomCardUpdate,
    XmppEvent_PBPresence_ChatRoomRegisterDelMember,
    XmppEvent_PBPresence_UserStatusChanage,
    XmppEvent_PBPresence_CategoryNotify,
    
    XmppEvent_Config_Key_Time,
    XmppEvent_User_Muc_List,
    
    XmppEvent_Friend_Presence,
    XmppEvent_Friend_Validation,
    
    XmppEvent_TransferChat,
    XmppEvent_MStateUpdate,
    XmppEvent_ReceiveTransferChat,
    
    XmppEvent_UpdateChannelInfo,
    XmppEvent_UpdateAppendInfo,
    
    XmppEvent_StreamEnd,
    XmppEvent_Disconnect,
    
    XmppEvent_MessageLog,
    
    XmppEvent_UserResource,
    
    XmppEvent_ConnectTimeOut,
    
    XmppEvent_CallVideoAudio,
    XmppEvent_CallMeetingAudioVideoConference,
    
    XmppEvent_ReceiveConsultMessage,
    XmppEvent_ReceiveEncryptMessage,
    XmppEvent_MessageError,
    XmppEvent_UpdateOfflineTime,
};

enum {
    MsgDirection_Receive = 1,
    MsgDirection_Send = 2,
};

enum XmppLoginType {
    XmppLoginType_LAN = 0,
    XmppLoginType_Internet,
};

@interface XmppImManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *domain;
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int loginType;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *systemVersion;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, assign) int productType;
@property (nonatomic, assign) int protocolType;
@property (nonatomic, assign) BOOL isFromMac;
@property (nonatomic, copy) NSString *deviceUUID;

/**
 获取用户当前登录状态
 */
- (BOOL)loginState;

- (NSString *)resource;

- (void)setLoginType:(int)LoginType;

- (id)xmppStack;

- (dispatch_queue_t)getXmppQueue;

- (NSString *)getRemoteLoginKey;

#pragma mark - 登录

- (void)loginwithName:(NSString *)userName password:(NSString *)pwd;

- (void)relogin;

- (void)cancelLogin;

- (void)sendHeartBeat;

- (void)addTarget:(id)object method:(SEL)method withXmppEvent:(enum XmppEvent)event;

- (void)removeTargaet:(id)object;

- (void)removeEvent:(enum XmppEvent)event atObject:(id)object;

- (void)resetIP:(NSString *)ip port:(int)port domain:(NSString *)domain;

#pragma mark - 群

- (void)quickJoinAllGroup;

// 获取群成员
- (NSArray *)getChatRoomMembersForGroupId:(NSString *)groupId;
- (NSArray *)inviteGroupMembers:(NSArray *)members ToGroupId:(NSString *)groupId;
- (BOOL)pbCreateChatRomm:(NSString *)roomName;
- (BOOL)registerJoinGroup:(NSString *)groupId;
- (BOOL)quitGroupDelRegister:(NSString *)groupId;
- (BOOL)setGroupId:(NSString *)groupId WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid;
- (BOOL)setGroupId:(NSString *)groupId WithMemberNickName:(NSString *)nickName ForJid:(NSString *)memberJid;
- (BOOL)removeGroupId:(NSString *)groupId ForMemberJid:(NSString *)memberJid WithNickName:(NSString *)nickName;
- (BOOL)destoryChatRoom:(NSString *)groupId;
- (NSDictionary *)groupMembersByGroupId:(NSString *)groupId;

#pragma mark - Roster

//0 全部拒绝 1.人工认证  2.答案认证 3.全部接收
- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)userId;

- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer;

- (NSString *)getFriendsJson;

- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer;

- (void)validationFriendWithXmppId:(NSString *)xmppId WithReason:(NSString *)reason;

- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId;

- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId;

//1.删除好友,客户端请求，其中mode1为单项删除，mode为2为双项删除
- (BOOL)deleteFriendWithXmppId:(NSString *)userId WithMode:(int)mode;

- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId;

- (NSDictionary *)parseMessageByMsgRaw:(id)msgRaw;

- (NSDictionary *)parseOriginMessageByMsgRaw:(id)msgRaw;

- (BOOL)setReceiveMsgLimitWithMode:(int)mode;

- (NSString *)getMyVirtualJid;

#pragma mark - 好友列表

- (void)receiveChatTransferToUser:(NSString *)user ForMsgId:(NSString *)msgId;

- (void)sendTypingToUserId:(NSString *)userId;

- (BOOL)sendAutoReplyWithMessage:(NSString *)message toJid:(NSString *)jid WithMsgId:(NSString *)msgId;

// 位置共享
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
 
 @param messageDict 消息体字典，具体需要什么在下层解析
 */

- (BOOL)sendGroupMessageWithMessageDict:(NSDictionary *)messageDict;

- (BOOL)sendMessage:(NSString *)message withChatType:(NSString *)chatType channelInfo:(NSString *)channelInfo WithAppendInfoDict:(NSDictionary *)appendInfoDict exInfo:(NSString *)exInfo toJid:(NSString *)jid realFrom:(NSString *)realFrom realTo:(NSString *)realTo msgId:(NSString *)msgId msgType:(int)msgType WithChatId:(NSString *)chatId ochatJson:(NSString *)ochatJson OutMsgRaw:(NSString **)msgRaw;

- (BOOL)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid realFromJid:(NSString *)realFromJid channelInfo:(NSString *)channelInfo WithAppendInfoDict:(NSDictionary *)appendInfoDict chatId:(NSString *)chatId WithMsgTYpe:(int)msgType OutMsgRaw:(NSString **)msgRaw;

- (BOOL)sendClearAllMsgStateByReadMarkT:(long long)readMarkT;

- (BOOL)sendControlStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId;

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithMessageReadFlag:(NSInteger)msgReadFlag WithXmppId:(NSString *)xmppId;

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithMessageReadFlag:(NSInteger)msgReadFlag WithXmppid:(NSString *)xmppId WithTo:(NSString *)to;

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithMessageReadFlag:(NSInteger)msgReadFlag WithXmppid:(NSString *)xmppId WithTo:(NSString *)to withRealTo:(NSString *)realTo;

- (BOOL)sendReadStateWithMessageTime:(long long)time groupName:(NSString *)groupName WithDomain:(NSString *)domain;

- (void)sendNotifyPresenceMsg:(NSDictionary *)msgDict ToJid:(NSString *)tojid;

- (BOOL)sendPublicNumberMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType;

- (BOOL)revokeMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid;

- (BOOL)revokeGroupMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid;

- (BOOL)revokeConsultMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid realToJid:(NSString *)realToJid chatType:(int)chatType;

#pragma mark - Login

- (void)quitLogin;

- (BOOL)forgelogin;

- (void)logout;

- (void)disconnect;

- (void)goAway;

- (void)goDnd;

- (void)goXa;

- (void)goChat;

- (void)deactiveReconnect;

- (void)activeReconnect;

#pragma mark - Share Location

- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType;

- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType;

- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType;

#pragma mark - Audio Video

- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extentInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid;

#pragma mark - EncryptionChat

- (void)sendEncryptionChatWithType:(int)encryptionChatType WithBody:(NSString *)body ToJid:(NSString *)jid;

@end
