//
//  STIMContactDatasourceManager.h
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/30.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STIMContactDatasourceManager : NSObject {
    NSMutableArray * _mergeRootBranch;
    
    NSMutableDictionary * _unmergeBranchDict;
}

+(STIMContactDatasourceManager *)getInstance;

-(void)expandBranchAtIndex:(NSInteger)index;

-(void)collapseBranchAtIndex:(NSInteger)index;

-(void)createUnMeregeDataSource;

-(NSArray *)QtalkDataSourceItem;

@end
