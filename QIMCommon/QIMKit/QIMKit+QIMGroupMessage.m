//
//  QIMKit+QIMGroupMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "QIMKit+QIMGroupMessage.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMGroupMessage)

- (void)updateLastGroupMsgTime {
    [[QIMManager sharedInstance] updateLastGroupMsgTime];
}

- (void)checkGroupChatMsg {
    [[QIMManager sharedInstance] checkGroupChatMsg];
}

- (void)updateOfflineGroupMessages {
    [[QIMManager sharedInstance] updateOfflineGroupMessages];
}

//拉取群翻页历史记录
- (NSArray *)getMucMsgListWihtGroupId:(NSString *)groupId WithDirection:(int)direction WithLimit:(int)limit WithVersion:(long long)version {
    return [[QIMManager sharedInstance] getMucMsgListWihtGroupId:groupId WithDirection:direction WithLimit:limit WithVersion:version];
}

//更新群阅读指针，三次重试
- (void)updateMucReadMark {
    
    [[QIMManager sharedInstance] updateMucReadMark];
}

@end
