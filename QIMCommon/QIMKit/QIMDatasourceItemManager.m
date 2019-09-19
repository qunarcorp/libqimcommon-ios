//
//  QIMDatasourceItemManager.m
//  QIMCommon
//
//  Created by lilu on 2019/3/18.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMDatasourceItemManager.h"
#import "QIMKitPublicHeader.h"

@interface QIMDatasourceItemManager ()

@property (nonatomic, strong) NSMutableDictionary *childItems;
@property (nonatomic, strong) NSMutableDictionary *totalItems;
@property (nonatomic, strong) NSMutableArray *mergedRootBranch;

@end

@implementation QIMDatasourceItemManager

static QIMDatasourceItemManager *_manager = nil;
static dispatch_once_t _onceQIMDatasourceItemManager;
+ (instancetype)sharedInstance {
    dispatch_once(&_onceQIMDatasourceItemManager, ^{
        _manager = [[QIMDatasourceItemManager alloc] init];
        [_manager listenLogoutNotify];
    });
    return _manager;
}

//监听退出登录通知
- (void)listenLogoutNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutNotify:) name:kNotificationLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDatasourceItemManager) name:@"kNotifyNotificationReloadOrganizationalStructure" object:nil];
}

- (void)logoutNotify:(NSNotification *)notify {
    //收到退出登录通知
    _manager = nil;
    _onceQIMDatasourceItemManager = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)clearDatasourceItemManager {
    _childItems = nil;
    _onceQIMDatasourceItemManager = nil;
    _mergedRootBranch = nil;
}

- (NSMutableDictionary *)childItems {
    if (!_childItems) {
        _childItems = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _childItems;
}

- (NSMutableDictionary *)totalItems {
    if (!_totalItems) {
        _totalItems = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _totalItems;
}

- (NSMutableArray *)mergedRootBranch {
    if (!_mergedRootBranch) {
        _mergedRootBranch = [[NSMutableArray alloc] initWithCapacity:3];
        [_mergedRootBranch addObject:@"staff"];
    }
    return _mergedRootBranch;
}

- (NSArray *)getQIMMergedRootBranch {
    return self.mergedRootBranch;
}

- (NSDictionary *)getChildItems {
    return self.childItems;
}

- (NSDictionary *)getTotalItems {
    return self.totalItems;
}

- (QIMDatasourceItem *)getChildDataSourceItemWithId:(NSString *)itemId {
    if (itemId.length > 0 && self.childItems) {
        QIMDatasourceItem *item = [self.childItems objectForKey:itemId];
        return item;
    }
    return nil;
}

- (QIMDatasourceItem *)getTotalDataSourceItemWithId:(NSString *)itemId {
    if (itemId.length > 0 && self.totalItems) {
        QIMDatasourceItem *item = [self.totalItems objectForKey:itemId];
        return item;
    }
    return nil;
}

- (void)addChildDataSourceItem:(QIMDatasourceItem *)item WithId:(NSString *)itemId {
    [self.childItems setObject:item forKey:itemId];
}

- (void)addTotalDataSourceItem:(QIMDatasourceItem *)item WithId:(NSString *)itemId {
    [self.totalItems setObject:item forKey:itemId];
}

-(void)expandBranchAtIndex:(NSInteger)index {
    NSString *depPath = [self.mergedRootBranch objectAtIndex:index];
    QIMDatasourceItem *parentNode = [[QIMDatasourceItemManager sharedInstance] getTotalDataSourceItemWithId:depPath];
    if (!parentNode) {
        parentNode = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:depPath];
    }
    if (parentNode.childNodesDict.count > 0) {
        [parentNode setIsExpand:YES];
        NSArray * array = [[parentNode childNodesDict]keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            QIMDatasourceItem * item1 = obj1;
            QIMDatasourceItem * item2 = obj2;
            if (item1.index < item2.index) {
                return NSOrderedAscending;
            }
            else{
                return NSOrderedDescending;
            }
        }];

            [self insertChildren:self.mergedRootBranch inArray:array atIndex:(index + 1) nLevel:(parentNode.nLevel + 1)];
//        [self insertChildren:self.mergedRootBranch inArray:[[parentNode childNodesDict] allKeys] atIndex:(index + 1) nLevel:(parentNode.nLevel + 1)];
    }
}

-(void)collapseBranchAtIndex:(NSInteger)index {
    NSString *depPath = [self.mergedRootBranch objectAtIndex:index];
    QIMDatasourceItem *parentNode = [[QIMDatasourceItemManager sharedInstance] getTotalDataSourceItemWithId:depPath];
    if (!parentNode) {
        parentNode = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:depPath];
    }
    if (parentNode.childNodesDict.count > 0) {
        [parentNode setIsExpand:NO];
        [self removeChildren:parentNode removeParentNode:NO];
    }
}

//recursively add children and all its expanded children to array at position index
- (void)insertChildren:(NSMutableArray *)children inArray:(NSMutableArray *)array atIndex:(NSUInteger)index nLevel:(NSInteger)nLevel {
    [children replaceObjectsInRange:NSMakeRange(index, 0) withObjectsFromArray:array];
}

