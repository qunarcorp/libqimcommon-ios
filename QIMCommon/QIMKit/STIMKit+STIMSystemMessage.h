//
//  STIMKit+STIMSystemMessage.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "STIMKit.h"

@interface STIMKit (STIMSystemMessage)

- (void)checkHeadlineMsg;

- (void)updateLastSystemMsgTime;

- (void)updateOfflineSystemNoticeMessages;

- (void)getSystemMsgLisByUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete;

@end
