//
//  QIMManager+Friend.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager.h"

@interface QIMManager (Friend)

- (NSMutableDictionary *)getFriendListDict;

- (void)updateFriendList;

- (void)updateFriendInviteList;

#pragma mark - friend
- (NSDictionary *)getVerifyFreindModeWithXmppId:(NSString *)userId;
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

- (NSDictionary *)getLastFriendNotify;

- (NSInteger)getFriendNotifyCount;

@end
