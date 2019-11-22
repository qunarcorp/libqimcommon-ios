//
//  STIMContactDatasourceManager.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/30.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "STIMContactDatasourceManager.h"
#import "STIMKitPublicHeader.h"
#import "STIMDatasourceItem.h"

@interface STIMContactDatasourceManager ()

@property (nonatomic, retain, readwrite) NSMutableArray * mergedRootBranch;

@end

static STIMContactDatasourceManager *_globalDataController = nil;

@implementation STIMContactDatasourceManager

@synthesize mergedRootBranch = _mergeRootBranch;

// 获取数据管理的控制器

+ (STIMContactDatasourceManager *)getInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalDataController = [[STIMContactDatasourceManager alloc] init];
    });
    return _globalDataController;
}

-(void)expandBranchAtIndex:(NSInteger)index {
    STIMDatasourceItem *childNode = [self.mergedRootBranch objectAtIndex:index];
    if (childNode.isParentNode) {
        [childNode setIsExpand:YES];
        [self insertChildren:_mergeRootBranch inArray:[childNode expand] atIndex:(index + 1) nLevel:(childNode.nLevel + 1)];
    }
}

-(void)collapseBranchAtIndex:(NSInteger)index {
    STIMDatasourceItem *childNode = [self.mergedRootBranch objectAtIndex:index];
    if (childNode.isParentNode) {
        [childNode setIsExpand:NO];
        [self removeChildren:childNode atIndex:(index+1) removeParentNode:NO];
    }
}

-(void)createUnMeregeDataSource {
    /*
    if (_unmergeBranchDict!=nil) {
        [_unmergeBranchDict removeAllObjects];
        _unmergeBranchDict = nil;
    }
    if (_unmergeBranchDict == nil) {
        _unmergeBranchDict  = [[NSMutableDictionary alloc] init];
    }
    if (_mergeRootBranch != nil) {
        [_mergeRootBranch removeAllObjects];
        _mergeRootBranch = nil;
    }
    
    if (_mergeRootBranch == nil) {
        _mergeRootBranch  = [[NSMutableArray alloc] init];
    }
    else {
        [_mergeRootBranch removeAllObjects];
    }
    
    if ([[[[STIMKit sharedInstance] getFriendListDict] allKeys] count] > 0) {
        [_unmergeBranchDict setDictionary:[[STIMKit sharedInstance] getFriendListDict]];
    }
    if (([[_unmergeBranchDict  allKeys] count] > 0) && ([_mergeRootBranch count] == 0)) {
        STIMDatasourceItem * parentNode  = [[STIMDatasourceItem alloc] init];
        if ([_unmergeBranchDict objectForKey:@"D"]) {
            NSString * groupName = [_unmergeBranchDict objectForKey:@"D"];
            [parentNode setNodeName:groupName];
            [parentNode  setIsParentNode:YES];
            [parentNode setIsExpand:NO];
        }
        if ([_unmergeBranchDict objectForKey:@"UL"]) {
            
            NSArray *userlistArray  = [_unmergeBranchDict  objectForKey:@"UL"];
            if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
                [[STIMKit sharedInstance] bulkInsertUserInfosNotSaveDescInfo:userlistArray];
            }
            for (NSDictionary *userDic in userlistArray) {
                
                NSString *userName = [userDic objectForKey:@"N"];
                if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
                    if ([userName isEqual:[NSNull null]] || userName.length <= 0) {
                        userName = [userDic objectForKey:@"W"];
                    }
                }
                NSString *jid = [NSString stringWithFormat:@"%@@%@",[userDic objectForKey:@"U"],[[STIMKit sharedInstance] getDomain]];
                STIMDatasourceItem * subItem  = [[STIMDatasourceItem alloc] init];
                [subItem setIsParentNode:NO];
                [subItem setJid:jid];
                [subItem setNodeName:userName];
                [parentNode addChildNodesItem:subItem];
                
            }
        }
        
        if ([_unmergeBranchDict   objectForKey:@"SD"]) {
            
            NSArray *userlistArray = [_unmergeBranchDict  objectForKey:@"SD"];
            for (NSDictionary *userDic in userlistArray) {
                [self recursiveLoadUnMergeData:userDic byNode:parentNode nLevel:1];
            }
        }
        [_mergeRootBranch addObject:parentNode];
        
    }
    //设置第一个节点默认展开
    if (_mergeRootBranch.count != 0) {
        [self expandBranchAtIndex:0];
    }
    */
}

-(NSArray *)QtalkDataSourceItem {
    return _mergeRootBranch;
}


-(void)recursiveLoadUnMergeData:(NSDictionary *)recursiveDict byNode:(STIMDatasourceItem *)parentNode nLevel:(NSInteger)nLevel {
    /*
    if (![recursiveDict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSArray  * userlistArray  = [recursiveDict   objectForKey:@"UL"];
    
    if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
        [[STIMKit sharedInstance] bulkInsertUserInfosNotSaveDescInfo:userlistArray];
    }
    
    NSString *groupName = [recursiveDict objectForKey:@"D"];
    
     STIMDatasourceItem * leafNode  = [[STIMDatasourceItem alloc] init];
    
    [leafNode setNLevel:nLevel];
    
    [leafNode setNodeName:groupName];
    
    [leafNode setIsParentNode:YES];
    
    [parentNode addChildNodesItem:leafNode];
    
    for (NSDictionary *userDic in userlistArray) {
        
        NSString *userName = [userDic objectForKey:@"N"];
        if ([STIMKit getSTIMProjectType] == STIMProjectTypeQChat) {
            if ([userName isEqual:[NSNull null]] || userName.length <= 0) {
                userName = [userDic objectForKey:@"W"];
            }
        }
        NSString *jid = [NSString stringWithFormat:@"%@@%@",[userDic objectForKey:@"U"],[[STIMKit sharedInstance] getDomain]];
        
        
        STIMDatasourceItem * subItem  = [[STIMDatasourceItem alloc] init];
        
        
        [subItem setIsParentNode:NO];
        
        [subItem setJid:jid];
        
        [subItem setNodeName:userName];
        
        [subItem setNLevel:(nLevel+1)];
        
        [leafNode addChildNodesItem:subItem];
                
    }
    
    NSDictionary *subSectorDict = [recursiveDict  objectForKey:@"SD"];
    for (NSDictionary *subRosterDict in subSectorDict) {
    
        [self recursiveLoadUnMergeData:subRosterDict byNode:leafNode nLevel:(nLevel+1)];
    }
     */
}

//recursively add children and all its expanded children to array at position index
- (int) insertChildren:(NSMutableArray *)children inArray:(NSMutableArray *)array atIndex:(NSUInteger)index nLevel:(NSInteger)nLevel {
    [children replaceObjectsInRange:NSMakeRange(index, 0) withObjectsFromArray:array];

    int res = 0;
    return res;
}

-(int) removeChildren:(STIMDatasourceItem *)parentNode  atIndex:(NSUInteger)index removeParentNode:(BOOL)removeParentNode{
    
    /*
    NSArray * childArray = parentNode.childNodesArray;
    for (STIMDatasourceItem *childItem in childArray) {
        if (childItem.isParentNode && childItem.isExpand) {
            [self removeChildren:childItem atIndex:index removeParentNode:YES];
        }
        else {
            [self.mergedRootBranch removeObjectAtIndex:index];
        }
    }
    
    if (removeParentNode) {
        [parentNode setIsExpand:NO];
        [self.mergedRootBranch removeObjectAtIndex:index];
    }
    */
    return 0;
}
@end
