//
//  STIMManager+PublicNavUserManager.h
//  STIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 STIM. All rights reserved.
//

//公共域用户管理

#import "STIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMManager (PublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(STIMKitgetPublicCompanySuccessedBlock)callback;

@end

NS_ASSUME_NONNULL_END
