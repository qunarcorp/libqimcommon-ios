//
//  IMDataManager+QIMDBQuickReply.h
//  QIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "IMDataManager.h"

@interface IMDataManager (QIMDBQuickReply)

#pragma mark - Group

- (long)qimDB_getQuickReplyGroupVersion;

- (void)qimDB_clearQuickReplyGroup;

- (void)qimDB_bulkInsertQuickReply:(NSArray *)groupItems;

- (void)qimDB_deleteQuickReplyGroup:(NSArray *)groupItems;

- (NSInteger)qimDB_getQuickReplyGroupCount;

- (NSArray *)qimDB_getQuickReplyGroup;

#pragma mark - Content

- (long)qimDB_getQuickReplyContentVersion;

- (void)qimDB_clearQuickReplyContents;

- (void)qimDB_bulkInsertQuickReplyContents:(NSArray *)contentItems;

- (void)qimDB_deleteQuickReplyContents:(NSArray *)items;

- (NSArray *)qimDB_getQuickReplyContentWithGroupId:(long)groupId;

@end
