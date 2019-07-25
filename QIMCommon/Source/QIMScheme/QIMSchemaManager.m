//
//  QIMSchemaManager.m
//  QIMCommon
//
//  Created by 李露 on 2018/9/11.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMSchemaManager.h"

@interface QIMSchemaManager ()

@property (nonatomic, strong) NSMutableSet *schemas;

@end

@implementation QIMSchemaManager

#pragma mark - setter and getter

- (NSMutableSet *)schemas {
    if (!_schemas) {
        _schemas = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _schemas;
}

static QIMSchemaManager *__manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[QIMSchemaManager alloc] init];
        [__manager registerSchemas];
    });
    return __manager;
}

- (BOOL)isLocalSchemaWithUrl:(NSString *)url {
    return [self.schemas containsObject:url];
}

- (void)registerSchemas {
 
    [self.schemas addObject:@"qtalkaphone://start_qtalk_activity"];
    [self.schemas addObject:@"qtalkaphone://rnsearch"];
    [self.schemas addObject:@"qtalkaphone://router/openHome"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/openGroupChat"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/openSingleChat"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/headLine"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/openGroupChatInfo"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/openSingleChatInfo"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/openUserCard"];
    
    [self.schemas addObject:@"qtalkaphone://qunarchat/hongbao"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/hongbao_balance"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/account_info"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/unreadList"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/publicNumber"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/openOrganizational"];
    [self.schemas addObject:@"qtalkaphone://qunarchat/myfile"];
    [self.schemas addObject:@"qtalkaphone://rnservice"];
    [self.schemas addObject:@"qtalkaphone://qrcode"];
    [self.schemas addObject:@"qtalkaphone://logout"];
    [self.schemas addObject:@"qtalkaphone://accountSwitch"];
}

- (void)postSchemaNotificationWithUrl:(NSURL *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QIMSchemaNotification" object:url];
    });
}

@end
