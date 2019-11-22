//
//  STIMNetworkObserver.h
//  CinCommonLibrary
//
//  Created by Grandia May on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Reachability.h"
#import <Foundation/Foundation.h>
#define kNotifyNetworkChange    @"kNotifyNetworkChange"

@interface STIMNetworkObserver : NSObject {
    Reachability *_reachAbility;
}

- (NetworkStatus) getCurrentStatus;

+(STIMNetworkObserver *) Instance;

@end
