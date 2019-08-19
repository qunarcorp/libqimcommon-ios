//
//  QIMKit+QIMWorkFeed.m
//  QIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMKit+QIMWorkFeed.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMWorkFeed)

- (NSArray *)getHotCommentUUIdsForMomentId:(NSString *)momentId {
    return [[QIMManager sharedInstance] getHotCommentUUIdsForMomentId:momentId];
}

- (void)setHotCommentUUIds:(NSArray *)hotCommentUUIds ForMomentId:(NSString *)momentId {
    [[QIMManager sharedInstance] setHotCommentUUIds:hotCommentUUIds ForMomentId:momentId];
}

- (void)removeHotCommentUUIdsForMomentId:(NSString *)momentId {
    [[QIMManager sharedInstance] removeHotCommentUUIdsForMomentId:momentId];
}

- (void)removeAllHotCommentUUIds {
    [[QIMManager sharedInstance] removeAllHotCommentUUIds];
}

- (void)updateLastWorkFeedMsgTime {
    [[QIMManager sharedInstance] updateLastWorkFeedMsgTime];
}

- (void)getRemoteMomentDetailWithMomentUUId:(NSString *)momentId withCallback:(QIMKitgetMomentDetailSuccessedBlock)callback {
    [[QIMManager sharedInstance] getRemoteMomentDetailWithMomentUUId:momentId withCallback:callback];
}

- (void)getAnonyMouseDicWithMomentId:(NSString *)momentId WithCallBack:(QIMKitgetAnonymouseSuccessedBlock)callback {
    [[QIMManager sharedInstance] getAnonyMouseDicWithMomentId:momentId WithCallBack:callback];
}

- (void)pushNewMomentWithMomentDic:(NSDictionary *)momentDic withCallBack:(QIMKitPushMomentSuccessedBlock)callback {
    [[QIMManager sharedInstance] pushNewMomentWithMomentDic:momentDic withCallBack:callback];
}

- (void)getMomentHistoryWithLastMomentId:(NSString *)momentId {
    [[QIMManager sharedInstance] getMomentHistoryWithLastMomentId:momentId];
}

- (void)deleteRemoteMomentWithMomentId:(NSString *)momentId {
    [[QIMManager sharedInstance] deleteRemoteMomentWithMomentId:momentId];
}

- (void)likeRemoteMomentWithMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(QIMKitLikeContentSuccessedBlock)callback {
    [[QIMManager sharedInstance] likeRemoteMomentWithMomentId:momentId withLikeFlag:likeFlag withCallBack:callback];
}

- (void)likeRemoteCommentWithCommentId:(NSString *)commentId withSuperParentUUID:(NSString *)superParentUUID withMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(QIMKitLikeContentSuccessedBlock)callback {
    [[QIMManager sharedInstance] likeRemoteCommentWithCommentId:commentId withSuperParentUUID:superParentUUID withMomentId:momentId withLikeFlag:likeFlag withCallBack:callback];
}

- (void)uploadCommentWithCommentDic:(NSDictionary *)commentDic {
    [[QIMManager sharedInstance] uploadCommentWithCommentDic:commentDic];
}

- (void)getRemoteRecentHotCommentsWithMomentId:(NSString *)momentId withHotCommentCallBack:(QIMKitWorkCommentBlock)callback {
    [[QIMManager sharedInstance] getRemoteRecentHotCommentsWithMomentId:momentId withHotCommentCallBack:callback];
}

- (void)getRemoteRecentNewCommentsWithMomentId:(NSString *)momentId withNewCommentCallBack:(QIMKitWorkCommentBlock)callback {
    [[QIMManager sharedInstance] getRemoteRecentNewCommentsWithMomentId:momentId withNewCommentCallBack:callback];
}

- (NSDictionary *)getWorkMomentWithMomentId:(NSString *)momentId {
    return [[QIMManager sharedInstance] getWorkMomentWithMomentId:momentId];
}

- (void)getWorkMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getWorkMomentWithLastMomentTime:lastMomentTime withUserXmppId:xmppId WithLimit:limit WithOffset:offset withFirstLocalMoment:firstLocal WithComplete:complete];
}

