//
//  QIMKit+QIMMessageManager.m
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMMessageManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMMessageManager)

- (NSArray *)getSupportMsgTypeList {
    return [[QIMMessageManager sharedInstance] getSupportMsgTypeList];
}

// 会话Cell上显示的文字
- (void)setMsgShowText:(NSString *)showText ForMessageType:(QIMMessageType)messageType {
    [[QIMMessageManager sharedInstance] setMsgShowText:showText ForMessageType:messageType];
}

- (NSString *)getMsgShowTextForMessageType:(QIMMessageType)messageType {
    return [[QIMMessageManager sharedInstance] getMsgShowTextForMessageType:messageType];
}

// 消息气泡
- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType {
    [[QIMMessageManager sharedInstance] registerMsgCellClass:cellClass ForMessageType:messageType];
}

- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType {
    [[QIMMessageManager sharedInstance] registerMsgCellClassName:cellClassName ForMessageType:messageType];
}

- (Class)getRegisterMsgCellClassForMessageType:(QIMMessageType)messageType {
    return [[QIMMessageManager sharedInstance] getRegisterMsgCellClassForMessageType:messageType];
}

- (id)getRegisterMsgCellForMessageType:(QIMMessageType)messageType {
    return [[QIMMessageManager sharedInstance] getRegisterMsgCellForMessageType:messageType];
}

// 消息定制窗口
- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType {
    [[QIMMessageManager sharedInstance] registerMsgVCClass:cellClass ForMessageType:messageType];
}

- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType {
    [[QIMMessageManager sharedInstance] registerMsgVCClassName:cellClassName ForMessageType:messageType];
}

- (Class)getRegisterMsgVCClassForMessageType:(QIMMessageType)messageType {
    return [[QIMMessageManager sharedInstance] getRegisterMsgVCClassForMessageType:messageType];
}

- (id)getRegisterMsgVCForMessageType:(QIMMessageType)messageType {
    return [[QIMMessageManager sharedInstance] getRegisterMsgVCForMessageType:messageType];
}

- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemId:(NSString *)itemId {
    [[QIMMessageManager sharedInstance] addMsgTextBarWithImage:imageName WithTitle:title ForItemId:itemId];
}

- (void)addMsgTextBarWithTrdInfo:(NSDictionary *)trdExtendInfo {
    [[QIMMessageManager sharedInstance]addMsgTextBarWithTrdInfo:trdExtendInfo];
}

- (NSArray *)getMsgTextBarButtonInfoList {
    return [[QIMMessageManager sharedInstance] getMsgTextBarButtonInfoList];
}

- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId {
    return [[QIMMessageManager sharedInstance] getExpandItemsForTrdextendId:trdextendId];
}

- (void)removeExpandItemsForType:(QIMTextBarExpandViewItemType)itemType {
    [[QIMMessageManager sharedInstance] removeExpandItemsForType:itemType];
}

- (NSDictionary *)getExpandItemsForType:(QIMTextBarExpandViewItemType)itemType {
    return [[QIMMessageManager sharedInstance] getExpandItemsForType:itemType];
}

- (BOOL)hasExpandItemForType:(QIMTextBarExpandViewItemType)itemType {
    return [[QIMMessageManager sharedInstance] hasExpandItemForType:itemType];
}

- (void)removeAllExpandItems {
    [[QIMMessageManager sharedInstance] removeAllExpandItems];
}

@end
