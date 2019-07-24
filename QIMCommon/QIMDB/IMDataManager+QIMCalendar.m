//
//  IMDataManager+QIMCalendar.m
//  QIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "IMDataManager+QIMCalendar.h"
#import "QIMDataBase.h"
#import "QIMPublicRedefineHeader.h"

@implementation IMDataManager (QIMCalendar)

- (NSArray *)qimDB_SelectTripByYearMonth:(NSString *)date {
    __block NSMutableArray *areaList = [[NSMutableArray alloc] init];
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select * from IM_TRIP_INFO where (tripDate Between '%@' and '%@') and canceled = '%@';", [date stringByAppendingString:@"-01"], [date stringByAppendingString:@"-31"], @"0"];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (areaList == nil) {
                areaList = [[NSMutableArray alloc] init];
            }
            NSString *tripId = [reader objectForColumnIndex:0];
            NSString *tripName = [reader objectForColumnIndex:1];
            NSString *tripDate = [reader objectForColumnIndex:2];
            
            NSString *tripType = [reader objectForColumnIndex:3];
            NSString *tripIntr = [reader objectForColumnIndex:4];
            NSString *tripInviter = [reader objectForColumnIndex:5];
            
            NSString *beginTime = [reader objectForColumnIndex:6];
            NSString *endTime = [reader objectForColumnIndex:7];
            NSString *scheduleTime = [reader objectForColumnIndex:8];
            
            NSString *appointment = [reader objectForColumnIndex:9];
            NSString *tripLocale = [reader objectForColumnIndex:10];
            NSString *tripLocaleNumber = [reader objectForColumnIndex:11];
            
            NSString *tripRoom = [reader objectForColumnIndex:12];
            
            if (!appointment.length) {
                appointment = [NSString stringWithFormat:@"%@-%@", tripLocale, tripRoom];
            }
            
            NSString *tripRoomNumber = [reader objectForColumnIndex:13];
            NSString *memberListJSON = [reader objectForColumnIndex:14];
            
            NSString *tripRemark = [reader objectForColumnIndex:15];
            NSString *canceled = [reader objectForColumnIndex:16];
            
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setQIMSafeObject:tripId forKey:@"tripId"];
            [param setQIMSafeObject:tripName forKey:@"tripName"];
            [param setQIMSafeObject:tripDate forKey:@"tripDate"];
            [param setQIMSafeObject:tripType forKey:@"tripType"];
            [param setQIMSafeObject:tripIntr forKey:@"tripIntr"];
            [param setQIMSafeObject:tripInviter forKey:@"tripInviter"];
            [param setQIMSafeObject:beginTime forKey:@"beginTime"];
            [param setQIMSafeObject:endTime forKey:@"endTime"];
            [param setQIMSafeObject:scheduleTime forKey:@"scheduleTime"];
            [param setQIMSafeObject:appointment forKey:@"appointment"];
            [param setQIMSafeObject:tripLocale forKey:@"tripLocale"];
            [param setQIMSafeObject:tripLocaleNumber forKey:@"tripLocaleNumber"];
            
            [param setQIMSafeObject:tripRoom forKey:@"tripRoom"];
            [param setQIMSafeObject:tripRoomNumber forKey:@"tripRoomNumber"];
            [param setQIMSafeObject:memberListJSON forKey:@"memberList"];
            [param setQIMSafeObject:tripRemark forKey:@"tripRemark"];
            [param setQIMSafeObject:canceled forKey:@"canceled"];

            [areaList addObject:param];
        }
    }];
    QIMVerboseLog(@"");
    return areaList;
}

