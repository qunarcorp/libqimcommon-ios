//
//  STIMKit+STIMAPPFound.m
//  STIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMKit+STIMAPPFound.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMAPPFound)

- (void)getRemoteFoundNavigation {
    return [[STIMManager sharedInstance] getRemoteFoundNavigation];
}

- (NSString *)getLocalFoundNavigation {
    return [[STIMManager sharedInstance] getLocalFoundNavigation];
}

@end
