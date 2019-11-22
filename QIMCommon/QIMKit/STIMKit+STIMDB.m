//
//  STIMKit+STIMDB.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "STIMKit+STIMDB.h"
#import "STIMPrivateHeader.h"

@implementation STIMKit (STIMDB)

- (NSString *)getDBPathWithUserXmppId:(NSString *)userJid {
    return [[STIMManager sharedInstance] getDBPathWithUserXmppId:userJid];
}

- (void)removeDataBase {
    //关闭数据库
    [[STIMManager sharedInstance] removeDataBase];
}

- (void)closeDataBase {
    STIMWarnLog(@"关闭数据库");
    [[STIMManager sharedInstance] closeDataBase];
}

- (void)clearDataBase {
    //清理数据库
    [[STIMManager sharedInstance] clearDataBase];
}

@end
