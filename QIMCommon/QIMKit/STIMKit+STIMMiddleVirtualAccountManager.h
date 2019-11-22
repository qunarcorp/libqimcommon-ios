//
//  STIMKit+STIMMiddleVirtualAccountManager.h
//  STIMCommon
//
//  Created by 李露 on 10/30/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface STIMKit (STIMMiddleVirtualAccountManager)

- (NSArray *)getMiddleVirtualAccounts;

- (BOOL)isMiddleVirtualAccountWithJid:(NSString *)jid;

@end

NS_ASSUME_NONNULL_END
