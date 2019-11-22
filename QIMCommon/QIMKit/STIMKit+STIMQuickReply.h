//
//  STIMKit+STIMQuickReply.h
//  STIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMQuickReply)

- (void)getRemoteQuickReply;

- (NSInteger)getQuickReplyGroupCount;

- (NSArray *)getQuickReplyGroup;

- (NSArray *)getQuickReplyContentWithGroupId:(long)groupId;

@end
