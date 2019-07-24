
//
//  QIMKit+QIMConsult.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "QIMKit+QIMConsult.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMConsult)

//- (NSMutableDictionary *)virtualRealJidDic {
//    return [[QIMManager sharedInstance] virtualRealJidDic];
//}

/*
- (NSArray *)getVirtualList{
    
    return [[QIMManager sharedInstance] getVirtualList];
}
*/

- (QIMMessageModel *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendConsultMessageId:msgId WithMessage:msg WithInfo:info toJid:toJid realToJid:realToJid WithChatType:chatType WithMsgType:msgType];
}

- (void)customerConsultServicesayHelloWithUser:(NSString *)user WithVirtualId:(NSString *)virtualId WithFromUser:(NSString *)fromUser{
    [[QIMManager sharedInstance] customerConsultServicesayHelloWithUser:user WithVirtualId:virtualId WithFromUser:fromUser];
}

- (void)customerServicesayHelloWithUser:(NSString *)user{
    [[QIMManager sharedInstance] customerServicesayHelloWithUser:user];
}

- (NSArray *)searchSuggestWithKeyword:(NSString *)keyword{

    return [[QIMManager sharedInstance] searchSuggestWithKeyword:keyword];
}

- (NSArray *)getSuggestOrganizationBySuggestId:(NSString *)suggestId{
    return [[QIMManager sharedInstance] getSuggestOrganizationBySuggestId:suggestId];
}

/**
 获取虚拟帐号列表
 */
- (NSDictionary *)getVirtualDic {
    return [[QIMManager sharedInstance] getVirtualDic];
}

/**
 获取我服务的虚拟帐号列表
 */
- (NSArray *)getMyhotLinelist {
    return [[QIMManager sharedInstance] getMyhotLinelist];
}

//V2版获取客服坐席列表：支持多店铺
- (NSArray *)getSeatSeStatus {
    return [[QIMManager sharedInstance] getSeatSeStatus];;
}

//V2版区别Shop来设置服务模式upSeatSeStatusWithSid.qunar
- (BOOL)updateSeatSeStatusWithShopId:(NSInteger)shopId WithStatus:(NSInteger)shopServiceStatus {
    return [[QIMManager sharedInstance] updateSeatSeStatusWithShopId:shopId WithStatus:shopServiceStatus];
}

- (NSDictionary *)userSeatStatusDict:(int)userStatus {
    
    return [[QIMManager sharedInstance] userSeatStatusDict:userStatus];
}

- (NSString *)userStatusTitleWithStatus:(int)userStatus {
    return [[QIMManager sharedInstance] userStatusTitleWithStatus:userStatus];
}

- (NSArray *)availableUserSeatStatus {
    
    return [[QIMManager sharedInstance]availableUserSeatStatus];
}

- (void)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId withBlock:(QIMCloseSessionBlock)block{
    [[QIMManager sharedInstance] closeSessionWithShopId:shopId WithVisitorId:visitorId withBlock:block];
}

@end
