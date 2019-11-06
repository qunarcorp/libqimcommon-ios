//
//  QIMManager+UserVcard.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/23.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

@interface QIMManager (UserVcard)

/**
 更新用户备注信息

 @param userId 用户Id
 @param markUpName 用户备注
 */
- (void)updateUserMarkupNameWithUserId:(NSString *)userId WithMarkupName:(NSString *)markUpName;

/**
 获取用户备注信息

 @param userId 用户Id
 @return 用户备注
 */
- (NSString *)getUserMarkupNameWithUserId:(NSString *)userId;

- (void)updateUserCard:(NSString *)xmppId withCache:(BOOL)cache;

/**
 更新用户名片

 @param xmppIds 用户Id数组
 */
- (void)updateUserCard:(NSArray *)xmppIds;

/**
 *  通过userId获取用户大头像
 *
 *  @param userId 头像url
 */
- (NSString *)getUserBigHeaderImageUrlWithUserId:(NSString *)userId;

/**
 更新我的名片信息
 */
- (void)updateMyCard;

- (void)updateQChatGroupMembersCardForGroupId:(NSString *)groupId;

/**
 更新我的头像

 @param photoData 头像二进制
 */
- (void)updateMyPhoto:(NSData *)photoData;

/**
 *  根据用户Id获取用户信息
 *
 *  @param myId 用户Id
 *
 *  @return 用户信息Info
 */
- (NSDictionary *)getUserInfoByUserId:(NSString *)myId;

/**
 + 根据用户Id获取WorkInfo
 + */
- (NSDictionary *)getUserWorkInfoByUserId:(NSString *)userId;


/**
 获取远端用户职工信息

 @param userId 用户Id
 */
- (void)getRemoteUserWorkInfoWithUserId:(NSString *)userId withCallBack:(QIMKitGetUserWorkInfoBlock)callback;

/**
 获取用户手机号

 @param qtalkId qtalkId
 */
- (void)getPhoneNumberWithUserId:(NSString *)qtalkId withCallBack:(QIMKitGetPhoneNumberBlock)callback;

/**
 *  通过nickName获取用户信息
 *
 *  @param nickName 昵称
 *
 *  数据样例： @"李露lucas"
 {
 DescInfo = "/旅游度假事业部/技术/当地人客户端开发";
 HeaderScr = "lilulucas.li@ejabhost1.jpg";
 LastUpdateTime = 5;
 Name = "\U674e\U9732lucas";
 SearchIndex = "liloulucas|liloulucas|lilulucas.li|lllucas|lllucas|";
 UserId = "lilulucas.li";
 XmppId = "lilulucas.li@ejabhost1";
 }
 */

#pragma mark - 用户头像

/**
 *  根据用户Id更新用户头像
 *
 *  @param userId 用户Id
 */
/*
- (void)takeUserHeaderByUserId:(NSString *)userId;
*/

/**
 用户默认头像
 */
+ (NSData *)defaultUserHeaderImage;

+ (NSString *)defaultUserHeaderImagePath;

/**
 获取用户头像本地路径

 @param userId 用户Id
 @param imageSize 用户头像尺寸
 @return 用户头像路径
 */
//- (NSString *)getHeaderImageLocalPathForUserId:(NSString *)userId WithHeaderImageSize:(CGSize)imageSize;

/**
 用户头像

 @param userId 用户Id
 */
//- (UIImage *)userHeaderImageByUserId:(NSString *)userId ;

/**
 第三方Cell默认头像
 
 @return 用户头像
 */
+ (UIImage *)defaultCommonTrdInfoImage ;

+ (NSString *)defaultCommonTrdInfoImagePath;

/**
 根据用户rtxId获取用户名片信息

 @param rtxId 用户Id
 */
- (NSDictionary *)getUserInfoByRTX:(NSString *)rtxId ;

/**
 更新用户签名

 @param userId 用户Id
 @param signature 个性签名
 */
- (void)updateUserSignature:(NSString *)signature withCallBack:(QIMKitUpdateSignatureBlock)callback;

#pragma mark - 跨域

- (void)searchQunarUserBySearchStr:(NSString *)searchStr withCallback:(QIMKitSearchQunarUserBlock)callback;

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr;

- (NSInteger)searchUserListTotalCountBySearchStr:(NSString *)searchStr;

- (NSArray *)selectUserListExMySelfBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

- (NSArray *)searchUserListBySearchStr:(NSString *)searchStr WithLimit:(NSInteger)limit WithOffset:(NSInteger)offset;

//好友页面搜索
- (void)searchUserListBySearchStr:(NSString *)searchStr Url:(NSString *)searchURL id:(NSString *)Id limit:(NSInteger)limitNum offset:(NSInteger)offset withCallBack:(QIMKitSearchUserListCallBack)callback;

@end
