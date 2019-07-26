//
//  QIMMessageManager.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"

@interface QIMMessageManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)getSupportMsgTypeList;

// 会话Cell上显示的文字
- (void)setMsgShowText:(NSString *)showText ForMessageType:(QIMMessageType)messageType;
- (NSString *)getMsgShowTextForMessageType:(QIMMessageType)messageType;

// 消息气泡
- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType;
- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType;
- (Class)getRegisterMsgCellClassForMessageType:(QIMMessageType)messageType;
- (id)getRegisterMsgCellForMessageType:(QIMMessageType)messageType;

// 消息定制窗口
- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType;
- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType;
- (Class)getRegisterMsgVCClassForMessageType:(QIMMessageType)messageType;
- (id)getRegisterMsgVCForMessageType:(QIMMessageType)messageType;
- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemId:(NSString *)itemId;

- (void)addMsgTextBarWithTrdInfo:(NSDictionary *)trdExtendInfo;

- (NSArray *)getMsgTextBarButtonInfoList;

- (void)removeExpandItemsForType:(QIMTextBarExpandViewItemType)itemType;
- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId;
- (NSDictionary *)getExpandItemsForType:(QIMTextBarExpandViewItemType)itemType;

- (BOOL)hasExpandItemForType:(QIMTextBarExpandViewItemType)itemType;
- (void)removeAllExpandItems;

@end
