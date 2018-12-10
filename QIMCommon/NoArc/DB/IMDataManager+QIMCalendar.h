//
//  IMDataManager+QIMCalendar.h
//  QIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "IMDataManager.h"

@interface IMDataManager (QIMCalendar)

- (NSArray *)qimDB_SelectTripByYearMonth:(NSString *)date;

- (void)qimDB_bulkInsertTrips:(NSArray *)trips;

- (NSArray *)qimDB_getLocalArea;

- (void)qimDB_bulkInsertArea:(NSArray *)areaList;

@end
