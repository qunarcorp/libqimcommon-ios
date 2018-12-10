//
//  QIMNSDateComparer.h
//  unhandleException
//
//  Created by May on 13-7-9.
//  Copyright (c) 2013年 May. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMNSDateRange : NSObject {
}

+ (QIMNSDateRange *) dateRangeByDay;
+ (QIMNSDateRange *) dateRangeByYesterDay;
+ (QIMNSDateRange *) dateRangeByBeforeYesterDay;
+ (QIMNSDateRange *) dateRangeBySevenDays;
+ (QIMNSDateRange *) dateRangeByWeek;
+ (QIMNSDateRange *) dateRangeByLastWeek;
+ (QIMNSDateRange *) dateRangeByMonth;
+ (QIMNSDateRange *) dateRangeByLastMonth;

- (BOOL) isInRange:(long long) timeInterval;

@property (nonatomic, assign) long long beginTime;
@property (nonatomic, assign) long long endTime;

@end

typedef enum {
    NSDateTypeCurrentDay = 1,
    NSDateTypeYesterDay,
    NSDateTypeBeforeYesterDay,
    NSDateTypeCurrentWeek,
    NSDateTypeCurrentMonth,
    NSDateTypeCurrent7Days,
    NSDateTypeCurrentLastWeek,
    NSDateTypeCurrentLastMonth,
    NSDateTypeCurrentYear,
    NSDateTypeTooLong,
} NSDateType;

@interface QIMNSDateComparer : NSObject {
    NSTimeInterval _currentTime;
    QIMNSDateRange *_dayRange;
    QIMNSDateRange *_yesterDayRange;
    QIMNSDateRange *_beforeYesterDayRange;
    QIMNSDateRange *_7DaysRange;
    QIMNSDateRange *_weekRange;
    QIMNSDateRange *_lastWeekRange;
    QIMNSDateRange *_monthRange;
    QIMNSDateRange *_lastMonthRange;
}

+ (QIMNSDateComparer *) instance;

- (NSString *)getTimeStrByDate:(NSDate *)date;
- (NSString *)getDateTimeStrByDate:(NSDate *)date;
- (NSString *)getDateStrByDate:(NSDate *)date;

- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

- (NSDateType) dateTypeWithTimeInterval:(long long) timeInterval;
- (NSUInteger) daysBetweenNowFromTimeInterval:(long long) timeInteval;

- (NSUInteger) daysBetweenTimeInterval:(long long)firstTimeInteval
                        toTimeInterval:(long long) secondTimeInterval;


@end
