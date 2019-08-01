//
//  QIMXMPPJID.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/22.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>

enum XMPPJIDCompareOptions
{
    XMPPJIDCompareUser     = 1, // 001
    XMPPJIDCompareDomain   = 2, // 010
    XMPPJIDCompareResource = 4, // 100
    
    XMPPJIDCompareBare     = 3, // 011
    XMPPJIDCompareFull     = 7, // 111
};
typedef enum XMPPJIDCompareOptions XMPPJIDCompareOptions;

@interface QIMXMPPJID : NSObject <NSCoding, NSCopying>

{
    __strong NSString *user;
    __strong NSString *domain;
    __strong NSString *resource;
}

+ (QIMXMPPJID *)jidWithString:(NSString *)jidStr;
+ (QIMXMPPJID *)jidWithString:(NSString *)jidStr resource:(NSString *)resource;
+ (QIMXMPPJID *)jidWithUser:(NSString *)user domain:(NSString *)domain resource:(NSString *)resource;

@property (strong, readonly) NSString *user;
@property (strong, readonly) NSString *domain;
@property (strong, readonly) NSString *resource;

/**
 * Terminology (from RFC 6120):
 *
 * The term "bare JID" refers to an XMPP address of the form <localpart@domainpart> (for an account at a server)
 * or of the form <domainpart> (for a server).
 *
 * The term "full JID" refers to an XMPP address of the form
 * <localpart@domainpart/resourcepart> (for a particular authorized client or device associated with an account)
 * or of the form <domainpart/resourcepart> (for a particular resource or script associated with a server).
 *
 * Thus a bareJID is one that does not have a resource.
 * And a fullJID is one that does have a resource.
 *
 * For convenience, there are also methods that that check for a user component as well.
 **/

- (QIMXMPPJID *)bareJID;
- (QIMXMPPJID *)domainJID;

- (NSString *)bare;
- (NSString *)full;

- (BOOL)isBare;
- (BOOL)isBareWithUser;

- (BOOL)isFull;
- (BOOL)isFullWithUser;

/**
 * A server JID does not have a user component.
 **/
- (BOOL)isServer;

/**
 * Returns a new jid with the given resource.
 **/
- (QIMXMPPJID *)jidWithNewResource:(NSString *)resource;

- (BOOL)isEqualToJID:(QIMXMPPJID *)aJID;

- (BOOL)isEqualToJID:(QIMXMPPJID *)aJID options:(XMPPJIDCompareOptions)mask;

@end
