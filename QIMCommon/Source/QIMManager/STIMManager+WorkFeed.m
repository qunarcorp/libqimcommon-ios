//
//  STIMManager+WorkFeed.m
//  STIMCommon
//
//  Created by lilu on 2019/1/7.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMManager+WorkFeed.h"
#import <objc/runtime.h>

@implementation STIMManager (WorkFeed)

- (NSArray *)getHotCommentUUIdsForMomentId:(NSString *)momentId {
    return [self.hotCommentUUIdsDic objectForKey:momentId];
}

- (void)setHotCommentUUIds:(NSArray *)hotCommentUUIds ForMomentId:(NSString *)momentId {
    [self.hotCommentUUIdsDic setSTIMSafeObject:hotCommentUUIds forKey:momentId];
}

- (void)removeHotCommentUUIdsForMomentId:(NSString *)momentId {
    if (momentId.length > 0) {
        [self.hotCommentUUIdsDic removeObjectForKey:momentId];
    }
}

- (void)removeAllHotCommentUUIds {
    [self.hotCommentUUIdsDic removeAllObjects];
}

- (void)updateLastWorkFeedMsgTime {
    STIMVerboseLog(@"更新本地未读的驼圈消息时间戳");
    long long defaultTime = ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff - 3600 * 24 * 3) * 1000;
    long long errorTime = [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewWorkFeedHistoryMessageListError] longLongValue];
    if (errorTime > 0) {
        self.lastWorkFeedMsgMsgTime = errorTime;
        STIMVerboseLog(@"本地驼圈错误时间戳 : %lld", errorTime);
    } else {
        self.lastWorkFeedMsgMsgTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkNoticeMessagesMaxTime];
    }
    if (self.lastWorkFeedMsgMsgTime == 0) {
        self.lastWorkFeedMsgMsgTime = defaultTime;
    }
    STIMVerboseLog(@"强制塞本地驼圈消息时间戳到为 kGetNewWorkFeedHistoryMessageListError : %f", self.lastWorkFeedMsgMsgTime);
    [[STIMUserCacheManager sharedInstance] setUserObject:@(self.lastWorkFeedMsgMsgTime) forKey:kGetNewWorkFeedHistoryMessageListError];
    STIMVerboseLog(@"强制塞本地驼圈消息时间戳到为 kGetNewWorkFeedHistoryMessageListError : %f完成", self.lastWorkFeedMsgMsgTime);
    
    STIMVerboseLog(@"强制塞本地驼圈消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewWorkFeedHistoryMessageListError] longLongValue]);
    
    STIMVerboseLog(@"最终获取到的本地驼圈已读未读最后消息时间戳为 : %lf", self.lastWorkFeedMsgMsgTime);
}

- (void)getRemoteMomentDetailWithMomentUUId:(NSString *)momentId withCallback:(STIMKitgetMomentDetailSuccessedBlock)callback {
    if (momentId.length <= 0) {
        return;
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/getPostDetail", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *anonyDic = @{@"uuid" : momentId};
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:anonyDic error:nil];
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            
            NSDictionary *momentDic = [result objectForKey:@"data"];
            if ([momentDic isKindOfClass:[NSDictionary class]]) {
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertMoments:@[momentDic]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(momentDic);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedDetail object:momentDic];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)getAnonyMouseDicWithMomentId:(NSString *)momentId WithCallBack:(STIMKitgetAnonymouseSuccessedBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/anonymouse/getAnonymouse", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *anonyDic = @{@"user" : [[STIMManager sharedInstance] getLastJid], @"postId": momentId ? momentId : [STIMUUIDTools UUID]};
    STIMVerboseLog(@"获取匿名Body : %@", [[STIMJSONSerializer sharedInstance] serializeObject:anonyDic]);
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:anonyDic error:nil];
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *anonymousDic = [result objectForKey:@"data"];
            if ([anonymousDic isKindOfClass:[NSDictionary class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(anonymousDic);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)pushNewMomentWithMomentDic:(NSDictionary *)momentDic withCallBack:(STIMKitPushMomentSuccessedBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/post/V2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:momentDic error:nil];
    NSString *momentBodyStr = [[STIMJSONSerializer sharedInstance] serializeObject:momentDic];
    STIMVerboseLog(@"pushNewMomentWithMomentDic Body : %@", momentBodyStr);
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *moments = [result objectForKey:@"data"];
            if ([moments isKindOfClass:[NSDictionary class]]) {
                NSArray *deletePosts = [moments objectForKey:@"deletePost"];
                NSArray *newPosts = [moments objectForKey:@"newPost"];
                if ([deletePosts isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkdeleteMoments:deletePosts];
                }
                if ([newPosts isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertMoments:newPosts];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeed object:newPosts];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(YES);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(NO);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(NO);
                }
            });
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(NO);
            }
        });
    }];
}

