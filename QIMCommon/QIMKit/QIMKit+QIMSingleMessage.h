//
//  QIMKit+QIMSingleMessage.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit.h"

@interface QIMKit (QIMSingleMessage)

- (void)checkSingleChatMsg;

/**
 更新最后一条单人消息时间
 */
- (void)updateLastMsgTime;

- (void)getReadFlag;

- (void)sendRecevieMessageState;

- (BOOL)updateOfflineMessagesV2;

@end
