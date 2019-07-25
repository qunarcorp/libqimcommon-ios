//
//  QIMKit+QIMPublicNavUserManager.m
//  QIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMKit+QIMPublicNavUserManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMPublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(QIMKitgetPublicCompanySuccessedBlock)callback {
    [[QIMManager sharedInstance] getPublicNavCompanyWithKeyword:keyword withCallBack:callback];
}

@end