- (void)getMomentHistoryWithLastUpdateTime:(long long)updateTime withOwnerXmppId:(NSString *)xmppId withPostType:(NSInteger)postType withCallBack:(STIMKitGetMomentHistorySuccessedBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/post/getPostList/v2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [bodyDic setSTIMSafeObject:@(updateTime) forKey:@"postCreateTime"];
    [bodyDic setSTIMSafeObject:[[xmppId componentsSeparatedByString:@"@"] firstObject] forKey:@"owner"];
    [bodyDic setSTIMSafeObject:[[xmppId componentsSeparatedByString:@"@"] lastObject] forKey:@"ownerHost"];
    [bodyDic setSTIMSafeObject:@(20) forKey:@"pageSize"];
    [bodyDic setSTIMSafeObject:@(1) forKey:@"getTop"];
    [bodyDic setSTIMSafeObject:@(postType) forKey:@"postType"];

    STIMVerboseLog(@"post/getPostList : %@", bodyDic);
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *moments = [result objectForKey:@"data"];
            if ([moments isKindOfClass:[NSDictionary class]]) {
                NSArray *deletePosts = [moments objectForKey:@"deletePost"];
                NSArray *newPosts = [moments objectForKey:@"newPost"];
                if ([deletePosts isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkdeleteMoments:deletePosts];
                }
                if ([newPosts isKindOfClass:[NSArray class]]) {
                    if (newPosts.count <= 0) {
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkdeleteMomentsWithXmppId:xmppId];
                    } else {
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertMoments:newPosts];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(newPosts);
                        }
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(nil);
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)deleteRemoteMomentWithMomentId:(NSString *)momentId {
    if (momentId.length <= 0) {
        return;
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/deletePost", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"uuid":momentId};
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                BOOL isDeleteFlag = [[data objectForKey:@"isDelete"] boolValue];
                if (isDeleteFlag == YES) {
                    NSInteger rId = [[data objectForKey:@"id"] integerValue];
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteMomentWithRId:rId];
                }
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)likeRemoteMomentWithMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(STIMKitLikeMomentSuccessedBlock)callback {
    if (momentId.length <= 0) {
        return;
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/like", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:nil forKey:@"commentId"];
    [bodyDic setSTIMSafeObject:@(likeFlag) forKey:@"likeType"];
    [bodyDic setSTIMSafeObject:@(STIMWorkFeedTypeMoment) forKey:@"opType"];
    [bodyDic setSTIMSafeObject:momentId forKey:@"postId"];
    [bodyDic setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"userId"];
    [bodyDic setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"userHost"];
    [bodyDic setSTIMSafeObject:[NSString stringWithFormat:@"2-%@", [STIMUUIDTools UUID]] forKey:@"likeId"];
    
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([data isKindOfClass:[NSDictionary class]]) {
                [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMomentLike:@[data]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(data);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedLike object:data];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}


#pragma mark - Remote Comment

- (void)likeRemoteCommentWithCommentId:(NSString *)commentId withSuperParentUUID:(NSString *)superParentUUID withMomentId:(NSString *)momentId withLikeFlag:(BOOL)likeFlag withCallBack:(STIMKitLikeContentSuccessedBlock)callback {
    if (momentId.length <= 0 || commentId.length <= 0) {
        return;
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/like", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:commentId forKey:@"commentId"];
    [bodyDic setSTIMSafeObject:@(likeFlag) forKey:@"likeType"];
    [bodyDic setSTIMSafeObject:@(STIMWorkFeedTypeComment) forKey:@"opType"];
    [bodyDic setSTIMSafeObject:momentId forKey:@"postId"];
    [bodyDic setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"userId"];
    [bodyDic setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"userHost"];
    [bodyDic setSTIMSafeObject:[NSString stringWithFormat:@"2-%@",[STIMUUIDTools UUID]] forKey:@"likeId"];
    [bodyDic setSTIMSafeObject:(superParentUUID.length > 0) ? superParentUUID : nil forKey:@"superParentUUID"];
    
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *attachCommentList = [data objectForKey:@"attachCommentList"];
                if ([attachCommentList isKindOfClass:[NSArray class]]) {
                    NSDictionary *postAttachCommentListData = @{@"postId":momentId, @"attachCommentList":attachCommentList};
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedAttachCommentList object:postAttachCommentListData];
                    });
                }
                [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMomentLike:@[data]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(data);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)uploadCommentWithCommentDic:(NSDictionary *)commentDic {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/uploadComment/V2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];

    NSString *commentStr = [[STIMJSONSerializer sharedInstance] serializeObject:commentDic];
    STIMVerboseLog(@"uploadCommentWithCommentDic Body : %@", commentStr);
    NSData *commentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:commentDic error:nil];
    
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:commentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                NSInteger likeNum = [[data objectForKey:@"postLikeNum"] integerValue];
                NSInteger postCommentNum = [[data objectForKey:@"postCommentNum"] integerValue];
                NSDictionary *postCommentData = @{@"postId":[commentDic objectForKey:@"postUUID"], @"postCommentNum":@(postCommentNum)};
                dispatch_async(dispatch_get_main_queue(), ^{
                   [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedCommentNum object:postCommentData];
                });
                [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMomentWithLikeNum:likeNum WithCommentNum:postCommentNum withPostId:[commentDic objectForKey:@"postUUID"]];
                NSArray *attachCommentList = [data objectForKey:@"attachCommentList"];
                if ([attachCommentList isKindOfClass:[NSArray class]]) {
                    NSDictionary *postAttachCommentListData = @{@"postId":[commentDic objectForKey:@"postUUID"], @"attachCommentList":attachCommentList};
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedAttachCommentList object:postAttachCommentListData];
                    });
                }
                NSArray *deleteComments = [data objectForKey:@"deleteComments"];
                if ([deleteComments isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteComments:deleteComments];
                }
                NSArray *newComment = [data objectForKey:@"newComment"];
                if ([newComment isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertComments:newComment];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkComment object:[newComment firstObject]];
                        NSInteger likeNum = [[data objectForKey:@"postLikeNum"] integerValue];
                        BOOL isPostLike = [[data objectForKey:@"isPostLike"] boolValue];
                        NSDictionary *likeData = @{@"postId":[commentDic objectForKey:@"postUUID"], @"likeNum":@(likeNum), @"isLike":@(isPostLike)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedLike object:likeData];
                        NSInteger postCommentNum = [[data objectForKey:@"postCommentNum"] integerValue];
                        NSDictionary *postCommentData = @{@"postId":[commentDic objectForKey:@"postUUID"], @"postCommentNum":@(postCommentNum)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedCommentNum object:postCommentData];
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMomentWithLikeNum:likeNum WithCommentNum:postCommentNum withPostId:[commentDic objectForKey:@"postUUID"]];
                    });
                }
            } else {

            }
        }
    } withFailedCallBack:^(NSError *error) {

    }];
}

