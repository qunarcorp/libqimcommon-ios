//
//  STIMKit+STIMSingleMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "STIMKit+STIMSingleMessage.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMSingleMessage)

- (void)checkSingleChatMsg {
    [[STIMManager sharedInstance] checkSingleChatMsg];
}

- (void)updateLastMsgTime {
    [[STIMManager sharedInstance] updateLastMsgTime];
}

- (void)getReadFlag {
    [[STIMManager sharedInstance] getReadFlag];
}

#warning 这里更新本地数据库已接收的消息状态 ，告诉对方已送达，readFlag=3，更新成功之后更新本地数据库状态
- (void)sendRecevieMessageState {
    [[STIMManager sharedInstance] sendRecevieMessageState];
}

- (BOOL)updateOfflineMessagesV2 {
    return [[STIMManager sharedInstance] updateOfflineMessagesV2];
}

#warning 单人聊天消息

#pragma mark - 单人ConsultServer消息（下拉加载） qchatId = 5

#pragma mark - 单人历史消息（下拉加载）

- (NSArray *)getUserChatlogWithFrom:(NSString *)from to:(NSString *)to version:(long long)version count:(int)count direction:(int)direction include:(BOOL)include {
    return [[STIMManager sharedInstance] getUserChatlogWithFrom:from to:to version:version count:count direction:direction include:include];
}

@end
