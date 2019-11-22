//
//  STIMKit+STIMMessageManager.m
//  STIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMMessageManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMMessageManager)

- (NSArray *)getSupportMsgTypeList {
    return [[STIMMessageManager sharedInstance] getSupportMsgTypeList];
}

// 会话Cell上显示的文字
- (void)setMsgShowText:(NSString *)showText ForMessageType:(STIMMessageType)messageType {
    [[STIMMessageManager sharedInstance] setMsgShowText:showText ForMessageType:messageType];
}

- (NSString *)getMsgShowTextForMessageType:(STIMMessageType)messageType {
    return [[STIMMessageManager sharedInstance] getMsgShowTextForMessageType:messageType];
}

// 消息气泡
- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(STIMMessageType)messageType {
    [[STIMMessageManager sharedInstance] registerMsgCellClass:cellClass ForMessageType:messageType];
}

- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(STIMMessageType)messageType {
    [[STIMMessageManager sharedInstance] registerMsgCellClassName:cellClassName ForMessageType:messageType];
}

- (Class)getRegisterMsgCellClassForMessageType:(STIMMessageType)messageType {
    return [[STIMMessageManager sharedInstance] getRegisterMsgCellClassForMessageType:messageType];
}

- (id)getRegisterMsgCellForMessageType:(STIMMessageType)messageType {
    return [[STIMMessageManager sharedInstance] getRegisterMsgCellForMessageType:messageType];
}

// 消息定制窗口
- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(STIMMessageType)messageType {
    [[STIMMessageManager sharedInstance] registerMsgVCClass:cellClass ForMessageType:messageType];
}

- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(STIMMessageType)messageType {
    [[STIMMessageManager sharedInstance] registerMsgVCClassName:cellClassName ForMessageType:messageType];
}

- (Class)getRegisterMsgVCClassForMessageType:(STIMMessageType)messageType {
    return [[STIMMessageManager sharedInstance] getRegisterMsgVCClassForMessageType:messageType];
}

- (id)getRegisterMsgVCForMessageType:(STIMMessageType)messageType {
    return [[STIMMessageManager sharedInstance] getRegisterMsgVCForMessageType:messageType];
}

- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemId:(NSString *)itemId {
    [[STIMMessageManager sharedInstance] addMsgTextBarWithImage:imageName WithTitle:title ForItemId:itemId];
}

- (void)addMsgTextBarWithTrdInfo:(NSDictionary *)trdExtendInfo {
    [[STIMMessageManager sharedInstance]addMsgTextBarWithTrdInfo:trdExtendInfo];
}

- (NSArray *)getMsgTextBarButtonInfoList {
    return [[STIMMessageManager sharedInstance] getMsgTextBarButtonInfoList];
}

- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId {
    return [[STIMMessageManager sharedInstance] getExpandItemsForTrdextendId:trdextendId];
}

- (void)removeExpandItemsForType:(STIMTextBarExpandViewItemType)itemType {
    [[STIMMessageManager sharedInstance] removeExpandItemsForType:itemType];
}

- (NSDictionary *)getExpandItemsForType:(STIMTextBarExpandViewItemType)itemType {
    return [[STIMMessageManager sharedInstance] getExpandItemsForType:itemType];
}

- (BOOL)hasExpandItemForType:(STIMTextBarExpandViewItemType)itemType {
    return [[STIMMessageManager sharedInstance] hasExpandItemForType:itemType];
}

- (void)removeAllExpandItems {
    [[STIMMessageManager sharedInstance] removeAllExpandItems];
}

@end