- (void)getWorkMoreMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getWorkMoreMomentWithLastMomentTime:lastMomentTime withUserXmppId:xmppId WithLimit:limit WithOffset:offset withFirstLocalMoment:firstLocal WithComplete:complete];
}

- (void)deleteRemoteCommentWithComment:(NSString *)commentId withPostUUId:(NSString *)postUUId withSuperParentUUId:(NSString *)superParentUUID withCallback:(QIMKitWorkCommentDeleteSuccessBlock)callback {
    [[QIMManager sharedInstance] deleteRemoteCommentWithComment:commentId withPostUUId:postUUId withSuperParentUUId:superParentUUID withCallback:callback];
}

//我的驼圈儿获取我的回复数据源
- (void)getRemoteOwnerCamelGetMyReplyWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(void (^)(NSArray *))complete{
    [[QIMManager sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:createTime pageSize:pageSize complete:complete];
}

//我的驼圈儿获取我@我的数据源
- (void)getRemoteOwnerCamelGetAtListWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(void (^)(NSArray *))complete{
    [[QIMManager sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:createTime pageSize:20 complete:complete];
}
#pragma mark - Remote Notice

- (void)updateRemoteWorkNoticeMsgReadStateWithTime:(long long)time {
    [[QIMManager sharedInstance] updateRemoteWorkNoticeMsgReadStateWithTime:time];
}

#pragma mark - Local Comment

- (void)getWorkCommentWithLastCommentRId:(NSInteger)lastCommentRId withMomentId:(NSString *)momentId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalComment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete {
    [[QIMManager sharedInstance] getWorkCommentWithLastCommentRId:lastCommentRId withMomentId:momentId WithLimit:limit WithOffset:offset withFirstLocalComment:firstLocal WithComplete:complete];
}

- (NSArray *)getWorkChildCommentsWithParentCommentUUID:(NSString *)parentCommentUUID {
    return [[QIMManager sharedInstance] getWorkChildCommentsWithParentCommentUUID:parentCommentUUID];
}

#pragma mark - 驼圈提醒
- (BOOL)getLocalWorkMomentNotifyConfig {
    return [[QIMManager sharedInstance] getLocalWorkMomentNotifyConfig];
}

- (void)getRemoteWorkMomentSwitch {
    [[QIMManager sharedInstance] getRemoteWorkMomentSwitch];
}

- (void)updateRemoteWorkMomentNotifyConfig:(BOOL)flag withCallBack:(QIMKitUpdateMomentNotifyConfigSuccessedBlock)callback {
    [[QIMManager sharedInstance] updateRemoteWorkMomentNotifyConfig:flag withCallBack:callback];
}

#pragma mark - Search Moment

- (void)searchMomentWithKey:(NSString *)key withSearchTime:(long long)searchTime withStartNum:(NSInteger)startNum withPageNum:(NSInteger)pageNum withSearchType:(NSInteger)searchType  withCallBack:(QIMKitSearchMomentBlock)callback {
        [[QIMManager sharedInstance] searchMomentWithKey:key withSearchTime:searchTime withStartNum:startNum withPageNum:pageNum withSearchType:searchType withCallBack:callback];
    }

#pragma mark - Local NoticeMsg

- (void)getRemoteLastWorkMoment {
    [[QIMManager sharedInstance] getRemoteLastWorkMoment];
}

- (NSDictionary *)getLastWorkMoment {
    return [[QIMManager sharedInstance] getLastWorkMoment];
}

- (NSInteger)getWorkNoticeMessagesCountWithEventType:(NSArray *)eventTypes {
    return [[QIMManager sharedInstance] getWorkNoticeMessagesCountWithEventType:eventTypes];
}

- (BOOL)checkWorkMomentExistWithMomentId:(NSString *)momentId {
    return [[QIMManager sharedInstance] checkWorkMomentExistWithMomentId:momentId];
}

- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState {
    return [[QIMManager sharedInstance] getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState];
}

- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes {
    return [[QIMManager sharedInstance] getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes];
}

- (void)updateLocalWorkNoticeMsgReadStateWithTime:(long long)time {
    [[QIMManager sharedInstance] updateLocalWorkNoticeMsgReadStateWithTime:time];
}

@end
