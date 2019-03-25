//
//  QIMMessageManager.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QIMMessageManager.h"
#import "QIMPrivateHeader.h"

static QIMMessageManager *__global_msg_manager = nil;

@implementation QIMMessageManager{
    NSMutableDictionary *_msgCellClassDic;
    NSMutableDictionary *_msgVCClassDic;
    NSMutableArray *_textBarButtonList;
    NSMutableDictionary *_showTextDic;
    NSMutableArray *_removeButtonList;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_msg_manager = [[QIMMessageManager alloc] init];
    });
    return __global_msg_manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _msgCellClassDic = [[NSMutableDictionary alloc] initWithCapacity:5];
        _msgVCClassDic = [[NSMutableDictionary alloc] init];
        _textBarButtonList = [[NSMutableArray alloc] init];
        _showTextDic = [[NSMutableDictionary alloc] init];
        _removeButtonList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)getSupportMsgTypeList{
    return _msgCellClassDic.allKeys;
}

- (void)setMsgShowText:(NSString *)showText ForMessageType:(QIMMessageType)messageType{
    [_showTextDic setQIMSafeObject:showText forKey:@(messageType)];
}

- (NSString *)getMsgShowTextForMessageType:(QIMMessageType)messageType{
    return [_showTextDic objectForKey:@(messageType)];
}

- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType{
    @try {
        NSString *baseCellClassStr = @"QIMMsgBaloonBaseCell";
        Class baseCellClass = NSClassFromString(baseCellClassStr);
        if ([cellClass isSubclassOfClass:[baseCellClass class]]) {
            [_msgCellClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType{
    @try {
        Class cellClass = NSClassFromString(cellClassName);
        NSString *baseCellClassStr = @"QIMMsgBaloonBaseCell";
        Class baseCellClass = NSClassFromString(baseCellClassStr);
        if ([cellClass isSubclassOfClass:[baseCellClass class]] && ![cellClassName isEqualToString:@"QIMDefalutMessageCell"]) {
            [_msgCellClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (Class)getRegisterMsgCellClassForMessageType:(QIMMessageType)messageType{
    return [_msgCellClassDic objectForKey:@(messageType)];
}

- (id )getRegisterMsgCellForMessageType:(QIMMessageType)messageType{
    Class someClass = [_msgCellClassDic objectForKey:@(messageType)];
    return [[someClass alloc] init];
}

- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType{

    @try {
        NSString *msgBaseVC = @"QIMMsgBaseVC";
        Class msgBaseVCClass = NSClassFromString(msgBaseVC);
        if ([cellClass isSubclassOfClass:[msgBaseVCClass class]]) {
            [_msgVCClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType{
    @try {
        Class cellClass = NSClassFromString(cellClassName);
        NSString *msgBaseVC = @"QIMMsgBaseVC";
        Class msgBaseVCClass = NSClassFromString(msgBaseVC);
        if ([cellClass isSubclassOfClass:[msgBaseVCClass class]]) {
            [_msgVCClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (Class)getRegisterMsgVCClassForMessageType:(QIMMessageType)messageType{
    return [_msgVCClassDic objectForKey:@(messageType)];
}

- (id)getRegisterMsgVCForMessageType:(QIMMessageType)messageType{
    Class someClass = [_msgVCClassDic objectForKey:@(messageType)];
    return [[someClass alloc] init];
}

- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemId:(NSString *)itemId{
    if (imageName.length > 0) {
        if (!_textBarButtonList) {
            _textBarButtonList = [NSMutableArray arrayWithCapacity:1];
        }
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
        [dic setObject:imageName?imageName:@"" forKey:@"ImageName"];
        [dic setObject:title?title:@"" forKey:@"title"];
        [dic setObject:itemId?itemId:@"" forKey:@"trdextendId"];
        [dic setObject:@(YES) forKey:@"local"];
        if (![_removeButtonList containsObject:itemId]) {
            [_textBarButtonList addObject:dic];
        }
    }
}

- (void)addMsgTextBarWithTrdInfo:(NSDictionary *)trdExtendInfo {
    NSString *trdEntendId = [trdExtendInfo objectForKey:@"trdextendId"];
    NSString *imageName = [trdExtendInfo objectForKey:@"icon"];
    if (imageName.length > 0) {
        if (!_textBarButtonList) {
            _textBarButtonList = [NSMutableArray arrayWithCapacity:1];
        }
        if (![_removeButtonList containsObject:trdEntendId]) {
            [_textBarButtonList addObject:trdExtendInfo];
        }
    }
}

- (NSArray *)getMsgTextBarButtonInfoList{
    return _textBarButtonList;
}

- (void)removeExpandItemsForType:(QIMTextBarExpandViewItemType)itemType
{
    [_textBarButtonList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj objectForKey:@"ItemType"] integerValue] == itemType) {
            *stop = YES;
            [_textBarButtonList removeObject:obj];
        }
    }];
}

- (void)removeAllExpandItems
{
    [_textBarButtonList removeAllObjects];
}

- (NSDictionary *)getExpandItemsForTrdextendId:(NSString *)trdextendId {
    for (NSDictionary * infoDic in _textBarButtonList) {
        NSString *tempTrdextendId = [infoDic objectForKey:@"trdextendId"];
        if ([tempTrdextendId isEqualToString:trdextendId]) {
            return infoDic;
        }
    }
    return nil;
}

- (NSDictionary *)getExpandItemsForType:(QIMTextBarExpandViewItemType)itemType
{
    for (NSDictionary * infoDic in _textBarButtonList) {
        if ([[infoDic objectForKey:@"ItemType"] integerValue] == itemType) {
            return infoDic;
        }
    }
        return nil;
}

- (BOOL)hasExpandItemForType:(QIMTextBarExpandViewItemType)itemType
{
    for (NSDictionary * infoDic in _textBarButtonList) {
        if ([[infoDic objectForKey:@"ItemType"] integerValue] == itemType) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)getHasRemoveExpandItems {
    return _removeButtonList;
}

- (void)removeExpandItemsForItemId:(NSString *)itemId {
    if (itemId.length > 0) {
        [_removeButtonList addObject:itemId];
    }
}

@end
