//
//  STIMKit+STIMQuickReply.m
//  STIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMQuickReply.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMQuickReply)

- (void)getRemoteQuickReply {
    [[STIMManager sharedInstance] getRemoteQuickReply];
}

- (NSInteger)getQuickReplyGroupCount {
    return [[STIMManager sharedInstance] getQuickReplyGroupCount];
}

- (NSArray *)getQuickReplyGroup {
    return [[STIMManager sharedInstance] getQuickReplyGroup];
}

- (NSArray *)getQuickReplyContentWithGroupId:(long)groupId {
    return [[STIMManager sharedInstance] getQuickReplyContentWithGroupId:groupId];
}
@end