- (void)getRemoteRecentHotCommentsWithMomentId:(NSString *)momentId withHotCommentCallBack:(STIMKitWorkCommentBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/getHotComment/V2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:momentId forKey:@"uuid"];
    
    STIMVerboseLog(@"HotComment : %@", bodyDic);
    NSData *hotCommentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;

    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:hotCommentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *newComment = [data objectForKey:@"newComment"];
                if ([newComment isKindOfClass:[NSArray class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(newComment);
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)getRemoteRecentNewCommentsWithMomentId:(NSString *)momentId withNewCommentCallBack:(STIMKitWorkCommentBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/getNewComment/V2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:momentId forKey:@"postUUID"];
    [bodyDic setSTIMSafeObject:@(20) forKey:@"pgSize"];
    [bodyDic setSTIMSafeObject:[self getHotCommentUUIdsForMomentId:momentId] forKey:@"hotCommentUUID"];

    STIMVerboseLog(@"cricle_camel/getNewComment/V2 : %@", bodyDic);
    NSData *hotCommentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:hotCommentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *attachCommentList = [data objectForKey:@"attachCommentList"];
                if ([attachCommentList isKindOfClass:[NSArray class]]) {
                    NSDictionary *postAttachCommentListData = @{@"postId":momentId, @"attachCommentList":attachCommentList};
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedAttachCommentList object:postAttachCommentListData];
                    });
                }
                NSArray *deteleComments = [data objectForKey:@"deleteComments"];
                if ([deteleComments isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteComments:deteleComments];
                }
                NSArray *newComment = [data objectForKey:@"newComment"];
                if ([newComment isKindOfClass:[NSArray class]] && newComment.count > 0) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertComments:newComment];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSInteger likeNum = [[data objectForKey:@"postLikeNum"] integerValue];
                        BOOL isPostLike = [[data objectForKey:@"isPostLike"] boolValue];
                        NSDictionary *likeData = @{@"postId":momentId, @"likeNum":@(likeNum), @"isLike":@(isPostLike)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedLike object:likeData];
                        NSInteger postCommentNum = [[data objectForKey:@"postCommentNum"] integerValue];
                        NSDictionary *postCommentData = @{@"postId":momentId, @"postCommentNum":@(postCommentNum)};
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedCommentNum object:postCommentData];
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMomentWithLikeNum:likeNum WithCommentNum:postCommentNum withPostId:momentId];
                        if (callback) {
                            callback(newComment);
                        }
                    });
                } else {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteCommentsWithPostId:momentId];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(@[]);
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)getRemoteCommentsHistoryWithLastCommentId:(NSInteger)commentRId withMomentId:(NSString *)momentId withCommentCallBack:(STIMKitWorkCommentBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/getHistoryComment/V2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@(commentRId) forKey:@"curCommentId"];
    [bodyDic setObject:momentId forKey:@"postUUID"];
    [bodyDic setObject:@(20) forKey:@"pgSize"];
    [bodyDic setSTIMSafeObject:[self getHotCommentUUIdsForMomentId:momentId] forKey:@"hotCommentUUID"];
    
    STIMVerboseLog(@"cricle_camel/getHistoryComment : %@", bodyDic);
    NSData *hotCommentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:hotCommentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            
            NSDictionary *data = [result objectForKey:@"data"];
            __typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *deteleComments = [data objectForKey:@"deleteComments"];
                if ([deteleComments isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteComments:deteleComments];
                }
                NSArray *newComment = [data objectForKey:@"newComment"];
                if ([newComment isKindOfClass:[NSArray class]] && newComment.count > 0) {
                    //插入历史20条
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertComments:newComment];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(newComment);
                        }
                    });
                } else {
                    //返回空，删除之前的历史
                    long long commentCreateTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_getCommentCreateTimeWithCurCommentId:commentRId];
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteCommentsWithPostId:momentId withcurCommentCreateTime:commentCreateTime];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (callback) {
                            callback(@[]);
                        }
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

