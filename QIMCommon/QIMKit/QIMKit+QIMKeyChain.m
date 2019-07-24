//
//  QIMKit+QIMKeyChain.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "QIMKit+QIMKeyChain.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMKeyChain)

+ (void)updateSessionListToKeyChain {
    [QIMManager updateSessionListToKeyChain];
}

+ (void)updateGroupListToKeyChain {
    [QIMManager updateGroupListToKeyChain];
}

+ (void)updateFriendListToKeyChain {
    [QIMManager updateFriendListToKeyChain];
}

+ (void)updateRequestFileURL {
    [QIMManager updateRequestFileURL];
}

+ (void)updateRequestURL {
    [QIMManager updateRequestURL];
}

+ (void)updateNewHttpRequestURL {
    [QIMManager updateNewHttpRequestURL];
}

+ (void)updateRequestDomain {
    [QIMManager updateRequestDomain];
}

@end
