//
//  STIMKit+STIMMessageManager.h
//  STIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMMessageManager)

- (NSArray *)getSupportMsgTypeList;

// 会话Cell上显示的文字
- (void)setMsgShowText:(NSString *)showText ForMessageType:(STIMMessageType)messageType;
- (NSString *)getMsgShowTextForMessageType:(STIMMessageType)messageType;

// 消息气泡
- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(STIMMessageType)messageType;
- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(STIMMessageType)messageType;
- (Class)getRegisterMsgCellClassForMessageType:(STIMMessageType)messageType;
- (id)getRegisterMsgCellForMessageType:(STIMMessageType)messageType;

// 消息定制窗口
- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(STIMMessageType)messageType;
- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(STIMMessageType)messageType;
- (Class)getRegisterMsgVCClassForMessageType:(STIMMessageType)messageType;
- (id)getRegisterMsgVCForMessageType:(STIMMessageType)messageType;
- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemId:(NSString *)itemId;

- (void)addMsgTextBarWithTrdInfo:(NSDictionary *)trdExtendInfo;
- (NSArray *)getMsgTextBarButtonInfoList;

- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId;

- (void)removeExpandItemsForType:(STIMTextBarExpandViewItemType)itemType;
- (NSDictionary *)getExpandItemsForType:(STIMTextBarExpandViewItemType)itemType;

- (BOOL)hasExpandItemForType:(STIMTextBarExpandViewItemType)itemType;
- (void)removeAllExpandItems;


@end
