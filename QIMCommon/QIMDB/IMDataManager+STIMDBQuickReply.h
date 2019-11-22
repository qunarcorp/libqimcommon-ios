//
//  IMDataManager+STIMDBQuickReply.h
//  STIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

@interface IMDataManager (STIMDBQuickReply)

#pragma mark - Group

- (long)stIMDB_getQuickReplyGroupVersion;

- (void)stIMDB_clearQuickReplyGroup;

- (void)stIMDB_bulkInsertQuickReply:(NSArray *)groupItems;

- (void)stIMDB_deleteQuickReplyGroup:(NSArray *)groupItems;

- (NSInteger)stIMDB_getQuickReplyGroupCount;

- (NSArray *)stIMDB_getQuickReplyGroup;

#pragma mark - Content

- (long)stIMDB_getQuickReplyContentVersion;

- (void)stIMDB_clearQuickReplyContents;

- (void)stIMDB_bulkInsertQuickReplyContents:(NSArray *)contentItems;

- (void)stIMDB_deleteQuickReplyContents:(NSArray *)items;

- (NSArray *)stIMDB_getQuickReplyContentWithGroupId:(long)groupId;

@end
