//
//  QIMPBStack.m
//  qunarChatCommon
//
//  Created by admin on 16/10/9.
//  Copyright © 2016年 May. All rights reserved.
//

#import "QIMPBStack.h"
#import "QIMPBStream.h"
#import "ProtobufReconnector.h"
#import "QIMXMPPJID.h"
#import "Message.pb.h"
#import "IQMessage+Utility.h"
#import "IMDataManager.h"
#import "XmppImManager.h"
#import "GCDAsyncSocket.h"
#import "QIMPublicRedefineHeader.h"
#include <sys/types.h>
#include <sys/sysctl.h>

enum PlaType {
    MachineTypeMac = 1,
    MachineTypeiOS = 2,
    MachineTypePC = 3,
    MachineTypeAndroid = 4,
    MachineTypeLinux = 5,
};

@interface QIMPBStack ()

@end

#pragma mark - xmppstack delegate

@interface QIMPBStack (PBXMPPStreamDelegate) <PBXMPPStreamDelegate>

@end

@interface QIMPBStack () {
    __strong QIMPBStream *_pbXmppStream;
    __strong NSString *_domain;
    __strong ProtobufReconnector *_reconnector;
    __strong NSTimeInterval _beginTime;
    __strong dispatch_source_t _connectTimer;
    dispatch_queue_t _xmppQueue;
    void *_xmppQueueTag;
    BOOL _startTLS;
}

@end

@implementation QIMPBStack

@synthesize userId, password, hostName, port;

- (dispatch_queue_t)getXmppQueue {
    return _xmppQueue;
}

- (NSString *)resource {
    return _pbXmppStream.myJID.resource;
}

- (void)setLoginType:(int)type {
    [_pbXmppStream setLoginType:type];
}

- (void)innerInit {
    
    _xmppQueueTag = &_xmppQueueTag;
    _xmppQueue = dispatch_queue_create("xmppRunningQueue", 0);
    dispatch_queue_set_specific(_xmppQueue, _xmppQueueTag, _xmppQueueTag, NULL);
    _pbXmppStream = [[QIMPBStream alloc] init];
    // 自动开启TLS
    [_pbXmppStream setAutoStartTLS:YES];
    
    //    _autoPing = [[XMPPAutoPing alloc] initWithDispatchQueue:_xmppQueue];
    //    [_autoPing setPingInterval:180];
    
    //    if (!_startTLS)
    //        _compression = [[XMPPCompression alloc] init];
    //    [_compression activate:_xmppStream];
    
    //    if (_startTLS)
    //        [_xmppStream setAutoStartTLS:YES];
    
    
    //    _messageArchiving = [[XMPPMessageArchiving alloc] initWithDispatchQueue:dispatch_queue_create("XMPPMessageArchiving Queue", DISPATCH_QUEUE_SERIAL)];
    //    _messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self];
    // 重连
    _reconnector = [[ProtobufReconnector alloc] initWithDispatchQueue:_xmppQueue];
    [_reconnector activate:_pbXmppStream];
    //
    //    [_messageArchiving activate:_xmppStream];
    //    [_autoPing activate:_xmppStream];
    
    [_pbXmppStream addDelegate:self delegateQueue:_xmppQueue];
    //    [_reconnector addDelegate:self delegateQueue:_xmppQueue];
    
    //    _iqManager = [[XmppIqManager alloc] initWithXmppStream:_xmppStream delegateQueue:_xmppQueue];
    
}

- (id)init {
    self = [super init];
    if (self) {
        [self innerInit];
    }
    return self;
}

- (id)initWithUserId:(NSString *)theUserId andDomain:(NSString *)theDomain {
    self = [super init];
    if (self) {
        [self innerInit];
        
        NSString *myselfUrl = [NSString stringWithFormat:@"%@@%@", theUserId, theDomain];
        [self setDomain:theDomain];
        [_pbXmppStream setMyJID:[QIMXMPPJID jidWithString:myselfUrl]];
    }
    return self;
}

- (id)initWithUserUri:(NSString *)uri {
    self = [super init];
    if (self) {
        _xmppQueue = dispatch_queue_create("xmppRunningQueue", 0);
        _pbXmppStream = [[QIMPBStream alloc] init];
        [_pbXmppStream addDelegate:self delegateQueue:_xmppQueue];
        [_pbXmppStream setMyJID:[QIMXMPPJID jidWithString:uri]];
    }
    return self;
}

- (id)initWithUserId:(NSString *)name andPassword:(NSString *)pwd {
    self = [super init];
    if (self) {
        [self setUserId:name];
        [self setPassword:pwd];
        _pbXmppStream = [[QIMPBStream alloc] init];
        _xmppQueue = dispatch_queue_create("xmppRunningQueue", 0);
        [_pbXmppStream addDelegate:self delegateQueue:_xmppQueue];
        [_pbXmppStream setMyJID:[QIMXMPPJID jidWithUser:name domain:_domain resource:@"local"]];
    }
    return self;
}

- (void)dealloc {
    QIMVerboseLog(@"QIMPBStack dealloc");
}

- (BOOL)connectWithTimeout:(NSTimeInterval)timeoutInterval withError:(NSError **)error {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        _beginTime = [[NSDate date] timeIntervalSince1970];
        
        [_reconnector resetNetworkingcheckingDomain:[self hostName]];
        [_reconnector setAutoReconnect:YES];
        [_reconnector manualStart];
        
        if (hostName && (port != 0)) {
            [_pbXmppStream setHostName:hostName];
            
            //            if ([_pbXmppStream myJID] == nil) {
            //                NSString *selfUrl = [NSString stringWithFormat:@"%@@%@", [self userId], [self domain]];
            //                [_pbXmppStream setMyJID:[QIMXMPPJID jidWithString:selfUrl]];
            //            }
            
            [_pbXmppStream setHostPort:port];
            
            if ([_pbXmppStream isConnected]) {
                NSError *error = nil;
                if (![_pbXmppStream isAuthenticated]) {
                    NSString *resource = [NSString stringWithFormat:@"V[%@]_P[%@]_D[%@]_S[%@]_ID[%@]_PB", self.appVersion ? self.appVersion : @"unknow", self.platform, self.deviceName, self.systemVersion, [QIMPBStream generateUUID]];
                    NSString *selfUrl = [NSString stringWithFormat:@"%@@%@/%@", [self userId], [self domain], resource];
                    [_pbXmppStream setMyJID:[QIMXMPPJID jidWithString:selfUrl]];
                    [_pbXmppStream setPassword:[self password]];
                    [_pbXmppStream setDeviceUUID:[self deviceUUID]];
                    [_pbXmppStream authenticateWithPassword:[self password] error:&error];
                } else {
                    QIMVerboseLog(@"当前链接已验证过了");
                    if ([self delegate] && [[self delegate] respondsToSelector:@selector(loginComplate)]) {
                        [[self delegate] loginComplate];
                    }
                }
                result = YES;
            } else {
                NSString *resource = [NSString stringWithFormat:@"V[%@]_P[%@]_D[%@]_S[%@]_ID[%@]_PB", self.appVersion ? self.appVersion : @"unknow", self.platform, self.deviceName, self.systemVersion, [QIMPBStream generateUUID]];
                NSString *selfUrl = [NSString stringWithFormat:@"%@@%@/%@", [self userId], [self domain], resource];
                [_pbXmppStream setMyJID:[QIMXMPPJID jidWithString:selfUrl]];
                [_pbXmppStream setPassword:[self password]];
                [_pbXmppStream setDeviceUUID:[self deviceUUID]];
                result = [_pbXmppStream connectWithTimeout:timeoutInterval error:error];
            }
        }
        result = NO;
    };
    
    if (dispatch_get_specific(_xmppQueueTag))
        block();
    else
        dispatch_sync(_xmppQueue, block);
    
    return result;
}

- (BOOL)connectToHost:(NSString *)host withPort:(int)serverPort withTimeout:(NSTimeInterval)timeoutInterval withError:(NSError **)error {
    [self setHostName:host];
    [self setPort:serverPort];
    return [self connectWithTimeout:timeoutInterval withError:error];
}

//<presence>
//<show>away</show>
//<status>我目前不在</status>
//<priority>5</priority>
//<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ver="caps-b75d8d2b25" ext="ca cs ep-notify-2 html"/>
//<x xmlns="vcard-temp:x:update">
//<photo>6ddb42992b4ccf7809b05769abf8d448fb31f481</photo>
//</x>
//</presence>
- (void)goAway {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"status"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"user_update_status"];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"show"] setValue:@"away"] build]];
    [headers addObject:[[[[StringHeader builder] setKey:@"priority"] setValue:@"5"] build]];
    [bodyBuilder setHeadersArray:headers];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build]];
}

//<presence>
//<show>dnd</show>
//<status>我目前不在</status>
//<priority>5</priority>
//<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ver="caps-b75d8d2b25" ext="ca cs ep-notify-2 html"/>
//<x xmlns="vcard-temp:x:update">
//<photo>6ddb42992b4ccf7809b05769abf8d448fb31f481</photo>
//</x>
//</presence>
- (void)goDnd {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"status"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"user_update_status"];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"show"] setValue:@"busy"] build]];
    [headers addObject:[[[[StringHeader builder] setKey:@"priority"] setValue:@"5"] build]];
    [bodyBuilder setHeadersArray:headers];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build]];
}

//<presence>
//<show>xa</show>
//<status>我目前不在</status>
//<priority>5</priority>
//<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ver="caps-b75d8d2b25" ext="ca cs ep-notify-2 html"/>
//<x xmlns="vcard-temp:x:update">
//<photo>6ddb42992b4ccf7809b05769abf8d448fb31f481</photo>
//</x>
//</presence>
- (void)goXa {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"status"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"user_update_status"];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"show"] setValue:@"xa"] build]];
    [headers addObject:[[[[StringHeader builder] setKey:@"priority"] setValue:@"5"] build]];
    [bodyBuilder setHeadersArray:headers];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build]];
}

//<presence>
//<show>chat</show>
//<status>我目前不在</status>
//<priority>5</priority>
//<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ver="caps-b75d8d2b25" ext="ca cs ep-notify-2 html"/>
//<x xmlns="vcard-temp:x:update">
//<photo>6ddb42992b4ccf7809b05769abf8d448fb31f481</photo>
//</x>
//</presence>
- (void)goChat {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"status"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"user_update_status"];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"show"] setValue:@"chat"] build]];
    [headers addObject:[[[[StringHeader builder] setKey:@"priority"] setValue:@"5"] build]];
    [bodyBuilder setHeadersArray:headers];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build]];
}

//<!-- TS:2014-03-21T17:07:54--><presence from="123455@lvtuchat.com/MaydeMacBook-Pro" to="123455@lvtuchat.com">
//<priority>5</priority>
//<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ext="ca cs ep-notify-2 html" ver="caps-b75d8d2b25"/>
//</presence>

