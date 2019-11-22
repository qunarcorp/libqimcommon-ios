//
//  STIMKit+STIMFriend.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "STIMKit+STIMFriend.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMFriend)


- (NSMutableDictionary *)getFriendListDict {
    return [[STIMManager sharedInstance] getFriendListDict];
}


- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)xmppId {
    return [[STIMManager sharedInstance] getVerifyFreindModeWithXmppId:xmppId];
}

- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer {
    
    return [[STIMManager sharedInstance] setVerifyFreindMode:mode WithQuestion:question WithAnswer:answer];
}

- (NSString *)getFriendsJson {
    return [[STIMManager sharedInstance] getFriendsJson];
}

- (void)updateFriendList {
    [[STIMManager sharedInstance] updateFriendList];
}

- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer {
    [[STIMManager sharedInstance] addFriendPresenceWithXmppId:xmppId WithAnswer:answer];
}

- (void)validationFriendWithXmppId:(NSString *)xmppId WithReason:(NSString *)reason {
    [[STIMManager sharedInstance] validationFriendWithXmppId:xmppId WithReason:reason];
}

- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId {
    [[STIMManager sharedInstance] agreeFriendRequestWithXmppId:xmppId];
}

- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId {
    [[STIMManager sharedInstance] refusedFriendRequestWithXmppId:xmppId];
}

//1.删除好友,客户端请求，其中mode1为单项删除，mode为2为双项删除
- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode {
    
    return [[STIMManager sharedInstance] deleteFriendWithXmppId:xmppId WithMode:mode];
}

- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId {
    
    return [[STIMManager sharedInstance] getReceiveMsgLimitWithXmppId:xmppId];
}

- (BOOL)setReceiveMsgLimitWithMode:(int)mode {
    
    return [[STIMManager sharedInstance] setReceiveMsgLimitWithMode:mode];
}

- (void)updateFriendInviteList {
    
    [[STIMManager sharedInstance] updateFriendInviteList];
}

- (NSDictionary *)getLastFriendNotify {
    return [[STIMManager sharedInstance]  getLastFriendNotify];
}

- (NSInteger)getFriendNotifyCount {
    return [[STIMManager sharedInstance] getFriendNotifyCount];
}

@end
