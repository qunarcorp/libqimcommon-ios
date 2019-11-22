//
//  STIMKit+STIMCalendar.m
//  STIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMKit+STIMCalendar.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMCalendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date {
    return [[STIMManager sharedInstance] selectTripByYearMonth:date];
}

- (void)createTrip:(NSDictionary *)param callBack:(STIMKitCreateTripBlock)callback {
    [[STIMManager sharedInstance] createTrip:param callBack:callback];
}

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(STIMKitGetTripAreaAvailableRoomBlock)callback {
    [[STIMManager sharedInstance] getTripAreaAvailableRoom:dateDic callBack:callback];
}

- (void)tripMemberCheck:(NSDictionary *)params callback:(STIMKitGetTripMemberCheckBlock)callback {
    [[STIMManager sharedInstance] tripMemberCheck:params callback:callback];
}

- (void)getAllCityList:(STIMKitGetTripAllCitysBlock)callback {
    [[STIMManager sharedInstance] getAllCityList:callback];
}

- (void)getAreaByCityId:(NSDictionary *)params :(STIMKitGetTripAreaAvailableRoomByCityIdBlock)callback {
    [[STIMManager sharedInstance] getAreaByCityId:params :callback];
}

- (NSArray *)getLocalAreaList {
    return [[STIMManager sharedInstance] getLocalAreaList];
}

- (void)getRemoteAreaList {
    [[STIMManager sharedInstance] getRemoteAreaList];
}

@end
