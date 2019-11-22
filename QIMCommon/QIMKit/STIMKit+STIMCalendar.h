//
//  STIMKit+STIMCalendar.h
//  STIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit.h"

@interface STIMKit (STIMCalendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date;

- (void)createTrip:(NSDictionary *)param callBack:(STIMKitCreateTripBlock)callback;

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(STIMKitGetTripAreaAvailableRoomBlock)callback;

- (void)tripMemberCheck:(NSDictionary *)params callback:(STIMKitGetTripMemberCheckBlock)callback;

- (void)getAllCityList:(STIMKitGetTripAllCitysBlock)callback;

- (void)getAreaByCityId:(NSDictionary *)params :(STIMKitGetTripAreaAvailableRoomByCityIdBlock)callback;

- (NSArray *)getLocalAreaList;

- (void)getRemoteAreaList;

@end
