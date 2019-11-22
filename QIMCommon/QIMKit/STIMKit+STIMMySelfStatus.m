//
//  STIMKit+STIMMySelfStatus.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "STIMKit+STIMMySelfStatus.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMMySelfStatus)

- (void)goOnline {
    
    [[STIMManager sharedInstance] goOnline];
}

- (void)goAway {
    
    [[STIMManager sharedInstance] goAway];
}

- (void)goDnd {
    
    [[STIMManager sharedInstance] goDnd];
}

- (void)goOffline {
    
    [[STIMManager sharedInstance] quitLogin];
}

- (void)deactiveReconnect {
    [[STIMManager sharedInstance] deactiveReconnect];
    
}

- (void)activeReconnect {
    [[STIMManager sharedInstance] activeReconnect];
}

@end
