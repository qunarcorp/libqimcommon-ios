//
//  QIMPBStream.m
//  qunarChatCommon
//
//  Created by admin on 16/10/9.
//  Copyright © 2016年 May. All rights reserved.
//

#import "QIMPBStream.h"
#import "QIMGCDMulticastDelegate.h"
#import "GCDAsyncSocket.h"
#import "QIMXMPPJID.h"
#import "QIMRSACoder.h"
#import "Message.pb.h"
#import "IQMessage+Utility.h"
#import "QIMPBXmppParser.h"
#import "NSString+QIMBase64.h"
#import "QIMProtobufModel.h"
#import "QIMPublicRedefineHeader.h"
//#import "curl.h"

#import "XmppImManager.h"
#import <libkern/OSAtomicDeprecated.h>
/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

#if TARGET_OS_IPHONE
#define MIN_KEEPALIVE_INTERVAL      10.0 // 15 Seconds
#define DEFAULT_KEEPALIVE_INTERVAL  45.0 //  1 Minutes
#else
#define MIN_KEEPALIVE_INTERVAL      1.0 // 10 Seconds
#define DEFAULT_KEEPALIVE_INTERVAL  45.0 //  1 Minutes
#endif

// Define the timeouts (in seconds) for SRV
#define TIMEOUT_SRV_RESOLUTION 30.0

// Define the timeouts (in seconds) for retreiving various parts of the XML stream
#define TIMEOUT_XMPP_WRITE         -1
#define TIMEOUT_XMPP_READ_START    10
#define TIMEOUT_XMPP_READ_STREAM   -1

// Define the tags we'll use to differentiate what it is we're currently reading or writing
#define TAG_XMPP_READ_START         100
#define TAG_XMPP_READ_STREAM        101
#define TAG_XMPP_WRITE_START        200
#define TAG_XMPP_WRITE_STREAM       201
#define TAG_XMPP_WRITE_RECEIPT      202

enum XMPPStreamConfig {
    kP2PMode = 1 << 0,  // If set, the XMPPStream was initialized in P2P mode
    kResetByteCountPerConnection = 1 << 1,  // If set, byte count should be reset per connection
#if TARGET_OS_IPHONE
    kEnableBackgroundingOnSocket  = 1 << 2,  // If set, the VoIP flag should be set on the socket
#endif
};
enum XMPPStreamErrorCode {
    XMPPStreamInvalidType,       // Attempting to access P2P methods in a non-P2P stream, or vice-versa
    XMPPStreamInvalidState,      // Invalid state for requested action, such as connect when already connected
    XMPPStreamInvalidProperty,   // Missing a required property, such as myJID
    XMPPStreamInvalidParameter,  // Invalid parameter, such as a nil JID
    XMPPStreamUnsupportedAction, // The server doesn't support the requested action
};

enum XMPPStreamFlags {
    kP2PInitiator = 1 << 0,  // If set, we are the P2P initializer
    kIsSecure = 1 << 1,  // If set, connection has been secured via SSL/TLS
    kIsAuthenticated = 1 << 2,  // If set, authentication has succeeded
    kDidStartNegotiation = 1 << 3,  // If set, negotiation has started at least once
};

NSString *const PBXMPPStreamErrorDomain = @"PBXMPPStreamErrorDomain";

const NSTimeInterval PBXMPPStreamTimeoutNone = 8;
static NSTimeInterval PBXMPPTimeoutArray[] = {3.0, 5.0, 8.0, 12.0, 12.0};
static int PBXMPPCurrentTimeoutpos = 0;
static int PBXMPPCurrentTimeoutCount = 5;

@interface QIMPBStream () {
    dispatch_queue_t willSendIqQueue;
    dispatch_queue_t willSendMessageQueue;
    dispatch_queue_t willSendPresenceQueue;
    
    dispatch_queue_t willReceiveIqQueue;
    dispatch_queue_t willReceiveMessageQueue;
    dispatch_queue_t willReceivePresenceQueue;
    
    dispatch_queue_t didReceiveIqQueue;
    
    dispatch_source_t connectTimer;
    
    QIMGCDMulticastDelegate <PBXMPPStreamDelegate> *multicastDelegate;
    
    int state;
    
    GCDAsyncSocket *asyncSocket;
    
    UInt64 numberOfBytesSent;
    UInt64 numberOfBytesReceived;
    
    //    XMPPParser *parser;
    //    NSError *parserError;
    
    Byte flags;
    Byte config;
    
    NSString *hostName;
    UInt16 hostPort;
    
    BOOL autoStartTLS;
    
    //    id <XMPPSASLAuthentication> auth;
    NSDate *authenticationDate;
    
    QIMXMPPJID *myJID_setByClient;
    QIMXMPPJID *myJID_setByServer;
    QIMXMPPJID *remoteJID;
    
    //    XMPPPresence *myPresence;
    //NSXMLElement *rootElement;
    
    NSTimeInterval keepAliveInterval;
    dispatch_source_t keepAliveTimer;
    NSTimeInterval lastSendReceiveTime;
    NSData *keepAliveData;
    
    NSMutableArray *registeredModules;
    NSMutableDictionary *autoDelegateDict;
    
    NSArray *srvResults;
    NSUInteger srvResultsIndex;
    
    NSMutableArray *receipts;
    NSMutableArray *iqReceipts;
    
    NSThread *xmppUtilityThread;
    NSRunLoop *xmppUtilityRunLoop;
    
    id userTag;
    
    NSMutableArray *registeredFeatures;
    NSMutableArray *registeredStreamPreprocessors;
    NSMutableArray *registeredElementHandlers;
    
    QIMPBXmppParser *pbXmppParser;
    
    __strong NSMutableDictionary *_messageDic;
}
- (void)setupKeepAliveTimer;
@end

@interface QIMPBStream (Login)
@end

@implementation QIMPBStream (Login)

static NSString *XmppPbStreamVersion = @"1.0";

- (void)sendWelcome {
    WelcomeMessageBuilder *builder = [WelcomeMessage builder];
    [builder setDomain:self.myJID.domain];
    [builder setVersion:XmppPbStreamVersion];
    [builder setUser:[[self myJID] user]];
    ProtoMessageBuilder *msgBuilder = [ProtoMessage builder];
    [msgBuilder setSignalType:SignalTypeSignalTypeWelcome];
    [msgBuilder setMessage:[builder build].data];
    [self sendProtobufMessage:[msgBuilder build]];
}

- (void)sendStartTLS {
    StartTLSBuilder *builder = [StartTLS builder];
    ProtoMessageBuilder *msgBuilder = [ProtoMessage builder];
    [msgBuilder setSignalType:SignalTypeSignalStartTls];
    [msgBuilder setMessage:[builder build].data];
    [self sendProtobufMessage:[msgBuilder build]];
}

- (void)sendBindMessage {
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setKey:@"BIND"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setValue:[[self myJID] resource]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IQMessage *result = [self syncIQMessage:[builder build]];
        NSDictionary *headerDic = [result getHeadersDicForHeaders:result.body.headers];
        self.serviceTime = [[headerDic objectForKey:@"time_value"] longLongValue];
        self.remoteKey = [headerDic objectForKey:@"key_value"];
        [self sendPriority:5];
        // 登录成功！～～～
        QIMVerboseLog(@"登录认证BindMessage :%@", result);
        [multicastDelegate pbXmppStreamDidAuthenticate:self];
    });
}

