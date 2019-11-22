//
//  STIMMessageManager.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import <Foundation/Foundation.h>
#import "STIMCommonEnum.h"

@interface STIMMessageManager : NSObject

+ (instancetype)sharedInstance;

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

- (void)removeExpandItemsForType:(STIMTextBarExpandViewItemType)itemType;
- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId;
- (NSDictionary *)getExpandItemsForType:(STIMTextBarExpandViewItemType)itemType;

- (BOOL)hasExpandItemForType:(STIMTextBarExpandViewItemType)itemType;
- (void)removeAllExpandItems;

@end
