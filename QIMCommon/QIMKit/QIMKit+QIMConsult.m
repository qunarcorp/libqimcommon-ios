
//
//  QIMKit+QIMConsult.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/31.
//

#import "QIMKit+QIMConsult.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMConsult)

- (NSMutableDictionary *)virtualRealJidDic {
    return [[QIMManager sharedInstance] virtualRealJidDic];
}

- (NSArray *)getVirtualList{
    
    return [[QIMManager sharedInstance] getVirtualList];
}

- (Message *)sendConsultMessageId:(NSString *)msgId WithMessage:(NSString *)msg WithInfo:(NSString *)info toJid:(NSString *)toJid realToJid:(NSString *)realToJid WithChatType:(ChatType)chatType WithMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendConsultMessageId:msgId WithMessage:msg WithInfo:info toJid:toJid realToJid:realToJid WithChatType:chatType WithMsgType:msgType];
}


- (void)chatTransferTo:(NSString *)user message:(NSString *)message chatId:(NSString *)chatId {
    [[QIMManager sharedInstance] chatTransferTo:user message:message chatId:chatId];
}

- (void)chatTransferFrom:(NSString *)from To:(NSString *)to User:(NSString *)user Reson:(NSString *)reson chatId:(NSString *)chatId WithMsgId:(NSString *)msgId {
    
    [[QIMManager sharedInstance] chatTransferFrom:from To:to User:user Reson:reson chatId:chatId WithMsgId:msgId];
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

- (NSString *)getRealJidForVirtual:(NSString *)virtualJid{
    return [[QIMManager sharedInstance] getRealJidForVirtual:virtualJid];
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

- (NSString *)closeSessionWithShopId:(NSString *)shopId WithVisitorId:(NSString *)visitorId {
    return [[QIMManager sharedInstance] closeSessionWithShopId:shopId WithVisitorId:visitorId];
}

@end