- (void)deleteRemoteCommentWithComment:(NSString *)commentId withPostUUId:(NSString *)postUUId withSuperParentUUId:(NSString *)superParentUUID withCallback:(STIMKitWorkCommentDeleteSuccessBlock)callback {
    if (commentId.length <= 0 || postUUId <= 0) {
        return;
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/deleteComment/V2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSDictionary *bodyDic = @{@"commentUUID":commentId, @"postUUID":postUUId, @"superParentUUID":superParentUUID};
    NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
            
                NSArray *attachCommentList = [data objectForKey:@"attachCommentList"];
                if ([attachCommentList isKindOfClass:[NSArray class]]) {
                    NSDictionary *postAttachCommentListData = @{@"postId":postUUId, @"attachCommentList":attachCommentList};
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedAttachCommentList object:postAttachCommentListData];
                    });
                }
                NSInteger postCommentNum = [[data objectForKey:@"postCommentNum"] integerValue];
                NSInteger likeNum = [[data objectForKey:@"postLikeNum"] integerValue];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMomentWithLikeNum:likeNum WithCommentNum:postCommentNum withPostId:postUUId];
                NSDictionary *postCommentData = @{@"postId":postUUId, @"postCommentNum":@(postCommentNum)};
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedCommentNum object:postCommentData];
                });
                
                NSDictionary *deleteCommentData = [data objectForKey:@"deleteCommentData"];
                if ([deleteCommentData isKindOfClass:[NSDictionary class]]) {
                    NSString *commentUUID = [deleteCommentData objectForKey:@"commentUUID"];
                    BOOL isDeleteFlag = [[deleteCommentData objectForKey:@"isDelete"] boolValue];
                    NSString *superParentCommentUUID = [deleteCommentData objectForKey:@"superParentCommentUUID"];
                    NSInteger superParentStatus = [[deleteCommentData objectForKey:@"superParentStatus"] integerValue];
                    if (isDeleteFlag == YES) {
                        
                        if (superParentStatus == 0) {
                            //0主评论没有被删除,正常只删这一条评论
                            NSDictionary *deleteCommentDic = @{@"uuid":commentUUID, @"isDelete":@(YES)};
                            [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteComments:@[deleteCommentDic]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (callback) {
                                    callback(YES, superParentStatus);
                                }
                            });
                        } else if (superParentStatus == 1) {
                            //1标识主评论已被删除但是还有子评论在客户端需标识该评论已被删除
                            NSDictionary *deleteCommentDic = @{@"uuid":commentUUID, @"isDelete":@(YES)};
                            [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteComments:@[deleteCommentDic]];
                            
                            //更新主评论为“该评论已被删除”
                            [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkUpdateComments:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (callback) {
                                    callback(YES, superParentStatus);
                                }
                            });
                        } else if (superParentStatus == 2) {
                            //2标识主评论已删除且没有了子评论在客户端可直接删除掉
                            [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkDeleteCommentsAndAllChildComments:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (callback) {
                                    callback(YES, superParentStatus);
                                }
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (callback) {
                                    callback(NO, 0);
                                }
                            });
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (callback) {
                                callback(NO, 0);
                            }
                        });
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(NO, 0);
                    }
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(NO, 0);
            }
        });
    }];
}


//获取我的回复列表
- (void)getRemoteOwnerCamelGetMyReplyWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(nonnull void (^)(NSArray * _Nonnull))complete{
    NSString * urlStr = [NSString stringWithFormat:@"%@/cricle_camel/ownerCamel/getMyReply", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@(createTime) forKey:@"createTime"];
    [bodyDic setObject:[STIMManager getLastUserName] forKey:@"owner"];
    [bodyDic setObject:[[STIMManager sharedInstance]getDomain] forKey:@"ownerHost"];
    [bodyDic setObject:@(20) forKey:@"pgSize"];
    
    STIMVerboseLog(@"ownerCamel/getMyReply : %@", bodyDic);
    NSData *hotCommentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    
    [self sendTPPOSTRequestWithUrl:urlStr withRequestBodyData:[[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil] withSuccessCallBack:^(NSData *responseData) {
        NSDictionary * result = [[STIMJSONSerializer sharedInstance]deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errorCode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errorCode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *deleteComments = [data objectForKey:@"deleteComments"];
                if (deleteComments.count > 0) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteWorkNoticeMessageWithUUid:deleteComments];
                }
                NSArray *newComment = [data objectForKey:@"newComment"];
                if (newComment > 0) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertNoticeMessage:newComment];
                } else {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteWorkNoticeMessageWithEventTypes:@[@(STIMWorkFeedNotifyTypeMyComment)]];
                }
                if (complete) {
                    complete([newComment copy]);
                }
            }
            else {
                if (complete) {
                    complete(nil);
                }
            }
        }
        else{
            if (complete) {
                complete(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (complete) {
            complete(nil);
        }
    }];
}


//获取@我的数据列表

