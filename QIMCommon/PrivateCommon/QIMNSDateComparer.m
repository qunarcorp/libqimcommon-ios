//
//  QIMNSDateComparer.m
//  unhandleException
//
//  Created by May on 13-7-9.
//  Copyright (c) 2013年 May. All rights reserved.
//

#import "QIMNSDateComparer.h"

//int diffday( const char *day1, const char *day2, const char *fmt )
//{
//    struct tm tm1, tm2;
//    long t;
//    
//    memset( &tm1, 0, sizeof(tm1) );
//    memset( &tm2, 0, sizeof(tm2) );
//    
//    if( !strptime( day1, fmt, &tm1 ) || !strptime( day2, fmt, &tm2 ) )
//    {
//        printf( "date format error!\n" );
//        return( -1 );
//    }
//    
//    t=(long)difftime( mktime(&tm1), mktime(&tm2) );
//    
//    return( abs( t/24/3600 ) );
//}

@implementation QIMNSDateRange

- (BOOL)isInRange:(long long)timeInterval {
    return (timeInterval > [self beginTime] && timeInterval < [self endTime]);
}

+ (QIMNSDateRange *) dateRangeByDay {
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                               fromDate:now];
    [comps setHour:0];
    NSDate *firstDay = [cal dateFromComponents:comps];
    NSDate *nextDay = [firstDay dateByAddingTimeInterval:86400];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[nextDay timeIntervalSince1970] * 1000];
    
    return theRange;
}

+ (QIMNSDateRange *)dateRangeByYesterDay{
    
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                               fromDate:now];
    [comps setHour:0];
    NSDate *nextDay = [cal dateFromComponents:comps];
    NSDate *firstDay = [nextDay dateByAddingTimeInterval:-86400];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[nextDay timeIntervalSince1970] * 1000];
    
    return theRange;
}

+ (QIMNSDateRange *)dateRangeByBeforeYesterDay{
    
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                               fromDate:now];
    [comps setHour:0];
    NSDate *nextDay = [cal dateFromComponents:comps];
    nextDay = [nextDay dateByAddingTimeInterval:-86400];
    NSDate *firstDay = [nextDay dateByAddingTimeInterval:-86400];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[nextDay timeIntervalSince1970] * 1000];
    
    return theRange;
}

+ (QIMNSDateRange *) dateRangeBySevenDays {
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                               fromDate:now];
    [comps setHour:0];
    NSDate *nextDay = [cal dateFromComponents:comps];
    NSDate *firstDay = [nextDay dateByAddingTimeInterval:-604800];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[nextDay timeIntervalSince1970] * 1000];
    
    return theRange;
}

+ (QIMNSDateRange *) dateRangeByWeek {
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday |NSCalendarUnitWeekdayOrdinal
                               fromDate:now];
    if (comps.weekday < 2)
    {
        comps.weekOfYear = comps.weekOfYear - 1;
    }
    comps.weekday = 2;
    NSDate *firstDay = [cal dateFromComponents:comps];
    
    NSTimeInterval timeInterval = 604800;
    
    NSDate *secondDay =[firstDay dateByAddingTimeInterval:timeInterval];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[secondDay timeIntervalSince1970] * 1000];
    return theRange;
}

+ (QIMNSDateRange *) dateRangeByLastWeek {
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit| NSMonthCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit
                               fromDate:now];
    if (comps.weekday < 2)
    {
        comps.week = comps.week - 1;
    }
    comps.weekday = 2;
    NSDate *secondDay = [cal dateFromComponents:comps];
    
    NSTimeInterval timeInterval = 604800;
    
    NSDate *firstDay =[secondDay dateByAddingTimeInterval:timeInterval - 0];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[secondDay timeIntervalSince1970] * 1000];
    return theRange;
}

+ (QIMNSDateRange *) dateRangeByMonth {
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                               fromDate:now];
    comps.day = 1;
    NSDate *firstDay = [cal dateFromComponents:comps];
    
    if ([comps month] >= 12) {
        [comps setYear:[comps year] + 1];
        [comps setMonth:1];
    } else {
        [comps setMonth:[comps month] + 1];
    }
    NSDate *nextDay = [cal dateFromComponents:comps];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[nextDay timeIntervalSince1970] * 1000];
    
    return theRange;
}

+ (QIMNSDateRange *) dateRangeByLastMonth {
    QIMNSDateRange *theRange = [[QIMNSDateRange alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal
                               components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                               fromDate:now];
    comps.day = 1;
    NSDate *nextDay = [cal dateFromComponents:comps];
    
    if ([comps month] <= 1) {
        [comps setYear:[comps year] - 1];
        [comps setMonth:12];
    } else {
        [comps setMonth:[comps month] - 1];
    }
    NSDate *firstDay = [cal dateFromComponents:comps];
    
    [theRange setBeginTime:[firstDay timeIntervalSince1970] * 1000];
    [theRange setEndTime:[nextDay timeIntervalSince1970] * 1000];
    return theRange;
}

@end


static QIMNSDateComparer *global_date_comparer = nil;

@implementation QIMNSDateComparer{
    NSDateFormatter *_dateFormatter;
    NSDateFormatter *_dateTimeFormatter;
    NSDateFormatter *_timeFormatter;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self checkTimeIntervalNow];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
         [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        _dateTimeFormatter = [[NSDateFormatter alloc] init];
        [_dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"HH:mm"];
        
    }
    return self;
}

