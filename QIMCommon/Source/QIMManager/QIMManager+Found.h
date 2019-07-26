//
//  QIMManager+Found.h
//  QIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMManager (Found)

- (void)getRemoteFoundNavigation;

- (NSString *)getLocalFoundNavigation;

@end

NS_ASSUME_NONNULL_END
