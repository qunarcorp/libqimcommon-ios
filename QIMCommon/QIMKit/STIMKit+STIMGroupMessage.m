//
//  STIMKit+STIMGroupMessage.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/12.
//

#import "STIMKit+STIMGroupMessage.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMGroupMessage)

- (void)updateLastGroupMsgTime {
    [[STIMManager sharedInstance] updateLastGroupMsgTime];
}

- (void)checkGroupChatMsg {
    [[STIMManager sharedInstance] checkGroupChatMsg];
}

- (void)updateOfflineGroupMessages {
    [[STIMManager sharedInstance] updateOfflineGroupMessages];
}

//拉取群翻页历史记录
- (NSArray *)getMucMsgListWithGroupId:(NSString *)groupId WithDirection:(int)direction WithLimit:(int)limit WithVersion:(long long)version include:(BOOL)include {
    return [[STIMManager sharedInstance] getMucMsgListWithGroupId:groupId WithDirection:direction WithLimit:limit WithVersion:version include:include];
}

//更新群阅读指针，三次重试
- (void)updateMucReadMark {
    
    [[STIMManager sharedInstance] updateMucReadMark];
}

@end
