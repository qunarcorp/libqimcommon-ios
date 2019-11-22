//
//  STIMKit+STIMPublicRobot.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/20.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMPublicRobot.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMPublicRobot)

- (int)getDealIdState:(NSString *)dealId {
    return [[STIMManager sharedInstance] getDealIdState:dealId];
}

- (void)setDealId:(NSString *)dealId ForState:(int)state {
    [[STIMManager sharedInstance]setDealId:dealId ForState:state];
}

#pragma mark - 公众号名片信息

- (UIImage *)getPublicNumberHeaderImageByFileName:(NSString *)fileName {
    return [[STIMManager sharedInstance] getPublicNumberHeaderImageByFileName:fileName];
}

- (NSString *)getPublicNumberDefaultHeaderPath {
    return [[STIMManager sharedInstance] getPublicNumberDefaultHeaderPath];
}

- (NSDictionary *)getPublicNumberCardByJid:(NSString *)publicNumberId {
    return [[STIMManager sharedInstance] getPublicNumberCardByJid:publicNumberId];
}

- (NSArray *)updatePublicNumberCardByIds:(NSArray *)publicNumberIdList WithNeedUpdate:(BOOL)flag {
    return [[STIMManager sharedInstance] updatePublicNumberCardByIds:publicNumberIdList WithNeedUpdate:flag];
}

#pragma mark - sss

- (NSArray *)getPublicNumberList {
    return [[STIMManager sharedInstance] getPublicNumberList];
}

- (void)updatePublicNumberList {
    [[STIMManager sharedInstance] updatePublicNumberList];
}

- (BOOL)focusOnPublicNumberId:(NSString *)publicNumberId {
    return [[STIMManager sharedInstance] focusOnPublicNumberId:publicNumberId];
}

- (BOOL)cancelFocusOnPublicNumberId:(NSString *)publicNumberId {
    return [[STIMManager sharedInstance] cancelFocusOnPublicNumberId:publicNumberId];
}

#pragma mark - 公众号消息

- (STIMMessageModel *)createPublicNumberMessageWithMsg:(NSString *)msg extenddInfo:(NSString *)extendInfo publicNumberId:(NSString *)publicNumberId msgType:(PublicNumberMsgType)msgType {
    return [[STIMManager sharedInstance] createPublicNumberMessageWithMsg:msg extenddInfo:extendInfo publicNumberId:publicNumberId msgType:msgType];
}

- (STIMMessageModel *)sendMessage:(NSString *)msg ToPublicNumberId:(NSString *)publicNumberId WithMsgId:(NSString *)msgId WithMsgType:(int)msgType {
    return [[STIMManager sharedInstance] sendMessage:msg ToPublicNumberId:publicNumberId WithMsgId:msgId WithMsgType:msgType];
}

- (NSArray *)getPublicNumberMsgListById:(NSString *)publicNumberId WithLimit:(int)limit WithOffset:(int)offset {
    return [[STIMManager sharedInstance] getPublicNumberMsgListById:publicNumberId WithLimit:limit WithOffset:offset];
}

- (void)clearNotReadMsgByPublicNumberId:(NSString *)jid {
    [[STIMManager sharedInstance] clearNotReadMsgByPublicNumberId:jid];
}

- (void)setNotReaderMsgCount:(int)count ForPublicNumberId:(NSString *)jid {
    [[STIMManager sharedInstance] setNotReaderMsgCount:count ForPublicNumberId:jid];
}

- (int)getNotReaderMsgCountByPublicNumberId:(NSString *)jid {
    return [[STIMManager sharedInstance] getNotReaderMsgCountByPublicNumberId:jid];
}

- (void)checkPNMsgTimeWithJid:(NSString *)jid WithMsgDate:(long long)msgDate {
    [[STIMManager sharedInstance] checkPNMsgTimeWithJid:jid WithMsgDate:msgDate];
}

- (NSArray *)searchRobotByKeyStr:(NSString *)keyStr {
    return [[STIMManager sharedInstance] searchRobotByKeyStr:keyStr];
}

@end
