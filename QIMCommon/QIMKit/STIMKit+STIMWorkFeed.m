//
//  STIMKit+STIMWorkFeed.m
//  STIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMKit+STIMWorkFeed.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMWorkFeed)

- (NSArray *)getHotCommentUUIdsForMomentId:(NSString *)momentId {
    return [[STIMManager sharedInstance] getHotCommentUUIdsForMomentId:momentId];
}

- (void)setHotCommentUUIds:(NSArray *)hotCommentUUIds ForMomentId:(NSString *)momentId {
    [[STIMManager sharedInstance] setHotCommentUUIds:hotCommentUUIds ForMomentId:momentId];
}

- (void)removeHotCommentUUIdsForMomentId:(NSString *)momentId {
    [[STIMManager sharedInstance] removeHotCommentUUIdsForMomentId:momentId];
}

- (void)removeAllHotCommentUUIds {
    [[STIMManager sharedInstance] removeAllHotCommentUUIds];
}

- (void)updateLastWorkFeedMsgTime {
    [[STIMManager sharedInstance] updateLastWorkFeedMsgTime];
}

- (void)getRemoteMomentDetailWithMomentUUId:(NSString *)momentId withCallback:(STIMKitgetMomentDetailSuccessedBlock)callback {
    [[STIMManager sharedInstance] getRemoteMomentDetailWithMomentUUId:momentId withCallback:callback];
}

- (void)getAnonyMouseDicWithMomentId:(NSString *)momentId WithCallBack:(STIMKitgetAnonymouseSuccessedBlock)callback {
    [[STIMManager sharedInstance] getAnonyMouseDicWithMomentId:momentId WithCallBack:callback];
}

- (void)pushNewMomentWithMomentDic:(NSDictionary *)momentDic withCallBack:(STIMKitPushMomentSuccessedBlock)callback {
    [[STIMManager sharedInstance] pushNewMomentWithMomentDic:momentDic withCallBack:callback];
}

- (void)getMomentHistoryWithLastMomentId:(NSString *)momentId {
    [[STIMManager sharedInstance] getMomentHistoryWithLastMomentId:momentId];
}

- (void)deleteRemoteMomentWithMomentId:(NSString *)momentId {
    [[STIMManager sharedInstance] deleteRemoteMomentWithMomentId:momentId];
}

- (void)likeRemoteMomentWithMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(STIMKitLikeContentSuccessedBlock)callback {
    [[STIMManager sharedInstance] likeRemoteMomentWithMomentId:momentId withLikeFlag:likeFlag withCallBack:callback];
}

- (void)likeRemoteCommentWithCommentId:(NSString *)commentId withSuperParentUUID:(NSString *)superParentUUID withMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(STIMKitLikeContentSuccessedBlock)callback {
    [[STIMManager sharedInstance] likeRemoteCommentWithCommentId:commentId withSuperParentUUID:superParentUUID withMomentId:momentId withLikeFlag:likeFlag withCallBack:callback];
}

- (void)uploadCommentWithCommentDic:(NSDictionary *)commentDic {
    [[STIMManager sharedInstance] uploadCommentWithCommentDic:commentDic];
}

- (void)getRemoteRecentHotCommentsWithMomentId:(NSString *)momentId withHotCommentCallBack:(STIMKitWorkCommentBlock)callback {
    [[STIMManager sharedInstance] getRemoteRecentHotCommentsWithMomentId:momentId withHotCommentCallBack:callback];
}

- (void)getRemoteRecentNewCommentsWithMomentId:(NSString *)momentId withNewCommentCallBack:(STIMKitWorkCommentBlock)callback {
    [[STIMManager sharedInstance] getRemoteRecentNewCommentsWithMomentId:momentId withNewCommentCallBack:callback];
}

- (NSDictionary *)getWorkMomentWithMomentId:(NSString *)momentId {
    return [[STIMManager sharedInstance] getWorkMomentWithMomentId:momentId];
}

- (void)getWorkMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getWorkMomentWithLastMomentTime:lastMomentTime withUserXmppId:xmppId WithLimit:limit WithOffset:offset withFirstLocalMoment:firstLocal WithComplete:complete];
}

