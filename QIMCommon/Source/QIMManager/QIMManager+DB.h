//
//  QIMManager+DB.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMManager.h"

@interface QIMManager (DB)

- (NSString *)getDBPathWithUserXmppId:(NSString *)userJid;

/**
 根据XmppId初始化数据库
 @param userJid 用户Id
 */
- (void)initDBWithUserXmppId:(NSString *)userJid;

/**
 清空数据库文件
 */
- (void)removeDataBase;

/**
 关闭数据库
 */
- (void)closeDataBase;

- (void)clearDataBase;

@end
