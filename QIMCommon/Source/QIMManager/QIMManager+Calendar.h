//
//  QIMManager+Calendar.h
//  QIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

@interface QIMManager (Calendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date;

- (void)getRemoteUserTripList;

- (void)createTrip:(NSDictionary *)param callBack:(QIMKitCreateTripBlock)callback;

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(QIMKitGetTripAreaAvailableRoomBlock)callback;

- (void)tripMemberCheck:(NSDictionary *)params callback:(QIMKitGetTripMemberCheckBlock)callback;

- (void)getAllCityList:(QIMKitGetTripAllCitysBlock)callback;

- (void)getAreaByCityId:(NSDictionary *)params :(QIMKitGetTripAreaAvailableRoomByCityIdBlock)callback;

- (NSArray *)getLocalAreaList;

- (void)getRemoteAreaList;

@end
