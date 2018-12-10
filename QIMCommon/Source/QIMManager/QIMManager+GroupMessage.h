//
//  QIMManager+GroupMessage.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMManager.h"

@interface QIMManager (GroupMessage)

- (void)updateLastGroupMsgTime;

- (void)updateLastMaxMucReadMarkTime;

- (void)checkGroupChatMsg;

- (void)updateOfflineGroupMessages;

- (NSArray *)getMucMsgListWihtGroupId:(NSString *)groupId WithDirection:(int)direction WithLimit:(int)limit WithVersion:(long long)version;

- (void)updateMucReadMark;

@end
