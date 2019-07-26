//
//  QIMKit+QIMMySelfStatus.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMKit+QIMMySelfStatus.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMMySelfStatus)

- (void)goOnline {
    
    [[QIMManager sharedInstance] goOnline];
}

- (void)goAway {
    
    [[QIMManager sharedInstance] goAway];
}

- (void)goDnd {
    
    [[QIMManager sharedInstance] goDnd];
}

- (void)goOffline {
    
    [[QIMManager sharedInstance] quitLogin];
}

- (void)deactiveReconnect {
    [[QIMManager sharedInstance] deactiveReconnect];
    
}

- (void)activeReconnect {
    [[QIMManager sharedInstance] activeReconnect];
}

@end
