//
//  QIMKit+QIMAPPFound.h
//  QIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMKit (QIMAPPFound)

- (void)getRemoteFoundNavigation;

- (NSString *)getLocalFoundNavigation;

@end

NS_ASSUME_NONNULL_END
