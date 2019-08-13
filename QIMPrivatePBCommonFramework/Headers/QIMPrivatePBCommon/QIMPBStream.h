//
//  QIMPBStream.h
//  qunarChatCommon
//
//  Created by admin on 16/10/9.
//  Copyright © 2016年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMProtobufModel.h"

enum PBXMPPStreamState {
    STATE_PBXMPP_DISCONNECTED,
    STATE_PBXMPP_RESOLVING_SRV,
    STATE_PBXMPP_CONNECTING,
    STATE_PBXMPP_OPENING,
    STATE_PBXMPP_NEGOTIATING,
    STATE_PBXMPP_STARTTLS_1,
    STATE_PBXMPP_STARTTLS_2,
    STATE_PBXMPP_POST_NEGOTIATION,
    STATE_PBXMPP_REGISTERING,
    STATE_PBXMPP_AUTH,
    STATE_PBXMPP_BINDING,
    STATE_PBXMPP_START_SESSION,
    STATE_PBXMPP_CONNECTED,
};

typedef enum PBXMPPStreamState XMPPStreamState;

@class GCDAsyncSocket, QIMXMPPJID, ProtoMessage, IQMessage, PresenceMessage;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface PBXMPPReceipt : NSObject {
    uint32_t atomicFlags;
    dispatch_semaphore_t semaphore;
}
@property(nonatomic, strong) id userInfo;

/**
 * Element receipts allow you to check to see if the element has been sent.
 * The timeout parameter allows you to do any of the following:
 *
 * - Do an instantaneous check (pass timeout == 0)
 * - Wait until the element has been sent (pass timeout < 0)
 * - Wait up to a certain amount of time (pass timeout > 0)
 *
 * It is important to understand what it means when [receipt wait:timeout] returns YES.
 * It does NOT mean the server has received the element.
 * It only means the data has been queued for sending in the underlying OS socket buffer.
 *
 * So at this point the OS will do everything in its capacity to send the data to the server,
 * which generally means the server will eventually receive the data.
 * Unless, of course, something horrible happens such as a network failure,
 * or a system crash, or the server crashes, etc.
 *
 * Even if you close the xmpp stream after this point, the OS will still do everything it can to send the data.
 **/
- (BOOL)wait:(NSTimeInterval)timeout;

- (void)signalSuccess;

- (void)signalFailure;
@end

@interface QIMPBStream : NSObject
// test
+ (void)testQIMPBStream;

@property(readonly) dispatch_queue_t xmppQueue;
@property(readonly) void *xmppQueueTag;
@property(readonly) XMPPStreamState state;

@property(nonatomic, assign) int loginType;
@property(readwrite, copy) QIMXMPPJID *myJID;
@property(readwrite, copy) NSString *password;
@property(readwrite, copy) NSString *hostName;
@property(nonatomic, copy) NSString *deviceUUID;
@property(readwrite, assign) UInt16 hostPort;
@property(nonatomic, assign) long long serviceTime;
@property(nonatomic, strong) NSString *remoteKey;

/**
 * Start TLS is used if the server supports it, regardless of wether it is required or not.
 *
 * The default is NO
 **/
@property(readwrite, assign) BOOL autoStartTLS;

+ (NSString *)generateUUID;

- (id)init;

- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr;

- (void)disconnect;

- (void)disconnectAfterSending;

- (BOOL)authenticateWithPassword:(NSString *)inPassword error:(NSError **)errPtr;

- (void)sendProtobufMessage:(ProtoMessage *)message;

- (void)sendProtobufMessage:(ProtoMessage *)message andGetReceipt:(PBXMPPReceipt **)receiptPtr;

- (void)sendPresenceMessage:(PresenceMessage *)message;

- (void)sendPresenceMessage:(PresenceMessage *)message ToJid:(NSString *)jid;

- (IQMessage *)syncIQMessage:(IQMessage *)message;

- (IQMessage *)syncIQMessage:(IQMessage *)message ToJid:(NSString *)jid;

- (void)cancelAllIQMessage;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate;

#if TARGET_OS_IPHONE

/**
 * If set, the kCFStreamNetworkServiceTypeVoIP flags will be set on the underlying CFRead/Write streams.
 *
 * The default value is NO.
 **/
@property (readwrite, assign) BOOL enableBackgroundingOnSocket;

#endif

#pragma mark State

- (void)sendHeartBeat;

- (BOOL)isDisconnected;

- (BOOL)isConnecting;

- (BOOL)isConnected;

- (BOOL)isAuthenticated;

- (void)registerModule:(QIMProtobufModel *)reconnector;

- (void)unregisterModule:(QIMProtobufModel *)reconnector;

@end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol PBXMPPStreamDelegate
@optional

/**
 * This method is called before the stream begins the connection process.
 *
 * If developing an iOS app that runs in the background, this may be a good place to indicate
 * that this is a task that needs to continue running in the background.
 **/
- (void)pbXmppStreamWillConnect:(QIMPBStream *)sender;

