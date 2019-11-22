//
//  STIMManager+WorkFeed.h
//  STIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMManager.h"
#import "STIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMManager (WorkFeed)

- (NSArray *)getHotCommentUUIdsForMomentId:(NSString *)momentId;

- (void)setHotCommentUUIds:(NSArray *)hotCommentUUIds ForMomentId:(NSString *)momentId;

- (void)removeHotCommentUUIdsForMomentId:(NSString *)momentId;

- (void)removeAllHotCommentUUIds;

- (void)updateLastWorkFeedMsgTime;

- (void)getRemoteMomentDetailWithMomentUUId:(NSString *)momentId withCallback:(STIMKitgetMomentDetailSuccessedBlock)callback;

- (void)getAnonyMouseDicWithMomentId:(NSString *)momentId WithCallBack:(STIMKitgetAnonymouseSuccessedBlock)callback;

- (void)pushNewMomentWithMomentDic:(NSDictionary *)momentDic withCallBack:(STIMKitPushMomentSuccessedBlock)callback;

- (void)getMomentHistoryWithLastMomentId:(NSString *)momentId;

- (void)deleteRemoteMomentWithMomentId:(NSString *)momentId;

- (void)likeRemoteMomentWithMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(STIMKitLikeContentSuccessedBlock)callback;

- (void)likeRemoteCommentWithCommentId:(NSString *)commentId withSuperParentUUID:(NSString *)superParentUUID withMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(STIMKitLikeContentSuccessedBlock)callback;

- (void)uploadCommentWithCommentDic:(NSDictionary *)commentDic;

- (void)getRemoteRecentHotCommentsWithMomentId:(NSString *)momentId withHotCommentCallBack:(STIMKitWorkCommentBlock)callback;

- (void)getRemoteRecentNewCommentsWithMomentId:(NSString *)momentId withNewCommentCallBack:(STIMKitWorkCommentBlock)callback;

- (NSDictionary *)getWorkMomentWithMomentId:(NSString *)momentId;

- (void)getWorkMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete;

- (void)getWorkMoreMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete;

- (void)deleteRemoteCommentWithComment:(NSString *)commentId withPostUUId:(NSString *)postUUId withSuperParentUUId:(NSString *)superParentUUID withCallback:(STIMKitWorkCommentDeleteSuccessBlock)callback;

//我的驼圈儿获取我的回复数据源
- (void)getRemoteOwnerCamelGetMyReplyWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(void (^)(NSArray *))complete;

//我的驼圈儿获取我@我的数据源
- (void)getRemoteOwnerCamelGetAtListWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(void (^)(NSArray *))complete;
#pragma mark - 用户入口

- (void)getCricleCamelEntrance;

#pragma mark - 用户发视频size权限
- (void)getCricleCamelVideoConfig;

#pragma mark - Remote Notice

- (void)getupdateRemoteWorkNoticeMsgs;

- (void)updateRemoteWorkNoticeMsgReadStateWithTime:(long long)time;

#pragma mark - Local Comment

- (void)getWorkCommentWithLastCommentRId:(NSInteger)lastCommentRId withMomentId:(NSString *)momentId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalComment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete;

#pragma mark - 驼圈提醒
- (BOOL)getLocalWorkMomentNotifyConfig;

- (void)getRemoteWorkMomentSwitch;

- (void)updateRemoteWorkMomentNotifyConfig:(BOOL)flag withCallBack:(STIMKitUpdateMomentNotifyConfigSuccessedBlock)callback;

#pragma mark - Search Moment
- (void)searchMomentWithKey:(NSString *)key withSearchTime:(long long)searchTime withStartNum:(NSInteger)startNum withPageNum:(NSInteger)pageNum withSearchType:(NSInteger)searchType  withCallBack:(STIMKitSearchMomentBlock)callback;

#pragma mark - Local NoticeMsg

- (void)getRemoteLastWorkMoment;

- (NSDictionary *)getLastWorkMoment;

- (NSDictionary *)getLastWorkOnlineMomentWithDic:(NSDictionary *)dic;

- (NSDictionary *)getLastWorkMomentWithDic:(NSDictionary *)dic;

- (NSArray *)getWorkChildCommentsWithParentCommentUUID:(NSString *)parentCommentUUID;

- (NSInteger)getWorkNoticeMessagesCountWithEventType:(NSArray *)eventTypes;

- (BOOL)checkWorkMomentExistWithMomentId:(NSString *)momentId;

- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState;

- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes;

- (void)updateLocalWorkNoticeMsgReadStateWithTime:(long long)time;

@end

NS_ASSUME_NONNULL_END
