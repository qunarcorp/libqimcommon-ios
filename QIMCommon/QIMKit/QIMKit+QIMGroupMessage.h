//
//  QIMKit+QIMGroupMessage.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit.h"

@interface QIMKit (QIMGroupMessage)

- (void)updateLastGroupMsgTime;

- (void)checkGroupChatMsg;

- (void)updateOfflineGroupMessages;

- (void)updateMucReadMark;

@end
