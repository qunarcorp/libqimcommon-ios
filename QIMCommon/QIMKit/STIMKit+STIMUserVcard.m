//
//  STIMKit+STIMUserVcard.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/23.
//

#import "STIMKit+STIMUserVcard.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMUserVcard)

- (void)updateUserMarkupNameWithUserId:(NSString *)userId WithMarkupName:(NSString *)markUpName {
    [[STIMManager sharedInstance] updateUserMarkupNameWithUserId:userId WithMarkupName:markUpName];
}

- (NSString *)getUserMarkupNameWithUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] getUserMarkupNameWithUserId:userId];
}

- (void)updateUserCard:(NSString *)xmppId withCache:(BOOL)cache {
    [[STIMManager sharedInstance] updateUserCard:xmppId withCache:cache];
}

- (void)updateUserCard:(NSArray *)xmppIds {
    [[STIMManager sharedInstance] updateUserCard:xmppIds];
}

- (NSString *)getUserBigHeaderImageUrlWithUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] getUserBigHeaderImageUrlWithUserId:userId];
}

- (void)updateMyCard {
    [[STIMManager sharedInstance] updateMyCard];
}

- (void)updateQChatGroupMembersCardForGroupId:(NSString *)groupId {
    [[STIMManager sharedInstance] updateQChatGroupMembersCardForGroupId:groupId];
}

- (void)updateMyPhoto:(NSData *)photoData {
    [[STIMManager sharedInstance] updateMyPhoto:photoData];
}

- (NSDictionary *)getUserInfoByUserId:(NSString *)myId {
    return [[STIMManager sharedInstance] getUserInfoByUserId:myId];
}

- (NSDictionary *)getUserWorkInfoByUserId:(NSString *)userId {
    return [[STIMManager sharedInstance] getUserWorkInfoByUserId:userId];
}

- (void)getRemoteUserWorkInfoWithUserId:(NSString *)userId withCallBack:(STIMKitGetUserWorkInfoBlock)callback {

    [[STIMManager sharedInstance] getRemoteUserWorkInfoWithUserId:userId withCallBack:callback];
}

- (void)getPhoneNumberWithUserId:(NSString *)qtalkId withCallBack:(STIMKitGetPhoneNumberBlock)callback{
    [[STIMManager sharedInstance] getPhoneNumberWithUserId:qtalkId withCallBack:callback];
}

#pragma mark - 用户头像

+ (NSData *)defaultUserHeaderImage {
    return [STIMManager defaultUserHeaderImage];
}

+ (NSString *)defaultUserHeaderImagePath {
    return [STIMManager defaultUserHeaderImagePath];
}

+ (UIImage *)defaultCommonTrdInfoImage {
    return [STIMManager defaultCommonTrdInfoImage];
}

+ (NSString *)defaultCommonTrdInfoImagePath {
    return [STIMManager defaultCommonTrdInfoImagePath];
}

- (void)updateUserSignature:(NSString *)signature withCallBack:(STIMKitUpdateSignatureBlock)callback {
    
    [[STIMManager sharedInstance] updateUserSignature:signature withCallBack:callback];
}

#pragma mark - 跨域

- (NSArray *)searchQunarUserBySearchStr:(NSString *)searchStr {
    return [[STIMManager sharedInstance] searchQunarUserBySearchStr:searchStr];
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr {
    return [[STIMManager sharedInstance] searchUserListBySearchStr:searchStr];
}

- (NSInteger)searchUserListTotalCountBySearchStr:(NSString *)searchStr {
    return [[STIMManager sharedInstance] searchUserListBySearchStr:searchStr];
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[STIMManager sharedInstance] searchUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

//好友页面搜索
- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr Url:(NSString *)searchURL id:(NSString *)Id limit:(NSInteger)limitNum offset:(NSInteger)offset {
    return [[STIMManager sharedInstance] searchUserListBySearchStr:searchStr Url:searchURL id:Id limit:limitNum offset:offset];
}

@end
