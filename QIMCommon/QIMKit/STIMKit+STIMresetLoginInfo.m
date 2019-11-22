//
//  STIMKit+STIMresetLoginInfo.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "STIMKit+STIMresetLoginInfo.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMresetLoginInfo)

- (void)resetIP:(NSString *)ip port:(int)port domain:(NSString *)domain httpServer:(NSString *)http fileServer:(NSString *)fileServer {
    //
    // 这里可能需要判断，如果用户换了，则要重新生成用户数据的事儿
    [[STIMManager sharedInstance] resetIP:ip port:port domain:domain httpServer:http fileServer:fileServer];
}

@end
