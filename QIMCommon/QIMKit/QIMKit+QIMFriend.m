//
//  QIMKit+QIMFriend.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit+QIMFriend.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMFriend)


- (NSMutableDictionary *)getFriendListDict {
    return [[QIMManager sharedInstance] getFriendListDict];
}


- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)xmppId {
    return [[QIMManager sharedInstance] getVerifyFreindModeWithXmppId:xmppId];
}

- (BOOL)setVerifyFreindMode:(int)mode WithQuestion:(NSString *)question WithAnswer:(NSString *)answer {
    
    return [[QIMManager sharedInstance] setVerifyFreindMode:mode WithQuestion:question WithAnswer:answer];
}

- (NSString *)getFriendsJson {
    return [[QIMManager sharedInstance] getFriendsJson];
}

- (void)updateFriendList {
    [[QIMManager sharedInstance] updateFriendList];
}

- (void)addFriendPresenceWithXmppId:(NSString *)xmppId WithAnswer:(NSString *)answer {
    [[QIMManager sharedInstance] addFriendPresenceWithXmppId:xmppId WithAnswer:answer];
}

- (void)validationFriendWithXmppId:(NSString *)xmppId WithReason:(NSString *)reason {
    [[QIMManager sharedInstance] validationFriendWithXmppId:xmppId WithReason:reason];
}

- (void)agreeFriendRequestWithXmppId:(NSString *)xmppId {
    [[QIMManager sharedInstance] agreeFriendRequestWithXmppId:xmppId];
}

- (void)refusedFriendRequestWithXmppId:(NSString *)xmppId {
    [[QIMManager sharedInstance] refusedFriendRequestWithXmppId:xmppId];
}

//1.删除好友,客户端请求，其中mode1为单项删除，mode为2为双项删除
- (BOOL)deleteFriendWithXmppId:(NSString *)xmppId WithMode:(int)mode {
    
    return [[QIMManager sharedInstance] deleteFriendWithXmppId:xmppId WithMode:mode];
}

- (int)getReceiveMsgLimitWithXmppId:(NSString *)xmppId {
    
    return [[QIMManager sharedInstance] getReceiveMsgLimitWithXmppId:xmppId];
}

- (BOOL)setReceiveMsgLimitWithMode:(int)mode {
    
    return [[QIMManager sharedInstance] setReceiveMsgLimitWithMode:mode];
}

- (void)updateFriendInviteList {
    
    [[QIMManager sharedInstance] updateFriendInviteList];
}

- (NSDictionary *)getLastFriendNotify {
    return [[QIMManager sharedInstance]  getLastFriendNotify];
}

- (NSInteger)getFriendNotifyCount {
    return [[QIMManager sharedInstance] getFriendNotifyCount];
}

@end