- (void)getWorkMoreMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getWorkMoreMomentWithLastMomentTime:lastMomentTime withUserXmppId:xmppId WithLimit:limit WithOffset:offset withFirstLocalMoment:firstLocal WithComplete:complete];
}

- (void)deleteRemoteCommentWithComment:(NSString *)commentId withPostUUId:(NSString *)postUUId withSuperParentUUId:(NSString *)superParentUUID withCallback:(STIMKitWorkCommentDeleteSuccessBlock)callback {
    [[STIMManager sharedInstance] deleteRemoteCommentWithComment:commentId withPostUUId:postUUId withSuperParentUUId:superParentUUID withCallback:callback];
}

//我的驼圈儿获取我的回复数据源
- (void)getRemoteOwnerCamelGetMyReplyWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(void (^)(NSArray *))complete{
    [[STIMManager sharedInstance] getRemoteOwnerCamelGetMyReplyWithCreateTime:createTime pageSize:pageSize complete:complete];
}

//我的驼圈儿获取我@我的数据源
- (void)getRemoteOwnerCamelGetAtListWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(void (^)(NSArray *))complete{
    [[STIMManager sharedInstance] getRemoteOwnerCamelGetAtListWithCreateTime:createTime pageSize:20 complete:complete];
}
#pragma mark - Remote Notice

- (void)updateRemoteWorkNoticeMsgReadStateWithTime:(long long)time {
    [[STIMManager sharedInstance] updateRemoteWorkNoticeMsgReadStateWithTime:time];
}

#pragma mark - Local Comment

- (void)getWorkCommentWithLastCommentRId:(NSInteger)lastCommentRId withMomentId:(NSString *)momentId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalComment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete {
    [[STIMManager sharedInstance] getWorkCommentWithLastCommentRId:lastCommentRId withMomentId:momentId WithLimit:limit WithOffset:offset withFirstLocalComment:firstLocal WithComplete:complete];
}

- (NSArray *)getWorkChildCommentsWithParentCommentUUID:(NSString *)parentCommentUUID {
    return [[STIMManager sharedInstance] getWorkChildCommentsWithParentCommentUUID:parentCommentUUID];
}

#pragma mark - 驼圈提醒
- (BOOL)getLocalWorkMomentNotifyConfig {
    return [[STIMManager sharedInstance] getLocalWorkMomentNotifyConfig];
}

- (void)getRemoteWorkMomentSwitch {
    [[STIMManager sharedInstance] getRemoteWorkMomentSwitch];
}

- (void)updateRemoteWorkMomentNotifyConfig:(BOOL)flag withCallBack:(STIMKitUpdateMomentNotifyConfigSuccessedBlock)callback {
    [[STIMManager sharedInstance] updateRemoteWorkMomentNotifyConfig:flag withCallBack:callback];
}

#pragma mark - Search Moment

- (void)searchMomentWithKey:(NSString *)key withSearchTime:(long long)searchTime withStartNum:(NSInteger)startNum withPageNum:(NSInteger)pageNum withSearchType:(NSInteger)searchType  withCallBack:(STIMKitSearchMomentBlock)callback {
        [[STIMManager sharedInstance] searchMomentWithKey:key withSearchTime:searchTime withStartNum:startNum withPageNum:pageNum withSearchType:searchType withCallBack:callback];
    }

#pragma mark - Local NoticeMsg

- (void)getRemoteLastWorkMoment {
    [[STIMManager sharedInstance] getRemoteLastWorkMoment];
}

- (NSDictionary *)getLastWorkMoment {
    return [[STIMManager sharedInstance] getLastWorkMoment];
}

- (NSInteger)getWorkNoticeMessagesCountWithEventType:(NSArray *)eventTypes {
    return [[STIMManager sharedInstance] getWorkNoticeMessagesCountWithEventType:eventTypes];
}

- (BOOL)checkWorkMomentExistWithMomentId:(NSString *)momentId {
    return [[STIMManager sharedInstance] checkWorkMomentExistWithMomentId:momentId];
}

- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState {
    return [[STIMManager sharedInstance] getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState];
}

- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes {
    return [[STIMManager sharedInstance] getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes];
}

- (void)updateLocalWorkNoticeMsgReadStateWithTime:(long long)time {
    [[STIMManager sharedInstance] updateLocalWorkNoticeMsgReadStateWithTime:time];
}

@end
