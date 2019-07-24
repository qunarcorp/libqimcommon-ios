//
//  QIMKit+QIMSystemMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit+QIMSystemMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMSystemMessage)

#pragma mark - 系统消息

- (void)checkHeadlineMsg {
    [[QIMManager sharedInstance] checkHeadlineMsg];
}

- (void)updateLastSystemMsgTime {
    [[QIMManager sharedInstance] updateLastSystemMsgTime];
}

- (void)updateOfflineSystemNoticeMessages {
    [[QIMManager sharedInstance] updateOfflineSystemNoticeMessages];
}

- (void)getSystemMsgLisByUserId:(NSString *)userId WithFromHost:(NSString *)fromHost WithLimit:(int)limit WithOffset:(int)offset withLoadMore:(BOOL)loadMore WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getSystemMsgLisByUserId:userId WithFromHost:fromHost WithLimit:limit WithOffset:offset withLoadMore:loadMore WithComplete:complete];
}

@end