- (void)goOnLine {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"priority"];
    [builder setValue:[NSString stringWithFormat:@"%d", 5]];
    [_pbXmppStream sendPresenceMessage:[builder build]];
}

- (void)deactiveReconnect {
    [_reconnector deactivate];
    [_reconnector stop];
}

- (void)activeReconnect {
    [_reconnector activate:_pbXmppStream];
    [_reconnector manualStart];
}

- (void)goOffLine {
    [self logout];
}

- (NSString *)getRemoteLoginKey {
    if ([_pbXmppStream isAuthenticated]) {
        IQMessageBuilder *iqBuilder = [IQMessage builder];
        [iqBuilder setKey:@"GET_USER_KEY"];
        [iqBuilder setMessageId:[QIMPBStream generateUUID]];
        IQMessage *result = [_pbXmppStream syncIQMessage:[iqBuilder build]];
        if ([result.key isEqualToString:@"result"]) {
            NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
            long long time_key = [[keyValues objectForKey:@"time_key"] longLongValue];
            NSString *key = [keyValues objectForKey:@"key"];
            return key;
        }
    }
    return nil;
}

- (NSString *)getJsonStringWithDictionary:(NSDictionary *)dictionary {
    if (dictionary == nil) {
        return nil;
    }
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        QIMVerboseLog(@"PB Json解析失败：%@", err);
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)chatTransferFrom:(NSString *)from To:(NSString *)to User:(NSString *)user Reson:(NSString *)reson chatId:(NSString *)chatId WithMsgId:(NSString *)msgId {
    if (to && from && user) {
        // 发给web端的
        NSArray *toComs = [to componentsSeparatedByString:@"@"];
        NSMutableDictionary *toUser = [NSMutableDictionary dictionary];
        [toUser setObject:toComs.firstObject forKey:@"TransId"];
        [toUser setObject:toComs.lastObject forKey:@"Domain"];
        [toUser setObject:reson forKey:@"TransReson"];
        NSString *toUserJson = [self getJsonStringWithDictionary:toUser];
        if (toUserJson) {
            XmppMessageBuilder *msgBuilder = [XmppMessage builder];
            [msgBuilder setMessageId:msgId];
            [msgBuilder setMessageType:1001];
            [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
            [msgBuilder setClientVersion:0];
            [msgBuilder setMessageId:msgId];
            MessageBodyBuilder *bodyBuilder = [MessageBody builder];
            [bodyBuilder setValue:toUserJson];
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:toUserJson] build]];
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"chatid"] setValue:@"0"] build]];
            [msgBuilder setBody:[bodyBuilder build]];
            ProtoMessageBuilder *builder = [ProtoMessage builder];
            [builder setSignalType:SignalTypeSignalTypeTransfor];
            [builder setFrom:[[_pbXmppStream myJID] full]];
            [builder setTo:user];
            [builder setMessage:msgBuilder.build.data];
            PBXMPPReceipt *receipt = nil;
            [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        }
        
        // 发给商户端的
        NSArray *fromComs = [from componentsSeparatedByString:@"@"];
        NSMutableDictionary *toKefu = [NSMutableDictionary dictionary];
        [toKefu setObject:fromComs.firstObject forKey:@"f"];
        [toKefu setObject:fromComs.lastObject forKey:@"d"];
        [toKefu setObject:reson forKey:@"r"];
        [toKefu setObject:user forKey:@"u"];
        NSString *toKefuJson = [self getJsonStringWithDictionary:toKefu];
        if (toKefuJson) {
            XmppMessageBuilder *msgBuilder = [XmppMessage builder];
            [msgBuilder setMessageId:msgId];
            [msgBuilder setMessageType:1002];
            [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
            [msgBuilder setClientVersion:0];
            [msgBuilder setMessageId:msgId];
            MessageBodyBuilder *bodyBuilder = [MessageBody builder];
            [bodyBuilder setValue:toKefuJson];
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"chatid"] setValue:@"0"] build]];
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:toKefuJson] build]];
            [msgBuilder setBody:[bodyBuilder build]];
            ProtoMessageBuilder *builder = [ProtoMessage builder];
            [builder setSignalType:SignalTypeSignalTypeTransfor];
            [builder setFrom:[[_pbXmppStream myJID] full]];
            [builder setTo:to];
            [builder setMessage:msgBuilder.build.data];
            PBXMPPReceipt *receipt = nil;
            [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        }
    }
}

- (void)receiveChatTransferToUser:(NSString *)user ForMsgId:(NSString *)msgId {
    if (user && msgId) {
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageId:msgId];
        [msgBuilder setMessageType:1003];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:msgId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"chatid"] setValue:@"0"] build]];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeTransfor];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:user];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    }
}

- (void)chatTransferTo:(NSString *)user message:(NSString *)message chatId:(NSString *)chatId {
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:message];
    [msgBuilder setBody:[bodyBuilder build]];
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeTransfor];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:user];
    [builder setMessage:msgBuilder.build.data];
    PBXMPPReceipt *receipt = nil;
    [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
}

- (void)goOnlineWithXmppStream:(QIMPBStream *)stream {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self goOnLine];
        if ([self delegate] && [[self delegate] respondsToSelector:@selector(loginComplate)]) {
            [[self delegate] loginComplate];
        }
        
        if ([self.delegate respondsToSelector:@selector(configWithRemoteKey:WithSystemTime:)]) {
            [self.delegate configWithRemoteKey:_pbXmppStream.remoteKey WithSystemTime:_pbXmppStream.serviceTime];
        }
    });
}

//<!-- TS:2014-03-21T16:32:17--><presence type="unavailable">
//<status>Logged out</status>
//</presence>
- (void)sendLogout {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"status"];
    [builder setValue:@"Logged out"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"type"] setValue:@"unavailable"] build]];
    [bodyBuilder setHeadersArray:headers];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build]];
}

- (void)logout {
    [self sendLogout];
    [_pbXmppStream cancelAllIQMessage];
    [_reconnector setAutoReconnect:NO];
    [_pbXmppStream disconnectAfterSending];
}

- (void)cancelLogin {
    
    [_pbXmppStream cancelAllIQMessage];
    [_reconnector setAutoReconnect:NO];
    [_pbXmppStream disconnectAfterSending];
    [_pbXmppStream disconnect];
}

- (void)sendHeartBeat {
    [_pbXmppStream sendHeartBeat];
}

#pragma mark - Virtual User
- (NSArray *)getVirtualList{
//    <iq to='xuejie.bi@ejabhost1' id='console938df079' type='get'>
//    <get_virtual_user xmlns='jabber:x:virtual_user' jid='it-rexian'/>
//    </iq>
    IQMessageBuilder *iqBuilder = [IQMessage builder];
    [iqBuilder setKey:@"GET_VIRTUAL_USER"];
    [iqBuilder setMessageId:[QIMPBStream generateUUID]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[iqBuilder build] ToJid:[[_pbXmppStream myJID] bare]];
    if ([result.key isEqualToString:@"result"]) {
        NSMutableArray *resultList = nil;
        for (MessageBody *body in result.bodys) {
            NSDictionary *keyValues = [result getHeadersDicForHeaders:body.headers];
            if (resultList == nil) {
                resultList = [NSMutableArray array];
            }
            NSString *value = [keyValues objectForKey:@"vuser"];
            if (value) {
                [resultList addObject:value];
            }
        }
        return resultList;
    }
    return nil;
}

- (NSString *)getRealJidForVirtual:(NSString *)virtualJid{
//    <iq to='xuejie.bi@ejabhost1' id='console938df079' type='get'>
//    <real_user_start_session xmlns='jabber:x:virtual_user' jid='it-rexian'/>
//    </iq>
    IQMessageBuilder *iqBuilder = [IQMessage builder];
    [iqBuilder setKey:@"REAL_USER_START_SESSION"];
    [iqBuilder setMessageId:[QIMPBStream generateUUID]];
    [iqBuilder setValue:virtualJid];
    IQMessage *result = [_pbXmppStream syncIQMessage:[iqBuilder build] ToJid:[[_pbXmppStream myJID] bare]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
        if ([[keyValues objectForKey:@"start_session"] isEqualToString:@"success"]) {
            return [keyValues objectForKey:@"real_user"];
        }
        return nil;
    }
    return nil;
}

- (NSString *)getMyVirtualJid{
//    <iq to='xuejie.bi@ejabhost1' id='console938df079' type='get'>
//    <get_virtual_user_role xmlns='jabber:x:virtual_user' />
//    </iq>
    IQMessageBuilder *iqBuilder = [IQMessage builder];
    [iqBuilder setKey:@"GET_VIRTUAL_USER_ROLE"];
    [iqBuilder setMessageId:[QIMPBStream generateUUID]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[iqBuilder build]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
        return nil;
    }
    return nil;
}

#pragma mark - Roster

//0 全部拒绝 1.人工认证  2.答案认证 3.全部接收
//<iq type='get' id='purple179d7709'>
//<get_verify_friend_mode xmlns='jabber:iq:verify_friend_mode' jid='dan.liu'/>
//</iq>
- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)xmppId {
    
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"GET_USER_OPT"];
    [builder setValue:xmppId];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
        int mode = [[keyValues objectForKey:@"mode"] intValue];
        NSString *question = [keyValues objectForKey:@"question"];
        NSString *answer = [keyValues objectForKey:@"answer"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:@(mode) forKey:@"mode"];
        if (question) {
            [dic setObject:question forKey:@"question"];
        }
        if (answer) {
            [dic setObject:answer forKey:@"answer"];
        }
        return dic;
    }
    return nil;
}

//<iq type='set' id='purple179d7709'>
//<set_verify_friend_mode xmlns='jabber:iq:verify_friend_mode' mode='3' question='1+1=?' answer='2'/>
//</iq>
- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"SET_USER_OPT"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"set_verify_friend_mode"];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"mode"] setValue:[NSString stringWithFormat:@"%d", mode]] build]];
    if (question) {
        [headerList addObject:[[[[StringHeader builder] setKey:@"question"] setValue:question] build]];
    }
    if (answer) {
        [headerList addObject:[[[[StringHeader builder] setKey:@"answer"] setValue:answer] build]];
    }
    [bodyBuilder setHeadersArray:headerList];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
        NSString *result = [keyValues objectForKey:@"result"];
        if ([result isEqualToString:@"success"]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getFriendsJson {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"GET_USER_FRIEND"];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
        NSString *json = [keyValues objectForKey:@"friends"];
        return json;
    }
    return @"[]";
}

- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"verify_friend"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"verify_friend"];
    if (answer) {
        NSMutableArray *headerList = [NSMutableArray array];
        [headerList addObject:[[[[StringHeader builder] setKey:@"answer"] setValue:answer] build]];
        [bodyBuilder setHeadersArray:headerList];
    }
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build] ToJid:xmppId];
}