-(void)removeChildren:(QIMDatasourceItem *)parentNode removeParentNode:(BOOL)removeParentNode{
    
    NSArray * childArray = parentNode.childNodesDict;
    for (NSString *childItemKey in childArray) {
        QIMDatasourceItem *childItem = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:childItemKey];
        if (childItem.isParentNode && childItem.isExpand) {
            [self removeChildren:childItem removeParentNode:YES];
        } else {
            [self.mergedRootBranch removeObject:childItem.nodeName];
        }
    }
    
    if (removeParentNode) {
        [parentNode setIsExpand:NO];
        [self.mergedRootBranch removeObject:parentNode.nodeName];
    }
}

- (void)createDataSource {
    NSArray *userlistArray = [[QIMKit sharedInstance] getOrganUserList];
    if (userlistArray.count <= 0 || ![userlistArray isKindOfClass:[NSArray class]]) {
        return;
    }
    NSMutableArray *organList = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *firstOrgan = [NSMutableArray arrayWithCapacity:3];
//    for (NSDictionary *userInfo in userlistArray) {
    for (NSInteger i = 0; i<userlistArray.count; i++) {
        NSDictionary * userInfo = [userlistArray objectAtIndex:i];
        NSString *userId = [userInfo objectForKey:@"UserId"];
        NSString *xmppId = [userInfo objectForKey:@"XmppId"];
        NSString *userName = [userInfo objectForKey:@"Name"];
        NSString *department = [userInfo objectForKey:@"DescInfo"];
        BOOL visibleFlag = [[userInfo objectForKey:@"visibleFlag"] boolValue];
        if (visibleFlag == NO) {
            //不展示
            continue;
        }
        if (department.length <= 0) {
            continue;
        }
        NSString *userDP = [department substringFromIndex:1];
        NSArray *organTemp = [userDP componentsSeparatedByString:@"/"];
        if (!organTemp || organTemp.count <= 0) {
            NSLog(@"%@员工的部门不合法", xmppId);
            continue;
        }
        NSString *escapeWhiteSpaceUserId = [userId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!userId || escapeWhiteSpaceUserId.length <= 0) {
            NSLog(@"%@员工的UserId不合法", userId);
            continue;
        }
        NSString *userDep = [NSString stringWithFormat:@"staff/%@/%@", userDP, xmppId];
        if (userDP.length == 0 || userDP== nil) {
            userDep = [NSString stringWithFormat:@"staff/%@",xmppId];
        }
        QIMDatasourceItem *userItem = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:nil];
        if (!userItem) {
            userItem = [[QIMDatasourceItem alloc] init];
            userItem.nodeName = userDep;
            userItem.jid = xmppId;
            userItem.index = i + 1;
        }

        [[QIMDatasourceItemManager sharedInstance] addChildDataSourceItem:userItem WithId:userDep];
        for (NSInteger i = organTemp.count - 1; i >= 0; i--) {
            NSString *dep = @"staff";
            for (NSInteger j = 0; j <= i; j++) {
                NSString * tmpStr = organTemp.lastObject;
                if (organTemp.count == 1 && (tmpStr == nil|| tmpStr.length == 0)) {

                }
                else{
                    dep = [dep stringByAppendingFormat:@"/%@", [organTemp objectAtIndex:j]];
                }
            }

            QIMDatasourceItem *childItem = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:dep];
            if (!childItem) {
                childItem = [[QIMDatasourceItem alloc] init];
                childItem.nodeName = dep;
                childItem.index = 100000*(i+1);
            }
            if (i == organTemp.count - 1) {
                if (![@"staff" isEqualToString:dep]) {
                    childItem.isParentNode = YES;
                    [childItem addChildNodesItem:userItem withChildDP:userDep];
                    [[QIMDatasourceItemManager sharedInstance] addChildDataSourceItem:childItem WithId:dep];
                }
                else{
                    [childItem addChildNodesItem:userItem withChildDP:userDep];
                }
            }
            NSString *parentDep = @"staff";
            for (NSInteger j = 0; j < i; j++) {
                parentDep = [parentDep stringByAppendingFormat:@"/%@", [organTemp objectAtIndex:j]];
            }
            QIMDatasourceItem *parentItem = [[QIMDatasourceItemManager sharedInstance] getChildDataSourceItemWithId:parentDep];
            if (!parentItem) {
                parentItem = [[QIMDatasourceItem alloc] init];
                parentItem.nodeName = parentDep;
                parentItem.index = 1000000000*(i+1);
            }
            parentItem.isParentNode = YES;
            if ([parentDep isEqualToString:dep]) {

            }
            else{
                [parentItem addChildNodesItem:childItem withChildDP:dep];
            }
            [[QIMDatasourceItemManager sharedInstance] addChildDataSourceItem:parentItem WithId:parentDep];
            if (i == 0) {
                [[QIMDatasourceItemManager sharedInstance] addTotalDataSourceItem:parentItem WithId:parentDep];
            }
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
