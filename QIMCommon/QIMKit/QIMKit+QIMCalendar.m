//
//  QIMKit+QIMCalendar.m
//  QIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMKit+QIMCalendar.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMCalendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date {
    return [[QIMManager sharedInstance] selectTripByYearMonth:date];
}

- (void)createTrip:(NSDictionary *)param callBack:(QIMKitCreateTripBlock)callback {
    [[QIMManager sharedInstance] createTrip:param callBack:callback];
}

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(QIMKitGetTripAreaAvailableRoomBlock)callback {
    [[QIMManager sharedInstance] getTripAreaAvailableRoom:dateDic callBack:callback];
}

- (void)tripMemberCheck:(NSDictionary *)params callback:(QIMKitGetTripMemberCheckBlock)callback {
    [[QIMManager sharedInstance] tripMemberCheck:params callback:callback];
}

- (void)getAllCityList:(QIMKitGetTripAllCitysBlock)callback {
    [[QIMManager sharedInstance] getAllCityList:callback];
}

- (void)getAreaByCityId:(NSDictionary *)params :(QIMKitGetTripAreaAvailableRoomByCityIdBlock)callback {
    [[QIMManager sharedInstance] getAreaByCityId:params :callback];
}

- (NSArray *)getLocalAreaList {
    return [[QIMManager sharedInstance] getLocalAreaList];
}

- (void)getRemoteAreaList {
    [[QIMManager sharedInstance] getRemoteAreaList];
}

@end
