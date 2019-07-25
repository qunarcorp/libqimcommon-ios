//
//  QIMManager+MiddleVirtualAccountManager.h
//  QIMCommon
//
//  Created by 李露 on 10/30/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMManager (MiddleVirtualAccountManager)

- (NSArray *)getMiddleVirtualAccounts;

- (BOOL)isMiddleVirtualAccountWithJid:(NSString *)jid;

@end

NS_ASSUME_NONNULL_END
