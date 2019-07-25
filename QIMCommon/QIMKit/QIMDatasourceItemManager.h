//
//  QIMDatasourceItemManager.h
//  QIMCommon
//
//  Created by lilu on 2019/3/18.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMDatasourceItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMDatasourceItemManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray *)getQIMMergedRootBranch;
- (NSDictionary *)getChildItems;
- (NSDictionary *)getTotalItems;

- (QIMDatasourceItem *)getChildDataSourceItemWithId:(NSString *)itemId;

- (QIMDatasourceItem *)getTotalDataSourceItemWithId:(NSString *)itemId;

- (void)addChildDataSourceItem:(QIMDatasourceItem *)item WithId:(NSString *)itemId;

- (void)addTotalDataSourceItem:(QIMDatasourceItem *)item WithId:(NSString *)itemId;


-(void)expandBranchAtIndex:(NSInteger)index;

-(void)collapseBranchAtIndex:(NSInteger)index;

- (void)createDataSource;

@end

NS_ASSUME_NONNULL_END
