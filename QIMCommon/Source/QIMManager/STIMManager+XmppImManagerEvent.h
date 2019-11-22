//
//  STIMManager+XmppImManagerEvent.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "STIMManager.h"

@interface STIMManager (XmppImManagerEvent)

- (void)registerEvent;

- (void)userMucListUpdate:(NSDictionary *)mucListDic;

- (void)onReadState:(NSDictionary *)infoDic;

+ (void)stimDB_privateCommonLog:(NSString *)log;

@end