- (void)validationFriendWihtXmppId:(NSString *)xmppId WithReason:(NSString *)reason {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"verify_friend"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"verify_friend"];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"method"] setValue:@"manual_authentication_confirm"] build]];
    [bodyBuilder setHeadersArray:headerList];
    if (reason) {
        [headerList addObject:[[[[StringHeader builder] setKey:@"reason"] setValue:reason] build]];
        [bodyBuilder setHeadersArray:headerList];
    }
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build] ToJid:xmppId];
}

- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"manual_authentication_confirm"];
    [builder setValue:xmppId];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"manual_authentication_confirm"];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"result"] setValue:@"allow"] build]];
    [bodyBuilder setHeadersArray:headerList];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build] ToJid:xmppId];
}

- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId {
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"manual_authentication_confirm"];
    [builder setValue:xmppId];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"manual_authentication_confirm"];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"result"] setValue:@"denied"] build]];
    [bodyBuilder setHeadersArray:headerList];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build] ToJid:xmppId];
}

- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"DEL_USER_FRIEND"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"delete_friend"];
    NSArray *coms = [xmppId componentsSeparatedByString:@"@"];
    NSString *usId = [coms firstObject];
    NSString *domain = [coms lastObject];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"jid"] setValue:usId] build]];
    [headers addObject:[[[[StringHeader builder] setKey:@"domain"] setValue:domain] build]];
    [headers addObject:[[[[StringHeader builder] setKey:@"mode"] setValue:[NSString stringWithFormat:@"%d", mode]] build]];
    [bodyBuilder setHeadersArray:headers];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValues = [result getHeadersDicForHeaders:result.body.headers];
        NSString *resultValue = [keyValues objectForKey:@"result"];
        if ([resultValue isEqualToString:@"success"]) {
            return YES;
        }
    }
    return NO;
}

- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId {
    return 0;
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setKey:@"recv_msg_limit"];
    [builder setValue:@"get"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"recv_msg_limit"];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build]];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyValue = [result getHeadersDicForHeaders:result.body.headers];
        int mode = [[keyValue objectForKey:@"mode"] intValue];
        return mode;
    }
    return 0;
}

- (BOOL)setReceiveMsgLimitWithMode:(int)mode {
    return NO;
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setKey:@"recv_msg_limit"];
    [builder setValue:@"get"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:@"recv_msg_limit"];
    NSMutableArray *headers = [NSMutableArray array];
    [headers addObject:[[[[StringHeader builder] setKey:@"mode"] setValue:[NSString stringWithFormat:@"%d", mode]] build]];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build]];
    if ([result.key isEqualToString:@"result"]) {
        return YES;
    }
    return NO;
}

- (NSString *)checkXmlmessage:(NSString *)message {
    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:[message length]];
    NSUInteger length = [message length];
    for (int i = 0; i < length; i++) {
        unichar c = [message characterAtIndex:i];
        if ((c == 0x0) ||
            (c == 0x9) ||
            (c == 0xA) ||
            (c == 0xD) ||
            ((c >= 0x20) && (c <= 0xFFFD)) ||
            ((c >= 0xE000) && (c <= 0xFFFD)) ||
            ((c >= 0x10000) && (c <= 0x10FFFF))) {
            [result appendString:[NSString stringWithCharacters:&c length:1]];
        }
    }
    return result;
}

- (void)sendTypingToUserId:(NSString *)jid {
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeTyping];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:jid];
    [_pbXmppStream sendProtobufMessage:[builder build]];
}

#pragma mark - 发送自动回复消息

- (BOOL)sendAutoReplyWithMessage:(NSString *)message toJid:(NSString *)jid WithMsgId:(NSString *)msgId {
    if (message.length > 0) {
        
        message = [self checkXmlmessage:message];
        
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageType:MessageTypeMessageTypeText];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:msgId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:message];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"auto_reply"] setValue:@"true"] build]];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeChat];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

#pragma mark - 发送阅读状态

- (BOOL)sendClearAllMsgStateByReadMarkT:(long long)readMarkT {
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setMessageId:[QIMPBStream generateUUID]];
    [msgBuilder setMessageType:MessageTypeMessageTypeText];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:[NSString stringWithFormat:@"{\"T\":%lld}", readMarkT]];
    [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"read_type"] setValue:@"0"] build]];
    [msgBuilder setBody:[bodyBuilder build]];
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeReadmark];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:[[_pbXmppStream myJID] bare]];
    [builder setMessage:msgBuilder.build.data];
    PBXMPPReceipt *receipt = nil;
    [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    return [receipt wait:3000];
}

- (BOOL)sendControlStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId {
    
    return [self sendReadStateWithMessagesIdArray:jsonString WithXmppid:xmppId WithTo:xmppId WithReadFlag:7];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId {
    
    return [self sendReadStateWithMessagesIdArray:jsonString WithXmppid:xmppId WithTo:xmppId WithReadFlag:4];
}

- (BOOL)sendReadStateWithMessagesIdArray:(NSString *)jsonString WithXmppid:(NSString *)xmppId WithTo:(NSString *)to WithReadFlag:(NSInteger)readFlag {
    if (jsonString && [jsonString length] > 0) {
        NSString *readFlagStr = @"3";
        if (readFlag == 4) {
            readFlagStr = @"4";
        } else if (readFlag == 7) {
            readFlagStr = @"7";
        } else {
            readFlagStr = @"3";
        }
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageId:[QIMPBStream generateUUID]];
        [msgBuilder setMessageType:MessageTypeMessageTypeText];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:jsonString];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"read_type"] setValue:readFlagStr] build]];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:xmppId] build]];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeReadmark];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:to];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

- (BOOL)sendReadStateWithMessageTime:(long long)time groupName:(NSString *)groupName WithDomain:(NSString *)domain {
    if (time > 0 && [groupName length] > 0) {
        NSString *value = [NSString stringWithFormat:@"[{\"id\":\"%@\",\"domain\":\"%@\",\"t\":%lld}]", groupName, domain, time];
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageId:[QIMPBStream generateUUID]];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageType:MessageTypeMessageTypeText];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:value];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"read_type"] setValue:@"2"] build]];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:[NSString stringWithFormat:@"%@@%@", groupName, domain]] build]];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeReadmark];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:[[_pbXmppStream myJID] bare]];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

- (void)sendNotifyPresenceMsg:(NSDictionary *)msgDict ToJid:(NSString *)tojid {
    
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setDefinedKey:PresenceKeyTypePresenceKeyNotify];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setValue:@"notify"];
    int categoryType = [[msgDict objectForKey:@"PresenceMsgType"] intValue];
    [builder setCategoryType:categoryType];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    NSString *msgBody = [msgDict objectForKey:@"PresenceMsg"];
    [bodyBuilder setValue:msgBody];
    [builder setBody:[bodyBuilder build]];
    [_pbXmppStream sendPresenceMessage:[builder build] ToJid:tojid];
}

#pragma mark - 发送共享位置消息

- (BOOL)sendShareLocationMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType WithChatId:(NSString *)chatId OutMsgRaw:(NSString **)msgRaw {
    if (message.length > 0) {
        
        message = [self checkXmlmessage:message];
        
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageId:msgId];
        [msgBuilder setMessageType:msgType];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:msgId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:message];
        if (chatId) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"chatid"] setValue:chatId] build]];
        }
        if (info.length > 0) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:info] build]];
        }
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeShareLocation];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

- (BOOL)sendShareLocationMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType WithChatId:(NSString *)chatId {
    return [self sendShareLocationMessage:message WithInfo:info toJid:jid WithMsgId:msgId WithMsgType:msgType WithChatId:chatId OutMsgRaw:nil];
}

#pragma mark - 发送公众号消息

- (BOOL)sendPublicNumberMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)jid WithMsgId:(NSString *)msgId WithMsgType:(int)msgType {
    if (message.length > 0) {
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageId:msgId];
        [msgBuilder setMessageType:msgType];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:msgId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:message];
        if (info.length > 0) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:info] build]];
        }
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeSubscription];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

#pragma mark - 发送单人消息

/**
 创建单人MessageBuilder
 
 @param messageDict 消息体字典，现用现解析
 */
- (ProtoMessageBuilder *)createChatMessageBuilderWithMsgDict:(NSDictionary *)messageDict {
    NSString *message = [messageDict objectForKey:@"MessageBody"];
    NSString *msgId = [messageDict objectForKey:@"MessageId"];
    NSString *extendInfo = [messageDict objectForKey:@"MessageExtendInfo"];
    SInt32 msgType = [[messageDict objectForKey:@"MessageType"] intValue];
    NSString *chatId = [messageDict objectForKey:@"MessageChatId"];
    NSString *backupInfo = [messageDict objectForKey:@"MessageBackUpInfo"];
    NSString *channelInfo = [messageDict objectForKey:@"MessageChannelInfo"];
    NSString *toJid = [messageDict objectForKey:@"ToJid"];
    NSDictionary *appendInfoDict = [messageDict objectForKey:@"MessageAppendInfoDict"];
    //创建MessageBuild
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setMessageId:msgId];
    [msgBuilder setMessageType:msgType];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    
    //创建BodyBuild
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:message];
    if (chatId.length > 0) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"chatid"] setValue:chatId] build]];
    }
    if (extendInfo.length > 0) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:extendInfo] build]];
    }
    if (backupInfo.length > 0) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"backupinfo"] setValue:backupInfo] build]];
    }
    if (channelInfo) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"channelid"] setValue:channelInfo] build]];
    }
    if (appendInfoDict.count > 0) {
        
        for (NSString *appendInfoKey in appendInfoDict.allKeys) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:appendInfoKey] setValue:[appendInfoDict objectForKey:appendInfoKey]] build]];
        }
    }
    [msgBuilder setBody:[bodyBuilder build]];
    
    //创建ProtoMessageBuilder
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeChat];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:toJid];
    [builder setMessage:msgBuilder.build.data];
    
    return builder;
}


/**
 发送单人消息
 */
