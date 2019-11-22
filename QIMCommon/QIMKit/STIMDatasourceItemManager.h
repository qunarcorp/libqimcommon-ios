//
//  STIMDatasourceItemManager.h
//  STIMCommon
//
//  Created by lilu on 2019/3/18.
//  Copyright © 2019 STIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIMDatasourceItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMDatasourceItemManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)getSTIMMergedRootBranch;
- (NSDictionary *)getChildItems;
- (NSDictionary *)getTotalItems;

- (STIMDatasourceItem *)getChildDataSourceItemWithId:(NSString *)itemId;

- (STIMDatasourceItem *)getTotalDataSourceItemWithId:(NSString *)itemId;

- (void)addChildDataSourceItem:(STIMDatasourceItem *)item WithId:(NSString *)itemId;

- (void)addTotalDataSourceItem:(STIMDatasourceItem *)item WithId:(NSString *)itemId;


-(void)expandBranchAtIndex:(NSInteger)index;

-(void)collapseBranchAtIndex:(NSInteger)index;

- (void)createDataSource;

@end

NS_ASSUME_NONNULL_END
