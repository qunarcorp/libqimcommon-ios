//
//  STIMKit+STIMPublicNavUserManager.m
//  STIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMKit+STIMPublicNavUserManager.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMPublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(STIMKitgetPublicCompanySuccessedBlock)callback {
    [[STIMManager sharedInstance] getPublicNavCompanyWithKeyword:keyword withCallBack:callback];
}

@end