- (NSString *)pwd_key_PLAIN:(BOOL)flag {
    if (self.myJID.user == nil)
        return @"";
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"\0"];
    [string appendString:self.myJID.user];
    if (self.loginType == 0) {
        // 手机端
        [string appendString:@"\0"];
        [string appendString:self.password];
        QIMVerboseLog(@"验证码QIMPBStream Login PWD : %@", string);
    } else {
        // Mac
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [formatter stringFromDate:[NSDate date]];
        
        NSDictionary *dic = @{@"p": self.password,
                              @"a": @"testapp",
                              @"u": self.myJID.user,
                              @"mk": self.deviceUUID
                              };
        NSError *error = nil;
        NSData *jsonData =
        [NSJSONSerialization dataWithJSONObject:dic
                                        options:NSJSONWritingPrettyPrinted
                                          error:&error];
        
        NSString *pwd = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        QIMVerboseLog(@"密码QIMPBStream Login PWD : %@", pwd);
        NSString *base64Res = nil;
        if (flag) {
            base64Res = [QIMRSACoder encryptByRsa:pwd];
        } else {
            base64Res = self.password;
        }
        
        [string appendString:@"\0"];
        [string appendString:base64Res ? base64Res : @""];
    }
    QIMVerboseLog(@"QIMPBStream Logintype : %d", self.loginType);
    NSString *base64Result = [string qim_base64EncodedString];
    QIMVerboseLog(@"QIMPBStream HHHHH : %@", base64Result);
    return base64Result;
}

- (void)sendAuthWithKey:(NSString *)key {
    AuthMessageBuilder *builder = [AuthMessage builder];
    [builder setMechanism:@"PLAIN"];
    [builder setAuthKey:key];
    ProtoMessageBuilder *msgBuilder = [ProtoMessage builder];
    [msgBuilder setSignalType:SignalTypeSignalTypeAuth];
    [msgBuilder setFrom:[[self myJID] full]];
    [msgBuilder setMessage:[builder build].data];
    [self sendProtobufMessage:[msgBuilder build]];
}

- (void)sendHeartBeat {
    QIMVerboseLog(@"sendHeartBeat");
    IQMessageBuilder *builder = [IQMessage builder];
    [builder setKey:@"PING"];
    [builder setMessageId:[QIMPBStream generateUUID]];
    [builder setValue:[[self myJID] resource]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self syncIQMessage:[builder build]];
    });
    //我不知道这是什么时候的心跳
    /*
     ProtoMessageBuilder *msgBuilder = [ProtoMessage builder];
     [msgBuilder setSignalType:SignalTypeSignalTypeHeartBeat];
     [msgBuilder setFrom:[[self myJID] full]];
     [self sendProtobufMessage:[msgBuilder build]];
     */
}

- (void)sendPriority:(int)level {
    
    PresenceMessageBuilder *builder = [PresenceMessage builder];
    [builder setKey:@"priority"];
    [builder setValue:[NSString stringWithFormat:@"%d", level]];
    [self sendPresenceMessage:[builder build]];
    
    dispatch_async(self.xmppQueue, ^{
        PBXMPPCurrentTimeoutpos = 0;
        [self setupKeepAliveTimer];
    });
}

@end

@implementation QIMPBStream

+ (NSString *)generateUUID {
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid) {
        result = (__bridge_transfer NSString *) CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    return [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (void)testQIMPBStream {
    QIMPBStream *stream = [[QIMPBStream alloc] init];
    NSString *resource = [NSString stringWithFormat:@"V[%@]_P[%@]_D[%@]_ID[%@]", @"0000", @"mac", @"Mac", [QIMPBStream generateUUID]];
    NSString *selfUrl = [NSString stringWithFormat:@"%@@%@/%@", @"ping.xue", @"ejabhost1", resource];
    QIMXMPPJID *myJid = [QIMXMPPJID jidWithString:selfUrl];
    [stream setMyJID:myJid];
    [stream setHostName:@"l-ejab2.vc.cn5.qunar.com"];
    [stream setHostPort:5224];
    [stream setPassword:@"2154233s@2"];
    [stream connectWithTimeout:60 error:nil];
}

@synthesize xmppQueue;
@synthesize xmppQueueTag;

/**
 * Shared initialization between the various init methods.
 **/
- (void)commonInit {
    // Parser
    pbXmppParser = [QIMPBXmppParser pbXmppParserInit];
    // IQ 记录
    _messageDic = [[NSMutableDictionary alloc] init];
    
    xmppQueueTag = &xmppQueueTag;
    xmppQueue = dispatch_queue_create("xmpp", NULL);
    dispatch_queue_set_specific(xmppQueue, xmppQueueTag, xmppQueueTag, NULL);
    
    willSendIqQueue = dispatch_queue_create("xmpp.willSendIq", NULL);
    willSendMessageQueue = dispatch_queue_create("xmpp.willSendMessage", NULL);
    willSendPresenceQueue = dispatch_queue_create("xmpp.willSendPresence", NULL);
    
    willReceiveIqQueue = dispatch_queue_create("xmpp.willReceiveIq", NULL);
    willReceiveMessageQueue = dispatch_queue_create("xmpp.willReceiveMessage", NULL);
    willReceivePresenceQueue = dispatch_queue_create("xmpp.willReceivePresence", NULL);
    
    didReceiveIqQueue = dispatch_queue_create("xmpp.didReceiveIq", NULL);
    
    multicastDelegate = (QIMGCDMulticastDelegate <PBXMPPStreamDelegate> *) [[QIMGCDMulticastDelegate alloc] init];
    
    state = STATE_PBXMPP_DISCONNECTED;
    
    flags = 0;
    config = 0;
    
    numberOfBytesSent = 0;
    numberOfBytesReceived = 0;
    
    hostPort = 5222;
    keepAliveInterval = DEFAULT_KEEPALIVE_INTERVAL;
    keepAliveData = [@" " dataUsingEncoding:NSUTF8StringEncoding];
    
    registeredModules = [[NSMutableArray alloc] init];
    autoDelegateDict = [[NSMutableDictionary alloc] init];
    
    receipts = [[NSMutableArray alloc] init];
    iqReceipts = [[NSMutableArray alloc] init];
    
    registeredFeatures = [[NSMutableArray alloc] init];
    registeredStreamPreprocessors = [[NSMutableArray alloc] init];
    registeredElementHandlers = [[NSMutableArray alloc] init];
    
    // Setup and start the utility thread.
    // We need to be careful to ensure the thread doesn't retain a reference to us longer than necessary.
    
    xmppUtilityThread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(xmppThreadMain) object:nil];
    [[xmppUtilityThread threadDictionary] setObject:self forKey:@"XMPPStream"];
    [xmppUtilityThread start];
}

/**
 * Standard XMPP initialization.
 * The stream is a standard client to server connection.
 **/
- (id)init {
    if ((self = [super init])) {
        // Common initialization
        [self commonInit];
        
        // Initialize socket
        
        //        asyncSocket = [[GCDAsyncSocket alloc] init];
        //        [asyncSocket setDelegate:self];
        //        xmppQueue = [asyncSocket delegateQueue];
        //        [asyncSocket setDelegateQueue:xmppQueue];
        
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:xmppQueue];
        
        [asyncSocket setIPv4Enabled:YES];
        [asyncSocket setIPv6Enabled:YES];
        [asyncSocket setIPv4PreferredOverIPv6:NO];
    }
    return self;
}

#if TARGET_OS_IPHONE

