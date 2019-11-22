//
//  STIMKit+STIMAPPFound.h
//  STIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMKit (STIMAPPFound)

- (void)getRemoteFoundNavigation;

- (NSString *)getLocalFoundNavigation;

@end

NS_ASSUME_NONNULL_END
