//
//  QIMKit+QIMDB.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit.h"

@interface QIMKit (QIMDB)

- (NSString *)getDBPathWithUserXmppId:(NSString *)userJid;
/**
 清空数据库文件
 */
- (void)removeDataBase;

/**
 关闭数据库
 */
- (void)closeDataBase;

/**
 清空数据库
 */
- (void)clearDataBase;

@end
