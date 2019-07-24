//
//  QIMManager+MySelfStatus.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMManager+MySelfStatus.h"
#import "XmppImManager.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (MySelfStatus)

- (void)goOnline {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
       [[XmppImManager sharedInstance] goChat];
    });
}

- (void)goAway {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [[XmppImManager sharedInstance] goAway];
    });
}

- (void)goDnd {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [[XmppImManager sharedInstance] goDnd];
    });
}

- (void)goOffline {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

        [[XmppImManager sharedInstance] quitLogin];
    });
}

- (void)deactiveReconnect {
    [[XmppImManager sharedInstance] deactiveReconnect];
    
}

- (void)activeReconnect {
    [[XmppImManager sharedInstance] activeReconnect];
}

@end
