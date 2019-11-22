//
//  IMDataManager+STIMCalendar.h
//  STIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

@interface IMDataManager (STIMCalendar)

- (NSArray *)stIMDB_SelectTripByYearMonth:(NSString *)date;

- (void)stIMDB_bulkInsertTrips:(NSArray *)trips;

- (NSArray *)stIMDB_getLocalArea;

- (void)stIMDB_bulkInsertArea:(NSArray *)areaList;

@end