- (BOOL)sendChatMessageWithMsgDict:(NSDictionary *)messageDict {
    NSString *message = [messageDict objectForKey:@"MessageBody"];
    NSString *toJid = [messageDict objectForKey:@"ToJid"];
    if (message.length > 0 && toJid.length > 0) {
        message = [self checkXmlmessage:message];
        ProtoMessageBuilder *builder = [self createChatMessageBuilderWithMsgDict:messageDict];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

#pragma mark - 发送群消息

/**
 创建群MessageBuilder
 
 @param messageDict 消息体字典，现用现解析
 */
- (ProtoMessageBuilder *)createGroupMessageBuilderWithMsgDict:(NSDictionary *)messageDict {
    
    /*
     [messageDict setQIMSafeObject:msg.message forKey:@"MessageBody"];
     [messageDict setQIMSafeObject:msg.messageId forKey:@"MessageId"];
     [messageDict setQIMSafeObject:msg.extendInformation forKey:@"MessageExtendInfo"];
     [messageDict setQIMSafeObject:@(msg.messageType) forKey:@"MessageType"];
     [messageDict setQIMSafeObject:[self getChatIdByUserId:userId] forKey:@"ChatId"];
     [messageDict setQIMSafeObject:msg.to forKey:@"ToJid"];
     */
    
    NSString *message = [messageDict objectForKey:@"MessageBody"];
    NSString *msgId = [messageDict objectForKey:@"MessageId"];
    NSString *extendInfo = [messageDict objectForKey:@"MessageExtendInfo"];
    SInt32 msgType = [[messageDict objectForKey:@"MessageType"] intValue];
    NSString *chatId = [messageDict objectForKey:@"ChatId"];
    NSString *backupInfo = [messageDict objectForKey:@"MessageBackUpInfo"];
    NSString *toJid = [messageDict objectForKey:@"ToJid"];
    //创建MessageBuild
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setMessageId:msgId];
    [msgBuilder setMessageType:msgType];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    
    //创建BodyBuild
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:message];
    if (chatId.length > 0) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"chatid"] setValue:chatId] build]];
    }
    if (extendInfo.length > 0) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:extendInfo] build]];
    }
    if (backupInfo.length > 0) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"backupinfo"] setValue:backupInfo] build]];
        //新艾特消息
        [msgBuilder setMessageType:MessageTypeMessageTypeGroupAt];
    }
    [msgBuilder setBody:[bodyBuilder build]];
    
    //创建ProtoMessageBuilder
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeGroupChat];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:toJid];
    [builder setMessage:msgBuilder.build.data];
    
    return builder;
}


/**
 发送群消息
 */
- (BOOL)sendGroupMessageWithMessageDict:(NSDictionary *)messageDict {
    NSString *message = [messageDict objectForKey:@"MessageBody"];
    NSString *toJid = [messageDict objectForKey:@"ToJid"];
    if (message.length > 0 && toJid.length > 0) {
        message = [self checkXmlmessage:message];
        ProtoMessageBuilder *builder = [self createGroupMessageBuilderWithMsgDict:messageDict];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

- (BOOL)revokeMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid {
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setMessageType:MessageTypeMessageTypeRevoke];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    [msgBuilder setMessageId:msgId];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:message];
    [msgBuilder setBody:[bodyBuilder build]];
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeRevoke];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:jid];
    [builder setMessage:msgBuilder.build.data];
    PBXMPPReceipt *receipt = nil;
    [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    return [receipt wait:3000];
}


- (BOOL)revokeGroupMessageId:(NSString *)msgId WithMessage:(NSString *)message ToJid:(NSString *)jid {
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setMessageType:MessageTypeMessageTypeRevoke];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    [msgBuilder setMessageId:msgId];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:message];
    [msgBuilder setBody:[bodyBuilder build]];
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeRevoke];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:jid];
    [builder setMessage:msgBuilder.build.data];
    PBXMPPReceipt *receipt = nil;
    [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    return [receipt wait:3000];
}

- (BOOL)sendReplyMessageId:(NSString *)replyMsgId WithReplyUser:(NSString *)replyUser WithMessageId:(NSString *)msgId WithMessage:(NSString *)message ToGroupId:(NSString *)groupId OutMsgRaw:(NSString **)msgRaw {
    XmppMessageBuilder *msgBuilder = [XmppMessage builder];
    [msgBuilder setMessageId:msgId];
    [msgBuilder setMessageType:MessageTypeMessageTypeReply];
    [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
    [msgBuilder setClientVersion:0];
    [msgBuilder setMessageId:msgId];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    [bodyBuilder setValue:message];
    if (replyMsgId) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"replyMsgId"] setValue:replyMsgId] build]];
    }
    if (replyUser) {
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"replyUser"] setValue:replyUser] build]];
    }
    [msgBuilder setBody:[bodyBuilder build]];
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypeGroupChat];
    [builder setFrom:[[_pbXmppStream myJID] full]];
    [builder setTo:groupId];
    [builder setMessage:msgBuilder.build.data];
    PBXMPPReceipt *receipt = nil;
    [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    return [receipt wait:3000];
}

- (BOOL)sendReplyMessageId:(NSString *)replyMsgId WithReplyUser:(NSString *)replyUser WithMessageId:(NSString *)msgId WithMessage:(NSString *)message ToGroupId:(NSString *)groupId {
    return [self sendReplyMessageId:replyMsgId WithReplyUser:replyUser WithMessageId:msgId WithMessage:message ToGroupId:groupId OutMsgRaw:nil];
}

- (BOOL)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)message WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid realFromJid:(NSString *)realFromJid channelInfo:(NSString *)channelInfo WithAppendInfoDict:(NSDictionary *)appendInfoDict chatId:(NSString *)chatId WithMsgTYpe:(int)msgType OutMsgRaw:(NSString **)msgRaw{
    if (message.length > 0) {
        
        message = [self checkXmlmessage:message];
        
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageId:msgId];
        [msgBuilder setMessageType:msgType];
        [msgBuilder setClientType:self.isFromMac?MachineTypeMac:MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:msgId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:message];
        if (chatId) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"qchatid"] setValue:chatId] build]];
        }
        if (channelInfo) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"channelid"] setValue:channelInfo] build]];
        }
        if (appendInfoDict.count > 0) {
            
            for (NSString *appendInfoKey in appendInfoDict.allKeys) {
                [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:appendInfoKey] setValue:[appendInfoDict objectForKey:appendInfoKey]] build]];
            }
        }
        if (info.length > 0) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:info] build]];
        }
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeConsult];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:toJid];
        [builder setRealfrom:realFromJid?realFromJid:[[_pbXmppStream myJID] bare]];
        [builder setRealto:realToJid];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
        return [receipt wait:3000];
    }
    return NO;
}

#pragma mark - Share Location

- (BOOL)joinShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType {
    for (NSString *jid in users) {
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageType:msgType];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:shareLocationId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:@"Join Share Location"];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeShareLocation];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        [_pbXmppStream sendProtobufMessage:[builder build]];
    }
    return YES;
}

- (BOOL)sendMyLocationToUsers:(NSArray *)users WithLocationInfo:(NSString *)locationInfo ByShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType {
    for (NSString *jid in users) {
        if (locationInfo.length > 0) {
            locationInfo = [self checkXmlmessage:locationInfo];
            XmppMessageBuilder *msgBuilder = [XmppMessage builder];
            [msgBuilder setMessageType:msgType];
            [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
            [msgBuilder setClientVersion:0];
            [msgBuilder setMessageId:shareLocationId];
            MessageBodyBuilder *bodyBuilder = [MessageBody builder];
            [bodyBuilder setValue:locationInfo];
            [msgBuilder setBody:[bodyBuilder build]];
            ProtoMessageBuilder *builder = [ProtoMessage builder];
            [builder setSignalType:SignalTypeSignalTypeShareLocation];
            [builder setFrom:[[_pbXmppStream myJID] full]];
            [builder setTo:jid];
            [builder setMessage:msgBuilder.build.data];
            [_pbXmppStream sendProtobufMessage:[builder build]];
        }
        return YES;
    }
    return YES;
}

- (BOOL)quitShareLocationToUsers:(NSArray *)users WithShareLocationId:(NSString *)shareLocationId WithMsgType:(int)msgType {
    for (NSString *jid in users) {
        
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageType:msgType];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:shareLocationId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:@"Quit Share Location"];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeShareLocation];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        [_pbXmppStream sendProtobufMessage:[builder build]];
    }
    return YES;
}

#pragma mark - group method

// 获取群成员
- (NSArray *)getChatRoomMembersForGroupId:(NSString *)groupId {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"GET_MUC_USER"];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"] && [result.body.value isEqualToString:@"error_info"] == NO) {
        NSMutableArray *results = [NSMutableArray array];
        for (MessageBody *body in result.bodys) {
            NSDictionary *keyValues = [result getHeadersDicForHeaders:body.headers];
            NSString *memberJid = [keyValues objectForKey:@"jid"];
            NSString *affiliation = [keyValues objectForKey:@"affiliation"];
            if (affiliation.length <= 0) {
                affiliation = @"none";
            }
            NSString *nickName = [keyValues objectForKey:@"name"];
            if (nickName.length <= 0) {
                NSDictionary *infoDic = [[IMDataManager sharedInstance] selectUserByJID:memberJid];
                if ((self.productType == 0 && [memberJid rangeOfString:self.domain].location != NSNotFound) || (self.productType == 1 && [memberJid rangeOfString:self.domain].location == NSNotFound)) {
                    nickName = [infoDic objectForKey:@"Name"];
                }
                
                if (nickName.length <= 0) {
                    nickName = [memberJid componentsSeparatedByString:@"@"].firstObject;
                }
                
            }
            NSMutableDictionary *memberInfo = [NSMutableDictionary dictionary];
            [memberInfo setObject:affiliation forKey:@"affiliation"];
            [memberInfo setObject:nickName forKey:@"name"];
            [memberInfo setObject:memberJid forKey:@"jid"];
            [results addObject:memberInfo];
        }
        return results;
    }
    return nil;
}

- (NSArray *)getChatRoomList {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"USER_MUCS"];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:[NSString stringWithFormat:@"conference.%@", self.domain]];
    if ([result.key isEqualToString:@"result"] && [result.body.value isEqualToString:@"error_info"] == NO) {
        NSMutableArray *results = [NSMutableArray array];
        for (MessageBody *body in result.bodys) {
            NSDictionary *keyValues = [result getHeadersDicForHeaders:body.headers];
            NSString *name = [keyValues objectForKey:@"name"];
            NSString *host = [keyValues objectForKey:@"host"];
            if (name && name) {
                [results addObject:[NSString stringWithFormat:@"%@@%@", name, host]];
            }
        }
        return results;
    } else {
        
    }
    return nil;
}

- (BOOL)createRoom:(NSString *)roomName {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"CREATE_MUC"];
    [builder setValue:[NSString stringWithFormat:@"%@@conference.%@", [roomName lowercaseString], [self domain]]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:[NSString stringWithFormat:@"conference.%@", [self domain]]];
    if ([result.key isEqualToString:@"result"] && [result.body.value isEqualToString:@"success"]) {
        return YES;
    }
    return NO;
}

- (NSArray *)inviteGroupMembers:(NSArray *)members ToGroupId:(NSString *)groupId {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"MUC_INVITE_V2"];
    for (NSString *jid in members) {
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:@"invite"];
        [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"jid"] setValue:jid] build]];
        [builder addBodys:[bodyBuilder build]];
    }
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        NSMutableArray *resultList = [NSMutableArray array];
        for (MessageBody *body in result.bodys) {
            NSDictionary *keyValues = [result getHeadersDicForHeaders:body.headers];
            NSString *jid = [keyValues objectForKey:@"jid"];
            NSString *status = [keyValues objectForKey:@"status"];
            if ([status isEqualToString:@"0"] == NO) {
                [resultList addObject:jid];
            }
        }
        return resultList;
    }
    // 如果没反成功就全失败了
    return members;
}

