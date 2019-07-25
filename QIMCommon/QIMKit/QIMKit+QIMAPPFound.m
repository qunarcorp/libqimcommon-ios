//
//  QIMKit+QIMAPPFound.m
//  QIMCommon
//
//  Created by lilu on 2019/4/16.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMKit+QIMAPPFound.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMAPPFound)

- (void)getRemoteFoundNavigation {
    return [[QIMManager sharedInstance] getRemoteFoundNavigation];
}

- (NSString *)getLocalFoundNavigation {
    return [[QIMManager sharedInstance] getLocalFoundNavigation];
}

@end
