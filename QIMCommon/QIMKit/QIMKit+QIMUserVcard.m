//
//  QIMKit+QIMUserVcard.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/23.
//

#import "QIMKit+QIMUserVcard.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMUserVcard)

- (void)updateUserMarkupNameWithUserId:(NSString *)userId WithMarkupName:(NSString *)markUpName {
    [[QIMManager sharedInstance] updateUserMarkupNameWithUserId:userId WithMarkupName:markUpName];
}

- (NSString *)getUserMarkupNameWithUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] getUserMarkupNameWithUserId:userId];
}

- (void)updateUserCard:(NSString *)xmppId withCache:(BOOL)cache {
    [[QIMManager sharedInstance] updateUserCard:xmppId withCache:cache];
}

- (void)updateUserCard:(NSArray *)xmppIds {
    [[QIMManager sharedInstance] updateUserCard:xmppIds];
}

- (NSString *)getUserBigHeaderImageUrlWithUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] getUserBigHeaderImageUrlWithUserId:userId];
}

- (void)updateMyCard {
    [[QIMManager sharedInstance] updateMyCard];
}

- (void)updateQChatGroupMembersCardForGroupId:(NSString *)groupId {
    [[QIMManager sharedInstance] updateQChatGroupMembersCardForGroupId:groupId];
}

- (void)updateMyPhoto:(NSData *)photoData {
    [[QIMManager sharedInstance] updateMyPhoto:photoData];
}

- (NSDictionary *)getUserInfoByUserId:(NSString *)myId {
    return [[QIMManager sharedInstance] getUserInfoByUserId:myId];
}

- (NSDictionary *)getUserWorkInfoByUserId:(NSString *)userId {
    return [[QIMManager sharedInstance] getUserWorkInfoByUserId:userId];
}

- (void)getRemoteUserWorkInfoWithUserId:(NSString *)userId withCallBack:(QIMKitGetUserWorkInfoBlock)callback {

    [[QIMManager sharedInstance] getRemoteUserWorkInfoWithUserId:userId withCallBack:callback];
}

- (void)getPhoneNumberWithUserId:(NSString *)qtalkId withCallBack:(QIMKitGetPhoneNumberBlock)callback{
    [[QIMManager sharedInstance] getPhoneNumberWithUserId:qtalkId withCallBack:callback];
}

#pragma mark - 用户头像

+ (NSData *)defaultUserHeaderImage {
    return [QIMManager defaultUserHeaderImage];
}

+ (NSString *)defaultUserHeaderImagePath {
    return [QIMManager defaultUserHeaderImagePath];
}

+ (UIImage *)defaultCommonTrdInfoImage {
    return [QIMManager defaultCommonTrdInfoImage];
}

+ (NSString *)defaultCommonTrdInfoImagePath {
    return [QIMManager defaultCommonTrdInfoImagePath];
}

- (void)updateUserSignature:(NSString *)signature withCallBack:(QIMKitUpdateSignatureBlock)callback {
    
    [[QIMManager sharedInstance] updateUserSignature:signature withCallBack:callback];
}

#pragma mark - 跨域

- (void)searchQunarUserBySearchStr:(NSString *)searchStr withCallback:(QIMKitSearchQunarUserBlock)callback {
    [[QIMManager sharedInstance] searchQunarUserBySearchStr:searchStr withCallback:callback];
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr {
    return [[QIMManager sharedInstance] searchUserListBySearchStr:searchStr];
}

- (NSInteger)searchUserListTotalCountBySearchStr:(NSString *)searchStr {
    return [[QIMManager sharedInstance] searchUserListBySearchStr:searchStr];
}

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset {
    return [[QIMManager sharedInstance] searchUserListBySearchStr:searchStr WithLimit:limit WithOffset:offset];
}

//好友页面搜索
- (void)searchUserListBySearchStr:(NSString *)searchStr Url:(NSString *)searchURL id:(NSString *)Id limit:(NSInteger)limitNum offset:(NSInteger)offset withCallBack:(QIMKitSearchUserListCallBack)callback {
    [[QIMManager sharedInstance] searchUserListBySearchStr:searchStr Url:searchURL id:Id limit:limitNum offset:offset withCallBack:callback];
//    return [[QIMManager sharedInstance] searchUserListBySearchStr:searchStr Url:searchURL id:Id limit:limitNum offset:offset];
}

@end
