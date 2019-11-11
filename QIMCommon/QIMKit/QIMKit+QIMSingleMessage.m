//
//  QIMKit+QIMSingleMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit+QIMSingleMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMSingleMessage)

- (void)checkSingleChatMsg {
    [[QIMManager sharedInstance] checkSingleChatMsg];
}

- (void)updateLastMsgTime {
    [[QIMManager sharedInstance] updateLastMsgTime];
}

- (void)getReadFlag {
    [[QIMManager sharedInstance] getReadFlag];
}

#warning 这里更新本地数据库已接收的消息状态 ，告诉对方已送达，readFlag=3，更新成功之后更新本地数据库状态
- (void)sendRecevieMessageState {
    [[QIMManager sharedInstance] sendRecevieMessageState];
}

- (BOOL)updateOfflineMessagesV2 {
    return [[QIMManager sharedInstance] updateOfflineMessagesV2];
}

@end