- (BOOL)registerJoinGroup:(NSString *)groupId {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"SET_MUC_USER"];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        return YES;
    }
    return NO;
}

- (BOOL)quitGroupDelRegister:(NSString *)groupId {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"DEL_MUC_USER"];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        return YES;
    }
    return NO;
}

- (BOOL)setGroupId:(NSString *)groupId WithAdminNickName:(NSString *)nickName ForJid:(NSString *)memberJid {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"SET_ADMIN"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"read_jid"] setValue:memberJid] build]];
    [headerList addObject:[[[[StringHeader builder] setKey:@"nick"] setValue:nickName] build]];
    [headerList addObject:[[[[StringHeader builder] setKey:@"affiliation"] setValue:@"admin"] build]];
    [bodyBuilder setHeadersArray:headerList];
    [bodyBuilder setValue:@"item"];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        return YES;
    }
    return NO;
}

- (BOOL)setGroupId:(NSString *)groupId WithMemberNickName:(NSString *)nickName ForJid:(NSString *)memberJid {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"SET_MEMBER"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"read_jid"] setValue:memberJid] build]];
    [headerList addObject:[[[[StringHeader builder] setKey:@"nick"] setValue:nickName] build]];
    [headerList addObject:[[[[StringHeader builder] setKey:@"affiliation"] setValue:@"member"] build]];
    [bodyBuilder setHeadersArray:headerList];
    [bodyBuilder setValue:@"item"];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        return YES;
    }
    return NO;
}

- (BOOL)removeGroupId:(NSString *)groupId ForMemberJid:(NSString *)memberJid WithNickName:(NSString *)nickName {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"CANCEL_MEMBER"];
    MessageBodyBuilder *bodyBuilder = [MessageBody builder];
    NSMutableArray *headerList = [NSMutableArray array];
    [headerList addObject:[[[[StringHeader builder] setKey:@"read_jid"] setValue:memberJid] build]];
    [headerList addObject:[[[[StringHeader builder] setKey:@"nick"] setValue:nickName] build]];
    [headerList addObject:[[[[StringHeader builder] setKey:@"role"] setValue:@"none"] build]];
    [bodyBuilder setHeadersArray:headerList];
    [bodyBuilder setValue:@"item"];
    [builder setBody:[bodyBuilder build]];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        return YES;
    }
    return NO;
}

- (BOOL)destoryChatRoom:(NSString *)groupId {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setKey:@"DESTROY_MUC"];
    [builder setValue:groupId];
    IQMessage *result = [_pbXmppStream syncIQMessage:[builder build] ToJid:groupId];
    if ([result.key isEqualToString:@"result"]) {
        NSDictionary *keyVaules = [result getHeadersDicForHeaders:result.body.headers];
        return [[[keyVaules objectForKey:@"result"] lowercaseString] isEqualToString:@"success"];
    }
    return NO;
}

@end

#pragma mark - message archiving delegate

@implementation QIMPBStream (XMPPMessageArchiving)

/*
 - (BOOL)configureWithParent:(XMPPMessageArchiving *)aParent queue:(dispatch_queue_t)queue {
 return YES;
 }
 
 - (void)archiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)stream {
 
 //    QIMVerboseLog(@"%@", message);
 }
 */
@end

#pragma mark - XMPP delegate

@implementation QIMPBStack (XMPPStreamDelegate)

- (void)pbXmppStreamDidRegister:(QIMPBStream *)sender {
    if ([self.delegate respondsToSelector:@selector(registerSuccess)]) {
        [self.delegate registerSuccess];
    }
}

- (void)pbXmppStream:(QIMPBStream *)sender didNotRegister:(id)error {
    QIMVerboseLog(@"you did not Register:%@", error);
    if ([self.delegate respondsToSelector:@selector(registerFaild:)]) {
        [self.delegate registerFaild:[error description]];
    }
}

#pragma mark - 记日志

- (void)pbXmppStream:(QIMPBStream *)sender didSendIQ:(id)iq {
    QIMVerboseLog(@"didSendIQ %@", iq);
}

- (void)pbXmppStream:(QIMPBStream *)sender didFailToSendIQ:(id)iq error:(NSError *)error {
    QIMVerboseLog(@"didFailToSendIQ %@, error: %@", iq, error);
}

- (void)pbXmppStream:(QIMPBStream *)sender didFailToSendPresence:(id)presence error:(NSError *)error {
    QIMVerboseLog(@"didFailToSendPresence %@, error: %@", presence, error);
}

- (void)pbXmppStream:(QIMPBStream *)sender didSendPresence:(id)presence {
    QIMVerboseLog(@"didSendPresence %@", presence);
}

- (void)pbXmppStream:(QIMPBStream *)sender didSendMessage:(id)message {
    QIMVerboseLog(@"message has sent:%@", message);
}

- (void)pbXmppStreamWillConnect:(QIMPBStream *)sender {
    QIMVerboseLog(@"pbXmppStreamWillConnect");
    [[self delegate] beginToConnect];
}

- (void)pbXmppStreamConnectDidTimeout:(QIMPBStream *)sender {
    QIMVerboseLog(@"pbXmppStreamConnectDidTimeout");
    NSError *error = nil;
    [self connectWithTimeout:8 withError:&error];
    if ([self.delegate respondsToSelector:@selector(connectTimeOut)]) {
        [self.delegate connectTimeOut];
    }
}

- (void)pbXmppStreamDidConnect:(QIMPBStream *)sender {
    QIMVerboseLog(@"%s", __func__);
    NSError *error = nil;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    QIMVerboseLog(@"xmppStreamDidConnect :%f", now);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XmppstackConnectedTimes"
                                                        object:@(now - _beginTime)];
    QIMVerboseLog(@"connected! escaped time is %f", now - _beginTime);
    
    [_pbXmppStream cancelAllIQMessage];
    
    if ([[self delegate] respondsToSelector:@selector(connected)]) {
        [[self delegate] connected];
    }
    
    //    if (_connectTimer != NULL) {
    //        dispatch_cancel(_connectTimer);
    //        dispatch_release(_connectTimer);
    //        _connectTimer = NULL;
    //    }
    //
    //    _connectTimer = dispatch_source_create(
    //                                           DISPATCH_SOURCE_TYPE_TIMER,
    //                                           0,
    //                                           0,
    //                                           _xmppQueue);
    //
    //    dispatch_source_set_timer(_connectTimer,
    //                              dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
    //                              //                              dispatch_walltime(NULL, 0),
    //                              DISPATCH_TIME_FOREVER,
    //                              1 * NSEC_PER_SEC); //每10秒触发timer，误差1秒
    //
    //    dispatch_source_set_event_handler(_connectTimer, ^{
    //#warning QIMPBStream 缺少Disconnect实现 不知道有什么用
    //        [sender disconnectWithError:[NSError errorWithDomain:@"com.qunar.qtalkfamily" code:111 userInfo:nil]];
    //    });
    
    //    dispatch_resume(_connectTimer);
    
    //    if (self.isRegister) {
    //        [stream registerWithPassword:self.password error:&error];
    //    } else {
    //        [stream authenticateWithPassword:[self password] error:&error];
    //    }
}

- (void)pbXmppStreamDidAuthenticate:(QIMPBStream *)sender {
    if (_connectTimer != NULL) {
        dispatch_cancel(_connectTimer);
        _connectTimer = NULL;
    }
    QIMVerboseLog(@"QIMPBStreamDidAuthenticate :%f", [[NSDate date] timeIntervalSince1970]);
    [self goOnlineWithXmppStream:sender];
}

- (void)pbXmppStream:(QIMPBStream *)sender didNotAuthenticate:(ProtoMessage *)pError {
    if (_connectTimer != NULL) {
        dispatch_cancel(_connectTimer);
        _connectTimer = NULL;
    }
    QIMVerboseLog(@"didNotAuthenticate:%@", pError);
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(loginFaildWithErrCode:WithErrMsg:)]) {
        ResponseFailure *authMsg = [ResponseFailure parseFromData:[pError message]];
        NSString *error = authMsg.error;
        NSString *errMsg = nil;
        NSString *errCode = [NSString stringWithFormat:@"%d", (int)authMsg.code];
        if ([error isEqualToString:@"not-authorized"]) {
            errMsg = @"out_of_date";
        } else if ([error isEqualToString:@"out_of_date"]) {
            errMsg = @"out_of_date";
        } else if ([error isEqualToString:@"frozen-in"]) {
            errMsg = @"登陆帐号异常。";
        }
        if (errCode == nil) {
            errCode = @"";
        }
        if (errMsg == nil) {
            errMsg = @"登陆客户端失败。";
        }
        [[self delegate] loginFaildWithErrCode:errCode WithErrMsg:errMsg];
    }
}

- (BOOL)pbXmppStream:(QIMPBStream *)sender didReceiveIQ:(id)iq {
    QIMVerboseLog(@"%s, %@", __func__, iq);
    return YES;
}

- (void)pbXmppStream:(QIMPBStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    QIMVerboseLog(@"willSecureWithSettings, %@", settings);
 
    settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
    
}

- (void)pbXmppStreamDidSecure:(QIMPBStream *)sender {
    QIMVerboseLog(@"xmppStreamDidSecure");
    NSError *error = nil;
    QIMPBStream *stream = sender;
    
    [stream authenticateWithPassword:[self password] error:&error];
}

#pragma mark - 错误处理、断连

- (void)pbXmppStream:(QIMPBStream *)sender didReceiveError:(id)error {
    QIMVerboseLog(@"xmppStream didReceiveError");
}

- (void)pbXmppStream:(QIMPBStream *)sender didFailToSendMessage:(ProtoMessage *)message error:(NSError *)error {
    @try {
        if (message.signalType == SignalTypeSignalTypeChat || message.signalType == SignalTypeSignalTypeGroupChat || message.signalType == SignalTypeSignalTypeSubscription || message.signalType == SignalTypeSignalTypeCollection) {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:message.message];
            NSString *msgId = [xmppMessage messageId];
            if (msgId) {
                NSDictionary *messageInfo = @{@"messageId": msgId};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kXmppStreamSendMessageFailed" object:messageInfo];
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)pbXmppStreamDidDisconnect:(QIMPBStream *)sender withError:(NSError *)error {
    QIMVerboseLog(@"pbXmppStreamDidDisconnect %@", error);
    if (_connectTimer != NULL) {
        dispatch_cancel(_connectTimer);
//        dispatch_release(_connectTimer);
        _connectTimer = NULL;
    }
    [[self delegate] disconnectedEvent];
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(onDisconnect)]) {
        [[self delegate] onDisconnect];
    }
    
    //    if (_compression) {
    //        [_compression deactivate];
    //    }
    
    //
    // 如果error 为空，强制认定是本地操作
    QIMVerboseLog(@"pbXmppStreamDidDisconnect ErrCode : %d", error.code);
    if (error) {
        if ([[error domain] isEqualToString:@"com.qunar.qtalkfamily"]) {
            QIMVerboseLog(@"pbXmppStreamDidDisconnect connectWithTimeout %@", @"com.qunar.qtalkfamily");
            [self connectWithTimeout:10 withError:&error];
        } else if (error.code == -9806) {
            //Error Domain=GCDAsyncSocketErrorDomain Code=7 "Socket closed by remote peer"
            //pbXmppStreamDidDisconnect Error Domain=kCFStreamErrorDomainSSL Code=-9806 "(null)" UserInfo={NSLocalizedRecoverySuggestion=Error code definition can be found in Apple's SecureTransport.h
            QIMVerboseLog(@"碰到9806，重试");
            [self connectWithTimeout:10 withError:&error];
        } else {
            QIMVerboseLog(@"cancelLogin");
            [self cancelLogin];
        }
    }
}

