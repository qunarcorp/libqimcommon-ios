//
//  QIMManager+resetLoginInfo.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMManager+resetLoginInfo.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (resetLoginInfo)

- (void)resetIP:(NSString *)ip port:(int)port domain:(NSString *)domain httpServer:(NSString *)http fileServer:(NSString *)fileServer {
    //
    // 这里可能需要判断，如果用户换了，则要重新生成用户数据的事儿
    
    [[XmppImManager sharedInstance] setDomain:domain];
    [[XmppImManager sharedInstance] setHostName:ip];
    [[XmppImManager sharedInstance] setPort:port];
}

@end