- (void)getRemoteOwnerCamelGetAtListWithCreateTime:(long long)createTime pageSize:(NSInteger)pageSize complete:(nonnull void (^)(NSArray * _Nonnull))complete{
    
    NSString * urlStr = [NSString stringWithFormat:@"%@/cricle_camel/ownerCamel/getAtList", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@(createTime) forKey:@"createTime"];;
    [bodyDic setObject:[STIMManager getLastUserName] forKey:@"owner"];
    [bodyDic setObject:[[STIMManager sharedInstance]getDomain] forKey:@"ownerHost"];
    [bodyDic setObject:@(20) forKey:@"pgSize"];
    
    STIMVerboseLog(@"ownerCamel/getAtList : %@", bodyDic);
    NSData *hotCommentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    [self sendTPPOSTRequestWithUrl:urlStr withRequestBodyData:[[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil] withSuccessCallBack:^(NSData *responseData) {
        NSDictionary * result = [[STIMJSONSerializer sharedInstance]deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errorCode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errorCode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                // undo
                NSArray *deleteAtList = [data objectForKey:@"deleteAtList"];
                if (deleteAtList.count > 0) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteWorkNoticeMessageWithUUid:deleteAtList];
                }
                NSArray *newAtList = [data objectForKey:@"newAtList"];
                if (newAtList.count > 0) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertNoticeMessage:newAtList];
                } else {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteWorkNoticeMessageWithEventTypes:@[@(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
                }
                
                if (complete) {
                    complete([newAtList copy]);
                }
            }
            else{
                if (complete) {
                    complete(nil);
                }
            }
        }
        else{
            if (complete) {
                complete(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (complete) {
            complete(nil);
        }
    }];
}


#pragma mark - 用户入口

- (void)getCricleCamelEntrance {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/entranceV2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];

    [self sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([result isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
            if (ret && errcode == 0) {
                NSDictionary *data = [result objectForKey:@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    BOOL authSign = [[data objectForKey:@"authSign"] boolValue];
                    BOOL oldAuthSign = [[[STIMUserCacheManager sharedInstance] userObjectForKey:@"kUserWorkFeedEntrance"] boolValue];
                    [[STIMUserCacheManager sharedInstance] setUserObject:@(authSign) forKey:@"kUserWorkFeedEntrance"];
                    if (authSign != oldAuthSign && authSign == NO) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyReloadWorkFeedEntrance object:nil];
                        });
                    }
                }
            } else {
                
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

#pragma mark - 用户发视频size权限
- (void)getCricleCamelVideoConfig {
    NSString *destUrl = [NSString stringWithFormat:@"%@/video/getUserVideoConfig", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    [self sendTPPOSTRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                BOOL useAble = [[data objectForKey:@"useAble"] boolValue];
                BOOL highDefinition = [[data objectForKey:@"highDefinition"] boolValue];
                NSInteger videoFileSize = [[data objectForKey:@"videoFileSize"] integerValue];
                NSInteger videoTimeLen = [[data objectForKey:@"videoTimeLen"] integerValue];
                NSInteger videoMaxTimeLen = [[data objectForKey:@"videoMaxTimeLen"] integerValue];
                [[STIMUserCacheManager sharedInstance] setUserObject:@(useAble) forKey:@"VideoConfigUseAble"];
                [[STIMUserCacheManager sharedInstance] setUserObject:@(highDefinition) forKey:@"highDefinition"];
                [[STIMUserCacheManager sharedInstance] setUserObject:@(videoFileSize) forKey:@"videoFileSize"];
                [[STIMUserCacheManager sharedInstance] setUserObject:@(videoTimeLen) forKey:@"videoTimeLen"];
                [[STIMUserCacheManager sharedInstance] setUserObject:@(videoMaxTimeLen) forKey:@"videoMaxTimeLen"];
            }
        }
    } withFailedCallBack:^(NSError *error) {

    }];
}

#pragma mark - Remote Notice

- (void)getupdateRemoteWorkNoticeMsgs {
//    {@"messageTime":0, "user":"lilulucas.li", "userHost":"ejabhost1", "messageId":"123"}
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/message/getMessageList", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    long long maxTime = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkNoticeMessagesMaxTime];
    [bodyDic setObject:@(self.lastWorkFeedMsgMsgTime) forKey:@"messageTime"];
    [bodyDic setObject:[STIMManager getLastUserName] forKey:@"user"];
    [bodyDic setObject:[[STIMManager sharedInstance] getDomain] forKey:@"userHost"];
    
    STIMVerboseLog(@"message/getMessageList Body : %@", bodyDic);
    NSData *noticeReadStateData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:noticeReadStateData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *msgList = [data objectForKey:@"msgList"];
                if ([msgList isKindOfClass:[NSArray class]]) {
                    [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkinsertNoticeMessage:msgList];
                    NSInteger notReadMessageCount = [[STIMManager sharedInstance] getWorkNoticeMessagesCountWithEventType:@[@(STIMWorkFeedNotifyTypeComment), @(STIMWorkFeedNotifyTypePOSTAt), @(STIMWorkFeedNotifyTypeCommentAt)]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //发送驼圈离线消息通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPBPresenceCategoryNotifyWorkNoticeMessage object:nil];
                        //发送驼圈离线消息小红点通知
                        STIMVerboseLog(@"发送驼圈离线消息小红点通知数: %ld", notReadMessageCount);
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkNoticeCount":@(notReadMessageCount)}];
                    });
                }
            }
            STIMVerboseLog(@"拉取离work线消息成功");
            STIMVerboseLog(@"清除本地work线消息时间戳");
            [[STIMUserCacheManager sharedInstance] removeUserObjectForKey:kGetNewWorkFeedHistoryMessageListError];
            STIMVerboseLog(@"强制塞本地驼圈消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewWorkFeedHistoryMessageListError] longLongValue]);
        } else {
            STIMVerboseLog(@"拉取离work线消息失败");
            STIMVerboseLog(@"重新set本地work线消息时间戳");
            [[STIMUserCacheManager sharedInstance] setUserObject:@(self.lastWorkFeedMsgMsgTime) forKey:kGetNewWorkFeedHistoryMessageListError];
            STIMVerboseLog(@"强制塞本地驼圈消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewWorkFeedHistoryMessageListError] longLongValue]);
        }
    } withFailedCallBack:^(NSError *error) {
        STIMVerboseLog(@"拉取离work线消息失败");
        STIMVerboseLog(@"重新set本地work线消息时间戳");
        [[STIMUserCacheManager sharedInstance] setUserObject:@(self.lastWorkFeedMsgMsgTime) forKey:kGetNewWorkFeedHistoryMessageListError];
        STIMVerboseLog(@"强制塞本地驼圈消息消息时间戳完成之后再取一下本地错误时间戳 : %lld", [[[STIMUserCacheManager sharedInstance] userObjectForKey:kGetNewWorkFeedHistoryMessageListError] longLongValue]);
    }];
}

