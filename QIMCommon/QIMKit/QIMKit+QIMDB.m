//
//  QIMKit+QIMDB.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit+QIMDB.h"
#import "QIMPrivateHeader.h"

@implementation QIMKit (QIMDB)

- (void)initDB {
    [[QIMManager sharedInstance] initDB];
}

- (void)removeDataBase {
    //关闭数据库
    [[QIMManager sharedInstance] removeDataBase];
}

- (void)closeDataBase {
    QIMWarnLog(@"关闭数据库");
    [[QIMManager sharedInstance] closeDataBase];
}

- (void)clearDataBase {
    //清理数据库
    [[QIMManager sharedInstance] clearDataBase];
}

@end
