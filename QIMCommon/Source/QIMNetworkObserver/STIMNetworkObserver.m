//
//  STIMNetworkObserver.m
//  CinCommonLibrary
//
//  Created by Grandia May on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "STIMNetworkObserver.h"
#import "STIMPublicRedefineHeader.h"

static STIMNetworkObserver *_global_network_observer_ = nil;

@implementation STIMNetworkObserver

+(STIMNetworkObserver *)Instance {
    @synchronized(self) {
        if (_global_network_observer_ == nil)
            _global_network_observer_ = [[STIMNetworkObserver alloc] init];
        return _global_network_observer_;
    }
}

- (void) onReachabilityChanged:(NSNotification *) notification {
    Reachability* reachability = [notification object];
    NetworkStatus status = [reachability currentReachabilityStatus];
    STIMVerboseLog(@"抛出通知 : kNotifyNetworkChange");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyNetworkChange object:[NSNumber numberWithInt:status]];
}

- (NetworkStatus)getCurrentStatus {
    return [_reachAbility currentReachabilityStatus];
}

- (id)init {
    
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(onReachabilityChanged:) 
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        _reachAbility = [Reachability reachabilityForInternetConnection];
        [_reachAbility startNotifier];
    }
    return self;
}

- (void)dealloc {
    
    [_reachAbility stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
@end
