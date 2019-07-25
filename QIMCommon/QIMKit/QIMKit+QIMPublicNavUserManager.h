//
//  QIMKit+QIMPublicNavUserManager.h
//  QIMCommon
//
//  Created by lilu on 2019/2/14.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMKit (QIMPublicNavUserManager)

- (void)getPublicNavCompanyWithKeyword:(NSString *)keyword withCallBack:(QIMKitgetPublicCompanySuccessedBlock)callback;

@end

NS_ASSUME_NONNULL_END
