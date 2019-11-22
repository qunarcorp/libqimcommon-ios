//
//  STIMKit+STIMPublicNavUserManager.h
//  STIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMKit (STIMPublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(STIMKitgetPublicCompanySuccessedBlock)callback;

@end

NS_ASSUME_NONNULL_END
