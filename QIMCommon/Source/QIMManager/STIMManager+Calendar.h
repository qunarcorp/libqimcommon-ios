//
//  STIMManager+Calendar.h
//  STIMCommon
//
//  Created by 李露 on 2018/9/6.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMManager.h"
#import "STIMPrivateHeader.h"

@interface STIMManager (Calendar)

- (NSArray *)selectTripByYearMonth:(NSString *)date;

- (void)getRemoteUserTripList;

- (void)createTrip:(NSDictionary *)param callBack:(STIMKitCreateTripBlock)callback;

- (void)getTripAreaAvailableRoom:(NSDictionary *)dateDic callBack:(STIMKitGetTripAreaAvailableRoomBlock)callback;

- (void)tripMemberCheck:(NSDictionary *)params callback:(STIMKitGetTripMemberCheckBlock)callback;

- (void)getAllCityList:(STIMKitGetTripAllCitysBlock)callback;

- (void)getAreaByCityId:(NSDictionary *)params :(STIMKitGetTripAreaAvailableRoomByCityIdBlock)callback;

- (NSArray *)getLocalAreaList;

- (void)getRemoteAreaList;

@end