- (void)updateRemoteWorkNoticeMsgReadStateWithTime:(long long)time {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/message/readMark", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:@(time) forKey:@"time"];
    
    STIMVerboseLog(@"/message/readMark : %@", bodyDic);
    NSData *noticeReadStateData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    __weak __typeof(self) weakSelf = self;
    
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:noticeReadStateData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            STIMVerboseLog(@"设置已读成功");
        } else {
            STIMVerboseLog(@"设置已读失败");
        }
    } withFailedCallBack:^(NSError *error) {

    }];
}

#pragma mark - 驼圈提醒开关

- (BOOL)getLocalWorkMomentNotifyConfig {
    BOOL exist = [[IMDataManager stIMDB_SharedInstance] stIMDB_checkExistUserCacheDataWithKey:kWorkMomentNotifySwitchConfig withType:12];
    if (exist) {
        return [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserCacheDataWithKey:kWorkMomentNotifySwitchConfig withType:12];
    } else {
        return YES;
    }
}

- (void)getRemoteWorkMomentSwitch {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/notify_config/getNotifyConfig", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"notifyUser"];
    [bodyDic setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"host"];
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                BOOL flag = [[data objectForKey:@"flag"] boolValue];
                NSString *notifyKey = [data objectForKey:@"notifyKey"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateUserCacheDataWithKey:kWorkMomentNotifySwitchConfig withType:12 withValue:@"驼圈开关" withValueInt:flag];
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)updateRemoteWorkMomentNotifyConfig:(BOOL)flag withCallBack:(STIMKitUpdateMomentNotifyConfigSuccessedBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/notify_config/updateNotifyConfig", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"notifyUser"];
    [bodyDic setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"host"];
    [bodyDic setSTIMSafeObject:@(flag) forKey:@"flag"];
    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                BOOL flag = [[data objectForKey:@"flag"] boolValue];
                NSString *notifyKey = [data objectForKey:@"notifyKey"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateUserCacheDataWithKey:kWorkMomentNotifySwitchConfig withType:12 withValue:@"驼圈开关" withValueInt:flag];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyUpdateNotifyConfig object:@(flag)];
                    if (callback) {
                        callback(YES);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(NO);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(NO);
                }
            });
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(NO);
            }
        });
    }];
}


#pragma mark - SearchMoment

- (void)searchMomentWithKey:(NSString *)key withSearchTime:(long long)searchTime withStartNum:(NSInteger)startNum withPageNum:(NSInteger)pageNum withSearchType:(NSInteger)searchType  withCallBack:(STIMKitSearchMomentBlock)callback {
    NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/search", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setSTIMSafeObject:key forKey:@"key"];
    //    [bodyDic setSTIMSafeObject:@"" forKey:@"searchTime"];
    [bodyDic setSTIMSafeObject:@(startNum) forKey:@"startNum"];
    [bodyDic setSTIMSafeObject:@(pageNum) forKey:@"pageNum"];
    [bodyDic setSTIMSafeObject:@(3) forKey:@"searchType"];

    NSData *bodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
    [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:bodyData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSDictionary *data = [result objectForKey:@"data"];
            if ([data isKindOfClass:[NSArray class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(data);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(nil);
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback(nil);
                }
            });
        }
    } withFailedCallBack:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    }];
}

#pragma mark - Local Moments

- (void)getRemoteLastWorkMoment {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *destUrl = [NSString stringWithFormat:@"%@/cricle_camel/post/getPostList/v2", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
        NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [bodyDic setSTIMSafeObject:@(0) forKey:@"postCreateTime"];
        [bodyDic setSTIMSafeObject:nil forKey:@"owner"];
        [bodyDic setSTIMSafeObject:nil forKey:@"ownerHost"];
        [bodyDic setSTIMSafeObject:@(1) forKey:@"pageSize"];
        [bodyDic setSTIMSafeObject:@(0) forKey:@"getTop"];
        [bodyDic setSTIMSafeObject:@(1) forKey:@"postType"];
        
        STIMVerboseLog(@"post/getPostList : %@", bodyDic);
        NSData *momentBodyData = [[STIMJSONSerializer sharedInstance] serializeObject:bodyDic error:nil];
        [self sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:momentBodyData withSuccessCallBack:^(NSData *responseData) {
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
            if (ret && errcode == 0) {
                NSDictionary *moments = [result objectForKey:@"data"];
                if ([moments isKindOfClass:[NSDictionary class]]) {
                    NSArray *deletePosts = [moments objectForKey:@"deletePost"];
                    NSArray *newPosts = [moments objectForKey:@"newPost"];
                    if ([deletePosts isKindOfClass:[NSArray class]]) {
                        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkdeleteMoments:deletePosts];
                    }
                    if ([newPosts isKindOfClass:[NSArray class]]) {
                        if (newPosts.count > 0) {
                            NSDictionary *lastMomentDic = [newPosts firstObject];
                            NSString *momentUUId = [lastMomentDic objectForKey:@"uuid"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkMoment":@(![self checkWorkMomentExistWithMomentId:momentUUId])}];
                            });
                            NSDictionary *momoentDic = [self getLastWorkMomentWithDic:lastMomentDic];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SUGGEST_WorkFeed_UPDATE object:momoentDic];
                            });
                        } else {
                            NSDictionary *localLastMomentDic = [self getLastWorkMoment];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //发送新帖子通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNotReadWorkCountChange object:@{@"newWorkMoment":@(YES)}];
                                });
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_RN_QTALK_SUGGEST_WorkFeed_UPDATE object:localLastMomentDic];
                            });
                        }
                    } else {
                        
                    }
                } else {
                }
            }
        } withFailedCallBack:^(NSError *error) {
            
        }];
    });
}

