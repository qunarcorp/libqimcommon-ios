//
//  QIMManager+PublicNavUserManager.h
//  QIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

//公共域用户管理

#import "QIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMManager (PublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(QIMKitgetPublicCompanySuccessedBlock)callback;

@end

NS_ASSUME_NONNULL_END
