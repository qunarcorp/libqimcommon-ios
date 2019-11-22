//
//  STIMKit+STIMSystemMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "STIMKit+STIMSystemMessage.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMSystemMessage)

#pragma mark - 系统消息

- (void)checkHeadlineMsg {
    [[STIMManager sharedInstance] checkHeadlineMsg];
}

- (void)updateLastSystemMsgTime {
    [[STIMManager sharedInstance] updateLastSystemMsgTime];
}

- (void)updateOfflineSystemNoticeMessages {
    [[STIMManager sharedInstance] updateOfflineSystemNoticeMessages];
}

- (void)getSystemMsgLisByUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getSystemMsgLisByUserId:userId WithFromHost:fromHost WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

@end
