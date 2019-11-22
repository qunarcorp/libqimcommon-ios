//
//  QIMManager+SingleMessage.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager.h"

@interface QIMManager (SingleMessage)

- (void)checkSingleChatMsg;

- (void)updateLastMsgTime;

- (void)getReadFlag;

- (void)sendRecevieMessageState;

- (BOOL)updateOfflineMessagesV2;

- (void)getUserChatlogWithFrom:(NSString *)from to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction include:(BOOL)include withCallBack:(QIMKitGetUserChatMsgListCallBack)callback;

- (void)getConsultServerlogWithFrom:(NSString *)from virtualId:(NSString *)virtualId to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction withCallBack:(QIMKitGetConsultServerMsgListCallBack)callback;

@end