#pragma mark -服务器控制客户端指令

- (void)pbXmppStream:(QIMPBStream *)sender didReceivePresenceKeyNotify:(PresenceMessage *)pMessage {
    QIMVerboseLog(@"didReceive指令消息 : %@", pMessage);
    @autoreleasepool {
        MessageBody *body = pMessage.body;
        NSString *bodyValue = body.value;
        if ([self delegate] && [self.delegate respondsToSelector:@selector(receiveKeyNotiyPresenceFromCatrgoryType:WithPresenceBodyValue:)]) {
            [self.delegate receiveKeyNotiyPresenceFromCatrgoryType:pMessage.categoryType WithPresenceBodyValue:bodyValue];
        }
    }
}

#pragma mark - 状态变更

- (void)pbXmppStream:(QIMPBStream *)sender didReceivePresence:(ProtoMessage *)pMessage {
    
    QIMVerboseLog(@"didReceivePresence \n %@", pMessage);
    @autoreleasepool {
        QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
        if (destJid) {
            PresenceMessage *presence = [PresenceMessage parseFromData:pMessage.message];
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(presence), [presence description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSString *key = [presence key];
            NSString *value = [presence value];
            if ([value isEqualToString:@"user_join_muc"]) {
                // 加入群通知
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *jid = [keyValues objectForKey:@"jid"];
                NSString *name = [destJid resource];
                NSString *affiliation = [keyValues objectForKey:@"affiliation"];
                NSString *domain = [keyValues objectForKey:@"domain"];
                jid = [NSString stringWithFormat:@"%@@%@", jid, domain];
                if ([[self chatRoomDelegate] respondsToSelector:@selector(pbChatRoom:WithAddJid:WithAffiliation:WithDomain:WithName:)]) {
                    [[self chatRoomDelegate] pbChatRoom:destJid.bare WithAddJid:jid WithAffiliation:affiliation WithDomain:domain WithName:name];
                }
            } else if ([value isEqualToString:@"invite_user"]) {
                // 邀请消息
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *inviteJid = [keyValues objectForKey:@"invite_jid"];
                NSString *status = [keyValues objectForKey:@"status"];
                if ([[self chatRoomDelegate] respondsToSelector:@selector(pbChatRoom:WithInviteUser:WithStatus:)]) {
                    [[self chatRoomDelegate] pbChatRoom:destJid.bare WithInviteUser:inviteJid WithStatus:status];
                }
            } else if ([value isEqualToString:@"destory_muc"]) {
                // 群销毁通知
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                if ([[self chatRoomDelegate] respondsToSelector:@selector(pbChatRoomDestory:)]) {
                    [[self chatRoomDelegate] pbChatRoomDestory:destJid.bare];
                }
            } else if ([value isEqualToString:@"del_muc_user"]) {
                // 群成员删除
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *memberJid = [keyValues objectForKey:@"del_jid"];
                NSString *affiliation = [keyValues objectForKey:@"affiliation"];
                NSString *role = [keyValues objectForKey:@"role"];
                NSString *code = [keyValues objectForKey:@"code"];
                if ([[self chatRoomDelegate] respondsToSelector:@selector(pbChatRoom:WithDelMemberJid:WithAffiliation:WithRole:WithCode:)]) {
                    [[self chatRoomDelegate] pbChatRoom:destJid.bare WithDelMemberJid:memberJid WithAffiliation:affiliation WithRole:role WithCode:code];
                }
            } else if ([value isEqualToString:@"update_muc_vcard"]) {
                // 群名片变更
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *nickName = [keyValues objectForKey:@"nick"];
                NSString *title = [keyValues objectForKey:@"title"];
                NSString *picUrl = [keyValues objectForKey:@"pic"];
                NSString *version = [keyValues objectForKey:@"version"];
                if ([[self chatRoomDelegate] respondsToSelector:@selector(pbChatRommUpdateCard:WithNickName:WithTitle:WithPicUrl:WithVersion:)]) {
                    [[self chatRoomDelegate] pbChatRommUpdateCard:destJid.bare WithNickName:nickName WithTitle:title WithPicUrl:picUrl WithVersion:version];
                }
            } else if ([value isEqualToString:@"del_muc_register"]) {
                // 被T通知
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *memberJid = [keyValues objectForKey:@"del_jid"];
                if ([[self chatRoomDelegate] respondsToSelector:@selector(pbChatRomm:WithDelRegJid:)]) {
                    [[self chatRoomDelegate] pbChatRomm:destJid.bare WithDelRegJid:memberJid];
                }
            } else if ([value isEqualToString:@"update_user_status"]) {
                // 用户状态变更
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *show = [keyValues objectForKey:@"show"];
                NSString *priority = [keyValues objectForKey:@"priority"];
                if ([[self delegate] respondsToSelector:@selector(pbUserStatusChange:WithShow:WithPriority:)]) {
                    [[self delegate] pbUserStatusChange:destJid.bare WithShow:show WithPriority:priority];
                }
            } else if ([value isEqualToString:@"verify_friend"]) {
                // 验证好友返回
                QIMXMPPJID *toJid = [QIMXMPPJID jidWithString:pMessage.to];
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *type = [keyValues objectForKey:@"type"];
                NSString *result = [keyValues objectForKey:@"result"];
                NSString *reason = [keyValues objectForKey:@"reason"];
                if ([[self delegate] respondsToSelector:@selector(verifyFriendPresenceWithFrom:WithTo:WihtDirection:WithResult:WithReason:)]) {
                    [[self delegate] verifyFriendPresenceWithFrom:destJid.bare WithTo:toJid.bare WihtDirection:2 WithResult:result WithReason:reason];
                }
            } else if ([value isEqualToString:@"confirm_verify_friend"]) {
                // 人工验证好友
                QIMXMPPJID *toJid = [QIMXMPPJID jidWithString:pMessage.to];
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *type = [keyValues objectForKey:@"type"];
                NSString *reason = [keyValues objectForKey:@"reason"];
                if ([[self delegate] respondsToSelector:@selector(validationFriendFromUserId:WithBody:)]) {
                    [[self delegate] validationFriendFromUserId:destJid.bare WithBody:reason];
                }
            } else if ([value isEqualToString:@"delete_friend"]) {
                // 验证好友返回
                QIMXMPPJID *toJid = [QIMXMPPJID jidWithString:pMessage.to];
                NSDictionary *keyValues = [presence getHeadersDicForHeaders:presence.body.headers];
                NSString *type = [keyValues objectForKey:@"type"];
                NSString *result = [keyValues objectForKey:@"result"];
                if ([result isEqualToString:@"success"]) {
                    NSString *userId = [keyValues objectForKey:@"jid"];
                    NSString *domain = [keyValues objectForKey:@"domain"];
                    NSString *jid = [NSString stringWithFormat:@"%@@%@", userId, domain];
                    if ([[self delegate] respondsToSelector:@selector(delFriend:)]) {
                        [[self delegate] delFriend:jid];
                    }
                }
            } else {
                QIMVerboseLog(@"不认识的Presence [%@]", value);
            }
        }
    }
}

#pragma mark - 消息处理

- (void)recordLog:(NSString *)log withDirection:(int)direction {
    if (log && [self.delegate respondsToSelector:@selector(messageLog:WithDirection:)]) {
        [self.delegate messageLog:log WithDirection:direction];
    }
}

- (void)pbXmppStream:(QIMPBStream *)sender didReceiveMessage:(ProtoMessage *)pMessage {
    switch (pMessage.signalType) {
        case SignalTypeSignalTypeConsult:
        {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *from = [destJid bare];
                NSString *realFrom = [pMessage realfrom];
                realFrom = [[QIMXMPPJID jidWithString:realFrom] bare];
                NSString *to = [pMessage to];
                to = [[QIMXMPPJID jidWithString:to] bare];
                NSString *realTo = [pMessage realto];
                realTo = [[QIMXMPPJID jidWithString:realTo] bare];
                NSString *msgRaw = [pMessage data];
                int platform = xmppMessage.clientType;
                int msgType = xmppMessage.messageType;
                NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
                NSString *msg = [xmppMessage.body value];
                NSString *msgId = [xmppMessage messageId];
                NSString *chatId = [keyValues objectForKey:@"qchatid"];
                if (chatId == nil) {
                    chatId = @"4";
                }
                NSString *autoReply = [keyValues objectForKey:@"auto_reply"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime/1000.0];
                if (msgId == nil) {
                    msgId = [date description];
                }
                
                BOOL carbonMessage = [[[keyValues objectForKey:@"carbon_message"] lowercaseString] isEqualToString:@"true"];
                NSString *sid = @"";
                if (carbonMessage == YES) {
                    if ([chatId isEqualToString:@"5"]) {
                        sid = [NSString stringWithFormat:@"%@-%@",from,realTo];
                        realFrom = realTo;
                    } else {
                        sid = [NSString stringWithFormat:@"%@-%@",from,from];
                    }
                } else {
                    if ([chatId isEqualToString:@"4"]) {
                        sid = [NSString stringWithFormat:@"%@-%@",from,realFrom];
                    } else {
                        sid = [NSString stringWithFormat:@"%@-%@",from,from];
                    }
                }
                if (msgId && realFrom && carbonMessage == NO) {
                    NSString * originMsgId = msgId;
                    if ([chatId isEqualToString:@"5"]) {
                        originMsgId = msgId;
                    } else {
                        originMsgId = [msgId stringByReplacingOccurrencesOfString:@"consult-" withString:@""];
                    }
                    NSArray *array = @[@{@"id": originMsgId?originMsgId:@""}];
                    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonArray = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSInteger readFlag = 3;
                    [self sendReadStateWithMessagesIdArray:jsonArray WithXmppid:realFrom WithTo:realFrom WithReadFlag:readFlag];
                }
                NSString *buAppendKey = @"bu";
                NSString *cctextAppendKey = @"cctext";
                NSString *buInfo = [keyValues objectForKey:buAppendKey];
                NSString *cctextInfo = [keyValues objectForKey:cctextAppendKey];
                if (buInfo.length > 0 && sid.length > 0) {
                    if ([self.delegate respondsToSelector:@selector(updateAppendInfo:WithAppendKey:ForUserId:)]) {
                        [self.delegate updateAppendInfo:buInfo WithAppendKey:buAppendKey ForUserId:sid];
                    }
                }
                if (cctextInfo.length > 0 && sid.length > 0) {
                    if ([self.delegate respondsToSelector:@selector(updateAppendInfo:WithAppendKey:ForUserId:)]) {
                        [self.delegate updateAppendInfo:cctextInfo WithAppendKey:cctextAppendKey ForUserId:sid];
                    }
                }
                SEL selector = @selector(onConsultMessageReceivedWithFromJid:realFrom:toJid:realToJid:isCarbon:messageType:platformType:message:messageId:stamp:extendInfo:chatId:msgRaw:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [self.delegate onConsultMessageReceivedWithFromJid:from realFrom:realFrom toJid:to realToJid:realTo isCarbon:(carbonMessage == YES) ? YES : NO messageType:msgType platformType:platform message:msg messageId:msgId stamp:date extendInfo:extendInfo chatId:chatId msgRaw:msgRaw];
                }
            }
            
        }
            break;
        case SignalTypeSignalTypeCarbon: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *channelInfo = [keyValues objectForKey:@"channelid"];
                if (channelInfo.length > 0) {
                    if ([self.delegate respondsToSelector:@selector(updateChannelInfo:ForUserId:)]) {
                        [self.delegate updateChannelInfo:channelInfo ForUserId:destJid.bare];
                    }
                }
                NSString *msgRaw = pMessage.data;
                NSString *autoReply = [keyValues objectForKey:@"auto_reply"];
                int platform = xmppMessage.clientType;
                int msgType = xmppMessage.messageType;
                NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
                NSString *msg = [xmppMessage.body value];
                NSString *msgId = [xmppMessage messageId];
                BOOL carbonMessage = YES;
                NSString *chatId = [keyValues objectForKey:@"chatid"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
                if (msgId == nil) {
                    msgId = [date description];
                }
                SEL selector = @selector(onMessageReceived:domain:messageType:platformType:message:originalMsg:messageId:direction:stamp:extendInfo:autoReply:chatId:msgRaw:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onMessageReceived:[destJid user]
                                                domain:[destJid domain]
                                           messageType:msgType
                                          platformType:platform
                                               message:msg
                                           originalMsg:nil
                                             messageId:msgId
                                             direction:(carbonMessage ? 2 : 1)
                                                 stamp:date
                                            extendInfo:extendInfo
                                             autoReply:autoReply
                                                chatId:chatId
                                                msgRaw:msgRaw];
                }
            }
            
        }
            break;
        case SignalTypeSignalTypeChat: {
            //
            // 二人消息
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                if ([self.delegate respondsToSelector:@selector(userResource:forJid:)]) {
                    [self.delegate userResource:destJid.resource forJid:destJid.bare];
                }
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *channelInfo = [keyValues objectForKey:@"channelid"];
                if (channelInfo.length > 0) {
                    if ([self.delegate respondsToSelector:@selector(updateChannelInfo:ForUserId:)]) {
                        [self.delegate updateChannelInfo:channelInfo ForUserId:destJid.bare];
                    }
                }
                
                NSString *buAppendKey = @"bu";
                NSString *cctextAppendKey = @"cctext";
                NSString *buInfo = [keyValues objectForKey:buAppendKey];
                NSString *cctextInfo = [keyValues objectForKey:cctextAppendKey];
                if (buInfo.length > 0) {
                    if ([self.delegate respondsToSelector:@selector(updateAppendInfo:WithAppendKey:ForUserId:)]) {
                        [self.delegate updateAppendInfo:buInfo WithAppendKey:buAppendKey ForUserId:destJid.bare];
                    }
                }
                if (cctextInfo.length > 0) {
                    if ([self.delegate respondsToSelector:@selector(updateAppendInfo:WithAppendKey:ForUserId:)]) {
                        [self.delegate updateAppendInfo:cctextInfo WithAppendKey:cctextAppendKey ForUserId:destJid.bare];
                    }
                }
                
                NSString *msgRaw = pMessage.data;
                NSString *autoReply = [keyValues objectForKey:@"auto_reply"];
                int platform = xmppMessage.clientType;
                int msgType = xmppMessage.messageType;
                NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
                NSString *msg = [xmppMessage.body value];
                NSString *msgId = [xmppMessage messageId];
                BOOL carbonMessage = [[[keyValues objectForKey:@"carbon_message"] lowercaseString] isEqualToString:@"true"];
                NSString *chatId = [keyValues objectForKey:@"chatid"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
                if (msgId == nil) {
                    msgId = [date description];
                }
                NSString *messageId = xmppMessage.messageId;
                //收到消息立马发已收到消息状态
                if (messageId && carbonMessage == NO) {
                    NSArray *array = @[@{@"id": messageId?messageId:@""}];
                    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonArray = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSInteger readFlag = 0x03;
                    [self sendReadStateWithMessagesIdArray:jsonArray WithXmppid:destJid.bare WithTo:destJid.bare WithReadFlag:readFlag];
                }
                
                if  (carbonMessage == NO && (msgType == MessageTypeWebRtcMsgTypeVideo || msgType == MessageTypeWebRtcMsgTypeAudio)){
                    if ([_pbXmppStream.myJID isEqualToJID:destJid] == NO && [self.delegate respondsToSelector:@selector(receiveCallAudioVideFromJid:WithResource:WithMsgType:)]) {
                        [self.delegate receiveCallAudioVideFromJid:destJid.bare WithResource:destJid.resource WithMsgType:msgType];
                    }
                }
                
                if (carbonMessage == NO && (msgType == MessageTypeWebRtcMsgTypeVideoMeeting)) {
                    if ([_pbXmppStream.myJID isEqualToJID:destJid] == NO && [self.delegate respondsToSelector:@selector(receiveMeetingAudioVideoConferenceFromJid:WithResource:WithMsgType:)]) {
                        [self.delegate receiveMeetingAudioVideoConferenceFromJid:destJid.bare WithResource:destJid.resource WithMsgType:msgType];
                    }
                }
                
                SEL selector = @selector(onMessageReceived:domain:messageType:platformType:message:originalMsg:messageId:direction:stamp:extendInfo:autoReply:chatId:msgRaw:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onMessageReceived:[destJid user]
                                                domain:[destJid domain]
                                           messageType:msgType
                                          platformType:platform
                                               message:msg
                                           originalMsg:nil
                                             messageId:msgId
                                             direction:(carbonMessage ? 2 : 1)
                                                 stamp:date
                                            extendInfo:extendInfo
                                             autoReply:autoReply
                                                chatId:chatId
                                                msgRaw:msgRaw];
                }
            }
        }
            break;
        case SignalTypeSignalTypeGroupChat: {
            //
            // 群消息
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                NSString *msgRaw = [pMessage data];
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSString *sendJid = [pMessage sendjid];
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *autoReply = [keyValues objectForKey:@"auto_reply"];
                int platform = xmppMessage.clientType;
                int msgType = xmppMessage.messageType;
                NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
                NSString *msg = [xmppMessage.body value];
                NSString *msgId = [xmppMessage messageId];
                BOOL carbonMessage = [[[keyValues objectForKey:@"carbon_message"] lowercaseString] isEqualToString:@"true"];
                NSString *chatId = [keyValues objectForKey:@"chatid"];
                NSString *replyMsgId = [keyValues objectForKey:@"replyMsgId"];
                NSString *replyUser = [keyValues objectForKey:@"replyUser"];
                NSString *backupInfo = [keyValues objectForKey:@"backupinfo"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
                if (msgId == nil) {
                    msgId = [date description];
                }
                SEL selector = @selector(onGroupMessageReceived:domain:sendJid:messageType:platformType:message:originalMsg:messageId:stamp:extendInfo:replyMsgId:replyUser:chatId:backupInfo:msgRaw:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onGroupMessageReceived:[destJid user]
                                                     domain:[destJid domain]
                                                    sendJid:sendJid
                                                messageType:msgType
                                               platformType:platform
                                                    message:msg
                                                originalMsg:nil
                                                  messageId:msgId
                                                      stamp:date
                                                 extendInfo:extendInfo
                                                 replyMsgId:replyMsgId
                                                  replyUser:replyUser
                                                     chatId:chatId
                                                 backupInfo:backupInfo
                                                     msgRaw:msgRaw];
                }
            }
        }
            break;
        case SignalTypeSignalTypeTyping: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (![[destJid resource] isEqualToString:[[_pbXmppStream myJID] resource]]) {
                if ([[self delegate] respondsToSelector:@selector(onTypingReceived:)]) {
                    [[self delegate] onTypingReceived:[destJid bare]];
                }
            }
        }
            break;
        case SignalTypeSignalTypeShareLocation: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSString *shareId = xmppMessage.messageId;
                int platform = xmppMessage.clientType;
                int msgType = xmppMessage.messageType;
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
                NSString *msg = [xmppMessage.body value];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
                SEL selector = @selector(onShareLocationMessageReceived:domain:shareId:messageType:platformType:message:stamp:extendInfo:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onShareLocationMessageReceived:[destJid user]
                                                             domain:[destJid domain]
                                                            shareId:shareId
                                                        messageType:msgType
                                                       platformType:platform
                                                            message:msg
                                                              stamp:date
                                                         extendInfo:extendInfo];
                }
            }
        }
            break;
        case SignalTypeSignalTypeReadmark: {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
            NSString *readType = [keyValues objectForKey:@"read_type"];
            BOOL carbonMessage = [[keyValues objectForKey:@"carbon_message"] boolValue];
            NSString *jid = [keyValues objectForKey:@"extendInfo"];
            /*群ReadMark
             {
             extendInfo = "1860101e80444e8082022fbc71ff58dd@conference.ejabhost1";
             "read_type" = 2;
             }
             */
            if (!jid) {
                NSString *userId = [[QIMXMPPJID jidWithString:pMessage.pb_from] user];
                NSString *domain = [[QIMXMPPJID jidWithString:pMessage.pb_from] domain];
                jid = [NSString stringWithFormat:@"%@@%@", userId, domain];
            }
            NSArray *jidComs = [jid componentsSeparatedByString:@";"];
            //@"chatType":@"group",
            if (jid.length > 0) {
                NSString *infoStr = [xmppMessage.body value];
                infoStr = [infoStr stringByReplacingOccurrencesOfString:@"consult-" withString:@""];
                SEL selector = @selector(onReadStateReceived:ForJid:infoStr:);
                if ([self delegate] && [[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onReadStateReceived:readType ForJid:jid infoStr:infoStr];
                }
            }
        }
            break;
        case SignalTypeSignalTypeHeadline: {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSString *context = [xmppMessage.body value];
            //        NSString *sub = [subject stringValue];
            NSString *msgId = [xmppMessage messageId];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
            if (msgId == nil) {
                msgId = [date description];
            }
            if (msgId == nil) {
                msgId = [date description];
            }
            NSString *msgRaw = [[pMessage description] copy];
            SEL selector = @selector(onSystemMsgReceived:messageId:stamp:msgRaw:);
            if ([self delegate] && [[self delegate] respondsToSelector:selector]) {
                [[self delegate] onSystemMsgReceived:context messageId:msgId stamp:date msgRaw:msgRaw];
            }
            
        }
            break;
        case SignalTypeSignalTypeNote: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSString *msg = [xmppMessage.body value];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
                if ([[self delegate] respondsToSelector:@selector(onQChatNoteReceived:from:stamp:)]) {
                    [[self delegate] onQChatNoteReceived:msg from:[destJid bare] stamp:date];
                }
            }
        }
            break;
        case SignalTypeSignalTypeRevoke: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSString *msg = [xmppMessage.body value];
                NSString *msgId = [xmppMessage messageId];
                if ([[self delegate] respondsToSelector:@selector(onRevokeReceived:messageId:message:)]) {
                    [[self delegate] onRevokeReceived:[destJid bare] messageId:msgId message:msg];
                }
            }
        }
            break;
        case SignalTypeSignalTypeSubscription: {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
            NSString *channelid = [keyValues objectForKey:@"channelid"];
            NSString *message = [xmppMessage.body value];
            int platform = [xmppMessage clientType];
            int msgType = [xmppMessage messageType];
            NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
            NSString *msgId = [xmppMessage messageId];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[xmppMessage receivedTime] / 1000.0];
            if (msgId == nil) {
                msgId = [date description];
            }
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@(platform) forKey:@"PlatformType"];
            [dic setObject:@(msgType) forKey:@"MsgType"];
            if (extendInfo) {
                [dic setObject:extendInfo forKey:@"extendInfo"];
            }
            if (msgId) {
                [dic setObject:msgId forKey:@"MsgId"];
            }
            if (message) {
                [dic setObject:message forKey:@"Message"];
            }
            if (channelid) {
                [dic setObject:channelid forKey:@"channelid"];
            }
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            [dic setObject:[destJid bare] forKey:@"PublicNumberId"];
            [dic setObject:date forKey:@"MsgDate"];
            
            if ([[self delegate] respondsToSelector:@selector(onReceivePublicNumberMsg:)]) {
                [[self delegate] onReceivePublicNumberMsg:dic];
            }
        }
            break;
        case SignalTypeSignalTypeMstate: {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSString *messageId = [xmppMessage messageId];
            long long receivedTime = [xmppMessage receivedTime];
            NSDictionary *messageInfo = @{@"messageId": messageId ? messageId : @"", @"receivedTime" : @(receivedTime)};
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kXmppStreamDidSendMessage" object:messageInfo];
            });
        }
            break;
        case SignalTypeSignalTypeTransfor: {
            QIMXMPPJID *fromJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (fromJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                { // Log
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSString *json = [xmppMessage.body value];
                int msgType = [xmppMessage messageType];
                if (msgType == 1003) {
                    NSString *msgId = [xmppMessage messageId];
                    if ([[self delegate] respondsToSelector:@selector(receiveChatTransferToUser:ForMsgId:)]) {
                        [[self delegate] receTransferChatWithFrom:[fromJid bare] WithMsgId:msgId];
                    }
                } else {
                    NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                    NSString *chatId = [keyValues objectForKey:@"chatid"];
                    NSString *msgId = [xmppMessage messageId];
                    if ([[self delegate] respondsToSelector:@selector(onTransferChatWithFrom:WithMsgType:WithChatId:WithMsgId:WithJson:)]) {
                        [[self delegate] onTransferChatWithFrom:[fromJid bare] WithMsgType:msgType WithChatId:chatId WithMsgId:msgId WithJson:json];
                    }
                }
            }
        }
            break;
        case SignalTypeSignalTypeWebRtc: {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
            NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
            if (extendInfo) {
                QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyAudioVideoMsgNotify" object:[destJid bare] userInfo:@{@"extendInfo": extendInfo}];
            }
        }
            break;
        case SignalTypeSignalTypeEncryption: {
            XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
            {
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            NSString *content = [[xmppMessage body] value];
            
            NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
            BOOL carbonMessage = [[[keyValues objectForKey:@"carbon_message"] lowercaseString] isEqualToString:@"true"];
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if ([destJid.resource isEqualToString:self.resource] == NO) {
                if ([self.delegate respondsToSelector:@selector(receiveEncryptMessageWithFrom:WithMsgType:WithContent:WithCarbon:)]) {
                    [self.delegate receiveEncryptMessageWithFrom:destJid.bare WithMsgType:xmppMessage.messageType WithContent:content WithCarbon:carbonMessage];
                }
            }
        }
            break;
        case SignalTypeSignalTypeCollection: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                {
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<==========Collection message[%s] ==========>\r%@<========== end Collection message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *channelInfo = [keyValues objectForKey:@"channelid"];
                
                NSString *msgRaw = pMessage.data;
                NSString *autoReply = [keyValues objectForKey:@"auto_reply"];
                int platform = xmppMessage.clientType;
                int msgType = xmppMessage.messageType;
                NSString *extendInfo = [keyValues objectForKey:@"extendInfo"];
                NSString *msg = [xmppMessage.body value];
                NSString *msgId = [xmppMessage messageId];
                BOOL carbonMessage = [[[keyValues objectForKey:@"carbon_message"] lowercaseString] isEqualToString:@"true"];
                NSString *chatId = [keyValues objectForKey:@"chatid"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:xmppMessage.receivedTime / 1000.0];
                if (msgId == nil) {
                    msgId = [date description];
                }
                NSString *realfrom = pMessage.realfrom;
                NSString *originFrom = pMessage.originfrom;
                NSString *originTo = pMessage.originto;
                NSString *originType = pMessage.origintype;
                SEL selector = @selector(onReceiveCollectionMsg:domain:realfrom:nickName:messageType:platformType:message:originalMsg:messageId:direction:stamp:extendInfo:chatId:msgRaw:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onReceiveCollectionMsg:[destJid user] domain:[destJid domain] realfrom:realfrom.length?realfrom:originFrom nickName:[destJid resource] messageType:msgType platformType:platform message:msg originalMsg:nil messageId:msgId direction:(carbonMessage ? 2 : 1) stamp:date extendInfo:extendInfo chatId:chatId msgRaw:msgRaw];
                }
                SEL selector2 = @selector(onReceiveCollectionMsg:WithOriginFrom:WithOriginTo:WithOriginType:);
                if ([[self delegate] respondsToSelector:selector2]) {
                    [[self delegate] onReceiveCollectionMsg:msgId WithOriginFrom:originFrom WithOriginTo:originTo WithOriginType:originType];
                }
            }
        }
            break;
        case SignalTypeSignalTypeError: {
            QIMXMPPJID *destJid = [QIMXMPPJID jidWithString:pMessage.pb_from];
            if (destJid) {
                XmppMessage *xmppMessage = [XmppMessage parseFromData:pMessage.message];
                {
                    NSString *log = [pMessage description];
                    log = [log stringByAppendingFormat:@"<========== Error message [%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(xmppMessage), [xmppMessage description]];
                    [self recordLog:log withDirection:MsgDirection_Receive];
                }
                NSDictionary *keyValues = [xmppMessage getHeadersDicForHeaders:xmppMessage.body.headers];
                NSString *messageId = [xmppMessage messageId];
                NSString *errcode = [keyValues objectForKey:@"errcode"];
                SEL selector = @selector(onReceiveErrorMsgWithFrom:WithMsgId:WithErrorCode:);
                if ([[self delegate] respondsToSelector:selector]) {
                    [[self delegate] onReceiveErrorMsgWithFrom:[destJid bare] WithMsgId:messageId WithErrorCode:errcode];
                }
            }
        }
            break;
        default: {
            //
            // 我也不知道是啥消息，多半是error
            { // Log
                NSString *log = [pMessage description];
                log = [log stringByAppendingFormat:@"<========== 不认识的消息类型 ==========>\r<========== message[%s] ==========>\r%@<========== end message ==========>\r", object_getClassName(pMessage), [pMessage description]];
                [self recordLog:log withDirection:MsgDirection_Receive];
            }
            QIMVerboseLog(@"这里出现了我也不认识的消息类型。。。。");
        }
            break;
    }
}