/**
 * This method is called after the tcp socket has connected to the remote host.
 * It may be used as a hook for various things, such as updating the UI or extracting the server's IP address.
 *
 * If developing an iOS app that runs in the background,
 * please use XMPPStream's enableBackgroundingOnSocket property as opposed to doing it directly on the socket here.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender socketDidConnect:(GCDAsyncSocket *)socket;

/**
 * This method is called after a TCP connection has been established with the server,
 * and the opening XML stream negotiation has started.
 **/
- (void)pbXmppStreamDidStartNegotiation:(QIMPBStream *)sender;

/**
 * This method is called immediately prior to the stream being secured via TLS/SSL.
 * Note that this delegate may be called even if you do not explicitly invoke the startTLS method.
 * Servers have the option of requiring connections to be secured during the opening process.
 * If this is the case, the XMPPStream will automatically attempt to properly secure the connection.
 *
 * The possible keys and values for the security settings are well documented.
 * Some possible keys are:
 * - kCFStreamSSLLevel
 * - kCFStreamSSLAllowsExpiredCertificates
 * - kCFStreamSSLAllowsExpiredRoots
 * - kCFStreamSSLAllowsAnyRoot
 * - kCFStreamSSLValidatesCertificateChain
 * - kCFStreamSSLPeerName
 * - kCFStreamSSLCertificates
 *
 * Please refer to Apple's documentation for associated values, as well as other possible keys.
 *
 * The dictionary of settings is what will be passed to the startTLS method of ther underlying AsyncSocket.
 * The AsyncSocket header file also contains a discussion of the security consequences of various options.
 * It is recommended reading if you are planning on implementing this method.
 *
 * The dictionary of settings that are initially passed will be an empty dictionary.
 * If you choose not to implement this method, or simply do not edit the dictionary,
 * then the default settings will be used.
 * That is, the kCFStreamSSLPeerName will be set to the configured host name,
 * and the default security validation checks will be performed.
 *
 * This means that authentication will fail if the name on the X509 certificate of
 * the server does not match the value of the hostname for the xmpp stream.
 * It will also fail if the certificate is self-signed, or if it is expired, etc.
 *
 * These settings are most likely the right fit for most production environments,
 * but may need to be tweaked for development or testing,
 * where the development server may be using a self-signed certificate.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings;

/**
 * This method is called after the stream has been secured via SSL/TLS.
 * This method may be called if the server required a secure connection during the opening process,
 * or if the secureConnection: method was manually invoked.
 **/
- (void)pbXmppStreamDidSecure:(QIMPBStream *)sender;

/**
 * This method is called after the XML stream has been fully opened.
 * More precisely, this method is called after an opening <xml/> and <stream:stream/> tag have been sent and received,
 * and after the stream features have been received, and any required features have been fullfilled.
 * At this point it's safe to begin communication with the server.
 **/
- (void)pbXmppStreamDidConnect:(QIMPBStream *)sender;

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
- (void)pbXmppStreamDidRegister:(QIMPBStream *)sender;

/**
 * This method is called if registration fails.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didNotRegister:(ProtoMessage *)error;

/**
 * This method is called after authentication has successfully finished.
 * If authentication fails for some reason, the xmppStream:didNotAuthenticate: method will be called instead.
 **/
- (void)pbXmppStreamDidAuthenticate:(QIMPBStream *)sender;

/**
 * This method is called if authentication fails.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didNotAuthenticate:(ProtoMessage *)error;

/**
 * This method is called if the XMPP server doesn't allow our resource of choice
 * because it conflicts with an existing resource.
 *
 * Return an alternative resource or return nil to let the server automatically pick a resource for us.
 **/