- (NSDictionary *)getLastWorkOnlineMomentWithDic:(NSDictionary *)dic {
    NSLog(@"getLastWorkOnlineMomentWithDic : %@", dic);
    NSMutableDictionary *momentDic = [[NSMutableDictionary alloc] init];
    NSString *userId = [NSString stringWithFormat:@"%@@%@", [dic objectForKey:@"owner"], [dic objectForKey:@"ownerHost"]];
    NSString *userName = [[STIMManager sharedInstance] getUserMarkupNameWithUserId:userId];
    NSString *photoUrl = nil;
    
    BOOL fromIsAnonymous = [[dic objectForKey:@"isAnyonous"] boolValue];
    if (fromIsAnonymous == YES) {
        userName = [dic objectForKey:@"anyonousName"];
        photoUrl = [dic objectForKey:@"anyonousPhoto"];
        if (![photoUrl stimDB_hasPrefixHttpHeader] && photoUrl.length > 0) {
            photoUrl = [NSString stringWithFormat:@"%@/%@", [[STIMNavConfigManager sharedInstance] innerFileHttpHost], photoUrl];
        }
    } else {
        NSDictionary *userInfo = [[STIMManager sharedInstance] getUserInfoByUserId:userId];
        NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"";
        NSString *lastDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
        photoUrl = [userInfo objectForKey:@"HeaderSrc"];
        if (![photoUrl stimDB_hasPrefixHttpHeader] && photoUrl.length > 0) {
            photoUrl = [NSString stringWithFormat:@"%@/%@", [[STIMNavConfigManager sharedInstance] innerFileHttpHost], photoUrl];
        }
        [momentDic setSTIMSafeObject:lastDp forKey:@"architecture"];
    }
    
    NSString *content = [dic objectForKey:@"content"];
    
    [momentDic setSTIMSafeObject:(content.length > 0) ? content : @"分享图片" forKey:@"content"];
    [momentDic setSTIMSafeObject:(userName.length > 0) ? userName : @"" forKey:@"name"];
    [momentDic setSTIMSafeObject:(photoUrl.length > 0) ? photoUrl : [STIMManager defaultUserHeaderImagePath] forKey:@"photo"];
    STIMVerboseLog(@"RN getLastWorkOnlineMomentWithDic : %@", momentDic);
    return momentDic;
}

- (NSDictionary *)getLastWorkMomentWithDic:(NSDictionary *)dic {
    NSLog(@"getLastWorkMomentWithDic : %@", dic);
    NSMutableDictionary *momentDic = [[NSMutableDictionary alloc] init];
    NSString *userId = [NSString stringWithFormat:@"%@@%@", [dic objectForKey:@"owner"], [dic objectForKey:@"ownerHost"]];
    NSString *userName = [[STIMManager sharedInstance] getUserMarkupNameWithUserId:userId];
    NSString *photoUrl = nil;
    
    BOOL fromIsAnonymous = [[dic objectForKey:@"isAnonymous"] boolValue];
    if (fromIsAnonymous == YES) {
        userName = [dic objectForKey:@"anonymousName"];
        photoUrl = [dic objectForKey:@"anonymousPhoto"];
        if (![photoUrl stimDB_hasPrefixHttpHeader] && photoUrl.length > 0) {
            photoUrl = [NSString stringWithFormat:@"%@/%@", [[STIMNavConfigManager sharedInstance] innerFileHttpHost], photoUrl];
        }
    } else {
        NSDictionary *userInfo = [[STIMManager sharedInstance] getUserInfoByUserId:userId];
        NSString *department = [userInfo objectForKey:@"DescInfo"]?[userInfo objectForKey:@"DescInfo"]:@"";
        NSString *lastDp = [[department componentsSeparatedByString:@"/"] objectAtIndex:2];
        photoUrl = [userInfo objectForKey:@"HeaderSrc"];
        if (![photoUrl stimDB_hasPrefixHttpHeader] && photoUrl.length > 0) {
            photoUrl = [NSString stringWithFormat:@"%@/%@", [[STIMNavConfigManager sharedInstance] innerFileHttpHost], photoUrl];
        }
        [momentDic setSTIMSafeObject:lastDp forKey:@"architecture"];
    }
    
    NSString *content = [dic objectForKey:@"content"];
    NSDictionary *contentDic = [[STIMJSONSerializer sharedInstance] deserializeObject:content error:nil];
    NSString *showContent = [contentDic objectForKey:@"content"];
    
    [momentDic setSTIMSafeObject:(showContent.length > 0) ? showContent : @"分享图片" forKey:@"content"];
    [momentDic setSTIMSafeObject:(userName.length > 0) ? userName : @"" forKey:@"name"];
    [momentDic setSTIMSafeObject:(photoUrl.length > 0) ? photoUrl : [STIMManager defaultUserHeaderImagePath] forKey:@"photo"];
    STIMVerboseLog(@"RN getLastWorkMoment : %@", momentDic);
    return momentDic;
}

- (NSDictionary *)getLastWorkMoment {
    NSDictionary *result = [[IMDataManager stIMDB_SharedInstance] stIMDB_getLastWorkMoment];
    return [self getLastWorkMomentWithDic:result];
}

- (NSDictionary *)getWorkMomentWithMomentId:(NSString *)momentId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkMomentWithMomentId:momentId];
}