- (BOOL)enableBackgroundingOnSocket
{
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (config & kEnableBackgroundingOnSocket) ? YES : NO;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setEnableBackgroundingOnSocket:(BOOL)flag
{
    dispatch_block_t block = ^{
        if (flag)
            config |= kEnableBackgroundingOnSocket;
        else
            config &= ~kEnableBackgroundingOnSocket;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Configuration
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Asynchronous operation (if outside xmppQueue)
    
    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Synchronous operation
    
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
}

- (void)removeDelegate:(id)delegate {
    // Synchronous operation
    
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate];
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
}

#pragma mark - QIMPBStream Thread

- (NSThread *)xmppUtilityThread {
    // This is a read-only variable, set in the init method and never altered.
    // Thus we supply direct access to it in this method.
    
    return xmppUtilityThread;
}

- (NSRunLoop *)xmppUtilityRunLoop {
    __block NSRunLoop *result = nil;
    
    dispatch_block_t block = ^{
        result = xmppUtilityRunLoop;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setXmppUtilityRunLoop:(NSRunLoop *)runLoop {
    dispatch_async(xmppQueue, ^{
        if (xmppUtilityRunLoop == nil) {
            xmppUtilityRunLoop = runLoop;
        }
    });
}

+ (void)xmppThreadMain {
    // This is the xmppUtilityThread.
    // It is designed to be used only if absolutely necessary.
    // If there is a GCD alternative, it should be used instead.
    
    @autoreleasepool {
        
        [[NSThread currentThread] setName:@"XMPPUtilityThread"];
        
        // Set XMPPStream's xmppUtilityRunLoop variable.
        //
        // And when done, remove the xmppStream reference from the dictionary so it's no longer retained.
        
        QIMPBStream *creator = [[[NSThread currentThread] threadDictionary] objectForKey:@"XMPPStream"];
        [creator setXmppUtilityRunLoop:[NSRunLoop currentRunLoop]];
        [[[NSThread currentThread] threadDictionary] removeObjectForKey:@"XMPPStream"];
        
        // We can't iteratively run the run loop unless it has at least one source or timer.
        // So we'll create a timer that will probably never fire.
        
        [NSTimer scheduledTimerWithTimeInterval:[[NSDate distantFuture] timeIntervalSinceNow]
                                         target:self
                                       selector:@selector(xmppThreadIgnore:)
                                       userInfo:nil
                                        repeats:YES];
        
        BOOL isCancelled = NO;
        BOOL hasRunLoopSources = YES;
        
        while (!isCancelled && hasRunLoopSources) {
            @autoreleasepool {
                
                hasRunLoopSources = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                                             beforeDate:[NSDate distantFuture]];
                
                isCancelled = [[NSThread currentThread] isCancelled];
            }
        }
    }
}

+ (void)xmppThreadStop {
    [[NSThread currentThread] cancel];
}

+ (void)xmppThreadIgnore:(NSTimer *)aTimer {
    // Ignore
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (XMPPStreamState)state {
    __block XMPPStreamState result = STATE_PBXMPP_DISCONNECTED;
    
    dispatch_block_t block = ^{
        result = (XMPPStreamState) state;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (NSString *)hostName {
    if (dispatch_get_specific(xmppQueueTag)) {
        return hostName;
    } else {
        __block NSString *result;
        
        dispatch_sync(xmppQueue, ^{
            result = hostName;
        });
        
        return result;
    }
}

- (void)setHostName:(NSString *)newHostName {
    if (dispatch_get_specific(xmppQueueTag)) {
        if (hostName != newHostName) {
            hostName = [newHostName copy];
        }
    } else {
        NSString *newHostNameCopy = [newHostName copy];
        
        dispatch_async(xmppQueue, ^{
            hostName = newHostNameCopy;
        });
        
    }
}

- (UInt16)hostPort {
    if (dispatch_get_specific(xmppQueueTag)) {
        return hostPort;
    } else {
        __block UInt16 result;
        
        dispatch_sync(xmppQueue, ^{
            result = hostPort;
        });
        
        return result;
    }
}

- (void)setHostPort:(UInt16)newHostPort {
    dispatch_block_t block = ^{
        hostPort = newHostPort;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (BOOL)autoStartTLS {
    __block BOOL result;
    
    dispatch_block_t block = ^{
        result = autoStartTLS;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setAutoStartTLS:(BOOL)flag {
    dispatch_block_t block = ^{
        autoStartTLS = flag;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (QIMXMPPJID *)myJID {
    __block QIMXMPPJID *result = nil;
    
    dispatch_block_t block = ^{
        
        if (myJID_setByServer)
            result = myJID_setByServer;
        else
            result = myJID_setByClient;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setMyJID_setByClient:(QIMXMPPJID *)newMyJID {
    // QIMXMPPJID is an immutable class (copy == retain)
    
    dispatch_block_t block = ^{
        myJID_setByClient = newMyJID;

    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (void)setMyJID_setByServer:(QIMXMPPJID *)newMyJID {
    // QIMXMPPJID is an immutable class (copy == retain)
    
    dispatch_block_t block = ^{
        
        QIMXMPPJID *oldMyJID;
        if (myJID_setByServer)
            oldMyJID = myJID_setByServer;
        else
            oldMyJID = myJID_setByClient;
        
        myJID_setByServer = newMyJID;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (void)setMyJID:(QIMXMPPJID *)newMyJID {
    [self setMyJID_setByClient:newMyJID];
}

- (QIMXMPPJID *)remoteJID {
    if (dispatch_get_specific(xmppQueueTag)) {
        return remoteJID;
    } else {
        __block QIMXMPPJID *result;
        
        dispatch_sync(xmppQueue, ^{
            result = remoteJID;
        });
        
        return result;
    }
}

/*- (XMPPPresence *)myPresence
 {
 if (dispatch_get_specific(xmppQueueTag))
 {
 return myPresence;
 }
 else
 {
 __block XMPPPresence *result;
 
 dispatch_sync(xmppQueue, ^{
 result = myPresence;
 });
 
 return result;
 }
 }*/

- (NSTimeInterval)keepAliveInterval {
    __block NSTimeInterval result = 0.0;
    
    dispatch_block_t block = ^{
        result = keepAliveInterval;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setKeepAliveInterval:(NSTimeInterval)interval {
    dispatch_block_t block = ^{
        
        if (keepAliveInterval != interval) {
            if (interval <= 0.0)
                keepAliveInterval = interval;
            else
                keepAliveInterval = MAX(interval, MIN_KEEPALIVE_INTERVAL);
            
            [self setupKeepAliveTimer];
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (char)keepAliveWhitespaceCharacter {
    __block char keepAliveChar = ' ';
    
    dispatch_block_t block = ^{
        
        NSString *keepAliveString = [[NSString alloc] initWithData:keepAliveData encoding:NSUTF8StringEncoding];
        if ([keepAliveString length] > 0) {
            keepAliveChar = (char) [keepAliveString characterAtIndex:0];
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return keepAliveChar;
}

- (void)setKeepAliveWhitespaceCharacter:(char)keepAliveChar {
    dispatch_block_t block = ^{
        
        if (keepAliveChar == ' ' || keepAliveChar == '\n' || keepAliveChar == '\t') {
            keepAliveData = [[NSString stringWithFormat:@"%c", keepAliveChar] dataUsingEncoding:NSUTF8StringEncoding];
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (UInt64)numberOfBytesSent {
    if (dispatch_get_specific(xmppQueueTag)) {
        return numberOfBytesSent;
    } else {
        __block UInt64 result;
        
        dispatch_sync(xmppQueue, ^{
            result = numberOfBytesSent;
        });
        
        return result;
    }
}

- (UInt64)numberOfBytesReceived {
    if (dispatch_get_specific(xmppQueueTag)) {
        return numberOfBytesReceived;
    } else {
        __block UInt64 result;
        
        dispatch_sync(xmppQueue, ^{
            result = numberOfBytesReceived;
        });
        
        return result;
    }
}

- (BOOL)resetByteCountPerConnection {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (config & kResetByteCountPerConnection) ? YES : NO;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setResetByteCountPerConnection:(BOOL)flag {
    dispatch_block_t block = ^{
        if (flag)
            config |= kResetByteCountPerConnection;
        else
            config &= ~kResetByteCountPerConnection;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (BOOL)isAuthenticating {
    
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            result = (state == STATE_PBXMPP_AUTH);
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (BOOL)isAuthenticated {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (flags & kIsAuthenticated) ? YES : NO;
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

- (void)setIsAuthenticated:(BOOL)flag {
    dispatch_block_t block = ^{
        if (flag) {
            flags |= kIsAuthenticated;
            authenticationDate = [NSDate date];
        } else {
            flags &= ~kIsAuthenticated;
            authenticationDate = nil;
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (NSDate *)authenticationDate {
    __block NSDate *result = nil;
    
    dispatch_block_t block = ^{
        if (flags & kIsAuthenticated) {
            result = authenticationDate;
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

/**
 * This method applies to standard password authentication schemes only.
 * This is NOT the primary authentication method.
 *
 * @see authenticate:error:
 *
 * This method exists for backwards compatibility, and may disappear in future versions.
 **/
- (BOOL)authenticateWithPassword:(NSString *)inPassword error:(NSError **)errPtr {
    
    // The given password parameter could be mutable
    [self setPassword:inPassword];
    
    __block BOOL result = YES;
    __block NSError *err = nil;
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            if (state != STATE_PBXMPP_CONNECTED) {
                NSString *errMsg = @"Please wait until the stream is connected.";
                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                
                err = [NSError errorWithDomain:PBXMPPStreamErrorDomain code:XMPPStreamInvalidState userInfo:info];
                
                result = NO;
                return_from_block;
            }
            
            if (myJID_setByClient == nil) {
                NSString *errMsg = @"You must set myJID before calling authenticate:error:.";
                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                
                err = [NSError errorWithDomain:PBXMPPStreamErrorDomain code:XMPPStreamInvalidProperty userInfo:info];
                
                result = NO;
                return_from_block;
            }
            
            // Choose the best authentication method.
            //
            // P.S. - This method is deprecated.
            
            // 多种认证 需要实现
            
            [self sendAuthWithKey:[self pwd_key_PLAIN:YES]];
            
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    if (errPtr)
        *errPtr = err;
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connection State
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Returns YES if the connection is closed, and thus no stream is open.
 * If the stream is neither disconnected, nor connected, then a connection is currently being established.
 **/
- (BOOL)isDisconnected {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (state == STATE_PBXMPP_DISCONNECTED);
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

/**
 * Returns YES is the connection is currently connecting
 **/

- (BOOL)isConnecting {
    
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            result = (state == STATE_PBXMPP_CONNECTING);
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

/**
 * Returns YES if the connection is open, and the stream has been properly established.
 * If the stream is neither disconnected, nor connected, then a connection is currently being established.
 **/
- (BOOL)isConnected {
    __block BOOL result = NO;
    
    dispatch_block_t block = ^{
        result = (state == STATE_PBXMPP_CONNECTED);
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect Timeout
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Start Connect Timeout
 **/

- (void)startConnectTimeout:(NSTimeInterval)timeout {
    
    if (timeout >= 0.0 && !connectTimer) {
        connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, xmppQueue);
        
        dispatch_source_set_event_handler(connectTimer, ^{
            @autoreleasepool {
                
                [self doConnectTimeout];
            }
        });
        
#if !OS_OBJECT_USE_OBJC
        dispatch_source_t theConnectTimer = connectTimer;
        dispatch_source_set_cancel_handler(connectTimer, ^{
            dispatch_release(theConnectTimer);
        });
#endif
        
        dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, (timeout * NSEC_PER_SEC));
        dispatch_source_set_timer(connectTimer, tt, (timeout * NSEC_PER_SEC), 0);
        
        dispatch_resume(connectTimer);
    }
}

/**
 * End Connect Timeout
 **/

- (void)endConnectTimeout {
    
    if (connectTimer) {
        dispatch_source_cancel(connectTimer);
        connectTimer = NULL;
    }
}

/**
 * Connect has timed out, so inform the delegates and close the connection
 **/

- (void)doConnectTimeout {
    
    [self endConnectTimeout];
    
    if (state != STATE_PBXMPP_DISCONNECTED) {
        [multicastDelegate pbXmppStreamConnectDidTimeout:self];
        
        if (state == STATE_PBXMPP_RESOLVING_SRV) {
            
            state = STATE_PBXMPP_DISCONNECTED;
        } else {
            [asyncSocket disconnect];
            
            // Everthing will be handled in socketDidDisconnect:withError:
        }
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark AsyncSocket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    if (completionHandler)
        completionHandler(YES);
    //        [multicastDelegate pbXmppStream:self didReceiveTrust:trust completionHandler:completionHandler];
}

/**
 * Called when a socket connects and is ready for reading and writing. "host" will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    // This method is invoked on the xmppQueue.
    //
    // The TCP connection is now established.
    QIMVerboseLog(@"socket: %@ didConnectToHost:%@ port:%ld", sock, host, port);

    [self endConnectTimeout];
    
#if TARGET_OS_IPHONE
    {
        if (self.enableBackgroundingOnSocket)
        {
            __block BOOL result;
            
            [asyncSocket performBlock:^{
                result = [asyncSocket enableBackgroundingOnSocket];
            }];
            
            if (result) {
                QIMVerboseLog(@"Enabled backgrounding on socket");
            }
            else {
                QIMVerboseLog(@"Error enabling backgrounding on socket!");
            }
        }
    }
#endif
    
    [multicastDelegate pbXmppStream:self socketDidConnect:sock];
    
//    srvResolver = nil;
    srvResults = nil;
    
    /*    // Are we using old-style SSL? (Not the upgrade to TLS technique specified in the XMPP RFC)
     if ([self isSecure])
     {
     // The connection must be secured immediately (just like with HTTPS)
     [self startTLS];
     }
     else
     {
     [self startNegotiation];
     }
     */
    state = STATE_PBXMPP_CONNECTED;
    [self sendWelcome];
    [self readDataWithTimeout:TIMEOUT_XMPP_READ_STREAM tag:TAG_XMPP_READ_STREAM];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    // This method is invoked on the xmppQueue.
    QIMVerboseLog(@"<========== socketDidSecure %@ ==========>", sock);
    [multicastDelegate pbXmppStreamDidSecure:self];
}

/**
 * Called when a socket has completed reading the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // This method is invoked on the xmppQueue.
    
    lastSendReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    numberOfBytesReceived += [data length];
    
    NSData *newData = data;
    {
        NSString *dataLog = @"<========== 接收到的原数据 ==========>";
        dataLog = [dataLog stringByAppendingFormat:@"\n%@", [data description]];
        [multicastDelegate pbXmppStream:self recordLog:dataLog withDirection:MsgDirection_Receive];
    }
    @try {
        NSArray *msgList = [pbXmppParser paserProtoMessageWithData:newData];
        QIMVerboseLog(@"<========== 接收到的原消息 %@ ==========>", msgList);
        
        for (ProtoMessage *message in msgList) {
            switch (message.signalType) {
                case SignalTypeSignalTypeWelcome: {
                    { // Log
                        NSString *log = [message description];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                    }
                    WelcomeMessage *welcomeMsg = [WelcomeMessage parseFromData:message.message];
                    if ([self autoStartTLS] && [welcomeMsg.sockmod isEqualToString:@"TLS"]) {
                        [self sendStartTLS];
                    } else {
                        [self sendAuthWithKey:[self pwd_key_PLAIN:YES]];
                    }
                    QIMVerboseLog(@"SignalTypeSignalTypeWelcome : %@", welcomeMsg);
                }
                    break;
                case SignalTypeSignalProceedTls: {
                    { // Log
                        NSString *log = [message description];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                        QIMVerboseLog(@"SignalTypeSignalProceedTls : %@", log);
                    }
                    NSMutableDictionary *tlsSetting = [NSMutableDictionary dictionary];
                    
                    tlsSetting[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
                    //[multicastDelegate pbXmppStream:self willSecureWithSettings:tlsSetting];
                    [asyncSocket startTLS:tlsSetting];
                }
                    break;
                case SignalTypeSignalTypeSucceededResponse: {
                    { // Log
                        NSString *log = [message description];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                        QIMVerboseLog(@"SignalTypeSignalTypeSucceededResponse : %@", log);
                    }
                    //  认证成功
                    [self setIsAuthenticated:YES];
                    [self sendBindMessage];
                }
                    break;
                case SignalTypeSignalTypeFailureResponse: {
                    { // Log
                        NSString *log = [message description];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                        QIMVerboseLog(@"SignalTypeSignalTypeFailureResponse : %@", log);
                    }
                    
                    ResponseFailure *authMsg = [ResponseFailure parseFromData:[message message]];
                    QIMVerboseLog(@"认证失败Error : %@", authMsg);
                    NSString *errorStr = authMsg.error;
                    if ([errorStr isEqualToString:@"cancel-rsa"]) {
                        // 帐号在白名单
                        [self sendAuthWithKey:[self pwd_key_PLAIN:NO]];
                        break;
                    }
                    // 认证失败
                    [multicastDelegate pbXmppStream:self didNotAuthenticate:message];
                    NSError *error = [NSError errorWithDomain:PBXMPPStreamErrorDomain
                                                         code:404
                                                     userInfo:@{NSLocalizedDescriptionKey:
                                                                    [NSString stringWithFormat:@"Error Authen Faild"]}];
                    QIMVerboseLog(@"认证失败 disconnectWithError : %@", error);
                    [self disconnectWithError:error];
                }
                    break;
                case SignalTypeSignalTypeIq:
                case SignalTypeSignalTypeIqresponse: {
                    // IQ 应答
                    IQMessage *iqMessage = [IQMessage parseFromData:message.message];
                    PBXMPPReceipt *parameters = [_messageDic objectForKey:iqMessage.messageId];
                    [parameters setUserInfo:iqMessage];
                    [parameters signalSuccess];
                    QIMVerboseLog(@"IQ应答SignalTypeSignalTypeIq | SignalTypeSignalTypeIqresponse: %@", iqMessage);
                    @synchronized (self) {
                        [_messageDic removeObjectForKey:iqMessage.messageId];
                    }
                    { // Log
                        NSString *log = [message description];
                        //                        log = [log stringByAppendingFormat:@"<========== message[%@] ==========>\r%@<========== end message ==========>\r",iqMessage.className,[iqMessage description]];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                    }
                }
                    break;
                case SignalTypeSignalTypePresence: {
                    PresenceMessage *presenceMessage = [PresenceMessage parseFromData:message.message];
                    if ([presenceMessage definedKey] == PresenceKeyTypePresenceKeyNotify) {
                        [multicastDelegate pbXmppStream:self didReceivePresenceKeyNotify:presenceMessage];
                    } else {
                        [multicastDelegate pbXmppStream:self didReceivePresence:message];
                    }
                }
                    break;
                case SignalTypeSignalTypeTransfor:
                case SignalTypeSignalTypeRevoke:
                case SignalTypeSignalTypeShareLocation:
                case SignalTypeSignalTypeHeadline:
                case SignalTypeSignalTypeNote:
                case SignalTypeSignalTypeTyping:
                case SignalTypeSignalTypeReadmark:
                case SignalTypeSignalTypeMstate:
                case SignalTypeSignalTypeGroupChat:
                case SignalTypeSignalTypeChat:
                case SignalTypeSignalTypeCarbon:
                case SignalTypeSignalTypeWebRtc:
                case SignalTypeSignalTypeSubscription:
                case SignalTypeSignalTypeConsult:
                case SignalTypeSignalTypeEncryption:
                case SignalTypeSignalTypeCollection:
                case SignalTypeSignalTypeError: {
                    [multicastDelegate pbXmppStream:self didReceiveMessage:message];
                }
                    break;
                case SignalTypeSignalTypeStreamEnd: {
                    QIMVerboseLog(@"Stream End");
                    StreamEnd *steamEndMsg = [StreamEnd parseFromData:message.message];
                    QIMVerboseLog(@"steamEnd Msg: %@", steamEndMsg);
                    QIMVerboseLog(@"steamEnd Code : %d", (int)steamEndMsg.code);
                    QIMVerboseLog(@"steamEnd Reason :%@", steamEndMsg.reason);
                    [multicastDelegate pbXmppStreamEndStream:self didReceiveMessgae:message];
                    
                    NSError *error = [NSError errorWithDomain:PBXMPPStreamErrorDomain
                                                         code:404
                                                     userInfo:@{NSLocalizedDescriptionKey:
                                                                    [NSString stringWithFormat:@"Error Service Disconnect."]}];
                    QIMVerboseLog(@"Stream End : %@", error);
                    [self disconnectWithError:error];
                    
                    { // Log
                        NSString *log = [message description];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                        QIMVerboseLog(@"SignalTypeSignalTypeStreamEnd ：%@, Error : %@", log, error);
                    }
                }
                    break;
                default: {
                    QIMVerboseLog(@"Default ////********%d*********////", (int)message.signalType);
                    { // Log
                        NSString *log = [message description];
                        [multicastDelegate pbXmppStream:self recordLog:log withDirection:MsgDirection_Receive];
                    }
                }
                    break;
            }
        }
        {
            NSString *dataLog = @"<========== Paser Buf 剩余数据 ==========>";
            // dataLog =  [dataLog stringByAppendingFormat:@"\n%@",[data description]];
            dataLog = [dataLog stringByAppendingFormat:@"\nPaserData:%@", [pbXmppParser paserBufFormatString]];
            [multicastDelegate pbXmppStream:self recordLog:dataLog withDirection:MsgDirection_Receive];
        }
    } @catch (NSException *exception) {
        NSString *errorLog = @"<========== 解析数据异常 ==========>";
        errorLog = [errorLog stringByAppendingFormat:@"\n%@", [exception description]];
        errorLog = [errorLog stringByAppendingFormat:@"%@",
                    [exception callStackSymbols]];
        errorLog = [errorLog stringByAppendingString:@"\n"];
        errorLog = [errorLog stringByAppendingFormat:@"\nRawData:%@", newData];
        errorLog = [errorLog stringByAppendingFormat:@"\nPaserData:%@", [pbXmppParser paserBufFormatString]];
        [multicastDelegate pbXmppStream:self recordLog:errorLog withDirection:MsgDirection_Receive];
        [pbXmppParser clearParser];
    } @finally {
    }
    
    [self readDataWithTimeout:TIMEOUT_XMPP_READ_STREAM tag:TAG_XMPP_READ_STREAM];
}

/**
 * Called after data with the given tag has been successfully sent.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    // This method is invoked on the xmppQueue.
    
    lastSendReceiveTime = [NSDate timeIntervalSinceReferenceDate];
    
    if (tag == TAG_XMPP_WRITE_RECEIPT) {
        if ([receipts count] == 0) {
            return;
        }
        // 这逻辑不对啊 有个能解除的不是 当前发送的消息的Waiting
        PBXMPPReceipt *receipt = [receipts objectAtIndex:0];
        [receipt signalSuccess];
        [receipts removeObjectAtIndex:0];
    }
    
}

/**
 * Called when a socket disconnects with or without error.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    // This method is invoked on the xmppQueue.
    QIMVerboseLog(@"Socket断开连接 %@ %@", sock, err);
    
    [self endConnectTimeout];
    
    if (srvResults && (++srvResultsIndex < [srvResults count])) {
        [self tryNextSrvResult];
    } else {
        // Update state
        state = STATE_PBXMPP_DISCONNECTED;
        
        // 清理Paser
        [pbXmppParser clearParser];
        [self cancelAllIQMessage];
        [self setIsAuthenticated:NO];
        
        // Stop the keep alive timer
        if (keepAliveTimer) {
            dispatch_source_cancel(keepAliveTimer);
            keepAliveTimer = NULL;
        }
        
        for (PBXMPPReceipt *receipt in receipts) {
            [receipt signalFailure];
        }
        [receipts removeAllObjects];
        
        flags = 0;
        [multicastDelegate pbXmppStreamDidDisconnect:self withError:err];
        
        /*        // Release the parser (to free underlying resources)
         [parser setDelegate:nil delegateQueue:NULL];
         parser = nil;
         
         // Clear any saved authentication information
         auth = nil;
         
         authenticationDate = nil;
         
         // Clear stored elements
         myJID_setByServer = nil;
         myPresence = nil;
         rootElement = nil;
         
         // Stop the keep alive timer
         if (keepAliveTimer)
         {
         dispatch_source_cancel(keepAliveTimer);
         keepAliveTimer = NULL;
         }
         
         // Clear srv results
         srvResolver = nil;
         srvResults = nil;
         
         // Clear any pending receipts
         for (XMPPElementReceipt *receipt in receipts)
         {
         [receipt signalFailure];
         }
         [receipts removeAllObjects];
         
         // Clear flags
         flags = 0;
         
         // Notify delegate
         
         if (parserError)
         {
         [multicastDelegate xmppStreamDidDisconnect:self withError:parserError];
         
         parserError = nil;
         }
         else
         {
         [multicastDelegate xmppStreamDidDisconnect:self withError:err];
         }
         */
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)tryNextSrvResult {
    NSAssert(dispatch_get_specific(xmppQueueTag), @"Invoked on incorrect queue");
    
    NSError *connectError = nil;
    BOOL success = NO;
    
    while (srvResultsIndex < [srvResults count]) {
//        XMPPSRVRecord *srvRecord = [srvResults objectAtIndex:srvResultsIndex];
//        NSString *srvHost = srvRecord.target;
//        UInt16 srvPort = srvRecord.port;
        
        success = [self connectToHost:[myJID_setByClient domain] onPort:5222 withTimeout:PBXMPPStreamTimeoutNone error:&connectError];
        
        if (success) {
            break;
        } else {
            srvResultsIndex++;
        }
    }
    
    if (!success) {
        // SRV resolution of the JID domain failed.
        // As per the RFC:
        //
        // "If the SRV lookup fails, the fallback is a normal IPv4/IPv6 address record resolution
        // to determine the IP address, using the "xmpp-client" port 5222, registered with the IANA."
        //
        // In other words, just try connecting to the domain specified in the JID.
        
        success = [self connectToHost:[myJID_setByClient domain] onPort:5222 withTimeout:PBXMPPStreamTimeoutNone error:&connectError];
    }
    
    if (!success) {
        [self endConnectTimeout];
        
        state = STATE_PBXMPP_DISCONNECTED;
        
        [multicastDelegate pbXmppStreamDidDisconnect:self withError:connectError];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark C2S Connection
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connectToHost:(NSString *)host onPort:(UInt16)port withTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr {
    NSAssert(dispatch_get_specific(xmppQueueTag), @"Invoked on incorrect queue");
    
    QIMVerboseLog(@"connectToHost: %@ onPort: %ld withTimeout:%lld", host, port, timeout);

    BOOL result = [asyncSocket connectToHost:host onPort:port error:errPtr];
    
    if (result && [self resetByteCountPerConnection]) {
        numberOfBytesSent = 0;
        numberOfBytesReceived = 0;
    }
    
    if (result) {
        
        [self startConnectTimeout:timeout];
        
        /*
         
         CURL *curl;
         struct curl_slist *hostList = NULL;
         //        10.90.184.163
         NSString *newHost = [NSString stringWithFormat:@"{%@}:%hu:{%@}", host, port, @"10.90.184.163"];
         hostList = curl_slist_append(NULL, newHost.UTF8String);
         
         curl = curl_easy_init();
         if(curl) {
         curl_easy_setopt(curl, CURLOPT_RESOLVE, hostList);
         curl_easy_setopt(curl, CURLOPT_URL, host);
         curl_easy_perform(curl);
         
         // always cleanup
         curl_easy_cleanup(curl);
         }
         
         curl_slist_free_all(hostList);
         
         NSMutableDictionary *tlsSetting = [NSMutableDictionary dictionary];
         
         tlsSetting[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
         tlsSetting[GCDAsyncSocketException] = host;
         
         //[multicastDelegate pbXmppStream:self willSecureWithSettings:tlsSetting];
         [asyncSocket startTLS:tlsSetting];
         */
    }
    
    return result;
}

- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr {
    
    __block BOOL result = NO;
    __block NSError *err = nil;
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            if (state != STATE_PBXMPP_DISCONNECTED) {
                NSString *errMsg = @"Attempting to connect while already connected or connecting.";
                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                
                err = [NSError errorWithDomain:PBXMPPStreamErrorDomain code:XMPPStreamInvalidState userInfo:info];
                
                result = NO;
                return_from_block;
            }
            
            /*        if ([self isP2P])
             {
             NSString *errMsg = @"P2P streams must use either connectTo:withAddress: or connectP2PWithSocket:.";
             NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
             
             err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamInvalidType userInfo:info];
             
             result = NO;
             return_from_block;
             }*/
            
            if (myJID_setByClient == nil) {
                // Note: If you wish to use anonymous authentication, you should still set myJID prior to calling connect.
                // You can simply set it to something like "anonymous@<domain>", where "<domain>" is the proper domain.
                // After the authentication process, you can query the myJID property to see what your assigned JID is.
                //
                // Setting myJID allows the framework to follow the xmpp protocol properly,
                // and it allows the framework to connect to servers without a DNS entry.
                //
                // For example, one may setup a private xmpp server for internal testing on their local network.
                // The xmpp domain of the server may be something like "testing.mycompany.com",
                // but since the server is internal, an IP (192.168.1.22) is used as the hostname to connect.
                //
                // Proper connection requires a TCP connection to the IP (192.168.1.22),
                // but the xmpp handshake requires the xmpp domain (testing.mycompany.com).
                
                NSString *errMsg = @"You must set myJID before calling connect.";
                NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
                
                err = [NSError errorWithDomain:PBXMPPStreamErrorDomain code:XMPPStreamInvalidProperty userInfo:info];
                
                result = NO;
                return_from_block;
            }
            
            // Notify delegates
            [multicastDelegate pbXmppStreamWillConnect:self];
            
            if ([hostName length] == 0) {
                // Resolve the hostName via myJID SRV resolution
                
                state = STATE_PBXMPP_RESOLVING_SRV;
                
                result = YES;
            } else {
                // Open TCP connection to the configured hostName.
                
                state = STATE_PBXMPP_CONNECTING;
                
                NSError *connectErr = nil;
                
                PBXMPPCurrentTimeoutpos = (PBXMPPCurrentTimeoutpos++ < PBXMPPCurrentTimeoutCount ? PBXMPPCurrentTimeoutpos : 0);
                
                NSTimeInterval timeout = PBXMPPTimeoutArray[PBXMPPCurrentTimeoutpos];
                
                result = [self connectToHost:hostName onPort:hostPort withTimeout:timeout error:&connectErr];
                
                if (!result) {
                    err = connectErr;
                    state = STATE_PBXMPP_DISCONNECTED;
                }
            }
            
            if (result) {
                [self startConnectTimeout:timeout];
            }
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
    
    if (errPtr)
        *errPtr = err;
    
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)disconnectWithError:(NSError *)error {
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            if (state != STATE_PBXMPP_DISCONNECTED) {
                [multicastDelegate pbXmppStreamWasToldToDisconnect:self];
                
                if (state == STATE_PBXMPP_RESOLVING_SRV) {
//                    [srvResolver stop];
//                    srvResolver = nil;
                    
                    state = STATE_PBXMPP_DISCONNECTED;
                    
                    [multicastDelegate pbXmppStreamDidDisconnect:self withError:error];
                } else {
                    [asyncSocket disconnect];
//                    [asyncSocket disconnectWithError:error];
                    
                    // Everthing will be handled in socketDidDisconnect:withError:
                }
            }
        }
    };
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
}

/**
 * Closes the connection to the remote host.
 **/
- (void)disconnect {
    [self disconnectWithError:nil];
}

- (void)disconnectAfterSending {
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            if (state != STATE_PBXMPP_DISCONNECTED) {
                [multicastDelegate pbXmppStreamWasToldToDisconnect:self];
                
                if (state == STATE_PBXMPP_RESOLVING_SRV) {
//                    [srvResolver stop];
//                    srvResolver = nil;
                    
                    state = STATE_PBXMPP_DISCONNECTED;
                    
                    [multicastDelegate pbXmppStreamDidDisconnect:self withError:nil];
                } else {
                    ProtoMessageBuilder *builder = [ProtoMessage builder];
                    [builder setSignalType:SignalTypeSignalTypeStreamEnd];
                    [self sendProtobufMessage:[builder build]];
                    [asyncSocket disconnectAfterWriting];
                    
                    // Everthing will be handled in socketDidDisconnect:withError:
                }
            }
        }
    };
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Keep Alive
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupKeepAliveTimer {
    NSAssert(dispatch_get_specific(xmppQueueTag), @"Invoked on incorrect queue");
    
    if (keepAliveTimer) {
        dispatch_source_cancel(keepAliveTimer);
        keepAliveTimer = NULL;
    }

    if (state == STATE_PBXMPP_CONNECTED) {
        if (keepAliveInterval > 0) {
            keepAliveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, xmppQueue);
            
            dispatch_source_set_event_handler(keepAliveTimer, ^{
                @autoreleasepool {
                    
                    [self keepAlive];
                }
            });
            
#if !OS_OBJECT_USE_OBJC
            dispatch_source_t theKeepAliveTimer = keepAliveTimer;
            
            dispatch_source_set_cancel_handler(keepAliveTimer, ^{
                dispatch_release(theKeepAliveTimer);
            });
#endif
            
            // Everytime we send or receive data, we update our lastSendReceiveTime.
            // We set our timer to fire several times per keepAliveInterval.
            // This allows us to maintain a single timer,
            // and an acceptable timer resolution (assuming larger keepAliveIntervals).
            
            uint64_t interval = ((keepAliveInterval / 4.0) * NSEC_PER_SEC);
            
            dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, interval);
            
            dispatch_source_set_timer(keepAliveTimer, tt, interval, 1.0);
            dispatch_resume(keepAliveTimer);
        }
    }
}

- (void)keepAlive {
    NSAssert(dispatch_get_specific(xmppQueueTag), @"Invoked on incorrect queue");
    if (state == STATE_PBXMPP_CONNECTED) {
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval elapsed = (now - lastSendReceiveTime);
        if (elapsed <= 0 || elapsed >= keepAliveInterval) {
            
            [self sendHeartBeat];
            // Force update the lastSendReceiveTime here just to be safe.
            //
            // In case the TCP socket comes to a crawl with a giant element in the queue,
            // which would prevent the socket:didWriteDataWithTag: method from being called for some time.
            
            lastSendReceiveTime = [NSDate timeIntervalSinceReferenceDate];
        }
    }
}

#pragma mark -

- (void)sendPresenceMessage:(PresenceMessage *)message ToJid:(NSString *)jid {
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypePresence];
    [builder setFrom:[[self myJID] full]];
    [builder setTo:jid];
    [builder setMessage:message.data];
    [self sendProtobufMessage:[builder build]];
}

- (void)sendPresenceMessage:(PresenceMessage *)pMessage {
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setSignalType:SignalTypeSignalTypePresence];
    if ([[self myJID] full].length > 0) {
        [builder setFrom:[[self myJID] full]];
        [builder setMessage:pMessage.data];
        [self sendProtobufMessage:[builder build]];
    }
}

- (void)failToSendMessage:(ProtoMessage *)message error:(NSError *)error {
    
    switch (message.signalType) {
        case SignalTypeSignalTypeIq: {
            [multicastDelegate pbXmppStream:self didFailToSendIQ:message error:error];
        }
            break;
        case SignalTypeSignalTypePresence: {
            [multicastDelegate pbXmppStream:self didFailToSendPresence:message error:error];
        }
            break;
        default: {
            [multicastDelegate pbXmppStream:self didFailToSendMessage:message error:error];
        }
            break;
    }
}

- (void)cancelAllIQMessage {
    NSArray *keys = [[_messageDic allKeys] copy];
    for (NSString *uuid in keys) {
        if (uuid) {
            PBXMPPReceipt *parameters = [_messageDic objectForKey:uuid];
            [parameters signalFailure];
            @synchronized (self) {
                [_messageDic removeObjectForKey:uuid];
            }
        }
    }
    keys = nil;
}

- (IQMessage *)syncIQMessage:(IQMessage *)iqMessage ToJid:(NSString *)jid {
    assert(dispatch_get_current_queue() != xmppQueue);
    if (iqMessage && [self isAuthenticated]) {
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
        PBXMPPReceipt *receipt = nil;
        ProtoMessageBuilder *msgBuilder = [ProtoMessage builder];
        [msgBuilder setSignalType:SignalTypeSignalTypeIq];
        [msgBuilder setFrom:[[self myJID] full]];
        [msgBuilder setTo:jid];
        [msgBuilder setMessage:iqMessage.data];
        [self sendProtobufMessage:[msgBuilder build] andGetReceipt:&receipt];
        @synchronized (self) {
            if (receipt) {
                [_messageDic setObject:receipt forKey:iqMessage.messageId];
            } else {
                QIMVerboseLog(@"iq send faild, maybe tcp not connected.");
            }
        }
        [receipt wait:40];
        NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
        if ([receipt userInfo] == nil) {

        }
        return [receipt userInfo];
    }
    return nil;
}

- (IQMessage *)syncIQMessage:(IQMessage *)iqMessage {
    return [self syncIQMessage:iqMessage ToJid:nil];
}

- (void)sendProtobufMessage:(ProtoMessage *)message {
    if (message == nil) return;
    dispatch_block_t block = ^{
        @autoreleasepool {
            if (state == STATE_PBXMPP_CONNECTED) {
                [multicastDelegate pbXmppStream:self recordLog:[message description] withDirection:MsgDirection_Send];
                [self writeData:[pbXmppParser bulidPackageForProtoMessage:message] withTimeout:TIMEOUT_XMPP_WRITE tag:TAG_XMPP_WRITE_STREAM];
            } else {
                NSError *error = [NSError errorWithDomain:PBXMPPStreamErrorDomain code:XMPPStreamInvalidState userInfo:nil];
                [self failToSendMessage:message error:error];
            }
        }
    };
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (void)sendProtobufMessage:(ProtoMessage *)message andGetReceipt:(PBXMPPReceipt **)receiptPtr {
    if (message == nil) return;
    if (receiptPtr == nil) {
        [self sendProtobufMessage:message];
    } else {
        __block PBXMPPReceipt *receipt = nil;
        
        dispatch_block_t block = ^{
            @autoreleasepool {
                
                if (state == STATE_PBXMPP_CONNECTED) {
                    receipt = [[PBXMPPReceipt alloc] init];
                    if (message.signalType != SignalTypeSignalTypeIq) {
                        [receipts addObject:receipt];
                    }
                    [multicastDelegate pbXmppStream:self recordLog:[message description] withDirection:MsgDirection_Send];
                    [self writeData:[pbXmppParser bulidPackageForProtoMessage:message] withTimeout:TIMEOUT_XMPP_WRITE tag:TAG_XMPP_WRITE_RECEIPT];
                } else {
                    NSError *error = [NSError errorWithDomain:PBXMPPStreamErrorDomain code:XMPPStreamInvalidState userInfo:nil];
                    [self failToSendMessage:message error:error];
                }
            }
        };
        if (dispatch_get_specific(xmppQueueTag))
            block();
        else
            dispatch_sync(xmppQueue, block);
        *receiptPtr = receipt;
    }
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    NSData *newData = data;
    
    numberOfBytesSent += [newData length];
    [asyncSocket writeData:newData withTimeout:timeout tag:tag];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    [asyncSocket readDataWithTimeout:timeout tag:tag];
}

- (void)registerModule:(QIMProtobufModel *)module {
    if (module == nil) return;
    
    // Asynchronous operation
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            // Register module
            
            [registeredModules addObject:module];
            
            // Add auto delegates (if there are any)
            
            NSString *className = NSStringFromClass([module class]);
            QIMGCDMulticastDelegate *autoDelegates = [autoDelegateDict objectForKey:className];
            
            QIMGCDMulticastDelegateEnumerator *autoDelegatesEnumerator = [autoDelegates delegateEnumerator];
            id delegate;
            dispatch_queue_t delegateQueue;
            
            while ([autoDelegatesEnumerator getNextDelegate:&delegate delegateQueue:&delegateQueue]) {
                [module addDelegate:delegate delegateQueue:delegateQueue];
            }
            
            // Notify our own delegate(s)
            
            [multicastDelegate pbXmppStream:self didRegisterModule:module];
            
        }
    };
    
    // Asynchronous operation
    
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_async(xmppQueue, block);
}

- (void)unregisterModule:(QIMProtobufModel *)module {
    if (module == nil) return;
    
    // Synchronous operation
    
    dispatch_block_t block = ^{
        @autoreleasepool {
            
            // Notify our own delegate(s)
            
            [multicastDelegate pbXmppStream:self willUnregisterModule:module];
            
            // Remove auto delegates (if there are any)
            
            NSString *className = NSStringFromClass([module class]);
            QIMGCDMulticastDelegate *autoDelegates = [autoDelegateDict objectForKey:className];
            
            QIMGCDMulticastDelegateEnumerator *autoDelegatesEnumerator = [autoDelegates delegateEnumerator];
            id delegate;
            dispatch_queue_t delegateQueue;
            
            while ([autoDelegatesEnumerator getNextDelegate:&delegate delegateQueue:&delegateQueue]) {
                // The module itself has dispatch_sync'd in order to invoke its deactivate method,
                // which has in turn invoked this method. If we call back into the module,
                // and have it dispatch_sync again, we're going to get a deadlock.
                // So we must remove the delegate(s) asynchronously.
                
                [module removeDelegate:delegate delegateQueue:delegateQueue synchronously:NO];
            }
            
            // Unregister modules
            
            [registeredModules removeObject:module];
            
        }
    };
    
    // Synchronous operation
    if (dispatch_get_specific(xmppQueueTag))
        block();
    else
        dispatch_sync(xmppQueue, block);
}
@end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PBXMPPReceipt

static const uint32_t receipt_unknown = 0 << 0;
static const uint32_t receipt_failure = 1 << 0;
static const uint32_t receipt_success = 1 << 1;

- (id)init {
    if ((self = [super init])) {
        atomicFlags = receipt_unknown;
        semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)signalSuccess {
    uint32_t mask = receipt_success;
    OSAtomicOr32Barrier(mask, &atomicFlags);
    
    dispatch_semaphore_signal(semaphore);
}

- (void)signalFailure {
    uint32_t mask = receipt_failure;
    OSAtomicOr32Barrier(mask, &atomicFlags);
    
    dispatch_semaphore_signal(semaphore);
}

- (BOOL)wait:(NSTimeInterval)timeout_seconds {
    uint32_t mask = 0;
    uint32_t flags = OSAtomicOr32Barrier(mask, &atomicFlags);
    
    if (flags != receipt_unknown) return (flags == receipt_success);
    
    dispatch_time_t timeout_nanos;
    
    if (isless(timeout_seconds, 0.0))
        timeout_nanos = DISPATCH_TIME_FOREVER;
    else
        timeout_nanos = dispatch_time(DISPATCH_TIME_NOW, (timeout_seconds * NSEC_PER_SEC));
    
    // dispatch_semaphore_wait
    //
    // Decrement the counting semaphore. If the resulting value is less than zero,
    // this function waits in FIFO order for a signal to occur before returning.
    //
    // Returns zero on success, or non-zero if the timeout occurred.
    //
    // Note: If the timeout occurs, the semaphore value is incremented (without signaling).
    
    long result = dispatch_semaphore_wait(semaphore, timeout_nanos);
    
    if (result == 0) {
        flags = OSAtomicOr32Barrier(mask, &atomicFlags);
        
        return (flags == receipt_success);
    } else {
        // Timed out waiting...
        return NO;
    }
}

- (void)dealloc {
#if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
#endif
}

@end
