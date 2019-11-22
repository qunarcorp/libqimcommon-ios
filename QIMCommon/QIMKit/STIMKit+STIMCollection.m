//
//  STIMKit+STIMCollection.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#import "STIMKit+STIMCollection.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMCollection)

- (NSString *)getCollectionUserHeaderUrlWithXmppId:(NSString *)userId {
    return [[STIMManager sharedInstance] getCollectionUserHeaderUrlWithXmppId:userId];
}

- (NSString *)getCollectionGroupHeaderUrlWithCollectionGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getCollectionGroupHeaderUrlWithCollectionGroupId:groupId];
}

- (NSDictionary *)getCollectionUserInfoByUserId:(NSString *)myId {
    
    return [[STIMManager sharedInstance] getCollectionUserInfoByUserId:myId];
}

- (void)updateCollectionUserCardByUserIds:(NSArray *)userIds {
    [[STIMManager sharedInstance] updateCollectionUserCardByUserIds:userIds];
}

- (void)saveCollectionMessage:(NSDictionary *)collectionMsgDic {
    [[STIMManager sharedInstance] saveCollectionMessage:collectionMsgDic];
}

- (STIMMessageModel *)getCollectionMsgListForMsgId:(NSString *)msgId {
    return [[STIMManager sharedInstance] getCollectionMsgListForMsgId:msgId];
}

- (NSArray *)getCollectionMsgListForUserId:(NSString *)userId originUserId:(NSString *)originUserId {

    return [[STIMManager sharedInstance] getCollectionMsgListForUserId:userId originUserId:originUserId];
}

- (NSDictionary *)getLastCollectionMsgByMsgId:(NSString *)lastMsgId {
    return [[STIMManager sharedInstance] getLastCollectionMsgByMsgId:lastMsgId];
}

- (NSArray *)getCollectionSessionListWithBindId:(NSString *)bindId {
    return [[STIMManager sharedInstance] getCollectionSessionListWithBindId:bindId];
}

- (NSArray *)getCollectionMsgListWithBindId:(NSString *)bindId {
    return [[STIMManager sharedInstance] getCollectionMsgListWithBindId:bindId];
}

- (NSArray *)getMyCollectionAccountList {
    return [[STIMManager sharedInstance] getMyCollectionAccountList];
}

- (void)getRemoteCollectionAccountList {
    [[STIMManager sharedInstance] getRemoteCollectionAccountList];
}

- (void)clearNotReadCollectionMsgByJid:(NSString *)jid {
    [[STIMManager sharedInstance] clearNotReadCollectionMsgByJid:jid];
}

- (void)clearNotReadCollectionMsgByBindId:(NSString *)bindId WithUserId:(NSString *)userId {
    [[STIMManager sharedInstance] clearNotReadCollectionMsgByBindId:bindId WithUserId:userId];
}

- (NSInteger)getNotReadCollectionMsgCount {
    return [[STIMManager sharedInstance] getNotReadCollectionMsgCount];
}

- (NSInteger)getNotReadCollectionMsgCountByBindId:(NSString *)bindId {
    return [[STIMManager sharedInstance] getNotReadCollectionMsgCountByBindId:bindId];
}

- (NSInteger)getNotReadCollectionMsgCountByBindId:(NSString *)bindId WithUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] getNotReadCollectionMsgCountByBindId:bindId WithUserId:userId];
}

#pragma mark - 代收Group

- (NSDictionary *)getCollectionGroupCardByGroupId:(NSString *)groupId {
    return [[STIMManager sharedInstance] getCollectionGroupCardByGroupId:groupId];
}

- (void)updateCollectionGroupCardByGroupId:(NSString *)groupId {

    [[STIMManager sharedInstance] updateCollectionGroupCardByGroupId:groupId];
}

@end