+ (QIMNSDateComparer *) instance {
    @synchronized(self) {
        if (global_date_comparer == nil)
            global_date_comparer = [[QIMNSDateComparer alloc] init];
    }
    return global_date_comparer;
}

- (void) checkTimeIntervalNow {
    
    _currentTime = [_dayRange endTime] / 1000;
    
    _dayRange = [QIMNSDateRange dateRangeByDay];
    
    _yesterDayRange = [QIMNSDateRange dateRangeByYesterDay];
    
    _beforeYesterDayRange = [QIMNSDateRange dateRangeByBeforeYesterDay];
    
    _monthRange = [QIMNSDateRange dateRangeByMonth];
    
    _weekRange = [QIMNSDateRange dateRangeByWeek];
    
    _7DaysRange = [QIMNSDateRange dateRangeBySevenDays];
    
    _lastWeekRange = [QIMNSDateRange dateRangeByLastWeek];
    
    _lastMonthRange = [QIMNSDateRange dateRangeByLastMonth];
    
}

- (NSUInteger) daysBetweenNowFromTimeInterval:(long long) timeInteval {
    
    NSUInteger days = 0;
    
    @autoreleasepool {
        NSDate* toDate   = [NSDate date];
        NSDate*  startDate  = [NSDate dateWithTimeIntervalSince1970:timeInteval / 1000];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal
                                   components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                                   fromDate:toDate];
        [comps setHour:0];
        NSDate *secondDay = [cal dateFromComponents:comps];
        comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                       fromDate:startDate];
        [comps setHour:0];
        NSDate *firstDay = [cal dateFromComponents:comps];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
        NSDateComponents *cps = [cal components:unitFlags fromDate:firstDay  toDate:secondDay options:0];
        
        days = [cps day];
    }
    return days;
    
    
//    long long currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
//    NSUInteger days = (currentTime - timeInteval) / 24/ 3600 / 1000;
//    return days;
}

- (NSUInteger) daysBetweenTimeInterval:(long long)firstTimeInteval
                        toTimeInterval:(long long) secondTimeInterval {
    NSUInteger days = 0;
    
    @autoreleasepool {
        NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:firstTimeInteval / 1000];
        NSDate* toDate = [NSDate dateWithTimeIntervalSince1970:secondTimeInterval / 1000];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comps = [cal
                                   components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                                   fromDate:toDate];
        [comps setHour:0];
        NSDate *secondDay = [cal dateFromComponents:comps];
        comps = [cal components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit
                       fromDate:startDate];
        [comps setHour:0];
        NSDate *firstDay = [cal dateFromComponents:comps];
        NSUInteger unitFlags = NSDayCalendarUnit;
        NSDateComponents *cps = [cal components:unitFlags fromDate:firstDay  toDate:secondDay options:0];
        
        days = abs((int)[cps day]);
    }
    return days;
}

- (NSString *)getTimeStrByDate:(NSDate *)date{
    return [_timeFormatter stringFromDate:date];
}

- (NSString *)getDateTimeStrByDate:(NSDate *)date{
    return [_dateTimeFormatter stringFromDate:date];
}

- (NSString *)getDateStrByDate:(NSDate *)date{
    return [_dateFormatter stringFromDate:date];
}

- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    BOOL result = NO;
    @autoreleasepool {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
        NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
        NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
        result = ([comp1 day]   == [comp2 day] &&
        [comp1 month] == [comp2 month] &&
        [comp1 year]  == [comp2 year]);
    }
    return result;
}

- (NSDateType) dateTypeWithTimeInterval:(long long) timeInterval {
    if ([[NSDate date] timeIntervalSince1970] > _currentTime)
        [self checkTimeIntervalNow];
    
    if (_dayRange && [_dayRange isInRange:timeInterval])
        return NSDateTypeCurrentDay;
    if (_yesterDayRange && [_yesterDayRange isInRange:timeInterval]) {
        return NSDateTypeYesterDay;
    }
    if (_beforeYesterDayRange && [_beforeYesterDayRange isInRange:timeInterval]) {
        return NSDateTypeBeforeYesterDay;
    }
    if (_7DaysRange && [_7DaysRange isInRange:timeInterval])
        return NSDateTypeCurrent7Days;
    if (_lastWeekRange && [_lastWeekRange isInRange:timeInterval])
        return NSDateTypeCurrentLastWeek;
    if (_monthRange && [_monthRange isInRange:timeInterval])
        return NSDateTypeCurrentMonth;
    if (_lastMonthRange && [_lastMonthRange isInRange:timeInterval])
        return NSDateTypeCurrentLastMonth;
//    if (_weekRange && [_weekRange isInRange:timeInterval])
//        return NSDateTypeCurrentWeek;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:[NSDate date]];
    if ([comp1 year] == [comp2 year]) {
        return NSDateTypeCurrentYear;
    }
    
    return NSDateTypeTooLong;
}

@end
