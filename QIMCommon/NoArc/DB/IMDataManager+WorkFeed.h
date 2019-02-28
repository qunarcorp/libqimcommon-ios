//
//  IMDataManager+WorkFeed.h
//  QIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "IMDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (WorkFeed)

- (void)qimDB_bulkinsertMoments:(NSArray *)moments;

- (NSDictionary *)qimDB_getWorkMomentWithMomentId:(NSString *)momentId;

- (void)qimDB_bulkdeleteMoments:(NSArray *)moments;

- (NSDictionary *)qimDB_getLastWorkMoment;

- (NSArray *)qimDB_getWorkMomentWithXmppId:(NSString *)xmppId WihtLimit:(int)limit WithOffset:(int)offset;

- (void)qimDB_deleteMomentWithRId:(NSInteger)rId;

- (void)qimDB_updateMomentLike:(NSArray *)likeMoments;

- (void)qimDB_updateMomentWithLikeNum:(NSInteger)likeMomentNum WithCommentNum:(NSInteger)commentNum withPostId:(NSString *)postId;

#pragma mark - Comment

- (void)qimDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID withcurCommentCreateTime:(long long)createTime;

- (long long)qimDB_getCommentCreateTimeWithCurCommentId:(NSInteger)commentId;

- (void)qimDB_bulkDeleteComments:(NSArray *)comments;

- (void)qimDB_bulkDeleteCommentsWithPostId:(NSString *)postUUID;

- (void)qimDB_bulkinsertComments:(NSArray *)comments;

- (NSArray *)qimDB_getWorkCommentsWithMomentId:(NSString *)momentId WihtLimit:(int)limit WithOffset:(int)offset;

#pragma mark - NoticeMessage

- (void)qimDB_bulkinsertNoticeMessage:(NSArray *)notices;

- (long long)qimDB_getWorkNoticeMessagesMaxTime;

- (NSInteger)qimDB_getWorkNoticeMessagesCount;

- (NSInteger)qimDB_getWorkNoticePOSTCount;

- (void)qimDB_updateWorkNoticePOSTMessageReadState;

- (NSArray *)qimDB_getWorkNoticeMessagesWihtLimit:(int)limit WithOffset:(int)offset;

- (void)qimDB_updateWorkNoticeMessageReadStateWithTime:(long long)time;

- (NSDictionary *)qimDB_getLastWorkMomentMessageDic;

@end

NS_ASSUME_NONNULL_END