- (void)getWorkMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete{
    if (firstLocal) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkMomentWithXmppId:xmppId WithLimit:limit WithOffset:offset];
            if (array.count > 0) {
                __block NSMutableArray *list = [NSMutableArray arrayWithArray:array];
                if (list.count >= limit) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(list);
                    });
                } else {
                    
                    NSDictionary *momentDic = [array lastObject];
                    STIMVerboseLog(@"last momentDic : %@", momentDic);
                    long long time = [[momentDic objectForKey:@"createTime"] longLongValue];
                    if (self.load_history_msg == nil) {
                        self.load_history_msg = dispatch_queue_create("Load History", 0);
                    }
                    dispatch_async(self.load_history_msg, ^{
                        [[STIMManager sharedInstance] getMomentHistoryWithLastUpdateTime:time withOwnerXmppId:xmppId withPostType:7 withCallBack:^(NSArray *moments) {
                            [list addObjectsFromArray:moments];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                complete(list);
                            });
                        }];
                    });
                }
            }
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[STIMManager sharedInstance] getMomentHistoryWithLastUpdateTime:lastMomentTime withOwnerXmppId:xmppId withPostType:7 withCallBack:^(NSArray *moments) {
                if (moments) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(moments);
                    });
                } else {
                    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkMomentWithXmppId:xmppId WithLimit:limit WithOffset:offset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(array);
                    });
                }
            }];
        });
    }
}

- (void)getWorkMoreMomentWithLastMomentTime:(long long)lastMomentTime withUserXmppId:(NSString *)xmppId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalMoment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete{
    if (firstLocal) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkMomentWithXmppId:xmppId WithLimit:limit WithOffset:offset];
            if (array.count) {
                __block NSMutableArray *list = [NSMutableArray arrayWithArray:array];
                if (list.count >= limit) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(list);
                    });
                } else {
                    
                    NSDictionary *momentDic = [array lastObject];
                    STIMVerboseLog(@"last momentDic : %@", momentDic);
                    long long time = [[momentDic objectForKey:@"createTime"] longLongValue];
                    if (self.load_history_msg == nil) {
                        self.load_history_msg = dispatch_queue_create("Load History", 0);
                    }
                    dispatch_async(self.load_history_msg, ^{
                        [[STIMManager sharedInstance] getMomentHistoryWithLastUpdateTime:time withOwnerXmppId:xmppId withPostType:1 withCallBack:^(NSArray *moments) {
                            [list addObjectsFromArray:moments];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                complete(list);
                            });
                        }];
                    });
                }
            }
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[STIMManager sharedInstance] getMomentHistoryWithLastUpdateTime:lastMomentTime withOwnerXmppId:xmppId withPostType:1 withCallBack:^(NSArray *moments) {
                if (moments) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(moments);
                    });
                } else {
                    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkMomentWithXmppId:xmppId WithLimit:limit WithOffset:offset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(array);
                    });
                }
            }];
        });
    }
}

#pragma mark - Local Comments

- (void)getWorkCommentWithLastCommentRId:(NSInteger)lastCommentRId withMomentId:(NSString *)momentId WithLimit:(int)limit WithOffset:(int)offset withFirstLocalComment:(BOOL)firstLocal WithComplete:(void (^)(NSArray *))complete{
    if (firstLocal) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkCommentsWithMomentId:momentId WithLimit:limit WithOffset:offset];
            if (array.count > 0) {
                __block NSMutableArray *list = [NSMutableArray arrayWithArray:array];
                if (list.count >= limit) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(list);
                    });
                } else {
                    NSDictionary *commentDic = [array lastObject];
                    NSInteger commentRId = [[commentDic objectForKey:@"rid"] integerValue];
                    NSLog(@"commentDic : %@", commentDic);
                    if (self.load_history_msg == nil) {
                        self.load_history_msg = dispatch_queue_create("Load History", 0);
                    }
                     dispatch_async(self.load_history_msg, ^{
                        [[STIMManager sharedInstance] getRemoteCommentsHistoryWithLastCommentId:commentRId withMomentId:momentId withCommentCallBack:^(NSArray *comments) {
                            [list addObjectsFromArray:comments];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                complete(list);
                            });
                        }];
                    });
                }
            }
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [[STIMManager sharedInstance] getRemoteCommentsHistoryWithLastCommentId:lastCommentRId withMomentId:momentId withCommentCallBack:^(NSArray *comments) {
                if (comments) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(comments);
                    });
                } else {
                    NSArray *array = [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkCommentsWithMomentId:momentId WithLimit:limit WithOffset:offset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        complete(array);
                    });
                }
            }];
        });
    }
}

- (NSArray *)getWorkChildCommentsWithParentCommentUUID:(NSString *)parentCommentUUID {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkChildCommentsWithParentCommentUUID:parentCommentUUID];
}

- (NSInteger)getWorkNoticeMessagesCountWithEventType:(NSArray *)eventTypes {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkNoticeMessagesCountWithEventType:eventTypes];
}

- (BOOL)checkWorkMomentExistWithMomentId:(NSString *)momentId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_checkMomentWithMomentId:momentId];
}

//新加
- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes readState:(int)readState {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkNoticeMessagesWithLimit:limit WithOffset:offset eventTypes:eventTypes readState:readState];
}

//新加
- (NSArray *)getWorkNoticeMessagesWithLimit:(int)limit WithOffset:(int)offset eventTypes:(NSArray *)eventTypes {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getWorkNoticeMessagesWithLimit:limit WithOffset:offset eventTypes:eventTypes];
}

- (void)updateLocalWorkNoticeMsgReadStateWithTime:(long long)time {
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateWorkNoticeMessageReadStateWithTime:time];
}

@end