#pragma mark - End Stream

- (void)pbXmppStreamEndStream:(QIMPBStream *)sender didReceiveMessgae:(ProtoMessage *)message {
    QIMVerboseLog(@"%@", message);
    StreamEnd *steamEndMsg = [StreamEnd parseFromData:message.message];
    if ([[self delegate] respondsToSelector:@selector(serviceStreamEndWithErrorCode:WithReason:)]) {
        [[self delegate] serviceStreamEndWithErrorCode:steamEndMsg.code WithReason:steamEndMsg.reason];
    }
}

#pragma mark -

- (void)pbXmppStream:(QIMPBStream *)sender recordLog:(NSString *)log withDirection:(int)direction {
    [self recordLog:log withDirection:direction];
}

#pragma mark - Audio Video

- (void)sendAudioVideoWithType:(int)msgType WithBody:(NSString *)body WithExtentInfo:(NSString *)extendInfo WithMsgId:(NSString *)msgId ToJid:(NSString *)jid {
    if (extendInfo.length > 0) {
        NSString *message = [self checkXmlmessage:body];
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageType:MessageTypeMessageTypeText];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        [msgBuilder setMessageId:msgId];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:message];
        if (extendInfo) {
            [bodyBuilder addHeaders:[[[[StringHeader builder] setKey:@"extendInfo"] setValue:extendInfo] build]];
        }
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeWebRtc];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    }
}

#pragma mark - EncryptionMessage

- (void)sendEncryptionChatWithType:(int)encryptionChatType WithBody:(NSString *)body ToJid:(NSString *)jid {
    if (body.length && jid.length) {
        NSString *message = [self checkXmlmessage:body];
        XmppMessageBuilder *msgBuilder = [XmppMessage builder];
        [msgBuilder setMessageType:encryptionChatType];
        [msgBuilder setMessageId:[QIMPBStream generateUUID]];
        [msgBuilder setClientType:self.isFromMac ? MachineTypeMac : MachineTypeiOS];
        [msgBuilder setClientVersion:0];
        MessageBodyBuilder *bodyBuilder = [MessageBody builder];
        [bodyBuilder setValue:message];
        [msgBuilder setBody:[bodyBuilder build]];
        ProtoMessageBuilder *builder = [ProtoMessage builder];
        [builder setSignalType:SignalTypeSignalTypeEncryption];
        [builder setFrom:[[_pbXmppStream myJID] full]];
        [builder setTo:jid];
        [builder setMessage:msgBuilder.build.data];
        PBXMPPReceipt *receipt = nil;
        [_pbXmppStream sendProtobufMessage:[builder build] andGetReceipt:&receipt];
    }
}

@end
