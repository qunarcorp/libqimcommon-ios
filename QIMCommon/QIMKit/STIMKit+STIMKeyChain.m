//
//  STIMKit+STIMKeyChain.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "STIMKit+STIMKeyChain.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMKeyChain)

+ (void)updateSessionListToKeyChain {
    [STIMManager updateSessionListToKeyChain];
}

+ (void)updateGroupListToKeyChain {
    [STIMManager updateGroupListToKeyChain];
}

+ (void)updateFriendListToKeyChain {
    [STIMManager updateFriendListToKeyChain];
}

+ (void)updateRequestFileURL {
    [STIMManager updateRequestFileURL];
}

+ (void)updateRequestURL {
    [STIMManager updateRequestURL];
}

+ (void)updateNewHttpRequestURL {
    [STIMManager updateNewHttpRequestURL];
}

+ (void)updateRequestDomain {
    [STIMManager updateRequestDomain];
}

@end