- (void)qimDB_bulkInsertTrips:(NSArray *)trips {
    if (trips.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO IM_TRIP_INFO (tripId, tripName, tripDate, tripType, tripIntr, tripInviter, beginTime, endTime, scheduleTime, appointment, tripLocale, tripLocaleNumber, tripRoom, tripRoomNumber, memberList, tripRemark, canceled) VALUES (:tripId, :tripName, :tripDate, :tripType, :tripIntr, :tripInviter, :beginTime, :endTime, :scheduleTime, :appointment, :tripLocale, :tripLocaleNumber, :tripRoom, :tripRoomNumber, :memberList, :tripRemark, :canceled);"];
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *tripItem in trips) {
            NSString *tripId = [tripItem objectForKey:@"tripId"];
            NSString *tripName = [tripItem objectForKey:@"tripName"];
            NSString *tripDate = [tripItem objectForKey:@"tripDate"];
            
            NSString *tripType = [tripItem objectForKey:@"tripType"];
            NSString *tripIntr = [tripItem objectForKey:@"tripIntr"];
            NSString *tripInviter = [tripItem objectForKey:@"tripInviter"];
            
            NSString *beginTime = [tripItem objectForKey:@"beginTime"];
            NSString *endTime = [tripItem objectForKey:@"endTime"];
            NSString *scheduleTime = [tripItem objectForKey:@"scheduleTime"];
            
            NSString *tripLocale = [tripItem objectForKey:@"tripLocale"];
            NSString *tripLocaleNumber = [tripItem objectForKey:@"tripLocaleNumber"];
            
            NSString *tripRoom = [tripItem objectForKey:@"tripRoom"];
            NSString *tripRoomNumber = [tripItem objectForKey:@"tripRoomNumber"];
            NSString *appointment = [tripItem objectForKey:@"appointment"];
            
            //这里特别注意下，会议室预定没有appointment，需要客户端拼
            if (!appointment.length) {
                appointment = [NSString stringWithFormat:@"%@-%@", tripLocale, tripRoom];
            }
            
            NSArray *memberList = [tripItem objectForKey:@"memberList"];
            NSData *data = [NSJSONSerialization dataWithJSONObject:memberList options:NSJSONWritingPrettyPrinted error:nil];
            NSString *memberListJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSString *tripRemark = [tripItem objectForKey:@"tripRemark"];
            NSString *canceled = [tripItem objectForKey:@"canceled"];
            
            NSMutableArray *param = [NSMutableArray array];
            
            [param addObject:tripId?tripId:@":NULL"];
            [param addObject:tripName?tripName:@":NULL"];
            [param addObject:tripDate?tripDate:@":NULL"];
            
            [param addObject:tripType?tripType:@":NULL"];
            [param addObject:tripIntr?tripIntr:@":NULL"];
            [param addObject:tripInviter?tripInviter:@":NULL"];
            
            [param addObject:beginTime?beginTime:@":NULL"];
            [param addObject:endTime?endTime:@":NULL"];
            [param addObject:scheduleTime?scheduleTime:@":NULL"];
            
            [param addObject:appointment?appointment:@":NULL"];
            [param addObject:tripLocale?tripLocale:@":NULL"];
            [param addObject:tripLocaleNumber?tripLocaleNumber:@":NULL"];
            
            [param addObject:tripRoom?tripRoom:@":NULL"];
            [param addObject:tripRoomNumber?tripRoomNumber:@":NULL"];
            [param addObject:memberListJSON?memberListJSON:@":NULL"];
            
            [param addObject:tripRemark?tripRemark:@":NULL"];
            [param addObject:canceled?canceled:@":NULL"];
            [paramList addObject:param];
        }
        BOOL result = [database executeBulkInsert:sql withParameters:paramList];
        QIMVerboseLog(@"result = :%d", result);
    }];
    QIMVerboseLog(@"");
}

- (NSArray *)qimDB_getLocalArea {
    __block NSMutableArray *areaList = [[NSMutableArray alloc] init];
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select *from IM_TRIP_AREA where Enable = 1";
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (areaList == nil) {
                areaList = [[NSMutableArray alloc] init];
            }
            NSString *areaId = [reader objectForColumnIndex:0];
            NSString *enable = [reader objectForColumnIndex:1];
            NSString *areaName = [reader objectForColumnIndex:2];
            NSString *morningStarts = [reader objectForColumnIndex:3];
            NSString *eveningEnds = [reader objectForColumnIndex:4];
            NSString *description = [reader objectForColumnIndex:5];
            
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setQIMSafeObject:areaId forKey:@"areaId"];
            [param setQIMSafeObject:enable forKey:@"enable"];
            [param setQIMSafeObject:areaName forKey:@"areaName"];
            [param setQIMSafeObject:morningStarts forKey:@"morningStarts"];
            [param setQIMSafeObject:eveningEnds forKey:@"eveningEnds"];
            [param setQIMSafeObject:description forKey:@"description"];
            [areaList addObject:param];
        }
    }];
    QIMVerboseLog(@"");
    return areaList;
}

- (void)qimDB_bulkInsertArea:(NSArray *)areaList {
    if (areaList.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO IM_TRIP_AREA (areaId,areaName,Enable,MorningStarts,EveningEnds, Description) VALUES (:areaId,:areaName,:Enable,:MorningStarts,:EveningEnds,:Description);"];
        NSMutableArray *paramList = [NSMutableArray array];
        for (NSDictionary *areaItem in areaList) {
            NSString *areaID = [areaItem objectForKey:@"areaID"];
            NSString *areaName = [areaItem objectForKey:@"areaName"];
            NSString *enable = [areaItem objectForKey:@"enable"];
            NSString *morningStarts = [areaItem objectForKey:@"morningStarts"];
            NSString *eveningEnds = [areaItem objectForKey:@"eveningEnds"];
            NSString *description = [areaItem objectForKey:@"description"];
            
            NSMutableArray *param = [NSMutableArray array];
            [param addObject:areaID?areaID:@":NULL"];
            [param addObject:areaName?areaName:@":NULL"];
            [param addObject:enable?enable:@":NULL"];
            [param addObject:morningStarts?morningStarts:@":NULL"];
            [param addObject:eveningEnds?eveningEnds:@":NULL"];
            [param addObject:description?description:@":NULL"];
            [paramList addObject:param];
        }
        [database executeBulkInsert:sql withParameters:paramList];
    }];
    QIMVerboseLog(@"");
}

@end
