//
//  QIMKit+QIMPublicRobot.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMPublicRobot.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMPublicRobot)

- (int)getDealIdState:(NSString *)dealId {
    return [[QIMManager sharedInstance] getDealIdState:dealId];
}

- (void)setDealId:(NSString *)dealId ForState:(int)state {
    [[QIMManager sharedInstance]setDealId:dealId ForState:state];
}

#pragma mark - 公众号名片信息

- (UIImage *)getPublicNumberHeaderImageByFileName:(NSString *)fileName {
    return [[QIMManager sharedInstance] getPublicNumberHeaderImageByFileName:fileName];
}

- (NSString *)getPublicNumberDefaultHeaderPath {
    return [[QIMManager sharedInstance] getPublicNumberDefaultHeaderPath];
}

- (NSDictionary *)getPublicNumberCardByJid:(NSString *)publicNumberId {
    return [[QIMManager sharedInstance] getPublicNumberCardByJid:publicNumberId];
}

- (void)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag withCallBack:(QIMKitUpdatePublicNumberCardCallBack)callback {
    [[QIMManager sharedInstance] updatePublicNumberCardByIds:publicNumberIdList WithNeedUpdate:flag withCallBack:callback];
}

#pragma mark - sss

- (NSArray *)getPublicNumberList {
    return [[QIMManager sharedInstance] getPublicNumberList];
}

- (void)updatePublicNumberList {
    [[QIMManager sharedInstance] updatePublicNumberList];
}

- (void)focusOnPublicNumberId:(NSString *)publicNumberId withCallBack:(QIMKitFocusPublicNumberCallBack)callback {
    [[QIMManager sharedInstance] focusOnPublicNumberId:publicNumberId withCallBack:callback];
}

- (void)cancelFocusOnPublicNumberId:(NSString *)publicNumberId withCallBack:(QIMKitCancelFocusPublicNumberCallBack)callback {
    [[QIMManager sharedInstance] cancelFocusOnPublicNumberId:publicNumberId withCallBack:callback];
}

#pragma mark - 公众号消息

- (QIMMessageModel *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType {
    return [[QIMManager sharedInstance] createPublicNumberMessageWithMsg:msg extenddInfo:extendInfo publicNumberId:publicNumberId msgType:msgType];
}

- (QIMMessageModel *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WithMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendMessage:msg ToPublicNumberId:publicNumberId WithMsgId:msgId WithMsgType:msgType];
}

- (NSArray *)getPublicNumberMsgListById:(NSString *)publicNumberId WithLimit:(int)limit WithOffset:(int)offset {
    return [[QIMManager sharedInstance] getPublicNumberMsgListById:publicNumberId WithLimit:limit WithOffset:offset];
}

- (void)clearNotReadMsgByPublicNumberId:(NSString *)jid {
    [[QIMManager sharedInstance] clearNotReadMsgByPublicNumberId:jid];
}

- (void)setNotReaderMsgCount:(int)count ForPublicNumberId:(NSString *)jid {
    [[QIMManager sharedInstance] setNotReaderMsgCount:count ForPublicNumberId:jid];
}

- (int)getNotReaderMsgCountByPublicNumberId:(NSString *)jid {
    return [[QIMManager sharedInstance] getNotReaderMsgCountByPublicNumberId:jid];
}

- (void)checkPNMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate {
    [[QIMManager sharedInstance] checkPNMsgTimeWithJid:jid WithMsgDate:msgDate];
}

- (void)searchRobotByKeyStr:(NSString *)keyStr withCallBack:(QIMKitSearchRobotByKeyStrCallBack)callback {
    [[QIMManager sharedInstance] searchRobotByKeyStr:keyStr withCallBack:callback];
}

@end
