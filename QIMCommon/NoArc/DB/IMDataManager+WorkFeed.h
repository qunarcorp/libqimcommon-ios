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

- (void)deleteMomentWithRId:(NSInteger)rId;

- (void)updateMomentLike:(NSArray *)likeMoments;

#pragma mark - Comment

- (void)qimDB_bulkDeleteComments:(NSArray *)comments;

- (void)qimDB_bulkinsertComments:(NSArray *)comments;

- (NSArray *)qimDB_getWorkCommentsWithMomentId:(NSString *)momentId WihtLimit:(int)limit WithOffset:(int)offset;

#pragma mark - NoticeMessage

- (void)qimDB_bulkinsertNoticeMessage:(NSArray *)notices;

- (long long)qimDB_getWorkNoticeMessagesMaxTime;

- (NSInteger)qimDB_getWorkNoticeMessagesCount;

- (NSArray *)qimDB_getWorkNoticeMessagesWihtLimit:(int)limit WithOffset:(int)offset;

- (void)qimDB_updateWorkNoticeMessageReadStateWithTime:(long long)time;

- (NSDictionary *)qimDB_getLastWorkMomentMessageDic;

@end

NS_ASSUME_NONNULL_END
