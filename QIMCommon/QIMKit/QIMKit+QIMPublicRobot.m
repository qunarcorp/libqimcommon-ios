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

- (NSArray *)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag {
    return [[QIMManager sharedInstance] updatePublicNumberCardByIds:publicNumberIdList WithNeedUpdate:flag];
}

#pragma mark - sss

- (NSArray *)recommendRobot {
    return [[QIMManager sharedInstance] recommendRobot];
}

- (void)registerPublicNumber {
    [[QIMManager sharedInstance] registerPublicNumber];
}

- (NSArray *)getPublicNumberList {
    return [[QIMManager sharedInstance] getPublicNumberList];
}

- (void)updatePublicNumberList {
    [[QIMManager sharedInstance] updatePublicNumberList];
}

- (BOOL)focusOnPublicNumberId:(NSString *)publicNumberId {
    return [[QIMManager sharedInstance] focusOnPublicNumberId:publicNumberId];
}

- (BOOL)cancelFocusOnPublicNumberId:(NSString *)publicNumberId {
    return [[QIMManager sharedInstance] cancelFocusOnPublicNumberId:publicNumberId];
}

#pragma mark - 公众号消息

- (Message *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType {
    return [[QIMManager sharedInstance] createPublicNumberMessageWithMsg:msg extenddInfo:extendInfo publicNumberId:publicNumberId msgType:msgType];
}

- (Message *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WihtMsgType:(int)msgType {
    return [[QIMManager sharedInstance] sendMessage:msg ToPublicNumberId:publicNumberId WithMsgId:msgId WihtMsgType:msgType];
}

- (NSArray *)getPublicNumberMsgListById:(NSString *)publicNumberId WihtLimit:(int)limit WithOffset:(int)offset {
    return [[QIMManager sharedInstance] getPublicNumberMsgListById:publicNumberId WihtLimit:limit WithOffset:offset];
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

- (NSArray *)searchRobotByKeyStr:(NSString *)keyStr {
    return [[QIMManager sharedInstance] searchRobotByKeyStr:keyStr];
}

@end
