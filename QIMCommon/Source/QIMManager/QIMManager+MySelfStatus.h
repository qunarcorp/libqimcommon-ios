//
//  QIMManager+MySelfStatus.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/1.
//

#import "QIMManager.h"

@interface QIMManager (MySelfStatus)

/**
 上线
 */
- (void)goOnline;

/**
 离开
 */
- (void)goAway;

/**
 忙碌
 */
- (void)goDnd;

/**
 下线
 */
- (void)goOffline;

- (void) deactiveReconnect;

- (void) activeReconnect;

@end