- (NSString *)pbXmppStream:(QIMPBStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource;

/**
 * These methods are called before their respective XML elements are broadcast as received to the rest of the stack.
 * These methods can be used to modify elements on the fly.
 * (E.g. perform custom decryption so the rest of the stack sees readable text.)
 *
 * You may also filter incoming elements by returning nil.
 *
 * When implementing these methods to modify the element, you do not need to copy the given element.
 * You can simply edit the given element, and return it.
 * The reason these methods return an element, instead of void, is to allow filtering.
 *
 * Concerning thread-safety, delegates implementing the method are invoked one-at-a-time to
 * allow thread-safe modification of the given elements.
 *
 * You should NOT implement these methods unless you have good reason to do so.
 * For general processing and notification of received elements, please use xmppStream:didReceiveX: methods.
 *
 * @see xmppStream:didReceiveIQ:
 * @see xmppStream:didReceiveMessage:
 * @see xmppStream:didReceivePresence:
 **/
- (id)pbXmppStream:(QIMPBStream *)sender willReceiveIQ:(id)iq;

- (id)pbXmppStream:(QIMPBStream *)sender willReceiveMessage:(id)message;

- (id)pbXmppStream:(QIMPBStream *)sender willReceivePresence:(id)presence;

/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 **/
- (BOOL)pbXmppStream:(QIMPBStream *)sender didReceiveIQ:(IQMessage *)iq;

- (void)pbXmppStream:(QIMPBStream *)sender didReceiveMessage:(ProtoMessage *)message;

- (void)pbXmppStream:(QIMPBStream *)sender didReceivePresenceKeyNotify:(PresenceMessage *)pMessage;

- (void)pbXmppStream:(QIMPBStream *)sender didReceivePresence:(PresenceMessage *)presence;

/**
 * This method is called if an XMPP error is received.
 * In other words, a <stream:error/>.
 *
 * However, this method may also be called for any unrecognized xml stanzas.
 *
 * Note that standard errors (<iq type='error'/> for example) are delivered normally,
 * via the other didReceive...: methods.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didReceiveError:(ProtoMessage *)error;

/**
 * These methods are called before their respective XML elements are sent over the stream.
 * These methods can be used to modify outgoing elements on the fly.
 * (E.g. add standard information for custom protocols.)
 *
 * You may also filter outgoing elements by returning nil.
 *
 * When implementing these methods to modify the element, you do not need to copy the given element.
 * You can simply edit the given element, and return it.
 * The reason these methods return an element, instead of void, is to allow filtering.
 *
 * Concerning thread-safety, delegates implementing the method are invoked one-at-a-time to
 * allow thread-safe modification of the given elements.
 *
 * You should NOT implement these methods unless you have good reason to do so.
 * For general processing and notification of sent elements, please use xmppStream:didSendX: methods.
 *
 * @see xmppStream:didSendIQ:
 * @see xmppStream:didSendMessage:
 * @see xmppStream:didSendPresence:
 **/
- (id)pbXmppStream:(QIMPBStream *)sender willSendIQ:(id)iq;

- (id)pbXmppStream:(QIMPBStream *)sender willSendMessage:(id)message;

- (id)pbXmppStream:(QIMPBStream *)sender willSendPresence:(id)presence;

/**
 * These methods are called after their respective XML elements are sent over the stream.
 * These methods may be used to listen for certain events (such as an unavailable presence having been sent),
 * or for general logging purposes. (E.g. a central history logging mechanism).
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didSendIQ:(id)iq;

- (void)pbXmppStream:(QIMPBStream *)sender didSendMessage:(id)message;

- (void)pbXmppStream:(QIMPBStream *)sender didSendPresence:(id)presence;

- (void)pbXmppStream:(QIMPBStream *)sender recordLog:(NSString *)log withDirection:(int)direction;

/**
 * These methods are called after failing to send the respective XML elements over the stream.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didFailToSendIQ:(ProtoMessage *)iq error:(NSError *)error;

- (void)pbXmppStream:(QIMPBStream *)sender didFailToSendMessage:(ProtoMessage *)message error:(NSError *)error;

- (void)pbXmppStream:(QIMPBStream *)sender didFailToSendPresence:(ProtoMessage *)presence error:(NSError *)error;

/**
 * This method is called if the disconnect method is called.
 * It may be used to determine if a disconnection was purposeful, or due to an error.
 **/
- (void)pbXmppStreamWasToldToDisconnect:(QIMPBStream *)sender;

/**
 * This methods is called if the XMPP Stream's connect times out
 **/
- (void)pbXmppStreamConnectDidTimeout:(QIMPBStream *)sender;

/**
 * This method is called after the stream is closed.
 *
 * The given error parameter will be non-nil if the error was due to something outside the general xmpp realm.
 * Some examples:
 * - The TCP socket was unexpectedly disconnected.
 * - The SRV resolution of the domain failed.
 * - Error parsing xml sent from server.
 **/
- (void)pbXmppStreamDidDisconnect:(QIMPBStream *)sender withError:(NSError *)error;

/**
 * This method is only used in P2P mode when the connectTo:withAddress: method was used.
 *
 * It allows the delegate to read the <stream:features/> element if/when they arrive.
 * Recall that the XEP specifies that <stream:features/> SHOULD be sent.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didReceiveP2PFeatures:(ProtoMessage *)streamFeatures;

/**
 * This method is only used in P2P mode when the connectTo:withSocket: method was used.
 *
 * It allows the delegate to customize the <stream:features/> element,
 * adding any specific featues the delegate might support.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender willSendP2PFeatures:(ProtoMessage *)streamFeatures;

/**
 * These methods are called as xmpp modules are registered and unregistered with the stream.
 * This generally corresponds to xmpp modules being initailzed and deallocated.
 *
 * The methods may be useful, for example, if a more precise auto delegation mechanism is needed
 * than what is available with the autoAddDelegate:toModulesOfClass: method.
 **/
- (void)pbXmppStream:(QIMPBStream *)sender didRegisterModule:(id)module;

- (void)pbXmppStream:(QIMPBStream *)sender willUnregisterModule:(id)module;

- (void)pbXmppStreamEndStream:(QIMPBStream *)sender didReceiveMessgae:(ProtoMessage *)message;


@end
