//
//  QIMKit+QIMQuickReply.m
//  QIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMQuickReply.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMQuickReply)

- (void)getRemoteQuickReply {
    [[QIMManager sharedInstance] getRemoteQuickReply];
}

- (NSInteger)getQuickReplyGroupCount {
    return [[QIMManager sharedInstance] getQuickReplyGroupCount];
}

- (NSArray *)getQuickReplyGroup {
    return [[QIMManager sharedInstance] getQuickReplyGroup];
}

- (NSArray *)getQuickReplyContentWithGroupId:(long)groupId {
    return [[QIMManager sharedInstance] getQuickReplyContentWithGroupId:groupId];
}
@end
