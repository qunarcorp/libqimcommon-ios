//
//  IMDataManager+WorkFeed.h
//  STIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (WorkFeed)

- (BOOL)stIMDB_checkMomentWithMomentId:(NSString *)momentId;

- (void)stIMDB_bulkinsertMoments:(NSArray *)moments;

- (NSDictionary *)stIMDB_getWorkMomentWithMomentId:(NSString *)momentId;

- (void)stIMDB_bulkdeleteMomentsWithXmppId:(NSString *)xmppId;

- (void)stIMDB_bulkdeleteMoments:(NSArray *)moments;

- (NSDictionary *)stIMDB_getLastWorkMoment;

- (NSArray *)stIMDB_getWorkMomentWithXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset;

- (void)stIMDB_deleteMomentWithRId:(NSInteger)rId;

- (void)stIMDB_updateMomentLike:(NSArray *)likeMoments;

- (void)stIMDB_updateMomentWithLikeNum:(NSInteger)likeMomentNum WithCommentNum:(NSInteger)commentNum withPostId:(NSString *)postId;

#pragma mark - Comment

- (void)stIMDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID withcurCommentCreateTime:(long long)createTime;

- (long long)stIMDB_getCommentCreateTimeWithCurCommentId:(NSInteger)commentId;

- (void)stIMDB_bulkUpdateComments:(NSArray *)comments;

- (void)stIMDB_bulkDeleteCommentsAndAllChildComments:(NSArray *)comments;

- (void)stIMDB_bulkDeleteComments:(NSArray *)comments;

- (void)stIMDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID;

- (void)stIMDB_bulkinsertComments:(NSArray *)comments;

- (NSArray *)stIMDB_getWorkCommentsWithMomentId:(NSString *)momentId WithLimit:(int)limit WithOffset:(int)offset;

- (NSArray *)stIMDB_getWorkChildCommentsWithParentCommentUUID:(NSString *)commentUUID;

#pragma mark - NoticeMessage

- (void)stIMDB_bulkinsertNoticeMessage:(NSArray *)notices;

- (long long)stIMDB_getWorkNoticeMessagesMaxTime;

- (NSInteger)stIMDB_getWorkNoticeMessagesCountWithEventType:(NSArray *)eventTyps;

//新加
- (NSArray *)stIMDB_getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState;

//新加
- (NSArray *)stIMDB_getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes;

//我的驼圈儿根据uuid 数组删除deleteListArr
- (void)stIMDB_deleteWorkNoticeMessageWithUUid:(NSArray *)deleteListArr;

- (void)stIMDB_deleteWorkNoticeMessageWithEventTypes:(NSArray *)eventTypes;

- (void)stIMDB_updateWorkNoticeMessageReadStateWithTime:(long long)time;

@end

NS_ASSUME_NONNULL_END
